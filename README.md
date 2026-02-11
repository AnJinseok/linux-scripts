# linux-scripts

리눅스·서버 관리용 쉘 스크립트 모음. **Linux 전용**이며, 기능별로 디렉터리를 나눠 두었습니다.

---

## 디렉터리 구조

```
linux-scripts/
├── README.md
├── wifi/              # Wi-Fi 연결/해제
│   └── wifi-connect.sh
├── system/            # 패키지 설치, 시스템 유틸
│   └── install_from_list.sh
├── shell/             # source 로 쓸 alias·함수 (서버용)
│   ├── aliases.sh
│   ├── start-maple-api-screen.sh
│   └── start-maple-front-screen.sh
├── git/               # git 배치 작업
│   └── git-pull.sh
└── ...
```

| 디렉터리 | 설명 |
|----------|------|
| **wifi/** | Wi-Fi 연결/해제 (wpa_supplicant) |
| **system/** | apt 패키지 일괄 설치 등 |
| **shell/** | 포트 조회/종료, Maple 워크스페이스 alias, screen 실행 스크립트 |
| **git/** | 여러 저장소 일괄 `git pull` |

---

## 요구 사항

- **Linux**
- Bash
- 일부 스크립트는 `sudo` 권한 필요

---

## 사용 방법

1. 저장소 클론 후 해당 디렉터리로 이동
2. `chmod +x 스크립트명.sh` 로 실행 권한 부여
3. `./스크립트명.sh` 또는 파일 상단 주석 참고

---

## wifi/

Wi-Fi 연결/해제 (wpa_supplicant).

### wifi-connect.sh

| 동작 | 사용법 |
|------|--------|
| 연결 끊기 | `sudo ./wifi-connect.sh disconnect` |
| 연결하기 | `sudo ./wifi-connect.sh connect "SSID" "비밀번호"` |

환경변수: `WIFI_IFACE` (기본 `wlp1s0`), `WPA_CONF_DIR` (기본 `/tmp`)

---

## system/

### install_from_list.sh

패키지 목록 파일을 읽어 `apt install` 로 일괄 설치.  
인자 생략 시 `./manual-packages.list` 사용.

```bash
./install_from_list.sh
./install_from_list.sh /path/to/my-packages.list
```

생성 파일: `*.resolved.*.list`, `*.missing.*.list`, `*.install.*.log`

---

## shell/

서버에 배치 후 `source` 해서 사용하는 alias·함수 및 Maple 실행 스크립트.

### aliases.sh

- **findport / killport / killport9** — 포트 조회·종료
- **ws, wsa, wsf** — 워크스페이스 경로
- **mweb, mapi** — 프론트 dev / API bootRun
- **screen** — sl, sr, sra, sk, ska 등 (세션 목록·접속·종료)
- **gitpull** — git-pull.sh 실행

```bash
source /path/to/shell/aliases.sh
# 도움말
ws-help
```

### start-maple-api-screen.sh / start-maple-front-screen.sh

`screen` 세션으로 Maple API 또는 Front 개발 서버를 백그라운드 실행.  
스크립트 내 경로를 서버 환경에 맞게 수정한 뒤 사용하세요.

```bash
chmod +x start-maple-api-screen.sh start-maple-front-screen.sh
./start-maple-api-screen.sh
./start-maple-front-screen.sh
```

---

## git/

### git-pull.sh

스크립트 내 `WORKSPACE` 및 배치할 저장소 경로를 수정한 뒤, 여러 저장소에서 순서대로 `git pull` 실행.

```bash
./git-pull.sh
```

---

## 추후 추가 예정

- 네트워크 진단/설정
- 로그 정리·백업/복원
- 기타 서버 관리 유틸
