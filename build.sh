#!/bin/bash
docker run -it --rm --name libuv-android-ndk -v "$1":/opt/build libuv-android-ndk:latest