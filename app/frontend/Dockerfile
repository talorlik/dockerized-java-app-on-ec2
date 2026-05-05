###############################################################################
# Frontend Dockerfile - static site + reverse proxy via Nginx Alpine.
###############################################################################

FROM nginx:1.27-alpine

RUN apk add --no-cache curl

# Custom config replaces the default
RUN rm -f /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY src/ /usr/share/nginx/html/

EXPOSE 80

HEALTHCHECK --interval=15s --timeout=3s --retries=5 \
  CMD curl -fsS http://localhost/healthz || exit 1
