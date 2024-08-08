const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const wp = wayland.server.wp;

pub const TearingControlV1 = extern struct {
    client: *wl.Client,
    link: wl.list.Link,
    resource: *wl.Resource,

    current: wp.TearingControlV1.PresentationHint,
    pending: wp.TearingControlV1.PresentationHint,

    events: extern struct {
        set_hint: wl.Signal(void),
        destroy: wl.Signal(void),
    },

    surface: *wlr.Surface,
};

pub const TearingControlManagerV1 = extern struct {
    global: *wl.Global,
    surface_hints: wl.list.Head(TearingControlV1, .link),

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        new_object: wl.Signal(*TearingControlV1),
        destroy: wl.Signal(void),
    },

    data: ?*anyopaque,

    extern fn wlr_tearing_control_manager_v1_create(server: *wl.Server, version: u32) ?*TearingControlManagerV1;
    pub fn create(server: *wl.Server, version: u32) !*TearingControlManagerV1 {
        return wlr_tearing_control_manager_v1_create(server, version) orelse error.OutOfMemory;
    }

    extern fn wlr_tearing_control_manager_v1_surface_hint_from_surface(
        manager: *TearingControlManagerV1,
        surface: *wlr.Surface,
    ) wp.TearingControlV1.PresentationHint;
    pub const hintFromSurface = wlr_tearing_control_manager_v1_surface_hint_from_surface;
};
