const wlr = @import("../wlroots.zig");

const wl = @import("wayland").server.wl;

const Seat = @import("seat").Seat;
const Tablet = @import("tablet_tool").Tablet;
const TabletTool = @import("tablet_tool").TabletTool;
const InputDevice = @import("input_device").InputDevice;
const Surface = @import("surface").Surface;

pub const WLR_TABLET_V2_TOOL_BUTTONS_CAP = 16;

pub const TabletSeatV2 = extern struct {
    pub const Client = extern struct {
        seat_link: wl.list.Link,
        client_link: wl.list.Link,
        wl_client: *wl.Client,
        resource: *wl.Resource,

        client: *TabletClientV2,
        seat_client: *Seat.Client,

        seat_client_destroy: wl.Listener(*Seat.Client),

        tools: wl.list.Head(TabletToolV2),
        tablets: wl.list.Head(TabletV2),
        pads: wl.list.Head(TabletPadV2),

        extern fn add_tablet_client(seat: *Client, tablet: *TabletV2) void;
        pub const addTablet = add_tablet_client;

        extern fn add_tablet_pad_client(seat: *Client, tablet_pad: *TabletPadV2) void;
        pub const addTabletPad = add_tablet_pad_client;

        extern fn add_tablet_tool_client(seat: *Client, tablet_tool: *TabletToolV2) void;
        pub const addTabletTool = add_tablet_tool_client;

        extern fn tablet_seat_client_from_resource(resource: *wl.resource) ?*Client;
        pub const fromResource = tablet_seat_client_from_resource;

        extern fn tablet_seat_client_v2_destroy(tablet_seat_client: *Client) void;
        pub const destroy = tablet_seat_client_v2_destroy;
    };

    link: wl.list.Link,
    seat: *Seat,
    manager: *TabletManagerV2,

    tablets: wl.list.Head(TabletV2),
    tools: wl.list.Head(TabletToolV2),
    pads: wl.list.Head(TabletPadV2),

    clients: wl.list.Head(Client),

    seat_destroy: wl.Listener(*Seat),

};

pub const TabletPadV2Grab = extern struct {
    pub const Interface = extern struct {};
    interface: *Interface,
    pad: TabletPadV2,
    data: usize,
};

pub const TabletToolV2Grab = extern struct {
    pub const Interface = extern struct {};
    interface: *Interface,
    pad: TabletToolV2,
    data: usize,
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

    extern fn get_or_create_tablet_seat(manager: *TabletManagerV2, seat: *Seat) TabletSeatV2;
    pub const getOrCreateTabletSeat = get_or_create_tablet_seat;
};

pub const TabletV2 = extern struct {
    pub const Client = extern struct {
        seat_link: wl.list.Link,
        tablet_link: wl.list.Link,
        client: *wl.Client,
        resource: *wl.Resource,

        extern fn tablet_client_from_resource(resource: *wl.resource) ?*Client;
        pub const fromResource = tablet_client_from_resource;
    };

    pub const event = struct {
        pub const Cursor = extern struct {
            surface: *Surface,
            serial: u32,
            hotspot_x: i32,
            hotspot_y: i32,
            seat_client: *Seat.Client,
        };

        pub const Feedback = extern struct {
            description: ?[*:0]u8,
            index: usize,
            serial: u32,
        };
    };

    link: wl.list.Link,
    wlr_tablet: *Tablet,
    wlr_device: *InputDevice,
    clients: wl.list.Head(Client, null),

    tool_destroy: wl.Listener(*TabletToolV2), // TabletToolV2 or TabletTool?

    current_client: *Client,

    extern fn destroy_tablet_v2(tablet: *TabletV2) void;
    pub const destroy = destroy_tablet_v2;
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

        extern fn tablet_tool_client_from_resource(resource: *wl.resource) ?*Client;
        pub const fromResource = tablet_tool_client_from_resource;
    };

    link: wl.list.Link,
    wlr_tablet_tool: *TabletTool,
    clients: wl.list.Head(Client, null),

    tool_destroy: wl.Listener(*TabletToolV2), // TabletToolV2 or TabletTool?

    current_client: *Client,
    focused_surface: *Surface,
    surface_destroy: wl.Listener(*Surface),

    grab: *TabletToolV2Grab,
    default_grab: TabletToolV2Grab,

    proximity_serial: u32,
    is_down: bool,
    down_serial: u32,
    num_buttons: usize,

    pressed_buttons: [WLR_TABLET_V2_TOOL_BUTTONS_CAP]u32,
    pressed_serials: [WLR_TABLET_V2_TOOL_BUTTONS_CAP]u32,

    events: extern struct {
        set_cursor: wl.Signal(*TabletV2.event.Cursor),
    },

    extern fn destroy_tablet_tool_v2(tablet_tool: *TabletToolV2) void;
    pub const destroy = destroy_tablet_tool_v2;
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

        extern fn tablet_pad_client_from_resource(resource: *wl.resource) ?*Client;
        pub const fromResource = tablet_pad_client_from_resource;
    };

    link: wl.list.Link,
    wlr_pad: TabletPad,
    wlr_device: *InputDevice,
    clients: wl.list.Head(Client, null),

    group_count: usize,
    groups: *u32,

    pad_destroy: wl.Listener(*TabletPadV2), // TabletPadV2 or TabletPad?

    current_client: *Client,
    grab: *TabletPadV2Grab,
    default_grab: TabletPadV2Grab,

    events: extern struct {
        button_feedback: wl.Signal(*TabletV2.event.Feedback),
        strip_feedback: wl.Signal(*TabletV2.event.Feedback),
        ring_feedback: wl.Signal(*TabletV2.event.Feedback),
    },

    extern fn destroy_tablet_pad_v2(tablet_tool: *TabletPadV2) void;
    pub const destroy = destroy_tablet_pad_v2;
};
