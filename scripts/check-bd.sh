#!/bin/bash

echo "Check master"
PGPASSWORD='test' \
psql "host=127.0.0.1 port=5432 user=postgres dbname=postgres" -c \
"select inet_server_addr() as server,
        inet_server_port() as port,
        pg_is_in_recovery() as is_replica,
        current_setting('transaction_read_only') as ro;";

echo "Check replica";
PGPASSWORD='test' \
psql "host=127.0.0.1 port=5433 user=postgres dbname=postgres" -c \
"select inet_server_addr() as server,
        inet_server_port() as port,
        pg_is_in_recovery() as is_replica,
        current_setting('transaction_read_only') as ro;"

