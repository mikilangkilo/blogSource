#!/usr/bin/env bash
read -p "Input name:" -s name
echo $name
cd ~/Desktop/hugoSite/content/ && hugo new post/$name.md