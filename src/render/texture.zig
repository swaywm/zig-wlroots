const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const TextureAttribs = extern struct {
    const GLenum: u32 = 0;
    const GLuint: u32 = 0;

    target: GLenum,
    tex: GLuint,

    hasAlpha: bool,
};

pub const Texture = extern struct {
    const Impl = opaque {};

    impl: *const Impl,
    width: u32,
    height: u32,

    extern fn wlr_texture_from_pixels(renderer: *wlr.Renderer, wl_fmt: wl.Shm.Format, stride: u32, width: u32, height: u32, data: *const anyopaque) ?*Texture;
    pub const fromPixels = wlr_texture_from_pixels;

    extern fn wlr_texture_from_dmabuf(renderer: *wlr.Renderer, attribs: *wlr.DmabufAttributes) ?*Texture;
    pub const fromDmabuf = wlr_texture_from_dmabuf;

    extern fn wlr_texture_is_opaque(texture: *Texture) bool;
    pub const isOpaque = wlr_texture_is_opaque;

    extern fn wlr_texture_is_gles2(texture: *Texture) bool;
    pub const isGles2 = wlr_texture_is_gles2;

    extern fn wlr_gles2_texture_get_attribs(texture: *Texture, attribs: *TextureAttribs) void;
    pub const gles2TextureAttribs = wlr_gles2_texture_get_attribs;

    extern fn wlr_texture_write_pixels(texture: *Texture, stride: u32, width: u32, height: u32, src_x: u32, src_y: u32, dst_x: u32, dst_y: u32, data: *const anyopaque) bool;
    pub const writePixels = wlr_texture_write_pixels;

    extern fn wlr_texture_destroy(texture: *Texture) void;
    pub const destroy = wlr_texture_destroy;

    extern fn wlr_texture_from_buffer(renderer: *wlr.Renderer, buffer: *wlr.Buffer) ?*Texture;
    pub const fromBuffer = wlr_texture_from_buffer;
};
