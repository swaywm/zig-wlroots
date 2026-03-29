const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const wp = wayland.server.wp;

pub const ColorManagerV1 = extern struct {
    pub const Features = extern struct {
        icc_v2_v4: bool,
        parametric: bool,
        set_primaries: bool,
        set_tf_power: bool,
        set_luminances: bool,
        set_mastering_display_primaries: bool,
        extended_target_volume: bool,
        windows_scrgb: bool,
    };

    pub const Options = extern struct {
        features: Features,
        render_intents: ?[*]const wp.ColorManagerV1.RenderIntent,
        render_intents_len: usize,
        transfer_functions: ?[*]const wp.ColorManagerV1.TransferFunction,
        transfer_functions_len: usize,
        primaries: ?[*]const wp.ColorManagerV1.Primaries,
        primaries_len: usize,
    };

    global: *wl.Global,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    private: extern struct {
        features: Features,
        render_intents: ?[*]const wp.ColorManagerV1.RenderIntent,
        render_intents_len: usize,
        transfer_functions: ?[*]const wp.ColorManagerV1.TransferFunction,
        transfer_functions_len: usize,
        primaries: ?[*]const wp.ColorManagerV1.Primaries,
        primaries_len: usize,
        outputs: wl.list.Link,
        surface_feedbacks: wl.list.Link,
        last_image_desc_identity: u64,
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_color_manager_v1_create(
        server: *wl.Server,
        version: u32,
        options: *const Options,
    ) ?*ColorManagerV1;
    pub fn create(
        server: *wl.Server,
        version: u32,
        options: *const Options,
    ) error{ColorManagerV1CreateFailed}!*ColorManagerV1 {
        return wlr_color_manager_v1_create(server, version, options) orelse error.ColorManagerV1CreateFailed;
    }
};
