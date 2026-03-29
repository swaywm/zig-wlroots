const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const wp = wayland.server.wp;

pub const ColorManagerV1 = extern struct {
    pub const Features = extern struct {
        icc_v2_v4: bool = false,
        parametric: bool = false,
        set_primaries: bool = false,
        set_tf_power: bool = false,
        set_luminances: bool = false,
        set_mastering_display_primaries: bool = false,
        extended_target_volume: bool = false,
        windows_scrgb: bool = false,
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
        options: struct {
            features: Features,
            render_intents: []const wp.ColorManagerV1.RenderIntent,
            transfer_functions: []const wp.ColorManagerV1.TransferFunction,
            primaries: []const wp.ColorManagerV1.Primaries,
        },
    ) error{ColorManagerV1CreateFailed}!*ColorManagerV1 {
        return wlr_color_manager_v1_create(server, version, &.{
            .features = options.features,
            .render_intents = options.render_intents.ptr,
            .render_intents_len = options.render_intents.len,
            .transfer_functions = options.transfer_functions.ptr,
            .transfer_functions_len = options.transfer_functions.len,
            .primaries = options.primaries.ptr,
            .primaries_len = options.primaries.len,
        }) orelse error.ColorManagerV1CreateFailed;
    }
};
