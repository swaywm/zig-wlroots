const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Fixes = extern struct {
    global: *wl.Global,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_fixes_create(server: *wl.Server, version: u32) ?*Fixes;
    pub fn create(server: *wl.Server, version: u32) error{OutOfMemory}!*Fixes {
        return wlr_fixes_create(server, version) orelse error.OutOfMemory;
    }
};
