#!/usr/bin/env bash
cd ~/../../../Volumes/workspace/blogSource/ && hugo && git add . && git commit -m "feature/new blog" && git push && cd public/ && git add . && git commit -m "feature/new blog" && git push --set-upstream origin master