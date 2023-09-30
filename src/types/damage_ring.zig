const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

const pixman = @import("pixman");

pub const DamageRing = extern struct {
    width: i32,
    height: i32,
    current: pixman.Region32,
    previous: [2]pixman.Region32,
    previous_idx: usize,

    extern fn wlr_damage_ring_init(ring: *DamageRing) void;
    pub const init = wlr_damage_ring_init;

    extern fn wlr_damage_ring_finish(ring: *DamageRing) void;
    pub const finish = wlr_damage_ring_finish;

    extern fn wlr_damage_ring_set_bounds(ring: *DamageRing, width: i32, height: i32) void;
    pub const setBounds = wlr_damage_ring_set_bounds;

    extern fn wlr_damage_ring_add(ring: *DamageRing, damage: *const pixman.Region32) bool;
    pub const add = wlr_damage_ring_add;

    extern fn wlr_damage_ring_add_box(ring: *DamageRing, box: ?*const wlr.Box) bool;
    pub const addBox = wlr_damage_ring_add_box;

    extern fn wlr_damage_ring_add_whole(ring: *DamageRing) void;
    pub const addWhole = wlr_damage_ring_add_whole;

    extern fn wlr_damage_ring_rotate(ring: *DamageRing) void;
    pub const rotate = wlr_damage_ring_rotate;

    extern fn wlr_damage_ring_get_buffer_damage(ring: *DamageRing, buffer_age: c_int, damage: *pixman.Region32) void;
    pub const getBufferDamage = wlr_damage_ring_get_buffer_damage;
};
