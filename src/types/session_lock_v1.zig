const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const ext = wayland.server.ext;

pub const SessionLockManagerV1 = extern struct {
    global: *wl.Global,

    events: extern struct {
        new_lock: wl.Signal(*SessionLockV1),
        destroy: wl.Signal(void),
    },

    data: usize,

    // private state

    server_destroy: wl.Listener(*wl.Server),

    extern fn wlr_session_lock_manager_v1_create(server: *wl.Server) ?*SessionLockManagerV1;
    pub fn create(server: *wl.Server) !*SessionLockManagerV1 {
        return wlr_session_lock_manager_v1_create(server) orelse error.OutOfMemory;
    }
};

pub const SessionLockV1 = extern struct {
    resource: *ext.SessionLockV1,

    surfaces: wl.list.Head(SessionLockSurfaceV1, .link),

    events: extern struct {
        new_surface: wl.Signal(*SessionLockSurfaceV1),
        unlock: wl.Signal(void),
        destroy: wl.Signal(void),
    },

    data: usize,

    // private state

    locked_sent: bool,

    extern fn wlr_session_lock_v1_send_locked(lock: *SessionLockV1) void;
    pub const sendLocked = wlr_session_lock_v1_send_locked;

    extern fn wlr_session_lock_v1_destroy(lock: *SessionLockV1) void;
    pub const destroy = wlr_session_lock_v1_destroy;
};

pub const SessionLockSurfaceV1 = extern struct {
    pub const State = extern struct {
        width: u32,
        height: u32,
        configure_serial: u32,
    };

    pub const Configure = extern struct {
        /// SessionLockSurfaceV1.configure_list
        link: wl.list.Link,
        serial: u32,
        width: u32,
        height: u32,
    };

    resource: *ext.SessionLockSurfaceV1,
    /// SessionLockV1.surfaces
    link: wl.list.Link,

    output: *wlr.Output,
    surface: *wlr.Surface,

    configured: bool,

    configure_list: wl.list.Head(Configure, .link),

    current: State,
    pending: State,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    data: usize,

    // private state

    output_destroy: wl.Listener(*wlr.Output),

    extern fn wlr_session_lock_surface_v1_configure(lock_surface: *SessionLockSurfaceV1, width: u32, height: u32) u32;
    pub const configure = wlr_session_lock_surface_v1_configure;

    extern fn wlr_session_lock_surface_v1_try_from_wlr_surface(surface: *wlr.Surface) ?*SessionLockSurfaceV1;
    pub const tryFromWlrSurface = wlr_session_lock_surface_v1_try_from_wlr_surface;
};
