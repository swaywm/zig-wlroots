const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const XdgActivationV1 = extern struct {
    pub const event = struct {
        pub const RequestActivate = extern struct {
            activation: *wlr.XdgActivationV1,
            token: *wlr.XdgActivationTokenV1,
            surface: *wlr.Surface,
        };
    };

    /// token timeout in milliseconds (0 to disable)
    token_timeout_msec: u32,

    tokens: wl.list.Head(XdgActivationTokenV1, "link"),

    events: extern struct {
        destroy: wl.Signal(*XdgActivationV1),
        request_activate: wl.Signal(*XdgActivationV1.RequestActivate.event),
    },

    // Private state
    global: *wl.Global,

    server_destroy: wl.Listener(*wl.Server),

    extern fn wlr_xdg_activation_v1_create(server: *wl.Server) ?*XdgActivationV1;
    pub fn create(server: *wl.Server) !*XdgActivationV1 {
        return wlr_xdg_activation_v1_create(server) orelse error.OutOfMemory;
    }
};

pub const XdgActivationTokenV1 = extern struct {
    activation: *wlr.XdgActivationV1,
    surface: ?*wlr.Surface,
    seat: ?*wlr.Seat,

    /// Invalid if seat is null
    serial: u32,
    app_id: ?[*:0]u8,

    link: wl.list.Link,

    // Private state
    token: [*:0]u8,
    resource: ?*wl.Resource,
    timeout: ?*wl.EventSource,

    seat_destroy: wl.Listener(*wlr.Seat),
    surface_destroy: wl.Listener(*wlr.Surface),
};
