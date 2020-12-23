const std = @import("std");

pub const Edges = packed struct {
    // ensure the struct is aligned as a u32 so that it can be used as a
    // field in extern structs where a u32 is expected.
    top: bool align(@alignOf(u32)) = false,
    bottom: bool = false,
    left: bool = false,
    right: bool = false,
    // padding to 32 bits
    _: u28 = 0,

    comptime {
        std.debug.assert(@sizeOf(@This()) == @sizeOf(u32));
        std.debug.assert(@alignOf(@This()) == @alignOf(u32));
    }
};
