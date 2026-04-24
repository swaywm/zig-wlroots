const wayland = @import("wayland");
const wl = wayland.server.wl;
const xdg = wayland.server.xdg;

const wlr = @import("../wlroots.zig");

pub const XdgForeignRegistry = extern struct {
    exported_surfaces: wl.list.Head(XdgForeignExported, .link),

    events: extern struct {
        destroy: wl.Signal(void),
    },

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_xdg_foreign_registry_create(server: *wl.Server) ?*wlr.XdgForeignRegistry;
    pub fn create(server: *wl.Server) !*wlr.XdgForeignRegistry {
        return wlr_xdg_foreign_registry_create(server) orelse error.OutOfMemory;
    }

    extern fn wlr_xdg_foreign_registry_find_by_handle(registry: *XdgForeignRegistry, handle: [*:0]const u8) ?*XdgForeignExported;
    pub fn find_by_handle(registry: *XdgForeignRegistry, handle: [*:0]const u8) ?*XdgForeignExported {
        return wlr_xdg_foreign_registry_find_by_handle(registry, handle);
    }
};

pub const XdgForeignExported = extern struct {
    // XdgForeignRegistry.exported_surfaces
    link: wl.list.Link,
    registry: *XdgForeignRegistry,

    toplevel: *wlr.XdgToplevel,
    handle: [37]u8,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    extern fn wlr_xdg_foreign_exported_init(surface: *XdgForeignExported, registry: *XdgForeignRegistry) bool;
    pub fn init(surface: *XdgForeignExported, registry: *XdgForeignRegistry) bool {
        return wlr_xdg_foreign_exported_init(surface, registry);
    }

    extern fn wlr_xdg_foreign_exported_finish(surface: *XdgForeignExported) void;
    pub fn finish(surface: *XdgForeignExported) void {
        return wlr_xdg_foreign_exported_finish(surface);
    }
};
