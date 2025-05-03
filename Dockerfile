FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Kolkata


RUN apt-get update && apt-get install -y \ 
    apache2 php8.1 libapache2-mod-php8.1 sqlite3 git curl \
    php8.1-mbstring php8.1-curl php8.1-xml php8.1-gd php8.1-sqlite3
#    apt-get install -y php8.1-common php8.1-json php8.1-mbstring php8.1-curl php8.1-xml php8.1-gd php8.1-pdo php8.1-sqlite3 


# git clone kodbox
RUN git clone -b dev https://github.com/arun912-ux/kodbox.git /var/www/kodbox
RUN chmod 777 -Rf /var/www/kodbox
RUN sed -i "s/\(\$config\['DEFAULT_PERRMISSIONS'\] *= *\)0[0-7]\{3,4\};/\10775;/" /var/www/kodbox/config/setting.php


# change apache conf
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/kodbox|' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's/^#\?export APACHE_RUN_GROUP=.*/export APACHE_RUN_GROUP=lxcsync/' /etc/apache2/envvars


## new custom group for accessing all lxc mounts
RUN groupadd -g 9000 lxcsync \
    && usermod -aG lxcsync www-data

# directory for additional mounts
RUN mkdir -p /opt/storage \
    && chown :lxcsync -R /opt/storage \
    && chmod g+s /opt/storage


# Set directory permissions: 775 and setgid
RUN find /opt/storage -type d -exec chmod 2775 {} \;
# Set file permissions: 664
RUN find /opt/storage -type f -exec chmod 664 {} \;

# Enable Apache modules
RUN a2enmod rewrite

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]
