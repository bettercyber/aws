touch ~/wazuh-agent-install.sh

echo '!#/bin/bash
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
apt-get update
# Set Wazuh Manager IP address
WAZUH_MANAGER="10.10.10.10" apt-get install wazuh-agent
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent
exit' > ~/wazuh-agent-install.sh

chmod +x ~/wazuh-agent-install.sh

/bin/bash ~/wazuh-agent-install.sh
