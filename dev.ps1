$builddir="static"
jade -P src/index.jade -O $builddir
jade -P src/auth_recv.jade -O $builddir
jade -P src/partials -O $builddir/partials
stylus -o $builddir/css src/styl/style.styl
coffee -b -o $builddir/js -j out.js src/coffee 
Copy-Item -ea 0 -r src/css $builddir 
Copy-Item -ea 0 -r src/images $builddir
Copy-Item -ea 0 -r src/js $builddir
