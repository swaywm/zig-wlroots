const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const DataDeviceManager = extern struct {
    global: *wl.Global,
    data_sources: wl.list.Head(wl.DataSource, null),

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        destroy: wl.Signal(*DataDeviceManager),
    },

    data: usize,

    extern fn wlr_data_device_manager_create(server: *wl.Server) ?*DataDeviceManager;
    pub fn create(server: *wl.Server) !*DataDeviceManager {
        return wlr_data_device_manager_create(server) orelse error.OutOfMemory;
    }
};

pub const DataOffer = extern struct {
    pub const Type = enum(c_int) {
        selection,
        drag,
    };

    resource: *wl.DataOffer,
    source: ?*DataSource,
    type: Type,
    /// wlr.Seat.selection_offers, wlr.Seat.drag_offers
    link: wl.list.Link,

    actions: u32,
    preferred_action: wl.DataDeviceManager.DndAction.Enum,
    in_ask: bool,

    source_destroy: wl.Listener(*DataSource),
};

pub const DataSource = extern struct {
    pub const Impl = extern struct {
        send: fn (source: *DataSource, mime_type: [*:0]const u8, fd: i32) callconv(.C) void,
        accept: ?fn (source: *DataSource, serial: u32, mime_type: ?[*:0]const u8) callconv(.C) void,
        destroy: ?fn (source: *DataSource) callconv(.C) void,
        dnd_drop: ?fn (source: *DataSource) callconv(.C) void,
        dnd_finish: ?fn (source: *DataSource) callconv(.C) void,
        dnd_action: ?fn (source: *DataSource, wl.DataDeviceManager.DndAction.Enum) callconv(.C) void,
    };

    impl: *const Impl,

    mime_types: wl.Array,
    actions: i32,

    accepted: bool,

    current_dnd_action: wl.DataDeviceManager.DndAction.Enum,
    compositor_action: u32,

    events: extern struct {
        destroy: wl.Signal(*DataSource),
    },

    extern fn wlr_data_source_init(source: *DataSource, impl: *const Impl) void;
    pub const init = wlr_data_source_init;

    extern fn wlr_data_source_send(source: *DataSource, mime_type: [*:0]const u8, fd: i32) void;
    pub const send = wlr_data_source_send;

    extern fn wlr_data_source_accept(source: *DataSource, serial: u32, mime_type: ?[*:0]const u8) void;
    pub const accept = wlr_data_source_accept;

    extern fn wlr_data_source_destroy(source: *DataSource) void;
    pub const destroy = wlr_data_source_destroy;

    extern fn wlr_data_source_dnd_drop(source: *DataSource) void;
    pub const dndDrop = wlr_data_source_dnd_drop;

    extern fn wlr_data_source_dnd_finish(source: *DataSource) void;
    pub const dndFinish = wlr_data_source_dnd_finish;

    extern fn wlr_data_source_dnd_action(source: *DataSource, action: wl.DataDeviceManager.DndAction.Enum) void;
    pub const dndAction = wlr_data_source_dnd_action;
};

pub const Drag = extern struct {
    pub const Icon = extern struct {
        drag: *Drag,
        surface: *wlr.Surface,
        mapped: bool,

        events: extern struct {
            map: wl.Signal(*Drag.Icon),
            unmap: wl.Signal(*Drag.Icon),
            destroy: wl.Signal(*Drag.Icon),
        },

        surface_destroy: wl.Listener(*wlr.Surface),

        data: usize,
    };

    pub const GrabType = enum(c_int) {
        keyboard,
        keyboard_pointer,
        keyboard_touch,
    };

    pub const event = struct {
        pub const Motion = extern struct {
            drag: *Drag,
            time: u32,
            sx: f64,
            sy: f64,
        };

        pub const Drop = extern struct {
            drag: *Drag,
            time: u32,
        };
    };

    grab_type: GrabType,
    keyboard_grab: wlr.Seat.KeyboardGrab,
    pointer_grab: wlr.Seat.PointerGrab,
    touch_grab: wlr.Seat.TouchGrab,

    seat: *wlr.Seat,
    seat_client: *wlr.Seat.Client,
    focus_client: ?*wlr.Seat.Client,

    icon: ?*Drag.Icon,
    focus: ?*wlr.Surface,
    source: ?*DataSource,

    started: bool,
    dropped: bool,
    cancelling: bool,
    grab_touch_id: i32,
    touch_id: i32,

    events: extern struct {
        focus: wl.Signal(*Drag),
        motion: wl.Signal(*event.Motion),
        drop: wl.Signal(*event.Drop),
        destroy: wl.Signal(*Drag),
    },

    source_destroy: wl.Listener(*DataSource),
    seat_client_destroy: wl.Listener(*wlr.Seat.Client),
    icon_destroy: wl.Listener(*Drag.Icon),

    data: usize,

    extern fn wlr_drag_create(
        seat_client: *wlr.Seat.Client,
        source: ?*DataSource,
        icon_surface: ?*wlr.Surface,
    ) ?*Drag;
    pub fn create(
        seat_client: *wlr.Seat.Client,
        source: ?*DataSource,
        icon_surface: ?*wlr.Surface,
    ) !*Drag {
        return wlr_drag_create(seat_client, source, icon_surface) orelse error.OutOfMemory;
    }
};
