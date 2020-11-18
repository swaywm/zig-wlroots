const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const wlr_proto = wayland.server.wlr;

pub const LayerShellV1 = extern struct {
    global: *wl.Global,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        new_surface: wl.Signal(*LayerSurfaceV1),
        destroy: wl.Signal(*LayerShellV1),
    },

    data: usize,

    extern fn wlr_layer_shell_v1_create(server: *wl.Server) ?*LayerShellV1;
    pub const create = wlr_layer_shell_v1_create;
};

pub const LayerSurfaceV1 = extern struct {
    pub const State = extern struct {
        anchor: wlr_proto.LayerSurfaceV1.Anchor,
        exclusive_zone: i32,
        margin: extern struct {
            top: u32,
            right: u32,
            bottom: u32,
            left: u32,
        },
        keyboard_interactive: bool,
        desired_width: u32,
        desired_height: u32,
        actual_width: u32,
        actual_height: u32,
        layer: wlr_proto.LayerShellV1.Layer,
    };

    pub const Configure = extern struct {
        /// LayerSurfaceV1.configure_list
        link: wl.list.Link,
        serial: u32,
        state: State,
    };

    surface: *wlr.Surface,
    output: ?*wlr.Output,
    resource: *wl.Resource,
    shell: *LayerShellV1,
    /// wlr.XdgPopup.link
    popups: wl.list.Head(wlr.XdgPopup, "link"),

    namespace: [*:0]u8,

    added: bool,
    configured: bool,
    mapped: bool,
    closed: bool,

    configure_serial: u32,
    configure_next_serial: u32,
    configure_list: wl.list.Head(LayerSurfaceV1.Configure, "link"),

    acked_configure: ?*Configure,

    client_pending: State,
    server_pending: State,
    current: State,

    surface_destroy: wl.Listener(*wlr.Surface),

    events: extern struct {
        destroy: wl.Signal(*LayerSurfaceV1),
        map: wl.Signal(*LayerSurfaceV1),
        unmap: wl.Signal(*LayerSurfaceV1),
        new_popup: wl.Signal(*wlr.XdgPopup),
    },

    data: usize,

    extern fn wlr_layer_surface_v1_configure(surface: *LayerSurfaceV1, width: u32, height: u32) void;
    pub const configure = wlr_layer_surface_v1_configure;

    extern fn wlr_layer_surface_v1_close(surface: *LayerSurfaceV1) void;
    pub const close = wlr_layer_surface_v1_close;

    extern fn wlr_layer_surface_v1_from_wlr_surface(surface: *wlr.Surface) *LayerSurfaceV1;
    pub const fromSurface = wlr_layer_surface_v1_from_wlr_surface;

    extern fn wlr_layer_surface_v1_for_each_surface(
        surface: *LayerSurfaceV1,
        iterator: fn (*wlr.Surface, c_int, c_int, ?*c_void) callconv(.C) void,
        user_data: ?*c_void,
    ) void;
    pub fn forEachSurface(
        surface: *LayerSurfaceV1,
        comptime T: type,
        iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: T) callconv(.C) void,
        data: T,
    ) void {
        wlr_layer_surface_v1_for_each_surface(surface, iterator, data);
    }

    extern fn wlr_layer_surface_v1_for_each_popup(
        surface: *LayerSurfaceV1,
        iterator: fn (*wlr.Surface, c_int, c_int, ?*c_void) callconv(.C) void,
        user_data: ?*c_void,
    ) void;
    pub fn forEachPopup(
        surface: *LayerSurfaceV1,
        comptime T: type,
        iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: T) callconv(.C) void,
        data: T,
    ) void {
        wlr_layer_surface_v1_for_each_popup(surface, iterator, data);
    }

    extern fn wlr_layer_surface_v1_surface_at(surface: *LayerSurfaceV1, sx: f64, sy: f64, sub_x: *f64, sub_y: *f64) ?*wlr.Surface;
    pub const surfaceAt = wlr_layer_surface_v1_surface_at;
};
