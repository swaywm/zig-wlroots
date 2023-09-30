const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Subcompositor = extern struct {
    global: *wl.Global,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        destroy: wl.Signal(*wlr.Compositor),
    },

    extern fn wlr_subcompositor_create(server: *wl.Server) ?*Subcompositor;
    pub fn create(server: *wl.Server) !*Subcompositor {
        return wlr_subcompositor_create(server) orelse error.OutOfMemory;
    }
};

pub const Subsurface = extern struct {
    pub const ParentState = extern struct {
        x: i32,
        y: i32,
        /// wlr.Surface.State.subsurfaces_above/subsurfaces_below
        link: wl.list.Link,
    };

    resource: *wl.Subsurface,
    surface: *wlr.Surface,
    parent: ?*wlr.Surface,

    current: ParentState,
    pending: ParentState,

    cached_seq: u32,
    has_cache: bool,

    synchronized: bool,
    reordered: bool,
    added: bool,

    surface_client_commit: wl.Listener(void),
    parent_destroy: wl.Listener(*wlr.Surface),

    events: extern struct {
        destroy: wl.Signal(*Subsurface),
    },

    data: usize,

    extern fn wlr_subsurface_try_from_wlr_surface(surface: *wlr.Surface) ?*wlr.Subsurface;
    pub const tryFromWlrSurface = wlr_subsurface_try_from_wlr_surface;
};
