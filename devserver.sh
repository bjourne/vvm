#!/bin/bash
set -eu

mkdir -p static/css

coffee -wbj out.js -o static/js src/coffee &
jade -wP src/index.jade -O static &
jade -wP src/partials -O static/partials &
stylus -w -o static/css src/styl/style.styl &
# Python doesn't like to be terminated for unknown reason.
/usr/bin/python app.py &

wait


