pub const List = extern struct {
    capacity: usize,
    length: usize,
    items: ?[*]?*c_void,
};
