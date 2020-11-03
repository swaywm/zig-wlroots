const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const ExportDmabufManagerV1 = extern struct {
    global: *wl.Global,
    /// ExportDmabufFrameV1.link
    frames: wl.List,

    server_destroy: wl.Listener(*wl.Server),

    events: extern struct {
        destroy: wl.Listener(*ExportDmabufManagerV1),
    },

    extern fn wlr_export_dmabuf_manager_v1_create(server: *wl.Server) ?*ExportDmabufManagerV1;
    pub const create = wlr_export_dmabuf_manager_v1_create;
};

pub const ExportDmabufFrameV1 = extern struct {
    resource: *wl.Resource,
    manager: *ExportDmabufManagerV1,
    /// ExportDmabufManagerV1.frames
    link: wl.List,

    attribs: wlr.DmabufAttributes,
    output: ?*wlr.Output,
    cursor_locked: bool,
    output_precommit: wl.Listener(*wlr.Output.event.Precommit),
};
