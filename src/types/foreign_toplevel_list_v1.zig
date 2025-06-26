const wl = @import("wayland").server.wl;

pub const ExtForeignToplevelListV1 = extern struct {
    global: *wl.Global,
    resources: wl.list.Head(wl.Resource, null),
    toplevels: wl.list.Head(ExtForeignToplevelHandleV1, .link),

    events: extern struct {
        destroy: wl.Signal(void),
    },

    data: ?*anyopaque,

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_ext_foreign_toplevel_list_v1_create(
        display: *wl.Server,
        version: u32,
    ) ?*ExtForeignToplevelListV1;
    pub fn create(
        display: *wl.Server,
        version: u32,
    ) !*ExtForeignToplevelListV1 {
        return wlr_ext_foreign_toplevel_list_v1_create(display, version) orelse error.OutOfMemory;
    }
};

pub const ExtForeignToplevelHandleV1 = extern struct {
    list: *ExtForeignToplevelListV1,
    resources: wl.list.Head(wl.Resource, null),
    link: wl.list.Link,

    title: ?[*:0]const u8,
    app_id: ?[*:0]const u8,
    identifier: [*:0]const u8,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    data: ?*anyopaque,

    pub const State = extern struct {
        title: ?[*:0]const u8,
        app_id: ?[*:0]const u8,
    };

    extern fn wlr_ext_foreign_toplevel_handle_v1_create(
        list: *ExtForeignToplevelListV1,
        state: *const State,
    ) ?*ExtForeignToplevelHandleV1;
    pub fn create(
        list: *ExtForeignToplevelListV1,
        state: *const State,
    ) !*ExtForeignToplevelHandleV1 {
        return wlr_ext_foreign_toplevel_handle_v1_create(list, state) orelse error.ToplevelHandleCreateFailed;
    }

    extern fn wlr_ext_foreign_toplevel_handle_v1_from_resource(
        resource: *wl.Resource,
    ) ?*ExtForeignToplevelHandleV1;
    pub fn fromResource(resource: *wl.Resource) ?*ExtForeignToplevelHandleV1 {
        return wlr_ext_foreign_toplevel_handle_v1_from_resource(resource);
    }

    extern fn wlr_ext_foreign_toplevel_handle_v1_destroy(
        toplevel: *ExtForeignToplevelHandleV1,
    ) void;
    pub const destroy = wlr_ext_foreign_toplevel_handle_v1_destroy;

    extern fn wlr_ext_foreign_toplevel_handle_v1_update_state(
        toplevel: *ExtForeignToplevelHandleV1,
        state: *const State,
    ) void;
    pub const updateState = wlr_ext_foreign_toplevel_handle_v1_update_state;
};
