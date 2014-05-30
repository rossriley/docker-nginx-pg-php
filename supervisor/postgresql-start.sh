#/bin/bash
DATA_DIR=/data/pgsql

# test if DATA_DIR has content
if [[ ! "$(ls -A $DATA_DIR)" ]]; then
    echo "Initializing PostgreSQL at $DATA_DIR"
    cp -R /var/lib/postgresql/9.3/main/* $DATA_DIR

fi

chown -R postgres $DATA_DIR
chmod -R 700 $DATA_DIR

/etc/init.d/postgresql start