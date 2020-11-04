const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const VirtualKeyboardManagerV1 = extern struct {
    global: *wl.Global,
    /// VirtualKeyboardV1.link
    virtual_keyboards: wl.List,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        new_virtual_keyboard: wl.Signal(*VirtualKeyboardV1),
        destroy: wl.Signal(*VirtualKeyboardManagerV1),
    },
    extern fn wlr_virtual_keyboard_manager_v1_create(server: *wl.Server) ?*VirtualKeyboardManagerV1;
    pub const create = wlr_virtual_keyboard_manager_v1_create;
};

pub const VirtualKeyboardV1 = extern struct {
    input_device: wlr.InputDevice,
    resource: *wl.Resource,
    seat: *wlr.Seat,
    has_keymap: bool,

    /// VirtualKeyboardManagerV1.virtual_keyboards
    link: wl.List,

    events: extern struct {
        destroy: wl.Signal(*VirtualKeyboardV1),
    },
};
