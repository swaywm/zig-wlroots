# zig-wlroots

This fork adds support for scenefx to zig-wlroots and provides a sample implementation (tinywl).

## Dependencies

- [zig](https://ziglang.org/) 0.11
- [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots) 0.16
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

- [x] Rounded corners
- [x] Drop shadow
- [ ] Blur support
