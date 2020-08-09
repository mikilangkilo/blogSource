#!/usr/bin/env bash
read -p "Input name:" -s name
echo $name
cd ~/../../../Volumes/workspace/blogSource/ && hugo new post/$name.md