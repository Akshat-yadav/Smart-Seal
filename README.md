# Blockchain Certificate Verification System

This repository contains three integrated parts:
- `server/`: Node.js + Express + MongoDB backend (JWT auth, upload, QR generation, PDF QR embed, verification)
- `flutter_app/`: Flutter mobile app (public verify + admin upload)
- `contracts/`: Solidity smart contract for certificate hash storage

## 1) Backend Setup

```powershell
cd C:\Users\91933\Dev\majorproject\server
copy .env.example .env
npm install
npm run dev
```

Backend default URL: `http://localhost:5000`

### Backend APIs
- `POST /admin/login`
- `POST /admin/bootstrap` (one-time initial admin creation, secret-gated)
- `POST /admin/create` (JWT required, create additional admins)
- `POST /admin/upload-certificate` (JWT required)
- `POST /upload-certificate` (JWT required, alias route for app integration)
- `GET /verify/:certificateId`

### Admin Security Flow
- Set `ADMIN_BOOTSTRAP_ENABLED=true` and a strong `ADMIN_BOOTSTRAP_SECRET` in `server/.env`.
- Call `POST /admin/bootstrap` once to create the first admin.
- Set `ADMIN_BOOTSTRAP_ENABLED=false` after initial setup.
- Use `/admin/create` (authenticated) for future admin accounts.
- `ALLOW_INSECURE_ADMIN_SEED` is for local development only and should stay `false` in production.

## 2) Flutter App Setup

```powershell
cd C:\Users\91933\Dev\majorproject\flutter_app
flutter pub get
flutter run
```

Update base URL in:
- `flutter_app/lib/core/config/app_config.dart`

Use:
- Android emulator: `http://10.0.2.2:5000`
- iOS simulator: `http://localhost:5000`
- Physical device: `http://<your-lan-ip>:5000`

## 3) Smart Contract

Contract file:
- `contracts/CertificateVerifier.sol`

Required functions:
- `addCertificate(bytes32 hash)` (admin only)
- `verifyCertificate(bytes32 hash)`

## 4) Optional Blockchain Integration in Backend

Backend can write/verify hashes on-chain if these are set in `server/.env`:

- `BLOCKCHAIN_RPC_URL`
- `BLOCKCHAIN_CONTRACT_ADDRESS`
- `BLOCKCHAIN_ADMIN_PRIVATE_KEY`
- `BLOCKCHAIN_REQUIRED=false` (set `true` to fail uploads when chain write fails)

If variables are not set, backend still works with MongoDB-only verification.
