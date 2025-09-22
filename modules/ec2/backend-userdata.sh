#!/bin/bash
yum update -y

# Install Nginx
amazon-linux-extras install nginx1 -y

# Create custom Nginx configuration for backend
cat > /etc/nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        location / {
            try_files $uri $uri/ =404;
            add_header X-Backend-Server "${server_name}" always;
        }

        # API endpoint for testing
        location /api/status {
            access_log off;
            return 200 '{"status": "healthy", "server": "${server_name}", "timestamp": "$time_iso8601"}';
            add_header Content-Type application/json;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
}
EOF

# Create custom backend web page
cat > /usr/share/nginx/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Backend Server - ${server_name}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f9f9f9; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { background: #4CAF50; color: white; padding: 20px; border-radius: 5px; text-align: center; }
        .info { background: #e8f5e8; padding: 15px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #4CAF50; }
        .status { background: #fff3cd; padding: 15px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #ffc107; }
        .highlight { background: #d4edda; padding: 10px; border-radius: 3px; display: inline-block; margin: 5px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Backend Web Server</h1>
            <h2>Server: ${server_name}</h2>
        </div>
        
        <div class="info">
            <h3>Server Information:</h3>
            <p><strong>Server Name:</strong> <span class="highlight">${server_name}</span></p>
            <p><strong>Server Role:</strong> <span class="highlight">Backend Web Server</span></p>
            <p><strong>Web Server:</strong> <span class="highlight">Nginx</span></p>
            <p><strong>Network:</strong> <span class="highlight">Private Subnet</span></p>
        </div>

        <div class="info">
            <h3>Instance Metadata:</h3>
            <p><strong>Instance ID:</strong> <span id="instance-id" class="highlight">Loading...</span></p>
            <p><strong>Private IP:</strong> <span id="private-ip" class="highlight">Loading...</span></p>
            <p><strong>Availability Zone:</strong> <span id="az" class="highlight">Loading...</span></p>
        </div>

        <div class="status">
            <h3>Lab 3 Success!</h3>
            <p>You are seeing content from a <strong>private subnet</strong> backend server</p>
            <p>Traffic flow: <strong>Internet → Public ALB → Proxy Server → Internal ALB → Backend Server (This page!)</strong></p>
            <p>This proves the complete multi-tier architecture is working correctly</p>
        </div>

        <div class="info">
            <h3>Request Information:</h3>
            <p><strong>Request Time:</strong> <span id="timestamp"></span></p>
            <p><strong>Served by:</strong> ${server_name} (Nginx)</p>
        </div>

        <div style="margin-top: 30px; text-align: center; color: #666;">
            <p><em>This content is served from a private subnet and accessed through load balancers</em></p>
        </div>
    </div>

    <script>
        // Set timestamp
        document.getElementById('timestamp').textContent = new Date().toLocaleString();

        // Fetch instance metadata
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(r => r.text()).then(d => document.getElementById('instance-id').textContent = d)
            .catch(() => document.getElementById('instance-id').textContent = 'N/A');
        
        fetch('http://169.254.169.254/latest/meta-data/local-ipv4')
            .then(r => r.text()).then(d => document.getElementById('private-ip').textContent = d)
            .catch(() => document.getElementById('private-ip').textContent = 'N/A');
        
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(r => r.text()).then(d => document.getElementById('az').textContent = d)
            .catch(() => document.getElementById('az').textContent = 'N/A');
    </script>
</body>
</html>
EOF

# Create additional test pages
mkdir -p /usr/share/nginx/html/api

cat > /usr/share/nginx/html/api/test.html << EOF
<!DOCTYPE html>
<html>
<head><title>API Test - ${server_name}</title></head>
<body>
    <h2>API Test Endpoint</h2>
    <p>Backend server responding: <strong>${server_name}</strong></p>
    <p>Timestamp: <strong>$(date)</strong></p>
    <p>This endpoint can be used for testing load balancer distribution</p>
</body>
</html>
EOF

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

# Create log entry
echo "$(date): Nginx backend server ${server_name} configured successfully" >> /var/log/userdata.log