# GrowCipher

## Visão Geral
GrowCipher é uma plataforma global, privada e offline-first para cultivadores de cannabis gerenciarem todo o ciclo de suas plantas com segurança, autonomia e controle total sobre os próprios dados.

## Escolha Tecnológica
- **Linguagem / Framework:** Flutter / Dart
- **Arquitetura:** Offline-first
- **Banco de Dados Local:** SQLite via plugin com suporte a SQLCipher
- **Segurança:** Acesso nativo a biometria, Android Keystore e Apple Secure Enclave (via plugins ou Platform Channels específicos).

## Pilares
1. **Offline-first** — tudo funciona sem rede e sem conta.
2. **Privacidade criptografada** — dados no aparelho, chaves no cofre do SO, nada de telemetria.
3. **Progressão local** — gamificação single-player para tornar o registro detalhado um hábito: XP por campo preenchido, níveis, conquistas, sequências e completude por planta. Sem ranking, sem cobrança, sem funcionalidade travada. Ver `docs/Gamificacao.md`.
4. **Inteligência no aparelho** — análise derivada do próprio histórico, com inferência 100% local em três camadas (determinística sempre presente; visão e linguagem como download opcional). Ver `docs/IA.md`.

## Objetivos (MVP)
1. Memória do cultivo (plantas, ciclos, ocorrências).
2. Organização diária (regas, observações, tarefas sem depender da nuvem).
3. Privacidade extrema (dados criptografados, sem rastreadores, remoção de EXIF das fotografias).
4. Aprendizado (estatísticas puramente baseadas nos próprios dados).
5. Motivo para registrar (progressão local que recompensa densidade de histórico).
6. Análise sem entregar o cofre (insights calculados no aparelho).
