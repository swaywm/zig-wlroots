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
