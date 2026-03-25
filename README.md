You want to:

* skip manual setup wizard
* install plugins automatically
* set admin username/password
* run everything via Docker

👉 This is done using **Configuration as Code (JCasC)** + a custom image.

---

# 🧠  Approach (best practice)

We’ll use:

1. **Custom Docker image**
2. **Jenkins Configuration as Code (JCasC)**
3. **Predefined plugins list**

---

# 📦 Project structure

```
jenkins/
├── Dockerfile
├── plugins.txt
├── casc.yaml
```

---

# 🐳 1. Dockerfile

```dockerfile id="jenkins-dockerfile"
FROM jenkins/jenkins:lts

USER root

# Install docker CLI (optional but useful)
RUN apt-get update && apt-get install -y docker.io

USER jenkins

# Install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Add JCasC config
COPY casc.yaml /usr/share/jenkins/ref/casc.yaml

# Enable JCasC
ENV CASC_JENKINS_CONFIG=/usr/share/jenkins/ref/casc.yaml
```

---

# 🔌 2. plugins.txt

List all required plugins:

```txt id="plugins-list"
configuration-as-code
workflow-aggregator
git
docker-workflow
blueocean
credentials-binding
```

👉 Add more as needed

---

# ⚙️ 3. casc.yaml (auto setup Jenkins)

```yaml id="casc-config"
jenkins:
  systemMessage: "Jenkins configured automatically 🚀"

  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: admin
          password: admin123

  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false

unclassified:
  location:
    url: http://localhost:8080/
```

---

# 🚀 4. Build image

```bash id="build-jenkins"
docker build -t my-jenkins .
```

---

# ▶️ 5. Run container

```bash id="run-jenkins"
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  my-jenkins
```

---

# 🎉 What you get

When Jenkins starts:

✅ No setup wizard
✅ Plugins pre-installed
✅ Admin user already created
✅ Ready to use immediately

---

# 🔐 Disable setup wizard (important)

If needed, explicitly disable:

```dockerfile id="disable-wizard"
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
```

---

# 🔁 Change password securely (better way)

Instead of hardcoding:

```yaml id="secure-password"
password: ${JENKINS_ADMIN_PASSWORD}
```

Run container with:

```bash id="env-password"
-e JENKINS_ADMIN_PASSWORD=StrongPassword123
```

---

# 🔥 Production improvements

* Use **Docker secrets** instead of env vars
* Store `casc.yaml` in Git
* Backup `/var/jenkins_home`
* Add reverse proxy (Nginx)

---

# ⚠️ Common mistakes

❌ Forgetting `configuration-as-code` plugin
❌ Wrong YAML indentation
❌ Not mounting volume → config lost
❌ Hardcoding passwords in repo

---

# 🏁 TL;DR

To automate Jenkins setup:

* Use **custom Dockerfile**
* Add **plugins.txt**
* Add **casc.yaml**
* Disable setup wizard
* Run container
