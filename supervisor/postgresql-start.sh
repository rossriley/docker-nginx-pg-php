#/bin/sh
DATA_DIR=/data/pgsql

# test if DATA_DIR has content
if [ -z "$(ls -A $DATA_DIR)" ]; then
    echo "Initializing PostgreSQL at $DATA_DIR"
    cp -R /var/lib/postgresql/9.3/main/* $DATA_DIR  
    FIRST_RUN="true"  
fi

post_start_action() {
    echo "Creating the superuser: $APP_USER"
    sudo -u postgres -H -- psql -c "DROP ROLE IF EXISTS $APP_USER;CREATE ROLE $APP_USER WITH ENCRYPTED PASSWORD '$APP_PASS';ALTER USER $APP_USER WITH ENCRYPTED PASSWORD '$APP_PASS';ALTER ROLE $APP_USER WITH SUPERUSER;ALTER ROLE $APP_USER WITH LOGIN;"
    if [ $(env | grep APP_DB) ]; then
        sudo -u postgres -H -- psql -c "CREATE DATABASE $APP_DB WITH OWNER=$APP_USER ENCODING='UTF8';"
        sudo -u postgres -H -- psql -c "GRANT ALL ON DATABASE $APP_DB TO $APP_USER;"
        sudo -u postgres -H -- psql -c "CREATE EXTENSION 'uuid-ossp';"
    fi
}

chown -R postgres:postgres $DATA_DIR
chmod -R 700 $DATA_DIR

/etc/init.d/postgresql start

if [ "$FIRST_RUN" = "true" ]; then
    post_start_action
fi