const wlr = @import("../wlroots.zig");

const posix = @import("std").posix;

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const SerialRange = extern struct {
    min_incl: u32,
    max_incl: u32,
};

pub const SerialRingset = extern struct {
    data: [128]SerialRange,
    end: c_int,
    count: c_int,
};

pub const TouchPoint = extern struct {
    touch_id: i32,
    surface: ?*wlr.Surface,
    client: *wlr.Seat.Client,

    focus_surface: ?*wlr.Surface,
    focus_client: ?*wlr.Seat.Client,
    sx: f64,
    sy: f64,

    events: extern struct {
        destroy: wl.Signal(*TouchPoint),
    },

    /// Seat.TouchState.touch_points
    link: wl.list.Link,

    private: extern struct {
        surface_destroy: wl.Listener(void),
        focus_surface_destroy: wl.Listener(void),
        client_destroy: wl.Listener(void),
    },
};

pub const Seat = extern struct {
    pub const Client = extern struct {
        client: *wl.Client,
        seat: *Seat,
        /// Seat.clients
        link: wl.list.Link,

        resources: wl.list.Head(wl.Seat, null),
        pointers: wl.list.Head(wl.Pointer, null),
        keyboards: wl.list.Head(wl.Keyboard, null),
        touches: wl.list.Head(wl.Touch, null),
        data_devices: wl.list.Head(wl.DataDevice, null),

        events: extern struct {
            destroy: wl.Signal(*Seat.Client),
        },

        serials: SerialRingset,
        needs_touch_frame: bool,

        value120: extern struct {
            acc_discrete: [2]i32,
            last_discrete: [2]i32,
            acc_axis: [2]f64,
        },

        extern fn wlr_seat_client_next_serial(client: *Client) u32;
        pub const nextSerial = wlr_seat_client_next_serial;

        extern fn wlr_seat_client_validate_event_serial(client: *Client, serial: u32) bool;
        pub const validateEventSerial = wlr_seat_client_validate_event_serial;

        extern fn wlr_seat_client_from_resource(seat: *wl.Seat) ?*Client;
        pub const fromWlSeat = wlr_seat_client_from_resource;

        extern fn wlr_seat_client_from_pointer_resource(pointer: *wl.Pointer) ?*Client;
        pub const fromWlPointer = wlr_seat_client_from_pointer_resource;
    };

    pub const PointerGrab = extern struct {
        pub const Interface = extern struct {
            enter: *const fn (
                grab: *PointerGrab,
                surface: *wlr.Surface,
                sx: f64,
                sy: f64,
            ) callconv(.C) void,
            clear_focus: *const fn (grab: *PointerGrab) callconv(.C) void,
            motion: *const fn (grab: *PointerGrab, time_msec: u32, sx: f64, sy: f64) callconv(.C) void,
            button: *const fn (
                grab: *PointerGrab,
                time_msec: u32,
                button: u32,
                state: wl.Pointer.ButtonState,
            ) callconv(.C) u32,
            axis: *const fn (
                grab: *PointerGrab,
                time_msec: u32,
                orientation: wl.Pointer.Axis,
                value: f64,
                value_discrete: i32,
                source: wl.Pointer.AxisSource,
                source: wl.Pointer.AxisRelativeDirection,
            ) callconv(.C) void,
            frame: ?*const fn (grab: *PointerGrab) callconv(.C) void,
            cancel: ?*const fn (grab: *PointerGrab) callconv(.C) void,
        };

        interface: *const Interface,
        seat: *Seat,
        data: ?*anyopaque,
    };

    pub const KeyboardGrab = extern struct {
        pub const Interface = extern struct {
            enter: *const fn (
                grab: *KeyboardGrab,
                surface: *wlr.Surface,
                keycodes: ?[*]const u32,
                num_keycodes: usize,
                modifiers: ?*const wlr.Keyboard.Modifiers,
            ) callconv(.C) void,
            clear_focus: *const fn (grab: *KeyboardGrab) callconv(.C) void,
            key: *const fn (grab: *KeyboardGrab, time_msec: u32, key: u32, state: u32) callconv(.C) void,
            modifiers: *const fn (grab: *KeyboardGrab, modifiers: ?*const wlr.Keyboard.Modifiers) callconv(.C) void,
            cancel: ?*const fn (grab: *KeyboardGrab) callconv(.C) void,
        };

        interface: *const Interface,
        seat: *Seat,
        data: ?*anyopaque,
    };

    pub const TouchGrab = extern struct {
        pub const Interface = extern struct {
            down: *const fn (grab: *TouchGrab, time_msec: u32, point: *TouchPoint) callconv(.C) u32,
            up: *const fn (grab: *TouchGrab, time_msec: u32, point: *TouchPoint) callconv(.C) u32,
            motion: *const fn (grab: *TouchGrab, time_msec: u32, point: *TouchPoint) callconv(.C) void,
            enter: *const fn (grab: *TouchGrab, time_msec: u32, point: *TouchPoint) callconv(.C) void,
            frame: ?*const fn (grab: *TouchGrab) callconv(.C) void,
            cancel: ?*const fn (grab: *TouchGrab) callconv(.C) void,
            wl_cancel: ?*const fn (grab: *TouchGrab, seat_client: *wlr.Seat.Client) callconv(.C) void,
        };

        interface: *const Interface,
        seat: *Seat,
        data: ?*anyopaque,
    };

    pub const PointerState = extern struct {
        pub const Button = extern struct {
            button: u32,
            n_pressed: usize,
        };

        seat: *Seat,
        focused_client: ?*Seat.Client,
        focused_surface: ?*wlr.Surface,
        sx: f64,
        sy: f64,

        grab: *PointerGrab,
        default_grab: *PointerGrab,

        sent_axis_source: bool,
        cached_axis_source: wl.Pointer.AxisSource,

        buttons: [16]Button,
        button_count: usize,
        grab_button: u32,
        grab_serial: u32,
        grab_time: u32,

        events: extern struct {
            focus_change: wl.Signal(*event.PointerFocusChange),
        },

        private: extern struct {
            surface_destroy: wl.Listener(void),
        },
    };

    pub const KeyboardState = extern struct {
        seat: *Seat,
        keyboard: ?*wlr.Keyboard,

        focused_client: ?*Seat.Client,
        focused_surface: ?*wlr.Surface,

        grab: *KeyboardGrab,
        default_grab: *KeyboardGrab,

        events: extern struct {
            focus_change: wl.Signal(*event.KeyboardFocusChange),
        },

        private: extern struct {
            keyboard_destroy: wl.Listener(void),
            keyboard_keymap: wl.Listener(void),
            keyboard_repeat_info: wl.Listener(void),

            surface_destroy: wl.Listener(void),
        },
    };

    pub const TouchState = extern struct {
        seat: *Seat,
        touch_points: wl.list.Head(TouchPoint, .link),

        grab_serial: u32,
        grab_id: u32,

        grab: *TouchGrab,
        default_grab: *TouchGrab,
    };

    pub const event = struct {
        pub const PointerFocusChange = extern struct {
            seat: *Seat,
            old_surface: ?*wlr.Surface,
            new_surface: ?*wlr.Surface,
            sx: f64,
            sy: f64,
        };

        pub const KeyboardFocusChange = extern struct {
            seat: *Seat,
            old_surface: ?*wlr.Surface,
            new_surface: ?*wlr.Surface,
        };

        pub const RequestSetCursor = extern struct {
            seat_client: *Seat.Client,
            surface: ?*wlr.Surface,
            serial: u32,
            hotspot_x: i32,
            hotspot_y: i32,
        };

        pub const RequestSetSelection = extern struct {
            source: ?*wlr.DataSource,
            serial: u32,
        };

        pub const RequestSetPrimarySelection = extern struct {
            source: ?*wlr.PrimarySelectionSource,
            serial: u32,
        };

        pub const RequestStartDrag = extern struct {
            drag: *wlr.Drag,
            origin: *wlr.Surface,
            serial: u32,
        };
    };

    global: *wl.Global,
    server: *wl.Server,
    clients: wl.list.Head(Seat.Client, .link),

    name: [*:0]u8,

    capabilities: u32,
    accumulated_capabilities: u32,

    selection_source: ?*wlr.DataSource,
    selection_serial: u32,
    /// wlr.DataOffer.link
    selection_offers: wl.list.Head(wlr.DataOffer, .link),

    primary_selection_source: ?*wlr.PrimarySelectionSource,
    primary_selection_serial: u32,

    drag: ?*wlr.Drag,
    drag_source: ?*wlr.DataSource,
    drag_serial: u32,
    /// wlr.DataOffer.link
    drag_offers: wl.list.Head(wlr.DataOffer, .link),

    pointer_state: PointerState,
    keyboard_state: KeyboardState,
    touch_state: TouchState,

    events: extern struct {
        pointer_grab_begin: wl.Signal(*PointerGrab),
        pointer_grab_end: wl.Signal(*PointerGrab),

        keyboard_grab_begin: wl.Signal(*KeyboardGrab),
        keyboard_grab_end: wl.Signal(*KeyboardGrab),

        touch_grab_begin: wl.Signal(*TouchGrab),
        touch_grab_end: wl.Signal(*TouchGrab),

        request_set_cursor: wl.Signal(*event.RequestSetCursor),

        request_set_selection: wl.Signal(*event.RequestSetSelection),
        set_selection: wl.Signal(*wlr.Seat),

        request_set_primary_selection: wl.Signal(*event.RequestSetPrimarySelection),
        set_primary_selection: wl.Signal(*wlr.Seat),

        request_start_drag: wl.Signal(*event.RequestStartDrag),
        start_drag: wl.Signal(*wlr.Drag),

        destroy: wl.Signal(*wlr.Seat),
    },

    data: ?*anyopaque,

    private: extern struct {
        display_destroy: wl.Listener(void),
        selection_source_destroy: wl.Listener(void),
        primary_selection_source_destroy: wl.Listener(void),
        drag_source_destroy: wl.Listener(void),
    },

    extern fn wlr_seat_create(server: *wl.Server, name: [*:0]const u8) ?*Seat;
    pub fn create(server: *wl.Server, name: [*:0]const u8) !*Seat {
        return wlr_seat_create(server, name) orelse error.OutOfMemory;
    }

    extern fn wlr_seat_destroy(seat: *Seat) void;
    pub const destroy = wlr_seat_destroy;

    extern fn wlr_seat_client_for_wl_client(seat: *Seat, wl_client: *wl.Client) ?*Seat.Client;
    pub const clientForWlClient = wlr_seat_client_for_wl_client;

    extern fn wlr_seat_set_capabilities(seat: *Seat, capabilities: u32) void;
    pub inline fn setCapabilities(seat: *Seat, capabilities: wl.Seat.Capability) void {
        wlr_seat_set_capabilities(seat, @as(u32, @bitCast(capabilities)));
    }

    extern fn wlr_seat_set_name(seat: *Seat, name: [*:0]const u8) void;
    pub const setName = wlr_seat_set_name;

    extern fn wlr_seat_pointer_surface_has_focus(seat: *Seat, surface: *wlr.Surface) bool;
    pub const pointerSurfaceHasFocus = wlr_seat_pointer_surface_has_focus;

    extern fn wlr_seat_pointer_enter(seat: *Seat, surface: ?*wlr.Surface, sx: f64, sy: f64) void;
    pub const pointerEnter = wlr_seat_pointer_enter;

    extern fn wlr_seat_pointer_clear_focus(seat: *Seat) void;
    pub const pointerClearFocus = wlr_seat_pointer_clear_focus;

    extern fn wlr_seat_pointer_send_motion(seat: *Seat, time_msec: u32, sx: f64, sy: f64) void;
    pub const pointerSendMotion = wlr_seat_pointer_send_motion;

    extern fn wlr_seat_pointer_send_button(seat: *Seat, time_msec: u32, button: u32, state: wl.Pointer.ButtonState) u32;
    pub const pointerSendButton = wlr_seat_pointer_send_button;

    extern fn wlr_seat_pointer_send_axis(
        seat: *Seat,
        time_msec: u32,
        orientation: wl.Pointer.Axis,
        value: f64,
        value_discrete: i32,
        source: wl.Pointer.AxisSource,
        relative_direction: wl.Pointer.AxisRelativeDirection,
    ) void;
    pub const pointerSendAxis = wlr_seat_pointer_send_axis;

    extern fn wlr_seat_pointer_send_frame(seat: *Seat) void;
    pub const pointerSendFrame = wlr_seat_pointer_send_frame;

    extern fn wlr_seat_pointer_notify_enter(seat: *Seat, surface: *wlr.Surface, sx: f64, sy: f64) void;
    pub const pointerNotifyEnter = wlr_seat_pointer_notify_enter;

    extern fn wlr_seat_pointer_notify_clear_focus(seat: *Seat) void;
    pub const pointerNotifyClearFocus = wlr_seat_pointer_notify_clear_focus;

    extern fn wlr_seat_pointer_warp(seat: *Seat, sx: f64, sy: f64) void;
    pub const pointerWarp = wlr_seat_pointer_warp;

    extern fn wlr_seat_pointer_notify_motion(seat: *Seat, time_msec: u32, sx: f64, sy: f64) void;
    pub const pointerNotifyMotion = wlr_seat_pointer_notify_motion;

    extern fn wlr_seat_pointer_notify_button(seat: *Seat, time_msec: u32, button: u32, state: wl.Pointer.ButtonState) u32;
    pub const pointerNotifyButton = wlr_seat_pointer_notify_button;

    extern fn wlr_seat_pointer_notify_axis(
        seat: *Seat,
        time_msec: u32,
        orientation: wl.Pointer.Axis,
        value: f64,
        value_discrete: i32,
        source: wl.Pointer.AxisSource,
        relative_direction: wl.Pointer.AxisRelativeDirection,
    ) void;
    pub const pointerNotifyAxis = wlr_seat_pointer_notify_axis;

    extern fn wlr_seat_pointer_notify_frame(seat: *Seat) void;
    pub const pointerNotifyFrame = wlr_seat_pointer_notify_frame;

    extern fn wlr_seat_pointer_start_grab(seat: *Seat, grab: ?*PointerGrab) void;
    pub const pointerStartGrab = wlr_seat_pointer_start_grab;

    extern fn wlr_seat_pointer_end_grab(seat: *Seat) void;
    pub const pointerEndGrab = wlr_seat_pointer_end_grab;

    extern fn wlr_seat_pointer_has_grab(seat: *Seat) bool;
    pub const pointerHasGrab = wlr_seat_pointer_has_grab;

    extern fn wlr_seat_set_keyboard(seat: *Seat, keyboard: ?*wlr.Keyboard) void;
    pub const setKeyboard = wlr_seat_set_keyboard;

    extern fn wlr_seat_get_keyboard(seat: *Seat) ?*wlr.Keyboard;
    pub const getKeyboard = wlr_seat_get_keyboard;

    extern fn wlr_seat_keyboard_send_key(seat: *Seat, time_msec: u32, key: u32, state: u32) void;
    pub const keyboardSendKey = wlr_seat_keyboard_send_key;

    extern fn wlr_seat_keyboard_send_modifiers(seat: *Seat, modifiers: ?*const wlr.Keyboard.Modifiers) void;
    pub const keyboardSendModifiers = wlr_seat_keyboard_send_modifiers;

    extern fn wlr_seat_keyboard_enter(seat: *Seat, surface: ?*wlr.Surface, keycodes: ?[*]const u32, num_keycodes: usize, modifiers: ?*const wlr.Keyboard.Modifiers) void;
    pub fn keyboardEnter(seat: *Seat, surface: ?*wlr.Surface, keycodes: []const u32, modifiers: ?*const wlr.Keyboard.Modifiers) void {
        wlr_seat_keyboard_enter(seat, surface, keycodes.ptr, keycodes.len, modifiers);
    }

    extern fn wlr_seat_keyboard_clear_focus(seat: *Seat) void;
    pub const keyboardClearFocus = wlr_seat_keyboard_clear_focus;

    extern fn wlr_seat_keyboard_notify_key(seat: *Seat, time_msec: u32, key: u32, state: u32) void;
    pub fn keyboardNotifyKey(seat: *Seat, time_msec: u32, key: u32, state: wl.Keyboard.KeyState) void {
        wlr_seat_keyboard_notify_key(seat, time_msec, key, @as(u32, @intCast(@intFromEnum(state))));
    }

    extern fn wlr_seat_keyboard_notify_modifiers(seat: *Seat, modifiers: ?*const wlr.Keyboard.Modifiers) void;
    pub const keyboardNotifyModifiers = wlr_seat_keyboard_notify_modifiers;

    extern fn wlr_seat_keyboard_notify_enter(seat: *Seat, surface: *wlr.Surface, keycodes: ?[*]const u32, num_keycodes: usize, modifiers: ?*const wlr.Keyboard.Modifiers) void;
    pub fn keyboardNotifyEnter(seat: *Seat, surface: *wlr.Surface, keycodes: []const u32, modifiers: ?*const wlr.Keyboard.Modifiers) void {
        wlr_seat_keyboard_notify_enter(seat, surface, keycodes.ptr, keycodes.len, modifiers);
    }

    extern fn wlr_seat_keyboard_notify_clear_focus(seat: *Seat) void;
    pub const keyboardNotifyClearFocus = wlr_seat_keyboard_notify_clear_focus;

    extern fn wlr_seat_keyboard_start_grab(seat: *Seat, grab: *KeyboardGrab) void;
    pub const keyboardStartGrab = wlr_seat_keyboard_start_grab;

    extern fn wlr_seat_keyboard_end_grab(seat: *Seat) void;
    pub const keyboardEndGrab = wlr_seat_keyboard_end_grab;

    extern fn wlr_seat_keyboard_has_grab(seat: *Seat) bool;
    pub const keyboardHasGrab = wlr_seat_keyboard_has_grab;

    extern fn wlr_seat_touch_get_point(seat: *Seat, touch_id: i32) ?*TouchPoint;
    pub const touchGetPoint = wlr_seat_touch_get_point;

    extern fn wlr_seat_touch_point_focus(seat: *Seat, surface: *wlr.Surface, time_msec: u32, touch_id: i32, sx: f64, sy: f64) void;
    pub const touchPointFocus = wlr_seat_touch_point_focus;

    extern fn wlr_seat_touch_point_clear_focus(seat: *Seat, time_msec: u32, touch_id: i32) void;
    pub const touchPointClearFocus = wlr_seat_touch_point_clear_focus;

    extern fn wlr_seat_touch_send_down(seat: *Seat, surface: *wlr.Surface, time_msec: u32, touch_id: i32, sx: f64, sy: f64) u32;
    pub const touchSendDown = wlr_seat_touch_send_down;

    extern fn wlr_seat_touch_send_up(seat: *Seat, time_msec: u32, touch_id: i32) u32;
    pub const touchSendUp = wlr_seat_touch_send_up;

    extern fn wlr_seat_touch_send_motion(seat: *Seat, time_msec: u32, touch_id: i32, sx: f64, sy: f64) void;
    pub const touchSendMotion = wlr_seat_touch_send_motion;

    extern fn wlr_seat_touch_send_frame(seat: *Seat) void;
    pub const touchSendFrame = wlr_seat_touch_send_frame;

    extern fn wlr_seat_touch_send_cancel(seat: *Seat, seat_client: *wlr.Seat.Client) void;
    pub const touchSendCancel = wlr_seat_touch_send_cancel;

    extern fn wlr_seat_touch_notify_down(seat: *Seat, surface: *wlr.Surface, time_msec: u32, touch_id: i32, sx: f64, sy: f64) u32;
    pub const touchNotifyDown = wlr_seat_touch_notify_down;

    extern fn wlr_seat_touch_notify_up(seat: *Seat, time_msec: u32, touch_id: i32) u32;
    pub const touchNotifyUp = wlr_seat_touch_notify_up;

    extern fn wlr_seat_touch_notify_motion(seat: *Seat, time_msec: u32, touch_id: i32, sx: f64, sy: f64) void;
    pub const touchNotifyMotion = wlr_seat_touch_notify_motion;

    extern fn wlr_seat_touch_notify_frame(seat: *Seat) void;
    pub const touchNotifyFrame = wlr_seat_touch_notify_frame;

    extern fn wlr_seat_touch_notify_cancel(seat: *Seat, seat_client: *wlr.Seat.Client) void;
    pub const touchNotifyCancel = wlr_seat_touch_notify_cancel;

    extern fn wlr_seat_touch_num_points(seat: *Seat) c_int;
    pub const touchNumPoints = wlr_seat_touch_num_points;

    extern fn wlr_seat_touch_start_grab(seat: *Seat, grab: *TouchGrab) void;
    pub const touchStartGrab = wlr_seat_touch_start_grab;

    extern fn wlr_seat_touch_end_grab(seat: *Seat) void;
    pub const touchEndGrab = wlr_seat_touch_end_grab;

    extern fn wlr_seat_touch_has_grab(seat: *Seat) bool;
    pub const touchHasGrab = wlr_seat_touch_has_grab;

    extern fn wlr_seat_validate_pointer_grab_serial(seat: *Seat, origin: ?*wlr.Surface, serial: u32) bool;
    pub const validatePointerGrabSerial = wlr_seat_validate_pointer_grab_serial;

    extern fn wlr_seat_validate_touch_grab_serial(seat: *Seat, origin: ?*wlr.Surface, serial: u32, point_ptr: ?**wlr.TouchPoint) bool;
    pub const validateTouchGrabSerial = wlr_seat_validate_touch_grab_serial;

    extern fn wlr_seat_request_set_selection(seat: *Seat, client: ?*Seat.Client, source: ?*wlr.DataSource, serial: u32) void;
    pub const requestSetSelection = wlr_seat_request_set_selection;

    extern fn wlr_seat_set_selection(seat: *Seat, source: ?*wlr.DataSource, serial: u32) void;
    pub const setSelection = wlr_seat_set_selection;

    extern fn wlr_seat_request_set_primary_selection(seat: *Seat, client: ?*Seat.Client, source: ?*wlr.PrimarySelectionSource, serial: u32) void;
    pub const requestSetPrimarySelection = wlr_seat_request_set_primary_selection;

    extern fn wlr_seat_set_primary_selection(seat: *Seat, source: ?*wlr.PrimarySelectionSource, serial: u32) void;
    pub const setPrimarySelection = wlr_seat_set_primary_selection;

    extern fn wlr_seat_request_start_drag(seat: *Seat, drag: *wlr.Drag, origin: *wlr.Surface, serial: u32) void;
    pub const requestStartDrag = wlr_seat_request_start_drag;

    extern fn wlr_seat_start_drag(seat: *Seat, drag: *wlr.Drag, serial: u32) void;
    pub const startDrag = wlr_seat_start_drag;

    extern fn wlr_seat_start_pointer_drag(seat: *Seat, drag: *wlr.Drag, serial: u32) void;
    pub const startPointerDrag = wlr_seat_start_pointer_drag;

    extern fn wlr_seat_start_touch_drag(seat: *Seat, drag: *wlr.Drag, serial: u32, point: *TouchPoint) void;
    pub const startTouchDrag = wlr_seat_start_touch_drag;
};
