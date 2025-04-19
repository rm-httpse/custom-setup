#!/bin/bash

echo "[+] Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

echo "[+] Instalando herramientas básicas..."
sudo apt install -y curl wget git unzip net-tools screen tmux openssh-server

echo "[+] Creando estructura de carpetas..."
mkdir -p ~/server/logs
mkdir -p ~/server/scripts

sudo systemctl enable ssh
sudo systemctl start ssh
echo "[+] SSH Habilitado!"

sudo ufw allow OpenSSH
sudo ufw enable
echo "[+] Firewall Habilitado!"


# Crear watchdog
cat << 'EOF' > /opt/server/scripts/watchdog.sh
HOST="8.8.8.8"
INTERVAL=1000

check_connection() {
    ping -c 1 \$HOST > /dev/null 2>&1
    return \$?
}

while true; do
    check_connection
    if [ \$? -eq 0 ]; then
        echo "[watchdog] Conexión activa."
    else
        echo "[watchdog] Sin conexión, reiniciando red..."
        sudo systemctl restart networking
    fi
    sleep \$INTERVAL
done
EOF

# Asignar permisos
chmod +x ~/server/scripts/watchdog.sh
echo "[+] Permisos asignados."


echo "[+] Setup completado!"
