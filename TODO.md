# NixOS / Dotfiles Refactor — TODO

A running list of the refactor's architecture work, bug fixes, and planned
features. Personal life-plan items (purchases, specs, non-technical stuff)
live in `future.txt`, which is gitignored.

---

## ✅ Recently completed

- **run-src**: hand-built bash script replacing `run-file.sh` +
  `run-file-pager.sh`. Multi-file/glob support, sequential tmux-pane
  execution via `wait-for` signaling, per-language `bin/<lang>/` output
  dirs, shebang-file rescue with a chmod confirm prompt, netrw batch mode
  (confirm-gated, launched in a dedicated tmux window), full nvim
  `<leader>r`/`<leader>R` integration, shellcheck-clean.
- **Auto-tmux**: every interactive shell execs into a tmux session on
  start (`.zshrc.personal`), closing the gap where `run-src` had nowhere
  to split a pane.
- **toggle-monitor** / **play-sound**: extracted from zshrc
  functions/aliases into standalone executable scripts on `PATH` (via
  `home.sessionPath`), callable from waybar/hyprland binds. `play-sound`
  now fires to VirtualMicSink, SoundboardSink, and headset simultaneously.
- **Config version control**: `hypr/`, `ghostty/`, `waybar/`, and `tmux/`
  configs moved from unmanaged `~/.config/*` into `mysystem/conf/*`, each
  symlinked back to its live location.
- **Attribution sweep**: `CREDITS.md` added to both `mysystem` and
  `nvim-config`, documenting every adapted external source (hyprlock-eq,
  DNX_Convert's dnxhd-pcm base, cool-cats' robbyrussell base, waybar and
  much of nvim's remaps/options from ThePrimeagen). Confirmed several
  scripts as fully original along the way.
- **Repo hygiene**: removed a stray duplicate git repo rooted at `~`
  (never had anything sensitive committed to it — verified), fixed a
  stale duplicate submodule entry in `.gitmodules`, fixed a real
  `<leader>ca` keybind collision between cellular-automaton and LSP code
  action.
- **RGB (OpenRGB)**: zone mapping fully corrected (be quiet! fans were on
  a zero-sized zone), `purple` profile re-saved and verified working via
  CLI round-trip. Band-aid notification added for boot-race failures
  (proper systemd service still pending — see below).
- **Hyprlock equalizer**: cava was listening to the wrong audio source
  (silent VirtualMic instead of the headphone monitor) — fixed via an
  explicit `[input] source =` in `~/.config/cava/config`. Labels
  restructured into a single sourced `labels.conf`.
- **Phase 0 deletions**: `tmpConectKeyboard.sh` (pair step ported into
  `ConnectToKnownKeyboard.sh`), `pkgs/lib/autotools.nix` (broken stub),
  waybar's dead `"later"` key, `oh-my-cat.zsh-theme` /
  `oh-my-donut.zsh-theme` (superseded early drafts, evolution visible in
  commit history instead).
- **toggle-monitor() vs mon-on/mon-off**: resolved — kept the toggle
  function only (as a standalone script, see above), dropped the
  redundant alias pair.

---

## 🏗️ Architecture

- [ ] Drop or wire up the unused `nvim-config` flake input in
      `flake.nix` (separate from the `.gitmodules` submodule — this is
      an actual unused flake input still downloading on every
      `nix flake update`)
- [ ] Kill `start.sh` — migrate everything to hyprland `exec-once` lines
      or proper systemd user services (waybar, notification daemon,
      audio enforcer, keyboard connect, RGB profile)
- [ ] Scripts as proper Nix derivations (`writeShellScriptBin`) with
      pinned dependencies, instead of relying on ambient `PATH`
- [ ] Virtual mic links are declared in three places (wireplumber
      module, systemd user service, `start.sh`) — keep one, remove the
      race
- [ ] `nm-applet --inidicator` typo in `start.sh` (silently wrong flag)
- [ ] `nvimunity` script: broken nested-quote escaping in the `eval`
      construction, and `xdotool`-based Shift detection likely silently
      fails on Wayland/Hyprland
- [ ] `stateVersion` mismatch — `system.stateVersion = "25.05"` vs.
      `home.stateVersion = "26.05"` — investigate which is historically
      correct rather than just syncing them
- [ ] Monitors config properly declared
- [ ] fcitx5 profile placement in home.nix (verify current state)
- [ ] DroidCam OBS plugin properly declared (verify current state)
- [ ] `nix.gc.automatic` garbage collection config
- [ ] `expressvpn` is `callPackage`'d in two places (`system.nix` and
      `network.nix`) — define once (overlay or `specialArgs`)
- [ ] `stormy` input missing `inputs.nixpkgs.follows = "nixpkgs"` —
      drags its own nixpkgs closure for a weather widget
- [ ] `allowUnfree` is set in three separate places — consolidate to one
- [ ] Refactor `virtualMicLinkScript`'s nesting (flagged with its own
      `# TODO` comment in `services.nix`)
- [ ] Remove duplicate plain `waybar` in `environment.systemPackages`
      (the `overrideAttrs` experimental-features version should be the
      only one)
- [ ] Decide the fate of the `stream_status` waybar module — script at
      `~/.local/scripts/stream_status` doesn't exist, module has been
      erroring silently every 5s. Remove the module, or write the
      script if the stream-status feature is actually wanted
- [ ] `cool-cats.zsh-theme`: `$(work_in_progress)` is still unescaped
      inside the `PROMPT` string (only `currentGitBranch` uses the
      `\$(...)` deferred-eval form) — the WIP indicator likely still
      only evaluates once at shell start, not per-prompt
- [ ] Merge `eq.sh` and `eq_inverted.sh` into one script taking
      `normal|inverted` as an argument (currently ~95% duplicated)
- [ ] Delete `now_playing_snippet.conf` / `equalizer_snippets.conf` if
      still present (superseded by the `labels.conf` restructure)
- [ ] Drop the `.sh` extension from all scripts (per-script `git mv` +
      grep callers to update references)
- [ ] README note documenting that `scripts/` stays flat until non-shell
      languages are introduced
- [ ] Extract remaining plain zshrc aliases (`rmhs`, `kill-davinci`,
      `dnx-convert`, `spf`, `update-myNixos`, `man-virtualMic`,
      `vmic-vol`) into a shell-neutral `shell/aliases` file — partially
      done (toggle-monitor/play-sound already extracted as standalone
      scripts)
- [ ] Bring config-linking under an automated tool (GNU Stow or a small
      script) instead of manual per-app `ln -s`
- [ ] Merge separate laptop/desktop branches into one flake with two
      `nixosConfigurations` sharing modules, instead of cherry-picking
      between branches
- [ ] Migrate Hyprland to a flake input for broader plugin ecosystem
      access (wanted, explicitly deprioritized)

---

## 📦 Package swaps

- [ ] swaync instead of dunst
- [ ] EasyEffects for the Razer Barracuda X volume curve
- [ ] Helium browser
- [ ] r8126 NIC driver via a proper builder pattern (or try
      `linuxPackages_zen`)

---

## 🔊 Audio safety

- [ ] Waybar volume color coding — green (<60%) / yellow (60–75%) / red
      (>75%)
- [ ] Ear-protection notification after sustained time above threshold
- [ ] Volume cap for the Barracuda X — needs a `pactl subscribe`
      watcher daemon; merge with `audio_enforcer.sh` into one proper
      enforcer service
- [ ] Audio output device detection script (scope from scratch)

---

## 🖥️ Hardware / boot reliability

- [ ] OpenRGB: proper systemd user service with device-ready detection
      and `Restart=on-failure` (band-aid `|| notify-send` is in place
      meanwhile; RGB mapping itself is fully fixed and verified)
- [ ] Per-monitor Hyprland workspaces — blocked upstream: nixpkgs'
      `hyprlandPlugins.hyprsplit` fails to build (tracked:
      nixpkgs#524892), and current hyprsplit has moved to a Lua
      architecture needing the home-manager `wayland.windowManager.hyprland`
      module, which isn't in use (hyprland.conf is hand-managed)

---

## 🎨 Terminal / aesthetics

- [ ] Fastfetch config with full specs, PSU as a variable, ASCII art
- [ ] Verify `future.txt` is properly gitignored
- [ ] Starship port of the cool-cats theme (chosen over maintaining a
      zsh-only prompt — enables cross-shell portability)

---

## 🎓 Skill-building / educational (low priority, on purpose)

- [ ] Experimental auto-detect input mode for run-src, `strace`/fd-0
      based — deliberately parked as a someday learning project, not a
      real need (the manual `-p` flag is the correct permanent design)
- [ ] `nvimunity` "resurrector" — an RPC-based script to gracefully hand
      off from a bare shell into a tmux session with nvim state
      preserved. Superseded in practice by the simpler auto-tmux
      solution; kept as an optional future RPC-learning project
      (reading: `nohup`, `disown`, `setsid`,
      mywiki.wooledge.org/ProcessManagement)

---

## 🎬 Other projects

- [ ] Rebuild the AI-assisted parts of `DNX_Convert.sh` (YouTube/yt-dlp
      support, argument-parsing style) by hand — same standard as
      run-src's no-AI-code rule; the base structure (adapted from
      NapoleonWils0n's dnxhd-pcm) is fine as-is
- [ ] Blender axis-lock addon: add the move-only-along-axis variant on
      plain `Alt+<axis>` (the lock-toggle variant now lives on
      `Shift+Alt+<axis>`)
- [ ] DaVinci Resolve audio loudness normalizer — fully scoped (Resolve
      API for clip enumeration, ffmpeg `loudnorm` for measurement against
      -14 LUFS, color-coding pass/fail, cross-platform), zero code
      written, explicitly deprioritized

---

## 📝 Repo meta

- [x] Publish this list as `TODO.md`, link it from `README.md`
