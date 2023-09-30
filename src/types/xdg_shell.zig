const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const xdg = wayland.server.xdg;

pub const XdgShell = extern struct {
    global: *wl.Global,
    version: u32,
    clients: wl.list.Head(XdgClient, .link),
    popup_grabs: wl.list.Head(XdgPopupGrab, .link),
    ping_timeout: u32,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        new_surface: wl.Signal(*wlr.XdgSurface),
        destroy: wl.Signal(*wlr.XdgShell),
    },

    data: usize,

    extern fn wlr_xdg_shell_create(server: *wl.Server, version: u32) ?*wlr.XdgShell;
    pub fn create(server: *wl.Server, version: u32) !*wlr.XdgShell {
        return wlr_xdg_shell_create(server, version) orelse error.OutOfMemory;
    }
};

pub const XdgClient = extern struct {
    shell: *wlr.XdgShell,
    resource: *xdg.WmBase,
    client: *wl.Client,
    surfaces: wl.list.Head(XdgSurface, .link),
    /// XdgShell.clients
    link: wl.list.Link,

    ping_serial: u32,
    ping_timer: *wl.EventSource,
};

pub const XdgPositioner = extern struct {
    pub const Rules = extern struct {
        anchor_rect: wlr.Box,
        anchor: xdg.Positioner.Anchor,
        gravity: xdg.Positioner.Gravity,
        constraint_adjustment: xdg.Positioner.ConstraintAdjustment,

        reactive: bool,

        has_parent_configure_serial: bool,
        parent_configure_serial: u32,

        size: extern struct {
            width: i32,
            height: i32,
        },
        parent_size: extern struct {
            width: i32,
            height: i32,
        },

        offset: extern struct {
            x: i32,
            y: i32,
        },

        extern fn wlr_xdg_positioner_rules_get_geometry(rules: *const Rules, box: *wlr.Box) void;
        pub const getGeometry = wlr_xdg_positioner_rules_get_geometry;

        extern fn wlr_xdg_positioner_rules_unconstrain_box(rules: *const Rules, constraint: *const wlr.Box, box: *wlr.Box) void;
        pub const unconstrainBox = wlr_xdg_positioner_rules_unconstrain_box;
    };

    resource: *xdg.Positioner,
    rules: Rules,

    extern fn wlr_xdg_positioner_from_resource(resource: *xdg.Positioner) *XdgPositioner;
    pub const fromResource = wlr_xdg_positioner_from_resource;
};

pub const XdgPopupGrab = extern struct {
    client: *wl.Client,

    pointer_grab: wlr.Seat.PointerGrab,
    keyboard_grab: wlr.Seat.KeyboardGrab,
    touch_grab: wlr.Seat.TouchGrab,
    seat: *wlr.Seat,

    popups: wl.list.Head(XdgPopup, .grab_link),
    /// XdgShell.popup_grabs
    link: wl.list.Link,

    seat_destroy: wl.Listener(*wlr.Seat),
};

pub const XdgPopup = extern struct {
    pub const State = extern struct {
        geometry: wlr.Box,
        reactive: bool,
    };

    pub const Configure = extern struct {
        fields: u32,
        geometry: wlr.Box,
        rules: XdgPositioner.Rules,

        reposition_token: u32,
    };

    base: *wlr.XdgSurface,
    link: wl.list.Link,

    resource: *xdg.Popup,
    sent_initial_configure: bool,
    parent: ?*wlr.Surface,
    seat: ?*wlr.Seat,

    scheduled: Configure,

    current: State,
    pending: State,

    events: extern struct {
        reposition: wl.Signal(void),
    },

    /// Grab.popups
    grab_link: wl.list.Link,

    extern fn wlr_xdg_popup_from_resource(resource: *xdg.Popup) ?*wlr.XdgPopup;
    pub const fromResource = wlr_xdg_popup_from_resource;

    extern fn wlr_xdg_popup_destroy(popup: *wlr.XdgPopup) void;
    pub const destroy = wlr_xdg_popup_destroy;

    extern fn wlr_xdg_popup_get_position(popup: *XdgPopup, popup_sx: *f64, popup_sy: *f64) void;
    pub const getPosition = wlr_xdg_popup_get_position;

    extern fn wlr_xdg_popup_get_toplevel_coords(popup: *XdgPopup, popup_sx: c_int, popup_sy: c_int, toplevel_sx: *c_int, toplevel_sy: *c_int) void;
    pub const getToplevelCoords = wlr_xdg_popup_get_toplevel_coords;

    extern fn wlr_xdg_popup_unconstrain_from_box(popup: *XdgPopup, toplevel_space_box: *const wlr.Box) void;
    pub const unconstrainFromBox = wlr_xdg_popup_unconstrain_from_box;
};

pub const XdgToplevel = extern struct {
    pub const State = extern struct {
        maximized: bool,
        fullscreen: bool,
        resizing: bool,
        activated: bool,
        suspended: bool,
        tiled: wlr.Edges,
        width: i32,
        height: i32,
        max_width: i32,
        max_height: i32,
        min_width: i32,
        min_height: i32,
    };

    pub const WmCapabilities = packed struct(u32) {
        window_menu: bool = false,
        maximize: bool = false,
        fullscreen: bool = false,
        minimize: bool = false,
        _: u28 = 0,
    };

    pub const Configure = extern struct {
        pub const Fields = packed struct(u32) {
            bounds: bool = false,
            wm_capabilities: bool = false,
            _: u30 = 0,
        };

        fields: Fields,
        maximized: bool,
        fullscreen: bool,
        resizing: bool,
        activated: bool,
        suspended: bool,
        tiled: wlr.Edges,
        width: i32,
        height: i32,
        bounds: extern struct {
            width: i32,
            height: i32,
        },
        wm_capabilities: WmCapabilities,
    };

    pub const Requested = extern struct {
        maximized: bool,
        minimized: bool,
        fullscreen: bool,

        fullscreen_output: ?*wlr.Output,
        fullscreen_output_destroy: wl.Listener(*wlr.Output),
    };

    pub const event = struct {
        pub const Move = extern struct {
            toplevel: *wlr.XdgToplevel,
            seat: *wlr.Seat.Client,
            serial: u32,
        };

        pub const Resize = extern struct {
            toplevel: *wlr.XdgToplevel,
            seat: *wlr.Seat.Client,
            serial: u32,
            edges: wlr.Edges,
        };

        pub const ShowWindowMenu = extern struct {
            toplevel: *wlr.XdgToplevel,
            seat: *wlr.Seat.Client,
            serial: u32,
            x: i32,
            y: i32,
        };
    };

    resource: *xdg.Toplevel,
    base: *wlr.XdgSurface,
    sent_initial_configure: bool,
    parent: ?*wlr.XdgToplevel,
    parent_unmap: wl.Listener(*XdgSurface),

    current: State,
    pending: State,
    scheduled: Configure,
    requested: Requested,

    title: ?[*:0]u8,
    app_id: ?[*:0]u8,
    events: extern struct {
        request_maximize: wl.Signal(void),
        request_fullscreen: wl.Signal(void),
        request_minimize: wl.Signal(void),
        request_move: wl.Signal(*event.Move),
        request_resize: wl.Signal(*event.Resize),
        request_show_window_menu: wl.Signal(*event.ShowWindowMenu),
        set_parent: wl.Signal(void),
        set_title: wl.Signal(void),
        set_app_id: wl.Signal(void),
    },

    extern fn wlr_xdg_toplevel_from_resource(resource: *xdg.Toplevel) ?*wlr.XdgToplevel;
    pub const fromResource = wlr_xdg_toplevel_from_resource;

    extern fn wlr_xdg_toplevel_set_size(toplevel: *wlr.XdgToplevel, width: i32, height: i32) u32;
    pub const setSize = wlr_xdg_toplevel_set_size;

    extern fn wlr_xdg_toplevel_set_activated(toplevel: *wlr.XdgToplevel, activated: bool) u32;
    pub const setActivated = wlr_xdg_toplevel_set_activated;

    extern fn wlr_xdg_toplevel_set_maximized(toplevel: *wlr.XdgToplevel, maximized: bool) u32;
    pub const setMaximized = wlr_xdg_toplevel_set_maximized;

    extern fn wlr_xdg_toplevel_set_fullscreen(toplevel: *wlr.XdgToplevel, fullscreen: bool) u32;
    pub const setFullscreen = wlr_xdg_toplevel_set_fullscreen;

    extern fn wlr_xdg_toplevel_set_resizing(toplevel: *wlr.XdgToplevel, resizing: bool) u32;
    pub const setResizing = wlr_xdg_toplevel_set_resizing;

    extern fn wlr_xdg_toplevel_set_tiled(toplevel: *wlr.XdgToplevel, tiled_edges: u32) u32;
    pub fn setTiled(toplevel: *wlr.XdgToplevel, tiled_edges: wlr.Edges) u32 {
        return wlr_xdg_toplevel_set_tiled(toplevel, @as(u32, @bitCast(tiled_edges)));
    }

    extern fn wlr_xdg_toplevel_set_bounds(toplevel: *wlr.XdgToplevel, width: i32, height: i32) u32;
    pub const setBounds = wlr_xdg_toplevel_set_bounds;

    extern fn wlr_xdg_toplevel_set_wm_capabilities(toplevel: *wlr.XdgToplevel, caps: WmCapabilities) u32;
    pub const setWmCapabilities = wlr_xdg_toplevel_set_wm_capabilities;

    extern fn wlr_xdg_toplevel_set_suspended(toplevel: *wlr.XdgToplevel, suspended: bool) u32;
    pub const setSuspended = wlr_xdg_toplevel_set_suspended;

    extern fn wlr_xdg_toplevel_send_close(toplevel: *wlr.XdgToplevel) void;
    pub const sendClose = wlr_xdg_toplevel_send_close;

    extern fn wlr_xdg_toplevel_set_parent(toplevel: *wlr.XdgToplevel, parent: ?*wlr.XdgToplevel) bool;
    pub const setParent = wlr_xdg_toplevel_set_parent;
};

pub const XdgSurface = extern struct {
    pub const Role = enum(c_int) {
        none,
        toplevel,
        popup,
    };

    pub const State = extern struct {
        configure_serial: u32,
        geometry: wlr.Box,
    };

    pub const Configure = extern struct {
        surface: *wlr.XdgSurface,
        /// XdgSurface.configure_list
        link: wl.list.Link,
        serial: u32,

        role: extern union {
            toplevel: *wlr.XdgToplevel.Configure,
            popup: *wlr.XdgPopup.Configure,
        },
    };

    client: *wlr.XdgClient,
    resource: *xdg.Surface,
    surface: *wlr.Surface,
    /// XdgClient.surfaces
    link: wl.list.Link,

    role: Role,
    role_resource: ?*wl.Resource,
    role_data: extern union {
        toplevel: ?*wlr.XdgToplevel,
        popup: ?*wlr.XdgPopup,
    },

    popups: wl.list.Head(XdgPopup, .link),

    added: bool,
    configured: bool,
    configure_idle: ?*wl.EventSource,
    scheduled_serial: u32,
    configure_list: wl.list.Head(XdgSurface.Configure, .link),

    current: State,
    pending: State,

    events: extern struct {
        destroy: wl.Signal(void),
        ping_timeout: wl.Signal(void),
        new_popup: wl.Signal(*wlr.XdgPopup),
        configure: wl.Signal(*wlr.XdgSurface.Configure),
        ack_configure: wl.Signal(*wlr.XdgSurface.Configure),
    },

    data: usize,

    // private state

    client_mapped: bool,
    role_resource_destroy: wl.Listener(*wl.Resource),

    extern fn wlr_xdg_surface_from_resource(resource: *xdg.Surface) ?*wlr.XdgSurface;
    pub const fromResource = wlr_xdg_surface_from_resource;

    extern fn wlr_xdg_surface_ping(surface: *wlr.XdgSurface) void;
    pub const ping = wlr_xdg_surface_ping;

    extern fn wlr_xdg_surface_surface_at(surface: *wlr.XdgSurface, sx: f64, sy: f64, sub_x: *f64, sub_y: *f64) ?*wlr.Surface;
    pub const surfaceAt = wlr_xdg_surface_surface_at;

    extern fn wlr_xdg_surface_popup_surface_at(surface: *wlr.XdgSurface, sx: f64, sy: f64, sub_x: *f64, sub_y: *f64) ?*wlr.Surface;
    pub const popupSurfaceAt = wlr_xdg_surface_popup_surface_at;

    extern fn wlr_xdg_surface_try_from_wlr_surface(surface: *wlr.Surface) ?*wlr.XdgSurface;
    pub const tryFromWlrSurface = wlr_xdg_surface_try_from_wlr_surface;

    extern fn wlr_xdg_surface_get_geometry(surface: *wlr.XdgSurface, box: *wlr.Box) void;
    pub const getGeometry = wlr_xdg_surface_get_geometry;

    extern fn wlr_xdg_surface_for_each_surface(
        surface: *wlr.XdgSurface,
        iterator: *const fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void,
        user_data: ?*anyopaque,
    ) void;
    pub inline fn forEachSurface(
        surface: *wlr.XdgSurface,
        comptime T: type,
        comptime iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: T) void,
        data: T,
    ) void {
        wlr_xdg_surface_for_each_surface(
            surface,
            struct {
                fn wrapper(s: *wlr.Surface, sx: c_int, sy: c_int, d: ?*anyopaque) callconv(.C) void {
                    iterator(s, sx, sy, @ptrCast(@alignCast(d)));
                }
            }.wrapper,
            data,
        );
    }

    extern fn wlr_xdg_surface_for_each_popup_surface(
        surface: *wlr.XdgSurface,
        iterator: *const fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void,
        user_data: ?*anyopaque,
    ) void;
    pub inline fn forEachPopupSurface(
        surface: *wlr.XdgSurface,
        comptime T: type,
        comptime iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: T) void,
        data: T,
    ) void {
        wlr_xdg_surface_for_each_popup_surface(
            surface,
            struct {
                fn wrapper(s: *wlr.Surface, sx: c_int, sy: c_int, d: ?*anyopaque) callconv(.C) void {
                    iterator(s, sx, sy, @ptrCast(@alignCast(d)));
                }
            }.wrapper,
            data,
        );
    }

    extern fn wlr_xdg_surface_schedule_configure(surface: *wlr.XdgSurface) u32;
    pub const scheduleConfigure = wlr_xdg_surface_schedule_configure;
};
