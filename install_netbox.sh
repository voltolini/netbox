#!/bin/bash

set -e

echo "=============================="
echo " NetBox Automated Installer"
echo " Ubuntu 24.04 LTS | NetBox v4.x"
echo "=============================="

# Variáveis de configuração
NETBOX_VERSION="v4.0.0"  # Altere se quiser outra versão
NETBOX_DIR="/opt/netbox"
POSTGRES_USER="netbox"
POSTGRES_PASSWORD="StrongP@ssw0rd"
POSTGRES_DB="netbox"
REDIS_HOST="localhost"

# Superuser NetBox
SUPERUSER_NAME="admin"
SUPERUSER_EMAIL="admin@example.com"
SUPERUSER_PASSWORD="Admin123!"

# Função para instalar pacotes do sistema
install_packages() {
    echo "[1/7] Instalando dependências do sistema..."
    apt update
    apt install -y python3 python3-pip python3-venv build-essential libxml2-dev libxslt1-dev libpq-dev libffi-dev libssl-dev \
        postgresql redis nginx git
}

# Função para configurar o PostgreSQL
setup_postgres() {
    echo "[2/7] Configurando PostgreSQL..."
    sudo -u postgres psql <<EOF
CREATE DATABASE $POSTGRES_DB;
CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
EOF
}

# Função para configurar o Redis
setup_redis() {
    echo "[3/7] Garantindo que o Redis esteja rodando..."
    systemctl enable redis-server
    systemctl start redis-server
}

# Função para instalar o NetBox
install_netbox() {
    echo "[4/7] Instalando o NetBox..."

    rm -rf $NETBOX_DIR

    cd /opt
    git clone -b $NETBOX_VERSION https://github.com/netbox-community/netbox.git
    cd $NETBOX_DIR

    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt

    # Copiar arquivo de configuração padrão
    cp netbox/netbox/configuration_example.py netbox/netbox/configuration.py

    # Ajustar SECRET_KEY e ALLOWED_HOSTS
    SECRET_KEY=$(python3 netbox/generate_secret_key.py)
    sed -i "s/^SECRET_KEY = .*/SECRET_KEY = '$SECRET_KEY'/" netbox/netbox/configuration.py
    sed -i "s/^ALLOWED_HOSTS = .*/ALLOWED_HOSTS = ['*']/" netbox/netbox/configuration.py

    # Ajustar bloco DATABASE linha a linha, incluindo CONN_MAX_AGE
    sed -i "s/^DATABASE = .*/DATABASE = {/" netbox/netbox/configuration.py
    sed -i "/^DATABASE = {/!b;n;c\    'NAME': '$POSTGRES_DB'," netbox/netbox/configuration.py
    sed -i "/^    'NAME':/!b;n;c\    'USER': '$POSTGRES_USER'," netbox/netbox/configuration.py
    sed -i "/^    'USER':/!b;n;c\    'PASSWORD': '$POSTGRES_PASSWORD'," netbox/netbox/configuration.py
    sed -i "/^    'PASSWORD':/!b;n;c\    'HOST': 'localhost'," netbox/netbox/configuration.py
    sed -i "/^    'HOST':/!b;n;c\    'PORT': ''," netbox/netbox/configuration.py
    sed -i "/^    'PORT':/!b;n;c\    'CONN_MAX_AGE': 300," netbox/netbox/configuration.py
    sed -i "/^    'CONN_MAX_AGE':/!b;n;c\}" netbox/netbox/configuration.py

    # Executar migrações e coletar arquivos estáticos
    python3 netbox/manage.py migrate
    python3 netbox/manage.py collectstatic --no-input
}

# Função para criar superusuário automaticamente
create_superuser() {
    echo "[5/7] Criando superusuário NetBox..."

    source $NETBOX_DIR/venv/bin/activate

    cat <<EOF | python3 netbox/manage.py shell
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='$SUPERUSER_NAME').exists():
    User.objects.create_superuser('$SUPERUSER_NAME', '$SUPERUSER_EMAIL', '$SUPERUSER_PASSWORD')
    print("Superuser criado com sucesso!")
else:
    print("Superuser '$SUPERUSER_NAME' já existe. Pulando criação.")
EOF
}

# Função para configurar Gunicorn e Supervisor
setup_gunicorn_supervisor() {
    echo "[6/7] Configurando Gunicorn e Supervisor..."

    cp -v contrib/gunicorn.py /opt/netbox/gunicorn.py
    cp -v contrib/netbox.service /etc/systemd/system/netbox.service
    cp -v contrib/netbox-rq.service /etc/systemd/system/netbox-rq.service

    systemctl daemon-reload
    systemctl enable netbox netbox-rq
    systemctl start netbox netbox-rq
}

# Função para configurar Nginx
setup_nginx() {
    echo "[7/7] Configurando Nginx..."

    cp -v contrib/nginx.conf /etc/nginx/sites-available/netbox
    ln -sf /etc/nginx/sites-available/netbox /etc/nginx/sites-enabled/netbox
    rm -f /etc/nginx/sites-enabled/default

    nginx -t
    systemctl restart nginx
}

# Execução do script
install_packages
setup_postgres
setup_redis
install_netbox
create_superuser
setup_gunicorn_supervisor
setup_nginx

echo "=============================="
echo " NetBox instalado com sucesso!"
echo " Superuser: $SUPERUSER_NAME / $SUPERUSER_PASSWORD"
echo " Acesse via: http://<IP-DO-SERVIDOR>/"
echo "=============================="
