# #!/bin/bash

# # user_data scripts automatically execute as root user, 
# # so, no need to use sudo
sudo apt-get update -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update

# # # install docker community edition
sudo apt-cache policy docker-ce
sudo apt-get install -y docker-ce

# #Build new imageterraform
sudo docker build -t app /home/ubuntu/app

# #run container with the new image
sudo docker run -d -p 80:3000 --name app app

