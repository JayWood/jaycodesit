FROM wordpress:6.6-php8.2-apache

# APT Update/Upgrade, then install packages we need
RUN apt update && \
    apt upgrade -y && \
    apt autoremove && \
    apt install -y \
    less \
    vim \
    wget \
    mariadb-client

COPY config/php/jc.ini $PHP_INI_DIR/conf.d/

RUN rm -fR /usr/src/wordpress/wp-content

COPY src/ /usr/src/wordpress/wp-content

COPY config/cmd.sh /usr/local/sbin

# Copy custom Apache configuration file for LogLevel
#COPY config/apache-custom.conf /etc/apache2/conf-available/

# Enable the custom configuration by creating a symbolic link
#RUN ln -s /etc/apache2/conf-available/apache-custom.conf /etc/apache2/conf-enabled/

RUN chmod +x /usr/local/sbin/cmd.sh

# Install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    php wp-cli.phar --info && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy .htaccess file
COPY config/.htaccess /var/www/html/.htaccess

ENTRYPOINT ["cmd.sh"]
CMD ["apache2-foreground"]
