# Dockerfile

# base image
FROM node:alpine

# create & set working directory
RUN mkdir -p /home/ubuntu
WORKDIR /home/ubuntu

# copy source files
COPY . /home/ubuntu

# install dependencies
RUN npm install

# start app
RUN npm run build
EXPOSE 3000
CMD [ "npm", "start" ]