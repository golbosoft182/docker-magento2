FROM centos:7

ENV XDEBUG_PORT 9000

# Install System Dependencies (PHP 7.2.*)
RUN yum update -y && \
    yum install -y epel-release

RUN yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum install -y yum-utils && \
    yum-config-manager --enable remi-php72 && \
    yum -y update

RUN yum install -y \
    php-fpm \
    php-cli \
    php-opcache\
    php-gd \
    php-xml \
    php-bcmath \
    php-dba \
    php-intl \
    php-mbstring \
    php-mysql \
    php-pdo \
    php-soap \
    php-pecl-apcu \
    php-pecl-imagick \
    php-zip \
    php-pear \
    php-devel

# Install Magento Dependencies
RUN yum install -y \
    curl \
    git \
    gnupg \
    vim \
    wget \
    lynx \
    psmisc \
    unzip \
    tar \
    bash-completion

# Install Node, NVM, NPM and Grunt
RUN yum install -y gcc-c++ make \
    && curl -sL https://rpm.nodesource.com/setup_12.x | bash - \
    && yum install -y nodejs \
    && npm install -y -g grunt

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

# Install Code Sniffer
RUN git clone https://github.com/magento/marketplace-eqp.git ~/.composer/vendor/magento/marketplace-eqp
RUN cd ~/.composer/vendor/magento/marketplace-eqp && composer install
RUN ln -s ~/.composer/vendor/magento/marketplace-eqp/vendor/bin/phpcs /usr/local/bin;

# Install XDebug
RUN yes | pecl install xdebug && \
    echo "zend_extension=$(find /usr/lib64/php/modules/ -name xdebug.so)" > /etc/php.d/xdebug.iniOLD

# Install Mhsendmail
#RUN yum -y install golang-go \
#   && mkdir /opt/go \
#   && export GOPATH=/opt/go \
#   && go get github.com/mailhog/mhsendmail

# Configuring system
RUN useradd -M -d /opt/app -s /bin/false nginx

RUN mkdir -p /run/php-fpm && \
    chown nginx:nginx /run/php-fpm

RUN mkdir -p /var/lib/php/session && \
    chown nginx:nginx /var/lib/php/session

COPY .docker/php-fpm/php-fpm.conf /etc/php-fpm.conf
COPY .docker/php-fpm/www.conf /etc/php-fpm.d/www.conf
COPY .docker/php-fpm/php.ini /etc/php.ini

#COPY .docker/bin/* /usr/local/bin/
#COPY .docker/users/* /var/www/
RUN chmod +x /usr/local/bin/*

#RUN chmod 777 -Rf /var/www /var/www/.* \
#    && chown -Rf www-data:www-data /var/www /var/www/.* \
#    && usermod -u 1000 www-data \
#    && chsh -s /bin/bash www-data\
#    && a2enmod rewrite \
#    && a2enmod headers

VOLUME /var/www/html
WORKDIR /var/www/html

RUN yum clean all

CMD php-fpm