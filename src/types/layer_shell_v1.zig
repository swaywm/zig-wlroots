const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const zwlr = wayland.server.zwlr;

pub const LayerShellV1 = extern struct {
    global: *wl.Global,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        new_surface: wl.Signal(*LayerSurfaceV1),
        destroy: wl.Signal(*LayerShellV1),
    },

    data: usize,

    extern fn wlr_layer_shell_v1_create(server: *wl.Server, version: u32) ?*LayerShellV1;
    pub fn create(server: *wl.Server, version: u32) !*LayerShellV1 {
        return wlr_layer_shell_v1_create(server, version) orelse error.OutOfMemory;
    }
};

pub const LayerSurfaceV1 = extern struct {
    pub const State = extern struct {
        pub const Fields = packed struct(u32) {
            desired_size: bool = false,
            anchor: bool = false,
            exclusive_zone: bool = false,
            margin: bool = false,
            keyboard_interactivity: bool = false,
            layer: bool = false,
            _: u26 = 0,
        };

        committed: Fields,
        anchor: zwlr.LayerSurfaceV1.Anchor,
        exclusive_zone: i32,
        margin: extern struct {
            top: i32,
            right: i32,
            bottom: i32,
            left: i32,
        },
        keyboard_interactive: zwlr.LayerSurfaceV1.KeyboardInteractivity,
        desired_width: u32,
        desired_height: u32,
        layer: zwlr.LayerShellV1.Layer,

        configure_serial: u32,
        actual_width: u32,
        actual_height: u32,
    };

    pub const Configure = extern struct {
        /// LayerSurfaceV1.configure_list
        link: wl.list.Link,
        serial: u32,

        width: u32,
        height: u32,
    };

    surface: *wlr.Surface,
    output: ?*wlr.Output,
    resource: *wl.Resource,
    shell: *LayerShellV1,
    /// wlr.XdgPopup.link
    popups: wl.list.Head(wlr.XdgPopup, .link),

    namespace: [*:0]u8,

    added: bool,
    configured: bool,

    configure_list: wl.list.Head(LayerSurfaceV1.Configure, .link),

    current: State,
    pending: State,

    events: extern struct {
        destroy: wl.Signal(*LayerSurfaceV1),
        new_popup: wl.Signal(*wlr.XdgPopup),
    },

    data: usize,

    extern fn wlr_layer_surface_v1_configure(surface: *LayerSurfaceV1, width: u32, height: u32) u32;
    pub const configure = wlr_layer_surface_v1_configure;

    extern fn wlr_layer_surface_v1_destroy(surface: *LayerSurfaceV1) void;
    pub const destroy = wlr_layer_surface_v1_destroy;

    extern fn wlr_layer_surface_v1_try_from_wlr_surface(surface: *wlr.Surface) ?*LayerSurfaceV1;
    pub const tryFromWlrSurface = wlr_layer_surface_v1_try_from_wlr_surface;

    extern fn wlr_layer_surface_v1_for_each_surface(
        surface: *LayerSurfaceV1,
        iterator: *const fn (*wlr.Surface, c_int, c_int, ?*anyopaque) callconv(.C) void,
        user_data: ?*anyopaque,
    ) void;
    pub inline fn forEachSurface(
        surface: *LayerSurfaceV1,
        comptime T: type,
        comptime iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: T) void,
        data: T,
    ) void {
        wlr_layer_surface_v1_for_each_surface(
            surface,
            struct {
                fn wrapper(s: *wlr.Surface, sx: c_int, sy: c_int, d: ?*anyopaque) callconv(.C) void {
                    iterator(s, sx, sy, @ptrCast(@alignCast(d)));
                }
            }.wrapper,
            data,
        );
    }

    extern fn wlr_layer_surface_v1_for_each_popup_surface(
        surface: *LayerSurfaceV1,
        iterator: *const fn (*wlr.Surface, c_int, c_int, ?*anyopaque) callconv(.C) void,
        user_data: ?*anyopaque,
    ) void;
    pub inline fn forEachPopupSurface(
        surface: *LayerSurfaceV1,
        comptime T: type,
        comptime iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: T) void,
        data: T,
    ) void {
        wlr_layer_surface_v1_for_each_popup_surface(
            surface,
            struct {
                fn wrapper(s: *wlr.Surface, sx: c_int, sy: c_int, d: ?*anyopaque) callconv(.C) void {
                    iterator(s, sx, sy, @ptrCast(@alignCast(d)));
                }
            }.wrapper,
            data,
        );
    }

    extern fn wlr_layer_surface_v1_surface_at(surface: *LayerSurfaceV1, sx: f64, sy: f64, sub_x: *f64, sub_y: *f64) ?*wlr.Surface;
    pub const surfaceAt = wlr_layer_surface_v1_surface_at;

    extern fn wlr_layer_surface_v1_popup_surface_at(surface: *LayerSurfaceV1, sx: f64, sy: f64, sub_x: *f64, sub_y: *f64) ?*wlr.Surface;
    pub const popupSurfaceAt = wlr_layer_surface_v1_popup_surface_at;

    extern fn wlr_layer_surface_v1_from_resource(resource: *wl.Resource) ?*LayerSurfaceV1;
    pub const fromResource = wlr_layer_surface_v1_from_resource;
};
