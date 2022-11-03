const std = @import("std");

pub const Edges = packed struct(u32) {
    top: bool = false,
    bottom: bool = false,
    left: bool = false,
    right: bool = false,
    _: u28 = 0,
};
