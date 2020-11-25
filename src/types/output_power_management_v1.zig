const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const zwlr = wayland.server.zwlr;

pub const OutputPowerManagerV1 = extern struct {
    pub const event = struct {
        pub const SetMode = extern struct {
            output: *wlr.Output,
            mode: zwlr.OutputPowerV1.Mode,
        };
    };

    global: *wl.Global,
    output_powers: wl.list.Head(OutputPowerV1, "link"),

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        set_mode: wl.Signal(*event.SetMode),
        destroy: wl.Signal(*OutputPowerManagerV1),
    },

    data: usize,

    extern fn wlr_output_power_manager_v1_create(server: *wl.Server) ?*OutputPowerManagerV1;
    pub fn create(server: *wl.Server) !*OutputPowerManagerV1 {
        return wlr_output_power_manager_v1_create(server) orelse error.OutOfMemory;
    }
};

pub const OutputPowerV1 = extern struct {
    resource: *wl.Resource,
    output: *wlr.Output,
    manager: *OutputPowerManagerV1,
    /// OutputPowerManagerV1.output_powers
    link: wl.list.Link,

    output_destroy_listener: wl.Listener(*wlr.Output),
    output_commit_listener: wl.Listener(*wlr.Output.event.Commit),

    data: usize,
};
