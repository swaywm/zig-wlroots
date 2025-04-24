const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const ExportDmabufManagerV1 = extern struct {
    global: *wl.Global,
    frames: wl.list.Head(ExportDmabufFrameV1, .link),

    events: extern struct {
        destroy: wl.Signal(*ExportDmabufManagerV1),
    },

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_export_dmabuf_manager_v1_create(server: *wl.Server) ?*ExportDmabufManagerV1;
    pub fn create(server: *wl.Server) !*ExportDmabufManagerV1 {
        return wlr_export_dmabuf_manager_v1_create(server) orelse error.OutOfMemory;
    }
};

pub const ExportDmabufFrameV1 = extern struct {
    resource: *wl.Resource,
    manager: *ExportDmabufManagerV1,
    /// ExportDmabufManagerV1.frames
    link: wl.list.Link,

    output: ?*wlr.Output,

    cursor_locked: bool,

    private: extern struct {
        output_commit: wl.Listener(void),
        output_destroy: wl.Listener(void),
    },
};
