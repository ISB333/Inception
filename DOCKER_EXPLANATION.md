# Docker & Infrastructure Explanation

## 1. How Docker and Docker Compose Work

### Docker
Docker is a platform for **containerization**. Think of it as a shipping container for software.
- **How it works:** It packages your application and all its dependencies (libraries, runtime, tools) into a single unit called an **Image**.
- **Runtime:** When you run an image, it becomes a **Container**. Unlike a Virtual Machine, it doesn't need a full operating system. It shares the **host's Linux kernel** but keeps the application isolated in its own user space (filesystem, network, process tree).
- **Result:** It guarantees that "it works on my machine" means it works on *every* machine.

### Docker Compose
Docker Compose is an **orchestrator** for single-host deployments.
- **The Problem:** Running individual `docker run` commands for a complex app (like WordPress + Database + NGINX) is tedious, error-prone, and hard to network together.
- **The Solution:** Compose allows you to define your entire infrastructure (services, networks, volumes) in a single YAML file (`docker-compose.yml`).
- **How it works:** You run `docker-compose up`, and it reads the configuration to build images, create networks, mount volumes, and start containers in the correct order.

---

## 2. Docker Image: With vs. Without Docker Compose

Technically, the **Docker Image itself is identical** in both scenarios. The difference lies in **how it is executed and managed**.

| Feature | Without Docker Compose (CLI) | With Docker Compose |
| :--- | :--- | :--- |
| **Execution** | `docker run -d -p 80:80 --network my-net ...` | `docker-compose up -d` |
| **Configuration** | Flags must be typed manually every time or saved in shell scripts. | Configuration is declarative and version-controlled in `docker-compose.yml`. |
| **Networking** | You must manually create networks and attach containers. | Creates a default network automatically; containers resolve each other by service name (e.g., `ping mariadb`). |
| **Persistence** | Volumes must be manually managed. | Volumes are defined and managed as part of the project stack. |
| **Maintenance** | Hard to restart or update specific parts of the stack. | Easy to restart (`docker-compose restart nginx`) or scale. |

**Summary:** Compose provides a **context** and **automation** layer around the raw Docker images.

---

## 3. Docker vs. Virtual Machines (VMs)

The key difference is **Architecture** and **Efficiency**.

### Virtual Machines (VMs)
- **Architecture:** Hardware -> Hypervisor -> **Guest OS** (Full Kernel) -> Binaries/Libs -> App.
- **Pros:** Complete isolation (different OS possible).
- **Cons:** Heavy. Each VM needs a full OS slice (GBs of RAM, CPU overhead), slow boot times (minutes).

### Docker (Containers)
- **Architecture:** Hardware -> Host OS -> **Docker Engine** -> Binaries/Libs -> App.
- **Pros:**
    - **Lightweight:** No Guest OS. Containers share the Host Kernel.
    - **Fast:** Starts in milliseconds (it's just a process starting).
    - **Efficient:** Uses only the RAM/CPU the app needs.
    - **Portable:** The image contains everything needed to run.

**Analogy:**
- **VM:** A house. It has its own plumbing, heating, and infrastructure. Secure but expensive and heavy.
- **Container:** An apartment. It shares the building's infrastructure (plumbing/heating = Kernel) but has its own locked door and furniture.

---

## 4. Pertinence of the Directory Structure

The required directory structure for Inception is designed for **modularity** and **separation of concerns**.

```
srcs/
├── docker-compose.yml    # The Conductor
├── .env                  # The Secrets
└── requirements/         # The Actors
    ├── mariadb/
    ├── nginx/
    └── wordpress/
```

### Why this structure?
1.  **Decoupling:** Each service (`mariadb`, `wordpress`, `nginx`) is self-contained in its own folder. You can delete the `nginx` folder and the other two services wouldn't care (until they need to talk to it).
2.  **Build Context:** When building the MariaDB image, Docker only needs to look inside `requirements/mariadb/`. It doesn't need to send the WordPress files to the Docker daemon. This speeds up builds.
3.  **Clarity:** It separates the **Orchestration** (`docker-compose.yml` at the root) from the **Implementation** (Dockerfiles and config scripts inside subfolders).
4.  **Scalability:** If you wanted to add a new service (e.g., a Redis cache), you simply add a `redis/` folder in `requirements/` and add a few lines to `docker-compose.yml`. You don't have to rewrite the whole project.

---

## 5. SSL/TLS Certificates (HTTPS)

### What is it?
- **SSL/TLS** (Secure Sockets Layer / Transport Layer Security) is a protocol for establishing authenticated and encrypted links between networked computers.
- **HTTPS** is simply HTTP over SSL/TLS.

### The Certificate
Think of a **Certificate** as a digital ID card (passport) for your website. It does two things:
1.  **Encryption:** It provides the public key used to encrypt data sent between the user and the server.
2.  **Identity:** It proves that the server is who it claims to be (e.g., "I am really google.com").

### How it works (Simplified)
1.  **Handshake:** When you connect to `https://adesille.42.fr`, the server sends its **Public Key** (Certificate).
2.  **Verification:** Your browser checks if the certificate is valid (not expired, matches the domain).
3.  **Encryption:** Your browser uses the Public Key to encrypt a message. Only the server has the corresponding **Private Key** to decrypt it.
4.  **Secure Session:** Once they agree on a secret code, they switch to symmetric encryption for the rest of the session (faster).

### In This Project
- We generated a **Self-Signed Certificate** using `openssl`.
- **Self-Signed:** Means we signed it ourselves, not a trusted Authority (like Verisign or Let's Encrypt).
- **Self-Signed:** Means we signed it ourselves, not a trusted Authority (like Verisign or Let's Encrypt).
- **Trade-off:** Browsers will warn users ("Not Secure"), but the connection is still encrypted and secure from eavesdropping.

### HTTP vs. HTTPS
- **HTTP:** Plain text. Anyone intercepting the connection can read passwords, cookies, and sensitive data.
- **HTTPS:** Encrypted. Data is scrambled, so only the intended recipient can read it. This is why HTTPS is required for login pages, payment forms, and any sensitive information.

