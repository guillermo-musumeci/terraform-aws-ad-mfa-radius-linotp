#!/bin/bash

# this script borrows heavily from instructions found here:
# https://aws.amazon.com/blogs/desktop-and-application-streaming/integrating-freeradius-mfa-with-amazon-workspaces/

##################
# LinOTP section #
##################

yum -y update
amazon-linux-extras install epel -y
yum localinstall http://linotp.org/rpm/el7/linotp/x86_64/Packages/LinOTP_repos-1.1-1.el7.x86_64.rpm -y
yum install -y LinOTP LinOTP_mariadb

# applicable if SELinux is enabled (it is not by default)
restorecon -Rv /etc/linotp2/
restorecon -Rv /var/log/linotp

# this needed to reach MariaDB in AWS RDS
yum install mysql

#################################
# linotp-create-mariadb section #
#################################

LANG=C
ENCKEY=encKey
LINOTP_CONF_DIR=/etc/linotp2
LINOTP_INI=$LINOTP_CONF_DIR/linotp.ini

# These passed from Terraform, $MARIA_PASS is also admin password for LinOTP web GUI
MARIA_HOST=${MARIA_HOST}
MARIA_USER=${MARIA_USER}
MARIA_PASS=${MARIA_PASS}

DB_HOST=localhost
DB_NAME=LINOTP
DB_USER=linotp
SERVICE=mariadb.service
#Colors
#DEFAULT='\e[39m'
DEFAULT='\e[0m'
RED='\e[91m'
#YELLOW='\e[93m'
#BLUE='\e[34m'
GREEN='\e[32m'
BOLD='\e[1m'

#Check if the database key exists as a nonempty file and create one in case it is not present.
if ! [ -s /etc/linotp2/encKey ]
then
    dd if=/dev/urandom of="$LINOTP_CONF_DIR/$ENCKEY" bs=1 count=128 && chown linotp "$LINOTP_CONF_DIR/$ENCKEY" && chmod 640 "$LINOTP_CONF_DIR/$ENCKEY"
fi

unset DB_PASS
DB_PASS=$(pwgen -cnsB 32 1)

# grant all privileges does NOT work in AWS RDS. Instead:
# GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER,
# CREATE TEMPORARY TABLES, CREATE VIEW, EVENT, TRIGGER, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, 
# EXECUTE ON $DB_NAME.* to $DB_USER@'%' identified by '$DB_PASS' WITH GRANT OPTION

mysql -u $MARIA_USER -p$MARIA_PASS -h $MARIA_HOST -P 3306 -e "CREATE DATABASE IF NOT EXISTS $DB_NAME; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, CREATE TEMPORARY TABLES, CREATE VIEW, EVENT, TRIGGER, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, EXECUTE ON $DB_NAME.* to $DB_USER@'%' identified by '$DB_PASS' WITH GRANT OPTION; flush privileges"

DATE=$(date +%Y%m%d-%H%M%S)

if [ -e /etc/linotp2/linotp.ini ]
then
        cp -a "$LINOTP_INI" "$LINOTP_INI.backup.$DATE"
fi

cp -a $LINOTP_CONF_DIR/linotp.ini.example $LINOTP_INI
sed -i -re "s%^sqlalchemy.url =.*%sqlalchemy.url = mysql://$DB_USER:$DB_PASS@$MARIA_HOST/$DB_NAME%" $LINOTP_INI

#########################
# LinOTP section part 2 #
#########################

sudo yum install yum-plugin-versionlock -y
sudo yum versionlock python-repoze-who

sudo yum install LinOTP_apache -y
sudo systemctl enable httpd
sudo systemctl start httpd

sudo mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.back
sudo mv /etc/httpd/conf.d/ssl_linotp.conf.template /etc/httpd/conf.d/ssl_linotp.conf

# sudo htdigest /etc/linotp2/admins "LinOTP2 admin area" admin
# leaves something like this> admin:LinOTP2 admin area:82ef060ae34ed45d3e3bb5acf1c69f71
password=$MARIA_PASS
digest="$( printf "%s:%s:%s" "admin" "LinOTP2 admin area" "$password" | md5sum | awk '{print $1}' )"
sudo sh -c "> /etc/linotp2/admins"
sudo sh -c 'printf "%s:%s:" "admin" "LinOTP2 admin area" >> "/etc/linotp2/admins"'
sudo sh -c "printf \"%s\n\" $digest >> /etc/linotp2/admins"

# restart web server
sudo systemctl restart httpd

######################
# FreeRADIUS section #
######################

sudo yum install -y perl-App-cpanminus perl-LWP-Protocol-https perl-Try-Tiny
sudo yum install -y git
sudo cpanm Config::File

# Added per (http://blog.manton.im/2017/02/setting-up-linotp-on-centos-7-with.html)
# cpan LWP::Protocol::https
# yum install -y perl-Crypt-SSLeay perl-Net-SSLeay

sudo yum install -y freeradius freeradius-perl freeradius-utils 

sudo mv /etc/raddb/clients.conf /etc/raddb/clients.conf.back
sudo mv /etc/raddb/users /etc/raddb/users.back

# Note that ${RADIUS_SEC} below is substituted by Terraform before this goes into user data.
# the radius secret is therefore the same as directory_password.
FILENAME=/etc/raddb/clients.conf
sudo touch $FILENAME
sudo chown root:radiusd $FILENAME
sudo chmod 644 $FILENAME
sudo sh -c "> $FILENAME"
sudo tee -a $FILENAME > /dev/null <<EOT
client localhost {
ipaddr  = 127.0.0.1
netmask= 32
secret  = 'TestSecretString'
}
client adconnector {
ipaddr  = 10.10.0.0/16
netmask = 255.255.0.0
secret  = 'TestSecretString'
}
EOT

# Download linotp perl module for FreeRADIUS
sudo git clone https://github.com/LinOTP/linotp-auth-freeradius-perl.git /usr/share/linotp/linotp-auth-freeradius-perl

# To allow FreeRADIUS to execute the ‘linotp’ plugin, overwrite the file
FILENAME=/etc/raddb/mods-available/perl
sudo touch $FILENAME
sudo chown root:radiusd $FILENAME
sudo chmod 640 $FILENAME
sudo sh -c "> $FILENAME"
sudo tee -a $FILENAME > /dev/null <<EOT
perl {
    filename = /usr/share/linotp/linotp-auth-freeradius-perl/radius_linotp.pm
}
EOT

# Activate the perl module
sudo ln -s /etc/raddb/mods-available/perl /etc/raddb/mods-enabled/perl

# Configure LinOTP perl module for FreeRADIUS
# REALM is the one configured in LinOTP web admin GUI
FILENAME=/etc/linotp2/rlm_perl.ini
sudo touch $FILENAME
sudo chown linotp:apache $FILENAME
sudo chmod 644 $FILENAME
sudo sh -c "> $FILENAME"
sudo tee -a $FILENAME > /dev/null <<EOT
#IP of the linotp server
URL=https://localhost/validate/simplecheck
#optional: limits search for user to this realm
REALM=ec.kopicloud.local
#optional: only use this UserIdResolver
RESCONF=LDAP
#optional: comment out if everything seems to work fine
Debug=True
#optional: use this, if you have selfsigned certificates, otherwise comment out
SSL_CHECK=False
EOT

# remove default enablements
sudo rm /etc/raddb/sites-enabled/{inner-tunnel,default}
sudo rm /etc/raddb/mods-enabled/eap

# create new site linotp
FILENAME=/etc/raddb/sites-available/linotp
sudo touch $FILENAME
sudo chown root:radiusd $FILENAME
sudo chmod 640 $FILENAME
sudo sh -c "> $FILENAME"
sudo tee -a $FILENAME > /dev/null <<EOT
server default {
    listen {
        type = auth
        ipaddr = *
        port = 0
        limit {
            max_connections = 16
            lifetime = 0
            idle_timeout = 30
        }
    }
    listen {
        ipaddr = *
        port = 0
        type = acct
    }
    authorize {
        preprocess
        IPASS
        suffix
        ntdomain
        files
        expiration
        logintime
        update control {
            Auth-Type := Perl
        }
        pap
    }
    authenticate {
        Auth-Type Perl {
            perl
        }
    }
    preacct {
        preprocess
        acct_unique
        suffix
        files
    }
    accounting {
        detail
        unix
        -sql
        exec
        attr_filter.accounting_response
    }
    session {
    }
    post-auth {
        update {
            &reply: += &session-state:
        }
        -sql
        exec
        remove_reply_message_if_eap
    }
}
EOT

sudo ln -s /etc/raddb/sites-available/linotp /etc/raddb/sites-enabled/linotp

sudo systemctl enable radiusd
sudo systemctl start radiusd