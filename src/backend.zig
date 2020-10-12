const wlr = @import("wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Backend = extern struct {
    const Impl = opaque {};

    impl: *const Impl,
    events: extern struct {
        destroy: wl.Signal,
        new_input: wl.Signal,
        new_output: wl.Signal,
    },

    extern fn wlr_backend_autocreate(server: *wl.Server, create_renderer_func: ?wlr.Renderer.CreateFn) ?*Backend;
    pub const autocreate = wlr_backend_autocreate;

    extern fn wlr_backend_start(backend: *Backend) bool;
    pub const start = wlr_backend_start;

    extern fn wlr_backend_destroy(backend: *Backend) void;
    pub const destroy = wlr_backend_destroy;

    extern fn wlr_backend_get_renderer(backend: *Backend) ?*wlr.Renderer;
    pub const getRenderer = wlr_backend_get_renderer;

    extern fn wlr_backend_get_session(backend: *Backend) ?*wlr.Session;
    pub const getSession = wlr_backend_get_session;
};
