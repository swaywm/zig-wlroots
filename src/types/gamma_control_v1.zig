const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const GammaControlManagerV1 = extern struct {
    pub const event = struct {
        pub const SetGamma = extern struct {
            output: *wlr.Output,
            control: ?*wlr.GammaControlV1,
        };
    };

    global: *wl.Global,
    controls: wl.list.Head(GammaControlV1, .link),

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        destroy: wl.Signal(*GammaControlManagerV1),
        set_gamma: wl.Signal(*event.SetGamma),
    },

    data: usize,

    extern fn wlr_gamma_control_manager_v1_create(server: *wl.Server) ?*GammaControlManagerV1;
    pub fn create(server: *wl.Server) !*GammaControlManagerV1 {
        return wlr_gamma_control_manager_v1_create(server) orelse error.OutOfMemory;
    }

    extern fn wlr_gamma_control_manager_v1_get_control(manager: *GammaControlManagerV1, output: *wlr.Output) ?*GammaControlV1;
    pub const getControl = wlr_gamma_control_manager_v1_get_control;
};

pub const GammaControlV1 = extern struct {
    resource: *wl.Resource,
    output: *wlr.Output,
    manager: *wlr.GammaControlManagerV1,
    /// GammaControlManagerV1.controls
    link: wl.list.Link,

    table: *u16,
    ramp_size: usize,

    output_destroy_listener: wl.Listener(*wlr.Output),

    data: usize,

    extern fn wlr_gamma_control_v1_apply(gamma_control: GammaControlV1, output_state: *wlr.Output.State) bool;
    pub const apply = wlr_gamma_control_v1_apply;

    extern fn wlr_gamma_control_v1_send_failed_and_destroy(gamma_control: *GammaControlV1) void;
    pub const sendFailedAndDestroy = wlr_gamma_control_v1_send_failed_and_destroy;
};
