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
        callback: *const fn (backend: *Backend, data: ?*anyopaque) callconv(.C) void,
        data: ?*anyopaque,
    ) void;
    pub const multiForEachBackend = wlr_multi_for_each_backend;

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
};
