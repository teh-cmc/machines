#!/usr/bin/env bash

# Edit as needed.

MANDATORY_ROLES=(
    ## Bootstrap
    base
    cron
    firejail

    ## Network
    nettools
    networkmanager
    unbound
    openresolv
    hostsctl
    nmtrust
    ssh

    ## Hardware (common)
    archive
    gnupg
    sysmon

    ## Important system daemons
    mirrorlist
    ntp
)
OPTIN_ROLES=(
    ## Bootstrap
    microcode

    ## Hardware (common)
    cups
    sound
    ssd

    ## Hardware (dedicated)
    laptop

    ## Toolchains
    golang
    nodejs
    pydev
    rust

    ## X session
    x
    i3
    lightdm
    fonts
    redshift
    screensaver

    ## Custom
    cmc
    # dotfiles

    ## Everything else
    aria2
    borg
    browsers
    calibre
    himawaripy
    media
    office
    pkgfile
    ripgrep
    virtualbox
    virtualenv
    visidata
    wttr
)
OPTOUT_TAGS=(
    abcde
    bazel
    beets
    enscript
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
ansible-playbook                                                                       \
    -i localhost                                                                       \
    --tags $(IFS=, ; echo "${MANDATORY_ROLES[*]}"),$(IFS=, ; echo "${OPTIN_ROLES[*]}") \
    --skip-tags $(IFS=, ; echo "${OPTOUT_TAGS[*]}")                                    \
    --list-tags                                                                        \
    playbook.yml

read -r -p "Are you sure? [y/N] " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then
    ansible-playbook                                    \
        -i localhost                                    \
        --tags $(IFS=, ; echo "${OPTIN_ROLES[*]}")      \
        --skip-tags $(IFS=, ; echo "${OPTOUT_TAGS[*]}") \
        playbook.yml
fi
