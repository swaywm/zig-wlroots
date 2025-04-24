const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const PrimarySelectionDeviceManagerV1 = extern struct {
    global: *wl.Global,
    /// PrimarySelectionV1Device.link
    devices: wl.list.Head(PrimarySelectionDeviceV1, .link),

    events: extern struct {
        destroy: wl.Signal(*PrimarySelectionDeviceManagerV1),
    },

    data: ?*anyopaque,

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_primary_selection_v1_device_manager_create(server: *wl.Server) ?*PrimarySelectionDeviceManagerV1;
    pub fn create(server: *wl.Server) !*PrimarySelectionDeviceManagerV1 {
        return wlr_primary_selection_v1_device_manager_create(server) orelse error.OutOfMemory;
    }
};

pub const PrimarySelectionDeviceV1 = extern struct {
    manager: *PrimarySelectionDeviceManagerV1,
    seat: *wlr.Seat,
    /// PrimarySelectionDeviceManagerV1.devices
    link: wl.list.Link,
    resources: wl.list.Head(wl.Resource, null),

    offers: wl.list.Head(wl.Resource, null),

    data: ?*anyopaque,

    private: extern struct {
        seat_destroy: wl.Listener(void),
        seat_focus_change: wl.Listener(void),
        seat_set_primary_selection: wl.Listener(void),
    },
};
