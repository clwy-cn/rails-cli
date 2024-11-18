Forked from [Docked Rails CLI](https://github.com/rails/docked)

Contains:

- Ruby 3.3.6 + YJIT 
- Node 22.11.0
- Ruby China mirror

# Docked Rails CLI

Setting up Rails for the first time with all the dependencies necessary can be daunting for beginners. Docked Rails CLI uses a Docker image to make it much easier, requiring only Docker to be installed.

Install [Docker](https://www.docker.com/products/docker-desktop/) (and [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) on Windows). Then copy'n'paste into your terminal:

```bash
docker volume create ruby-bundle-cache
alias docked='docker run --rm -it -v ${PWD}:/rails -u $(id -u):$(id -g) -v ruby-bundle-cache:/bundle -p 3000:3000 ghcr.io/rails/cli'
```

Then create your Rails app:

```bash
docked rails new weblog
cd weblog
docked rails generate scaffold post title:string body:text
docked rails db:migrate
docked rails server
```

That's it! Your Rails app is running on `http://localhost:3000/posts`.

## Sidenote

`docked` is not intended to replace a full development setup. It is merely a way for newcomers to quickly get started with Rails. The included dependencies stick to what you need when running `rails new` without additional options. It does not include dependencies for running with PostgreSQL or Redis for example.


# Docked Rails CLI

首次设置 Rails 并安装所有必要的依赖项对于初学者来说可能会感到棘手。Docked Rails CLI 使用 Docker 镜像使其变得更加容易，只需要安装 Docker 即可。

安装 [Docker](https://www.docker.com/products/docker-desktop/)（Windows 用户还需要安装 [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)）。然后将以下命令复制粘贴到终端中：

```bash
docker volume create ruby-bundle-cache
alias docked='docker run --rm -it -v ${PWD}:/rails -u $(id -u):$(id -g) -v ruby-bundle-cache:/bundle -p 3000:3000 ghcr.io/rails/cli'
```

然后创建你的 Rails 应用：

```bash
docked rails new weblog
cd weblog
docked rails generate scaffold post title:string body:text
docked rails db:migrate
docked rails server
```

就这样！你的 Rails 应用已经在 `http://localhost:3000/posts` 上运行了。

## 补充说明

`docked` 并不旨在替代完整的开发环境。它只是一个让新手快速开始使用 Rails 的方法。包含的依赖项仅限于运行 `rails new` 时不需要额外选项的情况。它不包括运行 PostgreSQL 或 Redis 等所需的依赖项。