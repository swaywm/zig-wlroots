const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const ScreencopyManagerV1 = extern struct {
    global: ?*struct_wl_global,
    frames: wl.List,
    server_destroy: wl.Listener(*wl.Server),
    events: extern struct {
        destroy: wl.Signal(*ScreencopyManagerV1),
    },
    data: ?*c_void,

    extern fn wlr_screencopy_manager_v1_create(server: *wl.Server) ?*ScreencopyManagerV1;
    pub const create = wlr_screencopy_manager_v1_create;
};

pub const ScreencopyClientV1 = extern struct {
    ref: c_int,
    manager: *ScreencopyManagerV1,
    damages: wl.List,
};

pub const ScreencopyFrameV1 = extern struct {
    resource: *wl.Resource,
    client: *ScreencopyClientV1,
    link: wl.List,

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
    output_precommit: wl.Listener(*wlr.Output.event.Precommit),
    output_destroy: wl.Listener(*wlr.Output),
    output_enable: wl.Listener(*wlr.Output),

    data: ?*c_void,
};
