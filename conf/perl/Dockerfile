FROM nginx

# Install common tools
RUN \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        perl \
        build-essential \
        curl \
        fcgiwrap

# Install JSON parser
RUN \
    echo yes | cpan -i JSON

# Install c++ library dependency
ADD ./fcgiwrap /etc/init.d/fcgiwrap
ADD ./99-start-fcgiwrap.sh /docker-entrypoint.d/99-start-fcgiwrap.sh

# Inculde nginx configuration
ADD ./default.conf /etc/nginx/conf.d/default.conf
