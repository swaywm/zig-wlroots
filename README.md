# zig-wlroots

Idiomatic [Zig](https://ziglang.org/) bindings for
[wlroots](https://gitlab.freedesktop.org/wlroots/wlroots).

*Note: these bindings are early in development and should not be considered
as stable as wlroots*

## Dependencies

- [zig](https://ziglang.org/) 0.9
- [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots) 0.15
- [zig-wayland](https://github.com/ifreund/zig-wayland)
- [zig-xkbcommon](https://github.com/ifreund/zig-xkbcommon)
- [zig-pixman](https://github.com/ifreund/zig-pixman)

## Usage

See [tinywl.zig](./tinywl/) for an example compositor using zig-wlroots and an example
of how to integrate zig-wlroots and its dependencies into your build.zig.

See the C headers of wlroots for documentation.

## License

zig-wlroots is released under the MIT (expat) license. The contents of the tinywl directory
are not part of zig-wlroots and are released under the Zero Clause BSD license.

## TODO

- [x] Bind enough to port [tinywl](https://gitlab.freedesktop.org/wlroots/wlroots/-/tree/master/tinywl)
- [x] Bind enough to port [river](https://github.com/riverwm/river)
- [ ] Complete bindings
