const wlr = @import("../wlroots.zig");

const posix = @import("std").posix;

const wayland = @import("wayland");
const wl = wayland.server.wl;
const ext = wayland.server.ext;

const pixman = @import("pixman");

pub const ExtImageCopyCaptureManagerV1 = extern struct {
    global: *wl.Global,

    events: extern struct {
        new_session: wl.Signal(*ExtImageCopyCaptureSessionV1),
    },

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_ext_image_copy_capture_manager_v1_create(
        display: *wl.Server,
        version: u32,
    ) ?*ExtImageCopyCaptureManagerV1;
    pub fn create(
        display: *wl.Server,
        version: u32,
    ) !*ExtImageCopyCaptureManagerV1 {
        return wlr_ext_image_copy_capture_manager_v1_create(display, version) orelse error.OutOfMemory;
    }
};

pub const ExtImageCopyCaptureSessionV1 = extern struct {
    resource: *wl.Resource,
    source: *wlr.ExtImageCaptureSourceV1,
    frame: *ExtImageCopyCaptureFrameV1,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    private: extern struct {
        source_destroy: wl.Listener(void),
        source_constraints_update: wl.Listener(void),
        source_frame: wl.Listener(void),

        damage: pixman.Region32,
    },
};

pub const ExtImageCopyCaptureFrameV1 = extern struct {
    resource: *wl.Resource,
    capturing: bool,
    buffer: ?*wlr.Buffer,
    buffer_damage: pixman.Region32,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    private: extern struct {
        session: ?*opaque {},
    },

    extern fn wlr_ext_image_copy_capture_frame_v1_ready(
        frame: *ExtImageCopyCaptureFrameV1,
        transform: wl.Output.Transform,
        presentation_time: *const posix.timespec,
    ) void;
    pub const ready = wlr_ext_image_copy_capture_frame_v1_ready;

    extern fn wlr_ext_image_copy_capture_frame_v1_fail(
        frame: *ExtImageCopyCaptureFrameV1,
        reason: ext.ImageCopyCaptureFrameV1.FailureReason,
    ) void;
    pub const fail = wlr_ext_image_copy_capture_frame_v1_fail;

    extern fn wlr_ext_image_copy_capture_frame_v1_copy_buffer(
        frame: *ExtImageCopyCaptureFrameV1,
        src: *wlr.Buffer,
        renderer: *wlr.Renderer,
    ) void;
    pub const copyBuffer = wlr_ext_image_copy_capture_frame_v1_copy_buffer;
};
