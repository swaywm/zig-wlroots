const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const DmabufBufferV1 = extern struct {
    base: wlr.Buffer,

    resource: ?*wl.Resource,
    attributes: wlr.DmabufAttributes,

    release: wl.Listener(void),

    extern fn wlr_dmabuf_v1_resource_is_buffer(buffer_resource: *wl.Resource) bool;
    pub const resourceIsBuffer = wlr_dmabuf_v1_resource_is_buffer;

    extern fn wlr_dmabuf_v1_buffer_from_buffer_resource(buffer_resource: *wl.Resource) *DmabufBufferV1;
    pub const fromBufferResource = wlr_dmabuf_v1_buffer_from_buffer_resource;
};

pub const LinuxDmabufV1 = extern struct {
    global: *wl.Global,
    renderer: *wlr.Renderer,

    events: extern struct {
        destroy: wl.Signal(*LinuxDmabufV1),
    },

    server_destroy: wl.Listener(*wl.Server),
    renderer_destroy: wl.Listener(*wlr.Renderer),

    extern fn wlr_linux_dmabuf_v1_create(server: *wl.Server, renderer: *wlr.Renderer) ?*LinuxDmabufV1;
    pub fn create(server: *wl.Server, renderer: *wlr.Renderer) !*LinuxDmabufV1 {
        return wlr_linux_dmabuf_v1_create(server, renderer) orelse error.OutOfMemory;
    }
};

pub const LinuxDmabufParamsV1 = extern struct {
    resource: *wl.Resource,
    linux_dmabuf: *LinuxDmabufV1,
    attributes: wlr.DmabufAttributes,
    has_modifier: bool,
};
