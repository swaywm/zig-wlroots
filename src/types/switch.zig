const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const SwitchType = enum(c_int) {
    lid,
    tablet_mode,
};

pub const SwitchState = enum(c_int) {
    off,
    on,
};

pub const Switch = extern struct {
    pub const event = struct {
        pub const Toggle = extern struct {
            device: *wlr.InputDevice,
            time_msec: u32,
            switch_type: SwitchType,
            switch_state: SwitchState,
        };
    };

    const Impl = opaque {};

    base: wlr.InputDevice,

    impl: *const Impl,

    events: extern struct {
        toggle: wl.Signal(*event.Toggle),
    },

    data: usize,
};
