const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const xdg = wayland.server.xdg;

pub const XdgShell = extern struct {
    global: *wl.Global,
    /// XdgClient.link
    clients: wl.List,
    /// XdgPopup.Grab.link
    popup_grabs: wl.List,
    ping_timeout: u32,

    display_destroy: wl.Listener,

    events: extern struct {
        new_surface: wl.Listener, // wlr.XdgSurface
        destroy: wl.Listener, // wlr.XdgShell
    },

    data: ?*c_void,

    extern fn wlr_xdg_shell_create(server: *wl.Server) ?*wlr.XdgShell;
    pub const create = wlr_xdg_shell_create;
};

pub const XdgClient = extern struct {
    shell: *wlr.XdgShell,
    resource: *xdg.WmBase,
    client: *wl.Client,
    /// XdgSurface.link
    surfaces: wl.List,
    /// XdgShell.clients
    link: wl.List,

    ping_serial: u32,
    ping_timer: *wl.EventSource,
};

pub const XdgPositioner = extern struct {
    /// This field is never initialized or used by wlroots, using it would be a bug
    /// TODO(wlroots11): remove this
    _: *wl.Resource,

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

pub const XdgPopup = extern struct {
    pub const Grab = extern struct {
        client: *wl.Client,

        pointer_grab: wlr.Seat.PointerGrab,
        keyboard_grab: wlr.Seat.KeyboardGrab,
        touch_grab: wlr.Seat.TouchGrab,
        seat: *wlr.Seat,

        /// XdgPopup.grab_link
        popups: wl.List,
        /// XdgShell.popup_grabs
        link: wl.List,

        seat_destroy: wl.Listener,
    };

    base: *wlr.XdgSurface,
    link: wl.List,

    resource: *xdg.Popup,
    committed: bool,
    parent: ?*wlr.Surface,
    seat: ?*wlr.Seat,

    geometry: wlr.Box,
    positioner: wlr.XdgPositioner,
    /// Grab.popups
    grab_link: wl.List,

    extern fn wlr_xdg_popup_destroy(surface: *wlr.Surface) void;
    pub inline fn destroy(popup: *wlr.XdgPopup) void {
        wlr_xdg_popup_destroy(popup.base);
    }

    extern fn wlr_xdg_popup_get_anchor_point(popup: *wlr.Popup, toplevel_sx: *c_int, toplevel_sy: *c_int) void;
    pub const getAnchorPoint = wlr_xdg_popup_get_anchor_point;

    extern fn wlr_xdg_popup_get_toplevel_coords(popup: *wlr.Popup, popup_sx: c_int, popup_sy: c_int, toplevel_sx: *c_int, toplevel_sy: *c_int) void;
    pub const getToplevelCoords = wlr_xdg_popup_get_toplevel_coords;

    extern fn wlr_xdg_popup_unconstrain_from_box(popup: *wlr.Popup, toplevel_sx_box: *wlr.Box) void;
    pub const unconstrainFromBox = wlr_xdg_popup_unconstrain_from_box;
};

pub const XdgToplevel = extern struct {
    pub const State = extern struct {
        maximized: bool,
        fullscreen: bool,
        resizing: bool,
        activated: bool,
        tiled: u32,
        width: u32,
        height: u32,
        max_width: u32,
        max_height: u32,
        min_width: u32,
        min_height: u32,
        fullscreen_output: ?*wlr.Output,
        fullscreen_output_destroy: wl.Listener,
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
            edges: u32,
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
    parent_unmap: wl.Listener,
    client_pending: State,
    server_pending: State,
    last_acked: State,
    current: State,
    title: ?[*:0]u8,
    app_id: ?[*:0]u8,
    events: extern struct {
        request_maximize: wl.Signal,
        request_fullscreen: wl.Signal, // event.SetFullscreen
        request_minimize: wl.Signal,
        request_move: wl.Signal, // event.Move
        request_resize: wl.Signal, // event.Resize
        request_show_window_menu: wl.Signal, // event.ShowWindowMenu
        set_parent: wl.Signal,
        set_title: wl.Signal,
        set_app_id: wl.Signal,
    },

    extern fn wlr_xdg_toplevel_set_size(surface: *wlr.XdgSurface, width: u32, height: u32) u32;
    pub fn setSize(toplevel: *wlr.Toplevel, width: u32, height: u32) u32 {
        return wlr_xdg_toplevel_set_size(toplevel.base, width, height);
    }

    extern fn wlr_xdg_toplevel_set_activated(surface: *wlr.XdgSurface, activated: bool) u32;
    pub fn setActivated(toplevel: *wlr.Toplevel, activated: bool) u32 {
        return wlr_xdg_toplevel_set_activated(toplevel.base, activated);
    }

    extern fn wlr_xdg_toplevel_set_maximized(surface: *wlr.XdgSurface, maximized: bool) u32;
    pub fn setMaximized(toplevel: *wlr.Toplevel, maximized: bool) u32 {
        return wlr_xdg_toplevel_set_maximized(toplevel.base, maximized);
    }

    extern fn wlr_xdg_toplevel_set_fullscreen(surface: *wlr.XdgSurface, fullscreen: bool) u32;
    pub fn setFullscreen(toplevel: *wlr.Toplevel, fullscreen: bool) u32 {
        return wlr_xdg_toplevel_set_fullscreen(toplevel.base, fullscreen);
    }

    extern fn wlr_xdg_toplevel_set_resizing(surface: *wlr.XdgSurface, resizing: bool) u32;
    pub fn setResizing(toplevel: *wlr.Toplevel, resizing: bool) u32 {
        return wlr_xdg_toplevel_set_resizing(toplevel.base, resizing);
    }

    extern fn wlr_xdg_toplevel_set_tiled(surface: *wlr.XdgSurface, tiled_edges: u32) u32;
    pub fn setTiled(toplevel: *wlr.Toplevel, tiled_edges: u32) u32 {
        return wlr_xdg_toplevel_set_tiled(toplevel.base, tiled_edges);
    }

    extern fn wlr_xdg_toplevel_send_close(surface: *wlr.XdgSurface) void;
    pub fn sendClose(toplevel: *wlr.Toplevel) void {
        wlr_xdg_toplevel_send_close(toplevel.base);
    }
};

pub const XdgSurface = extern struct {
    pub const Role = extern enum {
        none,
        toplevel,
        popup,
    };

    pub const Configure = extern struct {
        surface: *wlr.XdgSurface,
        /// XdgSurface.configure_list
        link: wl.List,
        serial: u32,
        toplevel_state: *wlr.XdgToplevel.State,
    };

    client: *wlr.XdgClient,
    resource: *xdg.Surface,
    surface: *wlr.Surface,
    /// XdgClient.surfaces
    link: wl.List,

    role: Role,
    role_data: extern union {
        toplevel: *wlr.XdgToplevel,
        popup: *wlr.XdgPopup,
    },

    /// wlr.XdgPopup.link
    popups: wl.List,

    added: bool,
    configured: bool,
    mapped: bool,
    configure_serial: u32,
    configure_idle: ?*wl.EventSource,
    configure_next_serial: u32,
    configure_list: wl.List,

    has_next_geometry: bool,
    next_geometry: wlr.Box,
    geometry: wlr.Box,

    surface_destroy: wl.Listener,
    surface_commit: wl.Listener,

    events: extern struct {
        destroy: wl.Signal,
        ping_timeout: wl.Signal,
        new_popup: wl.Signal,
        map: wl.Signal,
        unmap: wl.Signal,
        configure: wl.Signal, // wlr.XdgSurface.Configure
        ack_configure: wl.Signal, // wlr.XdgSurface.Configure
    },

    data: ?*c_void,

    extern fn wlr_xdg_surface_from_resource(resource: *xdg.Surface) ?*wlr.XdgSurface;
    pub const fromResource = wlr_xdg_surface_from_resource;

    extern fn wlr_xdg_surface_from_popup_resource(resource: *xdg.Popup) ?*wlr.XdgSurface;
    pub const fromPopupResource = wlr_xdg_surface_from_popup_resource;

    extern fn wlr_xdg_surface_from_toplevel_resource(resource: xdg.Toplevel) ?*wlr.XdgSurface;
    pub const fromToplevelResource = wlr_xdg_surface_from_toplevel_resource;

    extern fn wlr_xdg_surface_ping(surface: *wlr.XdgSurface) void;
    pub const ping = wlr_xdg_surface_ping;

    extern fn wlr_xdg_surface_surface_at(surface: *wlr.XdgSurface, sx: f64, sy: f64, sub_x: *f64, sub_y: *f64) ?*wlr.Surface;
    pub const surfaceAt = wlr_xdg_surface_surface_at;

    extern fn wlr_xdg_surface_from_wlr_surface(surface: *wlr.Surface) *wlr.XdgSurface;
    pub const fromWlrSurface = wlr_xdg_surface_from_wlr_surface;

    extern fn wlr_xdg_surface_get_geometry(surface: *wlr.XdgSurface, box: *wlr.Box) void;
    pub const getGeometry = wlr_xdg_surface_get_geometry;

    extern fn wlr_xdg_surface_for_each_surface(
        surface: *wlr.XdgSurface,
        iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: ?*c_void) void,
        user_data: ?*c_void,
    ) void;
    pub fn forEachSurface(
        surface: *wlr.XdgSurface,
        comptime T: type,
        iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: T) callconv(.C) void,
        data: T,
    ) void {
        wlr_xdg_surface_for_each_surface(surface, iterator, data);
    }

    extern fn wlr_xdg_surface_schedule_configure(surface: *wlr.XdgSurface) u32;
    pub const scheduleConfigure = wlr_xdg_surface_schedule_configure;

    extern fn wlr_xdg_surface_for_each_popup(
        surface: *wlr.XdgSurface,
        iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: ?*c_void) void,
        user_data: ?*c_void,
    ) void;
    pub fn forEachPopup(
        surface: *wlr.XdgSurface,
        comptime T: type,
        iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: T) callconv(.C) void,
        data: T,
    ) void {
        wlr_xdg_surface_for_each_popup(surface, iterator, data);
    }
};
