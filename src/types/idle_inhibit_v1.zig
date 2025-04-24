const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const IdleInhibitManagerV1 = extern struct {
    inhibitors: wl.list.Head(IdleInhibitorV1, .link),
    global: *wl.Global,

    events: extern struct {
        new_inhibitor: wl.Signal(*IdleInhibitorV1),
        destroy: wl.Signal(*IdleInhibitManagerV1),
    },

    data: ?*anyopaque,

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_idle_inhibit_v1_create(server: *wl.Server) ?*IdleInhibitManagerV1;
    pub fn create(server: *wl.Server) !*IdleInhibitManagerV1 {
        return wlr_idle_inhibit_v1_create(server) orelse error.OutOfMemory;
    }
};

pub const IdleInhibitorV1 = extern struct {
    surface: *wlr.Surface,
    resource: *wl.Resource,

    link: wl.list.Link,

    events: extern struct {
        destroy: wl.Signal(*wlr.Surface),
    },

    data: ?*anyopaque,

    private: extern struct {
        surface_destroy: wl.Listener(void),
    },
};
