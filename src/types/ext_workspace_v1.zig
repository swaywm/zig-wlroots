const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const ext = wayland.server.ext;

pub const ExtWorkspaceManagerV1 = extern struct {
    pub const event = struct {
        pub const Commit = extern struct {
            requests: *wl.list.Head(ExtWorkspaceV1Request, .link),
        };
    };

    global: *wl.Global,
    groups: wl.list.Head(ExtWorkspaceGroupHandleV1, .link),
    workspaces: wl.list.Head(ExtWorkspaceHandleV1, .link),
    events: extern struct {
        commit: wl.Signal(*event.Commit),
        destroy: wl.Signal(void),
    },

    data: ?*anyopaque,

    private: extern struct {
        resources: wl.list.Link,
        idle_source: ?*wl.EventSource,
        event_loop: *wl.EventLoop,
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_ext_workspace_manager_v1_create(server: *wl.Server, version: u32) ?*ExtWorkspaceManagerV1;
    pub fn create(server: *wl.Server, version: u32) !*ExtWorkspaceManagerV1 {
        return wlr_ext_workspace_manager_v1_create(server, version) orelse error.OutOfMemory;
    }

    extern fn wlr_ext_workspace_group_handle_v1_create(manager: *ExtWorkspaceManagerV1, caps: ext.WorkspaceGroupHandleV1.GroupCapabilities) ?*ExtWorkspaceGroupHandleV1;
    pub fn createGroup(manager: *ExtWorkspaceManagerV1, caps: ext.WorkspaceGroupHandleV1.GroupCapabilities) !*ExtWorkspaceGroupHandleV1 {
        return wlr_ext_workspace_group_handle_v1_create(manager, caps) orelse error.OutOfMemory;
    }

    extern fn wlr_ext_workspace_handle_v1_create(manager: *ExtWorkspaceManagerV1, id: [*:0]const u8, caps: ext.WorkspaceHandleV1.WorkspaceCapabilities) ?*ExtWorkspaceHandleV1;
    pub fn createWorkspace(manager: *ExtWorkspaceManagerV1, id: [*:0]const u8, caps: ext.WorkspaceHandleV1.WorkspaceCapabilities) !*ExtWorkspaceHandleV1 {
        return wlr_ext_workspace_handle_v1_create(manager, id, caps) orelse error.OutOfMemory;
    }
};

pub const ExtWorkspaceV1Request = extern struct {
    pub const Type = enum(c_int) {
        create_workspace = 0,
        activate = 1,
        deactivate = 2,
        assign = 3,
        remove = 4,
    };

    pub const Data = extern union {
        create_workspace: extern struct {
            name: [*:0]const u8,
            /// `null` if destroyed
            group: ?*ExtWorkspaceGroupHandleV1,
        },
        activate: extern struct {
            /// `null` if destroyed
            workspace: ?*ExtWorkspaceHandleV1,
        },
        deactivate: extern struct {
            /// `null` if destroyed
            workspace: ?*ExtWorkspaceHandleV1,
        },
        assign: extern struct {
            /// `null` if destroyed
            workspace: ?*ExtWorkspaceHandleV1,
            /// `null` if destroyed
            group: ?*ExtWorkspaceGroupHandleV1,
        },
        remove: extern struct {
            /// `null` if destroyed
            workspace: ?*ExtWorkspaceHandleV1,
        },
    };

    type: Type,
    link: wl.list.Link,
    data: Data,
};

pub const ExtWorkspaceGroupHandleV1 = extern struct {
    manager: *ExtWorkspaceManagerV1,
    caps: ext.WorkspaceGroupHandleV1.GroupCapabilities,
    events: extern struct {
        destroy: wl.Signal(void),
    },
    /// Manager.groups
    link: wl.list.Link,

    data: ?*anyopaque,

    private: extern struct {
        outputs: wl.list.Link,
        resources: wl.list.Link,
    },

    extern fn wlr_ext_workspace_group_handle_v1_destroy(group: *ExtWorkspaceGroupHandleV1) void;
    pub const destroy = wlr_ext_workspace_group_handle_v1_destroy;

    extern fn wlr_ext_workspace_group_handle_v1_output_enter(group: *ExtWorkspaceGroupHandleV1, output: *wlr.Output) void;
    pub const outputEnter = wlr_ext_workspace_group_handle_v1_output_enter;

    extern fn wlr_ext_workspace_group_handle_v1_output_leave(group: *ExtWorkspaceGroupHandleV1, output: *wlr.Output) void;
    pub const outputLeave = wlr_ext_workspace_group_handle_v1_output_leave;
};

pub const ExtWorkspaceHandleV1 = extern struct {
    manager: *ExtWorkspaceManagerV1,
    group: ?*ExtWorkspaceGroupHandleV1,
    id: ?[*:0]u8,
    name: ?[*:0]u8,
    coordinates: wl.Array,
    caps: ext.WorkspaceHandleV1.WorkspaceCapabilities,
    state: ext.WorkspaceHandleV1.State,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    /// Manager.workspaces
    link: wl.list.Link,

    data: ?*anyopaque,

    private: extern struct {
        resources: wl.list.Link,
    },

    extern fn wlr_ext_workspace_handle_v1_destroy(workspace: *ExtWorkspaceHandleV1) void;
    pub const destroy = wlr_ext_workspace_handle_v1_destroy;

    extern fn wlr_ext_workspace_handle_v1_set_group(workspace: *ExtWorkspaceHandleV1, group: ?*ExtWorkspaceGroupHandleV1) void;
    pub const setGroup = wlr_ext_workspace_handle_v1_set_group;

    extern fn wlr_ext_workspace_handle_v1_set_name(workspace: *ExtWorkspaceHandleV1, name: [*:0]const u8) void;
    pub const setName = wlr_ext_workspace_handle_v1_set_name;

    extern fn wlr_ext_workspace_handle_v1_set_coordinates(workspace: *ExtWorkspaceHandleV1, coords: [*]u32, coords_len: usize) void;
    pub fn setCoordinates(workspace: *ExtWorkspaceHandleV1, coords: []u32) void {
        wlr_ext_workspace_handle_v1_set_coordinates(workspace, coords.ptr, coords.len);
    }

    extern fn wlr_ext_workspace_handle_v1_set_active(workspace: *ExtWorkspaceHandleV1, enabled: bool) void;
    pub const setActive = wlr_ext_workspace_handle_v1_set_active;

    extern fn wlr_ext_workspace_handle_v1_set_urgent(workspace: *ExtWorkspaceHandleV1, enabled: bool) void;
    pub const setUrgent = wlr_ext_workspace_handle_v1_set_urgent;

    extern fn wlr_ext_workspace_handle_v1_set_hidden(workspace: *ExtWorkspaceHandleV1, enabled: bool) void;
    pub const setHidden = wlr_ext_workspace_handle_v1_set_hidden;
};
