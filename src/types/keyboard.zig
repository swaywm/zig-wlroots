const wlr = @import("../wlroots.zig");

const std = @import("std");

const wayland = @import("wayland");
const wl = wayland.server.wl;

const xkb = @import("xkbcommon");

pub const Keyboard = extern struct {
    pub const led = struct {
        pub const num_lock = 1 << 0;
        pub const caps_lock = 1 << 1;
        pub const scroll_lock = 1 << 2;
    };

    pub const ModifierMask = packed struct(u32) {
        shift: bool = false,
        caps: bool = false,
        ctrl: bool = false,
        alt: bool = false,
        mod2: bool = false,
        mod3: bool = false,
        logo: bool = false,
        mod5: bool = false,
        _: u24 = 0,
    };

    pub const Modifiers = extern struct {
        depressed: xkb.ModMask,
        latched: xkb.ModMask,
        locked: xkb.ModMask,
        group: xkb.LayoutIndex,
    };

    pub const event = struct {
        pub const Key = extern struct {
            time_msec: u32,
            keycode: u32,
            update_state: bool,
            state: wl.Keyboard.KeyState,
        };
    };

    const Impl = opaque {};

    base: wlr.InputDevice,

    impl: *const Impl,
    group: ?*wlr.KeyboardGroup,

    keymap_string: [*:0]u8,
    keymap_size: usize,
    keymap_fd: c_int,
    keymap: ?*xkb.Keymap,
    xkb_state: ?*xkb.State,
    led_indexes: [3]xkb.LED_Index,
    mod_indexes: [8]xkb.ModIndex,

    leds: u32,
    keycodes: [32]u32,
    num_keycodes: usize,
    modifiers: Modifiers,

    repeat_info: extern struct {
        rate: i32,
        delay: i32,
    },

    events: extern struct {
        key: wl.Signal(*event.Key),
        modifiers: wl.Signal(*Keyboard),
        keymap: wl.Signal(*Keyboard),
        repeat_info: wl.Signal(*Keyboard),
    },

    data: usize,

    extern fn wlr_keyboard_set_keymap(kb: *Keyboard, keymap: ?*xkb.Keymap) bool;
    pub const setKeymap = wlr_keyboard_set_keymap;

    extern fn wlr_keyboard_keymaps_match(km1: ?*xkb.Keymap, km2: ?*xkb.Keymap) bool;
    pub const keymapsMatch = wlr_keyboard_keymaps_match;

    extern fn wlr_keyboard_set_repeat_info(kb: *Keyboard, rate: i32, delay: i32) void;
    pub const setRepeatInfo = wlr_keyboard_set_repeat_info;

    extern fn wlr_keyboard_led_update(keyboard: *Keyboard, leds: u32) void;
    pub const ledUpdate = wlr_keyboard_led_update;

    extern fn wlr_keyboard_get_modifiers(keyboard: *Keyboard) u32;
    pub fn getModifiers(keyboard: *Keyboard) ModifierMask {
        return @as(ModifierMask, @bitCast(wlr_keyboard_get_modifiers(keyboard)));
    }

    extern fn wlr_keyboard_notify_modifiers(
        keyboard: *Keyboard,
        mods_depressed: u32,
        mods_latched: u32,
        mods_locked: u32,
        group: u32,
    ) void;
    pub fn notifyModifiers(keyboard: *Keyboard, modifiers: Modifiers) void {
        wlr_keyboard_notify_modifiers(
            keyboard,
            modifiers.depressed,
            modifiers.latched,
            modifiers.locked,
            modifiers.group,
        );
    }
};
