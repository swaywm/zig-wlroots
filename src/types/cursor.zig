const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Cursor = extern struct {
    pub const State = opaque {};

    state: *State,
    x: f64,
    y: f64,

    events: extern struct {
        motion: wl.Signal(*wlr.Pointer.event.Motion),
        motion_absolute: wl.Signal(*wlr.Pointer.event.MotionAbsolute),
        button: wl.Signal(*wlr.Pointer.event.Button),
        axis: wl.Signal(*wlr.Pointer.event.Axis),
        frame: wl.Signal(*Cursor),
        swipe_begin: wl.Signal(*wlr.Pointer.event.SwipeBegin),
        swipe_update: wl.Signal(*wlr.Pointer.event.SwipeUpdate),
        swipe_end: wl.Signal(*wlr.Pointer.event.SwipeEnd),
        pinch_begin: wl.Signal(*wlr.Pointer.event.PinchBegin),
        pinch_update: wl.Signal(*wlr.Pointer.event.PinchUpdate),
        pinch_end: wl.Signal(*wlr.Pointer.event.PinchEnd),
        hold_begin: wl.Signal(*wlr.Pointer.event.HoldBegin),
        hold_end: wl.Signal(*wlr.Pointer.event.HoldEnd),

        touch_up: wl.Signal(*wlr.Touch.event.Up),
        touch_down: wl.Signal(*wlr.Touch.event.Down),
        touch_motion: wl.Signal(*wlr.Touch.event.Motion),
        touch_cancel: wl.Signal(*wlr.Touch.event.Cancel),
        touch_frame: wl.Signal(void),

        tablet_tool_axis: wl.Signal(*wlr.Tablet.event.Axis),
        tablet_tool_proximity: wl.Signal(*wlr.Tablet.event.Proximity),
        tablet_tool_tip: wl.Signal(*wlr.Tablet.event.Tip),
        tablet_tool_button: wl.Signal(*wlr.Tablet.event.Button),
    },

    data: usize,

    extern fn wlr_cursor_create() ?*Cursor;
    pub fn create() !*Cursor {
        return wlr_cursor_create() orelse error.OutOfMemory;
    }

    extern fn wlr_cursor_destroy(cur: *Cursor) void;
    pub const destroy = wlr_cursor_destroy;

    extern fn wlr_cursor_warp(cur: *Cursor, dev: ?*wlr.InputDevice, lx: f64, ly: f64) bool;
    pub const warp = wlr_cursor_warp;

    extern fn wlr_cursor_absolute_to_layout_coords(cur: *Cursor, dev: ?*wlr.InputDevice, x: f64, y: f64, lx: *f64, ly: *f64) void;
    pub const absoluteToLayoutCoords = wlr_cursor_absolute_to_layout_coords;

    extern fn wlr_cursor_warp_closest(cur: *Cursor, dev: ?*wlr.InputDevice, x: f64, y: f64) void;
    pub const warpClosest = wlr_cursor_warp_closest;

    extern fn wlr_cursor_warp_absolute(cur: *Cursor, dev: ?*wlr.InputDevice, x: f64, y: f64) void;
    pub const warpAbsolute = wlr_cursor_warp_absolute;

    extern fn wlr_cursor_move(cur: *Cursor, dev: ?*wlr.InputDevice, delta_x: f64, delta_y: f64) void;
    pub const move = wlr_cursor_move;

    extern fn wlr_cursor_set_image(cur: *Cursor, pixels: [*c]const u8, stride: i32, width: u32, height: u32, hotspot_x: i32, hotspot_y: i32, scale: f32) void;
    pub const setImage = wlr_cursor_set_image;

    extern fn wlr_cursor_set_surface(cur: *Cursor, surface: ?*wlr.Surface, hotspot_x: i32, hotspot_y: i32) void;
    pub const setSurface = wlr_cursor_set_surface;

    extern fn wlr_cursor_attach_input_device(cur: *Cursor, dev: *wlr.InputDevice) void;
    pub const attachInputDevice = wlr_cursor_attach_input_device;

    extern fn wlr_cursor_detach_input_device(cur: *Cursor, dev: *wlr.InputDevice) void;
    pub const detachInputDevice = wlr_cursor_detach_input_device;

    extern fn wlr_cursor_attach_output_layout(cur: *Cursor, l: *wlr.OutputLayout) void;
    pub const attachOutputLayout = wlr_cursor_attach_output_layout;

    extern fn wlr_cursor_map_to_output(cur: *Cursor, output: *wlr.Output) void;
    pub const mapToOutput = wlr_cursor_map_to_output;

    extern fn wlr_cursor_map_input_to_output(cur: *Cursor, dev: *wlr.InputDevice, output: *wlr.Output) void;
    pub const mapInputToOutput = wlr_cursor_map_input_to_output;

    extern fn wlr_cursor_map_to_region(cur: *Cursor, box: *const wlr.Box) void;
    pub const mapToRegion = wlr_cursor_map_to_region;

    extern fn wlr_cursor_map_input_to_region(cur: *Cursor, dev: *wlr.InputDevice, box: *const wlr.Box) void;
    pub const mapInputToRegion = wlr_cursor_map_input_to_region;
};
