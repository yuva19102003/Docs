
# 🚀 **API KEY AUTHENTICATION IN NGINX REVERSE PROXY (END-TO-END)**

API keys are commonly used for:

- Protecting internal APIs
    
- Allowing only specific clients to access an API
    
- Blocking unauthorized calls
    
- Securing microservices
    

NGINX can check API keys **before** forwarding the request to your backend.

---

# 🔥 **1. How API Key Authentication Works**

```
Client → NGINX Reverse Proxy → Backend Server

NGINX checks:
    - Header:   X-API-KEY
    - or Query: ?api_key=
```

If key is valid → request is forwarded.  
If key is invalid → 401 Unauthorized.

---

# 🧱 **2. Create a Secret API Key**

Example:

```
API_KEY="my-super-secret-key-123"
```

You will verify this in NGINX.

---

# ⚙️ **3. Reverse Proxy with API Key Authentication**

Create or edit your config:

```bash
sudo nano /etc/nginx/sites-available/myapp
```

Paste this:

```
server {
    listen 80;
    server_name example.com;

    # Expected API key
    set $api_key "my-super-secret-key-123";

    location / {
        # Extract API key from header
        set $client_key $http_x_api_key;

        # If header is empty, check query ?api_key=
        if ($client_key = "") {
            set $client_key $arg_api_key;
        }

        # Validate
        if ($client_key != $api_key) {
            return 401;
        }

        # Forward request to backend
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

# 🧪 **4. Test the API Key**

### ❌ Without API Key:

```
curl http://example.com
```

Response:

```
401 Unauthorized
```

### ✅ With API Key (Header):

```
curl -H "X-API-KEY: my-super-secret-key-123" http://example.com
```

### ✅ With API Key (Query):

```
curl "http://example.com?api_key=my-super-secret-key-123"
```

---

# 🔐 **5. Hide API Key in Separate File (More Secure)**

Store the key in its own file:

```bash
sudo nano /etc/nginx/keys/api_key.conf
```

Add:

```
set $api_key "my-super-secret-key-123";
```

Protect the file:

```bash
sudo chmod 600 /etc/nginx/keys/api_key.conf
```

Then include it:

```
include /etc/nginx/keys/api_key.conf;

location / {
    …
}
```

---

# 🛡 **6. Allow Only Specific Endpoints to Require API Key**

Example: Protect `/admin` but not `/public`.

```
location /admin/ {
    if ($http_x_api_key != "my-super-secret-key-123") {
        return 401;
    }
    proxy_pass http://127.0.0.1:3000;
}

location /public/ {
    proxy_pass http://127.0.0.1:3000;
}
```

---

# 📌 **7. Return JSON Instead of Plain 401**

```
if ($client_key != $api_key) {
    return 401 '{"error":"invalid api key"}';
}
```

Add proper headers:

```
add_header Content-Type application/json;
```

---

# ⚡ **8. Reject Requests Missing API Key (No Proxy)**

This saves backend resources.

```
if ($client_key = "") {
    return 400 '{"error":"missing api key"}';
}
```

---

# 🧰 **9. Advanced Method — Using Map (Cleaner, No “if” inside location)**

```
map $http_x_api_key $key_ok {
    default 0;
    "my-super-secret-key-123" 1;
}

server {
    listen 80;

    location / {
        if ($key_ok = 0) { return 401; }
        proxy_pass http://127.0.0.1:3000;
    }
}
```

---

# 💡 **10. API Key Rotation (Multiple Keys Support)**

```
map $http_x_api_key $key_ok {
    default 0;
    "keyA-123" 1;
    "keyB-456" 1;
    "keyC-789" 1;
}
```

Supports multiple clients.

---

# 🚀 **DONE! API Key Authentication Added to Reverse Proxy**

You now have:

✔ API Key verification  
✔ Header + query param support  
✔ Secure key storage  
✔ JSON error response  
✔ Multiple keys  
✔ Key rotation  
✔ Endpoint-based protection

---
