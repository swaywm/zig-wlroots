const wlr = @import("../wlroots.zig");

const wl = @import("wayland").server.wl;

pub const XcursorManagerTheme = extern struct {
    scale: f32,
    theme: *wlr.XcursorTheme,
    /// XcursorManager.scaled_themes
    link: wl.list.Link,
};

pub const XcursorManager = extern struct {
    name: ?[*:0]u8,
    size: u32,
    scaled_themes: wl.list.Head(XcursorManagerTheme, "link"),

    extern fn wlr_xcursor_manager_create(name: ?[*:0]const u8, size: u32) ?*XcursorManager;
    pub fn create(name: ?[*:0]const u8, size: u32) !*XcursorManager {
        return wlr_xcursor_manager_create(name, size) orelse return error.OutOfMemory;
    }

    extern fn wlr_xcursor_manager_destroy(manager: *XcursorManager) void;
    pub const destroy = wlr_xcursor_manager_destroy;

    extern fn wlr_xcursor_manager_load(manager: *XcursorManager, scale: f32) bool;
    pub fn load(manager: *XcursorManager, scale: f32) !void {
        if (!wlr_xcursor_manager_load(manager, scale)) {
            return error.XcursorLoadFailed;
        }
    }

    extern fn wlr_xcursor_manager_get_xcursor(manager: *XcursorManager, name: [*:0]const u8, scale: f32) ?*wlr.Xcursor;
    pub const getXcursor = wlr_xcursor_manager_get_xcursor;

    extern fn wlr_xcursor_manager_set_cursor_image(manager: *XcursorManager, name: [*:0]const u8, cursor: *wlr.Cursor) void;
    pub const setCursorImage = wlr_xcursor_manager_set_cursor_image;
};
