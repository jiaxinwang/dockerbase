# Docker Base Image

一个项目脚手架，目的是提高版本管理的自动化程度，降低 docker build 的痛苦值，更多的 build == 快乐的 build，

## 快速开始

clone 仓库，进入本地文件夹

```
# 构建镜像
make docker-build
# 看看效果
docker images
# 快速进入镜像，快乐 coding ...
make test

# 以下操作需要修改 makefile 中的 registry 地址，并 docker login

# 推送镜像
make docker-push
# 拉取镜像
make docker-pull
# 导出
make docker-save

```

## Dockerfile 构建

Dockerfile 里只定义了几句

```
FROM registry.cn-hangzhou.aliyuncs.com/modelscope-repo/modelscope:ubuntu20.04-cuda11.3.0-py37-torch1.11.0-tf1.15.5-1.0.2
```

基于`registry.cn-hangzhou.aliyuncs.com/modelscope-repo/modelscope:ubuntu20.04-cuda11.3.0-py37-torch1.11.0-tf1.15.5-1.0.2` 大伙可以根据自己的需要改成不同的 base 镜像

```
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)"
```

因为达摩院的 base 镜像使用的是 /bin/sh 缺少常用的开箱系统工具且效率不高，为了方便进容器里鼓捣，安装 zsh，这句需要挂 VPN，但构建之后，本地 docker 会有缓存，以后再增加新的操作就不用挂梯子了。

```
# ENTRYPOINT ["tail", "-f", "/dev/null"]
```

在一些特殊场景下，打开这句注释，可以让容器一直活着，不会退出。

## makefile

makefile 里定义了几个命令，首先，保证你的项目文件夹 git 状态 clean，该提交的都已提交，没有 dirty data。

在

```
BIN_NAME=wangjiaxin/ubuntu20.04-cuda11.3.0-py37-torch1.11.0-tf1.15.5
BIN_NAME_ALIAS=registry.cn-beijing.aliyuncs.com/showmethemoney/damobase
```

这里，定义你的产品名称，同时也是 docker 仓库名称，因为我想将镜像同时推给 docker hub 和 阿里 registry，所以我定义了一个别名，大伙可以根据需求自行修改

然后，看看仓库有什么 tag，再给仓库打个不一样的 tag

```
git tag
git tag {不一样的tag}
```

```
GIT_TAG := $(shell git describe --abbrev=0 --tags 2>/dev/null || echo 0.0.0)
GIT_COMMIT_SEQ := $(shell git rev-parse --short HEAD)
GIT_COMMIT_CNT := $(shell git rev-list --all --count)
VERSION := $(GIT_TAG)-$(GIT_COMMIT_CNT)-$(GIT_COMMIT_SEQ)
FULL_VERSION := $(BIN_NAME):$(VERSION)
FULL_VERSION_ALIAS := $(BIN_NAME_ALIAS):$(VERSION)
```

这里会从 git 拿一些数据，如果你所有的改动都提交了，这里会定义镜像的 tag 为：

```
registry.cn-beijing.aliyuncs.com/showmethemoney/damobase:{不一样的tag}-{这个git仓库的总commit次数}-{最后一次commit的hash数}
```

如：

```
registry.cn-beijing.aliyuncs.com/showmethemoney/damobase:v0.0.1-11-11feaeb
# 该容器产生自 hash 为 11feaeb 的提交，此次提交是 git 仓库第 11 次提交，仓库最后一个 tag 是 v0.0.1
```

也就是说，每次`git commit`后，你都将得到一个不同的 docker image tag 字符串，它完整的描述了这个 image 来自哪一次 git 提交。

别的就没啥好说的，都很简单，脚手架怎么改都行，比如一次打上多个 tag，或者一次导出多个 tar 文件

最后，如果想**一键**构建最新的 image，并进入容器鼓捣:

```
make docker-build test
```
