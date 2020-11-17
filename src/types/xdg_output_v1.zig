const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const XdgOutputManagerV1 = extern struct {
    global: *wl.Global,
    layout: *wlr.OutputLayout,

    /// XdgOutputV1.link
    outputs: wl.List,

    events: extern struct {
        destroy: wl.Signal(*XdgOutputManagerV1),
    },

    server_destroy: wl.Listener(*wl.Server),
    layout_add: wl.Listener(*wlr.OutputLayout),
    layout_change: wl.Listener(*wlr.OutputLayout),
    layout_destroy: wl.Listener(*wlr.OutputLayout),

    extern fn wlr_xdg_output_manager_v1_create(server: *wl.Server, layout: *wlr.OutputLayout) ?*XdgOutputManagerV1;
    pub const create = wlr_xdg_output_manager_v1_create;
};

pub const XdgOutputV1 = extern struct {
    manager: *XdgOutputManagerV1,
    /// wl.Resource.getLink()
    resources: wl.List,
    /// XdgOutputManagerV1.outputs
    link: wl.List,

    layout_output: *wlr.OutputLayout.Output,

    x: i32,
    y: i32,
    width: i32,
    height: i32,

    destroy: wl.Listener(*wlr.OutputLayout.Output),
    description: wl.Listener(*wlr.Output),
};
