/**
 * statusbar — one-line status footer.
 *
 *   deepseek-v4.1-flash-1017 off | ~/Dev/ozan/studio-pi4 (main)          ↑12k ↓664 | €0.043 - €50.11 | 41.7%/1M
 *
 * Model and path on the left, tokens/spending/context on the right.
 * Spending comes from the live GreenPT credit balance (X-Credits-Remaining
 * on GET /v1/agents), sampled after each assistant message. The balance is
 * whole-account, so parallel processes on the same key inflate it.
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type {
  ExtensionAPI,
  ExtensionContext,
  ReadonlyFooterDataProvider,
  SessionEntry,
} from "@earendil-works/pi-coding-agent";
import type { TUI } from "@earendil-works/pi-tui";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { isAbsolute, relative, resolve, sep } from "node:path";

// --- constants ---------------------------------------------------------------

const BALANCE_TIMEOUT_MS = 8000;
const LOW_BALANCE_EUR = 1; // remaining: red below this
const WARN_BALANCE_EUR = 5; // remaining: yellow below this
const WARN_CONTEXT_PCT = 70; // context: yellow above this
const HOT_CONTEXT_PCT = 90; // context: red above this

// --- styling helpers ----------------------------------------------------------

const dim = (t: string) => `\x1b[2m${t}\x1b[22m`;
const green = (t: string) => `\x1b[32m${t}\x1b[39m`;
const yellow = (t: string) => `\x1b[33m${t}\x1b[39m`;
const red = (t: string) => `\x1b[31m${t}\x1b[39m`;
const SEP = dim(" | ");

// --- small pure helpers ---------------------------------------------------------

function fmt(n: number): string {
  if (n < 1000) return `${n}`;
  if (n < 10000) return `${(n / 1000).toFixed(1)}k`;
  if (n < 1_000_000) return `${Math.round(n / 1000)}k`;
  return `${(n / 1_000_000).toFixed(1)}M`;
}

function fmtEur(n: number): string {
  return n >= 1 ? `€${n.toFixed(2)}` : `€${n.toFixed(3)}`;
}

function shortCwd(cwd: string, home: string | undefined): string {
  if (!home) return cwd;
  const rel = relative(resolve(home), resolve(cwd));
  const escaped = rel === ".." || rel.startsWith(`..${sep}`) || isAbsolute(rel);
  if (escaped) return cwd;
  return rel === "" ? "~" : `~${sep}${rel}`;
}

/** Usage totals for a session entry, if it has one; null otherwise. */
function entryUsage(e: SessionEntry) {
  if (e.type === "message" && e.message.role === "assistant") {
    return (e.message as AssistantMessage).usage;
  }
  if (e.type === "message" && e.message.role === "toolResult") {
    return e.message.usage;
  }
  if ((e.type === "branch_summary" || e.type === "compaction") && e.usage) {
    return e.usage;
  }
  return undefined;
}

const joinParts = (parts: string[]): string => parts.filter(Boolean).join(SEP);

// --- section builders -------------------------------------------------------------

function buildLeft(
  ctx: ExtensionContext,
  footerData: ReadonlyFooterDataProvider,
): string {
  let modelStr = ctx.model?.id || "no-model";
  if (ctx.model?.reasoning) {
    modelStr += dim(` ${ctx.thinkingLevel ?? "off"}`);
  }
  const cwd = shortCwd(
    ctx.sessionManager.getCwd(),
    process.env.HOME || process.env.USERPROFILE,
  );
  const branch = footerData.getGitBranch();
  return modelStr + SEP + cwd + (branch ? dim(` (${branch})`) : "");
}

function buildRight(ctx: ExtensionContext, balance: BalanceState): string {
  return joinParts([
    tokens(ctx),
    spending(ctx, balance),
    contextPct(ctx),
  ]);
}

function tokens(ctx: ExtensionContext): string {
  let input = 0,
    output = 0;
  for (const e of ctx.sessionManager.getEntries()) {
    const u = entryUsage(e);
    if (u) {
      input += u.input;
      output += u.output;
    }
  }
  let s = "";
  if (input) s += `↑${fmt(input)}`;
  if (output) s += `${s ? " " : ""}↓${fmt(output)}`;
  return s;
}

function spending(ctx: ExtensionContext, balance: BalanceState): string {
  if (ctx.model?.provider !== "greenpt" || balance.lastRemaining === null) {
    return "";
  }
  const remCol = balance.lastRemaining < LOW_BALANCE_EUR
    ? red
    : balance.lastRemaining < WARN_BALANCE_EUR
    ? yellow
    : (t: string) => t;
  return `${fmtEur(balance.spent)}${dim(" - ")}${remCol(
    fmtEur(balance.lastRemaining),
  )}`;
}

function contextPct(ctx: ExtensionContext): string {
  const cu = ctx.getContextUsage();
  const contextWindow = cu?.contextWindow ?? ctx.model?.contextWindow ?? 0;
  const percent = cu?.percent;
  if (percent === null || percent === undefined) {
    return contextWindow > 0 ? dim(`?/${fmt(contextWindow)}`) : "";
  }
  const colored = percent > HOT_CONTEXT_PCT
    ? red
    : percent > WARN_CONTEXT_PCT
    ? yellow
    : green;
  return colored(`${percent.toFixed(1)}%/${fmt(contextWindow)}`);
}

// --- layout ------------------------------------------------------------------------

/** One footer line: left flush left, right flush right; truncated if too narrow. */
function layoutLine(width: number, left: string, right: string): string {
  const gap = width - visibleWidth(left) - visibleWidth(right);
  if (right === "" || gap >= 2) {
    return left + " ".repeat(Math.max(0, gap)) + right;
  }
  return truncateToWidth(left + SEP + right, width, dim("…"));
}

function layoutStatuses(
  width: number,
  footerData: ReadonlyFooterDataProvider,
): string | null {
  const statuses = footerData.getExtensionStatuses();
  if (statuses.size === 0) return null;
  const parts = [...statuses].map(
    ([key, text]) => `${key}: ${text}`,
  ).join(dim("  "));
  return truncateToWidth(parts, width, dim("…"));
}

// --- GreenPT balance -----------------------------------------------------------

interface BalanceState {
  start: number | null;
  lastRemaining: number | null;
  spent: number;
}

function resetBalance(): BalanceState {
  return { start: null, lastRemaining: null, spent: 0 };
}

/** Live balance from GET /v1/agents, or null on any failure. */
async function fetchRemaining(
  baseUrl: string,
  apiKey: string,
): Promise<number | null> {
  try {
    const res = await fetch(`${baseUrl}/agents`, {
      headers: { Authorization: `Bearer ${apiKey}` },
      signal: AbortSignal.timeout(BALANCE_TIMEOUT_MS),
    });
    if (!res.ok) return null;
    const raw = res.headers.get("x-credits-remaining");
    if (raw === null) return null;
    const remaining = Number(raw);
    return Number.isFinite(remaining) ? remaining : null;
  } catch {
    return null; // Transient failure; caller keeps the last values.
  }
}

async function refreshBalance(
  ctx: ExtensionContext,
  balance: BalanceState,
): Promise<void> {
  if (ctx.model?.provider !== "greenpt") return;
  const apiKey = await ctx.modelRegistry.getApiKeyForProvider("greenpt");
  const baseUrl = ctx.model?.baseUrl;
  if (!apiKey || !baseUrl) return;
  const remaining = await fetchRemaining(baseUrl, apiKey);
  if (remaining === null) return;
  if (balance.start === null) balance.start = remaining;
  balance.lastRemaining = remaining;
  balance.spent = Math.max(0, balance.start - remaining);
}

// --- plugin ------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  let footerTui: TUI | null = null;
  const balance = resetBalance();

  pi.on("session_start", async (_event, ctx) => {
    Object.assign(balance, resetBalance());
    ctx.ui.setFooter((tui, _theme, footerData) => {
      footerTui = tui;
      const unsub = footerData.onBranchChange(() => tui.requestRender());
      return {
        dispose: () => {
          unsub();
          footerTui = null;
        },
        invalidate() {},
        render(width: number): string[] {
          const left = buildLeft(ctx, footerData);
          const right = buildRight(ctx, balance);
          const lines = [layoutLine(width, left, right)];
          const statusLine = layoutStatuses(width, footerData);
          if (statusLine) lines.push(statusLine);
          return lines;
        },
      };
    });
    await refreshBalance(ctx, balance);
  });

  pi.on("message_end", async (event, ctx) => {
    if (event.message.role === "assistant") {
      await refreshBalance(ctx, balance);
    }
    footerTui?.requestRender();
  });
}
