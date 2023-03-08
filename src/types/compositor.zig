const wlr = @import("../wlroots.zig");

const os = @import("std").os;

const pixman = @import("pixman");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Compositor = extern struct {
    global: *wl.Global,
    renderer: *wlr.Renderer,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        new_surface: wl.Signal(*wlr.Surface),
        destroy: wl.Signal(*wlr.Compositor),
    },

    extern fn wlr_compositor_create(server: *wl.Server, renderer: *wlr.Renderer) ?*Compositor;
    pub fn create(server: *wl.Server, renderer: *wlr.Renderer) !*Compositor {
        return wlr_compositor_create(server, renderer) orelse error.OutOfMemory;
    }
};

pub const Surface = extern struct {
    pub const State = extern struct {
        pub const Fields = packed struct(u32) {
            buffer: bool = false,
            surface_damage: bool = false,
            buffer_damage: bool = false,
            opaque_region: bool = false,
            input_region: bool = false,
            transform: bool = false,
            scale: bool = false,
            frame_callback_list: bool = false,
            viewport: bool = false,
            offset: bool = false,
            _: u22 = 0,
        };

        committed: Fields,
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

        subsurfaces_below: wl.list.Head(wlr.Subsurface.ParentState, .link),
        subsurfaces_above: wl.list.Head(wlr.Subsurface.ParentState, .link),

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
        commit: ?*const fn (surface: *Surface) callconv(.C) void,
        precommit: ?*const fn (surface: *Surface, state: *const State) callconv(.C) void,
        destroy: ?*const fn (surface: *Surface) callconv(.C) void,
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

    cached: wl.list.Head(Surface.State, .cached_state_link),

    role: ?*const Role,
    role_data: ?*anyopaque,

    events: extern struct {
        client_commit: wl.Signal(void),
        commit: wl.Signal(*wlr.Surface),
        new_subsurface: wl.Signal(*wlr.Subsurface),
        destroy: wl.Signal(*wlr.Surface),
    },

    current_outputs: wl.list.Head(Surface.Output, .link),

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

    @"opaque": bool,

    extern fn wlr_surface_set_role(
        surface: *Surface,
        role: *const Role,
        role_data: ?*anyopaque,
        error_resource: ?*wl.Resource,
        error_code: u32,
    ) bool;
    pub const setRole = wlr_surface_set_role;

    extern fn wlr_surface_destroy_role_object(surface: *Surface) void;
    pub const destroyRoleObject = wlr_surface_destroy_role_object;

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
        iterator: *const fn (surface: *Surface, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void,
        user_data: ?*anyopaque,
    ) void;
    pub inline fn forEachSurface(
        surface: *Surface,
        comptime T: type,
        comptime iterator: fn (surface: *Surface, sx: c_int, sy: c_int, data: T) void,
        data: T,
    ) void {
        wlr_surface_for_each_surface(
            surface,
            struct {
                fn wrapper(s: *Surface, sx: c_int, sy: c_int, d: ?*anyopaque) callconv(.C) void {
                    iterator(s, sx, sy, @ptrCast(T, @alignCast(@alignOf(T), d)));
                }
            }.wrapper,
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

    pub usingnamespace if (wlr.config.has_xwayland) struct {
        extern fn wlr_surface_is_xwayland_surface(surface: *Surface) bool;
        pub const isXwaylandSurface = wlr_surface_is_xwayland_surface;
    } else struct {};

    extern fn wlr_surface_is_session_lock_surface_v1(surface: *Surface) bool;
    pub const isSessionLockSurfaceV1 = wlr_surface_is_session_lock_surface_v1;

    extern fn wlr_surface_lock_pending(surface: *Surface) u32;
    pub const lockPending = wlr_surface_lock_pending;

    extern fn wlr_surface_unlock_cached(surface: *Surface, seq: u32) void;
    pub const unlockCached = wlr_surface_unlock_cached;

    extern fn wlr_surface_is_subsurface(surface: *Surface) bool;
    pub const isSubsurface = wlr_surface_is_subsurface;
};
