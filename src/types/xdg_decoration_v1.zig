const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const zxdg = wayland.server.zxdg;

pub const XdgDecorationManagerV1 = extern struct {
    global: *wl.Global,
    decorations: wl.list.Head(XdgToplevelDecorationV1, .link),

    events: extern struct {
        new_toplevel_decoration: wl.Signal(*XdgToplevelDecorationV1),
        destroy: wl.Signal(*XdgDecorationManagerV1),
    },

    data: ?*anyopaque,

    extern fn wlr_xdg_decoration_manager_v1_create(server: *wl.Server) ?*XdgDecorationManagerV1;
    pub fn create(server: *wl.Server) !*XdgDecorationManagerV1 {
        return wlr_xdg_decoration_manager_v1_create(server) orelse error.OutOfMemory;
    }
};

pub const XdgToplevelDecorationV1 = extern struct {
    pub const Mode = enum(c_int) {
        none = 0,
        client_side = 1,
        server_side = 2,
    };

    pub const State = extern struct {
        mode: Mode,
    };

    pub const Configure = extern struct {
        /// XdgToplevelDecorationV1.configure_list
        link: wl.list.Link,
        surface_configure: *wlr.XdgSurface.Configure,
        mode: Mode,
    };

    resource: *zxdg.ToplevelDecorationV1,
    toplevel: *wlr.XdgToplevel,
    manager: *XdgDecorationManagerV1,
    /// XdgDecorationManagerV1.decorations
    link: wl.list.Link,

    current: State,
    pending: State,

    scheduled_mode: Mode,
    requested_mode: Mode,

    configure_list: wl.list.Head(XdgToplevelDecorationV1.Configure, .link),

    events: extern struct {
        destroy: wl.Signal(*XdgToplevelDecorationV1),
        request_mode: wl.Signal(*XdgToplevelDecorationV1),
    },

    data: ?*anyopaque,

    extern fn wlr_xdg_toplevel_decoration_v1_set_mode(decoration: *XdgToplevelDecorationV1, mode: Mode) u32;
    pub const setMode = wlr_xdg_toplevel_decoration_v1_set_mode;
};
