const wlr = @import("wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Backend = extern struct {
    const Impl = opaque {};

    impl: *const Impl,
    events: extern struct {
        destroy: wl.Signal(*Backend),
        new_input: wl.Signal(*wlr.InputDevice),
        new_output: wl.Signal(*wlr.Output),
    },

    // backend.h

    extern fn wlr_backend_autocreate(server: *wl.Server) ?*Backend;
    pub fn autocreate(server: *wl.Server) !*Backend {
        return wlr_backend_autocreate(server) orelse error.BackendCreateFailed;
    }

    extern fn wlr_backend_start(backend: *Backend) bool;
    pub fn start(backend: *Backend) !void {
        if (!wlr_backend_start(backend)) {
            return error.BackendStartFailed;
        }
    }

    extern fn wlr_backend_destroy(backend: *Backend) void;
    pub const destroy = wlr_backend_destroy;

    extern fn wlr_backend_get_session(backend: *Backend) ?*wlr.Session;
    pub const getSession = wlr_backend_get_session;

    extern fn wlr_backend_get_drm_fd(backend: *Backend) c_int;
    pub const getDrmFd = wlr_backend_get_drm_fd;

    // backend/multi.h

    extern fn wlr_multi_backend_create(server: *wl.Server) ?*Backend;
    pub fn createMulti(server: *wl.Server) !*Backend {
        return wlr_multi_backend_create(server) orelse error.BackendCreateFailed;
    }

    extern fn wlr_multi_backend_add(multi: *Backend, backend: *Backend) bool;
    pub const multiAdd = wlr_multi_backend_add;

    extern fn wlr_multi_backend_remove(multi: *Backend, backend: *Backend) void;
    pub const multiRemove = wlr_multi_backend_remove;

    extern fn wlr_backend_is_multi(backend: *Backend) bool;
    pub const isMulti = wlr_backend_is_multi;

    extern fn wlr_multi_is_empty(backend: *Backend) bool;
    pub const multiIsEmpty = wlr_multi_is_empty;

    extern fn wlr_multi_for_each_backend(backend: *Backend, callback: fn (backend: *Backend, data: ?*anyopaque) callconv(.C) void, data: ?*anyopaque) void;
    pub const multiForEachBackend = wlr_multi_for_each_backend;

    // backend/headless.h

    extern fn wlr_headless_backend_create(server: *wl.Server) ?*Backend;
    pub fn createHeadless(server: *wl.Server) !*Backend {
        return wlr_headless_backend_create(server) orelse error.BackendCreateFailed;
    }

    extern fn wlr_headless_add_output(headless: *Backend) ?*wlr.Output;
    pub fn headlessAddOutput(headless: *Backend) !*wlr.Output {
        return wlr_headless_add_output(headless) orelse error.OutOfMemory;
    }

    extern fn wlr_headless_add_input_device(headless: *Backend) ?*wlr.InputDevice;
    pub fn headlessAddInputDevice(headless: *Backend) !*wlr.InputDevice {
        return wlr_headless_add_input_device(headless) orelse error.OutOfMemory;
    }

    extern fn wlr_backend_is_headless(backend: *Backend) bool;
    pub const isHeadless = wlr_backend_is_headless;
};
