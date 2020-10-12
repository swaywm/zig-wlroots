const wlr = @import("wlroots.zig");

const os = @import("std").os;

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Output = extern struct {
    pub const Mode = extern struct {
        width: i32,
        height: i32,
        refresh: i32,
        preferred: bool,
        link: wl.List,
    };

    pub const AdaptiveSyncStatus = extern enum {
        disabled,
        enabled,
        unknown,
    };

    pub const State = extern struct {
        pub const field = struct {
            const buffer = 1 << 0;
            const damage = 1 << 1;
            const mode = 1 << 2;
            const enabled = 1 << 3;
            const scale = 1 << 4;
            const transform = 1 << 5;
            const adaptive_sync_enabled = 1 << 6;
            const gamma_lut = 1 << 7;
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
        damage: pixman_region32_t,
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
        link: wl.List,

        /// only when using a software cursor without a surface
        texture: ?*wlr.Texture,

        /// only when using a cursor surface
        surface: ?*wlr.Surface,
        surface_commit: wl.Listener,
        surface_destroy: wl.Listener,

        events: extern struct {
            destroy: wl.Signal,
        },
    };

    pub const event = struct {
        pub const Damage = extern struct {
            output: *wlr.Output,
            /// In output buffer local coordinates
            damage: *pixman_region32_t,
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
    resources: wl.List,

    name: [24]u8,
    description: ?[*:0]u8,
    make: [56]u8,
    model: [16]u8,
    serial: [16]u8,
    phys_width: i32,
    phys_height: i32,

    modes: wl.List,
    current_mode: *Mode,
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
        frame: wl.Signal,
        damage: wl.Signal, // event.Damage
        needs_frame: wl.Signal,
        precommit: wl.Signal, // event.Precommit
        commit: wl.Signal, // event.Commit
        present: wl.Signal, // event.Present
        enable: wl.Signal,
        mode: wl.Signal,
        scale: wl.Signal,
        transform: wl.Signal,
        description: wl.Signal,
        destroy: wl.Signal,
    },

    idle_frame: *wl.EventSource,
    idle_done: *wl.EventSource,

    attach_render_locks: c_int,

    cursors: wl.List,

    hardware_cursor: *Cursor,
    software_cursor_locks: c_int,

    display_destroy: wl.Listener,

    data: ?*c_void,
};
