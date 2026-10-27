# daylight-editor-flutter

The code editor widget shared by the Daylight apps (Daylight Workbench, Daylight Commander).
It is a vendored fork of [re_editor](https://github.com/reqable/re-editor) 0.10.0 (MIT) —
the package name stays `re_editor` so imports are unchanged.

## What the fork adds

- `CodeEditorStyle.fontFeatures` — turn OpenType ligatures off.
- **Column (block) selection** — Alt/Option + drag selects the same column range on every line.
  `CodeLineEditingController.blockSelection` exposes it; copy, cut, paste, typing, Backspace/Delete and
  IME (Korean) input apply to every row of the block.

See [PATCHES.md](PATCHES.md) for the exact changes (re-apply them when moving to a newer re_editor).

## Use

```yaml
dependencies:
  re_editor:
    git:
      url: https://github.com/jejezz/daylight-editor-flutter
      ref: v0.10.0+1
```

## License

MIT, same as upstream — see [LICENSE](LICENSE) (Copyright (c) 2024 Reqable).
