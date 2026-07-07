# 派工與模型調度守則（user-level，跨專案）

> 通用版，源自 vchatandroid `.claude/rules/model-dispatch.md`（2026-07-07 抽取）。
> 完整判準：`~/.claude/refs/judgment-rubrics.md`；派工模板五式：`~/.claude/refs/delegation-templates.md`。
> 優先序：user CLAUDE.md 紅線與各專案 project rules > 本檔。

## 1. 指揮官不下場

主對話（PM）的 context 是最貴的資源，只進「結論」，不進「原料」。命中任一 → 派 subagent，不自己動手：

| 情況 | 派給 |
|---|---|
| 預計 Read > 3 個檔案、或單檔 > 400 行且只為找答案 | Explore（唯讀） |
| grep 疊代 > 2 輪還沒收斂 | Explore |
| WebSearch / 多輪 WebFetch 的外部調查 | general-purpose |
| 批次機械改檔（≥ 3 處同模式） | general-purpose |
| 審查 / 驗收 / read-back | fresh general-purpose（或該專案的唯讀審查角色） |

留 inline 的例外：單點查證（< 100 行）、讀完立刻要 Edit 的同一檔、拍板與仲裁（判斷不外包，只外包收集）。

## 2. 派工三件套 + 回報合約

每次派工 prompt 必含：**目標與動機**、**驗收條件**（可觀察、可證偽）、**回報格式**。缺一件時 subagent 失敗不計入模型失敗次數——先補齊重派。

回報合約（寫進每個派工 prompt）：只回結論 + `檔案:行號`；長產物 Write 落檔回傳路徑；禁貼整檔內容回主對話。**防偽引用**：驗收條件要求回報引用檔內具體原文（如某節第一句），空殼引用立刻穿幫。涉及 enum / sealed / 簽名 / API 行為的派工，先 grep ground truth 塞進 prompt——錯誤前提 fan-out 會被 N 個平行 agent 一致背書（CHAT-4183 教訓）。

## 3. model 與 effort 顯式指定

| 任務 | model |
|---|---|
| 機械枚舉、格式轉換、有完整 spec 的批次套用 | haiku |
| 搜尋盤點、實作、測試、審查、外部研究（預設工作馬） | sonnet |
| 架構設計、跨 ≥ 3 模組取捨、需求歧義拆解、連錯後的救援 | opus |

專案若在 `.claude/agents/*.md` frontmatter 鎖定 model / effort，用該 agent 不需再指定。Agent tool 無 per-call effort（繼承 session）；Workflow `agent()` 有 `effort` 參數——機械 stage 用 `low`，verify / judge stage 用 `high` 以上。

## 4. 升降級路徑（完整判準見 refs/judgment-rubrics.md）

- haiku 驗收不過 1 次 → 升 sonnet；sonnet 同一子任務不過 2 次 → 升 opus，prompt 附完整失敗軌跡。
- opus 解出可重複模式 → 寫成明確步驟（改前/改後/邊界例），降級批次套用。
- 同一件事「同層同法微調」最多兩輪；第三輪必須換路 = 換抽象層 / 重新診斷 / 升級模型（帶失敗軌跡）/ 問 user 之一。

## 5. 驗證不自驗

做事的 agent 不能當驗收的 agent。宣稱完成前：

- 檔案產出 → fresh agent read-back，對驗收條件逐項 PASS/FAIL（要求引用檔內原文，防假 Read）。
- 程式碼 → 測試或實跑（測試指令見各專案 project rules），不是「看起來對」。編譯綠 ≠ 完成。
- 高風險判斷 → 第二意見（另一 agent 從對立立場攻擊）或多答案評審選優。
- 「已刪除 / 已歸零」類聲稱 → 反向 grep 證明。
