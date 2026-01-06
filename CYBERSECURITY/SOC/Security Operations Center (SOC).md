### **Security Operations Center (SOC) Definition**

A **Security Operations Center (SOC)** is a centralized team or facility that monitors, detects, investigates, and responds to cybersecurity threats in real-time. It acts as the **nerve center** for an organization's security posture.

### **Key Functions of a SOC (or) why Do organization need SOC  :**

1. **Continuous Monitoring** – 24/7 surveillance of networks, systems, and endpoints.
2. **Threat Detection & Analysis** – Identifying and analyzing cyber threats using SIEM (Security Information and Event Management) tools.
3. **Incident Response** – Investigating and mitigating security incidents.
4. **Threat Intelligence** – Collecting and analyzing global threat data to improve defenses.
5. **Compliance & Reporting** – Ensuring regulatory compliance (e.g., GDPR, HIPAA, ISO 27001).


### **SOC Team Structure**

A **Security Operations Center (SOC)** consists of multiple roles responsible for monitoring, detecting, and responding to cyber threats.

#### **SOC Levels & Roles:**

- **🔹 Level 1 (L1) – SOC Analyst (Triage & Monitoring)**
    
    - Monitors security alerts using SIEM tools.
    - Performs initial investigation and escalation.
- **🔹 Level 2 (L2) – Incident Responder**
    
    - Analyzes escalated incidents from L1.
    - Conducts deeper threat analysis and containment.
- **🔹 Level 3 (L3) – Threat Hunter / Forensic Analyst**
    
    - Actively searches for undetected threats.
    - Performs malware analysis & reverse engineering.
- **🔹 SOC Manager**
    
    - Oversees SOC operations and ensures security compliance.
    - Coordinates between security teams and management.
- **🔹 Threat Intelligence Analyst**
    
    - Tracks cyber threats and analyzes attack patterns.
    - Provides insights to improve defense strategies.


### **SOC Workflow**

A **Security Operations Center (SOC)** follows a structured process to detect, analyze, and respond to cyber threats.

#### **1. Threat Monitoring & Detection**

- SOC analysts continuously monitor security logs and alerts using SIEM tools.
- Sources: Firewalls, IDS/IPS, endpoint security, cloud logs.

#### **2. Triage & Alert Analysis**

- **L1 SOC Analyst:** Reviews alerts and classifies them based on severity.
- Filters false positives and escalates real threats.

#### **3. Incident Investigation & Response**

- **L2 Incident Responder:** Investigates escalated alerts.
- Identifies attack patterns and potential impact.
- Containment actions: Blocking malicious IPs, isolating infected systems.

#### **4. Threat Hunting & Forensics**

- **L3 Threat Hunter/Forensic Analyst:** Proactively searches for hidden threats.
- Analyzes malware and reverse-engineers attack methods.

#### **5. Remediation & Recovery**

- Removes threats, patches vulnerabilities, and restores affected systems.
- Ensures business continuity and minimizes downtime.

#### **6. Post-Incident Reporting & Improvement**

- Documents the incident, root cause, and response actions.
- Updates security policies and strengthens defenses.
- Shares threat intelligence to prevent future attacks.

### **Daily Routine of an SOC Analyst (L1)**

A Level 1 (L1) SOC Analyst is responsible for monitoring, detecting, and escalating potential security incidents. Their daily routine typically includes:

#### **1️⃣ Start of Shift – Log Review & Handover**

- Check updates from the previous shift.
- Review ongoing incidents and pending escalations.
- Verify the health of SIEM, IDS/IPS, and other security tools.

#### **2️⃣ Monitoring & Alert Analysis**

- Continuously monitor SIEM dashboards for new alerts.
- Analyze logs from firewalls, endpoints, and network traffic.
- Identify false positives and escalate real threats to L2 analysts.

#### **3️⃣ Incident Triage & Response**

- Classify alerts based on severity (low, medium, high, critical).
- Perform initial investigation (IP reputation checks, malware scans).
- Document findings and escalate complex cases to senior analysts.

#### **4️⃣ Threat Intelligence & Reporting**

- Check threat intelligence feeds for new vulnerabilities and attacks.
- Correlate alerts with recent threat intelligence updates.
- Maintain daily reports on security incidents and trends.

#### **5️⃣ End of Shift – Handover & Documentation**

- Update the ticketing system with findings and incident status.
- Communicate ongoing threats or critical issues to the next shift.
- Ensure proper documentation of actions taken for future reference.

---
### **Daily Routine of an SOC Analyst (L2)**

A Level 2 (L2) SOC Analyst handles deeper investigations, incident response, and threat analysis. They validate escalations from L1 analysts and take appropriate actions to mitigate threats.

---

#### **1️⃣ Start of Shift – Review & Handover**

- Go through the previous shift's reports and unresolved incidents.
- Check escalated alerts from L1 analysts.
- Verify SIEM, EDR, and threat intelligence platform health.

#### **2️⃣ Incident Investigation & Response**

- Analyze logs, network traffic, and endpoint behavior for deeper investigation.
- Perform forensic analysis on affected systems.
- Identify Indicators of Compromise (IoCs) and correlate them with threat intelligence.
- Contain and mitigate active threats (blocking malicious IPs, isolating infected hosts).

#### **3️⃣ Threat Hunting & Intelligence Analysis**

- Proactively search for undetected threats in the environment.
- Use threat intelligence feeds to update detection rules.
- Investigate patterns of attack (MITRE ATT&CK framework, TTPs).

#### **4️⃣ Security Policy & Rule Tuning**

- Fine-tune SIEM rules to reduce false positives.
- Optimize IDS/IPS, firewall, and endpoint protection configurations.
- Assist in creating playbooks for incident response.

#### **5️⃣ End of Shift – Handover & Reporting**

- Document detailed incident reports and analysis.
- Provide updates on threat trends and remediation actions.
- Ensure smooth handover to the next shift with ongoing cases.

---

#### **Key Tools Used by L2 Analysts:**

✅ **SIEM** (Splunk, QRadar, ArcSight)  
✅ **EDR** (CrowdStrike, SentinelOne, Microsoft Defender)  
✅ **Threat Intelligence** (VirusTotal, AlienVault, MISP)  
✅ **Forensic Tools** (Volatility, Autopsy, Wireshark)

### **Daily Routine of an SOC Analyst (L3)**

A Level 3 (L3) SOC Analyst, also known as a Senior SOC Analyst or Incident Responder, is responsible for advanced threat analysis, incident containment, and security improvements. They handle complex escalations from L2 analysts and contribute to threat mitigation strategies.

---

#### **1️⃣ Start of Shift – Review & Handover**

- Review escalations from L2 analysts.
- Check ongoing critical incidents and remediation status.
- Assess threat intelligence updates and advanced persistent threats (APTs).

#### **2️⃣ Advanced Incident Investigation & Response**

- Conduct deep forensic analysis on compromised systems.
- Investigate Zero-Day exploits and advanced threats.
- Develop Indicators of Compromise (IoCs) and Indicators of Attack (IoAs).
- Contain and remediate complex security incidents (e.g., ransomware, APTs).

#### **3️⃣ Threat Hunting & Malware Analysis**

- Perform proactive threat hunting across networks and endpoints.
- Reverse-engineer malware to understand its behavior and impact.
- Analyze attack techniques using frameworks like MITRE ATT&CK.

#### **4️⃣ Security Architecture & Policy Improvements**

- Enhance detection and response strategies.
- Fine-tune security controls, SIEM rules, and firewall policies.
- Collaborate with security engineers to improve infrastructure defenses.

#### **5️⃣ End of Shift – Reporting & Knowledge Sharing**

- Provide detailed reports on major incidents and remediation efforts.
- Conduct post-mortem analysis and suggest preventive measures.
- Train L1/L2 analysts on advanced attack techniques and response methods.

---

#### **Key Tools Used by L3 Analysts:**

✅ **Digital Forensics** (Volatility, Autopsy, FTK)  
✅ **Malware Analysis** (IDA Pro, Ghidra, Cuckoo Sandbox)  
✅ **Threat Intelligence** (MISP, ThreatConnect, Anomali)  
✅ **SIEM & EDR** (Splunk, QRadar, CrowdStrike)

