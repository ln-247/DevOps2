# Роль postgres

Роль устанавливает PostgreSQL, создаёт и настраивает кластер в отдельном
каталоге, управляет базами данных и пользователями, устанавливает
PostgreSQL Exporter.

Роль проверена на Ubuntu с PostgreSQL 18.

## Зависимости

Для управления базами данных и пользователями нужна коллекция:

```bash
ansible-galaxy collection install community.postgresql
```

Пакеты PostgreSQL, python3-psycopg2 и acl устанавливаются самой ролью.

## Переменные роли

Настройки находятся в defaults/main.yml.

| Переменная | Назначение | Значение по умолчанию |
| --- | --- | --- |
| postgres__packages | Устанавливаемые пакеты | postgresql, python3-psycopg2, acl |
| postgres__data_dir | Каталог данных кластера | /data/postgres/data |
| postgres__opts | Параметры postgresql.conf | port: 5432, max_connections: 100 |
| postgres__hba_rules | Список правил pg_hba.conf | Локальный вход postgres через peer и вход экспортера с 127.0.0.1 по паролю |
| postgres__databases | Список баз данных | База homework |
| postgres__users | Список пользователей PostgreSQL | Пустой список |
| postgres__exporter_version | Версия экспортера | 0.20.1 |
| postgres__exporter_arch | Архитектура экспортера | amd64 |
| postgres__exporter_port | Порт HTTP-интерфейса метрик | 9187 |
| postgres__exporter_db_user | Пользователь БД для экспортера | postgres_exporter |
| postgres__exporter_db_password | Пароль пользователя экспортера | Пустая строка; задаётся через Vault |


Внутренние переменные находятся в vars/main.yml:
- __pg_version — версия PostgreSQL для путей к программам и пакетной службе;
- __postgres_exporter_archive — имя архива экспортера без расширения.

## Пользователи и секреты

Пароли хранятся в зашифрованном файле
inventories/main/group_vars/all/encrypted.yml:

- vault_petrusha_password;
- vault_postgres_exporter_password.


## Пример плейбука

```yaml
---
- name: Configure PostgreSQL on vm1
  hosts: vm1
  become: true
  roles:
    - postgres
```

Запуск из каталога Homework2:

```bash
ansible-playbook postgres.play.yml -K
```
