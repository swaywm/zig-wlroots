pub const Box = extern struct {
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
};

pub const FBox = extern struct {
    x: f64,
    y: f64,
    width: f64,
    height: f64,
};
