const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Subcompositor = extern struct {
    global: *wl.Global,
};

pub const Compositor = extern struct {
    global: *wl.Global,
    renderer: *wlr.Renderer,

    subcompositor: Subcompositor,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        new_surface: wl.Signal(*wlr.Surface),
        destroy: wl.Signal(*wlr.Compositor),
    },

    extern fn wlr_compositor_create(server: *wl.Server, renderer: *wlr.Renderer) ?*Compositor;
    pub fn create(server: *wl.Server, renderer: *wlr.Renderer) !*Compositor {
        return wlr_compositor_create(server, renderer) orelse error.OutOfMemory;
    }
};
