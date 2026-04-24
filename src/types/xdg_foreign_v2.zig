const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const xdg = wayland.server.xdg;
const zxdg = wayland.server.zxdg;

pub const XdgForeignV2 = extern struct {
    exporter: extern struct {
        global: *wl.Global,
        objects: wl.list.Head(XdgExportedV2, .link),
    },
    importer: extern struct {
        global: *wl.Global,
        objects: wl.list.Head(XdgImportedV2, .link),
    },

    registry: *wlr.XdgForeignRegistry,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    data: ?*anyopaque,

    private: extern struct {
        foreign_registry_destroy: wl.Listener(void),
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_xdg_foreign_v2_create(server: *wl.Server, registry: *wlr.XdgForeignRegistry) ?*wlr.XdgForeignV2;
    pub fn create(server: *wl.Server, registry: *wlr.XdgForeignRegistry) !*wlr.XdgForeignV2 {
        return wlr_xdg_foreign_v2_create(server, registry) orelse error.OutOfMemory;
    }
};

pub const XdgExportedV2 = extern struct {
    base: wlr.XdgForeignExported,

    resource: *zxdg.ExportedV2,
    // XdgForeignV2.exporter.objects
    link: wl.list.Link,

    private: extern struct {
        xdg_toplevel_destroy: wl.Listener(void),
    },
};

pub const XdgImportedV2 = extern struct {
    exported: *wlr.XdgForeignExported,

    resource: *zxdg.ImportedV2,
    // XdgForeignV2.importer.objects
    link: wl.list.Link,
    children: wl.list.Head(XdgImportedChildV2, .link),

    private: extern struct {
        exported_destroyed: wl.Listener(void),
    },
};

pub const XdgImportedChildV2 = extern struct {
    imported: ?*XdgImportedV2,
    toplevel: *wlr.XdgToplevel,

    // XdgImportedV2.children
    link: wl.list.Link,

    private: extern struct {
        xdg_toplevel_destroy: wl.Listener(void),
        xdg_toplevel_set_parent: wl.Listener(void),
    },
};
