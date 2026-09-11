#!/bin/bash
set -e

echo "========================================"
echo " Starting Flutter Web Build for Vercel"
echo "========================================"

# Clone flutter stable if not cached
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK (stable branch)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
else
  echo "Found existing Flutter directory."
fi

export PATH="$PATH:`pwd`/flutter/bin"

echo "Flutter Version:"
flutter --version

echo "Enabling Flutter Web..."
flutter config --enable-web

echo "Getting dependencies..."
flutter pub get

echo "Compiling Flutter Web release..."
flutter build web --release

echo "========================================"
echo " Build Completed Successfully! (build/web)"
echo "========================================"
