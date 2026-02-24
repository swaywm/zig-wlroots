const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const ExtDataControlManagerV1 = extern struct {
    global: *wl.Global,
    devices: wl.list.Head(ExtDataControlDeviceV1, .link),

    events: extern struct {
        destroy: wl.Signal(void),
        new_device: wl.Signal(*ExtDataControlDeviceV1),
    },

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_ext_data_control_manager_v1_create(server: *wl.Server, version: u32) ?*ExtDataControlManagerV1;
    pub fn create(server: *wl.Server, version: u32) !*ExtDataControlManagerV1 {
        return wlr_ext_data_control_manager_v1_create(server, version) orelse error.OutOfMemory;
    }
};

pub const ExtDataControlDeviceV1 = extern struct {
    resource: *wl.Resource,
    manager: *ExtDataControlManagerV1,
    /// ExtDataControlManagerV1.devices
    link: wl.list.Link,

    seat: *wlr.Seat,
    selection_offer_resource: ?*wl.Resource,
    primary_selection_offer_resource: ?*wl.Resource,

    seat_destroy: wl.Listener(void),
    seat_set_selection: wl.Listener(void),
    seat_set_primary_selection: wl.Listener(void),

    extern fn wlr_ext_data_control_device_v1_destroy(device: *ExtDataControlDeviceV1) void;
    pub const destroy = wlr_ext_data_control_device_v1_destroy;
};
