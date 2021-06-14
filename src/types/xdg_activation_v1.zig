const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const XdgActivationV1 = extern struct {
    // token timeout in milliseconds (0 to disable)
    token_timeout_msec: u32,

    tokens: wl.list.Head(XdgActivationTokenV1, "link"),

    events: extern struct {
        destroy: wl.Signal(*XdgActivationV1),
        request_activate: wl.Signal(*XdgActivationV1.RequestActivate.event),
    },

    // Private state
    global: *wl.Global,

    server_destroy: wl.Listener(*wl.Server),

    pub const RequestActivate = extern struct {
        event: extern struct {
            activation: *wlr.XdgActivationV1,
            token: *wlr.XdgActivationTokenV1,
            surface: *wlr.Surface,
        },
    };

    extern fn wlr_xdg_activation_v1_create(server: *wl.Server) ?*XdgActivationV1;
    pub const create = wlr_xdg_activation_v1_create;
};

pub const XdgActivationTokenV1 = extern struct {
    activation: *wlr.XdgActivationV1,
    surface: ?*wlr.Surface,
    seat: ?*wlr.Seat,

    serial: ?u32, // Invalid if seat is null
    app_id: ?[*:0]u8,

    link: wl.list.Link,

    // Private state
    token: [*:0]u8,
    resource: ?*wl.Resource,
    timeout: ?*wl.EventSource, // TODO: Not sure about this

    seat_destroy: wl.Listener(*wlr.Seat),
    surface_destroy: wl.Listener(*wlr.Surface),
};
