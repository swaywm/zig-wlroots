const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const SecurityContextManagerV1 = extern struct {
    pub const event = struct {
        pub const Commit = extern struct {
            state: *const SecurityContextV1State,
            parent_client: *wl.Client,
        };
    };

    global: *wl.Global,

    events: extern struct {
        destroy: wl.Signal(void),
        commit: wl.Signal(*event.Commit),
    },

    data: ?*anyopaque,

    private: extern struct {
        contexts: wl.list.Link,

        server_destroy: wl.Listener(void),
    },

    extern fn wlr_security_context_manager_v1_create(server: *wl.Server) ?*SecurityContextManagerV1;
    pub fn create(server: *wl.Server) error{OutOfMemory}!*SecurityContextManagerV1 {
        return wlr_security_context_manager_v1_create(server) orelse error.OutOfMemory;
    }

    extern fn wlr_security_context_manager_v1_lookup_client(manager: *SecurityContextManagerV1, client: *const wl.Client) ?*SecurityContextV1State;
    pub const lookupClient = wlr_security_context_manager_v1_lookup_client;
};

pub const SecurityContextV1State = extern struct {
    sandbox_engine: ?[*:0]u8,
    app_id: ?[*:0]u8,
    instance_id: ?[*:0]u8,
};
