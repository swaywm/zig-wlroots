const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

const pixman = @import("pixman");

pub const DamageRing = extern struct {
    current: pixman.Region32,

    private: extern struct {
        buffers: wl.list.Link,
    },

    extern fn wlr_damage_ring_init(ring: *DamageRing) void;
    pub const init = wlr_damage_ring_init;

    extern fn wlr_damage_ring_finish(ring: *DamageRing) void;
    pub const finish = wlr_damage_ring_finish;

    extern fn wlr_damage_ring_add(ring: *DamageRing, damage: *const pixman.Region32) void;
    pub const add = wlr_damage_ring_add;

    extern fn wlr_damage_ring_add_box(ring: *DamageRing, box: ?*const wlr.Box) void;
    pub const addBox = wlr_damage_ring_add_box;

    extern fn wlr_damage_ring_add_whole(ring: *DamageRing) void;
    pub const addWhole = wlr_damage_ring_add_whole;

    extern fn wlr_damage_ring_rotate_buffer(ring: *DamageRing, buffer: *wlr.Buffer, damage: *pixman.Region32) void;
    pub const rotateBuffer = wlr_damage_ring_rotate_buffer;
};
