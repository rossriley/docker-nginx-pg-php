#/bin/bash
chown -R postgres /var/lib/postgresql/9.3/main
chmod -R 700 /var/lib/postgresql/9.3/main

/etc/init.d/postgresql start