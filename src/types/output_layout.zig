const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const OutputLayout = extern struct {
    pub const Output = extern struct {
        layout: *OutputLayout,

        output: *wlr.Output,

        x: c_int,
        y: c_int,
        /// OutputLayout.outputs
        link: wl.list.Link,

        auto_configured: bool,
        events: extern struct {
            destroy: wl.Signal(*OutputLayout.Output),
        },

        // private state

        addon: *wlr.Addon,

        commit: wl.Listener(*wlr.Output.event.Commit),
    };

    pub const Direction = enum(c_int) {
        up = 1,
        down = 2,
        left = 4,
        right = 8,
    };

    outputs: wl.list.Head(OutputLayout.Output, .link),

    events: extern struct {
        add: wl.Signal(*OutputLayout.Output),
        change: wl.Signal(*OutputLayout),
        destroy: wl.Signal(*OutputLayout),
    },

    data: usize,

    extern fn wlr_output_layout_create() ?*OutputLayout;
    pub fn create() !*OutputLayout {
        return wlr_output_layout_create() orelse error.OutOfMemory;
    }

    extern fn wlr_output_layout_destroy(layout: *OutputLayout) void;
    pub const destroy = wlr_output_layout_destroy;

    extern fn wlr_output_layout_get(layout: *OutputLayout, reference: *wlr.Output) ?*OutputLayout.Output;
    pub const get = wlr_output_layout_get;

    extern fn wlr_output_layout_output_at(layout: *OutputLayout, lx: f64, ly: f64) ?*wlr.Output;
    pub const outputAt = wlr_output_layout_output_at;

    extern fn wlr_output_layout_add(layout: *OutputLayout, output: *wlr.Output, lx: c_int, ly: c_int) ?*OutputLayout.Output;
    pub fn add(layout: *OutputLayout, output: *wlr.Output, lx: c_int, ly: c_int) !*OutputLayout.Output {
        return wlr_output_layout_add(layout, output, lx, ly) orelse error.OutOfMemory;
    }

    extern fn wlr_output_layout_add_auto(layout: *OutputLayout, output: *wlr.Output) ?*OutputLayout.Output;
    pub fn addAuto(layout: *OutputLayout, output: *wlr.Output) !*OutputLayout.Output {
        return wlr_output_layout_add_auto(layout, output) orelse error.OutOfMemory;
    }

    extern fn wlr_output_layout_remove(layout: *OutputLayout, output: *wlr.Output) void;
    pub const remove = wlr_output_layout_remove;

    extern fn wlr_output_layout_output_coords(layout: *OutputLayout, reference: *wlr.Output, lx: *f64, ly: *f64) void;
    pub const outputCoords = wlr_output_layout_output_coords;

    extern fn wlr_output_layout_contains_point(layout: *OutputLayout, reference: ?*wlr.Output, lx: c_int, ly: c_int) bool;
    pub const containsPoint = wlr_output_layout_contains_point;

    extern fn wlr_output_layout_intersects(layout: *OutputLayout, reference: ?*wlr.Output, target_lbox: *const wlr.Box) bool;
    pub const intersects = wlr_output_layout_intersects;

    extern fn wlr_output_layout_closest_point(layout: *OutputLayout, reference: ?*wlr.Output, lx: f64, ly: f64, dest_lx: *f64, dest_ly: *f64) void;
    pub const closestPoint = wlr_output_layout_closest_point;

    extern fn wlr_output_layout_get_box(layout: *OutputLayout, reference: ?*wlr.Output, dest_box: ?*wlr.Box) void;
    pub const getBox = wlr_output_layout_get_box;

    extern fn wlr_output_layout_get_center_output(layout: *OutputLayout) ?*wlr.Output;
    pub const getCenterOutput = wlr_output_layout_get_center_output;

    extern fn wlr_output_layout_adjacent_output(layout: *OutputLayout, direction: Direction, reference: *wlr.Output, ref_lx: f64, ref_ly: f64) ?*wlr.Output;
    pub const adjacentOutput = wlr_output_layout_adjacent_output;

    extern fn wlr_output_layout_farthest_output(layout: *OutputLayout, direction: Direction, reference: *wlr.Output, ref_lx: f64, ref_ly: f64) ?*wlr.Output;
    pub const farthestOutput = wlr_output_layout_farthest_output;
};
