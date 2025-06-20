const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const TextInputManagerV3 = extern struct {
    global: *wl.Global,
    text_inputs: wl.list.Head(TextInputV3, .link),

    events: extern struct {
        text_input: wl.Signal(*wlr.TextInputV3),
        destroy: wl.Signal(*wlr.TextInputManagerV3),
    },

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_text_input_manager_v3_create(server: *wl.Server) ?*wlr.TextInputManagerV3;
    pub fn create(server: *wl.Server) !*wlr.TextInputManagerV3 {
        return wlr_text_input_manager_v3_create(server) orelse error.OutOfMemory;
    }
};

pub const TextInputV3 = extern struct {
    pub const Features = packed struct(u32) {
        surrounding_text: bool = false,
        content_type: bool = false,
        cursor_rectangle: bool = false,
        _: u29 = 0,
    };

    pub const State = extern struct {
        surrounding: extern struct {
            text: ?[*:0]u8,
            cursor: u32,
            anchor: u32,
        },

        text_change_cause: u32,

        content_type: extern struct {
            hint: u32,
            purpose: u32,
        },

        cursor_rectangle: wlr.Box,

        features: Features,
    };

    seat: *wlr.Seat,
    resource: *wl.Resource,
    focused_surface: ?*wlr.Surface,
    pending: wlr.TextInputV3.State,
    current: wlr.TextInputV3.State,
    current_serial: u32,
    pending_enabled: bool,
    current_enabled: bool,
    active_features: Features,

    link: wl.list.Link,

    events: extern struct {
        enable: wl.Signal(*wlr.TextInputV3),
        commit: wl.Signal(*wlr.TextInputV3),
        disable: wl.Signal(*wlr.TextInputV3),
        destroy: wl.Signal(*wlr.TextInputV3),
    },

    private: extern struct {
        surface_destroy: wl.Listener(void),
        seat_destroy: wl.Listener(void),
    },

    extern fn wlr_text_input_v3_send_enter(text_input: *wlr.TextInputV3, surface: *wlr.Surface) void;
    pub const sendEnter = wlr_text_input_v3_send_enter;

    extern fn wlr_text_input_v3_send_leave(text_input: *wlr.TextInputV3) void;
    pub const sendLeave = wlr_text_input_v3_send_leave;

    extern fn wlr_text_input_v3_send_preedit_string(text_input: *wlr.TextInputV3, text: [*:0]const u8, cursor_begin: i32, cursor_end: i32) void;
    pub const sendPreeditString = wlr_text_input_v3_send_preedit_string;

    extern fn wlr_text_input_v3_send_commit_string(text_input: *wlr.TextInputV3, text: [*:0]const u8) void;
    pub const sendCommitString = wlr_text_input_v3_send_commit_string;

    extern fn wlr_text_input_v3_send_delete_surrounding_text(text_input: *wlr.TextInputV3, before_length: u32, after_length: u32) void;
    pub const sendDeleteSurroundingText = wlr_text_input_v3_send_delete_surrounding_text;

    extern fn wlr_text_input_v3_send_done(text_input: *wlr.TextInputV3) void;
    pub const sendDone = wlr_text_input_v3_send_done;
};
