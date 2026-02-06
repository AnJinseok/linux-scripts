#!/bin/bash
# workspace 등 여러 디렉터리에서 git pull 실행 (리눅스 전용)
# vi 로 편집해서 아래 "배치 작업" 구간에 필요한 경로/명령을 추가/수정하세요.
# 실행: chmod +x git-pull.sh  후  ./git-pull.sh   또는  bash git-pull.sh

set -e
WORKSPACE="/usr/local/workspace/bin"

echo "===== git pull 배치 시작 ====="

# ---------- 배치 작업 (아래 줄을 vi 로 수정/추가) ----------
echo "[1/3] maple-misc-scripts git pull"
cd "$WORKSPACE/../maple-misc-scripts" && git pull

echo "[2/3] maple-api git pull"
cd "$WORKSPACE/../maple-api" && git pull

echo "[3/3] maple-front git pull"
cd "$WORKSPACE/../maple-front" && git pull

# ---------- 여기 위까지 편집 ----------

echo "===== git pull 배치 완료 ====="
