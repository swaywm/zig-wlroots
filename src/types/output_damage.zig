const wlr = @import("../wlroots.zig");

const pixman = @import("pixman");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const OutputDamage = extern struct {
    output: *wlr.Output,
    max_rects: c_int,

    current: pixman.Region32,

    previous: [2]pixman.Region32,
    previous_idx: usize,

    pending_attach_render: bool,

    events: extern struct {
        frame: wl.Signal(*OutputDamage),
        destroy: wl.Signal(*OutputDamage),
    },

    output_destroy: wl.Listener(*wlr.Output),
    output_mode: wl.Listener(*wlr.Output),
    output_needs_frame: wl.Listener(*wlr.Output),
    output_damage: wl.Listener(*wlr.Output.event.Damage),
    output_frame: wl.Listener(*wlr.Output),
    output_precommit: wl.Listener(*wlr.Output.event.Precommit),
    output_commit: wl.Listener(*wlr.Output.event.Commit),

    extern fn wlr_output_damage_create(output: *wlr.Output) ?*OutputDamage;
    pub fn create(output: *wlr.Output) !*OutputDamage {
        return wlr_output_damage_create(output) orelse error.OutOfMemory;
    }

    extern fn wlr_output_damage_destroy(output_damage: *OutputDamage) void;
    pub const destroy = wlr_output_damage_destroy;

    extern fn wlr_output_damage_attach_render(output_damage: *OutputDamage, needs_frame: *bool, buffer_damage: *pixman.Region32) bool;
    pub fn attachRender(output_damage: *OutputDamage, needs_frame: *bool, buffer_damage: *pixman.Region32) !void {
        if (!wlr_output_damage_attach_render(output_damage, needs_frame, buffer_damage)) return error.AttachRenderFailed;
    }

    extern fn wlr_output_damage_add(output_damage: *OutputDamage, damage: *pixman.Region32) void;
    pub const add = wlr_output_damage_add;

    extern fn wlr_output_damage_add_whole(output_damage: *OutputDamage) void;
    pub const addWhole = wlr_output_damage_add_whole;

    extern fn wlr_output_damage_add_box(output_damage: *OutputDamage, box: *wlr.Box) void;
    pub const addBox = wlr_output_damage_add_box;
};
