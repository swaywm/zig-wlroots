const wlr = @import("../wlroots.zig");

const std = @import("std");
const mem = std.mem;
const posix = std.posix;

const pixman = @import("pixman");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Output = extern struct {
    pub const Mode = extern struct {
        pub const AspectRatio = enum(c_int) {
            none,
            @"4_3",
            @"16_9",
            @"64_27",
            @"256_135",
        };

        width: i32,
        height: i32,
        refresh: i32,
        preferred: bool,
        picture_aspect_ratio: AspectRatio,
        /// Output.modes
        link: wl.list.Link,
    };

    pub const AdaptiveSyncStatus = enum(c_int) {
        disabled,
        enabled,
    };

    pub const State = extern struct {
        pub const Fields = packed struct(u32) {
            buffer: bool = false,
            damage: bool = false,
            mode: bool = false,
            enabled: bool = false,
            scale: bool = false,
            transform: bool = false,
            adaptive_sync_enabled: bool = false,
            gamma_lut: bool = false,
            render_format: bool = false,
            subpixel: bool = false,
            layers: bool = false,
            wait_timeline: bool = false,
            signal_timeline: bool = false,
            _: u19 = 0,
        };

        pub const ModeType = enum(c_int) {
            fixed,
            custom,
        };

        committed: Fields,
        allow_reconfiguration: bool,
        damage: pixman.Region32,
        enabled: bool,
        scale: f32,
        transform: wl.Output.Transform,
        adaptive_sync_enabled: bool,
        render_format: u32,
        subpixel: wl.Output.Subpixel,

        buffer: ?*wlr.Buffer,
        buffer_src_box: wlr.FBox,
        buffer_dst_box: wlr.Box,

        tearing_page_flip: bool,

        mode_type: ModeType,
        mode: ?*Mode,
        custom_mode: extern struct {
            width: i32,
            height: i32,
            refresh: i32,
        },

        gamma_lut: ?[*]u16,
        gamma_lut_size: usize,

        // TODO: Bind wlr_output_layer and related structs
        layers: ?*opaque {},
        layers_len: usize,

        wait_timeline: ?*wlr.DrmSyncobjTimeline,
        wait_point: u64,

        signal_timeline: ?*wlr.DrmSyncobjTimeline,
        signal_point: u64,

        extern fn wlr_output_state_init(state: *State) void;
        pub fn init() State {
            var state: State = undefined;
            wlr_output_state_init(&state);
            return state;
        }

        extern fn wlr_output_state_finish(state: *State) void;
        pub const finish = wlr_output_state_finish;

        extern fn wlr_output_state_set_enabled(state: *State, enabled: bool) void;
        pub const setEnabled = wlr_output_state_set_enabled;

        extern fn wlr_output_state_set_mode(state: *State, mode: *Mode) void;
        pub const setMode = wlr_output_state_set_mode;

        extern fn wlr_output_state_set_custom_mode(state: *State, width: i32, height: i32, refresh: i32) void;
        pub const setCustomMode = wlr_output_state_set_custom_mode;

        extern fn wlr_output_state_set_scale(state: *State, scale: f32) void;
        pub const setScale = wlr_output_state_set_scale;

        extern fn wlr_output_state_set_transform(state: *State, transform: wl.Output.Transform) void;
        pub const setTransform = wlr_output_state_set_transform;

        extern fn wlr_output_state_set_adaptive_sync_enabled(state: *State, enabled: bool) void;
        pub const setAdaptiveSyncEnabled = wlr_output_state_set_adaptive_sync_enabled;

        extern fn wlr_output_state_set_render_format(state: *State, format: u32) void;
        pub const setRenderFormat = wlr_output_state_set_render_format;

        extern fn wlr_output_state_set_subpixel(state: *State, subpixel: wl.Output.Subpixel) void;
        pub const setSubpixel = wlr_output_state_set_subpixel;

        extern fn wlr_output_state_set_buffer(state: *State, buffer: *wlr.Buffer) void;
        pub const setBuffer = wlr_output_state_set_buffer;

        extern fn wlr_output_state_set_gamma_lut(state: *State, ramp_size: usize, r: *const u16, g: *const u16, b: *const u16) bool;
        pub const setGammaLut = wlr_output_state_set_gamma_lut;

        /// Clearing the gamma lut can't fail. Furthermore, a separate function for this
        /// allows using non-optional pointers for the r/b/g parameters of setGammaLut.
        pub fn clearGammaLut(state: *State) void {
            state.committed.gamma_lut = true;

            std.c.free(state.gamma_lut);
            state.gamma_lut = null;
            state.gamma_lut_size = 0;
        }

        extern fn wlr_output_state_set_damage(state: *State, damage: *const pixman.Region32) void;
        pub const setDamage = wlr_output_state_set_damage;

        extern fn wlr_output_state_copy(dst: *State, src: *const State) bool;
        pub const copy = wlr_output_state_copy;
    };

    pub const event = struct {
        pub const Damage = extern struct {
            output: *wlr.Output,
            /// In output buffer local coordinates
            damage: *const pixman.Region32,
        };

        pub const Precommit = extern struct {
            output: *wlr.Output,
            when: *posix.timespec,
            state: *const State,
        };

        pub const Commit = extern struct {
            output: *wlr.Output,
            when: *posix.timespec,
            state: *const Output.State,
        };

        pub const Present = extern struct {
            pub const Flags = packed struct(u32) {
                vsync: bool = false,
                hw_clock: bool = false,
                hw_completion: bool = false,
                zero_copy: bool = false,
                _: u28 = 0,
            };

            output: *wlr.Output,
            commit_seq: u32,
            presented: bool,
            when: posix.timespec,
            seq: c_uint,
            refresh: c_int,
            flags: Flags,
        };

        pub const Bind = extern struct {
            output: *wlr.Output,
            resource: *wl.Output,
        };

        pub const RequestState = extern struct {
            output: *wlr.Output,
            state: *const wlr.Output.State,
        };
    };

    const Impl = opaque {};

    impl: *const Impl,
    backend: *wlr.Backend,
    event_loop: *wl.EventLoop,

    global: ?*wl.Global,
    resources: wl.list.Head(wl.Output, null),

    name: [*:0]u8,
    description: ?[*:0]u8,
    make: ?[*:0]u8,
    model: ?[*:0]u8,
    serial: ?[*:0]u8,
    phys_width: i32,
    phys_height: i32,

    modes: wl.list.Head(Output.Mode, .link),
    current_mode: ?*Output.Mode,
    width: i32,
    height: i32,
    refresh: i32,

    enabled: bool,
    scale: f32,
    subpixel: wl.Output.Subpixel,
    transform: wl.Output.Transform,
    adaptive_sync_status: AdaptiveSyncStatus,
    render_format: u32,

    adaptive_sync_supported: bool,

    needs_frame: bool,
    frame_pending: bool,

    non_desktop: bool,

    commit_seq: u32,

    events: extern struct {
        frame: wl.Signal(*Output),
        damage: wl.Signal(*event.Damage),
        needs_frame: wl.Signal(*Output),
        precommit: wl.Signal(*event.Precommit),
        commit: wl.Signal(*event.Commit),
        present: wl.Signal(*event.Present),
        bind: wl.Signal(*event.Bind),
        description: wl.Signal(*Output),
        request_state: wl.Signal(*event.RequestState),
        destroy: wl.Signal(*Output),
    },

    idle_frame: ?*wl.EventSource,
    idle_done: ?*wl.EventSource,

    attach_render_locks: c_int,

    cursors: wl.list.Head(OutputCursor, .link),

    hardware_cursor: ?*OutputCursor,
    cursor_swapchain: ?*wlr.Swapchain,
    cursor_front_buffer: ?*wlr.Buffer,
    software_cursor_locks: c_int,

    // TODO: Bind wlr_output_layer and related structs
    layers: wl.list.Link,

    allocator: ?*wlr.Allocator,
    renderer: ?*wlr.Renderer,
    swapchain: ?*wlr.Swapchain,

    addons: wlr.AddonSet,

    data: ?*anyopaque,

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_output_create_global(output: *Output, server: *wl.Server) void;
    pub const createGlobal = wlr_output_create_global;

    extern fn wlr_output_destroy_global(output: *Output) void;
    pub const destroyGlobal = wlr_output_destroy_global;

    extern fn wlr_output_init_render(output: *Output, allocator: *wlr.Allocator, renderer: *wlr.Renderer) bool;
    pub const initRender = wlr_output_init_render;

    extern fn wlr_output_preferred_mode(output: *Output) ?*Mode;
    pub const preferredMode = wlr_output_preferred_mode;

    extern fn wlr_output_set_name(output: *Output, name: [*:0]const u8) void;
    pub const setName = wlr_output_set_name;

    extern fn wlr_output_set_description(output: *Output, desc: [*:0]const u8) void;
    pub const setDescription = wlr_output_set_description;

    extern fn wlr_output_schedule_done(output: *Output) void;
    pub const scheduleDone = wlr_output_schedule_done;

    extern fn wlr_output_destroy(output: *Output) void;
    pub const destroy = wlr_output_destroy;

    extern fn wlr_output_transformed_resolution(output: *Output, width: *c_int, height: *c_int) void;
    pub const transformedResolution = wlr_output_transformed_resolution;

    extern fn wlr_output_effective_resolution(output: *Output, width: *c_int, height: *c_int) void;
    pub const effectiveResolution = wlr_output_effective_resolution;

    extern fn wlr_output_test_state(output: *Output, state: *const Output.State) bool;
    pub const testState = wlr_output_test_state;

    extern fn wlr_output_commit_state(output: *Output, state: *const Output.State) bool;
    pub const commitState = wlr_output_commit_state;

    extern fn wlr_output_schedule_frame(output: *Output) void;
    pub const scheduleFrame = wlr_output_schedule_frame;

    extern fn wlr_output_get_gamma_size(output: *Output) usize;
    pub const getGammaSize = wlr_output_get_gamma_size;

    extern fn wlr_output_from_resource(resource: *wl.Output) ?*Output;
    pub const fromWlOutput = wlr_output_from_resource;

    extern fn wlr_output_lock_attach_render(output: *Output, lock: bool) void;
    pub const lockAttachRender = wlr_output_lock_attach_render;

    extern fn wlr_output_lock_software_cursors(output: *Output, lock: bool) void;
    pub const lockSoftwareCursors = wlr_output_lock_software_cursors;

    extern fn wlr_output_is_direct_scanout_allowed(output: *Output) bool;
    pub const isDirectScanoutAllowed = wlr_output_is_direct_scanout_allowed;

    // TODO render pass API

    extern fn wlr_output_is_drm(output: *Output) bool;
    pub const isDrm = wlr_output_is_drm;

    extern fn wlr_drm_connector_get_id(output: *Output) u32;
    pub const drmConnectorGetId = wlr_drm_connector_get_id;

    extern fn wlr_drm_create_lease(outputs: [*]*Output, n_outputs: usize, lease_fd: *c_int) ?*wlr.Backend.DrmLease;
    pub fn drmCreateLease(outputs: []*Output, lease_fd: *c_int) !*wlr.Backend.DrmLease {
        return wlr_drm_create_lease(outputs.ptr, outputs.len, lease_fd) orelse error.DrmLeaseCreateFailed;
    }

    extern fn wlr_drm_connector_add_mode(output: *Output, mode: *const drmModeModeInfo) ?*Output.Mode;
    pub const drmConnectorAddMode = wlr_drm_connector_add_mode;

    extern fn wlr_drm_mode_get_info(mode: *Output.Mode) *const drmModeModeInfo;
    pub const drmModeGetInfo = wlr_drm_mode_get_info;

    extern fn wlr_drm_connector_get_panel_orientation(output: *Output) wl.Output.Transform;
    pub const drmConnectorGetPanelOrientation = wlr_drm_connector_get_panel_orientation;

    extern fn wlr_output_is_headless(outupt: *Output) bool;
    pub const isHeadless = wlr_output_is_headless;

    extern fn wlr_output_is_wl(output: *Output) bool;
    pub const isWl = wlr_output_is_wl;

    extern fn wlr_wl_output_set_title(output: *Output, title: ?[*:0]const u8) void;
    pub const wlSetTitle = wlr_wl_output_set_title;

    extern fn wlr_wl_output_set_app_id(output: *Output, app_id: ?[*:0]const u8) void;
    pub const wlSetAppId = wlr_wl_output_set_app_id;

    extern fn wlr_wl_output_get_surface(output: *Output) *wayland.client.wl.Surface;
    pub const wlGetSurface = wlr_wl_output_get_surface;

    extern fn wlr_output_is_x11(output: *Output) bool;
    pub const isX11 = wlr_output_is_x11;

    extern fn wlr_x11_output_set_title(output: *Output, title: ?[*:0]const u8) void;
    pub const x11SetTitle = wlr_x11_output_set_title;
};

pub const OutputCursor = extern struct {
    output: *wlr.Output,
    x: f64,
    y: f64,
    enabled: bool,
    visible: bool,
    width: u32,
    height: u32,
    src_box: wlr.FBox,
    transform: wl.Output.Transform,
    hotspot_x: i32,
    hotspot_y: i32,
    texture: ?*wlr.Texture,
    own_texture: bool,
    wait_timeline: ?*wlr.DrmSyncobjTimeline,
    wait_point: u64,
    /// Output.cursors
    link: wl.list.Link,

    private: extern struct {
        renderer_destroy: wl.Listener(void),
    },

    extern fn wlr_output_cursor_create(output: *Output) ?*OutputCursor;
    pub fn create(output: *Output) !*OutputCursor {
        return wlr_output_cursor_create(output) orelse error.OutOfMemory;
    }

    extern fn wlr_output_cursor_set_buffer(cursor: *OutputCursor, buffer: *wlr.Buffer, hotspot_x: i32, hotspot_y: i32) bool;
    pub const setBuffer = wlr_output_cursor_set_buffer;

    extern fn wlr_output_cursor_move(cursor: *OutputCursor, x: f64, y: f64) bool;
    pub const move = wlr_output_cursor_move;

    extern fn wlr_output_cursor_destroy(cursor: *OutputCursor) void;
    pub const destroy = wlr_output_cursor_destroy;
};

const drmModeModeInfo = opaque {};
