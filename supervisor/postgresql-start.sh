#/bin/bash
DATA_DIR=/data/pgsql

# test if DATA_DIR has content
if [[ ! "$(ls -A $DATA_DIR)" ]]; then
    echo "Initializing PostgreSQL at $DATA_DIR"
    sudo -u postgres /usr/lib/postgresql/9.3/bin/initdb  -D /data/pgsql/

fi

chown -R postgres $DATA_DIR
chmod -R 700 $DATA_DIR

/etc/init.d/postgresql start