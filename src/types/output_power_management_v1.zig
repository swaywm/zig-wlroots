const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const wlr_proto = wayland.server.wlr;

pub const OutputPowerManagerV1 = extern struct {
    pub const event = struct {
        pub const SetMode = extern struct {
            output: *wlr.Output,
            mode: wlr_proto.OutputPowerV1.Mode,
        };
    };

    global: *wl.Global,
    /// OutputPowerV1.link
    output_powers: wl.List,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        set_mode: wl.Signal(*event.SetMode),
        destroy: wl.Signal(*OutputPowerManagerV1),
    },

    data: ?*c_void,

    extern fn wlr_output_power_manager_v1_create(server: *wl.Server) ?*OutputPowerManagerV1;
    pub const create = wlr_output_power_manager_v1_create;
};

pub const OutputPowerV1 = extern struct {
    resource: *wl.Resource,
    output: *wlr.Output,
    manager: *OutputPowerManagerV1,
    /// OutputPowerManagerV1.output_powers
    link: wl.List,

    output_destroy_listener: wl.Listener(*wlr.Output),
    output_commit_listener: wl.Listener(*wlr.Output.event.Commit),

    data: ?*c_void,
};
