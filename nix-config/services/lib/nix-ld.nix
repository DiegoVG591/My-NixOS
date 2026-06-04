{ config, lib, pkgs, ... }:
{
    # --- NIX-LD: ALLOWS RUNNING UNPATCHED BINARIES --- #
    # Provides fake /lib paths so pre-compiled binaries work on NixOS

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
        # --- BASICS --- #
        zlib        # compression
        zstd        # compression
        stdenv.cc.cc # C++ standard library
        curl        # HTTP transfers
        openssl     # SSL/TLS
        attr        # extended file attributes
        libssh      # SSH library
        bzip2       # compression
        libxml2     # XML parsing
        acl         # access control lists
        libsodium   # cryptography
        util-linux  # Linux utilities
        xz          # compression
        systemd     # systemd libraries

        # --- XORG LIBRARIES --- #
        # X11 display libraries needed by GUI apps
        libx11 libxcomposite libxdamage libxext
        libxfixes libxrandr libxtst libxcb
        libxshmfence libxxf86vm libxinerama
        libxcursor libxrender libxscrnsaver
        libxi libsm libice libxt libxmu libxft

        # --- GRAPHICS & AUDIO --- #
        libGL           # OpenGL
        libva           # video acceleration
        pipewire        # audio
        libdrm          # GPU direct rendering
        libgbm          # GPU buffer management
        vulkan-loader   # Vulkan graphics API
        alsa-lib        # ALSA audio
        libpulseaudio   # PulseAudio

        # --- GTK/GLITCH FIXES --- #
        glib gtk2 gtk3
        gdk-pixbuf cairo pango
        at-spi2-atk at-spi2-core
        dbus dbus-glib expat
        libxkbcommon

        # --- GAME/RUNTIME SUPPORT --- #
        libelf nspr nss cups
        libcap SDL2 libusb1
        ffmpeg libudev0-shim
        icu libnotify

        # --- IMAGE/AUDIO FORMATS --- #
        libogg libvorbis flac
        freeglut libjpeg libpng
        libsamplerate libmikmod
        libtheora libtiff pixman speex

        # --- NETWORKING/UTILS --- #
        networkmanager libxcrypt
        coreutils pciutils zenity

        # --- COMPATIBILITY --- #
        fuse        # filesystem in userspace
        e2fsprogs   # ext filesystem tools
    ];
}

