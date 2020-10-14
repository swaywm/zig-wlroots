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

    display_destroy: wl.Listener,

    events: extern struct {
        new_surface: wl.Signal,
        destroy: wl.Signal,
    },

    extern fn wlr_compositor_create(server: *wl.Server, renderer: *wlr.Renderer) ?*Compositor;
    pub const create = wlr_compositor_create;
};
