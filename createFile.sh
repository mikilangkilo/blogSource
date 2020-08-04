#!/usr/bin/env bash
read -p "Input name:" -s name
echo $name
cd ~/Desktop/self-projects/blogSource/ && hugo new post/$name.md