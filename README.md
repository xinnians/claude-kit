# claude-kit

個人跨專案 Claude Code 配置，抽取自 vchatandroid 專案的制度建設（2026-07-07，P0）。
私人 repo，**保留具名教訓案例**（CHAT-4183 等）當教材——不對外分享；若要分享需先全清洗。

## 安裝（每台電腦一次）

```sh
git clone <repo-url> ~/claude-kit
~/claude-kit/install.sh
```

symlink 部署：之後 `git pull` 即全機生效，不需重跑 install（新增檔案時才重跑）。
install.sh idempotent；會覆蓋的既有檔先備份成 `.bak`。

## 結構與設計原則

```
user/
  rules/    → ~/.claude/rules/    每 session 自動載入（所有專案）→ 有 context tax，合計硬上限 8KB
  refs/     → ~/.claude/refs/     不自動載入，rules 以路徑指向、按需讀取 → 大部頭放這
```

原則（源自 vchatandroid harness 診斷教訓）：**每寫進自動載入檔一行 = 對每個未來 session 收稅**。
新增內容一律先問「能不能放 refs / skill（觸發式）」，rules 只放高頻判斷表。

## 檔案來源對照（回流更新用）

| 本 repo | 源（vchatandroid） | 改寫方式 |
|---|---|---|
| `user/rules/delegation.md` | `.claude/rules/model-dispatch.md` | 去專案 agent 名/指令，SoT 改指 refs |
| `user/rules/engineering-discipline.md` | memory `feedback_*.md` 71 條精選 | 每條壓成 1-2 行+操作法；與 user CLAUDE.md 紅線去重 |
| `user/refs/judgment-rubrics.md` | `docs/ops/judgment-rubrics.md` | 判準保留，範例去專案化 |
| `user/refs/delegation-templates.md` | `docs/ops/delegation-templates.md` | 模板保留，專案鐵律改 `{佔位符}` |
| `user/refs/maintenance-protocol.md` | `docs/ops/maintenance-protocol.md` + `letter-to-future-sessions.md` 精華 | 合併；刪專案交接事項 |

源檔更新後想回流：對照本表 diff 語意差異，手動合入（不要整檔覆蓋——通用版已去專案化）。

## Backlog（P1 / P2，未抽取）

- P1 skills（user-level 觸發式）：config-sync-review、diagnose 骨架、release-version-bump 模式、architecture-map（selective load + staleness gating）、skill-authoring（progressive-disclosure references index + pitfall 模板）
- P1 workflows：caller-consumer-sweep / final-review 通用版
- P2 project-template：CLAUDE.md 骨架（指令優先序+SoT 表）、git-conventions（commit format + Partial-fix-followup trailer）、settings deny 護欄、opsx commands（direct 可搬）、baseline-metrics.sh（direct 可搬）、UNINSTALL sentinel 可逆整合手法
- P2 腳本：headless `claude -p` 排程巡檢骨架（claude-housekeeping / sentry-weekly）、find-unused「宣告→反查→0 hits」策略版

完整盤點依據：vchatandroid session 2026-07-07 的 portability audit（workflow wf_c043fe36-8c6，8 agent 分類＋對抗覆核）。
