FROM wordpress:6.6-php8.2-apache

# APT Update/Upgrade, then install packages we need
RUN apt update && \
    apt upgrade -y && \
    apt autoremove -y && \
    apt install -y \
    less \
    vim \
    wget \
    mariadb-client \
    curl

# Copy custom PHP configuration
COPY config/php/jc.ini $PHP_INI_DIR/conf.d/

# Clean up the default wp-content and copy the custom content
RUN rm -fR /usr/src/wordpress/wp-content
COPY src/ /usr/src/wordpress/wp-content


# Copy custom command script
COPY config/cmd.sh /usr/local/sbin
COPY config/backup.sh /usr/local/sbin

# Ensure the command script is executable
RUN chmod +x /usr/local/sbin/cmd.sh
RUN chmod +x /usr/local/sbin/backup.sh

# Install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    php wp-cli.phar --info && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy .htaccess file
COPY config/.htaccess /var/www/html/.htaccess

# Set entrypoint and command
ENTRYPOINT ["cmd.sh"]
CMD ["apache2-foreground"]
