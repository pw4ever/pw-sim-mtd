#!/bin/sh

NAME=pw-sim-mtd.make-world-param

SBCL_RUNTIME_OPT="--noinform --disable-ldb --lose-on-corruption --merge-core-pages"
SBCL_TOPLEVEL_OPT="--disable-debugger"

sbcl ${SBCL_RUNTIME_OPT} --end-runtime-options ${SBCL_TOPLEVEL_OPT} \
    --eval "(with-open-stream (*standard-output* (make-broadcast-stream)) (ql:quickload :${NAME}))"\
    --eval "(in-package :${NAME})"\
    --eval "(getopt)"\
    --eval "(run)"\
    --quit --end-toplevel-options $*
