#!/bin/bash
#Setup Odoo version 16 with Ubuntu 22.2
apt update -y
sudo adduser --system --quiet --shell=/bin/bash --home=/opt/odoo --gecos 'odoo' --group odoo
sudo mkdir /etc/odoo && mkdir /var/log/odoo/
sudo apt-get update && apt-get upgrade -y && apt-get install postgresql postgresql-server-dev-all build-essential python3-pil python3-lxml python3-dev python3-pip python3-setuptools npm nodejs git gdebi libldap2-dev libs>
python3 -m pip install wheel setuptools pip --upgrade
sudo service postgresql restart
git clone --depth=1 --branch=16.0 https://github.com/odoo/odoo.git /opt/odoo/odoo
sudo chown odoo:odoo /opt/odoo/ -R && sudo chown odoo:odoo /var/log/odoo/ -R && cd /opt/odoo/odoo && sudo pip3 install -r requirements.txt
sudo npm install -g less less-plugin-clean-css rtlcss -y
cd /tmp && wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb && sudo gdebi -n wkhtmltox_0.12.5-1.bionic_amd64.deb && rm wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin/ && sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin/
sudo su - postgres -c "createuser -s odoo"
sudo su - odoo -c "/opt/odoo/odoo/odoo-bin --addons-path=/opt/odoo/odoo/addons -s --stop-after-init"
sudo mv /opt/odoo/.odoorc /etc/odoo/odoo.conf
sudo sed -i "s,^\(logfile = \).*,\1"/var/log/odoo/odoo-server.log"," /etc/odoo/odoo.conf
sudo sed -i "s,^\(logrotate = \).*,\1"True"," /etc/odoo/odoo.conf
sudo sed -i "s,^\(proxy_mode = \).*,\1"True"," /etc/odoo/odoo.conf
sudo cp /opt/odoo/odoo/debian/init /etc/init.d/odoo && chmod +x /etc/init.d/odoo
sudo ln -s /opt/odoo/odoo/odoo-bin /usr/bin/odoo
sudo update-rc.d -f odoo start 20 2 3 4 5 .
sudo service odoo restart
ufw disable
echo "Login IP: `curl ifconfig.me`:8069"
