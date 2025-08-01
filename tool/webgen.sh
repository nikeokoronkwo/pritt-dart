#!/bin/sh

cd packages/webgen
pnpm i
pnpm compile
pnpm bundle
cd -
node tool/webgen/dist/webgen.js $@