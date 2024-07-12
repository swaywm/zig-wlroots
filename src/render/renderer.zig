const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

const pixman = @import("pixman");

pub const Renderer = extern struct {
    const Impl = opaque {};

    impl: *const Impl,

    rendering: bool,
    rendering_with_buffer: bool,

    events: extern struct {
        destroy: wl.Signal(*Renderer),
    },

    // wlr_renderer functions:

    extern fn wlr_renderer_autocreate(backend: *wlr.Backend) ?*Renderer;
    pub fn autocreate(backend: *wlr.Backend) !*Renderer {
        return wlr_renderer_autocreate(backend) orelse error.RendererCreateFailed;
    }

    extern fn wlr_renderer_is_gles2(renderer: *Renderer) bool;
    pub const isGles2 = wlr_renderer_is_gles2;

    extern fn wlr_renderer_is_pixman(renderer: *Renderer) bool;
    pub const isPixman = wlr_renderer_is_pixman;

    extern fn wlr_renderer_begin(renderer: *Renderer, width: u32, height: u32) void;
    pub const begin = wlr_renderer_begin;

    extern fn wlr_renderer_begin_with_buffer(renderer: *Renderer, buffer: *wlr.Buffer) bool;
    pub const beginWithBuffer = wlr_renderer_begin_with_buffer;

    pub extern fn wlr_renderer_end(renderer: *Renderer) void;
    pub const end = wlr_renderer_end;

    extern fn wlr_renderer_clear(renderer: *Renderer, color: *const [4]f32) void;
    pub const clear = wlr_renderer_clear;

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

    extern fn wlr_renderer_scissor(renderer: *Renderer, box: ?*wlr.Box) void;
    pub const scissor = wlr_renderer_scissor;

    extern fn wlr_renderer_get_shm_texture_formats(renderer: *Renderer, len: *usize) [*]const u32;
    pub const getShmTextureFormats = wlr_renderer_get_shm_texture_formats;

    extern fn wlr_renderer_get_dmabuf_texture_formats(renderer: *Renderer) ?*const wlr.DrmFormatSet;
    pub const getDmabufFormats = wlr_renderer_get_dmabuf_texture_formats;

    extern fn wlr_renderer_read_pixels(
        renderer: *Renderer,
        fmt: u32,
        stride: u32,
        width: u32,
        height: u32,
        src_x: u32,
        src_y: u32,
        dst_x: u32,
        dst_y: u32,
        data: [*]u8,
    ) bool;
    pub const readPixels = wlr_renderer_read_pixels;

    extern fn wlr_renderer_get_drm_fd(renderer: *Renderer) c_int;
    pub const getDrmFd = wlr_renderer_get_drm_fd;

    extern fn wlr_renderer_destroy(renderer: *Renderer) void;
    pub const destroy = wlr_renderer_destroy;

    // wlr_render functions:

    extern fn wlr_render_texture(
        renderer: *Renderer,
        texture: *wlr.Texture,
        projection: *const [9]f32,
        x: c_int,
        y: c_int,
        alpha: f32,
    ) bool;
    pub fn renderTexture(
        renderer: *Renderer,
        texture: *wlr.Texture,
        projection: *const [9]f32,
        x: c_int,
        y: c_int,
        alpha: f32,
    ) !void {
        if (!wlr_render_texture(renderer, texture, projection, x, y, alpha))
            return error.RenderFailed;
    }

    extern fn wlr_render_texture_with_matrix(
        renderer: *Renderer,
        texture: *wlr.Texture,
        matrix: *const [9]f32,
        alpha: f32,
    ) bool;
    pub fn renderTextureWithMatrix(
        renderer: *Renderer,
        texture: *wlr.Texture,
        matrix: *const [9]f32,
        alpha: f32,
    ) !void {
        if (!wlr_render_texture_with_matrix(renderer, texture, matrix, alpha))
            return error.RenderFailed;
    }

    extern fn wlr_render_subtexture_with_matrix(
        renderer: *Renderer,
        texture: *wlr.Texture,
        box: *const wlr.FBox,
        matrix: *const [9]f32,
        alpha: f32,
    ) bool;
    pub fn renderSubtextureWithMatrix(
        renderer: *Renderer,
        texture: *wlr.Texture,
        box: *const wlr.FBox,
        matrix: *const [9]f32,
        alpha: f32,
    ) !void {
        if (!wlr_render_subtexture_with_matrix(renderer, texture, box, matrix, alpha))
            return error.RenderFailed;
    }

    extern fn wlr_render_rect(
        renderer: *Renderer,
        box: *const wlr.Box,
        color: *const [4]f32,
        projection: *const [9]f32,
    ) void;
    pub const renderRect = wlr_render_rect;

    extern fn wlr_render_quad_with_matrix(
        renderer: *Renderer,
        color: *const [4]f32,
        matrix: *const [9]f32,
    ) void;
    pub const renderQuadWithMatrix = wlr_render_quad_with_matrix;

    pub const BufferPassOptions = extern struct {
        timer: ?*RenderTimer,
    };
    extern fn wlr_renderer_begin_buffer_pass(renderer: *Renderer, buffer: *wlr.Buffer, options: ?*const BufferPassOptions) ?*RenderPass;
    pub fn beginBufferPass(renderer: *Renderer, buffer: *wlr.Buffer, options: ?*const BufferPassOptions) !*RenderPass {
        return wlr_renderer_begin_buffer_pass(renderer, buffer, options) orelse error.OutOfMemory;
    }

    extern fn wlr_render_timer_create(renderer: *Renderer) ?*RenderTimer;
    pub fn createRenderTimer(renderer: *Renderer) !*RenderTimer {
        return wlr_render_timer_create(renderer) orelse error.OutOfMemory;
    }
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
