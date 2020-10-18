const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const ButtonState = extern enum {
    pressed,
    released,
};

pub const InputDevice = extern struct {
    pub const Type = extern enum {
        Keyboard,
        Pointer,
        Touch,
        TabletTool,
        TabletPad,
        Switch,
    };

    const Impl = opaque {};

    impl: *const Impl,

    kind: Type,
    vendor: c_uint,
    product: c_uint,
    name: [*:0]u8,

    width_mm: f64,
    height_mm: f64,
    output_name: [*:0]u8,

    /// InputDevice.kind determines which of these is active
    device: extern union {
        _device: ?*c_void,
        keyboard: *wlr.Keyboard,
        pointer: *wlr.Pointer,
        switch_device: *wlr.Switch,
        touch: *wlr.Touch,
        tablet: *wlr.Tablet,
        tablet_pad: *wlr.TabletPad,
    },

    events: extern struct {
        destroy: wl.Signal(*InputDevice),
    },

    data: ?*c_void,

    link: wl.List,
};
