const wlr = @import("../wlroots.zig");

const posix = @import("std").posix;

const wayland = @import("wayland");
const wl = wayland.server.wl;

const pixman = @import("pixman");

pub const ExtImageCaptureSourceV1 = extern struct {
    pub const Interface = extern struct {
        start: ?*const fn (source: *ExtImageCaptureSourceV1, with_cursors: bool) callconv(.c) void,
        stop: ?*const fn (source: *ExtImageCaptureSourceV1) callconv(.c) void,
        schedule_frame: ?*const fn (source: *ExtImageCaptureSourceV1) callconv(.c) void,
        copy_frame: *const fn (
            source: *ExtImageCaptureSourceV1,
            dst_frame: *wlr.ExtImageCopyCaptureFrameV1,
            frame_event: *event.Frame,
        ) callconv(.c) void,
        get_pointer_cursor: ?*const fn (source: *ExtImageCaptureSourceV1, seat: *wlr.Seat) callconv(.c) *Cursor,
    };

    pub const event = struct {
        pub const Frame = extern struct {
            damage: *const pixman.Region32,
        };
    };

    impl: *const Interface,
    resources: wl.list.Head(wl.Resource, null),

    width: u32,
    height: u32,

    shm_formats: *u32,
    shm_formats_len: isize,

    dmabuf_device: posix.dev_t,
    dmabuf_formats: wlr.DrmFormatSet,

    events: extern struct {
        constraints_update: wl.Signal(void),
        frame: wl.Signal(*event.Frame),
        destroy: wl.Signal(void),
    },

    extern fn wlr_ext_image_capture_source_v1_init(source: *ExtImageCaptureSourceV1, impl: *const Interface) void;
    pub const init = wlr_ext_image_capture_source_v1_init;

    extern fn wlr_ext_image_capture_source_v1_finish(source: *ExtImageCaptureSourceV1) void;
    pub const finish = wlr_ext_image_capture_source_v1_finish;

    extern fn wlr_ext_image_capture_source_v1_create_resource(
        source: *ExtImageCaptureSourceV1,
        client: *wl.Client,
        new_id: u32,
    ) bool;
    pub const createResource = wlr_ext_image_capture_source_v1_create_resource;

    extern fn wlr_ext_image_capture_source_v1_set_constraints_from_swapchain(
        source: *ExtImageCaptureSourceV1,
        swapchain: *wlr.Swapchain,
        renderer: *wlr.Renderer,
    ) bool;
    pub const setContraintsFromSwapchain = wlr_ext_image_capture_source_v1_set_constraints_from_swapchain;

    extern fn wlr_ext_image_capture_source_v1_from_resource(resource: *wl.Resource) ?*ExtImageCaptureSourceV1;
    pub const fromResource = wlr_ext_image_capture_source_v1_from_resource;

    pub const Cursor = extern struct {
        base: ExtImageCaptureSourceV1,

        entered: bool,
        x: i32,
        y: i32,
        hotspot: extern struct {
            x: i32,
            y: i32,
        },

        events: extern struct {
            update: wl.Signal(void),
        },

        extern fn wlr_ext_image_capture_source_v1_cursor_init(source_cursor: *Cursor, impl: *const Interface) void;
        pub const init = wlr_ext_image_capture_source_v1_cursor_init;

        extern fn wlr_ext_image_capture_source_v1_cursor_finish(source_cursor: *Cursor) void;
        pub const finish = wlr_ext_image_capture_source_v1_cursor_finish;
    };
};

pub const ExtOutputImageCaptureSourceManagerV1 = extern struct {
    global: *wl.Global,

    private: extern struct {
        display_destroy: wl.Listener(void),
    },

    extern fn wlr_ext_output_image_capture_source_manager_v1_create(
        display: *wl.Server,
        version: u32,
    ) ?*ExtOutputImageCaptureSourceManagerV1;
    pub fn create(display: *wl.Server, version: u32) !*ExtOutputImageCaptureSourceManagerV1 {
        return wlr_ext_output_image_capture_source_manager_v1_create(display, version) orelse error.OutOfMemory;
    }
};
