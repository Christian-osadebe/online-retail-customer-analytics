# SKILLS_DEMONSTRATED.md — Online Retail Customer Analytics

**Label:** AI-drafted, human-verified.

Concrete AI-for-business-analytics skills demonstrated in this project's `ai-workflow/` folder. Every skill is backed by a file in this folder.

## 1. Prompting, iteration & verification
- **Skill:** Write structured, constraint-based prompts for analytical tasks
  (falsifiable hypotheses, number-locked narratives) and iterate when the AI
  output is vague or overreaching.
- **Evidence:** `PROMPT_LOG.md` — 3 prompts with verbatim text and 4 documented
  iterations, including pushing back on a vague hypothesis and deleting an
  invented customer attribute.

## 2. AI-assisted EDA
- **Skill:** Use AI to draft testable hypotheses at speed, then confirm/refute
  each against executed code — treating AI output as a suspect, not a source.
- **Evidence:** `ai-eda-hypotheses.md` — 7 AI-drafted hypotheses; 3 confirmed,
  2 refuted, 2 nuanced by re-running `python/analysis.py` and pandas checks.
  The refutations yielded the two best insights (wholesale rhythm, November
  stocking peak).

## 3. AI for Excel formulas & KPI narration
- **Skill:** Draft Excel KPI packs (SUMIFS/COUNTIFS/XLOOKUP, nested RFM logic)
  with AI assistance, each formula carrying a "must equal" validation target
  from a trusted output.
- **Evidence:** `ai-excel-kpi-formulas.md` — 5 formulas logic-checked against
  verified outputs (1.71% return rate, 91.43% UK share, 24.93% guest checkout)
  plus a bracketed KPI narration template with a fill-from-verified-outputs rule.

## 4. Research & decision-support memos
- **Skill:** Turn verified findings into decision-ready narratives; use AI to
  draft, then enforce a number-lock (every figure traceable to executed output).
- **Evidence:** `ai-insight-narrative.md` — 400-word manager narrative, 30+
  figures, zero invented numbers or attributes; one invented attribute caught
  and removed in `PROMPT_LOG.md`.

## 5. Business writing for executives
- **Skill:** Structure AI-drafted writing for a decision-maker: headline
  findings first, evidence attached to every claim, prioritized recommendations
  last.
- **Evidence:** `ai-insight-narrative.md` — ends with 3 prioritized, cost-aware
  recommendations (win-back call economics, checkout fix, calendar spend shift).

## 6. Reusable AI workflows with human oversight
- **Skill:** Package the prompting → verification → labeling loop as reusable
  templates with a mandatory pre-ship checklist, so the workflow (not just the
  output) is the skill.
- **Evidence:** `PROMPT_LOG.md` — Templates A/B/C (hypothesis generation,
  verified narrative, verification checklist) designed for copy-paste reuse on
  any dataset.
