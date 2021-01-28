const wlr = @import("../wlroots.zig");

const pixman = @import("pixman");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const zpointer = wayland.server.zpointer;

pub const PointerConstraint = extern struct {
    pub const State = extern struct {
        pub const field = struct {
            pub const region = 1 << 0;
            pub const cursor_hint = 1 << 1;
        };

        committed: u32,
        region: pixman.Region32,

        // only valid for locked_pointer
        cursor_hint: extern struct {
          x: f64,
          y: f64,
        },
    };
    pub const Type = extern enum {
        locked,
        confined,
    };

    pointer_constraints: *PointerConstraints,

    resource: *wl.Resource,
    surface: *wlr.Surface,
    seat: *wlr.Seat,
    lifetime: zpointer.PointerConstraintsV1.Lifetime,
    type: Type,
    region: pixman.Region32,

    current: State,
    pending: State,

    surface_commit: wl.Listener(*wlr.Surface),
    surface_destroy: wl.Listener(*wlr.Surface),
    seat_destroy: wl.Listener(*wl.Seat),

    link: wl.list.Link,

    events: extern struct {
        set_region: wl.Signal(*PointerConstraint),
        destroy: wl.Signal(*PointerConstraint),
    },

    data: usize,

    extern fn wlr_pointer_constraint_v1_send_activated(constraint: *PointerConstraint) void;
    pub const sendActivated = wlr_pointer_constraint_v1_send_activated;

    extern fn wlr_pointer_constraint_v1_send_deactivated(constraint: *PointerConstraint) void;
    pub const sendDeactivated = wlr_pointer_constraint_v1_send_deactivated;
};

pub const PointerConstraints = extern struct {
    global: *wl.Global,
    constraints: wl.list.Head(PointerConstraint, "link"),

    events: extern struct {
        new_constraint: wl.Signal(*PointerConstraint),
    },

    server_destroy: wl.Listener(*wl.Server),

    data: usize,

    extern fn wlr_pointer_constraints_v1_create(server: *wl.Server) ?*PointerConstraints;
    pub fn create(server: *wl.Server) !*PointerConstraints {
        return wlr_pointer_constraints_v1_create(server) orelse error.OutOfMemory;
    }

    extern fn wlr_pointer_constraints_v1_constraint_for_surface(pointer_constraints: *PointerConstraints, surface: *wlr.Surface, seat: *wlr.Seat) ?*wlr_pointer_constraint_v1;
    pub const constraintForSurface = wlr_pointer_constraints_v1_constraint_for_surface;
};
