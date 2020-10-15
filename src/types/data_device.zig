const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const DataDeviceManager = extern struct {
    global: *wl.Global,
    data_sources: wl.List,

    display_destroy: wl.Listener,

    events: extern struct {
        destroy: wl.Signal
    },

    data: ?*c_void,

    extern fn wlr_data_device_manager_create(server: *wl.Server) ?*DataDeviceManager;
    pub const create = wlr_data_device_manager_create;
};

pub const DataOffer = extern struct {
    pub const Type = extern enum {
        selection,
        drag,
    };

    resource: *wl.DataOffer,
    source: ?*DataSource,
    kind: Type,
    /// wlr.Seat.selection_offers, wlr.Seat.drag_offers
    link: wl.List,

    actions: u32,
    preferred_action: wl.DataDeviceManager.DndAction,
    in_ask: bool,

    source_destroy: wl.Listener,
};

pub const DataSource = extern struct {
    pub const Impl = extern struct {
        send: fn (source: *DataSource, mime_type: [*:0]const u8, fd: i32) callconv(.C) void,
        accept: ?fn (source: *DataSource, serial: u32, mime_type: ?[*:0]const u8) callconv(.C) void,
        destroy: ?fn (source: *DataSource) callconv(.C) void,
        dnd_drop: ?fn (source: *DataSource) callconv(.C) void,
        dnd_finish: ?fn (source: *DataSource) callconv(.C) void,
        dnd_action: ?fn (source: *DataSource, wl.DataDeviceManager.DndAction) callconv(.C) void,
    };

    impl: *const Impl,

    mime_types: wl.Array,
    actions: i32,

    accepted: bool,

    current_dnd_action: wl.DataDeviceManager.DndAction,
    compositor_action: u32,

    events: extern struct {
        destroy: wl.Signal,
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

    extern fn wlr_data_source_dnd_action(source: *DataSource, action: wl.DataDeviceManager.DndAction) void;
    pub const dndAction = wlr_data_source_dnd_action;
};

pub const Drag = extern struct {
    pub const Icon = extern struct {
        drag: *Drag,
        surface: *wlr.Surface,
        mapped: bool,

        events: extern struct {
            map: wl.Signal,
            unmap: wl.Signal,
            destroy: wl.Signal,
        },

        surface_destroy: wl.Listener,

        data: ?*c_void,
    };

    pub const GrabType = extern enum {
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

    icon: ?*Icon,
    focus: ?*wlr.Surface,
    source: ?*DataSource,

    started: bool,
    dropped: bool,
    cancelling: bool,
    grab_touch_id: i32,
    touch_id: i32,

    events: extern struct {
        focus: wl.Signal,
        motion: wl.Signal, // event.Motion
        drop: wl.Signal, // event.Drop
        destroy: wl.Signal,
    },

    point_destroy: wl.Listener,
    source_destroy: wl.Listener,
    seat_client_destroy: wl.Listener,
    icon_destroy: wl.Listener,

    data: ?*c_void,

    extern fn wlr_drag_create(seat_client: *wlr.Seat.Client, source: ?*DataSource, icon_surface: ?*wlr.Surface) ?*Drag;
    pub const create = wlr_drag_create;
};
