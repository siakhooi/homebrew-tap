
repo := ''
tag := ''
owner := ''
tap := 'homebrew-tap'
get:
    curl https://api.github.com/repos/{{ owner }}/{{ repo }}/releases/tags/{{ tag }} | tee release.json
cp:
    echo cp -vr Formula `brew --repo`/Library/Taps/{{ owner }}/{{ tap }}/
test:
    brew install {{ repo }}
