const wlr = @import("../wlroots.zig");
const wl = @import("wayland").server.wl;

pub const OutputManagerV1 = extern struct {
    server: *wl.Server,
    global: *wl.Global,
    resources: wl.list.Head(wl.Resource, null),

    heads: wl.list.Head(OutputHeadV1, "link"),
    serial: u32,
    current_configuration_dirty: bool,

    events: extern struct {
        apply: wl.Signal(*OutputConfigurationV1),
        @"test": wl.Signal(*OutputConfigurationV1),
        destroy: wl.Signal(*OutputManagerV1),
    },

    server_destroy: wl.Listener(*wl.Server),

    data: usize,

    extern fn wlr_output_manager_v1_create(server: *wl.Server) ?*OutputManagerV1;
    pub fn create(server: *wl.Server) !*OutputManagerV1 {
        return wlr_output_manager_v1_create(server) orelse error.OutOfMemory;
    }

    extern fn wlr_output_manager_v1_set_configuration(manager: *OutputManagerV1, config: *OutputConfigurationV1) void;
    pub const setConfiguration = wlr_output_manager_v1_set_configuration;
};

pub const OutputHeadV1 = extern struct {
    pub const State = extern struct {
        output: *wlr.Output,

        enabled: bool,
        mode: ?*wlr.Output.Mode,
        custom_mode: extern struct {
            width: i32,
            height: i32,
            refresh: i32,
        },
        x: i32,
        y: i32,
        transform: wl.Output.Transform,
        scale: f32,
    };

    state: State,
    manager: *OutputManagerV1,
    link: wl.list.Link,

    resources: wl.list.Head(wl.Resource, null),
    mode_resources: wl.list.Head(wl.Resource, null),

    output_destroy: wl.Listener(*wlr.Output),
};

pub const OutputConfigurationV1 = extern struct {
    pub const Head = extern struct {
        state: OutputHeadV1.State,
        config: *OutputConfigurationV1,
        link: wl.list.Link,

        resource: ?*wl.Resource,

        output_destroy: wl.Listener(*wlr.Output),

        extern fn wlr_output_configuration_head_v1_create(config: *OutputConfigurationV1, output: *wlr.Output) ?*Head;
        pub fn create(config: *OutputConfigurationV1, output: *wlr.Output) !*Head {
            return wlr_output_configuration_head_v1_create(config, output) orelse error.OutOfMemory;
        }
    };

    heads: wl.list.Head(Head, "link"),

    manager: *OutputManagerV1,
    serial: u32,
    finalized: bool,
    finished: bool,
    resource: ?*wl.Resource,

    extern fn wlr_output_configuration_v1_create() ?*OutputConfigurationV1;
    pub fn create() !*OutputConfigurationV1 {
        return wlr_output_configuration_v1_create() orelse error.OutOfMemory;
    }

    extern fn wlr_output_configuration_v1_destroy(config: *OutputConfigurationV1) void;
    pub const destroy = wlr_output_configuration_v1_destroy;

    extern fn wlr_output_configuration_v1_send_succeeded(config: *OutputConfigurationV1) void;
    pub const sendSucceeded = wlr_output_configuration_v1_send_succeeded;

    extern fn wlr_output_configuration_v1_send_failed(config: *OutputConfigurationV1) void;
    pub const sendFailed = wlr_output_configuration_v1_send_failed;
};
