#!/usr/bin/env bash

ROLES=(
    cmc

    archive
    aria2
    base
    borg
    browsers
    calibre
    cron
    cups
    dotfiles
    firejail
    fonts
    gnupg
    himawaripy
    hostsctl
    i3
    laptop
    lightdm
    media
    microcode
    mirrorlist
    nettools
    networkmanager
    nmtrust
    ntp
    office
    pkgfile
    postgresql
    pydev
    ripgrep
    screensaver
    sound
    ssd
    ssh
    sysmon
    virtualbox
    virtualenv
    visidata
    wttr
    x

    # android
    # aws
    # backitup
    # bitlbee
    # bluetooth
    # cryptshot
    # dictd
    # editors
    # filesystems
    # gdm
    # git-annex
    # gnome
    # goesimage
    # hardened
    # hashicorp
    # iptables
    # ledger
    # localtime
    # logitech
    # macbook
    # macchiato
    # mail
    # mapping
    # mpd
    # mpv
    # openresolv
    # optical
    # parcimonie
    # pass ## TODO(cmc): esp. the rofi part
    # pdf
    # pianobar
    # pim
    # radio
    # rtorrent
    # spell
    # syncthing
    # tarsnap
    # taskwarrior
    # thinkpad
    # tor
    # udisks
    # unbound ## TODO(cmc): maybe at one point though
    # units
    # weechat
    # wormhole
    # yubikey ## TODO(cmc): maybe at one point though
)
SKIPPED_TAGS=(
    abcde
    autocutsel
    beets
    enscript
    gimp
    gthumb
    inkscape
    libreoffice
    mcomix
    pandoc
    qutebrowser
    shell-zsh
    simplescan
    surfraw
    termite
    texlive
    tor-browser
    undertime
    zoom
)

echo "The following tags will run:"
ansible-playbook                                     \
    -i localhost                                     \
    --tags $(IFS=, ; echo "${ROLES[*]}")             \
    --skip-tags $(IFS=, ; echo "${SKIPPED_TAGS[*]}") \
    --list-tags                                      \
    playbook.yml

read -r -p "Are you sure? [y/N] " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then
    ansible-playbook                                     \
        -i localhost                                     \
        --tags $(IFS=, ; echo "${ROLES[*]}")             \
        --skip-tags $(IFS=, ; echo "${SKIPPED_TAGS[*]}") \
        playbook.yml
fi
