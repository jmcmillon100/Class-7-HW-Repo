#!/bin/bash
set -euo pipefail

# =============================================================================
# Jenkins Bootstrap Script
# Amazon Linux 2023 (AL2023) — t3.medium
# Note: intentionally uses yum for Jenkins repo compatibility
# =============================================================================


# --------------------------------------
# Update all installed packages
# --------------------------------------
echo "[1/9] Updating system packages..."
sudo yum update -y


# --------------------------------------
# Configure swap (AL2023 has none by default)
# 2GB swapfile — prevents OOM kills during heavy Jenkins builds
# --------------------------------------
echo "[2/9] Configuring swap..."
if [ ! -f /swapfile ]; then
  sudo dd if=/dev/zero of=/swapfile bs=128M count=16
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
fi


# --------------------------------------
# Expand /tmp to 4GB via systemd drop-in
# AL2023 mounts /tmp as tmpfs via systemd tmp.mount — fstab remount
# is overridden at boot by the systemd unit. A drop-in override persists.
# --------------------------------------
echo "[3/9] Expanding /tmp..."
sudo mkdir -p /etc/systemd/system/tmp.mount.d

cat << 'EOF' | sudo tee /etc/systemd/system/tmp.mount.d/size.conf
[Mount]
Options=mode=1777,strictatime,nosuid,nodev,size=4G
EOF

sudo systemctl daemon-reload
sudo systemctl restart tmp.mount


# --------------------------------------
# Add the Jenkins repository to yum sources
# --------------------------------------
echo "[4/9] Adding Jenkins repository..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo


# --------------------------------------
# Import the Jenkins GPG key to verify packages
# --------------------------------------
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key


# --------------------------------------
# Upgrade all packages (including those from the new Jenkins repo)
# --------------------------------------
sudo yum upgrade -y


# --------------------------------------
# Install Amazon Corretto 21 (LTS — Java 17 EOL March 31 2026)
# --------------------------------------
echo "[5/9] Installing Java 21..."
sudo yum install java-21-amazon-corretto -y


# --------------------------------------
# Install Jenkins
# --------------------------------------
echo "[6/9] Installing Jenkins..."
sudo yum install jenkins -y


# =============================================================================
# Plugin Installation
# Uses the Plugin Installation Manager Tool (plugin-installation-manager-tool)
# jenkins-plugin-cli is not bundled with Jenkins 2.x rpm packages
# =============================================================================

echo "[7/9] Installing Jenkins plugins..."

JENKINS_HOME="${JENKINS_HOME:-/var/lib/jenkins}"
PLUGIN_DIR="${JENKINS_HOME}/plugins"
PLUGIN_MANAGER_JAR="/usr/local/bin/jenkins-plugin-manager.jar"

sudo mkdir -p "$PLUGIN_DIR"

# Download the Plugin Installation Manager jar
echo "[7/9] Downloading plugin installation manager..."
sudo wget -q -O "$PLUGIN_MANAGER_JAR" \
  https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.0/jenkins-plugin-manager-2.13.0.jar

# Write the plugin list to a temp file
PLUGIN_LIST_FILE=$(mktemp /tmp/jenkins-plugins-XXXXXX.txt)

cat > "$PLUGIN_LIST_FILE" << 'EOF'
# AWS
aws-credentials
pipeline-aws
ec2
amazon-ecs
codedeploy
aws-lambda
aws-codebuild
artifact-manager-s3
aws-secrets-manager-credentials-provider
aws-codepipeline
configuration-as-code-secret-ssm
aws-sam

# IaC
terraform
kubernetes

# Google Cloud
google-storage-plugin
google-kubernetes-engine
google-oauth-plugin

# Security Scanning
snyk-security-scanner
sonar
aqua-security-scanner
aqua-microscanner
aqua-serverless

# GitHub
github
github-oauth
pipeline-github
pipeline-githubnotify-step

# Build & Deploy
maven-plugin
pipeline-maven
publish-over-ssh
EOF

# --skip-failed-plugins skips unresolvable plugins and continues the rest
# --jenkins-update-center bypasses the default 301 redirect to the current index
sudo java -jar "$PLUGIN_MANAGER_JAR" \
  --war /usr/share/java/jenkins.war \
  --plugin-file "$PLUGIN_LIST_FILE" \
  --plugin-download-directory "$PLUGIN_DIR" \
  --jenkins-update-center https://updates.jenkins.io/current/update-center.json \
  --skip-failed-plugins

rm -f "$PLUGIN_LIST_FILE"

# Fix ownership so Jenkins can read the installed plugins
sudo chown -R jenkins:jenkins "$PLUGIN_DIR"

echo "[7/9] Plugin installation complete."


# --------------------------------------
# Enable Jenkins to start at boot
# --------------------------------------
echo "[8/9] Enabling Jenkins service..."
sudo systemctl enable jenkins


# --------------------------------------
# Start the Jenkins service
# --------------------------------------
echo "[9/9] Starting Jenkins..."
sudo systemctl start jenkins

# --------------------------------------
# Write initial admin password to SSM
# so it can be retrieved via terraform output
# --------------------------------------
echo "[post-start] Waiting for initial admin password..."
until [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; do
  sleep 5
done

aws ssm put-parameter \
  --name "/jenkins/initial-admin-password" \
  --value "$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)" \
  --type "SecureString" \
  --overwrite \
  --region us-east-1

echo "============================================"
echo " Jenkins bootstrap complete."
echo " Admin password written to SSM: /jenkins/initial-admin-password"
echo "============================================"
