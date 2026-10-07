const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const xdg = wayland.server.xdg;

pub const XdgToplevelTagManagerV1 = extern struct {
    pub const event = struct {
        pub const SetTag = struct {
            toplevel: *wlr.XdgToplevel,
            tag: [*:0]const u8,
        };

        pub const SetDescription = struct {
            toplevel: *wlr.XdgToplevel,
            description: [*:0]const u8,
        };
    };

    global: *wl.Global,

    events: extern struct {
        set_tag: wl.Signal(*XdgToplevelTagManagerV1.event.SetTag),
        set_description: wl.Signal(*XdgToplevelTagManagerV1.event.SetDescription),
        destroy: wl.Signal(void),
    },

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_xdg_toplevel_tag_manager_v1_create(server: *wl.Server, version: u32) ?*XdgToplevelTagManagerV1;
    pub fn create(server: *wl.Server, version: u32) !*XdgToplevelTagManagerV1 {
        return wlr_xdg_toplevel_tag_manager_v1_create(server, version) orelse error.OutOfMemory;
    }
};
