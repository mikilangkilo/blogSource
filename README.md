---
title: "About"
date: 2019-03-12T21:09:56+08:00
---

from hexo to hugo

## 安装go
 
brew install go

## clone hogo

git clone https://github.com/gohugoio/hugo.git

## hugo install

cd hugo/

## go install 

go install

## hugo 建站

hugo new site /

## hugo 新建文章

hugo new post/hugo_first_page.md
hugo new post/

## 安装themes

cd themes/
git clone https://github.com/spf13/hyde.git
hugo server --theme=hyde --buildDrafts

即可看到效果

## 指定生成路径为githubio

hugo --theme=hyde --baseUrl="http://gwyloved.github.io/"

## 初始化生成仓库

cd public/
git remote add origin https://github.com/GWYloved/GWYloved.github.io.git
git add .
git commit -m "gg"
git push

# hugo 指令

## 预览

hugo server --theme=hyde --buildDrafts
hugo server -w
hugo server --theme=hugo-creative-theme --buildDrafts

## 生成

hugo --theme=hyde --baseUrl="https://gwyloved.github.io/"

或者hugo

## 根目录直接生成并部署

cd ~/Desktop/hugoSite/ && hugo && git add . && git commit -m "rebase" && git push && cd public/ && git add . && git commit -m "rebase" && git push

## 基于个人简历生成html

1.

brew install pandoc 

2.

cd ~/Desktop/hugoSite/content/ && pandoc -f markdown -t html -o 安卓开发工程师-殷鹏程.html about.md -T "Pengcheng Yin's Resume" --metadata pagetitle="resume" -c css/main.css

