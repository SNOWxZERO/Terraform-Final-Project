#!/bin/bash
yum update -y

# Install Nginx
amazon-linux-extras install nginx1 -y

# Create Nginx reverse proxy configuration
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

    # Upstream backend servers (internal ALB)
    upstream backend_servers {
        server ${internal_alb_dns}:80;
    }

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        # Health check endpoint for ALB
        location /health {
            access_log off;
            return 200 "Healthy\n";
            add_header Content-Type text/plain;
        }

        # Proxy all other requests to backend
        location / {
            proxy_pass http://backend_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Add server identification
            add_header X-Proxy-Server "${server_name}" always;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
}
EOF

# Create a custom index page for direct proxy access (debugging)
cat > /usr/share/nginx/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Proxy Server - ${server_name}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { background: #f4f4f4; padding: 20px; border-radius: 5px; }
        .info { background: #e8f4f8; padding: 15px; margin: 20px 0; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔄 Nginx Reverse Proxy Server</h1>
            <h2>Server: ${server_name}</h2>
        </div>
        
        <div class="info">
            <h3>Server Information:</h3>
            <p><strong>Server Name:</strong> ${server_name}</p>
            <p><strong>Server Role:</strong> Reverse Proxy</p>
            <p><strong>Web Server:</strong> Nginx</p>
            <p><strong>Proxy Target:</strong> ${internal_alb_dns}</p>
        </div>

        <div class="info">
            <h3>Instance Metadata:</h3>
            <p><strong>Instance ID:</strong> <span id="instance-id">Loading...</span></p>
            <p><strong>Private IP:</strong> <span id="private-ip">Loading...</span></p>
            <p><strong>Public IP:</strong> <span id="public-ip">Loading...</span></p>
            <p><strong>Availability Zone:</strong> <span id="az">Loading...</span></p>
        </div>

        <div class="info">
            <h3>Status:</h3>
            <p>✅ This proxy server is forwarding requests to backend servers via internal load balancer</p>
            <p>🌐 Access this through the public load balancer to see backend content</p>
        </div>
    </div>

    <script>
        // Fetch instance metadata
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(r => r.text()).then(d => document.getElementById('instance-id').textContent = d)
            .catch(() => document.getElementById('instance-id').textContent = 'N/A');
        
        fetch('http://169.254.169.254/latest/meta-data/local-ipv4')
            .then(r => r.text()).then(d => document.getElementById('private-ip').textContent = d)
            .catch(() => document.getElementById('private-ip').textContent = 'N/A');
        
        fetch('http://169.254.169.254/latest/meta-data/public-ipv4')
            .then(r => r.text()).then(d => document.getElementById('public-ip').textContent = d)
            .catch(() => document.getElementById('public-ip').textContent = 'N/A');
        
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(r => r.text()).then(d => document.getElementById('az').textContent = d)
            .catch(() => document.getElementById('az').textContent = 'N/A');
    </script>
</body>
</html>
EOF

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

# Create log entry
echo "$(date): Nginx proxy server ${server_name} configured successfully" >> /var/log/userdata.log