# NixOS / Dotfiles Refactor — TODO

A running list of the refactor's architecture work, bug fixes, and planned
features. Personal life-plan items (purchases, specs, non-technical stuff)
live in `future.txt`, which is gitignored.

---

## 🔁 Two-machine routine

Both machines (`desktop`, `laptop`) follow `origin/main`. GitHub is the
single source of truth.

**Start of a session on a machine:**
1. `git fetch`, then `git status -sb`
2. `[behind N]` → `git pull --ff-only` (`[ahead N]` → push first;
   `[ahead N, behind M]` → diverged, stop and sort it out by hand)
3. `git diff --stat ORIG_HEAD HEAD` to see what came in:
   - `nix-config/`, `flake.nix`, `flake.lock`, `pkgs/` → `update-mySystem`
     and reboot
   - `nvim-config` pointer → `git submodule update --init`
   - `zsh/.zshrc.personal`, `conf/` → `exec zsh` / reload
   - docs, notes, scripts only → nothing more to do

**End of a session:** commit and push, so the other machine has something
to pull.

---

## ✅ Recently completed

- **Python / Jupyter stack for class (jupynium)**: `jupynium.nvim` working
  end to end on the desktop — notebook sync, cell execution (`<space>x`)
  and Jupyter-kernel completion in nvim-cmp (verified with
  `get_ipython`). Pieces: a single Nix Python environment `pyDevTools`
  in `system.nix` (jupyter-console, notebook, nbclassic, flake8, black,
  isort); `geckodriver` in the system packages; a venv at
  `~/.virtualenvs/jupynium` holding the plugin's Python half (installed by
  lazy's `build` line); a `jupynium-python` wrapper script in the home
  packages that sets `LD_LIBRARY_PATH` to Nix's libstdc++ so the pip-built
  `greenlet` wheel can load, used as the plugin's `python_host`; the
  `jupynium` source added to the nvim-cmp `sources` list. Selenium
  downloads its own Firefox into `~/.cache/selenium` (not Zen).
- **Zen as the default browser**: the `xdg.mimeApps` entries in
  `home/modules/programs.nix` pointed at `zen.desktop`, which doesn't
  exist (Nix installs `zen-beta.desktop`), so lookups fell through to
  Chromium. Fixed the filename; verified with `xdg-mime query default`
  and the Hytale launcher login now opening Zen.
- **Branch unification**: `laptop` and `main` merged into one history
  (`merge -s ours`, then `main` fast-forwarded). One flake, two
  `nixosConfigurations` (`desktop`, `laptop`) built from
  `nix-config/hosts/*`, sharing the same modules; laptop-only
  `hybrid-graphics.nix` (nvidia-prime). Per-host `networking.hostName`,
  and a single `update-mySystem` alias that picks the host from the
  hostname. Both machines rebuilt, booted and verified.
- **Firewall**: removed the legacy iptables / nftables overrides from
  `network.nix` (ExpressVPN debugging leftovers that kept the firewall
  service from starting). Firewall starts cleanly on both machines.
- **networking-lab module**: `nix-config/modules/networking-lab/` with
  vsftpd (disabled by default), its PAM service, and the FTP + passive
  port range in the firewall. Phone → laptop transfer verified end to end.
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
- **Unused vsftpd test certificate**: removed `certs/vsftpd.pem` from the
  repo and added `*.pem` to `.gitignore`. The private key is still in
  public git history, so it is treated as burned and must never be reused
  for anything real.
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

## 🐍 Python / Jupyter (class setup)

- [ ] **Laptop setup**: `git pull --ff-only`, `update-mySystem` + reboot,
      then create the venv by hand (`python3 -m venv
      ~/.virtualenvs/jupynium`) *before* opening nvim, so lazy's `build`
      line has somewhere to install. The venv isn't declared anywhere in
      the repos — decide whether to document it in the README or make it
      reproducible
- [ ] Selenium downloads its own Firefox into `~/.cache/selenium` on first
      use (needs internet, version not pinned). Decide whether to pin a
      Firefox through Nix instead
- [ ] Someday: get jupynium to drive Zen instead of Selenium's Firefox.
      Tried `SE_FIREFOX_PATH=~/.nix-profile/bin/zen-beta nvim …` (variable
      documented by Selenium Manager): nothing launched, no geckodriver
      process, and no error surfaced. Needs reading jupynium's/Selenium's
      logs; Zen isn't an officially supported browser for jupynium
- [ ] Consolidate Python: there is a plain `python314` in
      `home/modules/packages.nix` and the `pyDevTools` environment in
      `system.nix` — keep one, so `python3` is unambiguous
- [ ] Add the class's libraries (numpy, matplotlib, …) to `pyDevTools` once
      the course material says which — notebook kernels run in that
      environment
- [ ] `jupynium-python` only fixes `libstdc++` — other pip-built wheels may
      need further libraries; revisit if a new compiled dependency fails
      (alternative: take the compiled dependencies from nixpkgs)
- [ ] `jupynium.lua`: split the large `opts` table into readable sections
      with less nesting
- [ ] Jupynium completion: the README's `sorting` / `comparators` block was
      skipped on purpose (a `comparators` list replaces nvim-cmp's
      defaults; `priority_weight` changes ranking for all sources) —
      revisit only if kernel suggestions rank badly
- [ ] Optional: set a Jupyter password instead of the per-run token (the
      README recommends it); optional: upgrade pip inside the venv
- [ ] Learn Python basics for the class (docs.python.org/3/tutorial)

---

## 📝 Neovim config

- [ ] Give the `nvim-config` repo its own `README.md` and `TODO.md`
- [ ] Lint setup: lua_ls and selene report `vim` as an undefined global —
      configure them for Neovim (selene's Neovim std, lua_ls workspace
      library)
- [ ] Redo the LSP / linter / completion ecosystem properly (current setup
      is a quick, partly adapted baseline). Includes: nvim-lint wiring for
      tools that are only on PATH through Nix, and conform's formatters
- [ ] `nvim-notify` warns at startup that `NotifyBackground` has no
      background colour — set `background_colour` in its setup
- [ ] `client.is_stopped is deprecated` message — find the offending
      plugin with `:checkhealth vim.deprecated`

---

## 🖱️ Desktop defaults / cleanup

- [ ] Remove `chromium` from `system.nix` and decide about `brave` in the
      home packages. First check what the two web-app shortcuts
      `chrome-hoeckimmdkhoojlgdafcefdbcpkigklk-Default.desktop` and
      `brave-hoeckimmdkhoojlgdafcefdbcpkigklk-Default.desktop` in
      `~/.local/share/applications` are for — removing the browsers would
      break them
- [ ] `xdg.mimeApps` is declared in both `home/modules/display.nix` and
      `home/modules/programs.nix` — works (the module system merges them),
      but move it into one place
- [ ] `xdg-settings get default-web-browser` still reports `gvim.desktop`
      (stray association); check whether it matters or just remove it
- [ ] Decide whether `gcc` (and other toolchain packages) belong in the
      system config instead of `home.packages`

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
      pinned dependencies, instead of relying on ambient `PATH`. Also:
      `nvimunity` and `jupynium-python` currently live inline in the
      `let` of `home/modules/packages.nix` — move each into its own file
      so the `let` goes away and the module stays small
- [ ] Virtual mic links are declared in three places (wireplumber
      module, systemd user service, `start.sh`) — keep one, remove the
      race
- [ ] `nm-applet --inidicator` typo in `start.sh` (silently wrong flag)
- [ ] `nvimunity` script: broken nested-quote escaping in the `eval`
      construction, and `xdotool`-based Shift detection likely silently
      fails on Wayland/Hyprland — refactor it by hand once the shell
      scripting reading is done
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
      `dnx-convert`, `spf`, `update-mySystem`, `man-virtualMic`,
      `vmic-vol`) into a shell-neutral `shell/aliases` file — partially
      done (toggle-monitor/play-sound already extracted as standalone
      scripts)
- [ ] Bring config-linking under an automated tool (GNU Stow or a small
      script) instead of manual per-app `ln -s`
- [ ] Move `force-gigabit` out of the shared `network.nix` into
      `hosts/desktop/` — it targets `enp4s0`, so the laptop currently
      runs a service for an interface it doesn't have
- [ ] Per-host wallpaper preloads: `hyprpaper.conf` preloads wallpapers
      for both machines, so each one may log errors for files that don't
      exist on it (cosmetic)
- [ ] Per-host cava audio source: the laptop has no Razer headset, so the
      hyprlock equalizer shows no bars there. `~/.config/cava/config`
      isn't in `mysystem/conf/` yet, so the fix currently exists only on
      the desktop (cosmetic)
- [ ] Check unexplained leftovers: `scripts/TMP`, `tmpRealConfig/`, and
      whether `conf/tmux/plugins/` (TPM-cloned third-party repos) is
      tracked wholesale
- [ ] Untrack `scripts/blender/__pycache__/axis_lock.cpython-314.pyc`
      and gitignore `__pycache__/`
- [ ] Decide whether `conf/waybar/config.bak` stays tracked or goes
- [ ] Delete the old `laptop` branch (local and remote) after a few days
      of using both machines on `main`; check that no alias or script
      still refers to it
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

## 🌐 Networking

- [ ] `networking-lab`: give it an enable flag (or move it under
      `hosts/laptop/`) so the desktop doesn't open FTP ports for a
      service it never runs. vsftpd itself stays `enable = false` except
      while testing — plaintext FTP
- [ ] vsftpd: define the passive port range once with a `let` and use it
      in both the firewall and `extraConfig`, so the two can't drift
- [ ] vsftpd: add `localRoot` so the phone only sees one folder instead
      of the whole home directory
- [ ] Phone (GrapheneOS): "Always-on VPN + Block connections without
      VPN" blocks LAN access. Either use the VPN app's LAN-bypass option
      or only disable lockdown while testing, and re-enable afterwards
- [ ] `networking-lab` future: xinetd + inetutils comparison against the
      native vsftpd approach; split into one file per exercise when a
      second one arrives
- [ ] WireGuard + SSH remote access from the uni laptop to the home PC:
      SSH reachable only through the tunnel, key-based auth only, DDNS
      instead of a static IP. Order: build and test on the LAN first →
      have a friend from cybersecurity review it → only then the router
      port-forward

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
