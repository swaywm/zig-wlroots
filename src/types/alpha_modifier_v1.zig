const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const AlphaModifierV1 = extern struct {
    pub const State = extern struct {
        multiplier: f64,
    };

    global: *wl.Global,

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_alpha_modifier_v1_create(server: *wl.Server) ?*AlphaModifierV1;
    pub fn create(server: *wl.Server) !*AlphaModifierV1 {
        return wlr_alpha_modifier_v1_create(server) orelse error.OutOfMemory;
    }

    extern fn wlr_alpha_modifier_v1_get_surface_state(surface: *wlr.Surface) ?*const State;
    pub const getSurfaceState = wlr_alpha_modifier_v1_get_surface_state;
};
