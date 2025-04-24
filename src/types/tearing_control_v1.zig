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

    private: extern struct {
        previous: wp.TearingControlV1.PresentationHint,
        addon: wlr.Addon,
        synced: wlr.Surface.Synced,

        surface_commit: wl.Listener(void),
    },
};

pub const TearingControlManagerV1 = extern struct {
    global: *wl.Global,
    surface_hints: wl.list.Head(TearingControlV1, .link),

    events: extern struct {
        new_object: wl.Signal(*TearingControlV1),
        destroy: wl.Signal(void),
    },

    data: ?*anyopaque,

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

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
