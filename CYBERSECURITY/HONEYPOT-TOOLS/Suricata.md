### **Tutorial: Setting Up Suricata for Network Security Monitoring with Docker**

In this tutorial, we will guide you through setting up **Suricata** in a **Docker** container for network traffic analysis, intrusion detection, and prevention. Suricata is a powerful IDS/IPS/NSM engine, and using Docker for its deployment makes it easier to manage and scale.

---

### **Objective:**

1. Set up **Suricata** using Docker.
    
2. Configure Suricata to monitor network traffic.
    
3. Analyze Suricata logs to detect malicious activities and threats.
    
4. Optionally, integrate Suricata with **Elasticsearch** and **Kibana** for advanced visualization and analysis.
    

---

### **Step 1: Install Docker**

If you don’t have Docker installed, follow these instructions to install it on your system:

1. **Update your system**:
    
    ```bash
    sudo apt-get update && sudo apt-get upgrade -y
    ```
    
2. **Install Docker**:
    
    ```bash
    sudo apt-get install docker.io -y
    ```
    
3. **Verify the installation**:
    
    ```bash
    docker --version
    ```
    
4. **Start and Enable Docker** to run on boot:
    
    ```bash
    sudo systemctl start docker
    sudo systemctl enable docker
    ```
    

---

### **Step 2: Pull Suricata Docker Image**

To get started with Suricata in Docker, we’ll pull the official Suricata image from Docker Hub.

1. **Pull the Suricata Docker image**:
    
    ```bash
    docker pull jasonish/suricata
    ```
    
2. **Verify the image**:
    
    To verify the image has been pulled correctly:
    
    ```bash
    docker images
    ```
    
    You should see the `jasonish/suricata` image listed.
    

---

### **Step 3: Run Suricata in Docker**

1. **Run Suricata in a Docker container**:
    
    We will use Docker's `--net=host` option to allow Suricata to monitor the network interface of the host system.
    
    ```bash
    sudo docker run --name suricata --net=host --rm jasonish/suricata
    ```
    
    - `--name suricata`: This names the container `suricata`.
        
    - `--net=host`: This gives the container access to the host's network interfaces (needed for Suricata to monitor traffic).
        
    - `--rm`: This removes the container once it stops.
        
2. **Check if Suricata is running**:
    
    To see if Suricata is up and running inside the container:
    
    ```bash
    sudo docker ps
    ```
    
    This will show you the running Docker containers. You should see `suricata` listed.
    

---

### **Step 4: Configure Suricata in Docker**

The default Suricata configuration file is typically located at `/etc/suricata/suricata.yaml`. To modify the configuration in Docker, you need to mount a volume from the host machine into the container.

1. **Create a custom configuration directory** on your host:
    
    ```bash
    mkdir ~/suricata-config
    ```
    
2. **Copy the default Suricata configuration to your host**:
    
    First, you need to copy the default Suricata configuration from the Docker container to your host machine:
    
    ```bash
    sudo docker cp $(docker ps -q --filter "name=suricata"):/etc/suricata ~/suricata-config
    ```
    
3. **Edit the Suricata configuration**:
    
    Modify the `suricata.yaml` file located in `~/suricata-config/suricata.yaml` to suit your needs (e.g., specify the network interface, enable logging, etc.).
    

---

### **Step 5: Run Suricata with Custom Configuration**

1. **Run Suricata with the custom configuration**:
    
    Once you've configured Suricata, you can start the container again with your custom configuration:
    
    ```bash
    sudo docker run --name suricata --net=host -v ~/suricata-config:/etc/suricata --rm jasonish/suricata
    ```
    
    - `-v ~/suricata-config:/etc/suricata`: Mounts the `suricata-config` directory from your host to the container, enabling Suricata to use your custom configuration file.
        

---

### **Step 6: Analyze Suricata Logs**

Suricata generates logs that contain detailed information about network traffic, including potential threats and alerts.

1. **Configure Suricata to output logs to a shared volume**:
    
    If you want to access Suricata logs on your host machine, you can modify the `suricata.yaml` file to write logs to a mounted directory.
    
    Example:
    
    ```yaml
    outputs:
      - eve-log:
          enabled: yes
          filetype: json
          filename: /suricata/logs/eve.json
    ```
    
2. **Run Suricata with mounted log directory**:
    
    Now, when running Suricata, mount a directory on your host to store the logs:
    
    ```bash
    sudo docker run --name suricata --net=host -v ~/suricata-config:/etc/suricata -v ~/suricata-logs:/suricata/logs --rm jasonish/suricata
    ```
    
    This will store logs in the `~/suricata-logs` directory on your host machine.
    
3. **View Suricata Logs**:
    
    To view the real-time logs from Suricata:
    
    ```bash
    tail -f ~/suricata-logs/eve.json
    ```
    

---

### **Step 7: Integrating with Elasticsearch and Kibana (Optional)**

For more advanced analysis and visualization, you can send Suricata's EVE JSON output to **Elasticsearch** and use **Kibana** to visualize the data.

#### **7.1 Install Elasticsearch and Kibana**

You can run **Elasticsearch** and **Kibana** in Docker as well. Here’s a simple setup for running both services:

1. **Run Elasticsearch**:
    
    ```bash
    docker run --name elasticsearch -d -p 9200:9200 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:8.0.0
    ```
    
2. **Run Kibana**:
    
    ```bash
    docker run --name kibana -d -p 5601:5601 docker.elastic.co/kibana/kibana:8.0.0
    ```
    

#### **7.2 Configure Suricata to Send Logs to Elasticsearch**

1. Open the `suricata.yaml` file and find the output section.
    
2. Uncomment and configure the **Elasticsearch output** to point to your Elasticsearch container:
    
    ```yaml
    outputs:
      - elasticsearch:
          enabled: yes
          host: "http://elasticsearch:9200"
          index: "suricata-alerts-%Y.%m.%d"
    ```
    
3. **Restart Suricata** with this configuration:
    
    ```bash
    sudo docker run --name suricata --net=host -v ~/suricata-config:/etc/suricata -v ~/suricata-logs:/suricata/logs --rm jasonish/suricata
    ```
    
4. **Access Kibana**:
    
    Go to `http://localhost:5601` in your browser to access the Kibana dashboard. You can create an index pattern to view Suricata logs.
    

---

### **Step 8: Additional Configuration and Fine-Tuning**

1. **Suricata Rules**: Suricata uses rules to detect network traffic anomalies and threats. You can download additional rules from sources like **Emerging Threats** or **Snort** and configure them in Suricata’s rule directory.
    
2. **Updating Rules**: To automatically download and update rules, use the `suricata-update` command:
    
    ```bash
    sudo suricata-update
    ```
    

---

### **Summary**

- **Suricata** is a high-performance IDS/IPS engine used for network security monitoring and traffic analysis.
    
- We set up Suricata in a **Docker container** for ease of management and scalability.
    
- Suricata logs can be accessed in real-time and optionally forwarded to **Elasticsearch** and **Kibana** for advanced analysis and visualization.
    
- Suricata's **rule sets** can be updated and fine-tuned for better detection of threats.
    

