const os = @import("std").os;

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Device = extern struct {
    pub const event = struct {
        pub const Change = extern struct {
            pub const Type = enum(c_int) {
                hotplug = 1,
                lease,
            };

            type: Type,
            event: extern union {
                hotplug: Hotplug,
            },
        };

        pub const Hotplug = extern struct {
            connector_id: u32,
            prop_id: u32,
        };
    };

    fd: c_int,
    device_id: c_int,
    dev: os.dev_t,
    /// Session.devices
    link: wl.list.Link,

    events: extern struct {
        change: wl.Signal(*event.Change),
        remove: wl.Signal(void),
    },
};

pub const Session = extern struct {
    pub const event = struct {
        pub const Add = extern struct {
            path: [*:0]const u8,
        };
    };

    active: bool,

    vtnr: c_uint,
    seat: [256]u8,

    // TODO: do we need libudev bindings?
    udev: *opaque {},
    udev_monitor: *opaque {},
    udev_event: *wl.EventSource,

    seat_handle: *opaque {},
    libseat_event: *wl.EventSource,

    devices: wl.list.Head(Device, "link"),

    server: *wl.Server,
    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        active: wl.Signal(void),
        add_drm_card: wl.Signal(*event.Add),
        destroy: wl.Signal(*Session),
    },

    extern fn wlr_session_create(server: *wl.Server) ?*Session;
    pub fn create(server: *wl.Server) !*Session {
        return wlr_session_create(server) orelse error.SessionCreateFailed;
    }

    extern fn wlr_session_destroy(session: *Session) void;
    pub const destroy = wlr_session_destroy;

    extern fn wlr_session_open_file(session: *Session, path: [*:0]const u8) ?*Device;
    pub fn openFile(session: *Session, path: [*:0]const u8) !*Device {
        return wlr_session_open_file(session, path) orelse error.SessionOpenFileFailed;
    }

    extern fn wlr_session_close_file(session: *Session, device: *Device) void;
    pub const closeFile = wlr_session_close_file;

    extern fn wlr_session_change_vt(session: *Session, vt: c_uint) bool;
    pub fn changeVt(session: *Session, vt: c_uint) !void {
        if (!wlr_session_change_vt(session, vt)) return error.ChangeVtFailed;
    }

    extern fn wlr_session_find_gpus(session: *Session, ret_len: usize, ret: [*]*Device) isize;
    pub const findGpus = wlr_session_find_gpus;
};
