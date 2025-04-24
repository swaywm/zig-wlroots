const wlr = @import("../wlroots.zig");

const pixman = @import("pixman");

const std = @import("std");
const wayland = @import("wayland");
const wl = wayland.server.wl;
const zwp = wayland.server.zwp;

pub const PointerConstraintV1 = extern struct {
    pub const State = extern struct {
        pub const Fields = packed struct(u32) {
            region: bool = false,
            cursor_hint: bool = false,
            _: u30 = 0,
        };

        committed: Fields,
        region: pixman.Region32,

        cursor_hint: extern struct {
            enabled: bool,
            x: f64,
            y: f64,
        },
    };
    pub const Type = enum(c_int) {
        locked,
        confined,
    };

    pointer_constraints: *PointerConstraintsV1,

    resource: *wl.Resource,
    surface: *wlr.Surface,
    seat: *wlr.Seat,
    lifetime: zwp.PointerConstraintsV1.Lifetime,
    type: Type,
    region: pixman.Region32,

    current: State,
    pending: State,

    link: wl.list.Link,

    events: extern struct {
        set_region: wl.Signal(void),
        destroy: wl.Signal(*PointerConstraintV1),
    },

    data: ?*anyopaque,

    private: extern struct {
        surface_destroy: wl.Listener(void),
        seat_destroy: wl.Listener(void),

        synced: wlr.Surface.Synced,

        destroying: bool,
    },

    extern fn wlr_pointer_constraint_v1_send_activated(constraint: *PointerConstraintV1) void;
    pub const sendActivated = wlr_pointer_constraint_v1_send_activated;

    extern fn wlr_pointer_constraint_v1_send_deactivated(constraint: *PointerConstraintV1) void;
    pub const sendDeactivated = wlr_pointer_constraint_v1_send_deactivated;
};

pub const PointerConstraintsV1 = extern struct {
    global: *wl.Global,
    constraints: wl.list.Head(PointerConstraintV1, .link),

    events: extern struct {
        destroy: wl.Signal(void),
        new_constraint: wl.Signal(*PointerConstraintV1),
    },

    data: ?*anyopaque,

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_pointer_constraints_v1_create(server: *wl.Server) ?*PointerConstraintsV1;
    pub fn create(server: *wl.Server) !*PointerConstraintsV1 {
        return wlr_pointer_constraints_v1_create(server) orelse error.OutOfMemory;
    }

    extern fn wlr_pointer_constraints_v1_constraint_for_surface(pointer_constraints: *PointerConstraintsV1, surface: *wlr.Surface, seat: *wlr.Seat) ?*PointerConstraintV1;
    pub const constraintForSurface = wlr_pointer_constraints_v1_constraint_for_surface;
};
