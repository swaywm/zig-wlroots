const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const ServerDecorationManager = extern struct {
    pub const Mode = enum(c_int) {
        none = 0,
        client = 1,
        server = 2,
    };

    global: *wl.Global,
    resources: wl.list.Head(wl.Resource, "link"),
    decorations: wl.list.Head(ServerDecoration, "link"),

    default_mode: Mode,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        new_decoration: wl.Signal(*ServerDecoration),
        destroy: wl.Signal(*ServerDecorationManager),
    },

    data: usize,

    extern fn wlr_server_decoration_manager_create(server: *wl.Server) ?*ServerDecorationManager;
    pub fn create(server: *wl.Server) !*ServerDecorationManager {
        return wlr_server_decoration_manager_create(server) orelse error.OutOfMemory;
    }

    extern fn wlr_server_decoration_manager_set_default_mode(manager: *ServerDecorationManager, default_mode: Mode) void;
    pub const setDefaultMode = wlr_server_decoration_manager_set_default_mode;
};

pub const ServerDecoration = extern struct {
    resource: *wl.Resource,
    surface: *wlr.Surface,
    link: wl.list.Link,

    mode: ServerDecorationManager.Mode,

    events: extern struct {
        destroy: wl.Signal(*ServerDecoration),
        mode: wl.Signal(*ServerDecoration),
    },

    surface_destroy: wl.Listener(*wlr.Surface),

    data: usize,
};
