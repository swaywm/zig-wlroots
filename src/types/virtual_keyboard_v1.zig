const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const VirtualKeyboardManagerV1 = extern struct {
    global: *wl.Global,
    virtual_keyboards: wl.list.Head(VirtualKeyboardV1, "link"),

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        new_virtual_keyboard: wl.Signal(*VirtualKeyboardV1),
        destroy: wl.Signal(*VirtualKeyboardManagerV1),
    },

    extern fn wlr_virtual_keyboard_manager_v1_create(server: *wl.Server) ?*VirtualKeyboardManagerV1;
    pub fn create(server: *wl.Server) !*VirtualKeyboardManagerV1 {
        return wlr_virtual_keyboard_manager_v1_create(server) orelse error.OutOfMemory;
    }
};

pub const VirtualKeyboardV1 = extern struct {
    keyboard: wlr.Keyboard,
    resource: *wl.Resource,
    seat: *wlr.Seat,
    has_keymap: bool,

    /// VirtualKeyboardManagerV1.virtual_keyboards
    link: wl.list.Link,
};
