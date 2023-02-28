FROM node:12-alpine3.11
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --only=production
COPY . ./
CMD [ "node", "app.js" ]