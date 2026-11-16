#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
cat > /tmp/wifi-kick.sh <<'EOF'
#!/bin/sh
# 轮询 QRTR 里 WLFW 服务，出现后立刻 rebind ath10k
for i in $(seq 1 120); do
    if qrtr-lookup 2>/dev/null | grep -qiE 'ath|wlan'; then
        echo "WLFW seen at attempt $i" > /dev/kmsg
        D=/sys/bus/platform/drivers/ath10k_snoc
        echo 18800000.wifi > $D/unbind 2>/dev/null
        sleep 0.2
        echo 18800000.wifi > $D/bind 2>/dev/null
        exit 0
    fi
    sleep 0.5
done
echo "WLFW never seen" > /dev/kmsg
EOF
sshpass -p 1234 scp $OPTS /tmp/wifi-kick.sh root@172.16.42.1:/usr/local/sbin/wifi-kick.sh 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
chmod +x /usr/local/sbin/wifi-kick.sh
cat > /etc/systemd/system/wifi-kick.service <<EOF
[Unit]
Description=Kick ath10k when WLFW appears
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/wifi-kick.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable wifi-kick.service
echo enabled
sync; reboot
' 2>&1 | grep -v Warning
echo "rebooting with wifi-kick"
