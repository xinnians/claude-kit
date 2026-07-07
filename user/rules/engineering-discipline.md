# 工程紀律（user-level，跨專案）

> 濃縮自 vchatandroid 71 條 memory feedback（2026-07-07 抽取），只收跨語言/平台成立者。
> 與 user CLAUDE.md 紅線（不猜測、驗證 tag、plan 先行、scope 紀律、不 push）互補不重複。

## Debug

- **先診斷再動手**：user 回報「壞了」→ 第一動作是加 log / grep 重現取證，不是推測 root cause 直接改。
- **假說被推翻 2 次就下沉一層**：runtime 證據連續推翻同層假說 = 抽象層選錯，改讀下層 / 框架 / SDK 源碼，不在同層換角度猜。
- **第三方行為必實測**：SDK / lib 行為以實測或讀其源碼為準，註解與欄位名只是設計意圖；用本機 clone 的依賴源碼前先驗版本是否對齊。
- **收不到事件先加反向 control group**：listener / push / callback 類 debug 先做對稱的反向觀察排除環境偽像，再歸咎 SDK 或寫 workaround。

## 改動前

- **改共享狀態前列全 writer**：先 grep 出所有寫入者建清單再動手。
- **cross-cutting 前 grep 全 caller / consumer**：audit scope 以全庫 grep 為準，self-report ≠ ground truth。
- **schema / sealed / interface 升級 grep 全 consumer** 同步處理：漏 case 往往不會 compile error，只會 silent fail。
- **修 dead code 前先 git log 該檔**：可能是 conscious trade-off（等外部依賴）；註解描述意圖、git log 才是 ground truth。
- **搬運 legacy 前先問對齊**：lift-and-shift 到新架構前先驗這些定義還跟當前 server / SDK 對齊嗎，四不像先 reconcile 再併。

## 驗收

- **Gate 上線必證明有牙**：存量綠 → canary 違規驗紅 → 移除 canary 綠，三拍缺一不可；「存量跑綠」不構成證據（空集合掃描也綠）。掃描式測試額外 assert 掃描集非空。
- **警告揭 pattern 就全掃**：審查警告若是 language / framework 級 root cause，按 pattern 全庫掃，不窄化成單一 location。
- **HEAD vs working tree 分視角**：判「需不需要改」看 HEAD（`git show HEAD:<path>`）、判「最終呈現對不對」看 working tree；多 agent 並行時混用會把他人未 commit 的 Edit 誤判為現況。

## Git

- **commit 前列全變更逐一判斷**是否同一功能範圍，一次 stage 相關檔（含手動改的 import / DI）；用精確路徑不用 `-A`。
- **有 WIP 要隔離用 worktree 不用 checkout -b**（working tree 是 branch-agnostic）：`git worktree add -b <br> <path> HEAD`，base 用當前 HEAD 而非 origin default（遠端可能落後，會靜默拿到過時碼）。

## Claude Code 機制備忘

- 報告落盤用 Write tool，禁 Bash heredoc / cat / echo；寫後 Read 自驗。
- 目錄協作指引寫 CLAUDE.md（受眾是用 AI 工作的人，自動進 context）而非 README（受眾純人類）；兩者不併存。
- hook 注入的 additionalContext 是行動指令不是通知；PostToolUse 時 cwd 已 reset（跨 repo commit 的 hook 描述會張冠李戴）；PreToolUse matcher 對整條命令字串比對不解析 shell（flag 類前置步驟須獨立 Bash 呼叫）。
- meta-process 收集成本 > 收益時提早收尾：被動生效的元素留，需人主動維護的 ceremony 停。
