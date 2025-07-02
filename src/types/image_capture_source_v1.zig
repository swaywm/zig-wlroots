const wlr = @import("../wlroots.zig");

const posix = @import("std").posix;

const wayland = @import("wayland");
const wl = wayland.server.wl;

const pixman = @import("pixman");

pub const ImageCaptureSourceV1 = extern struct {
    impl: *const ImageCaptureSourceV1Interface,
    resources: wl.list.Head(wl.Resource, null),

    width: u32,
    height: u32,

    shm_formats: *u32,
    shm_formats_len: isize,

    dmabuf_device: posix.dev_t,
    dmabuf_formats: wlr.DrmFormatSet,

    events: extern struct {
        constraints_update: wl.Signal(void),
        frame: wl.Signal(void),
        destroy: wl.Signal(void),
    },

    extern fn wlr_ext_image_capture_source_v1_init(
        source: *ImageCaptureSourceV1,
        impl: *const ImageCaptureSourceV1Interface,
    ) void;
    pub fn init(
        source: *ImageCaptureSourceV1,
        impl: *const ImageCaptureSourceV1Interface,
    ) void {
        return wlr_ext_image_capture_source_v1_init(source, impl);
    }

    extern fn wlr_ext_image_capture_source_v1_finish(source: *ImageCaptureSourceV1) void;
    pub fn finish(source: *ImageCaptureSourceV1) void {
        return wlr_ext_image_capture_source_v1_finish(source);
    }

    extern fn wlr_ext_image_capture_source_v1_create_resource(
        source: *ImageCaptureSourceV1,
        client: *wl.Client,
        new_id: u32,
    ) bool;
    pub fn createResource(
        source: *ImageCaptureSourceV1,
        client: *wl.Client,
        new_id: u32,
    ) bool {
        return wlr_ext_image_capture_source_v1_create_resource(source, client, new_id);
    }

    extern fn wlr_ext_image_capture_source_v1_set_constraints_from_swapchain(
        source: *ImageCaptureSourceV1,
        swapchain: *wlr.Swapchain,
        renderer: *wlr.Renderer,
    ) bool;
    pub fn setContraintsFromSwapchain(
        source: *ImageCaptureSourceV1,
        swapchain: *wlr.Swapchain,
        renderer: *wlr.Renderer,
    ) bool {
        return wlr_ext_image_capture_source_v1_set_constraints_from_swapchain(
            source,
            swapchain,
            renderer,
        );
    }

    extern fn wlr_ext_image_capture_source_v1_from_resource(
        resource: *wl.Resource,
    ) ?*ImageCaptureSourceV1;
    pub fn fromResource(resource: *wl.Resource) !*ImageCaptureSourceV1 {
        return wlr_ext_image_capture_source_v1_from_resource(resource) orelse error.OutOfMemory;
    }
};

pub const ImageCaptureSourceV1Interface = extern struct {
    start: *const fn (
        source: *ImageCaptureSourceV1,
        with_cursors: bool,
    ) callconv(.C) void,

    stop: *const fn (source: *ImageCaptureSourceV1) callconv(.C) void,

    schedule_frame: *const fn (source: *ImageCaptureSourceV1) callconv(.C) void,

    copy_frame: *const fn (
        source: *ImageCaptureSourceV1,
        dst_frame: *wlr.ImageCopyCaptureFrameV1,
        frame_event: *ImageCaptureSourceV1FrameEvent,
    ) callconv(.C) void,

    get_pointer_cursor: *const fn (
        source: *ImageCaptureSourceV1,
        seat: *wlr.Seat,
    ) callconv(.C) *ImageCaptureSourceV1Cursor,
};

pub const ImageCaptureSourceV1FrameEvent = extern struct {
    damage: *const pixman.Region32,
};

pub const ImageCaptureSourceV1Cursor = extern struct {
    base: ImageCaptureSourceV1,

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

    extern fn wlr_ext_image_capture_source_v1_cursor_init(
        source_cursor: *ImageCaptureSourceV1Cursor,
        impl: *const ImageCaptureSourceV1Interface,
    ) void;
    pub fn cursorInit(
        source_cursor: *ImageCaptureSourceV1Cursor,
        impl: *const ImageCaptureSourceV1Interface,
    ) void {
        return wlr_ext_image_capture_source_v1_cursor_init(source_cursor, impl);
    }

    extern fn wlr_ext_image_capture_source_v1_cursor_finish(
        source_cursor: *ImageCaptureSourceV1Cursor,
    ) void;
    pub fn finish(source_cursor: *ImageCaptureSourceV1Cursor) void {
        return wlr_ext_image_capture_source_v1_cursor_finish(source_cursor);
    }
};

pub const OutputImageCaptureSourceManagerV1 = extern struct {
    global: *wl.Global,

    private: extern struct {
        display_destroy: wl.Listener(void),
    },

    extern fn wlr_ext_output_image_capture_source_manager_v1_create(
        display: *wl.Server,
        version: u32,
    ) ?*OutputImageCaptureSourceManagerV1;
    pub fn create(
        display: *wl.Server,
        version: u32,
    ) !*OutputImageCaptureSourceManagerV1 {
        return wlr_ext_output_image_capture_source_manager_v1_create(display, version) orelse error.OutOfMemory;
    }
};
