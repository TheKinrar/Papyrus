#!/usr/bin/env bash

(
set -e
PS1="$"
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/work"
gitcmd="git -c commit.gpgsign=false"

updated="0"
function getRef {
    git ls-tree $1 $2  | cut -d' ' -f3 | cut -f1
}
function getPaperRef {
    cd "$workdir/Paper"
    getRef HEAD "work/$1"
}
function update {
    cd "$workdir/$1"
    $gitcmd fetch && $gitcmd clean -fd && $gitcmd reset --hard $2
    refRemote=$(git rev-parse HEAD)
    cd ../
    $gitcmd add $1 -f
    refHEAD=$(getRef HEAD "$workdir/$1")
    echo "$1 $refHEAD - $refRemote"
    if [ "$refHEAD" != "$refRemote" ]; then
        export updated="1"
    fi
}
function updateP() {
    update $1 $(getPaperRef $1)
}

update Paper origin/ver/1.16.5
updateP Bukkit
updateP CraftBukkit
updateP Spigot

if [[ "$2" = "all" || "$2" = "a" ]] ; then
	updateP BuildData
	updateP Paperclip
fi
if [ "$updated" == "1" ]; then
    echo "Rebuilding patches without filtering to improve apply ability"
    cd "$basedir"
    scripts/rebuildPatches.sh "$basedir" nofilter 1>/dev/null|| exit 1
fi
)
