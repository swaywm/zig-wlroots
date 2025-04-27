const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const LinuxDrmSyncobjManagerV1 = extern struct {
    global: *wl.Global,

    private: extern struct {
        drm_fd: c_int,
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_linux_drm_syncobj_manager_v1_create(server: *wl.Server, version: u32, drm_fd: c_int) ?*LinuxDrmSyncobjManagerV1;
    pub const create = wlr_linux_drm_syncobj_manager_v1_create;
};
