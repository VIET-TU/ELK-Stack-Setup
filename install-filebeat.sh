#!/bin/bash

# Cập nhật hệ thống
sudo apt update

# Cài đặt các gói cần thiết
sudo apt install -y apt-transport-https wget

# Tải xuống và cài đặt GPG key của Elastic
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# Thêm kho lưu trữ Elastic vào danh sách nguồn
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

# Cập nhật hệ thống để áp dụng thay đổi mới
sudo apt update

# Cài đặt Filebeat
sudo apt install -y filebeat

# Sao chép file cấu hình mẫu
sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bak

# Cấu hình Filebeat để gửi log đến Elasticsearch hoặc Logstash
#sudo sed -i 's/#output.elasticsearch:/output.elasticsearch:/g' /etc/filebeat/filebeat.yml
#sudo sed -i 's/hosts: \["localhost:9200"\]/hosts: \["your_elasticsearch_server:9200"\]/g' /etc/filebeat/filebeat.yml
# Nếu bạn muốn gửi log đến Logstash, hãy sử dụng các dòng sau:
sudo sed -i 's/#output.logstash:/output.logstash:/g' /etc/filebeat/filebeat.yml
sudo sed -i 's/hosts: \["localhost:5044"\]/hosts: \["192.168.72.200:5044"\]/g' /etc/filebeat/filebeat.yml

# Bật dịch vụ Filebeat
sudo systemctl enable filebeat
sudo systemctl start filebeat


filebeat.inputs:
- type: log
  paths:
    - /var/log/*.log

# ------------------------------ Logstash Output -------------------------------
output.logstash:
  hosts: ["192.168.72.200:5044"]  # Thay địa chỉ IP này bằng địa chỉ của Logstash

filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false

# Thiết lập kết nối đến Kibana
setup.kibana:
  host: "http://192.168.72.200:5601"
  username: "elastic"
  password: "SZjlwtBmWmROnE*-0NHL"

setup.dashboards.enabled: true



#Đảm bảo rằng file cấu hình module Apache của bạn đã được lưu đúng cách. Từ những gì bạn cung cấp, cấu hình có vẻ đúng. Kiểm tra lại cấu hình trong file /etc/filebeat/modules.d/apache.yml:

- module: apache
  access:
    enabled: true
    var.paths: ["/var/log/apache2/access.log"]
  error:
    enabled: true
    var.paths: ["/var/log/apache2/error.log"]