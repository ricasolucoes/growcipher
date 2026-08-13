# GrowCipher

## Visão Geral
GrowCipher é uma plataforma global, privada e offline-first para cultivadores de cannabis gerenciarem todo o ciclo de suas plantas com segurança, autonomia e controle total sobre os próprios dados.

## Escolha Tecnológica
- **Linguagem / Framework:** Flutter / Dart
- **Arquitetura:** Offline-first
- **Banco de Dados Local:** SQLite via plugin com suporte a SQLCipher
- **Segurança:** Acesso nativo a biometria, Android Keystore e Apple Secure Enclave (via plugins ou Platform Channels específicos).

## Objetivos (MVP)
1. Memória do cultivo (plantas, ciclos, ocorrências).
2. Organização diária (regas, observações, tarefas sem depender da nuvem).
3. Privacidade extrema (dados criptografados, sem rastreadores, remoção de EXIF das fotografias).
4. Aprendizado (estatísticas puramente baseadas nos próprios dados).

## Current State (v1.0)
The v1.0 milestone has been completed. The app features:
- Core Riverpod architecture and secure encrypted storage (SQLCipher + Biometrics).
- Plant creation, timeline and quick event logging.
- Secure photo capturing with offline EXIF stripping.
- Export functionality (encrypted ZIP backup) and local dashboard statistics.

## Next Milestone Goals (v1.1+)
- TBD.
