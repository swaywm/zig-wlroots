const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const wp = wayland.server.wp;

pub const CursorShapeManagerV1 = extern struct {
    global: *wl.Global,

    events: extern struct {
        request_set_shape: wl.Signal(*event.RequestSetShape),
        destroy: wl.Signal(void),
    },

    data: ?*anyopaque,

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    pub const DeviceType = enum(c_int) {
        pointer,
        tablet_tool,
    };

    pub const event = struct {
        pub const RequestSetShape = extern struct {
            seat_client: *wlr.Seat.Client,
            device_type: DeviceType,
            tablet_tool: ?*wlr.TabletV2TabletTool,
            serial: u32,
            shape: wp.CursorShapeDeviceV1.Shape,
        };
    };

    extern fn wlr_cursor_shape_manager_v1_create(server: *wl.Server, version: u32) ?*CursorShapeManagerV1;
    pub fn create(server: *wl.Server, version: u32) !*CursorShapeManagerV1 {
        return wlr_cursor_shape_manager_v1_create(server, version) orelse error.OutOfMemory;
    }

    extern fn wlr_cursor_shape_v1_name(shape: wp.CursorShapeDeviceV1.Shape) [*:0]const u8;
    pub const shapeName = wlr_cursor_shape_v1_name;
};
