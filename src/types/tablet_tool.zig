const wlr = @import("../wlroots.zig");

const wl = @import("wayland").server.wl;

pub const TabletTool = extern struct {
    pub const Type = extern enum {
        pen = 1,
        eraser,
        brush,
        pencil,
        airbrush,
        mouse,
        lens,
        totem,
    };

    pub const Axis = extern enum {
        x = 1 << 0,
        y = 1 << 1,
        distance = 1 << 2,
        pressure = 1 << 3,
        tilt_x = 1 << 4,
        tilt_y = 1 << 5,
        rotation = 1 << 6,
        slider = 1 << 7,
        wheel = 1 << 8,
    };

    pub const ProximityState = extern enum {
        out,
        in,
    };

    pub const TipState = extern enum {
        up,
        down,
    };

    type: Type,
    hardware_serial: u64,
    hardware_wacom: u64,

    tilt: bool,
    pressure: bool,
    distance: bool,
    rotation: bool,
    slider: bool,
    wheel: bool,

    events: extern struct {
        destroy: wl.Signal(*TabletTool),
    },

    data: usize,
};

pub const Tablet = extern struct {
    pub const event = struct {
        pub const Axis = extern struct {
            device: *wlr.InputDevice,
            tool: *TabletTool,

            time_msec: u32,
            updated_axes: u32,
            /// From 0..1
            x: f64,
            /// From 0..1
            y: f64,
            /// Relative to last event
            dx: f64,
            /// Relative to last event
            dy: f64,
            pressure: f64,
            distance: f64,
            tilt_x: f64,
            tilt_y: f64,
            rotation: f64,
            slider: f64,
            wheel_delta: f64,
        };

        pub const Proximity = extern struct {
            pub const State = extern enum {
                out,
                in,
            };

            device: *wlr.InputDevice,
            tool: *TabletTool,

            time_msec: u32,
            x: f64,
            y: f64,
            state: Proximity.State,
        };

        pub const Tip = extern struct {
            pub const State = extern enum {
                up,
                down,
            };

            device: *wlr.InputDevice,
            tool: *TabletTool,

            time_msec: u32,
            x: f64,
            y: f64,
            state: Tip.State,
        };

        pub const Button = extern struct {
            device: *wlr.InputDevice,
            tool: *TabletTool,

            time_msec: u32,
            x: f64,
            y: f64,
            state: wl.Pointer.ButtonState,
        };
    };

    const Impl = opaque {};

    impl: *const Impl,

    events: extern struct {
        axis: wl.Signal(*event.Axis),
        proximity: wl.Signal(*event.Proximity),
        tip: wl.Signal(*event.Tip),
        button: wl.Signal(*event.Button),
    },

    name: [*:0]u8,
    paths: wlr.List,

    data: usize,
};
