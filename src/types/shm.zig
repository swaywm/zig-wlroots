const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Shm = extern struct {
    global: *wl.Global,

    private: extern struct {
        formats: ?[*]u32,
        formats_len: usize,

        server_destroy: wl.Listener(void),
    },

    extern fn wlr_shm_create(server: *wl.Server, version: u32, formats: [*]const u32, formats_len: usize) ?*Shm;
    pub fn create(server: *wl.Server, version: u32, formats: []const u32) error{OutOfMemory}!*Shm {
        return wlr_shm_create(server, version, formats.ptr, formats.len) orelse error.OutOfMemory;
    }

    extern fn wlr_shm_create_with_renderer(server: *wl.Server, version: u32, renderer: *wlr.Renderer) ?*Shm;
    pub fn createWithRenderer(server: *wl.Server, version: u32, renderer: *wlr.Renderer) error{OutOfMemory}!*Shm {
        return wlr_shm_create_with_renderer(server, version, renderer) orelse error.OutOfMemory;
    }
};
