const wlr = @import("wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Backend = extern struct {
    const Impl = opaque {};

    pub const OutputState = extern struct {
        output: *wlr.Output,
        base: wlr.Output.State,
    };

    impl: *const Impl,

    buffer_caps: u32,

    features: extern struct {
        timeline: bool,
    },

    events: extern struct {
        destroy: wl.Signal(*Backend),
        new_input: wl.Signal(*wlr.InputDevice),
        new_output: wl.Signal(*wlr.Output),
    },

    // backend.h

    extern fn wlr_backend_autocreate(loop: *wl.EventLoop, session_ptr: ?*?*wlr.Session) ?*Backend;
    pub fn autocreate(loop: *wl.EventLoop, session_ptr: ?*?*wlr.Session) !*Backend {
        return wlr_backend_autocreate(loop, session_ptr) orelse error.BackendCreateFailed;
    }

    extern fn wlr_backend_start(backend: *Backend) bool;
    pub fn start(backend: *Backend) !void {
        if (!wlr_backend_start(backend)) {
            return error.BackendStartFailed;
        }
    }

    extern fn wlr_backend_destroy(backend: *Backend) void;
    pub const destroy = wlr_backend_destroy;

    extern fn wlr_backend_get_drm_fd(backend: *Backend) c_int;
    pub const getDrmFd = wlr_backend_get_drm_fd;

    extern fn wlr_backend_test(backend: *Backend, states: [*]const OutputState, states_len: usize) bool;
    pub inline fn @"test"(backend: *Backend, states: []const OutputState) bool {
        return wlr_backend_test(backend, states.ptr, states.len);
    }

    extern fn wlr_backend_commit(backend: *Backend, states: [*]const OutputState, states_len: usize) bool;
    pub inline fn commit(backend: *Backend, states: []const OutputState) bool {
        return wlr_backend_commit(backend, states.ptr, states.len);
    }

    // backend/drm.h

    const DrmBackend = opaque {};

    pub const DrmLease = extern struct {
        fd: c_int,
        lessee_id: u32,
        backend: *DrmBackend,
        events: extern struct {
            destroy: wl.Signal(void),
        },
        data: ?*anyopaque,

        extern fn wlr_drm_lease_terminate(lease: *DrmLease) void;
        pub const terminate = wlr_drm_lease_terminate;
    };

    extern fn wlr_drm_backend_create(session: *wlr.Session, dev: *wlr.Device, parent: *wlr.Backend) ?*wlr.Backend;
    pub fn createDrm(session: *wlr.Session, dev: *wlr.Device, parent: *wlr.Backend) !*wlr.Backend {
        return wlr_drm_backend_create(session, dev, parent) orelse error.BackendCreateFailed;
    }

    extern fn wlr_backend_is_drm(backend: *wlr.Backend) bool;
    pub const isDrm = wlr_backend_is_drm;

    extern fn wlr_drm_backend_get_parent(backend: *wlr.Backend) ?*wlr.Backend;
    pub const drmGetParent = wlr_drm_backend_get_parent;

    extern fn wlr_drm_backend_get_non_master_fd(backend: *wlr.Backend) c_int;
    pub fn drmGetNonMasterFd(backend: *wlr.Backend) !c_int {
        const fd = wlr_drm_backend_get_non_master_fd(backend);
        return if (fd == -1) error.GetNonMasterFdFailed else fd;
    }

    // backend/multi.h

    extern fn wlr_multi_backend_create(loop: *wl.EventLoop) ?*Backend;
    pub fn createMulti(loop: *wl.EventLoop) !*Backend {
        return wlr_multi_backend_create(loop) orelse error.BackendCreateFailed;
    }

    extern fn wlr_multi_backend_add(multi: *Backend, backend: *Backend) bool;
    pub const multiAdd = wlr_multi_backend_add;

    extern fn wlr_multi_backend_remove(multi: *Backend, backend: *Backend) void;
    pub const multiRemove = wlr_multi_backend_remove;

    extern fn wlr_backend_is_multi(backend: *Backend) bool;
    pub const isMulti = wlr_backend_is_multi;

    extern fn wlr_multi_is_empty(backend: *Backend) bool;
    pub const multiIsEmpty = wlr_multi_is_empty;

    extern fn wlr_multi_for_each_backend(
        backend: *Backend,
        callback: *const fn (backend: *Backend, data: ?*anyopaque) callconv(.c) void,
        data: ?*anyopaque,
    ) void;
    pub inline fn multiForEachBackend(
        backend: *Backend,
        comptime T: type,
        comptime callback: fn (backend: *Backend, data: T) void,
        data: T,
    ) void {
        wlr_multi_for_each_backend(
            backend,
            struct {
                fn wrapper(b: *Backend, d: ?*anyopaque) callconv(.c) void {
                    callback(b, @ptrCast(@alignCast(d)));
                }
            }.wrapper,
            data,
        );
    }

    // backend/headless.h

    extern fn wlr_headless_backend_create(loop: *wl.EventLoop) ?*Backend;
    pub fn createHeadless(loop: *wl.EventLoop) !*Backend {
        return wlr_headless_backend_create(loop) orelse error.BackendCreateFailed;
    }

    extern fn wlr_headless_add_output(headless: *Backend, width: c_uint, height: c_uint) ?*wlr.Output;
    pub fn headlessAddOutput(headless: *Backend, width: c_uint, height: c_uint) !*wlr.Output {
        return wlr_headless_add_output(headless, width, height) orelse error.OutOfMemory;
    }

    extern fn wlr_backend_is_headless(backend: *Backend) bool;
    pub const isHeadless = wlr_backend_is_headless;

    // backend/wayland.h

    extern fn wlr_wl_backend_create(loop: *wl.EventLoop, remote_server: ?*wl.Server) ?*Backend;
    pub fn createWl(loop: *wl.EventLoop, remote_server: ?*wl.Server) !*Backend {
        return wlr_wl_backend_create(loop, remote_server) orelse error.BackendCreateFailed;
    }

    extern fn wlr_wl_backend_get_remote_display(wayland_backend: *Backend) *wl.Server;
    pub const wlGetRemoteServer = wlr_wl_backend_get_remote_display;

    extern fn wlr_wl_output_create(wl_backend: *Backend) ?*wlr.Output;
    pub fn wlOuputCreate(wayland_backend: *Backend) !*wlr.Output {
        return wlr_wl_output_create(wayland_backend) orelse error.OutOfMemory;
    }

    extern fn wlr_wl_output_create_from_surface(wayland_backend: *Backend, wl_surface: *wayland.client.wl.Surface) *wlr.Output;
    pub const wlOutputCreateFromSurface = wlr_wl_output_create_from_surface;

    extern fn wlr_backend_is_wl(wayland_backend: *Backend) bool;
    pub const isWl = wlr_backend_is_wl;

    // backend/x11.h

    extern fn wlr_x11_backend_create(loop: *wl.EventLoop, x11_display: [*:0]const u8) ?*Backend;
    pub fn createX11(loop: *wl.EventLoop, x11_display: [*:0]const u8) !*Backend {
        return wlr_x11_backend_create(loop, x11_display) orelse error.BackendCreateFailed;
    }

    extern fn wlr_x11_output_create(x11: *Backend) ?*wlr.Output;
    pub fn x11OutputCreate(x11: *Backend) !*wlr.Output {
        return wlr_x11_output_create(x11) orelse error.OutOfMemory;
    }

    extern fn wlr_backend_is_x11(x11: *Backend) bool;
    pub const isX11 = wlr_backend_is_x11;
};
