const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const DrmLeaseManagerV1 = extern struct {
    devices: wl.list.Head(DrmLeaseDeviceV1, .link),
    server: *wl.Server,

    events: extern struct {
        destroy: wl.Signal(void),
        request: wl.Signal(*DrmLeaseRequestV1),
    },

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_drm_lease_v1_manager_create(server: *wl.Server, backend: *wlr.Backend) ?*DrmLeaseManagerV1;
    pub const create = wlr_drm_lease_v1_manager_create;

    extern fn wlr_drm_lease_v1_manager_offer_output(manager: *DrmLeaseManagerV1, output: *wlr.Output) bool;
    pub const offerOutput = wlr_drm_lease_v1_manager_offer_output;

    extern fn wlr_drm_lease_v1_manager_withdraw_output(manager: *DrmLeaseManagerV1, output: *wlr.Output) void;
    pub const withdrawOutput = wlr_drm_lease_v1_manager_withdraw_output;
};

pub const DrmLeaseDeviceV1 = extern struct {
    resources: wl.list.Head(wl.Resource, null),
    global: *wl.Global,

    manager: *DrmLeaseManagerV1,
    backend: *wlr.Backend,

    connectors: wl.list.Head(DrmLeaseConnectorV1, .link),
    leases: wl.list.Head(DrmLeaseV1, .link),
    requests: wl.list.Head(DrmLeaseRequestV1, .link),
    /// DrmLeaseManagerV1.devices
    link: wl.list.Link,

    data: ?*anyopaque,

    private: extern struct {
        backend_destroy: wl.Listener(void),
    },
};

pub const DrmLeaseConnectorV1 = extern struct {
    resources: wl.list.Head(wl.Resource, null),

    output: *wlr.Output,
    device: *DrmLeaseDeviceV1,

    active_lease: ?*DrmLeaseV1,

    /// DrmLeaseDeviceV1.connectors
    link: wl.list.Link,

    private: extern struct {
        destroy: wl.Listener(void),
    },
};

pub const DrmLeaseRequestV1 = extern struct {
    resource: *wl.Resource,

    device: *DrmLeaseDeviceV1,

    connectors: ?[*]*DrmLeaseConnectorV1,
    n_connectors: usize,

    lease_resource: *wl.Resource,

    invalid: bool,
    /// DrmLeaseDeviceV1.requests
    link: wl.list.Link,

    extern fn wlr_drm_lease_request_v1_grant(request: *DrmLeaseRequestV1) ?*DrmLeaseV1;
    pub const grant = wlr_drm_lease_request_v1_grant;

    extern fn wlr_drm_lease_request_v1_reject(request: *DrmLeaseRequestV1) void;
    pub const reject = wlr_drm_lease_request_v1_reject;
};

pub const DrmLeaseV1 = extern struct {
    resource: *wl.Resource,

    drm_lease: *wlr.Backend.DrmLease,
    device: *DrmLeaseDeviceV1,

    connectors: [*]*DrmLeaseConnectorV1,
    n_connectors: usize,
    /// DrmLeaseDeviceV1.leases
    link: wl.list.Link,

    data: ?*anyopaque,

    private: extern struct {
        destroy: wl.Listener(void),
    },

    extern fn wlr_drm_lease_v1_revoke(lease: *DrmLeaseV1) void;
    pub const revoke = wlr_drm_lease_v1_revoke;
};
