const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const zwp = wayland.server.zwp;

pub const TabletTool = extern struct {
    pub const Type = enum(c_int) {
        pen = 1,
        eraser,
        brush,
        pencil,
        airbrush,
        mouse,
        lens,
        totem,
    };

    pub const Axes = packed struct(u32) {
        x: bool = false,
        y: bool = false,
        distance: bool = false,
        pressure: bool = false,
        tilt_x: bool = false,
        tilt_y: bool = false,
        rotation: bool = false,
        slider: bool = false,
        wheel: bool = false,
        _: u23 = 0,
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

    data: ?*anyopaque,
};

pub const Tablet = extern struct {
    pub const event = struct {
        pub const Axis = extern struct {
            device: *wlr.InputDevice,
            tool: *TabletTool,

            time_msec: u32,
            updated_axes: wlr.TabletTool.Axes,
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
            pub const State = enum(c_int) {
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
            pub const State = enum(c_int) {
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
            button: u32,
            state: zwp.TabletToolV2.ButtonState,
        };
    };

    const Impl = opaque {};

    base: wlr.InputDevice,

    impl: *const Impl,

    usb_vendor_id: u16,
    usb_product_id: u16,
    width_mm: f64,
    height_mm: f64,

    events: extern struct {
        axis: wl.Signal(*event.Axis),
        proximity: wl.Signal(*event.Proximity),
        tip: wl.Signal(*event.Tip),
        button: wl.Signal(*event.Button),
    },

    paths: wl.Array,

    data: ?*anyopaque,
};
