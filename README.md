Forked from [Docked Rails CLI](https://github.com/rails/docked)

Contains:

- Ruby 3.3.6 + YJIT 
- Node 22.11.0

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

## Complete Project Development Workflow

Create the project:

```bash
docked rails new weblog -d postgresql
```

After creation, in the project root directory, add a `docker-compose.yml` file with the following content:

```yaml
services:
  web:
    image: "registry.cn-hangzhou.aliyuncs.com/clwy/rails-cli"
    command: /bin/bash -c "rm -f /tmp/server.pid && bundle exec rails server -b 0.0.0.0 -P /tmp/server.pid"
    env_file: .env
    ports:
      - "3000:3000"
    depends_on:
      - postgresql
      - redis
    volumes:
      - .:/rails
      - ruby-bundle-cache:/bundle
    tty: true
    stdin_open: true
  postgresql:
    image: postgres:17
    ports:
      - "5432:5432"
    environment:
      POSTGRES_HOST_AUTH_METHOD: trust
    volumes:
      - ./data/pgdata:/var/lib/postgresql/data
  redis:
    image: redis:7.2.5
    ports:
      - "6379:6379"
    volumes:
      - ./data/redis:/data
volumes:
  ruby-bundle-cache:
    external: true
```

Modify the `config/database.yml` file to add the database configuration:

```yaml
default: &default
  # ...
  host: postgresql
  username: postgres
```

Start the project:

```bash
docker-compose up
```

## Sidenote
In `docked`, the [Ruby-China](https://gems.ruby-china.com/) gem source is not used due to occasional issues with delayed updates and network failures. Therefore, when using `docked` in mainland China, you might need to enable a proxy in the command line to install gems properly.

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

## 完整项目开发流程

创建项目：

```bash
docked rails new weblog -d postgresql
```

建好后，在项目根目录，增加`docker-compose.yml`文件，并添加如下内容：

```yml
services:
  web:
    image: "registry.cn-hangzhou.aliyuncs.com/clwy/rails-cli"
    command: /bin/bash -c "rm -f /tmp/server.pid && bundle exec rails server -b 0.0.0.0 -P /tmp/server.pid"
    env_file: .env
    ports:
      - "3000:3000"
    depends_on:
      - postgresql
      - redis
    volumes:
      - .:/rails
      - ruby-bundle-cache:/bundle
    tty: true
    stdin_open: true
  postgresql:
    image: postgres:17
    ports:
      - "5432:5432"
    environment:
      POSTGRES_HOST_AUTH_METHOD: trust
    volumes:
      - ./data/pgdata:/var/lib/postgresql/data
  redis:
    image: redis:7.2.5
    ports:
      - "6379:6379"
    volumes:
      - ./data/redis:/data
volumes:
  ruby-bundle-cache:
    external: true
```

修改`config/database.yml`文件，将数据库配置增加如下内容：

```yml
default: &default
  # ...
  host: postgresql
  username: postgres
```

启动项目

```bash
docker-compose up
```

## 备注
`docked`中，并没有使用[Ruby-China](https://gems.ruby-china.com/)作为 gem 源，因为偶尔有更新不及时、网络失败等问题。所以在中国大陆地区使用，有可能需要在命令行中开启代理，才能正常安装 gem。
