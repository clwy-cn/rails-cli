# Rails Docked

一个基于 Docker 的 Rails 开发环境，让你在任何操作系统上都能轻松开发 Rails 应用。

## 为什么选择 Rails Docked？

- 🚀 完全隔离的开发环境，避免系统依赖冲突
- 🔥 预配置中国区镜像源，解决网络问题
- 💪 内置常用开发依赖，无需繁琐配置
- 🎯 支持所有主流操作系统（Windows / macOS / Linux）

安装 `Rails` 开发环境，对于新手来说，非常棘手：

- 在中国大陆，由于网络环境不够友好，导致安装 `Ruby` 和 `RubyGems` 非常困难。
- `Rails` 项目开发中，经常需要安装一些由 `C` 或 `Rust` 等语言开发的 `Gem` 包。这些包在 `Windows` 中编译安装非常困难。
- 对于一些老旧 `macOS`，无法使用 `Homebrew` 正确安装第三方依赖。例如 [Active Storage](https://guides.rubyonrails.org/active_storage_overview.html) 中所需要的图片分析工具 [vips](https://github.com/libvips/libvips)，在 `macOS Monterey` 上已无法正确安装了。

为了让大家无论使用什么操作系统的电脑，都能简单、顺利的开发 `Ruby On Rails` 应用，于是有了 `Rails Docked` 这个项目。其中，主要参考了 [Docked Rails CLI](https://github.com/rails/docked) 的相关配置。

## 环境说明

预置环境包含：
- Ruby 3.4.1（默认开启 YJIT）
- Rails 8.0.1
- Node 22.12.0 + Yarn

预置镜像源包括：
- apt 命令：阿里云镜像源
- Ruby Gem：Ruby China 镜像源
- npm / Yarn：中国镜像源

<img width="837" alt="image" src="https://github.com/user-attachments/assets/d53a9e95-88c5-4941-b862-269ff0f329cb" />

## 安装 Docker

首先需要先安装 [Docker](https://www.docker.com/products/docker-desktop/)。如在安装过程出现了问题（常见于 Windows），请参考 [Docker 安装教程](https://clwy.cn/chapters/fullstack-node-mysql)。

## 创建 Docker 卷

创建一个名为 `ruby-bundle-cache` 的卷，用于保存 `Ruby` 项目的依赖包。

```bash
docker volume create ruby-bundle-cache
```

## 创建项目

### macOS、Linux 系统

创建一个名为 `docked` 的别名：

```bash
alias docked='docker run --rm -it \
 -v ${PWD}:/rails \
 -v ruby-bundle-cache:/bundle \
 -p 3000:3000 \
 registry.cn-hangzhou.aliyuncs.com/clwy/rails-docked'
 ```

创建 `rails` 项目：

```bash
docked rails new weblog -d postgresql
```

### Windows 系统

使用`PowerShell`，创建一个名为 `docked` 的别名：

```bash
Function docked { docker run --rm -it -v ${PWD}:/rails -v ruby-bundle-cache:/bundle -p 3000:3000 registry.cn-hangzhou.aliyuncs.com/clwy/rails-docked $args }
```

创建 `rails` 项目：

```bash
docked rails new weblog -d postgresql
```

## 使用 Docker Compose 配置容器

建好后，用编辑器打开 `weblog` 项目。在项目根目录下，增加 `docker-compose.yml` 文件，并添加如下内容：

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
volumes:
  ruby-bundle-cache:
    external: true
```

其中包含：

- PostgreSQL 17
- Redis 7.4

## 修改数据库连接

修改项目中的 `config/database.yml` 文件，增加如下数据库配置信息，这样才能连接到容器中的数据库：

```yml
default: &default
  # ...
  host: postgresql
  username: postgres
```

## 启动项目

- 启动容器

```bash
cd weblog
docker-compose up -d
```

- 进入容器

```bash
docker-compose exec web bash
```

- 安装 Ruby Gems

```bash
bundle install
```

- 创建数据库

```bash
rails db:create
```

- 使用脚手架，自动生成增删改查功能（可选）

```bash
# 创建路由、模型和迁移文件
rails generate scaffold post title:string body:text

# 迁移数据库
rails db:migrate
```

- 启动服务

```bash
rails s
```

等待服务顺利启动后，请访问 [http://localhost:3000/posts](http://localhost:3000/posts)

<img width="840" alt="image" src="https://github.com/user-attachments/assets/dbe0d056-27cd-4d53-bccc-3c2c944f3db7" />

## 常见问题

### 1. 如何更新

```bash
docker pull registry.cn-hangzhou.aliyuncs.com/clwy/rails-docked
```

### 2. 如何使用 MySQL 数据库？
如果需要使用 `MySQL` 替代 `PostgreSQL`，在创建项目时使用 `-d mysql` 参数，例如

```bash
docked rails new weblog -d mysql
```

并相应修改 `docker-compose.yml` 中的数据库配置，例如：

```yaml
services:
  web:
    image: "registry.cn-hangzhou.aliyuncs.com/clwy/rails-docked"
    ports:
      - "3000:3000"
    depends_on:
      - mysql
      - redis
    volumes:
      - .:/rails
      - ruby-bundle-cache:/bundle
    tty: true
    stdin_open: true
    command: ["tail", "-f", "/dev/null"]
  mysql:
    image: mysql:8.3
    ports:
      - "3306:3306"
    environment:
      MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
    volumes:
      - ./data/mysql:/var/lib/mysql
  redis:
    image: redis:7.4
    ports:
      - "6379:6379"
    volumes:
      - ./data/redis:/data
volumes:
  ruby-bundle-cache:
    external: true
```

同时需要修改 `config/database.yml` 中的数据库配置：

```yaml
default: &default
  # ...
  username: root
  password:
  host: mysql
```

### 2. 容器启动失败怎么办？
- 检查端口是否被占用
- 确保 Docker 服务正在运行
- 查看容器日志：`docker-compose logs`

### 3. macOS、Linux下如何设置 docked 别名？
在 macOS 和 Linux 系统中，可以通过以下方式设置别名：

```bash
# 编辑配置文件（根据你使用的 shell 选择合适的文件）
# 如果使用 bash，编辑 ~/.bashrc
# 如果使用 zsh，编辑 ~/.zshrc

# 在配置文件中添加以下内容
alias docked='docker run --rm -it \
 -v ${PWD}:/rails \
 -v ruby-bundle-cache:/bundle \
 -p 3000:3000 \
 registry.cn-hangzhou.aliyuncs.com/clwy/rails-docked'

# 使配置生效
source ~/.bashrc  # 如果使用 bash
# 或
source ~/.zshrc   # 如果使用 zsh
```

### 3. Windows 下如何设置 docked 别名？

在 Windows 系统中，可以通过以下方式设置 `PowerShell` 别名：

```bash
# 查看 PowerShell 配置文件的路径
echo $PROFILE
# 输出类似：C:\Users\用户名\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

# 如果该文件不存在，可以使用命令创建
New-Item -Path $PROFILE -Type File -Force

# 用你喜欢的编辑器打开该文件，添加以下内容
Function docked { docker run --rm -it -v ${PWD}:/rails -v ruby-bundle-cache:/bundle -p 3000:3000 registry.cn-hangzhou.aliyuncs.com/clwy/rails-docked $args }
```

注意：在运行 `docked rails new xxx` 命令时，有可能碰到提示：

```bash
无法加载文件 C:\Users\用户名\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1，因为在此系统上禁止运行脚本。
```

如果碰到这个错误，需要用`管理员身份`打开 `PowerShell`，然后运行：

```bash
Set-ExecutionPolicy RemoteSigned
# 接着按 A 键继续
```

## 许可证

本项目采用 [MIT 许可证](https://opensource.org/licenses/MIT)。

---

# Rails Docked

A Docker-based Rails development environment that makes it easy to develop Rails applications on any operating system.

## Why Choose Rails Docked?

- 🚀 Completely isolated development environment, avoiding system dependency conflicts
- 🔥 Pre-configured Chinese mirrors to solve network issues
- 💪 Built-in common development dependencies, no complex configuration needed
- 🎯 Supports all major operating systems (Windows / macOS / Linux)

Installing a `Rails` development environment can be challenging for beginners:

- In mainland China, installing `Ruby` and `RubyGems` is difficult due to network restrictions
- Rails projects often require `Gem` packages developed in `C` or `Rust`. These packages are difficult to compile and install on `Windows`
- For older `macOS` versions, it's impossible to correctly install third-party dependencies using `Homebrew`. For example, the image analysis tool [vips](https://github.com/libvips/libvips) required by [Active Storage](https://guides.rubyonrails.org/active_storage_overview.html) can no longer be installed correctly on `macOS Monterey`

`Rails Docked` was created to help everyone develop `Ruby On Rails` applications smoothly, regardless of their operating system. The configuration is mainly based on [Docked Rails CLI](https://github.com/rails/docked).

## Environment Details

Pre-installed environment:
- Ruby 3.4.1 (YJIT enabled by default)
- Rails 8.0.1
- Node 22.12.0 + Yarn

Pre-configured mirrors:
- apt command: Aliyun mirror
- Ruby Gem: Ruby China mirror
- npm / Yarn: Chinese mirror

<img width="837" alt="image" src="https://github.com/user-attachments/assets/d53a9e95-88c5-4941-b862-269ff0f329cb" />

## Installing Docker

First, install [Docker](https://www.docker.com/products/docker-desktop/). If you encounter any issues during installation (common on Windows), please refer to the [Docker Installation Guide](https://clwy.cn/chapters/fullstack-node-mysql).

## Creating Docker Volume

Create a volume named `ruby-bundle-cache` to store Ruby project dependencies.

```bash
docker volume create ruby-bundle-cache
```

## Creating a Project

### macOS and Linux Systems

Create an alias named `docked`:

```bash
alias docked='docker run --rm -it \
 -v ${PWD}:/rails \
 -u $(id -u):$(id -g) \
 -v ruby-bundle-cache:/bundle \
 -p 3000:3000 \
 registry.cn-hangzhou.aliyuncs.com/clwy/rails-docked'
```

Create a `rails` project:

```bash
docked rails new weblog -d postgresql
```

### Windows System

Using `PowerShell`, create an alias named `docked`:

```bash
Function docked { docker run --rm -it -v ${PWD}:/rails -v ruby-bundle-cache:/bundle -p 3000:3000 registry.cn-hangzhou.aliyuncs.com/clwy/rails-docked $args }
```

Create a `rails` project:

```bash
docked rails new weblog -d postgresql
```

## Configuring Docker Compose

After creation, open the `weblog` project in your editor. Add a `docker-compose.yml` file in the project root directory with the following content:

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
volumes:
  ruby-bundle-cache:
    external: true
```

Includes:
- PostgreSQL 17
- Redis 7.4

## Configuring Database Connection

Modify the `config/database.yml` file in your project to add the following database configuration for connecting to the container database:

```yml
default: &default
  # ...
  host: postgresql
  username: postgres
```

## Starting the Project

- Start containers

```bash
cd weblog
docker-compose up -d
```

- Enter container

```bash
docker-compose exec web bash
```

- Install Ruby Gems

```bash
bundle install
```

- Create database

```bash
rails db:create
```

- Generate scaffold for CRUD functionality (optional)

```bash
# Create routes, model and migration files
rails generate scaffold post title:string body:text

# Migrate database
rails db:migrate
```

- Start server

```bash
rails s
```

After the service starts successfully, visit [http://localhost:3000/posts](http://localhost:3000/posts)

<img width="840" alt="image" src="https://github.com/user-attachments/assets/dbe0d056-27cd-4d53-bccc-3c2c944f3db7" />

## Common Questions

### 1. How to Update

```bash
docker pull registry.cn-hangzhou.aliyuncs.com/clwy/rails-docked
```

### 2. How to Use MySQL Database?
To use `MySQL` instead of `PostgreSQL`, use the `-d mysql` parameter when creating the project:

```bash
docked rails new weblog -d mysql
```

Then modify the database configuration in `docker-compose.yml`:

```yaml
services:
  web:
    image: "registry.cn-hangzhou.aliyuncs.com/clwy/rails-docked"
    ports:
      - "3000:3000"
    depends_on:
      - mysql
      - redis
    volumes:
      - .:/rails
      - ruby-bundle-cache:/bundle
    tty: true
    stdin_open: true
    command: ["tail", "-f", "/dev/null"]
  mysql:
    image: mysql:8.3
    ports:
      - "3306:3306"
    environment:
      MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
    volumes:
      - ./data/mysql:/var/lib/mysql
  redis:
    image: redis:7.4
    ports:
      - "6379:6379"
    volumes:
      - ./data/redis:/data
volumes:
  ruby-bundle-cache:
    external: true
```

Also modify the database configuration in `config/database.yml`:

```yaml
default: &default
  # ...
  username: root
  password:
  host: mysql
```

### 2. What to Do If Container Fails to Start?
- Check if ports are already in use
- Ensure Docker service is running
- Check container logs: `docker-compose logs`

### 3. How to Set Up docked Alias on macOS and Linux?
On macOS and Linux systems, you can set up the alias as follows:

```bash
# Edit configuration file (choose based on your shell)
# For bash, edit ~/.bashrc
# For zsh, edit ~/.zshrc

# Add the following content to the file
alias docked='docker run --rm -it \
 -v ${PWD}:/rails \
 -u $(id -u):$(id -g) \
 -v ruby-bundle-cache:/bundle \
 -p 3000:3000 \
 registry.cn-hangzhou.aliyuncs.com/clwy/rails-docked'

# Apply changes
source ~/.bashrc  # if using bash
# or
source ~/.zshrc   # if using zsh
```

### 3. How to Set Up docked Alias on Windows?

On Windows systems, you can set up the `PowerShell` alias as follows:

```bash
# View PowerShell profile file path
echo $PROFILE
# Output similar to: C:\Users\username\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

# If the file doesn't exist, create it using
New-Item -Path $PROFILE -Type File -Force

# Open the file with your preferred editor and add
Function docked { docker run --rm -it -v ${PWD}:/rails -v ruby-bundle-cache:/bundle -p 3000:3000 registry.cn-hangzhou.aliyuncs.com/clwy/rails-docked $args }
```

Note: When running the `docked rails new xxx` command, you might encounter a warning: 

```bash
Unable to load file C:\Users\Username\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 because running scripts is disabled on this system.
```

If you encounter this error, you need to open `PowerShell` as `Administrator`, and then run:

```bash
Set-ExecutionPolicy RemoteSigned
# Then press the A key to continue
```

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).
