const os = @import("std").os;

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Device = extern struct {
    fd: c_int,
    dev: os.dev_t,
    signal: wl.Signal(*Session),

    /// Session.devices
    link: wl.list.Link,
};

pub const Session = extern struct {
    const Impl = opaque {};

    impl: *const Impl,
    session_signal: wl.Signal(*Session),
    active: bool,

    vtnr: c_uint,
    seat: [256]u8,

    // TODO: do we need libudev bindings?
    udev: *opaque {},
    udev_monitor: *opaque {},
    udev_event: *wl.EventSource,

    devices: wl.list.Head(Device, "link"),

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        destroy: wl.Signal(*Session),
    },

    extern fn wlr_session_create(server: *wl.Server) ?*Session;
    pub fn create(server: *wl.Server) !*Session {
        return wlr_session_create(server) orelse error.SessionCreateFailed;
    }

    extern fn wlr_session_destroy(session: *Session) void;
    pub const destroy = wlr_session_destroy;

    extern fn wlr_session_open_file(session: *Session, path: [*:0]const u8) c_int;
    pub const openFile = wlr_session_open_file;

    extern fn wlr_session_close_file(session: *Session, fd: c_int) void;
    pub const closeFile = wlr_session_close_file;

    extern fn wlr_session_signal_add(session: *Session, fd: c_int, listener: *wl.Listener(*Session)) void;
    pub const signalAdd = wlr_session_signal_add;

    extern fn wlr_session_change_vt(session: *Session, vt: c_uint) bool;
    pub fn changeVt(session: *Session, vt: c_uint) !void {
        if (!wlr_session_change_vt(session, vt)) return error.ChangeVtFailed;
    }

    extern fn wlr_session_find_gpus(session: *Session, ret_len: usize, ret: [*]c_int) usize;
    pub const findGpus = wlr_session_find_gpus;
};
