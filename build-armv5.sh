#!/bin/bash
set -eux

cd /ws

# Debian 11 用 APT リポジトリ修正
sed -i 's|deb.debian.org/debian|archive.debian.org/debian|g' /etc/apt/sources.list
sed -i 's|^deb .*bullseye-security.*|# &|g' /etc/apt/sources.list
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99ignore-check-valid-until

# 必要パッケージをインストール
apt update
apt -y install git build-essential cmake autoconf automake libtool pkg-config \
               libsdl2-dev libx11-dev x11proto-dev liblua5.3-dev zlib1g-dev \
               libminizip-dev libpng-dev libzip-dev libsqlite3-dev libelf-dev \
               libfreetype6-dev libjson-c-dev

# ソース取得
git clone --depth=1 https://github.com/mgba-emu/mgba.git
cd mgba

mkdir -p build && cd build

# CMake オプション指定
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/ws/armel \
  -DBUILD_QT=OFF \
  -DBUILD_SDL=ON \
  -DUSE_LUA=ON \
  -DUSE_DISCORD_RPC=OFF \
  -DUSE_FFMPEG=OFF \
  -DUSE_ZLIB=ON \
  -DUSE_MINIZIP=ON \
  -DUSE_PNG=ON \
  -DUSE_LIBZIP=ON \
  -DUSE_SQLITE3=ON \
  -DUSE_ELF=ON \
  -DUSE_JSON_C=ON \
  -DUSE_FREETYPE=ON \
  -DM_CORE_GBA=ON \
  -DM_CORE_GB=ON \
  -DBUILD_SHARED=ON \
  -DBUILD_STATIC=OFF \
  -DBUILD_TEST=OFF \
  -DBUILD_EXAMPLE=OFF \
  -DBUILD_HEADLESS=OFF

make -j$(nproc)

# 成果物整理
mkdir -p /ws/armel
cp mgba /ws/armel/mgba
chmod +x /ws/armel/mgba
