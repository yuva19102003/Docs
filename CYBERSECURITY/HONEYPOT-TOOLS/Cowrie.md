### **Tutorial: Setting Up Cowrie Honeypot with Docker and Securing Real SSH Server**

In this tutorial, we will set up **Cowrie**, a honeypot to capture SSH brute-force attacks, using **Docker**. Additionally, we will secure your **real SSH server** by changing its port and restricting access to only your specific IP.

#### **Objective:**

1. **Expose Cowrie's SSH service** on port 22 to the internet to capture SSH brute-force attempts.
    
2. **Secure your real SSH service** by moving it to a custom port (e.g., 6456) and allowing access only from a specific IP address.
    

---

### **Step 1: Set Up Cowrie Honeypot Using Docker**

1. **Pull the Cowrie Docker image**:
    
    ```bash
    docker pull cowrie/cowrie
    ```
    
2. **Run Cowrie container on your server**:
    
    Map port **22** (default SSH port) from your host machine to **port 22** inside the Cowrie container. Additionally, map the Telnet port **23** to **2233** for Telnet access.
    
    ```bash
    docker run -d --name=cowrie -p 22:22 -p 2233:23 cowrie/cowrie
    ```
    
    **Explanation:**
    
    - `-p 22:22`: Exposes **Cowrie’s port 22** (SSH) to your host machine’s **port 22**.
        
    - `-p 2233:23`: Exposes **Cowrie’s Telnet port 23** to your host machine’s **port 2233**.
        
3. **Cowrie will now be exposed to the internet** on **port 22** (the default SSH port) and will log any SSH brute-force attempts made by attackers.
    

---

### **Step 2: Configure Your Real SSH Server (on Host)**

#### **Change Your Real SSH Port to 6456**

1. **Edit the SSH configuration file** on your server:
    
    Open the SSH configuration file (`/etc/ssh/sshd_config`) using a text editor:
    
    ```bash
    sudo nano /etc/ssh/sshd_config
    ```
    
2. **Change the SSH port to 6456**:
    
    Find the line specifying `Port 22`, uncomment it, and change it to:
    
    ```bash
    Port 6456
    ```
    
3. **Restrict SSH access to your IP only**:
    
    Add this line to the `sshd_config` to allow SSH access only from your specific IP address:
    
    ```bash
    AllowUsers youruser@YOUR_IP
    ```
    
    Replace `youruser` with your SSH username and `YOUR_IP` with your actual IP address.
    
4. **Restart SSH service**:
    
    Restart the SSH service to apply the changes:
    
    ```bash
    sudo systemctl restart sshd
    ```
    

#### **Update Your Firewall**

1. **Allow access to port 6456** (real SSH):
    
    If you're using `ufw`, run the following to allow access from your IP only:
    
    ```bash
    sudo ufw allow from YOUR_IP to any port 6456
    ```
    
2. **Allow access to Cowrie's port 22**:
    
    Since Cowrie is running on port 22, you'll need to allow traffic to this port:
    
    ```bash
    sudo ufw allow 22
    ```
    
3. **Optional: Block all other SSH access on port 22** (if your real SSH is no longer on port 22):
    
    ```bash
    sudo ufw deny 22
    ```
    

---

### **Step 3: Verify the Setup**

1. **Test your real SSH server** (on port 6456):
    
    Try to SSH into your server using your custom SSH port (6456):
    
    ```bash
    ssh youruser@<your_ip> -p 6456
    ```
    
    This should work only if you are connecting from your allowed IP address.
    
2. **Test Cowrie SSH Honeypot** (on port 22):
    
    From any other machine (except your allowed IP), try to SSH into your server on port 22:
    
    ```bash
    ssh root@<your_ip> -p 22
    ```
    
    This will interact with **Cowrie**, and you should see the attacker’s attempt being logged in the **Cowrie container**.
    

---

### **Step 4: How It Works**

- **Attacker tries to SSH into port 22**: When the attacker attempts to SSH into your server (`ssh root@<your_ip> -p 22`), they are actually connecting to **Cowrie** due to the Docker port mapping (`-p 22:22`).
    
- **Cowrie container logs the attacker's actions**: The attacker will interact with **Cowrie's fake environment** (e.g., brute-forcing passwords or executing commands), but they will never reach your real server.
    
- **Your real SSH service** is safely running on **port 6456**, which is not exposed to the internet. Only your **allowed IP** can connect to it.
    

---

### **Summary of Ports and Access**

- **Real SSH server**:
    
    - Port: **6456**
        
    - **Only accessible** from your **specified IP address** (configured in `sshd_config`).
        
- **Cowrie SSH honeypot**:
    
    - Port: **22**
        
    - Exposed to the **entire internet** to capture SSH brute-force and malicious attempts.
        

---

This setup ensures that any SSH attack targeting port **22** will be captured by **Cowrie**, while your real SSH service is secured on a custom port and only accessible from your trusted IP address.

Let me know if you need any further assistance!