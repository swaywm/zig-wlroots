const wlr = @import("../wlroots.zig");

const wl = @import("wayland").server.wl;

pub const WLR_TABLET_V2_TOOL_BUTTONS_CAP = 16;

pub const TabletSeatV2 = extern struct {
    pub const Client = extern struct {
        seat_link: wl.list.Link,
        client_link: wl.list.Link,
        wl_client: *wl.Client,
        resource: *wl.Resource,

        client: *TabletV2.Client,
        seat_client: *wlr.Seat.Client,

        seat_client_destroy: wl.Listener(*wlr.Seat.Client),

        tools: wl.list.Head(TabletToolV2, null),
        tablets: wl.list.Head(TabletV2, null),
        pads: wl.list.Head(TabletPadV2, null),
    };

    pub const PadGrab = extern struct {
        pub const Interface = extern struct {
            enter: fn (
                grab: *PadGrab,
                tablet: *TabletV2,
                surface: *wlr.Surface,
            ) callconv(.C) void,

            button: fn (
                grab: *PadGrab,
                button: u32,
                state: wl.Pointer.ButtonState, // enum zwp_tablet_pad_v2_button_state
            ) callconv(.C) void,

            strip: fn (
                grab: *PadGrab,
                strip: u32,
                position: f64,
                finger: bool,
                time: u32,
            ) callconv(.C) void,

            ring: fn (
                grab: *PadGrab,
                ring: u32,
                position: f64,
                finger: bool,
                time: u32,
            ) callconv(.C) void,

            leave: fn (
                grab: *PadGrab,
                surface: *wlr.Surface,
            ) callconv(.C) void,

            mode: fn (
                grab: *PadGrab,
                group: usize,
                mode: u32,
                time: u32,
            ) callconv(.C) void,

            cancel: fn (
                grab: *PadGrab,
            ) callconv(.C) void,
        };

        interface: *Interface,
        pad: *TabletPadV2,
        data: usize,
    };

    pub const ToolGrab = extern struct {
        pub const Interface = extern struct {
            proximity_in: fn (
                grab: *ToolGrab,
                tablet: *TabletV2,
                surface: *wlr.Surface,
            ) callconv(.C) void,

            down: fn (
                grab: *ToolGrab,
            ) callconv(.C) void,

            up: fn (
                grab: *ToolGrab,
            ) callconv(.C) void,

            motion: fn (
                grab: *ToolGrab,
                x: f64,
                y: f64,
            ) callconv(.C) void,

            pressure: fn (
                grab: *ToolGrab,
                pressure: f64,
            ) callconv(.C) void,

            distance: fn (
                grab: *ToolGrab,
                distance: f64,
            ) callconv(.C) void,

            tilt: fn (
                grab: *ToolGrab,
                x: f64,
                y: f64,
            ) callconv(.C) void,

            rotation: fn (
                grab: *ToolGrab,
                degrees: f64,
            ) callconv(.C) void,

            slider: fn (
                grab: *ToolGrab,
                postion: f64,
            ) callconv(.C) void,

            wheel: fn (
                grab: *ToolGrab,
                degrees: f64,
                clicks: u32,
            ) callconv(.C) void,

            proximity_out: fn (
                grab: *ToolGrab,
            ) callconv(.C) void,

            button: fn (
                grab: *ToolGrab,
                button: u32,
                state: wl.Pointer.ButtonState, // enum zwp_tablet_tool_v2_button_state
            ) callconv(.C) void,

            cancel: fn (
                grab: *ToolGrab,
            ) callconv(.C) void,
        };

        interface: *Interface,
        pad: *TabletToolV2,
        data: usize,
    };

    link: wl.list.Link,
    seat: *wlr.Seat,
    manager: *TabletManagerV2,

    tablets: wl.list.Head(TabletV2, null),
    tools: wl.list.Head(TabletToolV2, null),
    pads: wl.list.Head(TabletPadV2, null),

    clients: wl.list.Head(Client, null),

    seat_destroy: wl.Listener(*wlr.Seat),
};

pub const TabletManagerV2 = extern struct {
    pub const Client = extern struct {
        link: wl.list.Link,
        client: *wl.Client,
        resource: *wl.Resource,
        manager: *TabletManagerV2,
        tablet_seats: wl.list.Head(TabletSeatV2, null),
    };

    global: *wl.Global,
    clients: wl.list.Head(Client, null),
    seats: wl.list.Head(TabletSeatV2, null),

    display_destroy: wl.Listener(*wl.Display),

    events: extern struct {
        destroy: wl.Signal(*TabletManagerV2),
    },

    data: usize,

    extern fn wlr_tablet_v2_create(server: *wl.Server) ?*TabletManagerV2;
    pub fn create(server: *wl.Server) !*TabletManagerV2 {
        return wlr_tablet_v2_create(display) orelse error.OutOfMemory;
    }
};

pub const TabletV2 = extern struct {
    pub const Client = extern struct {
        seat_link: wl.list.Link,
        tablet_link: wl.list.Link,
        client: *wl.Client,
        resource: *wl.Resource,
    };

    pub const event = struct {
        pub const Cursor = extern struct {
            surface: *wlr.Surface,
            serial: u32,
            hotspot_x: i32,
            hotspot_y: i32,
            seat_client: *wlr.Seat.Client,
        };

        pub const Feedback = extern struct {
            description: ?[*:0]u8,
            index: usize,
            serial: u32,
        };
    };

    link: wl.list.Link,
    wlr_tablet: *wlr.Tablet,
    wlr_device: *wlr.InputDevice,
    clients: wl.list.Head(Client, null),

    tool_destroy: wl.Listener(*wlr.InputDevice),

    current_client: *Client,

    extern fn wlr_tablet_create(manager: *TabletManagerV2, wlr_seat: *wlr.Seat, wlr_device: *wlr.InputDevice) void;
    pub const create = wlr_tablet_create;

    extern fn wlr_tablet_v2_end_grab(pad: *TabletPadV2) void;
    pub const endGrab = wlr_tablet_v2_end_grab;

    extern fn wlr_tablet_v2_start_grab(pad: *TabletPadV2, grab: TabletSeatV2.PadGrab) void;
    pub const startGrab = wlr_tablet_v2_start_grab;
};

pub const TabletToolV2 = extern struct {
    pub const Client = extern struct {
        seat_link: wl.list.Link,
        tool_link: wl.list.Link,
        client: *wl.Client,
        resource: *wl.Resource,
        tool: *TabletToolV2,
        seat: *TabletSeatV2.Client,

        frame_source: *wl.EventSource,
    };

    link: wl.list.Link,
    wlr_tablet_tool: *wlr.TabletTool,
    clients: wl.list.Head(Client, null),

    tool_destroy: wl.Listener(*wlr.TabletTool),

    current_client: *Client,
    focused_surface: *wlr.Surface,
    surface_destroy: wl.Listener(*wlr.Surface),

    grab: *TabletSeatV2.ToolGrab,
    default_grab: TabletSeatV2.ToolGrab,

    proximity_serial: u32,
    is_down: bool,
    down_serial: u32,
    num_buttons: usize,

    pressed_buttons: [WLR_TABLET_V2_TOOL_BUTTONS_CAP]u32,
    pressed_serials: [WLR_TABLET_V2_TOOL_BUTTONS_CAP]u32,

    events: extern struct {
        set_cursor: wl.Signal(*TabletV2.event.Cursor),
    },

    extern fn wlr_tablet_tool_create(manager: *TabletManagerV2, wlr_seat: *wlr.Seat, wlr_tool: *wlr.TabletTool) void;
    pub const create = wlr_tablet_tool_create;

    extern fn wlr_send_tablet_v2_tablet_tool_proximity_in(tool: *TabletToolV2, tablet: *TabletV2, surface: *wlr.Surface) void;
    pub const sendProximityIn = wlr_send_tablet_v2_tablet_tool_proximity_in;

    extern fn wlr_send_tablet_v2_tablet_tool_down(tool: *TabletToolV2) void;
    pub const sendDown = wlr_send_tablet_v2_tablet_tool_down;

    extern fn wlr_send_tablet_v2_tablet_tool_up(tool: *TabletToolV2) void;
    pub const sendUp = wlr_send_tablet_v2_tablet_tool_up;

    extern fn wlr_send_tablet_v2_tablet_tool_motion(tool: *TabletToolV2, x: f64, y: f64) void;
    pub const sendMotion = wlr_send_tablet_v2_tablet_tool_motion;

    extern fn wlr_send_tablet_v2_tablet_tool_pressure(tool: *TabletToolV2, x: f64, y: f64) void;
    pub const sendPressure = wlr_send_tablet_v2_tablet_tool_pressure;

    extern fn wlr_send_tablet_v2_tablet_tool_distance(tool: *TabletToolV2, distance: f64) void;
    pub const sendDistance = wlr_send_tablet_v2_tablet_tool_distance;

    extern fn wlr_send_tablet_v2_tablet_tool_tilt(tool: *TabletToolV2, x: f64, y: f64) void;
    pub const sendTilt = wlr_send_tablet_v2_tablet_tool_tilt;

    extern fn wlr_send_tablet_v2_tablet_tool_rotation(tool: *TabletToolV2, degrees: f64) void;
    pub const sendRotation = wlr_send_tablet_v2_tablet_tool_rotation;

    extern fn wlr_send_tablet_v2_tablet_tool_slider(tool: *TabletToolV2, position: f64) void;
    pub const sendSlider = wlr_send_tablet_v2_tablet_tool_slider;

    extern fn wlr_send_tablet_v2_tablet_tool_wheel(tool: *TabletToolV2, degrees: f64, clicks: i32) void;
    pub const sendWheel = wlr_send_tablet_v2_tablet_tool_wheel;

    extern fn wlr_send_tablet_v2_tablet_tool_proximity_out(tool: *TabletToolV2) void;
    pub const sendProximityOut = wlr_send_tablet_v2_tablet_tool_proximity_out;

    extern fn wlr_send_tablet_v2_tablet_tool_button(tool: *TabletToolV2, button: u32, state: wl.Pointer.ButtonState) void;
    pub const sendButton = wlr_send_tablet_v2_tablet_tool_button;

    extern fn wlr_tablet_v2_tablet_tool_notify_proximity_in(tool: *TabletToolV2, tablet: *TabletV2, surface: *wlr.Surface) void;
    pub const notifyProximityIn = wlr_tablet_v2_tablet_tool_notify_proximity_in;

    extern fn wlr_tablet_v2_tablet_tool_notify_down(tool: *TabletToolV2) void;
    pub const notifyDown = wlr_tablet_v2_tablet_tool_notify_down;

    extern fn wlr_tablet_v2_tablet_tool_notify_up(tool: *TabletToolV2) void;
    pub const notifyUp = wlr_tablet_v2_tablet_tool_notify_up;

    extern fn wlr_tablet_v2_tablet_tool_notify_motion(tool: *TabletToolV2, x: f64, y: f64) void;
    pub const notifyMotion = wlr_tablet_v2_tablet_tool_notify_motion;

    extern fn wlr_tablet_v2_tablet_tool_notify_pressure(tool: *TabletToolV2, x: f64, y: f64) void;
    pub const notifyPressure = wlr_tablet_v2_tablet_tool_notify_pressure;

    extern fn wlr_tablet_v2_tablet_tool_notify_distance(tool: *TabletToolV2, distance: f64) void;
    pub const notifyDistance = wlr_tablet_v2_tablet_tool_notify_distance;

    extern fn wlr_tablet_v2_tablet_tool_notify_tilt(tool: *TabletToolV2, x: f64, y: f64) void;
    pub const notifyTilt = wlr_tablet_v2_tablet_tool_notify_tilt;

    extern fn wlr_tablet_v2_tablet_tool_notify_rotation(tool: *TabletToolV2, degrees: f64) void;
    pub const notifyRotation = wlr_tablet_v2_tablet_tool_notify_rotation;

    extern fn wlr_tablet_v2_tablet_tool_notify_slider(tool: *TabletToolV2, position: f64) void;
    pub const notifySlider = wlr_tablet_v2_tablet_tool_notify_slider;

    extern fn wlr_tablet_v2_tablet_tool_notify_wheel(tool: *TabletToolV2, degrees: f64, clicks: i32) void;
    pub const notifyWheel = wlr_tablet_v2_tablet_tool_notify_wheel;

    extern fn wlr_tablet_v2_tablet_tool_notify_proximity_out(tool: *TabletToolV2) void;
    pub const notifyProximityOut = wlr_tablet_v2_tablet_tool_notify_proximity_out;

    extern fn wlr_tablet_v2_tablet_tool_notify_button(tool: *TabletToolV2, button: u32, state: wl.Pointer.ButtonState) void;
    pub const notifyButton = wlr_tablet_v2_tablet_tool_notify_button;

    extern fn wlr_tablet_tool_v2_start_grab(tool: *TabletToolV2, grab: *TabletSeatV2.ToolGrab) void;
    pub const startGrab = wlr_tablet_tool_v2_start_grab;

    extern fn wlr_tablet_tool_v2_end_grab(tool: *TabletToolV2) void;
    pub const endGrab = wlr_tablet_tool_v2_end_grab;

    extern fn wlr_tablet_tool_v2_start_implicit_grab(tool: *TabletToolV2) void;
    pub const startImplicitGrab = wlr_tablet_tool_v2_start_implicit_grab;

    extern fn wlr_tablet_tool_v2_has_implicit_grab(tool: *TabletToolV2) void;
    pub const hasImplicitGrab = wlr_tablet_tool_v2_has_implicit_grab;
};

pub const TabletPadV2 = extern struct {
    pub const Client = extern struct {
        seat_link: wl.list.Link,
        pad_link: wl.list.Link,
        client: *wl.Client,
        resource: *wl.Resource,
        pad: *TabletPadV2,
        seat: *TabletSeatV2.Client,

        button_count: usize,

        group_count: usize,
        groups: **wl.Resource,

        ring_count: usize,
        rings: **wl.Resource,

        strip_count: usize,
        strips: **wl.Resource,
    };

    link: wl.list.Link,
    wlr_pad: wlr.TabletPad,
    wlr_device: *wlr.InputDevice,
    clients: wl.list.Head(Client, null),

    group_count: usize,
    groups: *u32,

    pad_destroy: wl.Listener(*wlr.InputDevice),

    current_client: *Client,
    grab: *TabletSeatV2.PadGrab,
    default_grab: TabletSeatV2.PadGrab,

    events: extern struct {
        button_feedback: wl.Signal(*TabletV2.event.Feedback),
        strip_feedback: wl.Signal(*TabletV2.event.Feedback),
        ring_feedback: wl.Signal(*TabletV2.event.Feedback),
    },

    extern fn wlr_tablet_pad_create(manager: *TabletManagerV2, wlr_seat: *wlr.Seat, wlr_device: *wlr.InputDevice) void;
    pub const create = wlr_tablet_pad_create;

    extern fn wlr_send_tablet_v2_tablet_pad_enter(pad: *TabletPadV2, tablet: *TabletV2, surface: *wlr.Surface) void;
    pub const sendEnter = wlr_send_tablet_v2_tablet_pad_enter;

    extern fn wlr_send_tablet_v2_tablet_pad_button(pad: *TabletPadV2, button: usize, time: u32, state: wl.Pointer.ButtonState) void;
    pub const sendButton = wlr_send_tablet_v2_tablet_pad_button;

    extern fn wlr_send_tablet_v2_tablet_pad_strip(pad: *TabletPadV2, strip: u32, position: f64, finger: bool, time: u32) void;
    pub const sendStrip = wlr_send_tablet_v2_tablet_pad_strip;

    extern fn wlr_send_tablet_v2_tablet_pad_ring(pad: *TabletPadV2, strip: u32, position: f64, finger: bool, time: u32) void;
    pub const sendRing = wlr_send_tablet_v2_tablet_pad_ring;

    extern fn wlr_send_tablet_v2_tablet_pad_leave(pad: *TabletPadV2, surface: *wlr.Surface) void;
    pub const sendLeave = wlr_send_tablet_v2_tablet_pad_leave;

    extern fn wlr_send_tablet_v2_tablet_pad_mode(pad: *TabletPadV2, group: usize, mode: u32, time: u32) void;
    pub const sendMode = wlr_send_tablet_v2_tablet_pad_mode;
};
