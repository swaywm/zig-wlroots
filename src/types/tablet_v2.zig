const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const zwp = wayland.server.zwp;

pub const TabletManagerV2 = extern struct {
    global: *wl.Global,
    clients: wl.list.Link, // private to wlroots
    seats: wl.list.Link, // private to wlroots

    events: extern struct {
        destroy: wl.Listener(void),
    },

    data: ?*anyopaque,

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_tablet_v2_create(server: *wl.Server) ?*TabletManagerV2;
    pub fn create(server: *wl.Server) !*TabletManagerV2 {
        return wlr_tablet_v2_create(server) orelse error.OutOfMemory;
    }

    extern fn wlr_tablet_create(manager: *TabletManagerV2, wlr_seat: *wlr.Seat, wlr_device: *wlr.InputDevice) ?*TabletV2Tablet;
    pub fn createTabletV2Tablet(manager: *TabletManagerV2, wlr_seat: *wlr.Seat, wlr_device: *wlr.InputDevice) !*TabletV2Tablet {
        return wlr_tablet_create(manager, wlr_seat, wlr_device) orelse error.OutOfMemory;
    }

    extern fn wlr_tablet_pad_create(manager: *TabletManagerV2, wlr_seat: *wlr.Seat, wlr_device: *wlr.InputDevice) ?*TabletV2TabletPad;
    pub fn createTabletV2TabletPad(manager: *TabletManagerV2, wlr_seat: *wlr.Seat, wlr_device: *wlr.InputDevice) !*TabletV2TabletPad {
        return wlr_tablet_pad_create(manager, wlr_seat, wlr_device) orelse error.OutOfMemory;
    }

    extern fn wlr_tablet_tool_create(manager: *TabletManagerV2, wlr_seat: *wlr.Seat, wlr_tool: *wlr.TabletTool) ?*TabletV2TabletTool;
    pub fn createTabletV2TabletTool(manager: *TabletManagerV2, wlr_seat: *wlr.Seat, wlr_tool: *wlr.TabletTool) !*TabletV2TabletTool {
        return wlr_tablet_tool_create(manager, wlr_seat, wlr_tool) orelse error.OutOfMemory;
    }
};

pub const TabletV2Tablet = extern struct {
    link: wl.list.Link, // private to wlroots
    wlr_tablet: *wlr.Tablet,
    wlr_device: *wlr.InputDevice,
    clients: wl.list.Link, // private to wlroots

    current_client: ?*opaque {},

    private: extern struct {
        tablet_destroy: wl.Listener(void),
    },
};

pub const TabletV2TabletTool = extern struct {
    pub const event = struct {
        pub const SetCursor = extern struct {
            surface: ?*wlr.Surface,
            serial: u32,
            hotspot_x: i32,
            hotspot_y: i32,
            seat_client: *wlr.Seat.Client,
        };
    };

    pub const Grab = extern struct {
        pub const Interface = extern struct {
            proximity_in: ?*const fn (*Grab, *TabletV2Tablet, *wlr.Surface) callconv(.c) void,
            down: ?*const fn (*Grab) callconv(.c) void,
            up: ?*const fn (*Grab) callconv(.c) void,
            motion: ?*const fn (*Grab, f64, f64) callconv(.c) void,
            pressure: ?*const fn (*Grab, f64) callconv(.c) void,
            distance: ?*const fn (*Grab, f64) callconv(.c) void,
            tilt: ?*const fn (*Grab, f64, f64) callconv(.c) void,
            rotation: ?*const fn (*Grab, f64) callconv(.c) void,
            slider: ?*const fn (*Grab, f64) callconv(.c) void,
            wheel: ?*const fn (*Grab, f64, i32) callconv(.c) void,
            proximity_out: ?*const fn (*Grab) callconv(.c) void,
            button: ?*const fn (*Grab, u32, zwp.TabletToolV2.ButtonState) callconv(.c) void,
            cancel: ?*const fn (*Grab) callconv(.c) void,
        };
        interface: *const Interface,
        tool: *TabletV2TabletTool,
        data: ?*anyopaque,
    };

    link: wl.list.Link, // private to wlroots
    wlr_tool: *wlr.TabletTool,
    clients: wl.list.Link, // private to wlroots

    current_client: ?*opaque {},
    focused_surface: ?*wlr.Surface,

    grab: *Grab,
    default_grab: Grab,

    proximity_serial: u32,
    is_down: bool,
    down_serial: u32,
    num_buttons: usize,
    pressed_buttons: [16]u32,
    pressed_serials: [16]u32,

    events: extern struct {
        set_cursor: wl.Signal(*event.SetCursor),
    },

    private: extern struct {
        surface_destroy: wl.Listener(void),
        tool_destroy: wl.Listener(void),
    },

    extern fn wlr_send_tablet_v2_tablet_tool_proximity_in(tool: *TabletV2TabletTool, tablet: *TabletV2Tablet, surface: *wlr.Surface) void;
    pub const sendProximityIn = wlr_send_tablet_v2_tablet_tool_proximity_in;

    extern fn wlr_send_tablet_v2_tablet_tool_down(tool: *TabletV2TabletTool) void;
    pub const sendDown = wlr_send_tablet_v2_tablet_tool_down;

    extern fn wlr_send_tablet_v2_tablet_tool_up(tool: *TabletV2TabletTool) void;
    pub const sendUp = wlr_send_tablet_v2_tablet_tool_up;

    extern fn wlr_send_tablet_v2_tablet_tool_motion(tool: *TabletV2TabletTool, x: f64, y: f64) void;
    pub const sendMotion = wlr_send_tablet_v2_tablet_tool_motion;

    extern fn wlr_send_tablet_v2_tablet_tool_pressure(tool: *TabletV2TabletTool, pressure: f64) void;
    pub const sendPressure = wlr_send_tablet_v2_tablet_tool_pressure;

    extern fn wlr_send_tablet_v2_tablet_tool_distance(tool: *TabletV2TabletTool, distance: f64) void;
    pub const sendDistance = wlr_send_tablet_v2_tablet_tool_distance;

    extern fn wlr_send_tablet_v2_tablet_tool_tilt(tool: *TabletV2TabletTool, x: f64, y: f64) void;
    pub const sendTilt = wlr_send_tablet_v2_tablet_tool_tilt;

    extern fn wlr_send_tablet_v2_tablet_tool_rotation(tool: *TabletV2TabletTool, degrees: f64) void;
    pub const sendRotation = wlr_send_tablet_v2_tablet_tool_rotation;

    extern fn wlr_send_tablet_v2_tablet_tool_slider(tool: *TabletV2TabletTool, position: f64) void;
    pub const sendSlider = wlr_send_tablet_v2_tablet_tool_slider;

    extern fn wlr_send_tablet_v2_tablet_tool_wheel(tool: *TabletV2TabletTool, degrees: f64, clicks: i32) void;
    pub const sendWheel = wlr_send_tablet_v2_tablet_tool_wheel;

    extern fn wlr_send_tablet_v2_tablet_tool_proximity_out(tool: *TabletV2TabletTool) void;
    pub const sendProximityOut = wlr_send_tablet_v2_tablet_tool_proximity_out;

    extern fn wlr_send_tablet_v2_tablet_tool_button(tool: *TabletV2TabletTool, button: u32, state: zwp.TabletToolV2.ButtonState) void;
    pub const sendButton = wlr_send_tablet_v2_tablet_tool_button;

    extern fn wlr_tablet_v2_tablet_tool_notify_proximity_in(tool: *TabletV2TabletTool, tablet: *TabletV2Tablet, surface: *wlr.Surface) void;
    pub const notifyProximityIn = wlr_tablet_v2_tablet_tool_notify_proximity_in;

    extern fn wlr_tablet_v2_tablet_tool_notify_down(tool: *TabletV2TabletTool) void;
    pub const notifyDown = wlr_tablet_v2_tablet_tool_notify_down;

    extern fn wlr_tablet_v2_tablet_tool_notify_up(tool: *TabletV2TabletTool) void;
    pub const notifyUp = wlr_tablet_v2_tablet_tool_notify_up;

    extern fn wlr_tablet_v2_tablet_tool_notify_motion(tool: *TabletV2TabletTool, x: f64, y: f64) void;
    pub const notifyMotion = wlr_tablet_v2_tablet_tool_notify_motion;

    extern fn wlr_tablet_v2_tablet_tool_notify_pressure(tool: *TabletV2TabletTool, pressure: f64) void;
    pub const notifyPressure = wlr_tablet_v2_tablet_tool_notify_pressure;

    extern fn wlr_tablet_v2_tablet_tool_notify_distance(tool: *TabletV2TabletTool, distance: f64) void;
    pub const notifyDistance = wlr_tablet_v2_tablet_tool_notify_distance;

    extern fn wlr_tablet_v2_tablet_tool_notify_tilt(tool: *TabletV2TabletTool, x: f64, y: f64) void;
    pub const notifyTilt = wlr_tablet_v2_tablet_tool_notify_tilt;

    extern fn wlr_tablet_v2_tablet_tool_notify_rotation(tool: *TabletV2TabletTool, degrees: f64) void;
    pub const notifyRotation = wlr_tablet_v2_tablet_tool_notify_rotation;

    extern fn wlr_tablet_v2_tablet_tool_notify_slider(tool: *TabletV2TabletTool, position: f64) void;
    pub const notifySlider = wlr_tablet_v2_tablet_tool_notify_slider;

    extern fn wlr_tablet_v2_tablet_tool_notify_wheel(tool: *TabletV2TabletTool, degrees: f64, clicks: i32) void;
    pub const notifyWheel = wlr_tablet_v2_tablet_tool_notify_wheel;

    extern fn wlr_tablet_v2_tablet_tool_notify_proximity_out(tool: *TabletV2TabletTool) void;
    pub const notifyProximityOut = wlr_tablet_v2_tablet_tool_notify_proximity_out;

    extern fn wlr_tablet_v2_tablet_tool_notify_button(tool: *TabletV2TabletTool, button: u32, state: zwp.TabletToolV2.ButtonState) void;
    pub const notifyButton = wlr_tablet_v2_tablet_tool_notify_button;

    extern fn wlr_tablet_tool_v2_start_grab(tool: *TabletV2TabletTool, grab: *Grab) void;
    pub const startGrab = wlr_tablet_tool_v2_start_grab;

    extern fn wlr_tablet_tool_v2_end_grab(tool: *TabletV2TabletTool) void;
    pub const endGrab = wlr_tablet_tool_v2_end_grab;

    extern fn wlr_tablet_tool_v2_start_implicit_grab(tool: *TabletV2TabletTool) void;
    pub const startImplicitGrab = wlr_tablet_tool_v2_start_implicit_grab;

    extern fn wlr_tablet_tool_v2_has_implicit_grab(tool: *TabletV2TabletTool) bool;
    pub const hasImplicitGrab = wlr_tablet_tool_v2_has_implicit_grab;
};

pub const TabletV2TabletPad = extern struct {
    pub const event = struct {
        pub const Feedback = extern struct {
            description: [*:0]const u8,
            index: usize,
            serial: u32,
        };
    };

    pub const Grab = extern struct {
        pub const Interface = extern struct {
            enter: ?*const fn (*Grab, *TabletV2Tablet, *wlr.Surface) callconv(.c) u32,
            button: ?*const fn (*Grab, usize, u32, zwp.TabletPadV2.ButtonState) callconv(.c) void,
            strip: ?*const fn (*Grab, u32, f64, bool, u32) callconv(.c) void,
            ring: ?*const fn (*Grab, u32, f64, bool, u32) callconv(.c) void,
            leave: ?*const fn (*Grab, *wlr.Surface) callconv(.c) u32,
            mode: ?*const fn (*Grab, usize, u32, u32) callconv(.c) u32,
            cancel: ?*const fn (*Grab) callconv(.c) void,
        };

        interface: *const Interface,
        pad: *TabletV2TabletPad,
        data: ?*anyopaque,
    };

    link: wl.list.Link, // private to wlroots
    wlr_pad: *wlr.TabletPad,
    wlr_device: *wlr.InputDevice,
    clients: wl.list.Link, // private to wlroots

    group_count: usize,
    groups: [*]u32,

    current_client: ?*opaque {},

    grab: *Grab,
    default_grab: Grab,

    events: extern struct {
        button_feedback: wl.Signal(*event.Feedback),
        strip_feedback: wl.Signal(*event.Feedback),
        ring_feedback: wl.Signal(*event.Feedback),
    },

    private: extern struct {
        pad_destroy: wl.Listener(void),
    },

    extern fn wlr_send_tablet_v2_tablet_pad_enter(pad: *TabletV2TabletPad, tablet: *TabletV2Tablet, surface: *wlr.Surface) u32;
    pub const sendEnter = wlr_send_tablet_v2_tablet_pad_enter;

    extern fn wlr_send_tablet_v2_tablet_pad_button(pad: *TabletV2TabletPad, button: usize, time: u32, state: zwp.TabletPadV2.ButtonState) void;
    pub const sendButton = wlr_send_tablet_v2_tablet_pad_button;

    extern fn wlr_send_tablet_v2_tablet_pad_strip(pad: *TabletV2TabletPad, strip: u32, position: f64, finger: bool, time: u32) void;
    pub const sendStrip = wlr_send_tablet_v2_tablet_pad_strip;

    extern fn wlr_send_tablet_v2_tablet_pad_ring(pad: *TabletV2TabletPad, ring: u32, position: f64, finger: bool, time: u32) void;
    pub const sendRing = wlr_send_tablet_v2_tablet_pad_ring;

    extern fn wlr_send_tablet_v2_tablet_pad_leave(pad: *TabletV2TabletPad, surface: *wlr.Surface) u32;
    pub const sendLeave = wlr_send_tablet_v2_tablet_pad_leave;

    extern fn wlr_send_tablet_v2_tablet_pad_mode(pad: *TabletV2TabletPad, group: usize, mode: u32, time: u32) u32;
    pub const sendMode = wlr_send_tablet_v2_tablet_pad_mode;

    extern fn wlr_tablet_v2_tablet_pad_notify_enter(pad: *TabletV2TabletPad, tablet: *TabletV2Tablet, surface: *wlr.Surface) u32;
    pub const notifyEnter = wlr_tablet_v2_tablet_pad_notify_enter;

    extern fn wlr_tablet_v2_tablet_pad_notify_button(pad: *TabletV2TabletPad, button: usize, time: u32, state: zwp.TabletPadV2.ButtonState) void;
    pub const notifyButton = wlr_tablet_v2_tablet_pad_notify_button;

    extern fn wlr_tablet_v2_tablet_pad_notify_strip(pad: *TabletV2TabletPad, strip: u32, position: f64, finger: bool, time: u32) void;
    pub const notifyStrip = wlr_tablet_v2_tablet_pad_notify_strip;

    extern fn wlr_tablet_v2_tablet_pad_notify_ring(pad: *TabletV2TabletPad, ring: u32, position: f64, finger: bool, time: u32) void;
    pub const notifyRing = wlr_tablet_v2_tablet_pad_notify_ring;

    extern fn wlr_tablet_v2_tablet_pad_notify_leave(pad: *TabletV2TabletPad, surface: *wlr.Surface) u32;
    pub const notifyLeave = wlr_tablet_v2_tablet_pad_notify_leave;

    extern fn wlr_tablet_v2_tablet_pad_notify_mode(pad: *TabletV2TabletPad, group: usize, mode: u32, time: u32) u32;
    pub const notifyMode = wlr_tablet_v2_tablet_pad_notify_mode;

    extern fn wlr_tablet_v2_end_grab(pad: *TabletV2TabletPad) void;
    pub const endGrab = wlr_tablet_v2_end_grab;

    extern fn wlr_tablet_v2_start_grab(pad: TabletV2TabletPad, grab: *Grab) void;
    pub const startGrab = wlr_tablet_v2_start_grab;
};
