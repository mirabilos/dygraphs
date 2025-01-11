#!/bin/mksh
#
# Generates JSDoc in the /jsdoc dir. Clears any existing jsdoc there.

set -e

v=$(sed -n '/^Dygraph.VERSION = "\(.*\)";$/s//\1/p' <src/dygraph.js)
test -n "$v" || {
  echo 'E: could not determine version'
  exit 1
}

if [[ -d debian ]]; then
  dv=$(dpkg-parsechangelog -S Version)
  v="$v (Debian $dv)"
fi

rm -rf jsdoc jsdoc.tmp
mkdir jsdoc.tmp
t=$PWD/jsdoc.tmp
(cd /usr/share/nodejs/jsdoc2/templates/jsdoc && pax -rw . "$t/")
find jsdoc.tmp -type f -print0 | xargs -0r perl -pi -e \
  "s/\r+$//;" -e \
  "s! on [{][+]new Date[(][)][+][}]! for dygraph $v!g;"

echo Generating JSDoc...
srcfiles=src/dygraph.js
#srcfiles+=\ src/iframe-tarp.js
srcfiles+=\ src/dygraph-canvas.js
srcfiles+=\ src/dygraph-default-attrs.js
srcfiles+=\ src/dygraph-gviz.js
srcfiles+=\ src/dygraph-interaction-model.js
srcfiles+=\ src/dygraph-internal.externs.js
srcfiles+=\ src/dygraph-layout.js
srcfiles+=\ src/dygraph-options-reference.js
srcfiles+=\ src/dygraph-options.js
srcfiles+=\ src/dygraph-plugin-install.js
srcfiles+=\ src/dygraph-tickers.js
srcfiles+=\ src/dygraph-types.js
#srcfiles+=\ src/dygraph-utils.js
#srcfiles+=\ src/datahandler/datahandler.js
#srcfiles+=\ src/datahandler/default-fractions.js
#srcfiles+=\ src/datahandler/default.js
#srcfiles+=\ src/datahandler/bars.js
#srcfiles+=\ src/datahandler/bars-custom.js
#srcfiles+=\ src/datahandler/bars-error.js
#srcfiles+=\ src/datahandler/bars-fractions.js
srcfiles+=\ src/plugins/annotations.js
srcfiles+=\ src/plugins/axes.js
srcfiles+=\ src/plugins/chart-labels.js
srcfiles+=\ src/plugins/grid.js
#srcfiles+=\ src/plugins/legend.js
#srcfiles+=\ src/plugins/range-selector.js
#srcfiles+=\ src/extras/crosshair.js
#srcfiles+=\ src/extras/hairlines.js
#srcfiles+=\ src/extras/rebase.js
#srcfiles+=\ src/extras/shapes.js
#srcfiles+=\ src/extras/smooth-plotter.js
#srcfiles+=\ src/extras/super-annotations.js
#srcfiles+=\ src/extras/synchronizer.js
#srcfiles+=\ src/extras/unzoom.js
jsdoc2 \
  -t="$t" \
  -d=jsdoc \
  $srcfiles \
2>&1 | tee jsdoc.tmp/.errs

if test -s jsdoc.tmp/.errs; then errs=true; else errs=false; fi
rm -rf jsdoc.tmp

if $errs; then
  echo Please fix any jsdoc errors/warnings
  exit 1
fi

chmod -R a+rX jsdoc

echo Done
