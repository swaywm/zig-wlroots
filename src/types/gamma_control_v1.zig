const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const GammaControlManagerV1 = extern struct {
    global: *wl.Global,
    controls: wl.list.Head(GamaControlV1, "link"),

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        destroy: wl.Signal(*GammaControlManagerV1),
    },

    data: usize,

    extern fn wlr_gamma_control_manager_v1_create(server: *wl.Server) ?*GammaControlManagerV1;
    pub fn create(server: *wl.Server) !*GammaControlManagerV1 {
        return wlr_gamma_control_manager_v1_create(server) orelse error.OutOfMemory;
    }
};

pub const GamaControlV1 = extern struct {
    resource: *wl.Resource,
    output: *wlr.Output,
    /// GammaControlManagerV1.controls
    link: wl.list.Link,

    table: *u16,
    ramp_size: usize,

    output_commit_listener: wl.Listener(*wlr.Output.event.Commit),
    output_destroy_listener: wl.Listener(*wlr.Output),

    data: usize,
};
