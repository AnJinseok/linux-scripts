#!/usr/bin/env bash
# cron/crontab 파일 전체를 현재 사용자 crontab으로 적용 (기존 crontab 백업 후 덮어씀)
# 실행: linux-scripts 루트에서  sudo bash cron/install-crontab.sh
# 주의: 현재 crontab이 이 파일로 완전히 교체됩니다. 다른 크론은 이 파일에 함께 넣어 두세요.

set -e
SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CRONTAB_FILE="$SCRIPT_ROOT/cron/crontab"

if [[ ! -f "$CRONTAB_FILE" ]]; then
  echo "파일 없음: $CRONTAB_FILE"
  exit 1
fi

# 기존 crontab 백업 (현재 사용자)
BACKUP="$SCRIPT_ROOT/cron/crontab.backup.$(date +%Y%m%d-%H%M%S)"
crontab -l 2>/dev/null > "$BACKUP" || true
echo "백업: $BACKUP"

# cron/crontab 내용 적용 (주석·빈 줄은 crontab이 그대로 허용)
crontab "$CRONTAB_FILE"
echo "적용 완료. 확인: crontab -l"
