# CampusOS Web PWA Production Container
FROM nginx:alpine

# Copy custom Nginx configuration
COPY task-4-campusos-quality-deployment/deployment/docker/nginx.conf /etc/nginx/conf.d/default.conf

# Copy pre-built Flutter Web assets into Nginx webroot
# Note: Flutter Web is built prior using `flutter build web --release`
COPY build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
