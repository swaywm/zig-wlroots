const std = @import("std");
const os = std.os;

const wl = @import("wayland").server.wl;

const wlr = @import("wlroots");
const xkb = @import("xkbcommon");

const gpa = std.heap.c_allocator;

pub fn main() anyerror!void {
    wlr.log.init(.debug);

    var startup_cmd: ?[]const u8 = null;
    if (os.argv.len >= 2) startup_cmd = std.mem.span(os.argv[1]);

    var server: Server = undefined;
    try server.init();
    defer server.deinit();

    var buf: [11]u8 = undefined;
    const socket = try server.wl_server.addSocketAuto(&buf);

    if (startup_cmd) |cmd| {
        const child = try std.ChildProcess.init(&[_][]const u8{ "/bin/sh", "-c", cmd }, gpa);
        var env_map = try std.process.getEnvMap(gpa);
        try env_map.set("WAYLAND_DISPLAY", socket);
        child.env_map = &env_map;
        try child.spawn();
        // TODO kill child
    }

    if (!server.backend.start()) return error.BackendStartFailed;

    std.log.info("Runnnig compositor on WAYLAND_DISPLAY={}", .{socket});
    server.wl_server.run();
}

const Server = struct {
    wl_server: *wl.Server,
    backend: *wlr.Backend,
    renderer: *wlr.Renderer,

    output_layout: *wlr.OutputLayout,
    outputs: std.TailQueue(Output) = .{},
    new_output: wl.Listener(*wlr.Output) = undefined,

    xdg_shell: *wlr.XdgShell,
    new_xdg_surface: wl.Listener(*wlr.XdgSurface) = undefined,
    views: std.TailQueue(View) = .{},

    seat: *wlr.Seat,
    new_input: wl.Listener(*wlr.InputDevice) = undefined,
    request_set_cursor: wl.Listener(*wlr.Seat.event.RequestSetCursor) = undefined,
    request_set_selection: wl.Listener(*wlr.Seat.event.RequestSetSelection) = undefined,
    keyboards: std.TailQueue(Keyboard) = .{},

    cursor: *wlr.Cursor,
    cursor_mgr: *wlr.XCursorManager,
    cursor_motion: wl.Listener(*wlr.Pointer.event.Motion) = undefined,
    cursor_motion_absolute: wl.Listener(*wlr.Pointer.event.MotionAbsolute) = undefined,
    cursor_button: wl.Listener(*wlr.Pointer.event.Button) = undefined,
    cursor_axis: wl.Listener(*wlr.Pointer.event.Axis) = undefined,
    cursor_frame: wl.Listener(*wlr.Cursor) = undefined,

    cursor_mode: enum { passthrough, move, resize } = .passthrough,
    grabbed_view: ?*View = null,
    grab_x: f64 = 0,
    grab_y: f64 = 0,
    grab_box: wlr.Box = undefined,
    resize_edges: u32 = 0,

    fn init(server: *Server) !void {
        const wl_server = try wl.Server.create();
        const backend = wlr.Backend.autocreate(wl_server, null) orelse return error.BackendCreateFailed;
        server.* = .{
            .wl_server = wl_server,
            .backend = backend,
            .renderer = backend.getRenderer() orelse return error.GetRendererFailed,
            .output_layout = wlr.OutputLayout.create() orelse return error.OutOfMemory,
            .xdg_shell = wlr.XdgShell.create(wl_server) orelse return error.OutOfMemory,
            .seat = wlr.Seat.create(wl_server, "default") orelse return error.OutOfMemory,
            .cursor = wlr.Cursor.create() orelse return error.OutOfMemory,
            .cursor_mgr = wlr.XCursorManager.create(null, 24) orelse return error.OutOfMemory,
        };

        if (!server.renderer.initServer(wl_server)) return error.InitRendererFailed;

        _ = wlr.Compositor.create(server.wl_server, server.renderer) orelse return error.OutOfMemory;
        _ = wlr.DataDeviceManager.create(server.wl_server) orelse return error.OutOfMemory;

        server.new_output.setNotify(newOutput);
        server.backend.events.new_output.add(&server.new_output);

        server.new_xdg_surface.setNotify(newXdgSurface);
        server.xdg_shell.events.new_surface.add(&server.new_xdg_surface);

        server.new_input.setNotify(newInput);
        server.backend.events.new_input.add(&server.new_input);
        server.request_set_cursor.setNotify(requestSetCursor);
        server.seat.events.request_set_cursor.add(&server.request_set_cursor);
        server.request_set_selection.setNotify(requestSetSelection);
        server.seat.events.request_set_selection.add(&server.request_set_selection);

        server.cursor.attachOutputLayout(server.output_layout);
        if (!server.cursor_mgr.load(1)) return error.CantLoadXCursorTheme;
        server.cursor_motion.setNotify(cursorMotion);
        server.cursor.events.motion.add(&server.cursor_motion);
        server.cursor_motion_absolute.setNotify(cursorMotionAbsolute);
        server.cursor.events.motion_absolute.add(&server.cursor_motion_absolute);
        server.cursor_button.setNotify(cursorButton);
        server.cursor.events.button.add(&server.cursor_button);
        server.cursor_axis.setNotify(cursorAxis);
        server.cursor.events.axis.add(&server.cursor_axis);
        server.cursor_frame.setNotify(cursorFrame);
        server.cursor.events.frame.add(&server.cursor_frame);
    }

    fn deinit(server: *Server) void {
        server.wl_server.destroyClients();
        server.wl_server.destroy();
        server.backend.destroy();
    }

    fn newOutput(listener: *wl.Listener(*wlr.Output), wlr_output: *wlr.Output) void {
        const server = @fieldParentPtr(Server, "new_output", listener);

        if (wlr_output.preferredMode()) |mode| {
            wlr_output.setMode(mode);
            wlr_output.enable(true);
            if (!wlr_output.commit()) return;
        }

        const node = gpa.create(std.TailQueue(Output).Node) catch @panic("out of memory");
        const output = &node.data;

        output.* = .{
            .server = server,
            .wlr_output = wlr_output,
        };

        output.frame.setNotify(Output.frame);
        wlr_output.events.frame.add(&output.frame);

        server.output_layout.addAuto(wlr_output);
        server.outputs.append(node);
    }

    fn newXdgSurface(listener: *wl.Listener(*wlr.XdgSurface), xdg_surface: *wlr.XdgSurface) void {
        const server = @fieldParentPtr(Server, "new_xdg_surface", listener);

        if (xdg_surface.role != .toplevel) return;

        // Don't add the view to server.views until it is mapped
        const node = gpa.create(std.TailQueue(View).Node) catch @panic("out of memory");
        const view = &node.data;

        view.* = .{
            .server = server,
            .xdg_surface = xdg_surface,
        };

        view.map.setNotify(View.map);
        xdg_surface.events.map.add(&view.map);
        view.unmap.setNotify(View.unmap);
        xdg_surface.events.unmap.add(&view.unmap);
        view.destroy.setNotify(View.destroy);
        xdg_surface.events.destroy.add(&view.destroy);
        view.request_move.setNotify(View.requestMove);
        xdg_surface.role_data.toplevel.events.request_move.add(&view.request_move);
        view.request_resize.setNotify(View.requestResize);
        xdg_surface.role_data.toplevel.events.request_resize.add(&view.request_resize);
    }

    fn newInput(listener: *wl.Listener(*wlr.InputDevice), device: *wlr.InputDevice) void {
        const server = @fieldParentPtr(Server, "new_input", listener);
        switch (device.type) {
            .keyboard => {
                Keyboard.create(server, device) catch @panic("TOOD: log and return");
            },
            .pointer => server.cursor.attachInputDevice(device),
            else => {},
        }

        var caps: u32 = @enumToInt(wl.Seat.Capability.pointer);
        if (server.keyboards.len > 0)
            caps |= @as(u32, @enumToInt(wl.Seat.Capability.keyboard));
        server.seat.setCapabilities(caps);
    }

    fn requestSetCursor(
        listener: *wl.Listener(*wlr.Seat.event.RequestSetCursor),
        event: *wlr.Seat.event.RequestSetCursor,
    ) void {
        const server = @fieldParentPtr(Server, "request_set_cursor", listener);
        // TODO
    }

    fn requestSetSelection(
        listener: *wl.Listener(*wlr.Seat.event.RequestSetSelection),
        event: *wlr.Seat.event.RequestSetSelection,
    ) void {
        const server = @fieldParentPtr(Server, "request_set_selection", listener);
        // TODO
    }

    fn cursorMotion(
        listener: *wl.Listener(*wlr.Pointer.event.Motion),
        data: *wlr.Pointer.event.Motion,
    ) void {
        const server = @fieldParentPtr(Server, "cursor_motion", listener);
        // TODO
    }

    fn cursorMotionAbsolute(
        listener: *wl.Listener(*wlr.Pointer.event.MotionAbsolute),
        data: *wlr.Pointer.event.MotionAbsolute,
    ) void {
        const server = @fieldParentPtr(Server, "cursor_motion_absolute", listener);
        // TODO
    }

    fn cursorButton(
        listener: *wl.Listener(*wlr.Pointer.event.Button),
        data: *wlr.Pointer.event.Button,
    ) void {
        const server = @fieldParentPtr(Server, "cursor_button", listener);
        // TODO
    }

    fn cursorAxis(
        listener: *wl.Listener(*wlr.Pointer.event.Axis),
        data: *wlr.Pointer.event.Axis,
    ) void {
        const server = @fieldParentPtr(Server, "cursor_axis", listener);
        // TODO
    }

    fn cursorFrame(listener: *wl.Listener(*wlr.Cursor), data: *wlr.Cursor) void {
        const server = @fieldParentPtr(Server, "cursor_frame", listener);
        // TODO
    }

    fn handleKeybind(server: *Server, key: xkb.Keysym) bool {
        switch (key) {
            .Escape => server.wl_server.terminate(),
            // TODO: cycle views
            else => return false,
        }
        return true;
    }
};

const Output = struct {
    server: *Server,
    wlr_output: *wlr.Output,

    frame: wl.Listener(*wlr.Output) = undefined,

    fn frame(listener: *wl.Listener(*wlr.Output), wlr_output: *wlr.Output) void {
        const output = @fieldParentPtr(Output, "frame", listener);
        // TODO
    }
};

const View = struct {
    server: *Server,
    xdg_surface: *wlr.XdgSurface,

    x: i32 = 0,
    y: i32 = 0,

    map: wl.Listener(*wlr.XdgSurface) = undefined,
    unmap: wl.Listener(*wlr.XdgSurface) = undefined,
    destroy: wl.Listener(*wlr.XdgSurface) = undefined,
    request_move: wl.Listener(*wlr.XdgToplevel.event.Move) = undefined,
    request_resize: wl.Listener(*wlr.XdgToplevel.event.Resize) = undefined,

    fn map(listener: *wl.Listener(*wlr.XdgSurface), xdg_surface: *wlr.XdgSurface) void {
        const view = @fieldParentPtr(View, "map", listener);
        const node = @fieldParentPtr(std.TailQueue(View).Node, "data", view);
        view.server.views.append(node);
        // TODO: focus view
    }

    fn unmap(listener: *wl.Listener(*wlr.XdgSurface), xdg_surface: *wlr.XdgSurface) void {
        const view = @fieldParentPtr(View, "unmap", listener);
        const node = @fieldParentPtr(std.TailQueue(View).Node, "data", view);
        view.server.views.remove(node);
    }

    fn destroy(listener: *wl.Listener(*wlr.XdgSurface), xdg_surface: *wlr.XdgSurface) void {
        const view = @fieldParentPtr(View, "destroy", listener);
        const node = @fieldParentPtr(std.TailQueue(View).Node, "data", view);
        gpa.destroy(node);
    }

    fn requestMove(
        listener: *wl.Listener(*wlr.XdgToplevel.event.Move),
        event: *wlr.XdgToplevel.event.Move,
    ) void {
        const view = @fieldParentPtr(View, "request_move", listener);
        // TODO
    }

    fn requestResize(
        listener: *wl.Listener(*wlr.XdgToplevel.event.Resize),
        event: *wlr.XdgToplevel.event.Resize,
    ) void {
        const view = @fieldParentPtr(View, "request_resize", listener);
        // TODO
    }
};

const Keyboard = struct {
    server: *Server,
    device: *wlr.InputDevice,

    modifiers: wl.Listener(*wlr.Keyboard) = undefined,
    key: wl.Listener(*wlr.Keyboard.event.Key) = undefined,

    fn create(server: *Server, device: *wlr.InputDevice) !void {
        const node = try gpa.create(std.TailQueue(Keyboard).Node);
        errdefer gpa.destroy(node);

        const keyboard = &node.data;
        keyboard.* = .{
            .server = server,
            .device = device,
        };

        const context = xkb.Context.new(.no_flags) orelse return error.ContextFailed;
        defer context.unref();
        const keymap = xkb.Keymap.newFromNames(context, null, .no_flags) orelse return error.KeymapFailed;
        defer keymap.unref();

        const wlr_keyboard = device.device.keyboard;
        if (!wlr_keyboard.setKeymap(keymap)) return error.SetKeymapFailed;
        wlr_keyboard.setRepeatInfo(25, 600);

        keyboard.modifiers.setNotify(modifiers);
        wlr_keyboard.events.modifiers.add(&keyboard.modifiers);
        keyboard.key.setNotify(key);
        wlr_keyboard.events.key.add(&keyboard.key);

        server.seat.setKeyboard(device);
        server.keyboards.append(node);
    }

    fn modifiers(listener: *wl.Listener(*wlr.Keyboard), wlr_keyboard: *wlr.Keyboard) void {
        const keyboard = @fieldParentPtr(Keyboard, "modifiers", listener);
        keyboard.server.seat.setKeyboard(keyboard.device);
        keyboard.server.seat.keyboardNotifyModifiers(&wlr_keyboard.modifiers);
    }

    fn key(listener: *wl.Listener(*wlr.Keyboard.event.Key), event: *wlr.Keyboard.event.Key) void {
        const keyboard = @fieldParentPtr(Keyboard, "key", listener);
        const wlr_keyboard = keyboard.device.device.keyboard;

        // Translate libinput keycode -> xkbcommon
        const keycode = event.keycode + 8;

        var syms: ?[*]xkb.Keysym = undefined;
        const nsyms = wlr_keyboard.xkb_state.?.keyGetSyms(keycode, &syms);

        var handled = false;
        const modmask = wlr_keyboard.getModifiers();
        if (nsyms > 0 and modmask.alt and event.state == .pressed) {
            for (syms.?[0..@intCast(usize, nsyms)]) |sym| {
                if (keyboard.server.handleKeybind(sym)) {
                    handled = true;
                    break;
                }
            }
        }

        if (!handled) {
            keyboard.server.seat.setKeyboard(keyboard.device);
            keyboard.server.seat.keyboardNotifyKey(event.time_msec, event.keycode, event.state);
        }
    }
};
