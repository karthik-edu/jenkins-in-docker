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

# Disable setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
