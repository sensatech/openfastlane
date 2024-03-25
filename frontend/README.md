# frontend

This is the frontend of the Open Source Project "OpenFastLane"

## run project on your smartphone's browser

1. flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

2. then open http://localhost:8080 in your smartphone's browser

## Generate

```bash
flutter pub run build_runner build --delete-conflicting-outputs

```

# Start locally as HTTPS server

https://github.com/flutter/flutter/pull/106635

start with extra credentials

```bash
--web-tls-cert-path .certs/example.crt --web-tls-cert-key-path .certs/example.key
```

Deploy on Firebase Hosting

```bash
firebase deploy --only hosting
```