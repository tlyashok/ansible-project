#!/bin/bash

# пишем через write-порт (лидер)
PGPASSWORD='test' psql "host=127.0.0.1 port=5432 user=postgres dbname=postgres" -c \
"create table if not exists haproxy_check(id int);
 insert into haproxy_check values (extract(epoch from now())::int);"

echo "Если запись добавлена, значит запись в мастер передалась в реплику"
# читаем через read-порт (реплики)
PGPASSWORD='test' psql "host=127.0.0.1 port=5433 user=postgres dbname=postgres" -c \
"select count(*) as rows_on_replicas from haproxy_check;"

# (опционально) уборка
PGPASSWORD='test' psql "host=127.0.0.1 port=5432 user=postgres dbname=postgres" -c \
"drop table if exists haproxy_check;"


echo "Ловим ошибку, если прокси на реплику работает успешно"
# пишем через write-порт в реплику
PGPASSWORD='test' psql "host=127.0.0.1 port=5433 user=postgres dbname=postgres" -c \
"create table if not exists haproxy_check(id int);
 insert into haproxy_check values (extract(epoch from now())::int);"

# (опционально) уборка
PGPASSWORD='test' psql "host=127.0.0.1 port=5432 user=postgres dbname=postgres" -c \
"drop table if exists haproxy_check;"
