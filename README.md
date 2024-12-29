Forked from [Docked Rails CLI](https://github.com/rails/docked)，其中包含：

- Ruby 3.4.1 + YJIT
- Node 22.12.0
- [Ruby China Gem](https://gems.ruby-china.com/)
- Rails 8.0.1

# Docked Rails CLI

首次设置 Rails 并安装所有必要的依赖项对于初学者来说可能会感到棘手。Docked Rails CLI 使用 Docker 镜像使其变得更加容易，只需要安装 Docker 即可。

安装 [Docker](https://www.docker.com/products/docker-desktop/)（Windows 用户还需要安装 [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)）。然后将以下命令复制粘贴到终端中：

```bash
docker volume create ruby-bundle-cache
alias docked='docker run --rm -it -v ${PWD}:/rails -u $(id -u):$(id -g) -v ruby-bundle-cache:/bundle -p 3000:3000 registry.cn-hangzhou.aliyuncs.com/clwy/rails-cli'
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
    image: "registry.cn-hangzhou.aliyuncs.com/clwy/rails-docked"
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
    command: ["tail", "-f", "/dev/null"]
  postgresql:
    image: postgres:17
    ports:
      - "5432:5432"
    environment:
      POSTGRES_HOST_AUTH_METHOD: trust
    volumes:
      - ./data/pgdata:/var/lib/postgresql/data
  redis:
    image: redis:7.4
    ports:
      - "6379:6379"
    volumes:
      - ./data/redis:/data
  meilisearch:
    image: getmeili/meilisearch:v1.12
    environment:
      - MEILI_ENV=development
    ports:
      - "7700:7700"
    volumes:
      - ./data/meili_data:/meili_data
volumes:
  ruby-bundle-cache:
    external: true
```

其中包含：

- PostgreSQL 17
- Redis 7.4
- MeiliSearch 1.12

修改`config/database.yml`文件，将数据库配置增加如下内容：

```yml
default: &default
  # ...
  host: postgresql
  username: postgres
```

启动容器

```bash
docker-compose up -d
```

进入容器

```bash
docker-compose exec web bash
```

安装 Ruby Gems：

```bash
bundle install
```

启动项目

```bash
rails s
```

Forked from [Docked Rails CLI](https://github.com/rails/docked), which contains:

- Ruby 3.4.1 + YJIT 
- Node 22.12.0
- [Ruby China Gem](https://gems.ruby-china.com/)
- Rails 8.0.1

# Docked Rails CLI

Setting up Rails for the first time with all the dependencies necessary can be daunting for beginners. Docked Rails CLI uses a Docker image to make it much easier, requiring only Docker to be installed.

Install [Docker](https://www.docker.com/products/docker-desktop/) (and [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) on Windows). Then copy'n'paste into your terminal:

```bash
docker volume create ruby-bundle-cache
alias docked='docker run --rm -it -v ${PWD}:/rails -u $(id -u):$(id -g) -v ruby-bundle-cache:/bundle -p 3000:3000 registry.cn-hangzhou.aliyuncs.com/clwy/rails-cli'
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
    image: "registry.cn-hangzhou.aliyuncs.com/clwy/rails-docked"
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
    command: ["tail", "-f", "/dev/null"]
  postgresql:
    image: postgres:17
    ports:
      - "5432:5432"
    environment:
      POSTGRES_HOST_AUTH_METHOD: trust
    volumes:
      - ./data/pgdata:/var/lib/postgresql/data
  redis:
    image: redis:7.4
    ports:
      - "6379:6379"
    volumes:
      - ./data/redis:/data
  meilisearch:
    image: getmeili/meilisearch:v1.12
    environment:
      - MEILI_ENV=development
    ports:
      - "7700:7700"
    volumes:
      - ./data/meili_data:/meili_data
volumes:
  ruby-bundle-cache:
    external: true
```

Which contains:

- PostgreSQL 17
- Redis 7.4
- MeiliSearch 1.12

Modify the `config/database.yml` file to add the database configuration:

```yaml
default: &default
  # ...
  host: postgresql
  username: postgres
```

Start the containers:

```bash
docker-compose up -d
```

Enter the container:

```bash
docker-compose exec web bash
```

Install Ruby Gems:

```bash
bundle install
```

Start the project:

```bash
rails s
```