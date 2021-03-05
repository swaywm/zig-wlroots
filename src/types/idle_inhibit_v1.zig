const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const IdleInhibitManagerV1 = extern struct {
    inhibitors: wl.list.Head(IdleInhibitorV1, "link"),
    global: *wl.Global,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        new_inhibitor: wl.Signal(*IdleInhibitorV1),
        destroy: wl.Signal(*IdleInhibitManagerV1),
    },

    data: usize,

    extern fn wlr_idle_inhibit_v1_create(server: *wl.Server) ?*IdleInhibitManagerV1;
    pub fn create(server: *wl.Server) !*IdleInhibitManagerV1 {
        return wlr_idle_inhibit_v1_create(server) orelse error.OutOfMemory;
    }
};

pub const IdleInhibitorV1 = extern struct {
    surface: *wlr.Surface,
    resource: *wl.Resource,
    surface_destroy: wl.Listener(*wlr.Surface),

    link: wl.list.Link,

    events: extern struct {
        destroy: wl.Signal(*IdleInhibitorV1),
    },

    data: usize,
};
