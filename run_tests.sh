#!/bin/bash

docker build -t tronikel/conflict-marker.nvim-test .

docker run --rm \
    -v ./lua:/root/.config/nvim/lua/ \
    -v ./test:/root/test/ \
    tronikel/conflict-marker.nvim-test:latest
