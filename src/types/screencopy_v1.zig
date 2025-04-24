const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const ScreencopyManagerV1 = extern struct {
    global: *wl.Global,
    frames: wl.list.Head(ScreencopyFrameV1, .link),

    events: extern struct {
        destroy: wl.Signal(*ScreencopyManagerV1),
    },

    data: ?*anyopaque,

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_screencopy_manager_v1_create(server: *wl.Server) ?*ScreencopyManagerV1;
    pub fn create(server: *wl.Server) !*ScreencopyManagerV1 {
        return wlr_screencopy_manager_v1_create(server) orelse error.OutOfMemory;
    }
};

pub const ScreencopyClientV1 = extern struct {
    ref: c_int,
    manager: *ScreencopyManagerV1,
    // A list head, but usage is internal to wlroots
    damages: wl.list.Link,
};

pub const ScreencopyFrameV1 = extern struct {
    resource: *wl.Resource,
    client: *ScreencopyClientV1,
    /// ScreencopyManagerV1.frames
    link: wl.list.Link,

    shm_format: u32,
    dmabuf_format: u32,
    box: wlr.Box,
    shm_stride: c_int,

    overlay_cursor: bool,
    cursor_locked: bool,

    with_damage: bool,

    buffer_cap: wlr.BufferCap,
    buffer: *wlr.Buffer,

    output: *wlr.Output,

    data: ?*anyopaque,

    private: extern struct {
        output_commit: wl.Listener(void),
        output_destroy: wl.Listener(void),
    },
};
