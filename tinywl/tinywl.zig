const std = @import("std");
const os = std.os;

const wl = @import("wayland").server.wl;

const wlr = @import("wlroots");
const xkb = @import("xkbcommon");

const gpa = std.heap.c_allocator;

pub fn main() anyerror!void {
    wlr.log.init(.debug);

    var server: Server = undefined;
    try server.init();
    defer server.deinit();

    var buf: [11]u8 = undefined;
    const socket = try server.wl_server.addSocketAuto(&buf);

    if (os.argv.len >= 2) {
        const cmd = std.mem.span(os.argv[1]);
        var child = try std.ChildProcess.init(&[_][]const u8{ "/bin/sh", "-c", cmd }, gpa);
        defer child.deinit();
        var env_map = try std.process.getEnvMap(gpa);
        defer env_map.deinit();
        try env_map.set("WAYLAND_DISPLAY", socket);
        child.env_map = &env_map;
        try child.spawn();
    }

    try server.backend.start();

    std.log.info("Running compositor on WAYLAND_DISPLAY={}", .{socket});
    server.wl_server.run();
}

const Server = struct {
    wl_server: *wl.Server,
    backend: *wlr.Backend,
    renderer: *wlr.Renderer,

    output_layout: *wlr.OutputLayout,
    new_output: wl.Listener(*wlr.Output) = wl.Listener(*wlr.Output).init(newOutput),

    xdg_shell: *wlr.XdgShell,
    new_xdg_surface: wl.Listener(*wlr.XdgSurface) = wl.Listener(*wlr.XdgSurface).init(newXdgSurface),
    views: wl.list.Head(View, "link") = undefined,

    seat: *wlr.Seat,
    new_input: wl.Listener(*wlr.InputDevice) = wl.Listener(*wlr.InputDevice).init(newInput),
    request_set_cursor: wl.Listener(*wlr.Seat.event.RequestSetCursor) = wl.Listener(*wlr.Seat.event.RequestSetCursor).init(requestSetCursor),
    request_set_selection: wl.Listener(*wlr.Seat.event.RequestSetSelection) = wl.Listener(*wlr.Seat.event.RequestSetSelection).init(requestSetSelection),
    keyboards: wl.list.Head(Keyboard, "link") = undefined,

    cursor: *wlr.Cursor,
    cursor_mgr: *wlr.XcursorManager,
    cursor_motion: wl.Listener(*wlr.Pointer.event.Motion) = wl.Listener(*wlr.Pointer.event.Motion).init(cursorMotion),
    cursor_motion_absolute: wl.Listener(*wlr.Pointer.event.MotionAbsolute) = wl.Listener(*wlr.Pointer.event.MotionAbsolute).init(cursorMotionAbsolute),
    cursor_button: wl.Listener(*wlr.Pointer.event.Button) = wl.Listener(*wlr.Pointer.event.Button).init(cursorButton),
    cursor_axis: wl.Listener(*wlr.Pointer.event.Axis) = wl.Listener(*wlr.Pointer.event.Axis).init(cursorAxis),
    cursor_frame: wl.Listener(*wlr.Cursor) = wl.Listener(*wlr.Cursor).init(cursorFrame),

    cursor_mode: enum { passthrough, move, resize } = .passthrough,
    grabbed_view: ?*View = null,
    grab_x: f64 = 0,
    grab_y: f64 = 0,
    grab_box: wlr.Box = undefined,
    resize_edges: wlr.Edges = .{},

    fn init(server: *Server) !void {
        const wl_server = try wl.Server.create();
        const backend = try wlr.Backend.autocreate(wl_server, null);
        server.* = .{
            .wl_server = wl_server,
            .backend = backend,
            .renderer = backend.getRenderer() orelse return error.GetRendererFailed,
            .output_layout = try wlr.OutputLayout.create(),
            .xdg_shell = try wlr.XdgShell.create(wl_server),
            .seat = try wlr.Seat.create(wl_server, "default"),
            .cursor = try wlr.Cursor.create(),
            .cursor_mgr = try wlr.XcursorManager.create(null, 24),
        };

        try server.renderer.initServer(wl_server);

        _ = try wlr.Compositor.create(server.wl_server, server.renderer);
        _ = try wlr.DataDeviceManager.create(server.wl_server);

        server.backend.events.new_output.add(&server.new_output);

        server.xdg_shell.events.new_surface.add(&server.new_xdg_surface);
        server.views.init();

        server.backend.events.new_input.add(&server.new_input);
        server.seat.events.request_set_cursor.add(&server.request_set_cursor);
        server.seat.events.request_set_selection.add(&server.request_set_selection);
        server.keyboards.init();

        server.cursor.attachOutputLayout(server.output_layout);
        try server.cursor_mgr.load(1);
        server.cursor.events.motion.add(&server.cursor_motion);
        server.cursor.events.motion_absolute.add(&server.cursor_motion_absolute);
        server.cursor.events.button.add(&server.cursor_button);
        server.cursor.events.axis.add(&server.cursor_axis);
        server.cursor.events.frame.add(&server.cursor_frame);
    }

    fn deinit(server: *Server) void {
        server.wl_server.destroyClients();
        server.wl_server.destroy();
    }

    fn newOutput(listener: *wl.Listener(*wlr.Output), wlr_output: *wlr.Output) void {
        const server = @fieldParentPtr(Server, "new_output", listener);

        if (wlr_output.preferredMode()) |mode| {
            wlr_output.setMode(mode);
            wlr_output.enable(true);
            wlr_output.commit() catch return;
        }

        const output = gpa.create(Output) catch {
            std.log.crit("failed to allocate new output", .{});
            return;
        };

        output.* = .{
            .server = server,
            .wlr_output = wlr_output,
        };

        wlr_output.events.frame.add(&output.frame);

        server.output_layout.addAuto(wlr_output);
    }

    fn newXdgSurface(listener: *wl.Listener(*wlr.XdgSurface), xdg_surface: *wlr.XdgSurface) void {
        const server = @fieldParentPtr(Server, "new_xdg_surface", listener);

        if (xdg_surface.role != .toplevel) return;

        // Don't add the view to server.views until it is mapped
        const view = gpa.create(View) catch {
            std.log.crit("failed to allocate new view", .{});
            return;
        };

        view.* = .{
            .server = server,
            .xdg_surface = xdg_surface,
        };

        xdg_surface.events.map.add(&view.map);
        xdg_surface.events.unmap.add(&view.unmap);
        xdg_surface.events.destroy.add(&view.destroy);
        xdg_surface.role_data.toplevel.events.request_move.add(&view.request_move);
        xdg_surface.role_data.toplevel.events.request_resize.add(&view.request_resize);
    }

    const ViewAtResult = struct {
        view: *View,
        surface: *wlr.Surface,
        sx: f64,
        sy: f64,
    };

    fn viewAt(server: *Server, lx: f64, ly: f64) ?ViewAtResult {
        var it = server.views.iterator(.forward);
        while (it.next()) |view| {
            var sx: f64 = undefined;
            var sy: f64 = undefined;
            const x = lx - @intToFloat(f64, view.x);
            const y = ly - @intToFloat(f64, view.y);
            if (view.xdg_surface.surfaceAt(x, y, &sx, &sy)) |surface| {
                return ViewAtResult{
                    .view = view,
                    .surface = surface,
                    .sx = sx,
                    .sy = sy,
                };
            }
        }
        return null;
    }

    fn focusView(server: *Server, view: *View, surface: *wlr.Surface) void {
        if (server.seat.keyboard_state.focused_surface) |previous_surface| {
            if (previous_surface == surface) return;
            if (previous_surface.isXdgSurface()) {
                const xdg_surface = wlr.XdgSurface.fromWlrSurface(previous_surface);
                _ = xdg_surface.role_data.toplevel.setActivated(false);
            }
        }

        view.link.remove();
        server.views.prepend(view);

        _ = view.xdg_surface.role_data.toplevel.setActivated(true);

        const wlr_keyboard = server.seat.getKeyboard() orelse return;
        server.seat.keyboardNotifyEnter(
            surface,
            &wlr_keyboard.keycodes,
            wlr_keyboard.num_keycodes,
            &wlr_keyboard.modifiers,
        );
    }

    fn newInput(listener: *wl.Listener(*wlr.InputDevice), device: *wlr.InputDevice) void {
        const server = @fieldParentPtr(Server, "new_input", listener);
        switch (device.type) {
            .keyboard => Keyboard.create(server, device) catch |err| {
                std.log.err("failed to create keyboard: {}", .{err});
                return;
            },
            .pointer => server.cursor.attachInputDevice(device),
            else => {},
        }

        server.seat.setCapabilities(.{
            .pointer = true,
            .keyboard = server.keyboards.length() > 0,
        });
    }

    fn requestSetCursor(
        listener: *wl.Listener(*wlr.Seat.event.RequestSetCursor),
        event: *wlr.Seat.event.RequestSetCursor,
    ) void {
        const server = @fieldParentPtr(Server, "request_set_cursor", listener);
        if (event.seat_client == server.seat.pointer_state.focused_client)
            server.cursor.setSurface(event.surface, event.hotspot_x, event.hotspot_y);
    }

    fn requestSetSelection(
        listener: *wl.Listener(*wlr.Seat.event.RequestSetSelection),
        event: *wlr.Seat.event.RequestSetSelection,
    ) void {
        const server = @fieldParentPtr(Server, "request_set_selection", listener);
        server.seat.setSelection(event.source, event.serial);
    }

    fn cursorMotion(
        listener: *wl.Listener(*wlr.Pointer.event.Motion),
        event: *wlr.Pointer.event.Motion,
    ) void {
        const server = @fieldParentPtr(Server, "cursor_motion", listener);
        server.cursor.move(event.device, event.delta_x, event.delta_y);
        server.processCursorMotion(event.time_msec);
    }

    fn cursorMotionAbsolute(
        listener: *wl.Listener(*wlr.Pointer.event.MotionAbsolute),
        event: *wlr.Pointer.event.MotionAbsolute,
    ) void {
        const server = @fieldParentPtr(Server, "cursor_motion_absolute", listener);
        server.cursor.warpAbsolute(event.device, event.x, event.y);
        server.processCursorMotion(event.time_msec);
    }

    fn processCursorMotion(server: *Server, time_msec: u32) void {
        switch (server.cursor_mode) {
            .passthrough => if (server.viewAt(server.cursor.x, server.cursor.y)) |res| {
                server.seat.pointerNotifyEnter(res.surface, res.sx, res.sy);
                server.seat.pointerNotifyMotion(time_msec, res.sx, res.sy);
            } else {
                server.cursor_mgr.setCursorImage("left_ptr", server.cursor);
                server.seat.pointerClearFocus();
            },
            .move => {
                server.grabbed_view.?.x = @floatToInt(i32, server.cursor.x - server.grab_x);
                server.grabbed_view.?.y = @floatToInt(i32, server.cursor.y - server.grab_y);
            },
            .resize => {
                const view = server.grabbed_view.?;
                const border_x = @floatToInt(i32, server.cursor.x - server.grab_x);
                const border_y = @floatToInt(i32, server.cursor.y - server.grab_y);

                var new_left = server.grab_box.x;
                var new_right = server.grab_box.x + server.grab_box.width;
                var new_top = server.grab_box.y;
                var new_bottom = server.grab_box.y + server.grab_box.height;

                if (server.resize_edges.top) {
                    new_top = border_y;
                    if (new_top >= new_bottom)
                        new_top = new_bottom - 1;
                } else if (server.resize_edges.bottom) {
                    new_bottom = border_y;
                    if (new_bottom <= new_top)
                        new_bottom = new_top + 1;
                }

                if (server.resize_edges.left) {
                    new_left = border_x;
                    if (new_left >= new_right)
                        new_left = new_right - 1;
                } else if (server.resize_edges.right) {
                    new_right = border_x;
                    if (new_right <= new_left)
                        new_right = new_left + 1;
                }

                var geo_box: wlr.Box = undefined;
                view.xdg_surface.getGeometry(&geo_box);
                view.x = new_left - geo_box.x;
                view.y = new_top - geo_box.y;

                const new_width = @intCast(u32, new_right - new_left);
                const new_height = @intCast(u32, new_bottom - new_top);
                _ = view.xdg_surface.role_data.toplevel.setSize(new_width, new_height);
            },
        }
    }

    fn cursorButton(
        listener: *wl.Listener(*wlr.Pointer.event.Button),
        event: *wlr.Pointer.event.Button,
    ) void {
        const server = @fieldParentPtr(Server, "cursor_button", listener);
        _ = server.seat.pointerNotifyButton(event.time_msec, event.button, event.state);
        if (event.state == .released) {
            server.cursor_mode = .passthrough;
        } else if (server.viewAt(server.cursor.x, server.cursor.y)) |res| {
            server.focusView(res.view, res.surface);
        }
    }

    fn cursorAxis(
        listener: *wl.Listener(*wlr.Pointer.event.Axis),
        event: *wlr.Pointer.event.Axis,
    ) void {
        const server = @fieldParentPtr(Server, "cursor_axis", listener);
        server.seat.pointerNotifyAxis(
            event.time_msec,
            event.orientation,
            event.delta,
            event.delta_discrete,
            event.source,
        );
    }

    fn cursorFrame(listener: *wl.Listener(*wlr.Cursor), wlr_cursor: *wlr.Cursor) void {
        const server = @fieldParentPtr(Server, "cursor_frame", listener);
        server.seat.pointerNotifyFrame();
    }

    /// Assumes the modifier used for compositor keybinds is pressed
    /// Returns true if the key was handled
    fn handleKeybind(server: *Server, key: xkb.Keysym) bool {
        switch (key) {
            // Exit the compositor
            .Escape => server.wl_server.terminate(),
            // Focus the next view in the stack, pushing the current top to the back
            .F1 => {
                if (server.views.length() < 2) return true;
                const view = @fieldParentPtr(View, "link", server.views.link.next.?);
                view.link.remove();
                server.views.append(view);
                server.focusView(view, view.xdg_surface.surface);
            },
            else => return false,
        }
        return true;
    }
};

const Output = struct {
    const RenderData = struct {
        wlr_output: *wlr.Output,
        view: *View,
        renderer: *wlr.Renderer,
        when: *os.timespec,
    };

    server: *Server,
    wlr_output: *wlr.Output,

    frame: wl.Listener(*wlr.Output) = wl.Listener(*wlr.Output).init(frame),

    fn frame(listener: *wl.Listener(*wlr.Output), wlr_output: *wlr.Output) void {
        const output = @fieldParentPtr(Output, "frame", listener);
        const server = output.server;

        var now: os.timespec = undefined;
        os.clock_gettime(os.CLOCK_MONOTONIC, &now) catch @panic("CLOCK_MONOTONIC not supported");

        wlr_output.attachRender(null) catch return;

        var width: c_int = undefined;
        var height: c_int = undefined;
        wlr_output.effectiveResolution(&width, &height);

        server.renderer.begin(width, height);

        const color = [4]f32{ 0.3, 0.3, 0.3, 1.0 };
        server.renderer.clear(&color);

        // In reverse order to render views at the front of the list on top
        var it = server.views.iterator(.reverse);
        while (it.next()) |view| {
            var rdata = RenderData{
                .wlr_output = wlr_output,
                .view = view,
                .renderer = server.renderer,
                .when = &now,
            };
            view.xdg_surface.forEachSurface(*RenderData, renderSurface, &rdata);
        }

        wlr_output.renderSoftwareCursors(null);

        server.renderer.end();

        // Pending changes are automatically rolled back on failure
        wlr_output.commit() catch {};
    }

    fn renderSurface(surface: *wlr.Surface, sx: c_int, sy: c_int, rdata: *RenderData) callconv(.C) void {
        const wlr_output = rdata.wlr_output;
        const texture = surface.getTexture() orelse return;

        var ox: f64 = 0;
        var oy: f64 = 0;
        rdata.view.server.output_layout.outputCoords(wlr_output, &ox, &oy);
        ox += @intToFloat(f64, rdata.view.x + sx);
        oy += @intToFloat(f64, rdata.view.y + sy);

        var box = wlr.Box{
            .x = @floatToInt(c_int, ox * wlr_output.scale),
            .y = @floatToInt(c_int, oy * wlr_output.scale),
            .width = @floatToInt(c_int, @intToFloat(f32, surface.current.width) * wlr_output.scale),
            .height = @floatToInt(c_int, @intToFloat(f32, surface.current.height) * wlr_output.scale),
        };

        var matrix: [9]f32 = undefined;
        const transform = wlr.Output.transformInvert(surface.current.transform);
        wlr.matrix.projectBox(&matrix, &box, transform, 0, &wlr_output.transform_matrix);

        // wlroots will log an error for us
        rdata.renderer.renderTextureWithMatrix(texture, &matrix, 1) catch {};
        surface.sendFrameDone(rdata.when);
    }
};

const View = struct {
    server: *Server,
    link: wl.list.Link = undefined,
    xdg_surface: *wlr.XdgSurface,

    x: i32 = 0,
    y: i32 = 0,

    map: wl.Listener(*wlr.XdgSurface) = wl.Listener(*wlr.XdgSurface).init(map),
    unmap: wl.Listener(*wlr.XdgSurface) = wl.Listener(*wlr.XdgSurface).init(unmap),
    destroy: wl.Listener(*wlr.XdgSurface) = wl.Listener(*wlr.XdgSurface).init(destroy),
    request_move: wl.Listener(*wlr.XdgToplevel.event.Move) = wl.Listener(*wlr.XdgToplevel.event.Move).init(requestMove),
    request_resize: wl.Listener(*wlr.XdgToplevel.event.Resize) = wl.Listener(*wlr.XdgToplevel.event.Resize).init(requestResize),

    fn map(listener: *wl.Listener(*wlr.XdgSurface), xdg_surface: *wlr.XdgSurface) void {
        const view = @fieldParentPtr(View, "map", listener);
        view.server.views.prepend(view);
        view.x -= xdg_surface.geometry.x;
        view.y -= xdg_surface.geometry.y;
        view.server.focusView(view, xdg_surface.surface);
    }

    fn unmap(listener: *wl.Listener(*wlr.XdgSurface), xdg_surface: *wlr.XdgSurface) void {
        const view = @fieldParentPtr(View, "unmap", listener);
        view.link.remove();
    }

    fn destroy(listener: *wl.Listener(*wlr.XdgSurface), xdg_surface: *wlr.XdgSurface) void {
        const view = @fieldParentPtr(View, "destroy", listener);

        view.map.link.remove();
        view.unmap.link.remove();
        view.destroy.link.remove();
        view.request_move.link.remove();
        view.request_resize.link.remove();

        gpa.destroy(view);
    }

    fn requestMove(
        listener: *wl.Listener(*wlr.XdgToplevel.event.Move),
        event: *wlr.XdgToplevel.event.Move,
    ) void {
        const view = @fieldParentPtr(View, "request_move", listener);
        const server = view.server;
        server.grabbed_view = view;
        server.cursor_mode = .move;
        server.grab_x = server.cursor.x - @intToFloat(f64, view.x);
        server.grab_y = server.cursor.y - @intToFloat(f64, view.y);
    }

    fn requestResize(
        listener: *wl.Listener(*wlr.XdgToplevel.event.Resize),
        event: *wlr.XdgToplevel.event.Resize,
    ) void {
        const view = @fieldParentPtr(View, "request_resize", listener);
        const server = view.server;

        server.grabbed_view = view;
        server.cursor_mode = .resize;
        server.resize_edges = event.edges;

        var box: wlr.Box = undefined;
        view.xdg_surface.getGeometry(&box);

        const border_x = view.x + box.x + if (event.edges.right) box.width else 0;
        const border_y = view.y + box.y + if (event.edges.bottom) box.height else 0;
        server.grab_x = server.cursor.x - @intToFloat(f64, border_x);
        server.grab_y = server.cursor.y - @intToFloat(f64, border_y);

        server.grab_box = box;
        server.grab_box.x += view.x;
        server.grab_box.y += view.y;
    }
};

const Keyboard = struct {
    server: *Server,
    link: wl.list.Link = undefined,
    device: *wlr.InputDevice,

    modifiers: wl.Listener(*wlr.Keyboard) = wl.Listener(*wlr.Keyboard).init(modifiers),
    key: wl.Listener(*wlr.Keyboard.event.Key) = wl.Listener(*wlr.Keyboard.event.Key).init(key),

    fn create(server: *Server, device: *wlr.InputDevice) !void {
        const keyboard = try gpa.create(Keyboard);
        errdefer gpa.destroy(keyboard);

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

        wlr_keyboard.events.modifiers.add(&keyboard.modifiers);
        wlr_keyboard.events.key.add(&keyboard.key);

        server.seat.setKeyboard(device);
        server.keyboards.append(keyboard);
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

        var handled = false;
        if (wlr_keyboard.getModifiers().alt and event.state == .pressed) {
            for (wlr_keyboard.xkb_state.?.keyGetSyms(keycode)) |sym| {
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
