#!/usr/bin/env bash
# /root/ 아래에 워크스페이스·nginx 심볼릭 링크 생성 (root 전용)
# 실행: sudo bash system/link-workspace-symlinks.sh
#
# 생성되는 링크:
#   mcdapi     -> workspace/maple-api
#   mcdfront   -> workspace/maple-front (또는 maple-front)
#   mcdmisc    -> workspace/maple-misc-scripts
#   mcdscripts -> workspace/linux-scripts
#   nginx      -> /etc/nginx (설정)
#   nginx-log  -> /var/log/nginx (로그)

set -e
WORKSPACE="${WORKSPACE:-/usr/local/workspace}"
LINK_ROOT="${LINK_ROOT:-/root}"
NGINX_CONF="${NGINX_CONF:-/etc/nginx}"
NGINX_LOG="${NGINX_LOG:-/var/log/nginx}"

# 링크 정의: "링크이름" "대상 절대 경로"
# 대상이 없으면 건너뜀, 이미 같은 경로면 OK, 파일/디렉터리가 있으면 건너뜀
create_symlink() {
  local name="$1"
  local target="$2"
  local link_path="$LINK_ROOT/$name"

  if [[ -L "$link_path" ]]; then
    local current
    current=$(readlink -f "$link_path")
    if [[ "$current" == "$target" ]]; then
      echo "[OK] $link_path -> $target (이미 동일)"
      return 0
    fi
    echo "[경고] $link_path 가 다른 경로를 가리킴: $current (대상: $target)"
    return 1
  fi

  if [[ -e "$link_path" ]]; then
    echo "[건너뜀] $link_path 가 이미 존재함 (디렉터리/파일)"
    return 1
  fi

  if [[ ! -d "$target" ]]; then
    echo "[건너뜀] 대상 없음: $target"
    return 1
  fi

  ln -s "$target" "$link_path"
  echo "[생성] $link_path -> $target"
}

# 워크스페이스
create_symlink "mcdapi"     "$WORKSPACE/maple-api"
create_symlink "mcdfront"   "$WORKSPACE/maple-front"
create_symlink "mcdmisc"    "$WORKSPACE/maple-misc-scripts"
create_symlink "mcdscripts" "$WORKSPACE/linux-scripts"

# nginx (경로는 환경변수로 변경 가능)
create_symlink "nginx"      "$NGINX_CONF"
create_symlink "nginx-log"  "$NGINX_LOG"

echo "완료. 확인: ls -la $LINK_ROOT"
