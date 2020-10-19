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

    fn newOutput(listener: *wl.Listener(*wlr.Output), output: *wlr.Output) void {
        // TODO
    }

    fn newXdgSurface(listener: *wl.Listener(*wlr.XdgSurface), xdg_surface: *wlr.XdgSurface) void {
        // TODO
    }

    fn newInput(listener: *wl.Listener(*wlr.InputDevice), device: *wlr.InputDevice) void {
        // TODO
    }

    fn requestSetCursor(
        listener: *wl.Listener(*wlr.Seat.event.RequestSetCursor),
        event: *wlr.Seat.event.RequestSetCursor,
    ) void {
        // TODO
    }

    fn requestSetSelection(
        listener: *wl.Listener(*wlr.Seat.event.RequestSetSelection),
        event: *wlr.Seat.event.RequestSetSelection,
    ) void {
        // TODO
    }

    fn cursorMotion(
        listener: *wl.Listener(*wlr.Pointer.event.Motion),
        data: *wlr.Pointer.event.Motion,
    ) void {
        // TODO
    }

    fn cursorMotionAbsolute(
        listener: *wl.Listener(*wlr.Pointer.event.MotionAbsolute),
        data: *wlr.Pointer.event.MotionAbsolute,
    ) void {
        // TODO
    }

    fn cursorButton(
        listener: *wl.Listener(*wlr.Pointer.event.Button),
        data: *wlr.Pointer.event.Button,
    ) void {
        // TODO
    }

    fn cursorAxis(
        listener: *wl.Listener(*wlr.Pointer.event.Axis),
        data: *wlr.Pointer.event.Axis,
    ) void {
        // TODO
    }

    fn cursorFrame(listener: *wl.Listener(*wlr.Cursor), data: *wlr.Cursor) void {
        // TODO
    }
};

const Output = struct {
    server: *Server,
    wlr_output: *wlr.Output,

    frame: wl.Listener(*wlr.Output),
};

const View = struct {
    server: *Server,
    xdg_surface: *wlr.XdgSurface,

    mapped: bool,
    x: i32,
    y: i32,

    map: wl.Listener(*wlr.XdgSurface),
    unmap: wl.Listener(*wlr.XdgSurface),
    destroy: wl.Listener(*wlr.XdgSurface),
    request_move: wl.Listener(*wlr.XdgToplevel.event.Move),
    request_resize: wl.Listener(*wlr.XdgToplevel.event.Resize),
};

const Keyboard = struct {
    server: *Server,
    device: *wlr.InputDevice,

    modifiers: wl.Listener(*wlr.Keyboard),
    key: wl.Listener(*wlr.Keyboard.event.Key),
};
