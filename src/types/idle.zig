const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Idle = extern struct {
    global: *wl.Global,
    idle_timers: wl.list.Head(IdleTimeout, "link"),
    event_loop: *wl.EventLoop,
    enabled: bool,

    server_destroy: wl.Listener(*wl.Server),
    events: extern struct {
        activity_notify: wl.Signal(*wlr.Seat),
        destroy: wl.Signal(*Idle),
    },

    data: usize,

    extern fn wlr_idle_create(server: *wl.Server) ?*Idle;
    pub fn create(server: *wl.Server) !*Idle {
        return wlr_idle_create(server) orelse error.OutOfMemory;
    }

    extern fn wlr_idle_notify_activity(idle: *Idle, seat: *wlr.Seat) void;
    pub const notifyActivity = wlr_idle_notify_activity;

    extern fn wlr_idle_set_enabled(idle: *Idle, seat: ?*wlr.Seat, enabled: bool) void;
    pub const setEnabled = wlr_idle_set_enabled;
};

pub const IdleTimeout = extern struct {
    resource: *wl.Resource,
    link: wl.list.Link,
    seat: *wlr.Seat,

    idle_source: *wl.EventSource,
    idle_state: bool,
    enabled: bool,
    timeout: u32,

    events: extern struct {
        idle: wl.Signal(*IdleTimeout),
        resumed: wl.Signal(*IdleTimeout),
        destroy: wl.Signal(void),
    },

    input_listener: wl.Listener(*wlr.Seat),
    seat_destroy: wl.Listener(*wlr.Seat),

    data: usize,

    extern fn wlr_idle_timeout_create(idle: *Idle, seat: *wlr.Seat, timeout: u32) ?*IdleTimeout;
    pub fn create(idle: *Idle, seat: *wlr.Seat, timeout: u32) !*IdleTimeout {
        return wlr_idle_timeout_create(idle, seat, timeout) orelse error.OutOfMemory;
    }

    extern fn wlr_idle_timeout_destroy(timeout: *IdleTimeout) void;
    pub const destroy = wlr_idle_timeout_destroy;
};
