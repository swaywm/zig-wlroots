pub const DrmFormat = extern struct {
    format: u32,
    len: usize,
    capacity: usize,
    modifiers: [*]u64,

    extern fn wlr_drm_format_finish(format: *DrmFormat) void;
    pub const finish = wlr_drm_format_finish;
};

pub const DrmFormatSet = extern struct {
    len: usize,
    capacity: usize,
    formats: [*]DrmFormat,

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

    extern fn wlr_drm_format_set_union(dst: *DrmFormatSet, a: *const DrmFormatSet, b: *const DrmFormatSet) bool;
    pub const @"union" = wlr_drm_format_set_union;
};
