#!/bin/bash
# workspace 등 여러 디렉터리에서 git pull 실행 (리눅스 전용)
# 정책: 원격(깃)을 무조건 따름 — 로컬 수정은 버리고 fetch + reset --hard
# 실행: chmod +x git-pull.sh  후  ./git-pull.sh   또는  bash git-pull.sh

set -e
WORKSPACE="/usr/local/workspace"

# 현재 브랜치를 원격과 동일하게 맞춤 (로컬 변경 버림)
do_pull() {
    local dir="$1"
    local name="$2"
    echo "[$name] $dir"
    cd "$dir" && git fetch origin && git reset --hard "origin/$(git branch --show-current)"
}

echo "===== git pull 배치 시작 (원격 기준으로 덮어씀) ====="

# ---------- 배치 작업 (아래 줄을 vi 로 수정/추가) ----------
do_pull "$WORKSPACE/linux-scripts"    "1/4 linux-scripts"
do_pull "$WORKSPACE/maple-misc-scripts" "2/4 maple-misc-scripts"
do_pull "$WORKSPACE/maple-api"         "3/4 maple-api"
do_pull "$WORKSPACE/maple-front"       "4/4 maple-front"

# ---------- 여기 위까지 편집 ----------

echo "===== git pull 배치 완료 ====="
