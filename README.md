# openclawbeta on Fly.io (Ubuntu 24.04 + KasmVNC + OpenClaw)

이 저장소는 아래 요구사항을 충족하도록 Fly.io 배포 구성을 제공합니다.

- 베이스 이미지: **Ubuntu 24.04 LTS**
- 원격 데스크톱: **KasmVNC**
- AI 환경: **OpenClaw Gateway 부팅 시 자동 시작**
- 브라우저: **Google Chrome 기본 설치**
- Fly 앱 이름: **openclawbeta**
- 머신 스펙: **performance 16 vCPU(AMD EPYC), RAM 131072MB**
- 스토리지: **Volume 500GB SSD**
- 기본 VNC 비밀번호: **17891789**

## Codespaces에서 그대로 복붙용 전체 명령어

아래 블록을 통째로 복사/붙여넣기 하시면 됩니다.

```bash
set -e

# 0) Fly CLI 설치 (Codespaces에 없을 때만)
if ! command -v flyctl >/dev/null 2>&1; then
  curl -L https://fly.io/install.sh | sh
  export FLYCTL_INSTALL="${HOME}/.fly"
  export PATH="${FLYCTL_INSTALL}/bin:${PATH}"
fi

# 1) 로그인
fly auth login

# 2) 앱 생성
fly apps create openclawbeta

# 3) 500GB 볼륨 생성 (도쿄 리전 nrt)
fly volumes create openclaw_data --region nrt --size 500

# 4) 기본 VNC 비밀번호 설정
fly secrets set VNC_PASSWORD='17891789'

# 5) 배포 (최초 머신 생성 포함)
fly deploy --remote-only

# 6) 확인
fly status
fly ips list
```

> `fly deploy` 시 `fly.toml` 설정으로 머신이 생성되며, VM 사양은 `performance / 16 vCPU / 131072MB`로 적용됩니다.

## 접속 포트

- `443/tcp` → KasmVNC Web UI (`:8443`)
- `18789/tcp` → OpenClaw Gateway (`:18789`)

## 기본 계정/암호

- 사용자: `kasm`
- VNC 비밀번호 기본값: `17891789`

## 동작 방식

- `supervisord` 가 컨테이너 PID 1으로 실행됩니다.
- `start-kasmvnc.sh` 가 KasmVNC 서버를 시작합니다.
- `start-openclaw.sh` 가 `openclaw gateway --port 18789 --verbose` 를 자동 실행합니다.
- `/data` 는 Fly Volume 에 마운트되어 영속 저장됩니다.
