const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const TransientSeatManagerV1 = extern struct {
    global: *wl.Global,

    events: extern struct {
        create_seat: wl.Signal(*TransientSeatV1),
    },

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_transient_seat_manager_v1_create(server: *wl.Server) ?*TransientSeatManagerV1;
    pub fn create(server: *wl.Server) !*TransientSeatManagerV1 {
        return wlr_transient_seat_manager_v1_create(server) orelse error.OutOfMemory;
    }
};

pub const TransientSeatV1 = extern struct {
    resource: *wl.Resource,
    seat: *wlr.Seat,

    private: extern struct {
        seat_destroy: wl.Listener(void),
    },

    extern fn wlr_transient_seat_v1_ready(seat: *TransientSeatV1, wlr_seat: *wlr.Seat) void;
    pub const ready = wlr_transient_seat_v1_ready;

    extern fn wlr_transient_seat_v1_deny(seat: *TransientSeatV1) void;
    pub const deny = wlr_transient_seat_v1_deny;
};
