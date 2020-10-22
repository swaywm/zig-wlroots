const wlr = @import("../wlroots.zig");

const wl = @import("wayland").server.wl;

pub const XCursorManagerTheme = extern struct {
    scale: f32,
    theme: *wlr.XCursorTheme,
    link: wl.List,
};

pub const XCursorManager = extern struct {
    name: ?[*:0]u8,
    size: u32,
    /// XCursorManagerTheme.link
    scaled_themes: wl.List,

    extern fn wlr_xcursor_manager_create(name: ?[*:0]const u8, size: u32) ?*XCursorManager;
    pub const create = wlr_xcursor_manager_create;

    extern fn wlr_xcursor_manager_destroy(manager: *XCursorManager) void;
    pub const destroy = wlr_xcursor_manager_destroy;

    extern fn wlr_xcursor_manager_load(manager: *XCursorManager, scale: f32) bool;
    pub const load = wlr_xcursor_manager_load;

    extern fn wlr_xcursor_manager_get_xcursor(manager: *XCursorManager, name: [*:0]const u8, scale: f32) ?*wlr.XCursor;
    pub const getXCursor = wlr_xcursor_manager_get_xcursor;

    extern fn wlr_xcursor_manager_set_cursor_image(manager: *XCursorManager, name: [*:0]const u8, cursor: *wlr.Cursor) void;
    pub const setCursorImage = wlr_xcursor_manager_set_cursor_image;
};
