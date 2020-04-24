#!/usr/bin/env bash
cd ~/Desktop/hugoSite/ && hugo && git add . && git commit -m "feature/new blog" && git push && cd public/ && git add . && git commit -m "feature/new blog" && git push