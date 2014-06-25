#/bin/bash
DATA_DIR=/data/pgsql

# test if DATA_DIR has content
if [[ ! "$(ls -A $DATA_DIR)" ]]; then
    echo "Initializing PostgreSQL at $DATA_DIR"
    cp -R /var/lib/postgresql/9.3/main/* $DATA_DIR  
    FIRST_RUN="true"  
fi

post_start_action() {
    echo "Creating the superuser: $USER"
    sudo -u postgres -H -- psql -c "DROP ROLE IF EXISTS $PG_USER;CREATE ROLE $PG_USER WITH ENCRYPTED PASSWORD '$PG_PASS';ALTER USER $PG_USER WITH ENCRYPTED PASSWORD '$PG_PASS';ALTER ROLE $PG_USER WITH SUPERUSER;ALTER ROLE $PG_USER WITH LOGIN;"
    if [ $(env | grep PG_DB) ]; then
        sudo -u postgres -H -- psql -c "CREATE DATABASE $PG_DB WITH OWNER=$PG_USER ENCODING='UTF8'; GRANT ALL ON DATABASE $db TO $PG_USER"
    fi
}

chown -R postgres:postgres $DATA_DIR
chmod -R 700 $DATA_DIR

/etc/init.d/postgresql start

if [ "$FIRST_RUN" = "true" ]; then
    post_start_action
fi