const wlr = @import("../wlroots.zig");

const os = @import("std").os;

const pixman = @import("pixman");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Output = extern struct {
    pub const Mode = extern struct {
        width: i32,
        height: i32,
        refresh: i32,
        preferred: bool,
        /// Output.modes
        link: wl.list.Link,
    };

    pub const AdaptiveSyncStatus = extern enum {
        disabled,
        enabled,
        unknown,
    };

    pub const State = extern struct {
        pub const field = struct {
            pub const buffer = 1 << 0;
            pub const damage = 1 << 1;
            pub const mode = 1 << 2;
            pub const enabled = 1 << 3;
            pub const scale = 1 << 4;
            pub const transform = 1 << 5;
            pub const adaptive_sync_enabled = 1 << 6;
            pub const gamma_lut = 1 << 7;
        };

        pub const BufferType = extern enum {
            render,
            scanout,
        };

        pub const ModeType = extern enum {
            fixed,
            custom,
        };

        /// This is a bitfield of State.field members
        committed: u32,
        damage: pixman.Region32,
        enabled: bool,
        scale: f32,
        transform: wl.Output.Transform,
        adaptive_sync_enabled: bool,

        // if (committed & field.buffer)
        buffer_type: BufferType,
        buffer: ?*wlr.Buffer,

        // if (committed & field.mode)
        mode_type: ModeType,
        mode: ?*Mode,
        custom_mode: extern struct {
            width: i32,
            height: i32,
            refresh: i32,
        },

        // if (committed & field.gamma_lut)
        gamma_lut: ?[*]u16,
        gamma_lut_size: usize,
    };

    pub const Cursor = extern struct {
        output: *wlr.Output,
        x: f64,
        y: f64,
        enabled: bool,
        visible: bool,
        width: u32,
        height: u32,
        hotspot_x: i32,
        hotspot_y: i32,
        /// Output.cursors
        link: wl.list.Link,

        /// only when using a software cursor without a surface
        texture: ?*wlr.Texture,

        /// only when using a cursor surface
        surface: ?*wlr.Surface,
        surface_commit: wl.Listener(*wlr.Surface),
        surface_destroy: wl.Listener(*wlr.Surface),

        events: extern struct {
            destroy: wl.Signal(*Output.Cursor),
        },

        extern fn wlr_output_cursor_create(output: *Output) ?*Cursor;
        pub const create = wlr_output_cursor_create;

        extern fn wlr_output_cursor_set_image(cursor: *Cursor, pixels: ?[*]const u8, stride: i32, width: u32, height: u32, hotspot_x: i32, hotspot_y: i32) bool;
        pub const setImage = wlr_output_cursor_set_image;

        extern fn wlr_output_cursor_set_surface(cursor: *Cursor, surface: ?*wlr.Surface, hotspot_x: i32, hotspot_y: i32) void;
        pub const setSurface = wlr_output_cursor_set_surface;

        extern fn wlr_output_cursor_move(cursor: *Cursor, x: f64, y: f64) bool;
        pub const move = wlr_output_cursor_move;

        extern fn wlr_output_cursor_destroy(cursor: *Cursor) void;
        pub const destroy = wlr_output_cursor_destroy;
    };

    pub const event = struct {
        pub const Damage = extern struct {
            output: *wlr.Output,
            /// In output buffer local coordinates
            damage: *pixman.Region32,
        };

        pub const Precommit = extern struct {
            output: *wlr.Output,
            when: *os.timespec,
        };

        pub const Commit = extern struct {
            output: *wlr.Output,
            /// This is a bitfield of State.field members
            comitted: u32,
        };

        pub const Present = extern struct {
            pub const flag = struct {
                const vsync = 1 << 0;
                const hw_clock = 1 << 1;
                const hw_completion = 1 << 2;
                const zero_copy = 1 << 3;
            };

            output: *wlr.Output,
            commit_seq: u32,
            when: *os.timespec,
            seq: c_uint,
            refresh: c_int,
            /// This is a bitfield of Present.flag members
            flags: u32,
        };
    };

    const Impl = opaque {};

    impl: *const Impl,
    backend: *wlr.Backend,
    server: *wl.Server,

    global: *wl.Global,
    resources: wl.list.Head(wl.Output, null),

    name: [24]u8,
    description: ?[*:0]u8,
    make: [56]u8,
    model: [16]u8,
    serial: [16]u8,
    phys_width: i32,
    phys_height: i32,

    modes: wl.list.Head(Output.Mode, "link"),
    current_mode: *Output.Mode,
    width: i32,
    height: i32,
    refresh: i32,

    enabled: bool,
    scale: f32,
    subpixel: wl.Output.Subpixel,
    transform: wl.Output.Transform,
    adaptive_sync_status: AdaptiveSyncStatus,

    needs_frame: bool,
    frame_pending: bool,
    transform_matrix: [9]f32,

    pending: State,

    commit_seq: u32,

    events: extern struct {
        frame: wl.Signal(*Output),
        damage: wl.Signal(*event.Damage),
        needs_frame: wl.Signal(*Output),
        precommit: wl.Signal(*event.Precommit),
        commit: wl.Signal(*event.Commit),
        present: wl.Signal(*event.Present),
        enable: wl.Signal(*Output),
        mode: wl.Signal(*Output),
        scale: wl.Signal(*Output),
        transform: wl.Signal(*Output),
        description: wl.Signal(*Output),
        destroy: wl.Signal(*Output),
    },

    idle_frame: *wl.EventSource,
    idle_done: *wl.EventSource,

    attach_render_locks: c_int,

    cursors: wl.list.Head(Output.Cursor, "link"),

    hardware_cursor: *Output.Cursor,
    software_cursor_locks: c_int,

    server_destroy: wl.Listener(*wl.Server),

    data: usize,

    extern fn wlr_output_enable(output: *Output, enable: bool) void;
    pub const enable = wlr_output_enable;

    extern fn wlr_output_create_global(output: *Output) void;
    pub const createGlobal = wlr_output_create_global;

    extern fn wlr_output_destroy_global(output: *Output) void;
    pub const destroyGlobal = wlr_output_destroy_global;

    extern fn wlr_output_preferred_mode(output: *Output) ?*Mode;
    pub const preferredMode = wlr_output_preferred_mode;

    extern fn wlr_output_set_mode(output: *Output, mode: *Mode) void;
    pub const setMode = wlr_output_set_mode;

    extern fn wlr_output_set_custom_mode(output: *Output, width: i32, height: i32, refresh: i32) void;
    pub const setCustomMode = wlr_output_set_custom_mode;

    extern fn wlr_output_set_transform(output: *Output, transform: wl.Output.Transform) void;
    pub const setTransform = wlr_output_set_transform;

    extern fn wlr_output_enable_adaptive_sync(output: *Output, enabled: bool) void;
    pub const enableAdaptiveSync = wlr_output_enable_adaptive_sync;

    extern fn wlr_output_set_scale(output: *Output, scale: f32) void;
    pub const setScale = wlr_output_set_scale;

    extern fn wlr_output_set_subpixel(output: *Output, subpixel: wl.Output.Subpixel) void;
    pub const setSubpixel = wlr_output_set_subpixel;

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

    extern fn wlr_output_attach_render(output: *Output, buffer_age: ?*c_int) bool;
    pub const attachRender = wlr_output_attach_render;

    extern fn wlr_output_attach_buffer(output: *Output, buffer: *wlr.Buffer) void;
    pub const attachBuffer = wlr_output_attach_buffer;

    extern fn wlr_output_preferred_read_format(output: *Output, fmt: *wl.Shm.Format) bool;
    pub const preferredReadFormat = wlr_output_preferred_read_format;

    extern fn wlr_output_set_damage(output: *Output, damage: *pixman.Region32) void;
    pub const setDamage = wlr_output_set_damage;

    extern fn wlr_output_test(output: *Output) bool;
    pub const @"test" = wlr_output_test;

    extern fn wlr_output_commit(output: *Output) bool;
    pub const commit = wlr_output_commit;

    extern fn wlr_output_rollback(output: *Output) void;
    pub const rollback = wlr_output_rollback;

    extern fn wlr_output_schedule_frame(output: *Output) void;
    pub const scheduleFrame = wlr_output_schedule_frame;

    extern fn wlr_output_get_gamma_size(output: *Output) usize;
    pub const getGammaSize = wlr_output_get_gamma_size;

    extern fn wlr_output_set_gamma(output: *Output, size: usize, r: [*]const u16, g: [*]const u16, b: [*]const u16) void;
    pub const setGamma = wlr_output_set_gamma;

    extern fn wlr_output_export_dmabuf(output: *Output, attribs: *wlr.DmabufAttributes) bool;
    pub const exportDmabuf = wlr_output_export_dmabuf;

    extern fn wlr_output_from_resource(resource: *Output) ?*Output;
    pub const fromResource = wlr_output_from_resource;

    extern fn wlr_output_lock_attach_render(output: *Output, lock: bool) void;
    pub const lockAttachRender = wlr_output_lock_attach_render;

    extern fn wlr_output_lock_software_cursors(output: *Output, lock: bool) void;
    pub const lockSoftwareCursors = wlr_output_lock_software_cursors;

    extern fn wlr_output_render_software_cursors(output: *Output, damage: ?*pixman.Region32) void;
    pub const renderSoftwareCursors = wlr_output_render_software_cursors;

    extern fn wlr_output_transform_invert(tr: wl.Output.Transform) wl.Output.Transform;
    pub const transformInvert = wlr_output_transform_invert;

    extern fn wlr_output_transform_compose(tr_a: wl.Output.Transform, tr_b: wl.Output.Transform) wl.Output.Transform;
    pub const transformCompose = wlr_output_transform_compose;

    extern fn wlr_output_is_noop(output: *Output) bool;
    pub const isNoop = wlr_output_is_noop;
};
