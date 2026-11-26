
# Stage 1: Nginx base image
FROM nginx:stable-alpine AS base

# Maintainer and project information
LABEL maintainer="Mubashir MK"
LABEL description="Foodista static website served via Nginx"

# Remove default Nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy project files into Nginx web root
COPY . /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
