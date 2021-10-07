const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const xdg = wayland.server.xdg;

pub const XdgShell = extern struct {
    global: *wl.Global,
    clients: wl.list.Head(XdgClient, "link"),
    popup_grabs: wl.list.Head(XdgPopupGrab, "link"),
    ping_timeout: u32,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        new_surface: wl.Signal(*wlr.XdgSurface),
        destroy: wl.Signal(*wlr.XdgShell),
    },

    data: usize,

    extern fn wlr_xdg_shell_create(server: *wl.Server) ?*wlr.XdgShell;
    pub fn create(server: *wl.Server) !*wlr.XdgShell {
        return wlr_xdg_shell_create(server) orelse error.OutOfMemory;
    }
};

pub const XdgClient = extern struct {
    shell: *wlr.XdgShell,
    resource: *xdg.WmBase,
    client: *wl.Client,
    surfaces: wl.list.Head(XdgSurface, "link"),
    /// XdgShell.clients
    link: wl.list.Link,

    ping_serial: u32,
    ping_timer: *wl.EventSource,
};

pub const XdgPositioner = extern struct {
    anchor_rect: wlr.Box,
    anchor: xdg.Positioner.Anchor,
    gravity: xdg.Positioner.Gravity,
    constraint_adjustment: xdg.Positioner.ConstraintAdjustment,

    size: extern struct {
        width: i32,
        height: i32,
    },

    offset: extern struct {
        x: i32,
        y: i32,
    },

    extern fn wlr_xdg_positioner_get_geometry(positioner: *wlr.XdgPositioner) wlr.Box;
    pub const getGeometry = wlr_xdg_positioner_get_geometry;

    extern fn wlr_positioner_invert_x(positioner: *wlr.XdgPositioner) void;
    pub const invertX = wlr_positioner_invert_x;

    extern fn wlr_positioner_invert_y(positioner: *wlr.XdgPositioner) void;
    pub const invertY = wlr_positioner_invert_y;
};

pub const XdgPopupGrab = extern struct {
    client: *wl.Client,

    pointer_grab: wlr.Seat.PointerGrab,
    keyboard_grab: wlr.Seat.KeyboardGrab,
    touch_grab: wlr.Seat.TouchGrab,
    seat: *wlr.Seat,

    popups: wl.list.Head(XdgPopup, "grab_link"),
    /// XdgShell.popup_grabs
    link: wl.list.Link,

    seat_destroy: wl.Listener(*wlr.Seat),
};

pub const XdgPopup = extern struct {
    base: *wlr.XdgSurface,
    link: wl.list.Link,

    resource: *xdg.Popup,
    committed: bool,
    parent: ?*wlr.Surface,
    seat: ?*wlr.Seat,

    geometry: wlr.Box,
    positioner: wlr.XdgPositioner,
    /// Grab.popups
    grab_link: wl.list.Link,

    extern fn wlr_xdg_popup_destroy(surface: *wlr.XdgSurface) void;
    pub inline fn destroy(popup: *wlr.XdgPopup) void {
        wlr_xdg_popup_destroy(popup.base);
    }

    extern fn wlr_xdg_popup_get_position(popup: *XdgPopup, popup_sx: *f64, popup_sy: *f64) void;
    pub const getPosition = wlr_xdg_popup_get_position;

    extern fn wlr_xdg_popup_get_anchor_point(popup: *XdgPopup, toplevel_sx: *c_int, toplevel_sy: *c_int) void;
    pub const getAnchorPoint = wlr_xdg_popup_get_anchor_point;

    extern fn wlr_xdg_popup_get_toplevel_coords(popup: *XdgPopup, popup_sx: c_int, popup_sy: c_int, toplevel_sx: *c_int, toplevel_sy: *c_int) void;
    pub const getToplevelCoords = wlr_xdg_popup_get_toplevel_coords;

    extern fn wlr_xdg_popup_unconstrain_from_box(popup: *XdgPopup, toplevel_sx_box: *const wlr.Box) void;
    pub const unconstrainFromBox = wlr_xdg_popup_unconstrain_from_box;
};

pub const XdgToplevel = extern struct {
    pub const State = extern struct {
        maximized: bool,
        fullscreen: bool,
        resizing: bool,
        activated: bool,
        tiled: wlr.Edges,
        width: u32,
        height: u32,
        max_width: u32,
        max_height: u32,
        min_width: u32,
        min_height: u32,
    };

    pub const Configure = extern struct {
        maximized: bool,
        fullscreen: bool,
        resizing: bool,
        activated: bool,
        tiled: wlr.Edges,
        width: u32,
        height: u32,
    };

    pub const Requested = extern struct {
        maximized: bool,
        minimized: bool,
        fullscreen: bool,

        fullscreen_output: ?*wlr.Output,
        fullscreen_output_destroy: wl.Listener(*wlr.Output),
    };

    pub const event = struct {
        pub const SetFullscreen = extern struct {
            surface: *wlr.XdgSurface,
            fullscreen: bool,
            output: ?*wlr.Output,
        };

        pub const Move = extern struct {
            surface: *wlr.XdgSurface,
            seat: *wlr.Seat.Client,
            serial: u32,
        };

        pub const Resize = extern struct {
            surface: *wlr.XdgSurface,
            seat: *wlr.Seat.Client,
            serial: u32,
            edges: wlr.Edges,
        };

        pub const ShowWindowMenu = extern struct {
            surface: *wlr.XdgSurface,
            seat: *wlr.Seat.Client,
            serial: u32,
            x: u32,
            y: u32,
        };
    };

    resource: *xdg.Toplevel,
    base: *wlr.XdgSurface,
    added: bool,
    parent: ?*wlr.XdgSurface,
    parent_unmap: wl.Listener(*XdgSurface),

    current: State,
    pending: State,
    scheduled: Configure,
    requested: Requested,

    title: ?[*:0]u8,
    app_id: ?[*:0]u8,
    events: extern struct {
        request_maximize: wl.Signal(*wlr.XdgSurface),
        request_fullscreen: wl.Signal(*event.SetFullscreen),
        request_minimize: wl.Signal(*wlr.XdgSurface),
        request_move: wl.Signal(*event.Move),
        request_resize: wl.Signal(*event.Resize),
        request_show_window_menu: wl.Signal(*event.ShowWindowMenu),
        set_parent: wl.Signal(*wlr.XdgSurface),
        set_title: wl.Signal(*wlr.XdgSurface),
        set_app_id: wl.Signal(*wlr.XdgSurface),
    },

    extern fn wlr_xdg_toplevel_set_size(surface: *wlr.XdgSurface, width: u32, height: u32) u32;
    pub fn setSize(toplevel: *wlr.XdgToplevel, width: u32, height: u32) u32 {
        return wlr_xdg_toplevel_set_size(toplevel.base, width, height);
    }

    extern fn wlr_xdg_toplevel_set_activated(surface: *wlr.XdgSurface, activated: bool) u32;
    pub fn setActivated(toplevel: *wlr.XdgToplevel, activated: bool) u32 {
        return wlr_xdg_toplevel_set_activated(toplevel.base, activated);
    }

    extern fn wlr_xdg_toplevel_set_maximized(surface: *wlr.XdgSurface, maximized: bool) u32;
    pub fn setMaximized(toplevel: *wlr.XdgToplevel, maximized: bool) u32 {
        return wlr_xdg_toplevel_set_maximized(toplevel.base, maximized);
    }

    extern fn wlr_xdg_toplevel_set_fullscreen(surface: *wlr.XdgSurface, fullscreen: bool) u32;
    pub fn setFullscreen(toplevel: *wlr.XdgToplevel, fullscreen: bool) u32 {
        return wlr_xdg_toplevel_set_fullscreen(toplevel.base, fullscreen);
    }

    extern fn wlr_xdg_toplevel_set_resizing(surface: *wlr.XdgSurface, resizing: bool) u32;
    pub fn setResizing(toplevel: *wlr.XdgToplevel, resizing: bool) u32 {
        return wlr_xdg_toplevel_set_resizing(toplevel.base, resizing);
    }

    extern fn wlr_xdg_toplevel_set_tiled(surface: *wlr.XdgSurface, tiled_edges: u32) u32;
    pub fn setTiled(toplevel: *wlr.XdgToplevel, tiled_edges: wlr.Edges) u32 {
        return wlr_xdg_toplevel_set_tiled(toplevel.base, @bitCast(u32, tiled_edges));
    }

    extern fn wlr_xdg_toplevel_send_close(surface: *wlr.XdgSurface) void;
    pub fn sendClose(toplevel: *wlr.XdgToplevel) void {
        wlr_xdg_toplevel_send_close(toplevel.base);
    }

    extern fn wlr_xdg_toplevel_set_parent(surface: *wlr.XdgSurface, parent: ?*wlr.XdgSurface) void;
    pub fn setParent(toplevel: *wlr.XdgToplevel, parent: ?*wlr.XdgToplevel) void {
        wlr_xdg_toplevel_set_parent(toplevel.base, if (parent) |p| p.base else null);
    }
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
        toplevel_configure: *wlr.XdgToplevel.Configure,
    };

    client: *wlr.XdgClient,
    resource: *xdg.Surface,
    surface: *wlr.Surface,
    /// XdgClient.surfaces
    link: wl.list.Link,

    role: Role,
    role_data: extern union {
        toplevel: *wlr.XdgToplevel,
        popup: *wlr.XdgPopup,
    },

    popups: wl.list.Head(XdgPopup, "link"),

    added: bool,
    configured: bool,
    mapped: bool,
    configure_idle: ?*wl.EventSource,
    scheduled_serial: u32,
    configure_list: wl.list.Head(XdgSurface.Configure, "link"),

    current: State,
    pending: State,

    surface_destroy: wl.Listener(*wlr.Surface),
    surface_commit: wl.Listener(*wlr.Surface),

    events: extern struct {
        destroy: wl.Signal(*wlr.XdgSurface),
        ping_timeout: wl.Signal(*wlr.XdgSurface),
        new_popup: wl.Signal(*wlr.XdgPopup),
        map: wl.Signal(*wlr.XdgSurface),
        unmap: wl.Signal(*wlr.XdgSurface),
        configure: wl.Signal(*wlr.XdgSurface.Configure),
        ack_configure: wl.Signal(*wlr.XdgSurface.Configure),
    },

    data: usize,

    extern fn wlr_xdg_surface_from_resource(resource: *xdg.Surface) ?*wlr.XdgSurface;
    pub const fromResource = wlr_xdg_surface_from_resource;

    extern fn wlr_xdg_surface_from_popup_resource(resource: *xdg.Popup) ?*wlr.XdgSurface;
    pub const fromPopupResource = wlr_xdg_surface_from_popup_resource;

    extern fn wlr_xdg_surface_from_toplevel_resource(resource: *xdg.Toplevel) ?*wlr.XdgSurface;
    pub const fromToplevelResource = wlr_xdg_surface_from_toplevel_resource;

    extern fn wlr_xdg_surface_ping(surface: *wlr.XdgSurface) void;
    pub const ping = wlr_xdg_surface_ping;

    extern fn wlr_xdg_surface_surface_at(surface: *wlr.XdgSurface, sx: f64, sy: f64, sub_x: *f64, sub_y: *f64) ?*wlr.Surface;
    pub const surfaceAt = wlr_xdg_surface_surface_at;

    extern fn wlr_xdg_surface_popup_surface_at(surface: *wlr.XdgSurface, sx: f64, sy: f64, sub_x: *f64, sub_y: *f64) ?*wlr.Surface;
    pub const popupSurfaceAt = wlr_xdg_surface_popup_surface_at;

    extern fn wlr_xdg_surface_from_wlr_surface(surface: *wlr.Surface) *wlr.XdgSurface;
    pub const fromWlrSurface = wlr_xdg_surface_from_wlr_surface;

    extern fn wlr_xdg_surface_get_geometry(surface: *wlr.XdgSurface, box: *wlr.Box) void;
    pub const getGeometry = wlr_xdg_surface_get_geometry;

    extern fn wlr_xdg_surface_for_each_surface(
        surface: *wlr.XdgSurface,
        iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void,
        user_data: ?*anyopaque,
    ) void;
    pub inline fn forEachSurface(
        surface: *wlr.XdgSurface,
        comptime T: type,
        iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: T) callconv(.C) void,
        data: T,
    ) void {
        wlr_xdg_surface_for_each_surface(
            surface,
            @ptrCast(fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void, iterator),
            data,
        );
    }

    extern fn wlr_xdg_surface_for_each_popup_surface(
        surface: *wlr.XdgSurface,
        iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void,
        user_data: ?*anyopaque,
    ) void;
    pub inline fn forEachPopupSurface(
        surface: *wlr.XdgSurface,
        comptime T: type,
        iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: T) callconv(.C) void,
        data: T,
    ) void {
        wlr_xdg_surface_for_each_popup_surface(
            surface,
            @ptrCast(fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void, iterator),
            data,
        );
    }

    extern fn wlr_xdg_surface_schedule_configure(surface: *wlr.XdgSurface) u32;
    pub const scheduleConfigure = wlr_xdg_surface_schedule_configure;
};
