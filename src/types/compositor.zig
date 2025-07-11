const wlr = @import("../wlroots.zig");

const posix = @import("std").posix;

const pixman = @import("pixman");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Compositor = extern struct {
    global: *wl.Global,
    renderer: ?*wlr.Renderer,

    events: extern struct {
        new_surface: wl.Signal(*wlr.Surface),
        destroy: wl.Signal(*wlr.Compositor),
    },

    private: extern struct {
        server_destroy: wl.Listener(void),
        renderer_destroy: wl.Listener(void),
    },

    extern fn wlr_compositor_create(server: *wl.Server, version: u32, renderer: ?*wlr.Renderer) ?*Compositor;
    pub fn create(server: *wl.Server, version: u32, renderer: ?*wlr.Renderer) !*Compositor {
        return wlr_compositor_create(server, version, renderer) orelse error.OutOfMemory;
    }

    extern fn wlr_compositor_set_renderer(compositor: *Compositor, renderer: ?*wlr.Renderer) void;
    pub const setRenderer = wlr_compositor_set_renderer;
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

        synced: wl.Array,

        extern fn wlr_surface_state_has_buffer(state: *State) bool;
        pub const hasBuffer = wlr_surface_state_has_buffer;
    };

    pub const Role = extern struct {
        name: [*:0]const u8,
        no_object: bool = false,
        client_commit: ?*const fn (surface: *Surface) callconv(.c) void = null,
        commit: ?*const fn (surface: *Surface) callconv(.c) void = null,
        map: ?*const fn (surface: *Surface) callconv(.c) void = null,
        unmap: ?*const fn (surface: *Surface) callconv(.c) void = null,
        destroy: ?*const fn (surface: *Surface) callconv(.c) void = null,
    };

    pub const Output = extern struct {
        surface: *wlr.Surface,
        output: *wlr.Output,

        // Surface.current_outputs
        link: wl.list.Link,

        private: extern struct {
            bind: wl.Listener(void),
            destroy: wl.Listener(void),
        },
    };

    pub const Synced = extern struct {
        pub const Impl = extern struct {
            state_size: usize,
            init_state: ?*const fn (state: *anyopaque) callconv(.c) void,
            finish_state: ?*const fn (state: *anyopaque) callconv(.c) void,
            move_state: ?*const fn (dst: *anyopaque, src: *anyopaque) callconv(.c) void,
            commit: ?*const fn (synced: *Synced) callconv(.c) void = null,
        };

        surface: *Surface,
        impl: *const Impl,
        /// wlr.Surface.synced
        link: wl.list.Link,
        index: usize,

        extern fn wlr_surface_synced_init(
            synced: *Synced,
            surface: *Surface,
            impl: *const Impl,
            pending: *anyopaque,
            current: *anyopaque,
        ) bool;
        pub inline fn init(
            synced: *Synced,
            surface: *Surface,
            impl: *const Impl,
            pending: *anyopaque,
            current: *anyopaque,
        ) error{OutOfMemory}!void {
            if (!wlr_surface_synced_init(synced, surface, impl, pending, current)) {
                return error.OutOfMemory;
            }
        }

        extern fn wlr_surface_synced_finish(synced: *Synced) void;
        pub const deinit = wlr_surface_synced_finish;

        extern fn wlr_surface_synced_get_state(synced: *Synced, state: *const Surface.State) *anyopaque;
        pub const getState = wlr_surface_synced_get_state;
    };

    resource: *wl.Surface,
    compositor: *wlr.Compositor,

    buffer: ?*wlr.ClientBuffer,

    buffer_damage: pixman.Region32,
    opaque_region: pixman.Region32,
    input_region: pixman.Region32,

    current: State,
    pending: State,

    cached: wl.list.Head(Surface.State, .cached_state_link),

    mapped: bool,

    role: ?*const Role,
    role_resource: ?*wl.Resource,

    events: extern struct {
        client_commit: wl.Signal(void),
        commit: wl.Signal(*wlr.Surface),
        map: wl.Signal(void),
        unmap: wl.Signal(void),
        new_subsurface: wl.Signal(*wlr.Subsurface),
        destroy: wl.Signal(*wlr.Surface),
    },

    current_outputs: wl.list.Head(Surface.Output, .link),

    addons: wlr.AddonSet,
    data: ?*anyopaque,

    private: extern struct {
        role_resource_destroy: wl.Listener(void),

        previous: extern struct {
            scale: i32,
            transform: wl.Output.Transform,
            width: c_int,
            height: c_int,
            buffer_width: c_int,
            buffer_height: c_int,
        },

        unmap_commit: bool,

        @"opaque": bool,

        handling_commit: bool,
        pending_rejected: bool,

        preferred_buffer_scale: i32,
        preferred_buffer_transform_sent: bool,
        preferred_buffer_transform: wl.Output.Transform,

        synced: wl.list.Link,
        synced_len: usize,

        pending_buffer_resource: *wl.Resource,
        pending_buffer_resource_destroy: wl.Listener(void),
    },

    extern fn wlr_surface_set_role(
        surface: *Surface,
        role: *const Role,
        error_resource: ?*wl.Resource,
        error_code: u32,
    ) bool;
    pub const setRole = wlr_surface_set_role;

    extern fn wlr_surface_set_role_object(surface: *Surface, role_resource: *wl.Resource) void;
    pub const setRoleObject = wlr_surface_set_role_object;

    extern fn wlr_surface_map(surface: *Surface) void;
    pub const map = wlr_surface_map;

    extern fn wlr_surface_unmap(surface: *Surface) void;
    pub const unmap = wlr_surface_unmap;

    extern fn wlr_surface_has_buffer(surface: *Surface) bool;
    pub const hasBuffer = wlr_surface_has_buffer;

    extern fn wlr_surface_get_texture(surface: *Surface) ?*wlr.Texture;
    pub const getTexture = wlr_surface_get_texture;

    extern fn wlr_surface_get_root_surface(surface: *Surface) *Surface;
    pub const getRootSurface = wlr_surface_get_root_surface;

    extern fn wlr_surface_point_accepts_input(surface: *Surface, sx: f64, sy: f64) bool;
    pub const pointAcceptsInput = wlr_surface_point_accepts_input;

    extern fn wlr_surface_surface_at(surface: *Surface, sx: f64, sy: f64, sub_x: *f64, sub_y: *f64) ?*Surface;
    pub const surfaceAt = wlr_surface_surface_at;

    extern fn wlr_surface_send_enter(surface: *Surface, output: *wlr.Output) void;
    pub const sendEnter = wlr_surface_send_enter;

    extern fn wlr_surface_send_leave(surface: *Surface, output: *wlr.Output) void;
    pub const sendLeave = wlr_surface_send_leave;

    extern fn wlr_surface_send_frame_done(surface: *Surface, when: *const posix.timespec) void;
    pub const sendFrameDone = wlr_surface_send_frame_done;

    extern fn wlr_surface_get_extents(surface: *Surface, box: *wlr.Box) void;
    pub const getExtents = wlr_surface_get_extents;

    extern fn wlr_surface_from_resource(resource: *wl.Surface) *Surface;
    pub const fromWlSurface = wlr_surface_from_resource;

    extern fn wlr_surface_for_each_surface(
        surface: *Surface,
        iterator: *const fn (surface: *Surface, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.c) void,
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
                fn wrapper(s: *Surface, sx: c_int, sy: c_int, d: ?*anyopaque) callconv(.c) void {
                    iterator(s, sx, sy, @ptrCast(@alignCast(d)));
                }
            }.wrapper,
            data,
        );
    }

    extern fn wlr_surface_get_effective_damage(surface: *Surface, damage: *pixman.Region32) void;
    pub const getEffectiveDamage = wlr_surface_get_effective_damage;

    extern fn wlr_surface_get_buffer_source_box(surface: *Surface, box: *wlr.FBox) void;
    pub const getBufferSourceBox = wlr_surface_get_buffer_source_box;

    extern fn wlr_surface_accepts_touch(surface: *Surface, seat: *wlr.Seat) bool;
    pub const acceptsTouch = wlr_surface_accepts_touch;

    extern fn wlr_surface_accepts_tablet_v2(surface: *Surface, tablet: *wlr.TabletV2Tablet) bool;
    pub const acceptsTabletV2 = wlr_surface_accepts_tablet_v2;

    extern fn wlr_surface_lock_pending(surface: *Surface) u32;
    pub const lockPending = wlr_surface_lock_pending;

    extern fn wlr_surface_unlock_cached(surface: *Surface, seq: u32) void;
    pub const unlockCached = wlr_surface_unlock_cached;

    extern fn wlr_surface_set_preferred_buffer_scale(surface: *Surface, scale: i32) void;
    pub const setPreferredBufferScale = wlr_surface_set_preferred_buffer_scale;

    extern fn wlr_surface_set_preferred_buffer_transform(surface: *Surface, transform: wl.Output.Transform) void;
    pub const setPreferredBufferTransform = wlr_surface_set_preferred_buffer_transform;
};
