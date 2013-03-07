#!/bin/bash
set -eu

mkdir -p static/css
coffee -wbj out.js -o static/js src/coffee &
jade -wP src/index.jade -O static &
jade -wP src/partials -O static/partials &
stylus -w -o static/css src/styl/style.styl &
python app.py
wait

