FROM node:16-alpine as ui-build
WORKDIR /usr/app/client/
COPY package*.json ./
RUN npm install
COPY src/ ./src
COPY public/ ./public
RUN npm run build

FROM node:16-alpine as server-build
WORKDIR /usr/app/
COPY --from=ui-build /usr/app/client/build/ ./client/build
WORKDIR /usr/app/server/

COPY package*.json ./
RUN npm install
COPY server.js ./
ENV NODE_ENV=production

EXPOSE 5000
CMD ["node", "server.js"]