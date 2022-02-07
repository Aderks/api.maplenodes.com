# api.maplenodes.com
Maple Nodes API

```cd $HOME && git clone https://github.com/Aderks/api.maplenodes.com.git```

**Create Service:**

```
sudo tee <<EOF >/dev/null /etc/systemd/system/api.service
[Unit]
Description=API Stack
Requires=docker.service network-online.target
After=docker.service network-online.target

[Service]
WorkingDirectory=/home/aderks/api.maplenodes.com
Type=oneshot
RemainAfterExit=yes

# Pre-start command
ExecStartPre=/usr/bin/docker-compose -f "/home/aderks/api.maplenodes.com/docker-compose.yml" down

# Compose up
ExecStart=/usr/bin/docker-compose -f "/home/aderks/api.maplenodes.com/docker-compose.yml" up -d

# Compose down
ExecStop=/usr/bin/docker-compose -f "/home/aderks/api.maplenodes.com/docker-compose.yml" down

[Install]
WantedBy=multi-user.target
EOF
```

```
sudo systemctl daemon-reload && \
sudo systemctl enable api

sudo systemctl start api && journalctl -f -o cat -u api
sudo systemctl stop api && journalctl -f -o cat -u api
sudo systemctl restart graph && journalctl -f -o cat -u api
```
