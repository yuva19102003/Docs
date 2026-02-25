# 🏗️ 0️⃣ Architecture Overview

![Image](https://access.redhat.com/webassets/avalon/d/OpenShift_Container_Platform-4.19-Architecture-en-US/images/7cb0013c7080c715e106f482eab98065/create-push-app.png)

![Image](https://access.redhat.com/webassets/avalon/d/OpenShift_Container_Platform-4.14-Architecture-en-US/images/81d412906026bcfe261fe3fc8c77327b/ocp_arch_lifecycle.png)

![Image](https://access.redhat.com/webassets/avalon/d/OpenShift_Container_Platform-3.11-Architecture-en-US/images/35d3e721ab382dcacbaca170c55dda05/router_model.png)

![Image](https://kodekloud.com/kk-media/image/upload/v1752882688/notes-assets/images/OpenShift-4-Services-and-Routes/service-architecture-flowchart.jpg)

Flow:

Developer → Docker Build → DockerHub → OpenShift Deployment → Service → Route → User

---

# 🧩 STEP 1 — Create Web Application

## 📄 main.go

```go
package main

import (
	"fmt"
	"net/http"
	"os"
)

func handler(w http.ResponseWriter, r *http.Request) {
	message := os.Getenv("MESSAGE")
	if message == "" {
		message = "Hello from OpenShift 🚀"
	}
	fmt.Fprintf(w, message)
}

func main() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8080", nil)
}
```

Important:

* Uses port **8080** (OpenShift safe)
* Reads env variable

---

# 🐳 STEP 2 — Create OpenShift-Compatible Dockerfile

```dockerfile
# ---------- Build Stage ----------
FROM golang:1.22-alpine AS builder

WORKDIR /opt/app

COPY main.go .

RUN go mod init demo && \
    go mod tidy && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app && \
    chmod 755 app

# ---------- Runtime Stage ----------
FROM alpine:latest

WORKDIR /opt/app
RUN mkdir -p /opt/app && chmod -R 777 /opt/app

COPY --from=builder /opt/app/app .

EXPOSE 8080

CMD ["./app"]
```

Why this works:

* No root requirement
* Arbitrary UID safe
* Proper permissions
* Uses 8080

---

# 🏗️ STEP 3 — Build Docker Image

```bash
docker build -t yuvaraiden001/web-demo:v1 .
```

---

# 📦 STEP 4 — Push to DockerHub

```bash
docker login
docker push yuvaraiden001/web-demo:v1
```

Now image is available publicly.

---

# 🔐 STEP 5 — Login to OpenShift

```powershell
oc login --token=<token> --server=<server>
oc project romanyuvan-dev
```

---

# 🚀 STEP 6 — Deploy Using YAML (Production Style)

## 📄 deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-demo
  template:
    metadata:
      labels:
        app: web-demo
    spec:
      containers:
        - name: web-demo
          image: yuvaraiden001/web-demo:v1
          ports:
            - containerPort: 8080
          env:
            - name: MESSAGE
              value: "Hello Yuva from OpenShift 🔥"
```

Apply:

```powershell
oc apply -f deployment.yaml
```

Check:

```powershell
oc get pods
```

Wait until Running.

---

# 🌐 STEP 7 — Create Service

## 📄 service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-demo-service
spec:
  selector:
    app: web-demo
  ports:
    - port: 8080
      targetPort: 8080
  type: ClusterIP
```

Apply:

```powershell
oc apply -f service.yaml
```

---

# 🌍 STEP 8 — Create Route (External Access)

## 📄 route.yaml

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: web-demo-route
spec:
  to:
    kind: Service
    name: web-demo-service
  port:
    targetPort: 8080
  tls:
    termination: edge
```

Apply:

```powershell
oc apply -f route.yaml
```

Check route:

```powershell
oc get route
```

Copy URL → open in browser 🔥

---

# 🔄 STEP 9 — Scaling

```powershell
oc scale deployment web-demo --replicas=3
```

Check:

```powershell
oc get pods
```

OpenShift service load balances automatically.

---

# 🔁 STEP 10 — Rolling Update

Change message in deployment.yaml.

Build new version:

```bash
docker build -t yuvaraiden001/web-demo:v2 .
docker push yuvaraiden001/web-demo:v2
```

Update deployment:

```powershell
oc set image deployment/web-demo web-demo=yuvaraiden001/web-demo:v2
```

Check rollout:

```powershell
oc rollout status deployment/web-demo
```

No downtime.

---

# 🔎 STEP 11 — Debugging

Logs:

```powershell
oc logs <pod-name>
```

Describe:

```powershell
oc describe pod <pod-name>
```

Shell access:

```powershell
oc rsh <pod-name>
```

---

# 🎯 What You Achieved

You now used:

* Container Runtime (CRI-O)
* Deployment
* ReplicaSet
* Service
* Route (HAProxy)
* Scaling
* Rolling updates
* Environment variables
* TLS termination

That’s full OpenShift application lifecycle.

---

# 🧠 Interview Summary Answer

“OpenShift application deployment flow consists of building a container image, pushing it to a registry, creating a Deployment for pods, exposing it via a Service for internal communication, and creating a Route for external access with TLS termination.”

---

