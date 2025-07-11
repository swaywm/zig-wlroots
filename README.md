# zig-wlroots

Idiomatic [Zig](https://ziglang.org/) bindings for
[wlroots](https://gitlab.freedesktop.org/wlroots/wlroots).

The main repository is on [codeberg](https://codeberg.org/ifreund/zig-wlroots),
which is where the issue tracker may be found and where contributions are accepted.

Read-only mirrors exist on [sourcehut](https://git.sr.ht/~ifreund/zig-wlroots)
and [github](https://github.com/swaywm/zig-wlroots).

## Completion status

Large parts of the wlroots API are fully bound, more than enough for the
[river](https://codeberg.org/river/river) Wayland compositor to use these bindings.

At this stage, I only personally add bindings for new parts of the
wlroots API as required by river. If your project requires some
part of the wlroots API not yet bound please open an issue or pull
request on [codeberg](https://codeberg.org/ifreund/zig-wlroots).

## Dependencies

- [zig](https://ziglang.org/) 0.15
- [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots) 0.19
- [zig-wayland](https://codeberg.org/ifreund/zig-wayland)
- [zig-xkbcommon](https://codeberg.org/ifreund/zig-xkbcommon)
- [zig-pixman](https://codeberg.org/ifreund/zig-pixman)

## Usage

See [tinywl.zig](./tinywl/) for an example compositor using zig-wlroots and an example
of how to integrate zig-wlroots and its dependencies into your build.zig.

See the C headers of wlroots for documentation.

## Versioning

zig-wlroots versions have the form `major.minor.revision` where major and minor
are the major and minor version numbers of the compatible wlroots release. The
revision number is incremented for every zig-wlroots release compatible with a
given wlroots release. Breaking changes and bugfixes may occur with only a
revision version bump. The required Zig version may be updated with a revision
version bump.

For example, zig-wlroots `0.16.42` would be compatible with wlroots 0.16, the 42
indicating that there were 42 zig-wlroots releases since the initial wlroots 0.16
compatible zig-wlroots release.

For unreleased versions, the `-dev` suffix is used (e.g. `0.1.0-dev`).

## License

zig-wlroots is released under the MIT (expat) license. The contents of the tinywl directory
are not part of zig-wlroots and are released under the Zero Clause BSD license.
