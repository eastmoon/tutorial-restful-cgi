FROM nginx

# Install common tools
RUN \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        python \
        curl \
        fcgiwrap
## Python default install is version 2.7, it will need to install pip 2.7 by script
RUN \
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py | python

# Install c++ library dependency
ADD ./fcgiwrap /etc/init.d/fcgiwrap
ADD ./99-start-fcgiwrap.sh /docker-entrypoint.d/99-start-fcgiwrap.sh

# Inculde nginx configuration
ADD ./default.conf /etc/nginx/conf.d/default.conf
