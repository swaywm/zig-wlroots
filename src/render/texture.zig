const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

const pixman = @import("pixman");

pub const Texture = extern struct {
    const Impl = opaque {};

    pub const ReadPixelsOptions = extern struct {
        data: *anyopaque,
        format: u32,
        stride: u32,
        dst_x: u32,
        dst_y: u32,
        src_box: wlr.Box,
    };

    impl: *const Impl,
    width: u32,
    height: u32,

    extern fn wlr_texture_read_pixels(texture: *Texture, options: *const ReadPixelsOptions) bool;
    pub const readPixels = wlr_texture_read_pixels;

    extern fn wlr_texture_preferred_read_format(texture: *Texture) u32;
    pub const preferredReadFormat = wlr_texture_preferred_read_format;

    extern fn wlr_texture_from_pixels(renderer: *wlr.Renderer, wl_fmt: wl.Shm.Format, stride: u32, width: u32, height: u32, data: *const anyopaque) ?*Texture;
    pub const fromPixels = wlr_texture_from_pixels;

    extern fn wlr_texture_from_dmabuf(renderer: *wlr.Renderer, attribs: *wlr.DmabufAttributes) ?*Texture;
    pub const fromDmabuf = wlr_texture_from_dmabuf;

    extern fn wlr_texture_update_from_buffer(texture: *Texture, buffer: *wlr.Buffer, damage: *const pixman.Region32) bool;
    pub const updateFromBuffer = wlr_texture_update_from_buffer;

    extern fn wlr_texture_destroy(texture: *Texture) void;
    pub const destroy = wlr_texture_destroy;

    extern fn wlr_texture_from_buffer(renderer: *wlr.Renderer, buffer: *wlr.Buffer) ?*Texture;
    pub const fromBuffer = wlr_texture_from_buffer;
};
