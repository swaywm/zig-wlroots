const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const RelativePointerManagerV1 = extern struct {
    global: *wl.Global,
    relative_pointers: wl.list.Head(RelativePointerV1, "link"),

    events: extern struct {
        destroy: wl.Signal(*RelativePointerManagerV1),
        new_relative_pointer: wl.Signal(*RelativePointerV1),
    },

    server_destroy: wl.Listener(*wl.Server),

    data: usize,

    extern fn wlr_relative_pointer_manager_v1_create(server: *wl.Server) ?*RelativePointerManagerV1;
    pub fn create(server: *wl.Server) !*RelativePointerManagerV1 {
        return wlr_relative_pointer_manager_v1_create(server) orelse error.OutOfMemory;
    }

    extern fn wlr_relative_pointer_manager_v1_send_relative_motion(
        manager: *RelativePointerManagerV1,
        seat: *wlr.Seat,
        time_usec: u64,
        dx: f64,
        dy: f64,
        dx_unaccel: f64,
        dy_unaccel: f64,
    ) void;
    pub const sendRelativeMotion = wlr_relative_pointer_manager_v1_send_relative_motion;
};

pub const RelativePointerV1 = extern struct {
    resource: *wl.Resource,
    pointer_resource: *wl.Resource,
    seat: *wlr.Seat,
    link: wl.list.Link,

    events: extern struct {
        destroy: wl.Signal(*RelativePointerV1),
    },

    seat_destroy: wl.Listener(*wlr.Seat),
    pointer_destroy: wl.Listener(*wlr.Pointer),

    data: usize,

    extern fn wlr_relative_pointer_v1_from_resource(resource: *wl.Resource) ?*RelativePointerV1;
    pub const fromResource = wlr_relative_pointer_v1_from_resource;
};
