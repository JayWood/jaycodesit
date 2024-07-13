FROM wordpress:6.5-php8.2-apache

# APT Update/Upgrade, then install packages we need
RUN apt update && \
    apt upgrade -y && \
    apt autoremove && \
    apt install -y \
    vim \
    wget \
    mariadb-client

# Replace php.ini
#COPY php.ini /usr/local/etc/php

COPY config/php/jc.ini $PHP_INI_DIR/conf.d/

RUN rm -fR /usr/src/wordpress/wp-content

COPY src/ /usr/src/wordpress/wp-content

COPY config/cmd.sh /usr/local/sbin

RUN chmod +x /usr/local/sbin/cmd.sh

# Install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    php wp-cli.phar --info && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

ENTRYPOINT ["cmd.sh"]
CMD ["apache2-foreground"]
