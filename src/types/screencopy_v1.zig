const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const ScreencopyManagerV1 = extern struct {
    global: *wl.Global,
    frames: wl.list.Head(ScreencopyFrameV1, "link"),
    server_destroy: wl.Listener(*wl.Server),
    events: extern struct {
        destroy: wl.Signal(*ScreencopyManagerV1),
    },
    data: usize,

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

    format: wl.Shm.Format,
    fourcc: u32,
    box: wlr.Box,
    stride: c_int,

    overlay_cursor: bool,
    cursor_locked: bool,

    with_damage: bool,

    shm_buffer: ?*wl.shm.Buffer,
    dma_buffer: ?*wlr.DmabufBufferV1,

    buffer_destroy: wl.Listener(*wl.Resource),

    output: *wlr.Output,
    output_commit: wl.Listener(*wlr.Output.event.Commit),
    output_destroy: wl.Listener(*wlr.Output),
    output_enable: wl.Listener(*wlr.Output),

    data: usize,
};
