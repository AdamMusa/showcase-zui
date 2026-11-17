# Bundled demo applications

Every directory here is a complete, standalone Zui application: pure Ruby plus its own assets, with
no application-owned QML. They are vendored copies of the framework's example suite, kept here so
the showcase can launch real applications instead of showing pictures of them.

Run any of them directly:

```bash
zui run demos/smart_home_energy/main.rb
```

Or open the showcase's **Demo apps** page and press Launch, which runs the same command as a
detached child process from the repository root.

## What was changed from upstream

- `Gemfile` resolves Zui from a sibling `../../../zui` checkout, falling back to the published gem.
  Override with `ZUI_PATH`.
- `Gemfile.lock`, `dist/`, `android/`, `ios/` and the framework test harness directories were not
  copied: locks and generated project trees belong to whoever builds, and `zui mobile --enable`
  recreates the mobile directories on demand.
- Nothing else. The Ruby sources, READMEs, asset provenance notes and assets are unchanged.

## Packaging a demo

```bash
zui bundle demos/tesla_drive_dashboard
zui bundle --full demos/tesla_drive_dashboard
```

Generated bundles land under each application's own `dist/` directory and are ignored by Git.
