const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const zwp = wayland.server.zwp;

pub const FullscreenShellV1 = extern struct {
    pub const event = struct {
        pub const PresentSurface = extern struct {
            client: *wl.Client,
            surface: ?*wlr.Surface,
            method: zwp.FullscreenShellV1.PresentMethod,
            output: ?*wlr.Output,
        };
    };

    global: *wl.Global,

    events: extern struct {
        destroy: wl.Signal(*wlr.FullscreenShellV1),
        present_surface: wl.Signal(*wlr.FullscreenShellV1.event.PresentSurface),
    },

    server_destroy: wl.Listener(*wl.Server),

    data: usize,

    extern fn wlr_fullscreen_shell_v1_create(server: *wl.Server) ?*wlr.FullscreenShellV1;
    pub fn create(server: *wl.Server) !*wlr.FullscreenShellV1 {
        return wlr_fullscreen_shell_v1_create(server) orelse error.OutOfMemory;
    }
};
