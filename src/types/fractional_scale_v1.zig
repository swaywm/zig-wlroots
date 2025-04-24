const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const FractionalScaleManagerV1 = extern struct {
    global: *wl.Global,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_fractional_scale_manager_v1_create(server: *wl.Server, version: u32) ?*FractionalScaleManagerV1;
    pub fn create(server: *wl.Server, version: u32) !*FractionalScaleManagerV1 {
        return wlr_fractional_scale_manager_v1_create(server, version) orelse error.OutOfMemory;
    }

    extern fn wlr_fractional_scale_v1_notify_scale(surface: *wlr.Surface, scale: f64) void;
    pub const notifyScale = wlr_fractional_scale_v1_notify_scale;
};
