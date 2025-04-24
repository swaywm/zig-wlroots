const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

const pixman = @import("pixman");

pub const Renderer = extern struct {
    const Impl = opaque {};

    /// Bitmask of wlr.BufferCap
    render_buffer_caps: u32,

    events: extern struct {
        destroy: wl.Signal(*Renderer),
        lost: wl.Signal(void),
    },

    features: extern struct {
        output_color_transform: bool,
        timeline: bool,
    },

    private: extern struct {
        impl: *const Impl,
    },

    extern fn wlr_renderer_autocreate(backend: *wlr.Backend) ?*Renderer;
    pub fn autocreate(backend: *wlr.Backend) !*Renderer {
        return wlr_renderer_autocreate(backend) orelse error.RendererCreateFailed;
    }

    extern fn wlr_renderer_get_texture_formats(renderer: *Renderer, buffer_caps: u32) ?*const wlr.DrmFormatSet;
    pub const getTextureFormats = wlr_renderer_get_texture_formats;

    extern fn wlr_renderer_init_wl_shm(renderer: *Renderer, server: *wl.Server) bool;
    pub inline fn initWlShm(renderer: *Renderer, server: *wl.Server) !void {
        if (!wlr_renderer_init_wl_shm(renderer, server)) {
            return error.RenderInitFailed;
        }
    }

    extern fn wlr_renderer_init_wl_display(renderer: *Renderer, server: *wl.Server) bool;
    pub fn initServer(renderer: *Renderer, server: *wl.Server) !void {
        if (!wlr_renderer_init_wl_display(renderer, server)) {
            return error.RenderInitFailed;
        }
    }

    extern fn wlr_renderer_get_drm_fd(renderer: *Renderer) c_int;
    pub const getDrmFd = wlr_renderer_get_drm_fd;

    extern fn wlr_renderer_destroy(renderer: *Renderer) void;
    pub const destroy = wlr_renderer_destroy;

    pub const BufferPassOptions = extern struct {
        timer: ?*RenderTimer = null,
        color_transform: ?*wlr.ColorTransform = null,
        signal_timeline: ?*wlr.DrmSyncobjTimeline = null,
        signal_point: u64 = 0,
    };
    extern fn wlr_renderer_begin_buffer_pass(renderer: *Renderer, buffer: *wlr.Buffer, options: ?*const BufferPassOptions) ?*RenderPass;
    pub fn beginBufferPass(renderer: *Renderer, buffer: *wlr.Buffer, options: ?*const BufferPassOptions) !*RenderPass {
        return wlr_renderer_begin_buffer_pass(renderer, buffer, options) orelse error.OutOfMemory;
    }

    extern fn wlr_render_timer_create(renderer: *Renderer) ?*RenderTimer;
    pub fn createRenderTimer(renderer: *Renderer) !*RenderTimer {
        return wlr_render_timer_create(renderer) orelse error.OutOfMemory;
    }

    extern fn wlr_renderer_is_gles2(renderer: *Renderer) bool;
    pub const isGles2 = wlr_renderer_is_gles2;

    extern fn wlr_renderer_is_pixman(renderer: *Renderer) bool;
    pub const isPixman = wlr_renderer_is_pixman;

    extern fn wlr_gles2_renderer_get_egl(renderer: *Renderer) *wlr.Egl;
    pub const gles2GetEgl = wlr_gles2_renderer_get_egl;

    extern fn wlr_gles2_renderer_check_ext(renderer: *Renderer, name: [*:0]const u8) bool;
    pub const gles2CheckExt = wlr_gles2_renderer_check_ext;

    extern fn wlr_gles2_renderer_get_buffer_fbo(renderer: *Renderer, buffer: *wlr.Buffer) c_uint;
    pub const gles2GetBufferFbo = wlr_gles2_renderer_get_buffer_fbo;
};

pub const RenderTimer = opaque {
    extern fn wlr_render_timer_get_duration_ns(timer: *RenderTimer) c_int;
    pub const getDurationNs = wlr_render_timer_get_duration_ns;

    extern fn wlr_render_timer_destroy(timer: *RenderTimer) void;
    pub const destroy = wlr_render_timer_destroy;
};

pub const RenderPass = opaque {
    pub const BlendMode = enum(c_int) {
        premultiplied,
        none,
    };

    pub const ScaleFilterMode = enum(c_int) {
        bilinear,
        nearest,
    };

    pub const Color = extern struct {
        r: f32,
        g: f32,
        b: f32,
        a: f32,
    };

    pub const TextureOptions = extern struct {
        texture: *wlr.Texture,
        src_box: wlr.FBox,
        dst_box: wlr.Box,
        alpha: ?*const f32,
        clip: ?*const pixman.Region32,
        transform: wl.Output.Transform,
        filter_mode: ScaleFilterMode,
        blend_mode: BlendMode,
        wait_timeline: ?*wlr.DrmSyncobjTimeline = null,
        wait_point: u64,
    };

    pub const RectOptions = extern struct {
        box: wlr.Box,
        color: Color,
        clip: ?*pixman.Region32,
        blend_mode: BlendMode,
    };

    extern fn wlr_render_pass_submit(render_pass: *RenderPass) bool;
    pub const submit = wlr_render_pass_submit;

    extern fn wlr_render_pass_add_texture(render_pass: *RenderPass, options: *const TextureOptions) void;
    pub const addTexture = wlr_render_pass_add_texture;

    extern fn wlr_render_pass_add_rect(render_pass: *RenderPass, options: *const RectOptions) void;
    pub const addRect = wlr_render_pass_add_rect;
};
