#!/usr/bin/env bash
# /var/log/nginx access.log, error.log에서 DB 관련 접속 시도 패턴 검사
# 사용법: 서버에서 실행 (sudo 또는 www-data/adm 권한 필요)
#   bash check-nginx-db-access.sh
#   또는: sudo bash check-nginx-db-access.sh

set -e
LOG_DIR="${NGINX_LOG_DIR:-/var/log/nginx}"
ACCESS_GLOB="$LOG_DIR/access.log*"
ERROR_GLOB="$LOG_DIR/error.log*"

# DB/관리 도구 경로 패턴 (access 로그에서 검색)
# - phpmyadmin, mysql, 3306, admin DB 관련 URI
PATTERNS=(
  'phpmyadmin'
  'phpMyAdmin'
  'mysql'
  'mysqli'
  ':3306'
  '/admin'
  'sqlite'
  'pgadmin'
  'adminer'
  '.php'
  'wp-admin'
  'wp-login'
  'phpunit'
  'actuator'
  'actuator/'
  'console'
  'h2-console'
  'debug'
  '\.sql'
  'union.*select'
  'select.*from'
  'insert.*into'
  'information_schema'
)

echo "=============================================="
echo "Nginx 로그 디렉토리: $LOG_DIR"
echo "=============================================="

# access.log (비압축)
if [[ -f "$LOG_DIR/access.log" ]]; then
  echo ""
  echo "[access.log] DB/관리·스캔 패턴 매칭"
  for p in "${PATTERNS[@]}"; do
    count=$(grep -c -i -E "$p" "$LOG_DIR/access.log" 2>/dev/null || true)
    if [[ -n "$count" && "$count" -gt 0 ]]; then
      echo "  패턴: $p  ->  ${count}건"
      grep -n -i -E "$p" "$LOG_DIR/access.log" 2>/dev/null | head -20
      echo "  ..."
    fi
  done
fi

# access.log.1 (비압축)
if [[ -f "$LOG_DIR/access.log.1" ]]; then
  echo ""
  echo "[access.log.1] DB/관리·스캔 패턴 매칭"
  for p in "${PATTERNS[@]}"; do
    count=$(grep -c -i -E "$p" "$LOG_DIR/access.log.1" 2>/dev/null || true)
    if [[ -n "$count" && "$count" -gt 0 ]]; then
      echo "  패턴: $p  ->  ${count}건"
      grep -n -i -E "$p" "$LOG_DIR/access.log.1" 2>/dev/null | head -20
      echo "  ..."
    fi
  done
fi

# 압축 access 로그
for f in "$LOG_DIR"/access.log.*.gz; do
  [[ -f "$f" ]] || continue
  echo ""
  echo "[$(basename "$f")] DB/관리·스캔 패턴 매칭"
  for p in "${PATTERNS[@]}"; do
    count=$(zcat "$f" 2>/dev/null | grep -c -i -E "$p" 2>/dev/null || true)
    if [[ -n "$count" && "$count" -gt 0 ]]; then
      echo "  패턴: $p  ->  ${count}건"
      zcat "$f" 2>/dev/null | grep -n -i -E "$p" 2>/dev/null | head -20
      echo "  ..."
    fi
  done
done

# error.log: DB/업스트림 연결 관련
echo ""
echo "=============================================="
echo "[error.log] DB/업스트림·연결 관련 라인"
echo "=============================================="
for err in "$LOG_DIR/error.log" "$LOG_DIR/error.log.1"; do
  [[ -f "$err" ]] || continue
  echo ""
  echo "--- $(basename "$err") ---"
  grep -i -E 'connect|refused|3306|mysql|mariadb|upstream|database' "$err" 2>/dev/null || true
done
for err in "$LOG_DIR"/error.log.*.gz; do
  [[ -f "$err" ]] || continue
  echo ""
  echo "--- $(basename "$err") ---"
  zcat "$err" 2>/dev/null | grep -i -E 'connect|refused|3306|mysql|mariadb|upstream|database' 2>/dev/null || true
done

echo ""
echo "=============================================="
echo "검사 완료."
echo "=============================================="
