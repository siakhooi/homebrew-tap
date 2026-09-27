
repo := ''
tag := ''
owner := ''
tap := 'homebrew-tap'

default:
    @just --list
get:
    curl https://api.github.com/repos/{{ owner }}/{{ repo }}/releases/tags/{{ tag }} | tee release.json
cp:
    cp -vr Formula `brew --repo`/Library/Taps/{{ owner }}/{{ tap }}
test:
    brew trust {{ owner }}/tap
    brew install {{ repo }}
tree:
    tree `brew --repo`/Library/Taps/{{ owner }}/{{ tap }}

bump-all:
    ./scripts/bump-up-version.sh

bump app:
    ./scripts/bump-up-version.sh {{ app }}
