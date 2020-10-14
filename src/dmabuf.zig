pub const DmabufAttributes = extern struct {
    pub const Flags = extern enum {
        y_invert = 1,
        interlaced = 2,
        bottom_first = 4,
    };

    width: i32,
    height: i32,
    format: u32,
    flags: u32,
    modifier: u64,

    n_planes: c_int,
    offset: [4]u32,
    stride: [4]u32,
    fd: [4]c_int,

    extern fn wlr_dmabuf_attributes_finish(attribs: *DmabufAttributes) void;
    pub const finish = wlr_dmabuf_attributes_finish;

    extern fn wlr_dmabuf_attributes_copy(dst: *DmabufAttributes, src: *DmabufAttributes) bool;
    pub const copy = wlr_dmabuf_attributes_copy;
};
