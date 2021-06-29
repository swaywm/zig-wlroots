const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const KeyboardShortcutsInhibitManagerV1 = extern struct {
    inhibitors: wl.list.Head(wlr.KeyboardShortcutsInhibitorV1, "link"),
    global: *wl.Global,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        new_inhibitor: wl.Signal(*wlr.KeyboardShortcutsInhibitorV1),
        destroy: wl.Signal(*wlr.KeyboardShortcutsInhibitManagerV1),
    },

    data: usize,

    extern fn wlr_keyboard_shortcuts_inhibit_v1_create(server: *wl.Server) ?*wlr.KeyboardShortcutsInhibitManagerV1;
    pub fn create(server: *wl.Server) !*wlr.KeyboardShortcutsInhibitManagerV1 {
        return wlr_keyboard_shortcuts_inhibit_v1_create(server) orelse error.OutOfMemory;
    }
};

pub const KeyboardShortcutsInhibitorV1 = extern struct {
    surface: *wlr.Surface,
    seat: *wlr.Seat,
    active: bool,
    resource: *wl.Resource,

    surface_destroy: wl.Listener(*wlr.Surface),
    seat_destroy: wl.Listener(*wlr.Seat),

    link: wl.list.Link,

    events: extern struct {
        destroy: wl.Signal(*wlr.KeyboardShortcutsInhibitorV1),
    },

    data: usize,

    extern fn wlr_keyboard_shortcuts_inhibitor_v1_activate(inhibitor: *wlr.KeyboardShortcutsInhibitorV1) void;
    pub const activate = wlr_keyboard_shortcuts_inhibitor_v1_activate;

    extern fn wlr_keyboard_shortcuts_inhibitor_v1_deactivate(inhibitor: *wlr.KeyboardShortcutsInhibitorV1) void;
    pub const deactivate = wlr_keyboard_shortcuts_inhibitor_v1_deactivate;
};
