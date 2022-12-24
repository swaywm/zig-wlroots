const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const InputDevice = extern struct {
    pub const Type = enum(c_int) {
        keyboard,
        pointer,
        touch,
        tablet_tool,
        tablet_pad,
        switch_device,
    };

    type: Type,
    vendor: c_uint,
    product: c_uint,
    name: [*:0]u8,

    events: extern struct {
        destroy: wl.Signal(*InputDevice),
    },

    data: usize,

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

    extern fn wlr_input_device_get_virtual_keyboard(wlr_dev: *InputDevice) ?*wlr.VirtualKeyboardV1;
    pub const getVirtualKeyboard = wlr_input_device_get_virtual_keyboard;

    pub usingnamespace if (wlr.config.has_libinput_backend) struct {
        extern fn wlr_input_device_is_libinput(wlr_dev: *InputDevice) bool;
        pub const isLibinput = wlr_input_device_is_libinput;

        extern fn wlr_libinput_get_device_handle(wlr_dev: *InputDevice) *LibinputDevice;
        pub fn getLibinputDevice(wlr_dev: *InputDevice) ?*LibinputDevice {
            if (!wlr_input_device_is_libinput(wlr_dev)) return null;
            return wlr_libinput_get_device_handle(wlr_dev);
        }
    } else struct {};
};

const LibinputDevice = opaque {};
