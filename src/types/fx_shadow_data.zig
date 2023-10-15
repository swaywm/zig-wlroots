const wlr = @import("../wlroots.zig");

const std = @import("std");
const os = std.os;

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const ShadowData = extern struct {
    enabled: bool,
    color: *[4]f32,
    blur_sigma: f64,

    extern fn shadow_data_get_default() ShadowData;
    pub const getDefault = shadow_data_get_default;

    // Functions that are related to `scene_buffer` have been moved to `scene.zig`.
    //
    // scene_buffer_has_shadow(ShadowData);
};
