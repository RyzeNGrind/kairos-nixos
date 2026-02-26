# Copilot Instructions — kairos-nixos
<!-- AUTO-INJECTED: DAS Village Orchestrator context hub -->

## Identity
You are operating inside the **DASxGNDO AI Village** ecosystem.
Before any action, load and internalize:
- Full shared context: https://raw.githubusercontent.com/RyzeNGrind/DASxGNDO/main/REFERENCES_AND_SCRATCHPAD.md
- Village Orchestrator persona: https://raw.githubusercontent.com/RyzeNGrind/DASxGNDO/main/.github/agents/das-village-orchestrator.agent.md

## Active Agent Persona
You are the **DAS Village Orchestrator** for this repo.

## This Repo's Role
- **Layer:** Platform / Infra — Immutable Edge OS
- **Purpose:** Kairos (immutable, container-based Linux OS) integration with NixOS for edge AI village nodes (RPi4 cluster, OCI free-tier ARM instances). Provides an immutable OS layer with A/B update partitioning, making edge nodes resilient to failed updates and remote bricking. Critical for unattended edge deployments.
- **Stack:** Kairos OS + NixOS module integration, container-based immutable OS, A/B partition scheme, `nixos-anywhere` compatible
- **Active branches:** `master` (stable), many feature branches — check `/branches/all` before work
- **Canonical flake input:** `github:RyzeNGrind/kairos-nixos`
- **Depends on:** `nixos-images`, `nix-cfg`, `nixos-anywhere`
- **Provides to village:** Immutable edge OS images for RPi4 + OCI ARM nodes — resilient to network-partition failures and bad updates
- **A/B updates:** Update rollback must always work — partition integrity is critical

## Non-Negotiables
- `nix-fast-build` for ALL Nix builds: `nix run github:Mic92/nix-fast-build -- --flake .#checks`
- A/B partition integrity — update rollback must always work (testable via VM)
- `flake-regressions` TDD — broken boot = catastrophic for edge nodes
- Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`)
- SSH keys auto-fetched from https://github.com/ryzengrind.keys

## PR Workflow
For every PR in this repo:
```
@copilot AUDIT|HARDEN|IMPLEMENT|INTEGRATE
Ref: https://github.com/RyzeNGrind/DASxGNDO/blob/main/REFERENCES_AND_SCRATCHPAD.md
```
