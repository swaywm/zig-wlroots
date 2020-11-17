const wlr = @import("wlroots.zig");

pub const XcursorImage = extern struct {
    width: u32,
    height: u32,
    hotspot_x: u32,
    hotspot_y: u32,
    delay: u32,
    buffer: [*]u8,
};

pub const Xcursor = extern struct {
    image_count: c_uint,
    images: [*]*XcursorImage,
    name: [*:0]u8,
    total_delay: u32,

    extern fn wlr_xcursor_frame(cursor: *Xcursor, time: u32) c_int;
    pub const frame = wlr_xcursor_frame;

    // kinda ugly, wlroots decided to use the enum directly here instead of
    // a uint32_t which has the ABI of an int
    extern fn wlr_xcursor_get_resize_name(edges: c_int) [*:0]const u8;
    pub fn getResizeName(edges: wlr.Edges) [*:0]const u8 {
        return wlr_xcursor_get_resize_name(@bitCast(c_int, edges));
    }
};

pub const XcursorTheme = extern struct {
    cursor_count: c_uint,
    cursors: [*]*Xcursor,
    name: [*:0]u8,
    size: c_int,

    extern fn wlr_xcursor_theme_load(name: [*:0]const u8, size: c_int) ?*XcursorTheme;
    pub const load = wlr_xcursor_theme_load;

    extern fn wlr_xcursor_theme_destroy(theme: *XcursorTheme) void;
    pub const destroy = wlr_xcursor_theme_destroy;

    extern fn wlr_xcursor_theme_get_cursor(theme: *XcursorTheme, name: [*:0]const u8) ?*Xcursor;
    pub const getCursor = wlr_xcursor_theme_get_cursor;
};
