---
title: 使用appveyor.xml 进行双端部署hexo
date: 2017-12-21 11:12:17
tags:
---


# 注册并登录AppVeyor

> 访问 [AppVeyor](https://ci.appveyor.com/login),使用github登录即可。

# 添加project

> 在 [project页面](https://ci.appveyor.com/projects/new),添加相应的source repo

# 添加appveyor.yml到source repo

> appveyor如[appveyor样例](https://github.com/formulahendry/formulahendry.github.io.source/blob/master/appveyor.yml),只需要更改 [Your Github Access Token]即可。

# 在repo/settings/Environment中添加四个变量

> GIT_USER_EMAIL: github email
> GIT_USER_NAME: github username
> STATIC_SITE_REPO: blog repo site
> TARGET_BRANCH: blog repo main branch (default is master)

# 完成

> 背后的过程如下
> Git push to Source Repo -> AppVeyor CI -> Update GitHub Pages Content Repo -> Generate your Hexo blog site

# [出处](https://formulahendry.github.io/2016/12/04/hexo-ci/)
