const std = @import("std");

pub const Importance = enum(c_int) {
    silent = 0,
    err = 1,
    info = 2,
    debug = 3,
    last,
};

extern fn wlr_log_init(
    verbosity: Importance,
    callback: ?*const fn (importance: Importance, fmt: [*:0]const u8, args: *std.builtin.VaList) callconv(.c) void,
) void;
pub const init = wlr_log_init;

extern fn wlr_log_get_verbosity() Importance;
pub const getVerbosity = wlr_log_get_verbosity;
