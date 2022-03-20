const wlr = @import("../wlroots.zig");

const os = @import("std").os;

const pixman = @import("pixman");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Surface = extern struct {
    pub const State = extern struct {
        pub const field = struct {
            pub const buffer = 1 << 0;
            pub const surface_damage = 1 << 1;
            pub const buffer_damage = 1 << 2;
            pub const opaque_region = 1 << 3;
            pub const input_region = 1 << 4;
            pub const transform = 1 << 5;
            pub const scale = 1 << 6;
            pub const frame_callback_list = 1 << 7;
            pub const viewport = 1 << 8;
        };

        /// This is a bitfield of State.field members
        committed: u32,
        seq: u32,

        buffer: ?*wlr.Buffer,
        dx: i32,
        dy: i32,
        surface_damage: pixman.Region32,
        buffer_damage: pixman.Region32,
        @"opaque": pixman.Region32,
        input: pixman.Region32,
        transform: wl.Output.Transform,
        scale: i32,
        frame_callback_list: wl.list.Head(wl.Callback, null),

        width: c_int,
        height: c_int,
        buffer_width: c_int,
        buffer_height: c_int,

        subsurfaces_below: wl.list.Head(Subsurface.ParentState, "link"),
        subsurfaces_above: wl.list.Head(Subsurface.ParentState, "link"),

        viewport: extern struct {
            has_src: bool,
            has_dst: bool,
            src: wlr.FBox,
            dst_width: c_int,
            dst_height: c_int,
        },

        cached_state_locks: usize,
        cached_state_link: wl.list.Link,
    };

    pub const Role = extern struct {
        name: [*:0]const u8,
        commit: ?fn (surface: *Surface) callconv(.C) void,
        precommit: ?fn (surface: *Surface) callconv(.C) void,
    };

    pub const Output = extern struct {
        surface: *wlr.Surface,
        output: *wlr.Output,

        // Surface.current_outputs
        link: wl.list.Link,
        bind: wl.Listener(*wlr.Output.event.Bind),
        destroy: wl.Listener(*wlr.Output),
    };

    resource: *wl.Surface,
    renderer: *wlr.Renderer,

    buffer: ?*wlr.ClientBuffer,

    sx: c_int,
    sy: c_int,

    buffer_damage: pixman.Region32,
    external_damage: pixman.Region32,
    opaque_region: pixman.Region32,
    input_region: pixman.Region32,

    current: State,
    pending: State,

    cached: wl.list.Head(Surface.State, "cached_state_link"),

    role: ?*const Role,
    role_data: ?*anyopaque,

    events: extern struct {
        commit: wl.Signal(*wlr.Surface),
        new_subsurface: wl.Signal(*wlr.Subsurface),
        destroy: wl.Signal(*wlr.Surface),
    },

    current_outputs: wl.list.Head(Surface.Output, "link"),

    addons: wlr.AddonSet,
    data: usize,

    // private state

    renderer_destroy: wl.Listener(*wlr.Renderer),

    previous: extern struct {
        scale: i32,
        transform: wl.Output.Transform,
        width: c_int,
        height: c_int,
        buffer_width: c_int,
        buffer_height: c_int,
    },

    extern fn wlr_surface_set_role(
        surface: *Surface,
        role: *const Role,
        role_data: ?*anyopaque,
        error_resource: ?*wl.Resource,
        error_code: u32,
    ) bool;
    pub const setRole = wlr_surface_set_role;

    // Just check if Surface.buffer is null, that's all this function does
    extern fn wlr_surface_has_buffer(surface: *Surface) bool;

    extern fn wlr_surface_get_texture(surface: *Surface) ?*wlr.Texture;
    pub const getTexture = wlr_surface_get_texture;

    extern fn wlr_surface_get_root_surface(surface: *Surface) ?*Surface;
    pub const getRootSurface = wlr_surface_get_root_surface;

    extern fn wlr_surface_point_accepts_input(surface: *Surface, sx: f64, sy: f64) bool;
    pub const pointAcceptsInput = wlr_surface_point_accepts_input;

    extern fn wlr_surface_surface_at(surface: *Surface, sx: f64, sy: f64, sub_x: *f64, sub_y: *f64) ?*Surface;
    pub const surfaceAt = wlr_surface_surface_at;

    extern fn wlr_surface_send_enter(surface: *Surface, output: *wlr.Output) void;
    pub const sendEnter = wlr_surface_send_enter;

    extern fn wlr_surface_send_leave(surface: *Surface, output: *wlr.Output) void;
    pub const sendLeave = wlr_surface_send_leave;

    extern fn wlr_surface_send_frame_done(surface: *Surface, when: *const os.timespec) void;
    pub const sendFrameDone = wlr_surface_send_frame_done;

    extern fn wlr_surface_get_extends(surface: *Surface, box: *wlr.Box) void;
    pub const getExtends = wlr_surface_get_extends;

    extern fn wlr_surface_from_resource(resource: *wl.Surface) *Surface;
    pub const fromWlSurface = wlr_surface_from_resource;

    extern fn wlr_surface_for_each_surface(
        surface: *Surface,
        iterator: fn (surface: *Surface, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void,
        user_data: ?*anyopaque,
    ) void;
    pub inline fn forEachSurface(
        surface: *Surface,
        comptime T: type,
        iterator: fn (surface: *Surface, sx: c_int, sy: c_int, data: T) callconv(.C) void,
        data: T,
    ) void {
        wlr_surface_for_each_surface(
            surface,
            @ptrCast(fn (surface: *Surface, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void, iterator),
            data,
        );
    }

    extern fn wlr_surface_get_effective_damage(surface: *Surface, damage: *pixman.Region32) void;
    pub const getEffectiveDamage = wlr_surface_get_effective_damage;

    extern fn wlr_surface_get_buffer_source_box(surface: *Surface, box: *wlr.FBox) void;
    pub const getBufferSourceBox = wlr_surface_get_buffer_source_box;

    extern fn wlr_surface_accepts_touch(seat: *wlr.Seat, surface: *Surface) bool;
    pub fn acceptsTouch(surface: *Surface, seat: *wlr.Seat) bool {
        return wlr_surface_accepts_touch(seat, surface);
    }

    extern fn wlr_surface_is_xdg_surface(surface: *Surface) bool;
    pub const isXdgSurface = wlr_surface_is_xdg_surface;

    extern fn wlr_surface_is_layer_surface(surface: *Surface) bool;
    pub const isLayerSurface = wlr_surface_is_layer_surface;

    extern fn wlr_surface_is_xwayland_surface(surface: *Surface) bool;
    pub const isXWaylandSurface = wlr_surface_is_xwayland_surface;

    extern fn wlr_surface_lock_pending(surface: *Surface) u32;
    pub const lockPending = wlr_surface_lock_pending;

    extern fn wlr_surface_unlock_cached(surface: *Surface, seq: u32) void;
    pub const unlockCached = wlr_surface_unlock_cached;

    extern fn wlr_surface_is_subsurface(surface: *Surface) bool;
    pub const isSubsurface = wlr_surface_is_subsurface;
};

pub const Subsurface = extern struct {
    pub const ParentState = extern struct {
        x: i32,
        y: i32,
        /// Surface.State.subsurfaces_above/subsurfaces_below
        link: wl.list.Link,
    };

    resource: *wl.Subsurface,
    surface: *Surface,
    parent: ?*Surface,

    current: ParentState,
    pending: ParentState,

    cached_seq: u32,
    has_cache: bool,

    synchronized: bool,
    reordered: bool,
    mapped: bool,
    added: bool,

    surface_destroy: wl.Listener(*Surface),
    parent_destroy: wl.Listener(*Surface),

    events: extern struct {
        destroy: wl.Signal(*Subsurface),
        map: wl.Signal(*Subsurface),
        unmap: wl.Signal(*Subsurface),
    },

    data: usize,

    extern fn wlr_subsurface_from_wlr_surface(surface: *Surface) ?*wlr.Subsurface;
    pub const fromWlrSurface = wlr_subsurface_from_wlr_surface;
};
