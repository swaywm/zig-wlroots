const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const wp = wayland.server.wp;

pub const ContentTypeManagerV1 = extern struct {
    global: *wl.Global,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    data: ?*anyopaque,

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_content_type_manager_v1_create(server: *wl.Server, version: u32) ?*ContentTypeManagerV1;
    pub fn create(server: *wl.Server, version: u32) !*ContentTypeManagerV1 {
        return wlr_content_type_manager_v1_create(server, version) orelse error.OutOfMemory;
    }

    extern fn wlr_surface_get_content_type_v1(manager: *ContentTypeManagerV1, surface: *wlr.Surface) wp.ContentTypeV1.Type;
    pub const get = wlr_surface_get_content_type_v1;
};
