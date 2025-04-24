const wlr = @import("../wlroots.zig");

const std = @import("std");
const posix = std.posix;

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const XwaylandServer = extern struct {
    pub const Options = extern struct {
        lazy: bool,
        enable_wm: bool,
        no_touch_pointer_emulation: bool,
        force_xrandr_emulation: bool,
        terminate_delay: c_int,
    };

    pub const event = struct {
        pub const Ready = extern struct {
            server: *XwaylandServer,
            wm_fd: c_int,
        };
    };

    pid: posix.pid_t,
    client: ?*wl.Client,
    pipe_source: ?*wl.EventSource,
    wm_fd: [2]c_int,
    wl_fd: [2]c_int,
    ready: bool,

    server_start: posix.time_t,
    display: c_int,
    display_name: [16]u8,
    x_fd: [2]c_int,
    x_fd_read_event: [2]?*wl.EventSource,
    options: Options,

    wl_server: *wl.Server,

    events: extern struct {
        ready: wl.Signal(*event.Ready),
        destroy: wl.Signal(void),
    },

    data: ?*anyopaque,

    private: extern struct {
        client_destroy: wl.Listener(void),
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_xwayland_server_create(server: *wl.Server, options: *Options) ?*XwaylandServer;
    pub fn create(server: *wl.Server, options: *Options) !*XwaylandServer {
        return wlr_xwayland_server_create(server, options) orelse error.XwaylandServerCreateFailed;
    }

    extern fn wlr_xwayland_server_destroy(server: *XwaylandServer) void;
    pub const destroy = wlr_xwayland_server_destroy;
};
