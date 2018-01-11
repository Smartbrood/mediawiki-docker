FROM php:7.2.1-fpm-stretch

# System Dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
               git \
               gettext-base \
               imagemagick \
               libicu-dev \
               # Required for SyntaxHighlighting
               python \
    && rm -r /var/lib/apt/lists/*

# Install the PHP extensions we need
RUN docker-php-ext-install mbstring mysqli opcache intl

# Install the default object cache.
RUN pecl channel-update pecl.php.net \
	&& pecl install apcu-5.1.8 \
	&& docker-php-ext-enable apcu

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# SQLite Directory Setup
RUN mkdir -p /var/www/data \
    && chown -R www-data:www-data /var/www/data

RUN mkdir -p /var/www/html/w \
    && chown -R www-data:www-data /var/www/html/w \
    && touch /var/log/MWf2b.log \
##    && ln -sf /dev/stdout /var/log/MWf2b.log \
    && touch /var/log/MWf2b.log \
    && chown -R www-data:www-data /var/log/MWf2b.log \
    && mkdir -p /efs/mediawiki_upload \
    && chown -R www-data:www-data /efs/mediawiki_upload

VOLUME /var/www/html

WORKDIR /var/www/html

# Version
ENV MEDIAWIKI_MAJOR_VERSION 1.30
ENV MEDIAWIKI_BRANCH REL1_30
ENV MEDIAWIKI_VERSION 1.30.0
ENV MEDIAWIKI_SHA512 ec4aeb08c18af0e52aaf99124d43cd357328221934d593d87f38da804a2f4a5b172a114659f87f6de58c2140ee05ae14ec6a270574f655e7780a950a51178643

# MediaWiki setup
RUN curl -fSL "https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_MAJOR_VERSION}/mediawiki-${MEDIAWIKI_VERSION}.tar.gz" -o mediawiki.tar.gz \
	&& echo "${MEDIAWIKI_SHA512} *mediawiki.tar.gz" | sha512sum -c - \
	&& tar -xz --strip-components=1 -f mediawiki.tar.gz \
	&& rm mediawiki.tar.gz \
        && rm -rf ./images \
        && ln -s  /efs/mediawiki_upload ./images \
	&& chown -R www-data:www-data extensions skins cache images

COPY files/docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
COPY files/LocalSettings.php.template /LocalSettings.php.template
COPY files/fail2banlog.php /fail2banlog.php

ENTRYPOINT ["docker-php-entrypoint"]

EXPOSE 9000

CMD ["php-fpm"]
