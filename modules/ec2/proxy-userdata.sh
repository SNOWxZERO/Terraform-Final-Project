#!/bin/bash
yum update -y

# Install Nginx
amazon-linux-extras install nginx1 -y

# Create Nginx configuration with placeholder for backend ALB
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

    # Upstream backend servers (will be updated by null_resource)
    upstream backend_servers {
        server BACKEND_ALB_PLACEHOLDER:80;
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

        # Check if backend is configured, if not serve static content
        location / {
            # Try to proxy to backend first
            error_page 502 503 504 = @fallback;
            proxy_pass http://backend_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_connect_timeout 1s;
            proxy_read_timeout 1s;
            
            # Add server identification
            add_header X-Proxy-Server "${server_name}" always;
        }

        # Fallback to static content if backend is not available
        location @fallback {
            try_files $uri $uri/ /index.html;
            add_header X-Proxy-Server "${server_name}" always;
            add_header X-Proxy-Mode "Fallback" always;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
}
EOF

# Create initial page that shows current proxy status
cat > /usr/share/nginx/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Proxy Server - ${server_name}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #fff3e0; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { background: #FF9800; color: white; padding: 20px; border-radius: 5px; text-align: center; }
        .info { background: #fff8e1; padding: 15px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #FF9800; }
        .highlight { background: #ffcc02; padding: 10px; border-radius: 3px; display: inline-block; margin: 5px 0; }
        .status { background: #e1f5fe; padding: 15px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #03A9F4; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Nginx Proxy Server (Initial Mode)</h1>
            <h2>Server: ${server_name}</h2>
        </div>
        
        <div class="status">
            <h3>Current Status:</h3>
            <p><strong>Proxy Mode:</strong> <span class="highlight">Initial/Fallback</span></p>
            <p><strong>Backend Target:</strong> <span class="highlight">BACKEND_ALB_PLACEHOLDER</span></p>
            <p><strong>Next Step:</strong> Backend ALB configuration pending</p>
        </div>
        
        <div class="info">
            <h3>Server Information:</h3>
            <p><strong>Server Name:</strong> <span class="highlight">${server_name}</span></p>
            <p><strong>Server Role:</strong> <span class="highlight">Reverse Proxy (Waiting for Backend)</span></p>
            <p><strong>Web Server:</strong> <span class="highlight">Nginx</span></p>
            <p><strong>Network:</strong> <span class="highlight">Public Subnet</span></p>
        </div>

        <div class="info">
            <h3>Instance Metadata:</h3>
            <p><strong>Instance ID:</strong> <span id="instance-id" class="highlight">Loading...</span></p>
            <p><strong>Private IP:</strong> <span id="private-ip" class="highlight">Loading...</span></p>
            <p><strong>Public IP:</strong> <span id="public-ip" class="highlight">Loading...</span></p>
            <p><strong>Availability Zone:</strong> <span id="az" class="highlight">Loading...</span></p>
        </div>

        <div class="info">
            <h3>Deployment Progress:</h3>
            <p>Infrastructure deployed successfully</p>
            <p>Proxy server is healthy and responding</p>
            <p>Waiting for backend ALB DNS configuration</p>
            <p><strong>Note:</strong> After backend configuration, this page will show backend content</p>
        </div>

        <div class="info">
            <h3>Request Information:</h3>
            <p><strong>Request Time:</strong> <span id="timestamp"></span></p>
            <p><strong>Served by:</strong> ${server_name} (Nginx - Fallback Mode)</p>
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
echo "$(date): Nginx proxy server ${server_name} configured with backend placeholder" >> /var/log/userdata.log