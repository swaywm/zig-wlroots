pub const Edges = extern enum {
    none = 0,
    top = 1 << 0,
    bottom = 1 << 1,
    left = 1 << 2,
    right = 1 << 3,
};
