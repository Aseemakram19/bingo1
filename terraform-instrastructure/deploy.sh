#!/bin/bash

#################################################################
#Author : Mohammed Aseem - YOUTUBE CHANNEL - CLOUDASEEM
#This will install Jenkins and Docker and Sonarqube and trivy
####################################################################

# Update the package list to make sure you have the latest information about available packages
sudo apt update -y
sleep 5
# 1.  Install Nginx
sudo apt install nginx -y
sleep 5
# Start the Nginx service
sudo systemctl start nginx 
sudo systemctl enable nginx #Nginx to start automatically on system boot
sleep 5

# 2. jenkins installation on ubuntu 
sudo apt update -y
sleep 5
sudo apt install fontconfig openjdk-17-jre -y
sleep 15
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sleep 5
sudo apt-get install jenkins -y 
sleep 10
sudo systemctl enable jenkins
sudo systemctl start jenkins

# 3. install docker & INSTALL SONARQUBE AS A CONTAINER IN THE EC2 INSTANCE
sudo apt-get update -y
sudo apt-get install docker.io -y
sleep 5
sudo usermod -aG docker ubuntu 
sudo usermod -aG docker jenkins 
newgrp docker
sleep 5
sudo chmod 777 /var/run/docker.sock
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
sleep 5

# 4. install trivy ON THE INSTANCE
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
sleep 5
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sleep 5
sudo apt-get install trivy -y
sleep 5
