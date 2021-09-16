FROM node:14-alpine as builder

RUN mkdir /app
WORKDIR /app

COPY ./package*.json ./
RUN npm install

ENV NODE_PATH=/app/node_modules/.bin
COPY ./src ./src
RUN npm run build

FROM nginx:stable
RUN rm -rf /usr/share/nginx/html/*

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/site.conf /etc/nginx/conf.d/default.conf

COPY --from=builder ./app/build /usr/share/nginx/html/

RUN touch /var/run/nginx.pid && \
    chown -R 1001:1001 /var/run/nginx.pid && \
    chown -R 1001:1001 /var/cache/nginx
USER 1001
CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'