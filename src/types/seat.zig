const wlr = @import("../wlroots.zig");

const os = @import("std").os;

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

    surface_destroy: wl.Listener,
    focus_surface_destroy: wl.Listener,
    client_destroy: wl.Listener,

    events: extern struct {
        destroy: wl.Signal,
    },

    /// Seat.TouchState.touch_points
    link: wl.List,
};

pub const Seat = extern struct {
    pub const Client = extern struct {
        client: *wl.Client,
        seat: *Seat,
        /// Seat.clients
        link: wl.List,

        resources: wl.List,
        pointers: wl.List,
        keyboards: wl.List,
        touches: wl.List,
        data_devices: wl.List,

        events: extern struct {
            destroy: wl.Signal,
        },

        serials: SerialRingset,
    };

    pub const PointerGrab = extern struct {
        pub const Interface = extern struct {
            enter: fn (
                grab: *PointerGrab,
                surface: *wlr.Surface,
                sx: f64,
                sy: f64,
            ) callconv(.C) void,
            clear_focus: fn (grab: *PointerGrab) callconv(.C) void,
            motion: fn (grab: *PointerGrab, time_msec: u32, sx: f64, sy: f64) callconv(.C) void,
            button: fn (
                grab: *PointerGrab,
                time_msec: u32,
                button: u32,
                state: wlr.ButtonState,
            ) callconv(.C) u32,
            axis: fn (
                grab: *PointerGrab,
                time_msec: u32,
                orientation: wlr.AxisOrientation,
                value: f64,
                value_discrete: i32,
                source: wlr.Pointer.event.Axis.Source,
            ) callconv(.C) void,
            frame: ?fn (grab: *PointerGrab) callconv(.C) void,
            cancel: ?fn (grab: *PointerGrab) callconv(.C) void,
        };

        interface: *const Interface,
        seat: *Seat,
        data: ?*c_void,
    };

    pub const KeyboardGrab = extern struct {
        pub const Interface = extern struct {
            enter: fn (
                grab: *KeyboardGrab,
                surface: *wlr.Surface,
                keycodes: [*]u32,
                num_keycodes: usize,
                modifiers: *wlr.Keyboard.Modifiers,
            ) callconv(.C) void,
            clear_focus: fn (grab: *KeyboardGrab) callconv(.C) void,
            key: fn (grab: *KeyboardGrab, time_msec: u32, key: u32, state: u32) callconv(.C) void,
            modifiers: fn (grab: *KeyboardGrab, modifiers: *wlr.Keyboard.Modifiers) callconv(.C) void,
            cancel: ?fn (grab: *KeyboardGrab) callconv(.C) void,
        };

        interface: *const Interface,
        seat: *Seat,
        data: ?*c_void,
    };

    pub const TouchGrab = extern struct {
        pub const Interface = extern struct {
            down: fn (grab: *TouchGrab, time_msec: u32, point: *TouchPoint) callconv(.C) u32,
            up: fn (grab: *TouchGrab, time_msec: u32, point: *TouchPoint) callconv(.C) void,
            motion: fn (grab: *TouchGrab, time_msec: u32, point: *TouchPoint) callconv(.C) void,
            enter: fn (grab: *TouchGrab, time_msec: u32, point: *TouchPoint) callconv(.C) void,
            cancel: ?fn (grab: *TouchGrab) callconv(.C) void,
        };

        interface: *const Interface,
        seat: *Seat,
        data: ?*c_void,
    };

    pub const PointerState = extern struct {
        seat: *Seat,
        focused_client: ?*Seat.Client,
        focused_surface: ?*wlr.Surface,
        sx: f64,
        sy: f64,

        grab: *PointerGrab,
        default_grab: *PointerGrab,

        buttons: [16]u32,
        button_count: usize,
        grab_button: u32,
        grab_serial: u32,
        grab_time: u32,

        surface_destroy: wl.Listener,

        events: extern struct {
            focus_change: wl.Signal, // event.PointerFocusChange
        },
    };

    pub const KeyboardState = extern struct {
        seat: *Seat,
        keyboard: ?*wlr.Keyboard,

        focused_client: ?*Seat.Client,
        focused_surface: ?*wlr.Surface,

        keyboard_destroy: wl.Listener,
        keyboard_keymap: wl.Listener,
        keyboard_repeat_info: wl.Listener,
        surface_destroy: wl.Listener,

        grab: *KeyboardGrab,
        default_grab: *KeyboardGrab,

        events: extern struct {
            focus_change: wl.Signal, // event.KeyboardFocusChange
        },
    };

    pub const TouchState = extern struct {
        seat: *Seat,
        /// TouchPoint.link
        touch_points: wl.List,

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
    /// Seat.Client.link
    clients: wl.List,

    name: [*:0]u8,

    capabilities: u32,
    accumulated_capabilities: u32,
    last_event: os.timespec,

    selection_source: ?*wlr.DataSource,
    selection_serial: u32,
    /// wlr.DataOffer.link
    selection_offers: wl.List,

    primary_selection_source: ?*wlr.PrimarySelectionSource,
    primary_selection_serial: u32,

    drag: ?*wlr.Drag,
    drag_source: ?*wlr.DataSource,
    drag_serial: u32,
    /// wlr.DataOffer.link
    drag_offers: wl.List,

    pointer_state: PointerState,
    keyboard_state: KeyboardState,
    touch_state: TouchState,

    display_destroy: wl.Listener,
    selection_source_destroy: wl.Listener,
    primary_selection_source_destroy: wl.Listener,
    drag_source_destroy: wl.Listener,

    events: extern struct {
        pointer_grab_begin: wl.Signal,
        pointer_grab_end: wl.Signal,

        keyboard_grab_begin: wl.Signal,
        keyboard_grab_end: wl.Signal,

        touch_grab_begin: wl.Signal,
        touch_grab_end: wl.Signal,

        request_set_cursor: wl.Signal, // event.RequestSetCursor

        request_set_selection: wl.Signal, // event.RequestSetSelection
        set_selection: wl.Signal,

        request_set_primary_selection: wl.Signal, // event.RequestSetPrimarySelection
        set_primary_selection: wl.Signal,

        request_start_drag: wl.Signal, // event.RequestStartDrag
        start_drag: wl.Signal,

        destroy: wl.Signal,
    },

    data: ?*c_void,
};
