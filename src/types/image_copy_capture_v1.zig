const wlr = @import("../wlroots.zig");

const posix = @import("std").posix;

const wayland = @import("wayland");
const wl = wayland.server.wl;
const FailureReason = wl.ext.ImageCopyCaptureFrameV1.FailureReason;

const pixman = @import("pixman");

const ImageCopyCaptureSessionV1 = extern struct {
    resource: *wl.Resource,
    source: *wlr.ImageCaptureSourceV1,
    frame: *ImageCopyCaptureFrameV1,

    source_destroy: wl.listener(void),
    source_constraints_update: wl.listener(void),
    source_frame: wl.listener(void),

    damage: pixman.Region32,
};

pub const ImageCopyCaptureManagerV1 = extern struct {
    global: *wl.Global,

    private: extern struct {
        server_destroy: wl.Listener(void),
    },

    extern fn wlr_ext_image_copy_capture_manager_v1_create(
        display: *wl.Server,
        version: u32,
    ) ?*ImageCopyCaptureManagerV1;
    pub fn create(
        display: *wl.Server,
        version: u32,
    ) !*ImageCopyCaptureManagerV1 {
        return wlr_ext_image_copy_capture_manager_v1_create(display, version) orelse error.OutOfMemory;
    }
};

pub const ImageCopyCaptureFrameV1 = extern struct {
    resource: *wl.Resource,
    capturing: bool,
    buffer: *wlr.buffer,
    buffer_damage: pixman.Region32,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    private: extern struct {
        session: *ImageCopyCaptureSessionV1,
    },

    extern fn wlr_ext_image_copy_capture_frame_v1_ready(
        frame: *ImageCopyCaptureFrameV1,
        transform: wl.Output.Transform,
        presentation_time: *const posix.timespec,
    ) void;
    pub fn ready(
        frame: *ImageCopyCaptureFrameV1,
        transform: wl.Output.Transform,
        presentation_time: *const posix.timespec,
    ) void {
        return wlr_ext_image_copy_capture_frame_v1_ready(frame, transform, presentation_time);
    }

    extern fn wlr_ext_image_copy_capture_frame_v1_fail(
        frame: *ImageCopyCaptureFrameV1,
        reason: FailureReason,
    ) void;
    pub fn fail(
        frame: *ImageCopyCaptureFrameV1,
        reason: FailureReason,
    ) void {
        return wlr_ext_image_copy_capture_frame_v1_fail(frame, reason);
    }

    extern fn wlr_ext_image_copy_capture_frame_v1_copy_buffer(
        frame: *ImageCopyCaptureFrameV1,
        src: *wlr.Buffer,
        renderer: *wlr.Renderer,
    ) void;
    pub fn copyBuffer(
        frame: *ImageCopyCaptureFrameV1,
        src: *wlr.Buffer,
        renderer: *wlr.Renderer,
    ) void {
        return wlr_ext_image_copy_capture_frame_v1_copy_buffer(frame, src, renderer);
    }
};
