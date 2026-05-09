FROM node:18-alpine

ENV NODE_ENV=production

WORKDIR /app

COPY src/package*.json ./
RUN npm install --production

COPY src/ .
RUN chown -R node:node /app

USER node

EXPOSE 3000
CMD ["node", "server.js"]