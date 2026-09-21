# smooth-scroll.hx

`smooth-scroll.hx` is a plugin for [Helix](https://github.com/helix-editor/helix/) which provides built-in function replacements which scroll smoothly between positions. The full list of functions can be seen in the installation section.

https://github.com/user-attachments/assets/2cf59e34-f6db-4f1e-9254-ea0298ae5cfd

## Installation

Follow the instructions [here](https://github.com/mattwparas/helix/blob/steel-event-system/STEEL.md) to install Helix on the plugin branch.

Then, install the plugin with:

```sh
forge pkg install --git https://github.com/thomasschafer/smooth-scroll.hx.git
```

Once installed, you can add the following to `init.scm` in your Helix config directory:

```scheme
(require "smooth-scroll/smooth-scroll.scm")
```

Then, you can update your `config.toml` to make use of the smooth scrolling functions:

```toml
[keys.normal]
C-d = ":half-page-down-smooth"
C-u = ":half-page-up-smooth"
pageup = ":page-up-smooth"
pagedown = ":page-down-smooth"

[keys.normal.z]
z = ":align-view-center-smooth"
t = ":align-view-top-smooth"
b = ":align-view-bottom-smooth"
```

The alignment functions land the cursor exactly where `zz`, `zt` and `zb` do, which means
they respect `editor.scrolloff`: with the default of `5`, `zt` leaves five rows above the
cursor rather than putting it flush against the top. That margin is discovered by asking
Helix how far it is willing to scroll, so there is nothing to configure.

One known limitation: if `editor.scrolloff` is set to half the height of the viewport or
more, the alignments can settle one row away from where the built-ins would. Helix uses a
slightly different margin at the bottom of the viewport than at the top, and only the top
one is observable from a plugin.
