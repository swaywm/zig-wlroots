const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const IdleNotifierV1 = extern struct {
    global: *wl.Global,

    private: extern struct {
        inhibited: bool,
        notifications: wl.list.Link,

        server_destroy: wl.Listener(void),
    },

    extern fn wlr_idle_notifier_v1_create(server: *wl.Server) ?*IdleNotifierV1;
    pub fn create(server: *wl.Server) !*IdleNotifierV1 {
        return wlr_idle_notifier_v1_create(server) orelse error.OutOfMemory;
    }

    extern fn wlr_idle_notifier_v1_set_inhibited(notifier: *IdleNotifierV1, inhibited: bool) void;
    pub const setInhibited = wlr_idle_notifier_v1_set_inhibited;

    extern fn wlr_idle_notifier_v1_notify_activity(notifier: *IdleNotifierV1, seat: *wlr.Seat) void;
    pub const notifyActivity = wlr_idle_notifier_v1_notify_activity;
};
