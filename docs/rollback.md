# 回滚：dawei.translate 翻译浮层

整套可拆干净，不影响 emoji/clipboard。手装 overlay **不是 git 仓库**。

本文是操作说明。**不要在仍要使用浮层时执行** `omarchy plugin disable` / `remove`。

**禁止**默认跑 `omarchy refresh shell` 或 `omarchy refresh hyprland`（会重置更多用户配置）。除非用户明确同意，否则只用下面的定向步骤。

---

## 1. 快捷键：从 `bindings.lua` 删除 SUPER+SHIFT+T

**路径：** `~/.config/hypr/bindings.lua`

先备份：

```bash
cp ~/.config/hypr/bindings.lua ~/.config/hypr/bindings.lua.bak.$(date +%s)
```

删掉 Translate 绑定（以及紧邻的说明注释，可选）：

```lua
-- Translate overlay (ISS-006 / S7). SUPER SHIFT + T was free; no unbind.
-- SUPER+T (floating) left unchanged.
o.bind("SUPER + SHIFT + T", "Translate", "omarchy-shell shell toggle dawei.translate")
```

或恢复备份：

```bash
# cp ~/.config/hypr/bindings.lua.bak.<ts> ~/.config/hypr/bindings.lua
```

**不要**动相近绑定：`SUPER + T`（浮动窗口）。

然后：

```bash
hyprctl reload
hyprctl configerrors
omarchy menu keybindings --print | rg 'Translate' || echo "binding gone"
```

验收：`configerrors` 空；打印无 `Translate` / 无 `SUPER SHIFT + T → Translate`。

---

## 2. 插件（非 git 手装）

```bash
omarchy plugin disable dawei.translate || true
omarchy plugin remove dawei.translate --yes
```

`--yes` 即可。对**非 git 手装 overlay**：`omarchy plugin remove` 是 **`mv`** 到

```text
~/.config/omarchy/plugins/.dawei.translate.bak.<utc>
```

**不是** `rm -rf` 主路径 `~/.config/omarchy/plugins/dawei.translate`。

第三方扫描只看 `$dir/*/manifest.json`，点目录 `.*.bak.*` 不会被捡起，`plugin list` 里应消失。

**不要**把 `rm -rf` 当 remove 主路径。

若要彻底丢掉备份：确认 list 已无该 id 后，再手动

```bash
rm -rf ~/.config/omarchy/plugins/.dawei.translate.bak.*
```

然后：

```bash
omarchy-shell shell rescanPlugins
omarchy plugin list --json | jq 'any(.[]; .id=="dawei.translate")'
# 期望 false
ls ~/.config/omarchy/plugins/.dawei.translate.bak.* 2>/dev/null || true
```

验收：plugin list 无 `dawei.translate`；插件主目录不在（已 mv 成点备份）或 list 已不扫描它。

---

## 3. CLI symlink（仓库源文件保留）

`~/.local/bin/omarchy-translate` 是指向仓库的符号链接：

```text
~/.local/bin/omarchy-translate
  → /home/dawei/Developer/new_runtime/ocr-translate/bin/omarchy-translate
```

回滚只删 **symlink**，**源在仓库保留**：

```bash
rm -f ~/.local/bin/omarchy-translate
command -v omarchy-translate || echo "omarchy-translate not on PATH"
```

不要 `rm` 仓库里的 `bin/omarchy-translate`（除非连源码也要丢掉）。

验收：`command -v omarchy-translate` 失败。

---

## 4. 密钥文件（按需保留）

路径：`~/.config/omarchy/secrets/deepseek.env`（权限 600）。

- **默认建议保留**，下次重装浮层不用重填 key。
- 若要删除：

```bash
rm -f ~/.config/omarchy/secrets/deepseek.env
# 空目录可留：
# rmdir ~/.config/omarchy/secrets 2>/dev/null || true
```

QML / 插件源码不读该文件。

---

## 5. 验收清单（整套拆完后）

- [ ] `omarchy menu keybindings --print` 无 Translate
- [ ] `omarchy plugin list` 无 `dawei.translate`
- [ ] `command -v omarchy-translate` 失败（仅 PATH symlink 已删；仓库源可仍在）
- [ ] emoji / clipboard 仍可用
- [ ] **没有**跑 `omarchy refresh shell` / `omarchy refresh hyprland`

---

## 不要做

- 不要 `rm -rf ~/.config/omarchy/plugins/dawei.translate` 当官方 remove
- 不要默认 `omarchy refresh shell` / `omarchy refresh hyprland`
- 不要改 `/usr/share/omarchy/`
- 不要在仍使用本插件时执行本节命令
