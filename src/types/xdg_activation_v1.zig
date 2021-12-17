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
        request_activate: wl.Signal(*XdgActivationV1.event.RequestActivate),
    },

    // Private state

    server: *wl.Server,

    global: *wl.Global,

    server_destroy: wl.Listener(*wl.Server),

    extern fn wlr_xdg_activation_v1_create(server: *wl.Server) ?*XdgActivationV1;
    pub fn create(server: *wl.Server) !*XdgActivationV1 {
        return wlr_xdg_activation_v1_create(server) orelse error.OutOfMemory;
    }

    extern fn wlr_xdg_activation_token_v1_create(activation: *XdgActivationV1) ?*XdgActivationTokenV1;
    pub const createToken = wlr_xdg_activation_token_v1_create;

    extern fn wlr_xdg_activation_v1_find_token(activation: *XdgActivationV1, token_str: [*:0]const u8) ?*XdgActivationTokenV1;
    pub const findToken = wlr_xdg_activation_v1_find_token;

    extern fn wlr_xdg_activation_v1_add_token(activation: *XdgActivationV1, token_str: [*:0]const u8) ?*XdgActivationTokenV1;
    pub const addToken = wlr_xdg_activation_v1_add_token;
};

pub const XdgActivationTokenV1 = extern struct {
    activation: *wlr.XdgActivationV1,
    surface: ?*wlr.Surface,
    seat: ?*wlr.Seat,

    /// Invalid if seat is null
    serial: u32,
    app_id: ?[*:0]u8,

    link: wl.list.Link,

    data: usize,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    // Private state
    token: [*:0]u8,
    resource: ?*wl.Resource,
    timeout: ?*wl.EventSource,

    seat_destroy: wl.Listener(*wlr.Seat),
    surface_destroy: wl.Listener(*wlr.Surface),

    extern fn wlr_xdg_activation_token_v1_destroy(token: *XdgActivationTokenV1) void;
    pub const destroy = wlr_xdg_activation_token_v1_destroy;

    extern fn wlr_xdg_activation_token_v1_get_name(token: *XdgActivationTokenV1) [*:0]const u8;
    pub const name = wlr_xdg_activation_token_v1_get_name;
};
