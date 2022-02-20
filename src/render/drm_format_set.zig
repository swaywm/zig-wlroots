const std = @import("std");
const c = @cImport(@cInclude("wlr/render/drm_format_set.h"));

pub const DrmFormat = extern struct {
    // Use comptime introspection to get the alignment of arch dependent field
    format: u32 align(std.meta.fieldInfo(c.wlr_drm_format, .format).alignment),
    len: usize,
    capacity: usize,

    // The output of translate_c is arch dependent for flexible arrays so import
    // the generated version directly rather than copying it verbatim here
    pub const modifiers = c.wlr_drm_format.modifiers;
};

pub const DrmFormatSet = extern struct {
    len: usize,
    capacity: usize,
    formats: [*]*DrmFormat,

    extern fn wlr_drm_format_set_finish(set: *DrmFormatSet) void;
    pub const finish = wlr_drm_format_set_finish;

    extern fn wlr_drm_format_set_get(set: *const DrmFormatSet, format: u32) *const DrmFormat;
    pub const get = wlr_drm_format_set_get;

    extern fn wlr_drm_format_set_has(set: *const DrmFormatSet, format: u32, modifier: u64) bool;
    pub const has = wlr_drm_format_set_has;

    extern fn wlr_drm_format_set_add(set: *DrmFormatSet, format: u32, modifier: u64) bool;
    pub const add = wlr_drm_format_set_add;

    extern fn wlr_drm_format_set_intersect(dst: *DrmFormatSet, a: *const DrmFormatSet, b: *const DrmFormatSet) bool;
    pub const intersect = wlr_drm_format_set_intersect;
};
