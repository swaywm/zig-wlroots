const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Viewporter = extern struct {
    global: *wl.Global,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    server_destroy: wl.Listener(*wl.Server),

    extern fn wlr_viewporter_create(server: *wl.Server) ?*Viewporter;
    pub const create = wlr_viewporter_create;
};

pub const Viewport = extern struct {
    resource: *wl.Resource,
    surface: *wlr.Surface,

    surface_destroy: wl.Listener(*wlr.Surface),
    surface_commit: wl.Listener(*wlr.Surface),
};
