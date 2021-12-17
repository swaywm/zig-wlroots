const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const InputMethodManagerV2 = extern struct {
    global: *wl.Global,
    input_methods: wl.list.Head(InputMethodV2, "link"),

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        input_method: wl.Signal(*wlr.InputMethodV2),
        destroy: wl.Signal(*wlr.InputMethodManagerV2),
    },

    extern fn wlr_input_method_manager_v2_create(server: *wl.Server) ?*wlr.InputMethodManagerV2;
    pub fn create(server: *wl.Server) !*wlr.InputMethodManagerV2 {
        return wlr_input_method_manager_v2_create(server) orelse error.OutOfMemory;
    }
};

pub const InputMethodV2 = extern struct {
    pub const PreeditString = extern struct {
        text: [*:0]u8,
        cursor_begin: i32,
        cursor_end: i32,
    };

    pub const DeleteSurroundingText = extern struct {
        before_length: u32,
        after_length: u32,
    };

    pub const State = extern struct {
        preedit: wlr.InputMethodV2.PreeditString,
        commit_text: [*:0]u8,
        delete: wlr.InputMethodV2.DeleteSurroundingText,
    };

    pub const KeyboardGrab = extern struct {
        resource: *wl.Resource,
        input_method: *wlr.InputMethodV2,
        keyboard: ?*wlr.Keyboard,

        keyboard_keymap: wl.Listener(*wlr.Keyboard),
        keyboard_repeat_info: wl.Listener(*wlr.Keyboard),
        keyboard_destroy: wl.Listener(*wlr.Keyboard),

        events: extern struct {
            destroy: wl.Signal(*wlr.InputMethodV2.KeyboardGrab),
        },

        extern fn wlr_input_method_keyboard_grab_v2_send_key(keyboard_grab: *wlr.InputMethodV2.KeyboardGrab, time: u32, key: u32, state: u32) void;
        pub fn sendKey(keyboard_grab: *wlr.InputMethodV2.KeyboardGrab, time: u32, key: u32, state: wl.Keyboard.KeyState) void {
            wlr_input_method_keyboard_grab_v2_send_key(keyboard_grab, time, key, @intCast(u32, @enumToInt(state)));
        }

        extern fn wlr_input_method_keyboard_grab_v2_send_modifiers(keyboard_grab: *wlr.InputMethodV2.KeyboardGrab, modifiers: *wlr.Keyboard.Modifiers) void;
        pub const sendModifiers = wlr_input_method_keyboard_grab_v2_send_modifiers;

        extern fn wlr_input_method_keyboard_grab_v2_set_keyboard(keyboard_grab: *wlr.InputMethodV2.KeyboardGrab, keyboard: ?*wlr.Keyboard) void;
        pub const setKeyboard = wlr_input_method_keyboard_grab_v2_set_keyboard;

        extern fn wlr_input_method_keyboard_grab_v2_destroy(keyboard_grab: *wlr.InputMethodV2.KeyboardGrab) void;
        pub const destroy = wlr_input_method_keyboard_grab_v2_destroy;
    };

    resource: *wl.Resource,
    seat: *wlr.Seat,
    seat_client: *wlr.Seat.Client,

    pending: wlr.InputMethodV2.State,
    current: wlr.InputMethodV2.State,
    active: bool,
    client_active: bool,
    current_serial: u32,

    popup_surfaces: wl.list.Head(InputPopupSurfaceV2, "link"),
    keyboard_grab: ?*KeyboardGrab,

    link: wl.list.Link,

    seat_client_destroy: wl.Listener(*wlr.Seat.Client),

    events: extern struct {
        commit: wl.Signal(*wlr.InputMethodV2),
        new_popup_surface: wl.Signal(*wlr.InputPopupSurfaceV2),
        grab_keyboard: wl.Signal(*wlr.InputMethodV2.KeyboardGrab),
        destroy: wl.Signal(*wlr.InputMethodV2),
    },

    extern fn wlr_input_method_v2_send_activate(input_method: *wlr.InputMethodV2) void;
    pub const sendActivate = wlr_input_method_v2_send_activate;

    extern fn wlr_input_method_v2_send_deactivate(input_method: *wlr.InputMethodV2) void;
    pub const sendDeactivate = wlr_input_method_v2_send_deactivate;

    extern fn wlr_input_method_v2_send_surrounding_text(input_method: *wlr.InputMethodV2, text: [*:0]const u8, cursor: u32, anchor: u32) void;
    pub const sendSurroundingText = wlr_input_method_v2_send_surrounding_text;

    extern fn wlr_input_method_v2_send_content_type(input_method: *wlr.InputMethodV2, hint: u32, purpose: u32) void;
    pub const sendContentType = wlr_input_method_v2_send_content_type;

    extern fn wlr_input_method_v2_send_text_change_cause(input_method: *wlr.InputMethodV2, cause: u32) void;
    pub const sendTextChangeCause = wlr_input_method_v2_send_text_change_cause;

    extern fn wlr_input_method_v2_send_done(input_method: *wlr.InputMethodV2) void;
    pub const sendDone = wlr_input_method_v2_send_done;

    extern fn wlr_input_method_v2_send_unavailable(input_method: *wlr.InputMethodV2) void;
    pub const sendUnavailable = wlr_input_method_v2_send_unavailable;
};

pub const InputPopupSurfaceV2 = extern struct {
    resource: *wl.Resource,
    input_method: *InputMethodV2,
    link: wl.list.Link,
    mapped: bool,

    surface: *wlr.Surface,

    surface_destroy: wl.Listener(*wlr.Surface),

    events: extern struct {
        map: wl.Signal(void),
        unmap: wl.Signal(void),
        destroy: wl.Signal(void),
    },

    data: usize,
};
