const wlr = @import("../wlroots.zig");

const std = @import("std");
const os = std.os;

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const XwaylandShellV1 = extern struct {
    global: *wl.Global,

    events: extern struct {
        destroy: wl.Signal(void),
        new_surface: wl.Signal(*XwaylandSurfaceV1),
    },

    private: extern struct {
        client: *wl.Client,
        surfaces: wl.list.Link,

        server_destroy: wl.Listener(void),
        client_destroy: wl.Listener(void),
    },

    extern fn wlr_xwayland_shell_v1_create(server: *wl.Server, version: u32) ?*XwaylandShellV1;
    pub fn create(server: *wl.Server, version: u32) !*XwaylandShellV1 {
        return wlr_xwayland_shell_v1_create(server, version) orelse error.OutOfMemory;
    }

    extern fn wlr_xwayland_shell_v1_destroy(shell: *XwaylandShellV1) void;
    pub const destroy = wlr_xwayland_shell_v1_destroy;

    extern fn wlr_xwayland_shell_v1_set_client(shell: *XwaylandShellV1, client: ?*wl.Client) void;
    pub const setClient = wlr_xwayland_shell_v1_set_client;

    extern fn wlr_xwayland_shell_v1_surface_from_serial(shell: *XwaylandShellV1, serial: u64) ?*wlr.Surface;
    pub const surfaceFromSerial = wlr_xwayland_shell_v1_surface_from_serial;
};

pub const XwaylandSurfaceV1 = extern struct {
    surface: *wlr.Surface,
    serial: u64,

    private: extern struct {
        resource: *wl.Resource,
        link: wl.list.Link,
        shell: *wlr.XwaylandShellV1,
        added: bool,
    },
};
