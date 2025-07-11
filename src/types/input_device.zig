const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const InputDevice = extern struct {
    pub const Type = enum(c_int) {
        keyboard,
        pointer,
        touch,
        tablet,
        tablet_pad,
        @"switch",
    };

    type: Type,
    name: ?[*:0]u8,

    events: extern struct {
        destroy: wl.Signal(*InputDevice),
    },

    data: ?*anyopaque,

    extern fn wlr_keyboard_from_input_device(wlr_dev: *InputDevice) *wlr.Keyboard;
    pub const toKeyboard = wlr_keyboard_from_input_device;

    extern fn wlr_pointer_from_input_device(wlr_dev: *InputDevice) *wlr.Pointer;
    pub const toPointer = wlr_pointer_from_input_device;

    extern fn wlr_touch_from_input_device(wlr_dev: *InputDevice) *wlr.Touch;
    pub const toTouch = wlr_touch_from_input_device;

    extern fn wlr_switch_from_input_device(wlr_dev: *InputDevice) *wlr.Switch;
    pub const toSwitch = wlr_switch_from_input_device;

    extern fn wlr_tablet_from_input_device(wlr_dev: *InputDevice) *wlr.Tablet;
    pub const toTablet = wlr_tablet_from_input_device;

    extern fn wlr_tablet_pad_from_input_device(wlr_dev: *InputDevice) *wlr.TabletPad;
    pub const toTabletPad = wlr_tablet_pad_from_input_device;

    extern fn wlr_input_device_get_virtual_keyboard(wlr_dev: *InputDevice) ?*wlr.VirtualKeyboardV1;
    pub const getVirtualKeyboard = wlr_input_device_get_virtual_keyboard;

    extern fn wlr_input_device_is_libinput(wlr_dev: *InputDevice) bool;
    pub const isLibinput = wlr_input_device_is_libinput;

    extern fn wlr_libinput_get_device_handle(wlr_dev: *InputDevice) *LibinputDevice;
    pub fn getLibinputDevice(wlr_dev: *InputDevice) ?*LibinputDevice {
        if (!wlr_input_device_is_libinput(wlr_dev)) return null;
        return wlr_libinput_get_device_handle(wlr_dev);
    }

    extern fn wlr_input_device_is_wl(wlr_dev: *InputDevice) bool;
    pub const isWl = wlr_input_device_is_wl;

    extern fn wlr_input_device_is_x11(wlr_dev: *InputDevice) bool;
    pub const isX11 = wlr_input_device_is_x11;
};

const LibinputDevice = opaque {};
