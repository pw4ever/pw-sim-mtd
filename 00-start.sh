#!/bin/sh

NAME=pw-sim-mtd

SBCL_RUNTIME_OPT="--noinform --disable-ldb --lose-on-corruption --merge-core-pages --dynamic-space-size 2048"
SBCL_TOPLEVEL_OPT="--disable-debugger"

sbcl ${SBCL_RUNTIME_OPT} --end-runtime-options ${SBCL_TOPLEVEL_OPT} \
    --eval "(with-open-stream (*standard-output* (make-broadcast-stream)) (ql:quickload :${NAME}))"\
    --eval "(in-package :${NAME})"\
    --eval "(getopt)"\
    --eval "(sim)"\
    --quit --end-toplevel-options $*
