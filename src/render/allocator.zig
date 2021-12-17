const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Allocator = extern struct {
    pub const Interface = extern struct {
        create_buffer: fn (alloc: *wlr.Allocator, width: c_int, height: c_int, format: *const wlr.DrmFormat) callconv(.C) ?*wlr.Buffer,
        destroy: fn (alloc: *wlr.Allocator) callconv(.C) void,
    };

    impl: *const Interface,

    buffer_caps: u32,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    extern fn wlr_allocator_init(alloc: *Allocator, impl: *const Interface, buffer_caps: u32) void;
    pub const init = wlr_allocator_init;

    extern fn wlr_allocator_autocreate(backend: *wlr.Backend, renderer: *wlr.Renderer) ?*Allocator;
    pub fn autocreate(backend: *wlr.Backend, renderer: *wlr.Renderer) !*Allocator {
        return wlr_allocator_autocreate(backend, renderer) orelse error.AllocatorCreateFailed;
    }

    extern fn wlr_allocator_destroy(alloc: *Allocator) void;
    pub const destroy = wlr_allocator_destroy;

    extern fn wlr_allocator_create_buffer(alloc: *Allocator, width: c_int, height: c_int, format: *const wlr.DrmFormat) ?*wlr.Buffer;
    pub const createBuffer = wlr_allocator_create_buffer;
};
