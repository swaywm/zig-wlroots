const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const InputInhibitManager = extern struct {
    global: *wl.Global,
    active_client: ?*wl.Client,
    active_inhibitor: ?*wl.Resource,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        activate: wl.Signal(*InputInhibitManager),
        deactivate: wl.Signal(*InputInhibitManager),
        destroy: wl.Signal(*InputInhibitManager),
    },

    data: usize,

    extern fn wlr_input_inhibit_manager_create(server: *wl.Server) ?*InputInhibitManager;
    pub fn create(server: *wl.Server) !*InputInhibitManager {
        return wlr_input_inhibit_manager_create(server) orelse error.OutOfMemory;
    }
};
