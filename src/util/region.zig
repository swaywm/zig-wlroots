const pixman = @import("pixman");

const wayland = @import("wayland");
const wl = wayland.server.wl;

extern fn wlr_region_scale(dst: *pixman.Region32, src: *pixman.Region32, scale: f32) void;
pub const scale = wlr_region_scale;

extern fn wlr_region_scale_xy(dst: *pixman.Region32, src: *pixman.Region32, scale_x: f32, scale_y: f32) void;
pub const scaleXY = wlr_region_scale_xy;

extern fn wlr_region_transform(dst: *pixman.Region32, src: *pixman.Region32, transform: wl.Output.Transform, width: c_int, height: c_int) void;
pub const transform = wlr_region_transform;

extern fn wlr_region_expand(dst: *pixman.Region32, src: *pixman.Region32, distance: c_int) void;
pub const expand = wlr_region_expand;

extern fn wlr_region_rotated_bounds(dst: *pixman.Region32, src: *pixman.Region32, rotation: f32, ox: c_int, oy: c_int) void;
pub const rotatedBounds = wlr_region_rotated_bounds;

extern fn wlr_region_confine(region: *pixman.Region32, x1: f64, y1: f64, x2: f64, y2: f64, x2_out: *f64, y2_out: *f64) bool;
pub const confine = wlr_region_confine;
