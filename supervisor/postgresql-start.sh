#/bin/bash

if [ ! -f /data/mysql/ibdata1 ]; then
    mysql_install_db
fi

/usr/bin/mysqld_safe