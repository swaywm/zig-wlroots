pub const List = extern struct {
    capacity: usize,
    length: usize,
    items: ?[*]?*anyopaque,
};
