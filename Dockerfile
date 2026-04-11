# Build Flutter Web from monorepo root (optional stack component):
#   docker build -f SecureMail-Flutter/Dockerfile -t securemail-flutter-web \
#     --build-arg API_BASE_URL=http://localhost:3000 .

FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

COPY SecureMail-Flutter/pubspec.yaml SecureMail-Flutter/pubspec.lock* ./
RUN flutter pub get

COPY SecureMail-Flutter .

ARG API_BASE_URL=http://localhost:3000
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginx:1.27-alpine
COPY SecureMail-Flutter/docker/nginx-default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 8080
