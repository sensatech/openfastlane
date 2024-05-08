#Stage 1 - Install dependencies and build the app in a build environment
FROM ubuntu:latest AS build-env

# Install flutter dependencies
RUN apt-get update
RUN apt-get install -y curl git wget unzip gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 sed
RUN apt-get clean

# Clone the flutter repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
# Set flutter path
ENV PATH="${PATH}:/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin"

# Run flutter doctor
RUN flutter doctor -v
RUN flutter channel stable
RUN flutter upgrade

WORKDIR /app/frontend

ADD frontend /app/frontend

RUN dart pub get
RUN flutter build web --release --base-href /app/

# Stage 2 - Create the run-time image
FROM nginx:1.21.1-alpine
COPY docker-nginx-ofl-frontend.conf /etc/nginx/nginx.conf
COPY --from=build-env /app/frontend/build/web /usr/share/nginx/html/app
RUN chmod 755 /usr/share/nginx/html -R
EXPOSE 9000