#!/bin/bash

(
    cd test || exit

    if ! docker image ls | grep tronikel/conflict-marker.nvim-test &>/dev/null; then
        docker build -t tronikel/conflict-marker.nvim-test .
    fi
)

docker run --rm \
    -v ./lua:/root/.config/nvim/lua/ \
    -v ./test:/root/test/ \
    tronikel/conflict-marker.nvim-test:latest
