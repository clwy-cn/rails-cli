ARG RUBY_VERSION=3.3.6

FROM ruby:$RUBY_VERSION-slim

# Set the sources of the aliyun in China
RUN sed -i 's@deb.debian.org@mirrors.aliyun.com@g' /etc/apt/sources.list.d/debian.sources

# Set the gem of ruby-china sources
RUN gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/

# Configure bundle to use the ruby-china mirror
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libvips gnupg2 curl git libjemalloc2  && \
    postgresql-client libpq-dev default-mysql-client default-libmysqlclient-dev pkg-config

# Ensure node.js 22 is available for apt-get
ARG NODE_MAJOR=22
RUN apt-get update && \
    mkdir -p /etc/apt/keyrings && \
    curl --fail --silent --show-error --location https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# Install node and yarn
RUN apt-get update -qq && apt-get install -y nodejs && npm install -g yarn && \
    npm config set registry https://registry.npmmirror.com/ && \
    yarn config set registry https://registry.npmmirror.com/

# Mount $PWD to this workdir
WORKDIR /rails

# Ensure gems are installed on a persistent volume and available as bins
# Make the folder world writable to let the default user install the gems
RUN mkdir /bundle && chmod -R ugo+rwt /bundle
VOLUME /bundle
ENV BUNDLE_PATH='/bundle'
ENV PATH="/bundle/ruby/$RUBY_VERSION/bin:${PATH}"
ENV RUBY_YJIT_ENABLE="1"

# Install Rails
RUN gem install rails

# Ensure binding is always 0.0.0.0, even in development, to access server from outside container
ENV BINDING="0.0.0.0"

# Overwrite ruby image's entrypoint to provide open cli
ENTRYPOINT [""]