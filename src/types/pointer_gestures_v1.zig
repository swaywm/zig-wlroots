const wlr = @import("../wlroots.zig");

const std = @import("std");
const wayland = @import("wayland");
const wl = wayland.server.wl;
const zwp = wayland.server.zwp;

pub const PointerGesturesV1 = extern struct {
    global: *wl.Global,
    swipes: wl.list.Head(zwp.PointerGestureSwipeV1, null),
    pinches: wl.list.Head(zwp.PointerGesturePinchV1, null),
    holds: wl.list.Head(zwp.PointerGestureHoldV1, null),

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        destroy: wl.Signal(*PointerGesturesV1),
    },

    data: usize,

    extern fn wlr_pointer_gestures_v1_create(server: *wl.Server) ?*PointerGesturesV1;
    pub fn create(server: *wl.Server) !*PointerGesturesV1 {
        return wlr_pointer_gestures_v1_create(server) orelse error.OutOfMemory;
    }

    extern fn wlr_pointer_gestures_v1_send_swipe_begin(
        pointer_gestures: *PointerGesturesV1,
        seat: *wlr.Seat,
        time_msec: u32,
        fingers: u32,
    ) void;
    pub const sendSwipeBegin = wlr_pointer_gestures_v1_send_swipe_begin;

    extern fn wlr_pointer_gestures_v1_send_swipe_update(
        pointer_gestures: *PointerGesturesV1,
        seat: *wlr.Seat,
        time_msec: u32,
        dx: f64,
        dy: f64,
    ) void;
    pub const sendSwipeUpdate = wlr_pointer_gestures_v1_send_swipe_update;

    extern fn wlr_pointer_gestures_v1_send_swipe_end(
        pointer_gestures: *PointerGesturesV1,
        seat: *wlr.Seat,
        time_msec: u32,
        cancelled: bool,
    ) void;
    pub const sendSwipeEnd = wlr_pointer_gestures_v1_send_swipe_end;

    extern fn wlr_pointer_gestures_v1_send_pinch_begin(
        pointer_gestures: *PointerGesturesV1,
        seat: *wlr.Seat,
        time_msec: u32,
        fingers: u32,
    ) void;
    pub const sendPinchBegin = wlr_pointer_gestures_v1_send_pinch_begin;

    extern fn wlr_pointer_gestures_v1_send_pinch_update(
        pointer_gestures: *PointerGesturesV1,
        seat: *wlr.Seat,
        time_msec: u32,
        dx: f64,
        dy: f64,
        scale: f64,
        rotation: f64,
    ) void;
    pub const sendPinchUpdate = wlr_pointer_gestures_v1_send_pinch_update;

    extern fn wlr_pointer_gestures_v1_send_pinch_end(
        pointer_gestures: *PointerGesturesV1,
        seat: *wlr.Seat,
        time_msec: u32,
        cancelled: bool,
    ) void;
    pub const sendPinchEnd = wlr_pointer_gestures_v1_send_pinch_end;

    extern fn wlr_pointer_gestures_v1_send_hold_begin(
        pointer_gestures: *PointerGesturesV1,
        seat: *wlr.Seat,
        time_msec: u32,
        fingers: u32,
    ) void;
    pub const sendHoldBegin = wlr_pointer_gestures_v1_send_hold_begin;

    extern fn wlr_pointer_gestures_v1_send_hold_end(
        pointer_gestures: *PointerGesturesV1,
        seat: *wlr.Seat,
        time_msec: u32,
        cancelled: bool,
    ) void;
    pub const sendHoldEnd = wlr_pointer_gestures_v1_send_hold_end;
};
