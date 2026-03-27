const wlr = @import("../wlroots.zig");

pub const NamedPrimaries = enum(c_int) {
    srgb = 1,
    bt2020 = 2,
};

pub const TransferFunction = enum(c_int) {
    srgb = 1,
    st2084_pq = 2,
    ext_linear = 4,
    gamma22 = 8,
    bt1886 = 16,
};

pub const Encoding = enum(c_int) {
    none = 0,
    identity = 1,
    bt709 = 2,
    fcc = 4,
    bt601 = 8,
    smpte240 = 16,
    bt2020 = 32,
    bt2020_cl = 64,
    ictcp = 128,
};

pub const Range = enum(c_int) {
    none,
    limited,
    full,
};

pub const Cie1931Xy = extern struct {
    x: f32,
    y: f32,
};

pub const Primaries = extern struct {
    red: Cie1931Xy,
    green: Cie1931Xy,
    blue: Cie1931Xy,
    white: Cie1931Xy,
};

pub const Luminances = extern struct {
    min: f32,
    max: f32,
    reference: f32,
};
