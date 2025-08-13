# Use an official Node.js runtime as a parent image
FROM node:18-alpine

# Create and change to the app directory.
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure both package.json AND package-lock.json are copied.
# Copying this first prevents re-running npm install on every code change.
COPY app/package*.json ./

# Install production dependencies.
RUN npm install --production
# RUN npm install -g npm@11.5.2 --omit-dev

# Copy local code to the container image.
COPY app/ ./

# Make port 3000 available to the world outside this container
EXPOSE 3000

# Run the app when the container launches
CMD ["node", "index.js"]
