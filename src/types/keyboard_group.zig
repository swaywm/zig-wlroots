const wlr = @import("../wlroots.zig");

const wl = @import("wayland").server.wl;

pub const KeyboardGroup = extern struct {
    keyboard: wlr.Keyboard,

    // these are technically list heads, but their usage is internal to wlroots
    devices: wl.list.Link,
    keys: wl.list.Link,

    events: extern struct {
        /// wl.Array of u32 keycodes
        enter: wl.Signal(*wl.Array),
        /// wl.Array of u32 keycodes
        leave: wl.Signal(*wl.Array),
    },

    data: usize,

    extern fn wlr_keyboard_group_create() ?*KeyboardGroup;
    pub fn create() !*KeyboardGroup {
        return wlr_keyboard_group_create() orelse error.OutOfMemory;
    }

    extern fn wlr_keyboard_group_from_wlr_keyboard(keyboard: *wlr.Keyboard) ?*KeyboardGroup;
    pub const fromKeyboard = wlr_keyboard_group_from_wlr_keyboard;

    extern fn wlr_keyboard_group_add_keyboard(group: *KeyboardGroup, keyboard: *wlr.Keyboard) bool;
    pub const addKeyboard = wlr_keyboard_group_add_keyboard;

    extern fn wlr_keyboard_group_remove_keyboard(group: *KeyboardGroup, keyboard: *wlr.Keyboard) void;
    pub const removeKeyboard = wlr_keyboard_group_remove_keyboard;

    extern fn wlr_keyboard_group_destroy(group: *KeyboardGroup) void;
    pub const destroy = wlr_keyboard_group_destroy;
};
