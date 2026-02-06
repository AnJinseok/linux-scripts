# linux-scripts

리눅스·서버 관리용 쉘 스크립트 모음. **Linux 전용**이며, 기능별로 디렉터리를 나눠 두었습니다.

## 디렉터리 구조

```
linux-scripts/
├── README.md
├── wifi/              # Wi-Fi 연결/해제 등
│   └── wifi-connect.sh
├── (추가 예정)        # 네트워크, 시스템, 백업 등 카테고리별로 확장
└── ...
```

- **wifi/** — Wi-Fi 관련 스크립트
- 추후 **네트워크**, **시스템**, **백업** 등 카테고리를 추가할 예정입니다. 새 스크립트는 용도에 맞는 디렉터리에 넣어 사용합니다.

## 요구 사항

- **Linux** (다른 OS에서는 실행하지 않음)
- Bash
- 필요한 스크립트는 대부분 `sudo` 권한 필요

## 사용 방법

1. 저장소 클론 후 해당 디렉터리로 이동
2. 스크립트에 실행 권한 부여: `chmod +x 스크립트명.sh`
3. 각 스크립트의 사용법은 `./스크립트명.sh` (인자 없이 실행) 또는 파일 상단 주석 참고

---

## wifi/

Wi-Fi 연결/해제 (wpa_supplicant). NetworkManager가 인터페이스를 unavailable로 볼 때 사용.

### wifi-connect.sh

| 동작     | 입력할 것 |
|----------|------------|
| 연결 끊기 | `disconnect` (추가 인자 없음) |
| 연결하기 | `connect` + `"공유기 이름(SSID)"` + `"비밀번호"` (따옴표 권장) |

**예시**

```bash
cd wifi
chmod +x wifi-connect.sh

# 연결 끊기
sudo ./wifi-connect.sh disconnect

# 연결
sudo ./wifi-connect.sh connect "MyHomeWiFi" "mypassword123"
```

**환경변수**

- `WIFI_IFACE` — Wi-Fi 인터페이스 (기본: `wlp1s0`)
- `WPA_CONF_DIR` — wpa_supplicant 설정 파일 디렉터리 (기본: `/tmp`)

다른 인터페이스 사용 예:

```bash
WIFI_IFACE=wlan0 sudo ./wifi-connect.sh connect "SSID" "비밀번호"
```

---

## 추후 추가 예정

- 네트워크 진단/설정 스크립트
- 시스템 점검·로그 정리 스크립트
- 백업/복원 스크립트
- 기타 서버 관리용 유틸

새 스크립트는 위와 같이 **기능별 디렉터리**를 만들어 그 안에 두면 됩니다.
