const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const XdgOutputManagerV1 = extern struct {
    global: *wl.Global,
    layout: *wlr.OutputLayout,

    outputs: wl.list.Head(XdgOutputV1, "link"),

    events: extern struct {
        destroy: wl.Signal(*XdgOutputManagerV1),
    },

    server_destroy: wl.Listener(*wl.Server),
    layout_add: wl.Listener(*wlr.OutputLayout),
    layout_change: wl.Listener(*wlr.OutputLayout),
    layout_destroy: wl.Listener(*wlr.OutputLayout),

    extern fn wlr_xdg_output_manager_v1_create(server: *wl.Server, layout: *wlr.OutputLayout) ?*XdgOutputManagerV1;
    pub fn create(server: *wl.Server, layout: *wlr.OutputLayout) !*XdgOutputManagerV1 {
        return wlr_xdg_output_manager_v1_create(server, layout) orelse error.OutOfMemory;
    }
};

pub const XdgOutputV1 = extern struct {
    manager: *XdgOutputManagerV1,
    resources: wl.list.Head(wl.Resource, null),
    /// XdgOutputManagerV1.outputs
    link: wl.list.Link,

    layout_output: *wlr.OutputLayout.Output,

    x: i32,
    y: i32,
    width: i32,
    height: i32,

    destroy: wl.Listener(*wlr.OutputLayout.Output),
    description: wl.Listener(*wlr.Output),
};
