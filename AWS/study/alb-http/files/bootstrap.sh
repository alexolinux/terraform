#!/bin/bash
yum update -y
yum -y install nginx
echo "Host: $(hostnamectl --transient)" > /usr/share/nginx/html/index.html
systemctl enable --now nginx
