const wlr = @import("wlroots.zig");

pub const XCursorImage = extern struct {
    width: u32,
    height: u32,
    hotspot_x: u32,
    hotspot_y: u32,
    delay: u32,
    buffer: [*]u8,
};

pub const XCursor = extern struct {
    image_count: c_uint,
    images: [*]*XCursorImage,
    name: [*:0]u8,
    total_delay: u32,

    extern fn wlr_xcursor_frame(cursor: *XCursor, time: u32) c_int;
    pub const frame = wlr_xcursor_frame;

    extern fn wlr_xcursor_get_resize_name(edges: wlr.Edges) [*:0]const u8;
    pub const getResizeName = wlr_xcursor_get_resize_name;
};

pub const XCursorTheme = extern struct {
    cursor_count: c_uint,
    cursors: [*]*XCursor,
    name: [*:0]u8,
    size: c_int,

    extern fn wlr_xcursor_theme_load(name: [*:0]const u8, size: c_int) ?*XCursorTheme;
    pub const load = wlr_xcursor_theme_load;

    extern fn wlr_xcursor_theme_destroy(theme: *XCursorTheme) void;
    pub const destroy = wlr_xcursor_theme_destroy;

    extern fn wlr_xcursor_theme_get_cursor(theme: *XCursorTheme, name: [*:0]const u8) ?*XCursor;
    pub const getCursor = wlr_xcursor_theme_get_cursor;
};
