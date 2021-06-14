const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

extern fn wlr_matrix_identity(mat: *[9]f32) void;
pub const identity = wlr_matrix_identity;

extern fn wlr_matrix_multiply(mat: *[9]f32, a: *const [9]f32, b: *const [9]f32) void;
pub const multiply = wlr_matrix_multiply;

extern fn wlr_matrix_transpose(mat: *[9]f32, a: *const [9]f32) void;
pub const transpose = wlr_matrix_transpose;

extern fn wlr_matrix_translate(mat: *[9]f32, x: f32, y: f32) void;
pub const translate = wlr_matrix_translate;

extern fn wlr_matrix_scale(mat: *[9]f32, x: f32, y: f32) void;
pub const scale = wlr_matrix_scale;

extern fn wlr_matrix_rotate(mat: *[9]f32, rad: f32) void;
pub const rotate = wlr_matrix_rotate;

extern fn wlr_matrix_transform(mat: *[9]f32, transform: wl.Output.Transform) void;
pub const transform = wlr_matrix_transform;

extern fn wlr_matrix_project_box(mat: *[9]f32, box: *const wlr.Box, transform: wl.Output.Transform, rotation: f32, projection: *const [9]f32) void;
pub const projectBox = wlr_matrix_project_box;
