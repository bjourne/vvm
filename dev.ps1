jade -P src/index.jade -O bld
jade -P src/partials -O bld/partials
stylus -o bld/css src/styl/style.styl
coffee -b -o bld/js -j out.js src/coffee 
Copy-Item -ea 0 -r src/css bld 
Copy-Item -ea 0 -r src/images bld
Copy-Item -ea 0 -r src/js bld
Copy-Item -ea 0 -r bld/* C:\p\db\Dropbox\Public
