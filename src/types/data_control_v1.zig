const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const DataControlManagerV1 = extern struct {
    global: *wl.Global,
    devices: wl.list.Head(DataControlDeviceV1, .link),

    events: extern struct {
        destroy: wl.Signal(*DataControlManagerV1),
        new_device: wl.Signal(*DataControlDeviceV1),
    },

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_data_control_manager_v1_create(server: *wl.Server) ?*DataControlManagerV1;
    pub fn create(server: *wl.Server) !*DataControlManagerV1 {
        return wlr_data_control_manager_v1_create(server) orelse error.OutOfMemory;
    }
};

pub const DataControlDeviceV1 = extern struct {
    resource: *wl.Resource,
    manager: *DataControlManagerV1,
    /// DataControlManagerV1.devices
    link: wl.list.Link,

    seat: *wlr.Seat,
    selection_offer_resource: ?*wl.Resource,
    primary_selection_offer_resource: ?*wl.Resource,

    private: extern struct {
        seat_destroy: wl.Listener(void),
        seat_set_selection: wl.Listener(void),
        seat_set_primary_selection: wl.Listener(void),
    },

    extern fn wlr_data_control_device_v1_destroy(device: *DataControlDeviceV1) void;
    pub const destroy = wlr_data_control_device_v1_destroy;
};
