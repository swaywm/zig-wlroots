# zig-wlroots

Idiomatic [Zig](https://ziglang.org/) bindings for
[wlroots](https://gitlab.freedesktop.org/wlroots/wlroots).

The main repository is on [codeberg](https://codeberg.org/ifreund/zig-wlroots),
this is where the issue tracker may be found and where contributions are accepted.

Read-only mirrors exist on [sourcehut](https://git.sr.ht/~ifreund/zig-wlroots)
and [github](https://github.com/ifreund/zig-wlroots).

## Completion status

Large parts of the wlroots API are fully bound, more than enough for the
[river](https://github.com/riverwm/river) Wayland compositor to use these bindings.

At this stage, I only personally add bindings for new parts of the
wlroots API as required by river. If your project requires some
part of the wlroots API not yet bound please open an issue or pull
request on [codeberg](https://codeberg.org/ifreund/zig-wlroots).

## Dependencies

- [zig](https://ziglang.org/) 0.11
- [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots) 0.17
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
