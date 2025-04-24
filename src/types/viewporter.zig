const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Viewporter = extern struct {
    global: *wl.Global,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_viewporter_create(server: *wl.Server) ?*Viewporter;
    pub fn create(server: *wl.Server) !*Viewporter {
        return wlr_viewporter_create(server) orelse error.OutOfMemory;
    }
};
