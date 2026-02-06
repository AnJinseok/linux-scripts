#!/bin/bash
#
# wifi-connect.sh — Wi-Fi 연결/해제 (wpa_supplicant)
# 리눅스 전용. NetworkManager가 인터페이스를 unavailable로 볼 때 사용.
#
# 사용법:
#   sudo ./wifi-connect.sh disconnect
#   sudo ./wifi-connect.sh connect "SSID" "비밀번호"
#
# 입력할 것:
#   끊기:        disconnect 만 입력 (추가 인자 없음)
#   연결:        connect + "공유기 이름(SSID)" + "비밀번호" (따옴표 권장)
# 예시:
#   sudo ./wifi-connect.sh disconnect
#   sudo ./wifi-connect.sh connect "MyHomeWiFi" "mypassword123"
#
# 환경변수:
#   WIFI_IFACE   — Wi-Fi 인터페이스 (기본: wlp1s0)
#   WPA_CONF_DIR — wpa_supplicant 설정 디렉터리 (기본: /tmp)
#

set -e

# ---------------------------------------------------------------------------
# 기본값 (환경변수로 덮어쓰기 가능)
# ---------------------------------------------------------------------------
WIFI_IFACE="${WIFI_IFACE:-wlp1s0}"
WPA_CONF_DIR="${WPA_CONF_DIR:-/tmp}"

# ---------------------------------------------------------------------------
# 사용법 출력 후 종료
# 입력: 없음
# 출력: usage 문자열을 stdout으로 출력, exit 1
# ---------------------------------------------------------------------------
usage() {
    echo "Usage: $0 disconnect"
    echo "       $0 connect <SSID> <PASSWORD>"
    echo ""
    echo "  disconnect  - wpa_supplicant 종료, DHCP 해제"
    echo "  connect     - 지정 SSID/비밀번호로 Wi-Fi 연결"
    echo ""
    echo "입력할 것:"
    echo "  disconnect  → 아무 추가 입력 없이: $0 disconnect"
    echo "  connect     → 연결할 Wi-Fi 이름(SSID)과 비밀번호: $0 connect \"공유기이름\" \"비밀번호\""
    echo ""
    echo "예시:"
    echo "  $0 disconnect"
    echo "  $0 connect \"MyHomeWiFi\" \"mypassword123\""
    echo ""
    echo "Env: WIFI_IFACE=${WIFI_IFACE}  WPA_CONF_DIR=${WPA_CONF_DIR}"
    exit 1
}

# ---------------------------------------------------------------------------
# 리눅스 여부 확인
# 입력: 없음
# 출력: 리눅스가 아니면 에러 메시지 후 exit 1
# ---------------------------------------------------------------------------
check_linux() {
    if [[ "$(uname -s)" != "Linux" ]]; then
        echo "Error: 이 스크립트는 Linux 전용입니다." >&2
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Wi-Fi 연결 해제: wpa_supplicant 종료, DHCP 해제
# 입력: 없음 (WIFI_IFACE 사용)
# 출력: 진행 메시지, 해제 완료
# ---------------------------------------------------------------------------
cmd_disconnect() {
    echo "[*] Wi-Fi 연결 해제 중: ${WIFI_IFACE}"

    # 기존 wpa_supplicant 프로세스 종료
    if killall wpa_supplicant 2>/dev/null; then
        echo "    wpa_supplicant 종료됨"
    fi

    # DHCP 임대 해제 (실패해도 계속 진행)
    dhclient -r "${WIFI_IFACE}" 2>/dev/null || true

    # NetworkManager가 해당 장치를 관리하지 않도록 설정 (선택)
    if command -v nmcli &>/dev/null; then
        nmcli device set "${WIFI_IFACE}" managed no 2>/dev/null || true
    fi

    echo "[*] 해제 완료"
}

# ---------------------------------------------------------------------------
# Wi-Fi 연결: wpa_supplicant 설정 생성 후 연결, DHCP로 IP 획득
# 입력: $1=SSID, $2=비밀번호(PSK)
# 출력: 연결 진행 메시지, 성공 시 IP 정보 / 실패 시 exit 1
# ---------------------------------------------------------------------------
cmd_connect() {
    local ssid="$1"
    local psk="$2"

    # SSID/비밀번호 필수
    if [[ -z "$ssid" || -z "$psk" ]]; then
        echo "Error: connect 시 SSID와 비밀번호가 필요합니다." >&2
        usage
    fi

    echo "[*] Wi-Fi 연결: SSID=${ssid}, iface=${WIFI_IFACE}"

    # 기존 wpa_supplicant 종료
    killall wpa_supplicant 2>/dev/null || true
    sleep 1

    # NetworkManager가 인터페이스를 건드리지 않도록
    if command -v nmcli &>/dev/null; then
        nmcli device set "${WIFI_IFACE}" managed no 2>/dev/null || true
    fi

    # 인터페이스 up
    ip link set "${WIFI_IFACE}" up

    # wpa_supplicant 설정 파일 생성
    local conf_file="${WPA_CONF_DIR}/wpa-${ssid}.conf"
    cat > "${conf_file}" << EOF
network={
    ssid="${ssid}"
    psk="${psk}"
    key_mgmt=WPA-PSK
}
EOF
    echo "    설정 파일: ${conf_file}"

    # 기존 IP/라우트 제거 후 wpa_supplicant 백그라운드 실행
    ip addr flush dev "${WIFI_IFACE}" 2>/dev/null || true
    wpa_supplicant -B -i "${WIFI_IFACE}" -c "${conf_file}"
    echo "    wpa_supplicant 시작됨, AP 연결 대기 중..."
    sleep 5

    # DHCP로 IP 획득
    dhclient -r "${WIFI_IFACE}" 2>/dev/null || true
    dhclient "${WIFI_IFACE}" 2>/dev/null || true
    sleep 1

    # IPv4 할당 여부 확인
    if ip -4 addr show "${WIFI_IFACE}" | grep -q 'inet '; then
        echo "[*] 연결 완료"
        ip -4 addr show "${WIFI_IFACE}" | grep 'inet '
    else
        echo "[!] IP를 받지 못했습니다. 수동 확인: ip a show ${WIFI_IFACE}" >&2
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# 메인: 리눅스 확인 후 서브커맨드 실행
# ---------------------------------------------------------------------------
check_linux

case "${1:-}" in
    disconnect)
        cmd_disconnect
        ;;
    connect)
        shift
        cmd_connect "$1" "$2"
        ;;
    *)
        usage
        ;;
esac
