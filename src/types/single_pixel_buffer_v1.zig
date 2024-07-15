const wl = @import("wayland").server.wl;

pub const SinglePixelBufferManagerV1 = extern struct {
    global: *wl.Global,

    // private state

    server_destroy: wl.Listener(*wl.Server),

    extern fn wlr_single_pixel_buffer_manager_v1_create(server: *wl.Server) ?*SinglePixelBufferManagerV1;
    pub fn create(server: *wl.Server) !*SinglePixelBufferManagerV1 {
        return wlr_single_pixel_buffer_manager_v1_create(server) orelse error.OutOfMemory;
    }
};
