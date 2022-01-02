const wlr = @import("wlroots.zig");

const std = @import("std");
const os = std.os;

const wayland = @import("wayland");
const wl = wayland.server.wl;

// Only bind enough to make binding wlr/xwayland.h possible
// Consider full xcb bindings in the future if needed
const xcb = struct {
    const GenericEvent = opaque {};
    const Pixmap = u32;
    const Window = u32;
    const Atom = u32;

    const StackMode = enum(c_int) {
        above = 0,
        below = 1,
        top_if = 2,
        bottom_if = 3,
        opposite = 4,
    };
};

pub const Xwm = opaque {};
pub const XwaylandCursor = opaque {};

pub const XwaylandServer = extern struct {
    pub const Options = extern struct {
        lazy: bool,
        enable_wm: bool,
        no_touch_pointer_emulation: bool,
    };

    pub const event = struct {
        pub const Ready = extern struct {
            server: *XwaylandServer,
            wm_fd: c_int,
        };
    };

    pid: os.pid_t,
    client: ?*wl.Client,
    pipe_source: ?*wl.EventSource,
    wm_fd: [2]c_int,
    wl_fd: [2]c_int,

    server_start: os.time_t,
    display: c_int,
    display_name: [16]u8,
    x_fd: [2]c_int,
    x_fd_read_event: [2]?*wl.EventSource,
    options: Options,

    wl_server: *wl.Server,

    events: extern struct {
        ready: wl.Signal(*event.Ready),
        destroy: wl.Signal(void),
    },

    client_destroy: wl.Listener(*wl.Client),
    display_destroy: wl.Listener(*wl.Server),

    data: usize,

    extern fn wlr_xwayland_server_create(server: *wl.Server, options: *Options) ?*XwaylandServer;
    pub fn create(server: *wl.Server, options: *Options) !*XwaylandServer {
        return wlr_xwayland_server_create(server, options) orelse error.XwaylandServerCreateFailed;
    }

    extern fn wlr_xwayland_server_destroy(server: *XwaylandServer) void;
    pub const destroy = wlr_xwayland_server_destroy;
};

pub const Xwayland = extern struct {
    pub const event = struct {
        pub const RemoveStartupInfo = extern struct {
            id: [*:0]const u8,
            window: xcb.Window,
        };
    };
    server: *XwaylandServer,
    xwm: ?*Xwm,
    cursor: ?*XwaylandCursor,

    display_name: [*:0]const u8,

    wl_server: *wl.Server,
    compositor: *wlr.Compositor,
    seat: ?*wlr.Seat,

    events: extern struct {
        ready: wl.Signal(void),
        new_surface: wl.Signal(*XwaylandSurface),
        remove_startup_info: wl.Signal(*event.RemoveStartupInfo),
    },

    user_event_handler: ?fn (*Xwm, *xcb.GenericEvent) callconv(.C) c_int,

    server_ready: wl.Listener(*XwaylandServer.event.Ready),
    server_destroy: wl.Listener(void),
    seat_destroy: wl.Listener(*wlr.Seat),

    data: usize,

    extern fn wlr_xwayland_create(server: *wl.Server, compositor: *wlr.Compositor, lazy: bool) ?*Xwayland;
    pub fn create(server: *wl.Server, compositor: *wlr.Compositor, lazy: bool) !*Xwayland {
        return wlr_xwayland_create(server, compositor, lazy) orelse error.XwaylandCreateFailed;
    }

    extern fn wlr_xwayland_destroy(wlr_xwayland: *Xwayland) void;
    pub const destroy = wlr_xwayland_destroy;

    extern fn wlr_xwayland_set_cursor(wlr_xwayland: *Xwayland, pixels: [*]u8, stride: u32, width: u32, height: u32, hotspot_x: i32, hotspot_y: i32) void;
    pub const setCursor = wlr_xwayland_set_cursor;

    extern fn wlr_xwayland_set_seat(xwayland: *Xwayland, seat: *wlr.Seat) void;
    pub const setSeat = wlr_xwayland_set_seat;
};

pub const XwaylandSurface = extern struct {
    pub const IcccmInputModel = enum(c_int) {
        none = 0,
        passive = 1,
        local = 2,
        global = 3,
    };

    /// Bitfield with the size/alignment of a u32
    pub const Decorations = packed struct {
        no_border: bool align(@alignOf(u32)) = false,
        no_title: bool = false,
        _: u30 = 0,

        comptime {
            std.debug.assert(@sizeOf(@This()) == @sizeOf(u32));
            std.debug.assert(@alignOf(@This()) == @alignOf(u32));
        }
    };

    pub const Hints = extern struct {
        flags: u32,
        input: u32,
        initial_state: i32,
        icon_pixmap: xcb.Pixmap,
        icon_window: xcb.Window,
        icon_x: i32,
        icon_y: i32,
        icon_mask: xcb.Pixmap,
        window_group: xcb.Window,
    };

    pub const SizeHints = extern struct {
        flags: u32,
        x: i32,
        y: i32,
        width: i32,
        height: i32,
        min_width: i32,
        min_height: i32,
        max_width: i32,
        max_height: i32,
        width_inc: i32,
        height_inc: i32,
        base_width: i32,
        base_height: i32,
        min_aspect_num: i32,
        min_aspect_den: i32,
        max_aspect_num: i32,
        max_aspect_den: i32,
        win_gravity: u32,
    };

    pub const event = struct {
        pub const Configure = extern struct {
            surface: *XwaylandSurface,
            x: i16,
            y: i16,
            width: u16,
            height: u16,
            mask: u16,
        };

        pub const Move = extern struct {
            surface: *XwaylandSurface,
        };

        pub const Resize = extern struct {
            surface: *XwaylandSurface,
            edges: u32,
        };

        pub const Minimize = extern struct {
            surface: *XwaylandSurface,
            minimize: bool,
        };
    };

    window_id: xcb.Window,
    xwm: *Xwm,
    surface_id: u32,

    link: wl.list.Link,
    stack_link: wl.list.Link,
    unpaired_link: wl.list.Link,

    surface: ?*wlr.Surface,
    x: i16,
    y: i16,
    width: u16,
    height: u16,
    saved_width: u16,
    saved_height: u16,
    override_redirect: bool,
    mapped: bool,

    title: ?[*:0]u8,
    class: ?[*:0]u8,
    instance: ?[*:0]u8,
    role: ?[*:0]u8,
    startup_id: ?[*:0]u8,
    pid: os.pid_t,
    has_utf8_title: bool,

    children: wl.list.Head(XwaylandSurface, "parent_link"),
    parent: ?*XwaylandSurface,
    /// XwaylandSurface.children
    parent_link: wl.list.Link,

    window_type: ?[*]xcb.Atom,
    window_type_len: usize,

    protocols: ?[*]xcb.Atom,
    protocols_len: usize,

    decorations: Decorations,
    hints: ?*Hints,
    hints_urgency: u32,
    size_hints: ?*SizeHints,

    pinging: bool,
    ping_timer: *wl.EventSource,

    modal: bool,
    fullscreen: bool,
    maximized_vert: bool,
    maximized_horz: bool,
    minimized: bool,

    has_alpha: bool,

    events: extern struct {
        destroy: wl.Signal(*XwaylandSurface),
        request_configure: wl.Signal(*event.Configure),
        request_move: wl.Signal(*event.Move),
        request_resize: wl.Signal(*event.Resize),
        request_minimize: wl.Signal(*event.Minimize),
        request_maximize: wl.Signal(*XwaylandSurface),
        request_fullscreen: wl.Signal(*XwaylandSurface),
        request_activate: wl.Signal(*XwaylandSurface),

        map: wl.Signal(*XwaylandSurface),
        unmap: wl.Signal(*XwaylandSurface),
        set_title: wl.Signal(*XwaylandSurface),
        set_class: wl.Signal(*XwaylandSurface),
        set_role: wl.Signal(*XwaylandSurface),
        set_parent: wl.Signal(*XwaylandSurface),
        set_pid: wl.Signal(*XwaylandSurface),
        set_startup_id: wl.Signal(*XwaylandSurface),
        set_window_type: wl.Signal(*XwaylandSurface),
        set_hints: wl.Signal(*XwaylandSurface),
        set_decorations: wl.Signal(*XwaylandSurface),
        set_override_redirect: wl.Signal(*XwaylandSurface),
        set_geometry: wl.Signal(*XwaylandSurface),
        ping_timeout: wl.Signal(*XwaylandSurface),
    },

    surface_destroy: wl.Listener(*wlr.Surface),

    data: usize,

    extern fn wlr_xwayland_surface_activate(surface: *XwaylandSurface, activated: bool) void;
    pub const activate = wlr_xwayland_surface_activate;

    extern fn wlr_xwayland_surface_restack(surface: *XwaylandSurface, sibling: ?*XwaylandSurface, mode: xcb.StackMode) void;
    pub const restack = wlr_xwayland_surface_restack;

    extern fn wlr_xwayland_surface_configure(surface: *XwaylandSurface, x: i16, y: i16, width: u16, height: u16) void;
    pub const configure = wlr_xwayland_surface_configure;

    extern fn wlr_xwayland_surface_close(surface: *XwaylandSurface) void;
    pub const close = wlr_xwayland_surface_close;

    extern fn wlr_xwayland_surface_set_minimized(surface: *XwaylandSurface, minimized: bool) void;
    pub const setMinimized = wlr_xwayland_surface_set_minimized;

    extern fn wlr_xwayland_surface_set_maximized(surface: *XwaylandSurface, maximized: bool) void;
    pub const setMaximized = wlr_xwayland_surface_set_maximized;

    extern fn wlr_xwayland_surface_set_fullscreen(surface: *XwaylandSurface, fullscreen: bool) void;
    pub const setFullscreen = wlr_xwayland_surface_set_fullscreen;

    extern fn wlr_xwayland_surface_from_wlr_surface(surface: *wlr.Surface) *XwaylandSurface;
    pub const fromWlrSurface = wlr_xwayland_surface_from_wlr_surface;

    extern fn wlr_xwayland_surface_ping(surface: *XwaylandSurface) void;
    pub const ping = wlr_xwayland_surface_ping;

    extern fn wlr_xwayland_or_surface_wants_focus(surface: *const XwaylandSurface) bool;
    pub const overrideRedirectWantsFocus = wlr_xwayland_or_surface_wants_focus;

    extern fn wlr_xwayland_icccm_input_model(surface: *const XwaylandSurface) IcccmInputModel;
    pub const icccmInputModel = wlr_xwayland_icccm_input_model;
};
