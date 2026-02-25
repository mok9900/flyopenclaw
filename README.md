# openclawbeta on Fly.io (Ubuntu 24.04 + KasmVNC + OpenClaw)

이 저장소는 아래 요구사항을 충족하도록 Fly.io 배포 구성을 제공합니다.

- 베이스 이미지: **Ubuntu 24.04 LTS**
- 원격 데스크톱: **KasmVNC**
- AI 환경: **OpenClaw Gateway 부팅 시 자동 시작**
- 브라우저: **Google Chrome 기본 설치**
- Fly 앱 이름: **openclawbeta**
- 머신 스펙: **performance 16 vCPU(AMD EPYC), RAM 131072MB**
- 스토리지: **Volume 500GB SSD**

## 배포 순서

```bash
fly auth login
fly apps create openclawbeta
fly volumes create openclaw_data --region nrt --size 500
fly deploy
```

> `fly.toml` 에서 앱 이름은 `openclawbeta` 로 고정되어 있습니다.

## 접속 포트

- `443/tcp` → KasmVNC Web UI (`:8443`)
- `18789/tcp` → OpenClaw Gateway (`:18789`)

## 기본 계정/암호

- 사용자: `kasm`
- VNC 비밀번호 기본값: `openclawbeta`
- 운영 시에는 반드시 Fly secret/env 로 `VNC_PASSWORD` 변경을 권장합니다.

```bash
fly secrets set VNC_PASSWORD='강력한비밀번호'
```

## 동작 방식

- `supervisord` 가 컨테이너 PID 1으로 실행됩니다.
- `start-kasmvnc.sh` 가 KasmVNC 서버를 시작합니다.
- `start-openclaw.sh` 가 `openclaw gateway --port 18789 --verbose` 를 자동 실행합니다.
- `/data` 는 Fly Volume 에 마운트되어 영속 저장됩니다.
