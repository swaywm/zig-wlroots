const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const wp = wayland.server.wp;

pub const ColorRepresentationManagerV1 = extern struct {
    pub const CoeffsAndRange = extern struct {
        coeffs: wp.ColorRepresentationSurfaceV1.Coefficients,
        range: wp.ColorRepresentationSurfaceV1.Range,
    };

    pub const Options = extern struct {
        supported_alpha_modes: ?[*]const wp.ColorRepresentationSurfaceV1.AlphaMode,
        supported_alpha_modes_len: usize,
        supported_coeffs_and_ranges: ?[*]const CoeffsAndRange,
        supported_coeffs_and_ranges_len: usize,
    };

    global: *wl.Global,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    private: extern struct {
        supported_alpha_modes: ?[*]wp.ColorRepresentationSurfaceV1.AlphaMode,
        supported_alpha_modes_len: usize,
        supported_coeffs_and_ranges: ?[*]CoeffsAndRange,
        supported_coeffs_and_ranges_len: usize,
        display_destroy: wl.Listener(void),
    },

    extern fn wlr_color_representation_manager_v1_create(server: *wl.Server, version: u32, options: *const Options) ?*ColorRepresentationManagerV1;
    pub fn create(server: *wl.Server, version: u32, options: *const Options) error{ColorRepresentationManagerV1CreateFailed}!*ColorRepresentationManagerV1 {
        return wlr_color_representation_manager_v1_create(server, version, options) orelse error.ColorRepresentationManagerV1CreateFailed;
    }

    extern fn wlr_color_representation_manager_v1_create_with_renderer(server: *wl.Server, version: u32, renderer: *wlr.Renderer) ?*ColorRepresentationManagerV1;
    pub fn createWithRenderer(server: *wl.Server, version: u32, renderer: *wlr.Renderer) error{ColorRepresentationManagerV1CreateFailed}!*ColorRepresentationManagerV1 {
        return wlr_color_representation_manager_v1_create_with_renderer(server, version, renderer) orelse error.ColorRepresentationManagerV1CreateFailed;
    }
};
