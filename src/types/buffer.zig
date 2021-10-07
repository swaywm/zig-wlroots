const wlr = @import("../wlroots.zig");

const os = @import("std").os;
const wl = @import("wayland").server.wl;
const pixman = @import("pixman");

pub const ShmAttributes = extern struct {
    fd: c_int,
    format: u32,
    width: c_int,
    height: c_int,
    stride: c_int,
    offset: os.off_t,
};

pub const Buffer = extern struct {
    pub const data_ptr_access_flag = struct {
        pub const read = 1 << 0;
        pub const write = 1 << 1;
    };

    pub const Impl = extern struct {
        destroy: fn (buffer: *Buffer) callconv(.C) void,
        get_dmabuf: fn (buffer: *Buffer, attribs: *wlr.DmabufAttributes) callconv(.C) bool,
        get_shm: fn (buffer: *Buffer, attribs: *wlr.ShmAttributes) callconv(.C) bool,
        begin_data_ptr_access: fn (buffer: *Buffer, flags: u32, data: **anyopaque, format: *u32, stride: *usize) callconv(.C) bool,
        end_data_ptr_access: fn (buffer: *Buffer) callconv(.C) void,
    };

    pub const ResourceInterface = extern struct {
        name: [*:0]const u8,
        is_instance: fn (resource: *wl.Resource) callconv(.C) bool,
        from_resource: fn (resource: *wl.Resource) callconv(.C) ?*Buffer,
    };

    impl: *const Impl,

    width: c_int,
    height: c_int,

    dropped: bool,
    n_locks: usize,

    accessing_data_ptr: bool,

    events: extern struct {
        destroy: wl.Signal(void),
        release: wl.Signal(void),
    },

    addons: wlr.AddonSet,

    extern fn wlr_buffer_init(buffer: *Buffer, impl: *const Buffer.Impl, width: c_int, height: c_int) void;
    pub const init = wlr_buffer_init;

    extern fn wlr_buffer_drop(buffer: *Buffer) void;
    pub const drop = wlr_buffer_drop;

    extern fn wlr_buffer_lock(buffer: *Buffer) *Buffer;
    pub const lock = wlr_buffer_lock;

    extern fn wlr_buffer_unlock(buffer: *Buffer) void;
    pub const unlock = wlr_buffer_unlock;

    extern fn wlr_buffer_get_dmabuf(buffer: *Buffer, attribs: *wlr.DmabufAttributes) bool;
    pub const getDmabuf = wlr_buffer_get_dmabuf;

    extern fn wlr_buffer_get_shm(buffer: *Buffer, attribs: *wlr.ShmAttributes) bool;
    pub const getShm = wlr_buffer_get_shm;

    extern fn wlr_buffer_register_resource_interface(iface: *const ResourceInterface) void;
    pub const registerResourceInterface = wlr_buffer_register_resource_interface;

    extern fn wlr_buffer_from_resource(resource: *wl.Buffer) ?*Buffer;
    pub const fromWlBuffer = wlr_buffer_from_resource;

    extern fn wlr_buffer_begin_data_ptr_access(buffer: *Buffer, flags: u32, data: **anyopaque, format: *u32, stride: *usize) bool;
    pub const beginDataPtrAccess = wlr_buffer_begin_data_ptr_access;

    extern fn wlr_buffer_end_data_ptr_access(buffer: *Buffer) void;
    pub const endDataPtrAccess = wlr_buffer_end_data_ptr_access;
};

pub const ClientBuffer = extern struct {
    base: Buffer,

    texture: ?*wlr.Texture,
    source: ?*wlr.Buffer,

    // private state

    source_destroy: wl.Listener(void),

    shm_source_format: u32,

    extern fn wlr_client_buffer_create(buffer: *wlr.Buffer, renderer: *wlr.Renderer) ?*ClientBuffer;
    pub const create = wlr_client_buffer_create;

    extern fn wlr_client_buffer_get(buffer: *wlr.Buffer) ?*ClientBuffer;
    pub const get = wlr_client_buffer_get;

    extern fn wlr_client_buffer_apply_damage(buffer: *ClientBuffer, next: *wlr.Buffer, damage: *pixman.Region32) bool;
    pub const applyDamage = wlr_client_buffer_apply_damage;
};
