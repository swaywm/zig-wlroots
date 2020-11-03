const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const GammaControlManagerV1 = extern struct {
    global: *wl.Global,
    /// GamaControlV1.link
    controls: wl.List,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        destroy: wl.Signal(*GammaControlManagerV1),
    },

    data: ?*c_void,

    extern fn wlr_gamma_control_manager_v1_create(server: *wl.Server) ?*GammaControlManagerV1;
    pub const create = wlr_gamma_control_manager_v1_create;
};

pub const GamaControlV1 = extern struct {
    resource: *wl.Resource,
    output: *wlr.Output,
    /// GammaControlManagerV1.controls
    link: wl.List,

    output_destroy_listener: wl.Listener(*wlr.Output),

    data: ?*c_void,
};
