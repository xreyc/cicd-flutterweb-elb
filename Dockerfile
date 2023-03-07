# Base image
FROM ubuntu:20.04 AS builder

# Install dependencies
RUN apt-get update
RUN apt-get install -y git unzip curl
RUN apt-get clean

# Clone the flutter repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter path
# RUN /usr/local/flutter/bin/flutter doctor -v
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Change stable channel
RUN flutter channel stable

# Enable web capabilities
RUN flutter config --enable-web
RUN flutter upgrade
RUN flutter pub global activate webdev

# Copy files to container and build
RUN mkdir /app
COPY . /app
WORKDIR /app
RUN flutter pub get
RUN flutter build web --release

# Start Nginx
FROM nginx:1.21.1-alpine
COPY default.conf /etc/nginx/conf.d
COPY --from=builder /app/build/web /usr/share/nginx/html