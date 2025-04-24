const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Drm = extern struct {
    global: *wl.Global,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    private: extern struct {
        node_name: ?[*:0]u8,
        formats: wlr.DrmFormatSet,
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_drm_create(server: *wl.Server, renderer: *wlr.Renderer) ?*Drm;
    pub fn create(server: *wl.Server, renderer: *wlr.Renderer) !*Drm {
        return wlr_drm_create(server, renderer) orelse error.WlrDrmCreateFailed;
    }
};
