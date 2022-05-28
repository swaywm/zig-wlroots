const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const VirtualPointerManagerV1 = extern struct {
    pub const event = struct {
        pub const NewPointer = extern struct {
            new_pointer: *VirtualPointerV1,
            suggested_seat: ?*wlr.Seat,
            suggested_output: ?*wlr.Output,
        };
    };

    global: *wl.Global,
    virtual_pointers: wl.list.Head(VirtualPointerV1, "link"),

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        new_virtual_pointer: wl.Signal(*event.NewPointer),
        destroy: wl.Signal(*VirtualPointerManagerV1),
    },

    extern fn wlr_virtual_pointer_manager_v1_create(server: *wl.Server) ?*VirtualPointerManagerV1;
    pub fn create(server: *wl.Server) !*VirtualPointerManagerV1 {
        return wlr_virtual_pointer_manager_v1_create(server) orelse error.OutOfMemory;
    }
};

pub const VirtualPointerV1 = extern struct {
    pointer: wlr.Pointer,
    resource: *wl.Resource,

    axis_event: [2]wlr.Pointer.event.Axis,
    axis: wl.Pointer.Axis,
    axis_valid: [2]bool,

    /// VirtualPointerManagerV1.virtual_pointers
    link: wl.list.Link,
};
