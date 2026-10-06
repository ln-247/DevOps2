#!/bin/bash
# shellcheck shell=bash
set -eu

# Скрипт подготовки окружения для ДЗ №5
# Запуск Nginx в Docker-контейнере для получения TLS-сертификата от Let's Encrypt

echo "=== Подготовка окружения для Let's Encrypt ==="

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then echo "Ошибка: Docker не установлен. Установите Docker (Задание 4) перед выполнением этого скрипта."; exit 1; fi

# Проверка, что Docker запущен
if ! docker info &> /dev/null; then
    echo "Ошибка: Docker не запущен. Запустите службу Docker."
    exit 1
fi

# Установка Certbot
echo "Установка Certbot..."
sudo apt update
sudo apt install -y certbot

# Создание тестового домена (локально)
echo "Настройка локального домена myserver.local..."
if ! grep -q "myserver.local" /etc/hosts; then
    echo "127.0.0.1 myserver.local" | sudo tee -a /etc/hosts
fi

# Создание директории для веб-контента
echo "Создание директории с веб-контентом..."
sudo mkdir -p /var/www/myserver.local
echo "<html><body><h1>It works!</h1></body></html>" | sudo tee /var/www/myserver.local/index.html

# Остановка и удаление предыдущего контейнера, если он существует
if docker ps -a --format '{{.Names}}' | grep -q "^nginx-letsencrypt$"; then
    echo "Остановка и удаление предыдущего контейнера nginx-letsencrypt..."
    docker stop nginx-letsencrypt &> /dev/null || true
    docker rm nginx-letsencrypt &> /dev/null || true
fi

# Запуск Nginx в Docker-контейнере
echo "Запуск Nginx в Docker-контейнере..."
docker run -d \
    --name nginx-letsencrypt \
    --restart unless-stopped \
    -p 80:80 \
    -v /var/www/myserver.local:/usr/share/nginx/html:ro \
    nginx:alpine

# Ожидание запуска контейнера
echo "Ожидание запуска контейнера..."
sleep 3

# Проверка статуса контейнера
echo "Проверка статуса контейнера..."
docker ps --filter "name=nginx-letsencrypt" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Проверка доступности веб-сервера
echo "Проверка доступности веб-сервера..."
if curl -s -o /dev/null -w "%{http_code}" http://myserver.local | grep -q "200"; then
    echo "Веб-сервер доступен!"
else
    echo "Предупреждение: веб-сервер не отвечает. Проверьте логи: docker logs nginx-letsencrypt"
fi

echo ""
echo "=== Подготовка завершена ==="
echo "Домен myserver.local настроен и доступен по адресу http://myserver.local"
echo "Nginx запущен в контейнере: nginx-letsencrypt"
echo ""
echo "Теперь можно приступать к выполнению задания 5."
echo "Для просмотра логов контейнера используйте: docker logs nginx-letsencrypt"
