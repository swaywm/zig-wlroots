const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const AxisSource = enum(c_int) {
    wheel,
    finger,
    continuous,
    wheel_tilt,
};

pub const AxisOrientation = enum(c_int) {
    vertical,
    horizontal,
};

pub const Pointer = extern struct {
    pub const event = struct {
        pub const Motion = extern struct {
            device: *wlr.InputDevice,
            time_msec: u32,
            delta_x: f64,
            delta_y: f64,
            unaccel_dx: f64,
            unaccel_dy: f64,
        };

        pub const MotionAbsolute = extern struct {
            device: *wlr.InputDevice,
            time_msec: u32,
            x: f64,
            y: f64,
        };

        pub const Button = extern struct {
            device: *wlr.InputDevice,
            time_msec: u32,
            button: u32,
            state: wl.Pointer.ButtonState,
        };

        pub const Axis = extern struct {
            device: *wlr.InputDevice,
            time_msec: u32,
            source: AxisSource,
            orientation: AxisOrientation,
            delta: f64,
            delta_discrete: i32,
        };

        pub const SwipeBegin = extern struct {
            device: *wlr.InputDevice,
            time_msec: u32,
            fingers: u32,
        };

        pub const SwipeUpdate = extern struct {
            device: *wlr.InputDevice,
            time_msec: u32,
            fingers: u32,
            dx: f64,
            dy: f64,
        };

        pub const SwipeEnd = extern struct {
            device: *wlr.InputDevice,
            time_msec: u32,
            cancelled: bool,
        };

        pub const PinchBegin = extern struct {
            device: *wlr.InputDevice,
            time_msec: u32,
            fingers: u32,
        };

        pub const PinchUpdate = extern struct {
            device: *wlr.InputDevice,
            time_msec: u32,
            fingers: u32,
            dx: f64,
            dy: f64,
            scale: f64,
            rotation: f64,
        };

        pub const PinchEnd = extern struct {
            device: *wlr.InputDevice,
            time_msec: u32,
            cancelled: bool,
        };

        pub const HoldBegin = extern struct {
            device: *wlr.InputDevice,
            time_msec: u32,
            fingers: u32,
        };

        pub const HoldEnd = extern struct {
            device: *wlr.InputDevice,
            time_msec: u32,
            cancelled: bool,
        };
    };

    const Impl = opaque {};

    base: wlr.InputDevice,

    impl: *const Impl,

    output_name: [*:0]u8,

    events: extern struct {
        motion: wl.Signal(*event.Motion),
        motion_absolute: wl.Signal(*event.MotionAbsolute),
        button: wl.Signal(*event.Button),
        axis: wl.Signal(*event.Axis),
        frame: wl.Signal(*Pointer),

        swipe_begin: wl.Signal(*event.SwipeBegin),
        swipe_update: wl.Signal(*event.SwipeUpdate),
        swipe_end: wl.Signal(*event.SwipeEnd),

        pinch_begin: wl.Signal(*event.PinchBegin),
        pinch_update: wl.Signal(*event.PinchUpdate),
        pinch_end: wl.Signal(*event.PinchEnd),

        hold_begin: wl.Signal(*event.HoldBegin),
        hold_end: wl.Signal(*event.HoldEnd),
    },
};
