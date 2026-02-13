#!/usr/bin/env bash
# 저장소에 .sh 파일의 실행 비트를 기록 (한 번만 실행 후 커밋·푸시)
# 실행: linux-scripts 루트에서  bash git/record-executable-bit.sh
# 이후  git add -A  &&  git commit -m "..."  &&  git push  하면, pull 시에도 실행 권한 유지됨

set -e
SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_ROOT"

# shell/, git/, cron/, system/ 아래 모든 .sh 에 대해 실행 비트 기록
git update-index --chmod=+x shell/*.sh 2>/dev/null || true
git update-index --chmod=+x git/*.sh   2>/dev/null || true
git update-index --chmod=+x cron/*.sh  2>/dev/null || true
git update-index --chmod=+x system/*.sh 2>/dev/null || true

echo "실행 비트 기록 완료. git status 로 확인 후 커밋·푸시하세요."
