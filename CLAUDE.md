# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Puppet module (`kogitoapp-gitea`) for managing Gitea (self-hosted Git service). Automates installation, configuration, and service management on Linux/BSD systems.

## Commands

```bash
# Install dependencies
gem install bundler && bundle install

# Run full test suite (metadata_lint, lint, validate, rubocop, spec)
bundle exec rake test

# Individual tasks
bundle exec rake spec                                        # Unit tests only
bundle exec rake spec SPEC=spec/classes/config_spec.rb       # Single spec file
bundle exec rake lint                                        # Puppet lint
bundle exec rake validate                                    # Validate manifests/templates
bundle exec rake rubocop                                     # Ruby style checks

# Acceptance tests (requires Docker/Vagrant)
bundle exec rake beaker
```

## Architecture

### Class Dependency Chain

```
Anchor[gitea::begin]
  -> Class[gitea::packages]   # OS packages (curl, git, tar)
  -> Class[gitea::user]       # git user/group
  -> Class[gitea::install]    # Binary download, dirs, systemd unit
  -> Class[gitea::config]     # INI config file via inifile module
  ~> Class[gitea::service]    # Systemd service (~> triggers restart on config change)
Anchor[gitea::end]
```

The main `gitea` class (init.pp) orchestrates this chain and conditionally includes sub-classes based on `manage_install`, `manage_config`, and `manage_service` parameters.

### Key Design Patterns

- **Version-aware config**: `config.pp` uses `versioncmp()` to handle Gitea >= 1.20 (LFS_CONTENT_PATH moved from `[server]` to `[lfs]` section as `PATH`).
- **HA support**: `manage_install` parameter allows skipping binary installation for active/passive DRBD setups.
- **Hiera data**: Defaults in `data/common.yaml`, OS-specific overrides in `data/os/{OsFamily}.yaml`. Hierarchy defined in `hiera.yaml` (v5).
- **INI config merging**: `config.pp` uses `deep_merge()` to combine required settings with user-provided `configuration_sections`.

### Module Dependencies

- `puppetlabs-stdlib` — `ensure_packages()`, `deep_merge()`, `versioncmp()`
- `puppetlabs-inifile` — INI file management via `create_ini_settings()`
- `lwf-remote_file` — Binary download with checksum verification

### Test Structure

Tests live in `spec/classes/` using RSpec Puppet with `rspec-puppet-facts` for cross-OS testing via `on_supported_os()`. Default test facts are in `spec/default_module_facts.yml`. Test fixtures (module dependencies) defined in `.fixtures.yml`.

## Code Style

- 2-space indentation for `.pp`, `.rb`, `.erb`, `.yaml` files; 4-space for everything else (see `.editorconfig`)
- UTF-8, LF line endings, trailing whitespace trimmed (except Markdown)
- Ruby style enforced by `.rubocop.yml`; Puppet style by puppet-lint via Rakefile
