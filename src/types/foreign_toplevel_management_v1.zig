const wlr = @import("../wlroots.zig");

const std = @import("std");
const wl = @import("wayland").server.wl;

pub const ForeignToplevelManagerV1 = extern struct {
    event_loop: *wl.EventLoop,
    global: *wl.Global,
    resources: wl.list.Head(wl.Resource, null),
    toplevels: wl.list.Head(ForeignToplevelHandleV1, "link"),

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        destroy: wl.Signal(*ForeignToplevelManagerV1),
    },

    data: usize,

    extern fn wlr_foreign_toplevel_manager_v1_create(wl_server: *wl.Server) ?*ForeignToplevelManagerV1;
    pub fn create(wl_server: *wl.Server) !*ForeignToplevelManagerV1 {
        return wlr_foreign_toplevel_manager_v1_create(wl_server) orelse error.OutOfMemory;
    }
};

pub const ForeignToplevelHandleV1 = extern struct {
    pub const State = packed struct {
        maximized: bool align(@alignOf(u32)) = false,
        minimized: bool = false,
        activated: bool = false,
        fullscreen: bool = false,
        _: u28 = 0,
        comptime {
            std.debug.assert(@sizeOf(@This()) == @sizeOf(u32));
            std.debug.assert(@alignOf(@This()) == @alignOf(u32));
        }
    };

    pub const Output = extern struct {
        link: wl.list.Link,
        output: *wlr.Output,
        toplevel: *ForeignToplevelHandleV1,

        // private state

        output_bind: wl.Listener(*wlr.Output.event.Bind),
        output_destroy: wl.Listener(*wlr.Output),
    };

    pub const event = struct {
        pub const Maximized = extern struct {
            toplevel: *ForeignToplevelHandleV1,
            maximized: bool,
        };

        pub const Minimized = extern struct {
            toplevel: *ForeignToplevelHandleV1,
            minimized: bool,
        };

        pub const Activated = extern struct {
            toplevel: *ForeignToplevelHandleV1,
            seat: *wlr.Seat,
        };

        pub const Fullscreen = extern struct {
            toplevel: *ForeignToplevelHandleV1,
            fullscreen: bool,
            output: *wlr.Output,
        };

        pub const SetRectangle = extern struct {
            toplevel: *ForeignToplevelHandleV1,
            surface: *wlr.Surface,
            x: i32,
            y: i32,
            width: i32,
            height: i32,
        };
    };

    manager: *ForeignToplevelManagerV1,
    resources: wl.list.Head(wl.Resource, null),
    link: wl.list.Link,
    idle_source: ?*wl.EventSource,

    title: ?[*:0]u8,
    app_id: ?[*:0]u8,
    parent: ?*ForeignToplevelHandleV1,
    outputs: wl.list.Head(ForeignToplevelHandleV1.Output, "link"),
    state: State,

    events: extern struct {
        request_maximize: wl.Signal(*event.Maximized),
        request_minimize: wl.Signal(*event.Minimized),
        request_activate: wl.Signal(*event.Activated),
        request_fullscreen: wl.Signal(*event.Fullscreen),
        request_close: wl.Signal(*ForeignToplevelHandleV1),
        set_rectangle: wl.Signal(*event.SetRectangle),
        destroy: wl.Signal(*ForeignToplevelHandleV1),
    },

    data: usize,

    extern fn wlr_foreign_toplevel_handle_v1_create(manager: *ForeignToplevelManagerV1) ?*ForeignToplevelHandleV1;
    pub fn create(manager: *ForeignToplevelManagerV1) !*ForeignToplevelHandleV1 {
        return wlr_foreign_toplevel_handle_v1_create(manager) orelse error.OutOfMemory;
    }

    extern fn wlr_foreign_toplevel_handle_v1_destroy(toplevel: *ForeignToplevelHandleV1) void;
    pub const destroy = wlr_foreign_toplevel_handle_v1_destroy;

    extern fn wlr_foreign_toplevel_handle_v1_set_title(toplevel: *ForeignToplevelHandleV1, title: [*:0]const u8) void;
    pub const setTitle = wlr_foreign_toplevel_handle_v1_set_title;

    extern fn wlr_foreign_toplevel_handle_v1_set_app_id(toplevel: *ForeignToplevelHandleV1, app_id: [*:0]const u8) void;
    pub const setAppId = wlr_foreign_toplevel_handle_v1_set_app_id;

    extern fn wlr_foreign_toplevel_handle_v1_output_enter(toplevel: *ForeignToplevelHandleV1, output: *wlr.Output) void;
    pub const outputEnter = wlr_foreign_toplevel_handle_v1_output_enter;

    extern fn wlr_foreign_toplevel_handle_v1_output_leave(toplevel: *ForeignToplevelHandleV1, output: *wlr.Output) void;
    pub const outputLeave = wlr_foreign_toplevel_handle_v1_output_leave;

    extern fn wlr_foreign_toplevel_handle_v1_set_maximized(toplevel: *ForeignToplevelHandleV1, maximized: bool) void;
    pub const setMaximized = wlr_foreign_toplevel_handle_v1_set_maximized;

    extern fn wlr_foreign_toplevel_handle_v1_set_minimized(toplevel: *ForeignToplevelHandleV1, minimized: bool) void;
    pub const setMinimized = wlr_foreign_toplevel_handle_v1_set_minimized;

    extern fn wlr_foreign_toplevel_handle_v1_set_activated(toplevel: *ForeignToplevelHandleV1, activated: bool) void;
    pub const setActivated = wlr_foreign_toplevel_handle_v1_set_activated;

    extern fn wlr_foreign_toplevel_handle_v1_set_fullscreen(toplevel: *ForeignToplevelHandleV1, fullscreen: bool) void;
    pub const setFullscreen = wlr_foreign_toplevel_handle_v1_set_fullscreen;

    extern fn wlr_foreign_toplevel_handle_v1_set_parent(toplevel: *ForeignToplevelHandleV1, parent: ?*ForeignToplevelHandleV1) void;
    pub const setParent = wlr_foreign_toplevel_handle_v1_set_parent;
};
