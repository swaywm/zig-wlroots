const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const AddonSet = extern struct {
    // private state
    addons: wl.list.Head(Addon, "link"),

    extern fn wlr_addon_set_init(set: *AddonSet) void;
    pub const init = wlr_addon_set_init;

    extern fn wlr_addon_set_finish(set: *AddonSet) void;
    pub const deinit = wlr_addon_set_finish;

    extern fn wlr_addon_find(set: *AddonSet, owner: ?*const anyopaque, impl: *const Addon.Interface) ?*Addon;
    pub const find = wlr_addon_find;
};

pub const Addon = extern struct {
    pub const Interface = extern struct {
        name: [*:0]const u8,
        destroy: fn (*Addon) callconv(.C) void,
    };

    impl: *const Interface,

    // private state

    owner: ?*const anyopaque,
    link: wl.list.Link,

    extern fn wlr_addon_init(addon: *Addon, set: *AddonSet, owner: ?*const anyopaque, impl: *const Interface) void;
    pub const init = wlr_addon_init;

    extern fn wlr_addon_finish(addon: *Addon) void;
    pub const deinit = wlr_addon_finish;
};
