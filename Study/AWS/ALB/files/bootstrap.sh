#!/bin/bash
yum update -y
yum install -y nginx
echo "<html><body><h2>EC2 Hostname: \$(hostname)</h2></body></html>" > /usr/share/nginx/html/index.html
systemctl enable --now nginx
