import { readdir, readFile, writeFile } from "node:fs/promises";
import { execSync } from "node:child_process";
import { join } from "node:path";

type Kind = "swift" | "objc";
type Parsed = { types: Map<string, string[]>; kind: Kind };
type Target = { name: string; note: string; filter?: RegExp };
type Summary = { name: string; types: number; members: number };

const SDK = execSync("xcrun --sdk iphoneos --show-sdk-path", { encoding: "utf8" }).trim();
const FRAMEWORKS = join(SDK, "System/Library/Frameworks");
const OUT = process.argv[2] ?? "AppleIntelligence.md";

const TARGETS: Target[] = [
  {
    name: "FoundationModels",
    note: "On-device LLM (Apple Intelligence core). iOS 26+. Present on ineligible devices but SystemLanguageModel.availability == .unavailable(.deviceNotEligible). Polyfill: mirror API, route to cloud LLM or local MLX/llama.cpp; @Generable → constrained JSON decode.",
  },
  {
    name: "ImagePlayground",
    note: "Image generation + Genmoji. iOS 18.2+. AI-gated. Polyfill: diffusion backend (cloud or CoreML SD).",
  },
  {
    name: "VisualIntelligence",
    note: "Camera/onscreen semantic search. iOS 26+. AI-gated. Polyfill: VisionKit DataScanner + vision model.",
  },
  {
    name: "UIKit",
    filter: /WritingTools|AdaptiveImageGlyph|WritingToolsCoordinator|WritingToolsResult|WritingToolsBehavior/,
    note: "Writing Tools + Genmoji adaptive glyphs — AI-gated subset of UIKit (UIKit itself ships). Polyfill: custom UIMenu → LLM backend; glyphs as NSTextAttachment.",
  },
  {
    name: "AppIntents",
    filter: /AssistantSchema|AssistantIntent|AssistantEntity|AssistantEnum/,
    note: "Assistant schemas (AI Siri) — AI-gated subset of AppIntents (AppIntents itself ships). Polyfill: intent-router LLM.",
  },
];

const clean = (line: string): string =>
  line.replace(/\s+/g, " ").replace(/\s*\{\s*$/, "").trim();

function extractSwift(text: string): Parsed {
  const types = new Map<string, string[]>();
  const add = (t: string, sig?: string) => {
    if (!types.has(t)) types.set(t, []);
    if (sig) types.get(t)!.push(sig);
  };
  const stack: { name: string; depth: number }[] = [];
  const typeRE = /\b(?:public|open)\b.*?\b(struct|class|enum|protocol|actor)\s+(\w+)/;
  const extRE = /\bextension\s+(?:\w+\.)?(\w+)/;
  const memRE = /\b(?:public|open)\b\s+(?:static\s+|class\s+|final\s+|mutating\s+|nonmutating\s+|override\s+|convenience\s+|required\s+|indirect\s+|weak\s+|unowned\s+)*(func|var|let|init|subscript|case|typealias|associatedtype|operator)\b/;
  const caseRE = /^\s*(?:indirect\s+)?case\s+\w+/;
  let depth = 0;

  for (const line of text.split("\n")) {
    const opens = (line.match(/\{/g)?.length ?? 0) - (line.match(/\}/g)?.length ?? 0);
    const tm = typeRE.exec(line);
    const em = extRE.exec(line);
    if (tm) {
      add(tm[2]);
      stack.push({ name: tm[2], depth });
    } else if (em && /\bextension\b/.test(line)) {
      add(em[1]);
      stack.push({ name: em[1], depth });
    } else {
      const top = stack.at(-1)?.name ?? "(global)";
      if (memRE.test(line) || caseRE.test(line)) add(top, clean(line));
    }
    depth += opens;
    while (stack.length && depth <= stack.at(-1)!.depth) stack.pop();
  }
  return { types, kind: "swift" };
}

function extractObjC(text: string): Parsed {
  const types = new Map<string, string[]>();
  const add = (t: string, sig?: string) => {
    if (!types.has(t)) types.set(t, []);
    if (sig) types.get(t)!.push(sig);
  };
  const nested = "(?:[^()]|\\([^()]*\\))*";
  const strip = (l: string): string =>
    l
      .replace(new RegExp(`\\b(?:API_AVAILABLE|API_UNAVAILABLE|API_DEPRECATED(?:_WITH_REPLACEMENT)?|API_DEPRECATED_BEGIN)\\s*\\(${nested}\\)`, "g"), "")
      .replace(new RegExp(`\\bNS_[A-Z_]+\\s*(?:\\(${nested}\\))?`, "g"), "")
      .replace(/\s+/g, " ")
      .replace(/[;,]\s*$/, "")
      .trim();
  let cur: string | null = null;

  for (const raw of text.split("\n")) {
    const line = raw.trim();
    const iface = /^@interface\s+(\w+)/.exec(line) ?? /^@protocol\s+(\w+)/.exec(line);
    if (iface) {
      cur = iface[1];
      add(cur);
    } else if (/^@end/.test(line)) {
      cur = null;
    } else if (cur && /^@property/.test(line)) {
      add(cur, strip(line));
    } else if (cur && /^[-+]\s*\(/.test(line)) {
      add(cur, strip(line));
    }
  }
  return { types, kind: "objc" };
}

async function parse(name: string): Promise<Parsed | null> {
  const base = join(FRAMEWORKS, `${name}.framework`);
  const modules = join(base, "Modules", `${name}.swiftmodule`);
  const iface = (await readdir(modules).catch(() => [])).find((x) => /arm64.*\.swiftinterface$/.test(x));
  if (iface) return extractSwift(await readFile(join(modules, iface), "utf8"));

  const headers = join(base, "Headers");
  const files = (await readdir(headers).catch(() => [])).filter((f) => f.endsWith(".h"));
  if (!files.length) return null;
  let src = "";
  for (const h of files) src += (await readFile(join(headers, h), "utf8")) + "\n";
  return extractObjC(src);
}

function render(target: Target, parsed: Parsed): { md: string; types: number; members: number } {
  const { filter } = target;
  const names = [...parsed.types.keys()]
    .sort()
    .filter((t) => !filter || filter.test(t) || parsed.types.get(t)!.some((s) => filter.test(s)));

  let types = 0;
  let members = 0;
  let body = "";
  for (const t of names) {
    const sigs = [...new Set(parsed.types.get(t))].sort();
    if (filter && !sigs.length && !filter.test(t)) continue;
    types++;
    body += `\n### [ ] \`${t}\` — ${sigs.length} member${sigs.length === 1 ? "" : "s"}\n\n`;
    for (const sig of sigs) {
      members++;
      body += `- [ ] \`${sig}\`\n`;
    }
  }

  const kind = parsed.kind === "swift" ? "Swift (.swiftinterface)" : "ObjC (headers)";
  const scope = filter ? ` · filtered subset \`${filter.source}\`` : " · full framework";
  const head =
    `\n\n---\n\n## ${target.name}${filter ? " (AI subset)" : ""}\n\n> ${target.note}\n\n` +
    `Source: ${SDK.split("/").pop()} · ${kind}${scope}\n\nTypes: ${types} · Members: ${members}\n`;
  return { md: head + body, types, members };
}

async function main(): Promise<void> {
  let out =
    `# Apple Intelligence — polyfill API checklist\n\n` +
    `Target: real iOS. Scope: only Apple-Intelligence-capability-gated APIs Apple ` +
    `disables on ineligible/old devices. All other SDK frameworks ship to the device ` +
    `and are NOT listed here.\n\n` +
    `Source: \`${SDK.split("/").pop()}\` · real arm64e \`.swiftinterface\`. ` +
    `All boxes unchecked = polyfill TODO.\n`;

  const summary: Summary[] = [];
  for (const target of TARGETS) {
    const parsed = await parse(target.name);
    if (!parsed) continue;
    const { md, types, members } = render(target, parsed);
    out += md;
    summary.push({ name: target.name + (target.filter ? " (AI subset)" : ""), types, members });
  }

  const totalTypes = summary.reduce((a, b) => a + b.types, 0);
  const totalMembers = summary.reduce((a, b) => a + b.members, 0);
  const index =
    `\n| Framework | Types | Members |\n|---|--:|--:|\n` +
    summary.map((s) => `| ${s.name} | ${s.types} | ${s.members} |`).join("\n") +
    `\n| **TOTAL** | **${totalTypes}** | **${totalMembers}** |\n`;

  const splitAt = out.indexOf("\n\n---");
  await writeFile(OUT, out.slice(0, splitAt) + "\n" + index + out.slice(splitAt));
}

await main();
