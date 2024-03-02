const wlr = @import("../wlroots.zig");

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

    pub const IcccmWmHints = extern struct {
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

        min_aspect_num: i32,
        min_aspect_den: i32,

        max_aspect_num: i32,
        max_aspect_den: i32,

        base_width: i32,
        base_height: i32,

        win_gravity: u32,
    };

    pub const EwmhWmStrutPartial = extern struct {
        left: u32,
        right: u32,
        top: u32,
        bottom: u32,
        left_start_y: u32,
        left_end_y: u32,
        right_start_y: u32,
        right_end_y: u32,
        top_start_x: u32,
        top_end_x: u32,
        bottom_start_x: u32,
        bottom_end_x: u32,
    };
};

pub const Xwm = opaque {};
pub const XwaylandCursor = opaque {};

pub const Xwayland = extern struct {
    pub const event = struct {
        pub const RemoveStartupInfo = extern struct {
            id: [*:0]const u8,
            window: xcb.Window,
        };
    };

    /// This can be null during destruction
    server: ?*wlr.XwaylandServer,
    own_server: bool,
    xwm: ?*Xwm,
    shell_v1: *wlr.XwaylandShellV1,
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

    user_event_handler: ?*const fn (*Xwm, *xcb.GenericEvent) callconv(.C) c_int,

    server_start: wl.Listener(void),
    server_ready: wl.Listener(*wlr.XwaylandServer.event.Ready),
    server_destroy: wl.Listener(void),
    seat_destroy: wl.Listener(*wlr.Seat),
    shell_destroy: wl.Listener(void),

    data: usize,

    extern fn wlr_xwayland_create(server: *wl.Server, compositor: *wlr.Compositor, lazy: bool) ?*Xwayland;
    pub fn create(server: *wl.Server, compositor: *wlr.Compositor, lazy: bool) !*Xwayland {
        return wlr_xwayland_create(server, compositor, lazy) orelse error.XwaylandCreateFailed;
    }

    extern fn wlr_xwayland_create_with_server(server: *wl.Server, compositor: *wlr.Compositor, xwayland_server: *wlr.XwaylandServer) ?*Xwayland;
    pub fn createWithServer(server: *wl.Server, compositor: *wlr.Compositor, xwayland_server: *wlr.XwaylandServer) !*Xwayland {
        return wlr_xwayland_create_with_server(server, compositor, xwayland_server) orelse error.XwaylandCreateWithServerFailed;
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
    pub const Decorations = packed struct(u32) {
        no_border: bool = false,
        no_title: bool = false,
        _: u30 = 0,
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
    serial: u64,

    link: wl.list.Link,
    stack_link: wl.list.Link,
    unpaired_link: wl.list.Link,

    surface: ?*wlr.Surface,
    surface_addon: wlr.Addon,
    surface_commit: wl.Listener(*wlr.Surface),
    surface_map: wl.Listener(void),
    surface_unmap: wl.Listener(void),

    x: i16,
    y: i16,
    width: u16,
    height: u16,
    saved_width: u16,
    saved_height: u16,
    override_redirect: bool,

    title: ?[*:0]u8,
    class: ?[*:0]u8,
    instance: ?[*:0]u8,
    role: ?[*:0]u8,
    startup_id: ?[*:0]u8,
    pid: os.pid_t,
    has_utf8_title: bool,

    children: wl.list.Head(XwaylandSurface, .parent_link),
    parent: ?*XwaylandSurface,
    /// XwaylandSurface.children
    parent_link: wl.list.Link,

    window_type: ?[*]xcb.Atom,
    window_type_len: usize,

    protocols: ?[*]xcb.Atom,
    protocols_len: usize,

    decorations: Decorations,
    hints: ?*xcb.IcccmWmHints,
    size_hints: ?*xcb.SizeHints,
    strut_partial: ?*xcb.EwmhWmStrutPartial,

    pinging: bool,
    ping_timer: *wl.EventSource,

    modal: bool,
    fullscreen: bool,
    maximized_vert: bool,
    maximized_horz: bool,
    minimized: bool,
    withdrawn: bool,

    has_alpha: bool,

    events: extern struct {
        destroy: wl.Signal(void),
        request_configure: wl.Signal(*event.Configure),
        request_move: wl.Signal(void),
        request_resize: wl.Signal(*event.Resize),
        request_minimize: wl.Signal(*event.Minimize),
        request_maximize: wl.Signal(void),
        request_fullscreen: wl.Signal(void),
        request_activate: wl.Signal(void),

        associate: wl.Signal(void),
        dissociate: wl.Signal(void),

        set_title: wl.Signal(void),
        set_class: wl.Signal(void),
        set_role: wl.Signal(void),
        set_parent: wl.Signal(void),
        set_startup_id: wl.Signal(void),
        set_window_type: wl.Signal(void),
        set_hints: wl.Signal(void),
        set_decorations: wl.Signal(void),
        set_strut_partial: wl.Signal(void),
        set_override_redirect: wl.Signal(void),
        set_geometry: wl.Signal(void),
        ping_timeout: wl.Signal(void),
    },

    data: usize,

    extern fn wlr_xwayland_surface_activate(surface: *XwaylandSurface, activated: bool) void;
    pub const activate = wlr_xwayland_surface_activate;

    extern fn wlr_xwayland_surface_restack(surface: *XwaylandSurface, sibling: ?*XwaylandSurface, mode: xcb.StackMode) void;
    pub const restack = wlr_xwayland_surface_restack;

    extern fn wlr_xwayland_surface_configure(surface: *XwaylandSurface, x: i16, y: i16, width: u16, height: u16) void;
    pub const configure = wlr_xwayland_surface_configure;

    extern fn wlr_xwayland_surface_close(surface: *XwaylandSurface) void;
    pub const close = wlr_xwayland_surface_close;

    extern fn wlr_xwayland_surface_set_withdrawn(surface: *XwaylandSurface, withdrawn: bool) void;
    pub const setWithdrawn = wlr_xwayland_surface_set_withdrawn;

    extern fn wlr_xwayland_surface_set_minimized(surface: *XwaylandSurface, minimized: bool) void;
    pub const setMinimized = wlr_xwayland_surface_set_minimized;

    extern fn wlr_xwayland_surface_set_maximized(surface: *XwaylandSurface, maximized: bool) void;
    pub const setMaximized = wlr_xwayland_surface_set_maximized;

    extern fn wlr_xwayland_surface_set_fullscreen(surface: *XwaylandSurface, fullscreen: bool) void;
    pub const setFullscreen = wlr_xwayland_surface_set_fullscreen;

    extern fn wlr_xwayland_surface_try_from_wlr_surface(surface: *wlr.Surface) ?*XwaylandSurface;
    pub const tryFromWlrSurface = wlr_xwayland_surface_try_from_wlr_surface;

    extern fn wlr_xwayland_surface_ping(surface: *XwaylandSurface) void;
    pub const ping = wlr_xwayland_surface_ping;

    extern fn wlr_xwayland_or_surface_wants_focus(surface: *const XwaylandSurface) bool;
    pub const overrideRedirectWantsFocus = wlr_xwayland_or_surface_wants_focus;

    extern fn wlr_xwayland_icccm_input_model(surface: *const XwaylandSurface) IcccmInputModel;
    pub const icccmInputModel = wlr_xwayland_icccm_input_model;
};
