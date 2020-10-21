const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const InputDevice = extern struct {
    pub const Type = extern enum {
        keyboard,
        pointer,
        touch,
        tablet_tool,
        tablet_pad,
        switch_device,
    };

    const Impl = opaque {};

    impl: *const Impl,

    type: Type,
    vendor: c_uint,
    product: c_uint,
    name: [*:0]u8,

    width_mm: f64,
    height_mm: f64,
    output_name: [*:0]u8,

    /// InputDevice.type determines which of these is active
    device: extern union {
        _device: ?*c_void,
        keyboard: *wlr.Keyboard,
        pointer: *wlr.Pointer,
        // TODO:
        //switch_device: *wlr.Switch,
        touch: *wlr.Touch,
        tablet: *wlr.Tablet,
        // TODO:
        //tablet_pad: *wlr.TabletPad,
    },

    events: extern struct {
        destroy: wl.Signal(*InputDevice),
    },

    data: ?*c_void,

    link: wl.List,
};
