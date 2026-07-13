// gen-ai-checklist — Apple Intelligence polyfill checklist (real iOS target).
// Lists ONLY the Apple-Intelligence-capability-gated API surface that Apple disables
// on ineligible/old devices — the polyfill targets. Everything else in the SDK ships
// to the device already. Parses real arm64e .swiftinterface from the iOS SDK.
// Output: one consolidated AppleIntelligence.md
import { readdir, readFile, writeFile } from 'node:fs/promises';
import { execSync } from 'node:child_process';
import { join } from 'node:path';

const SDK = execSync('xcrun --sdk iphoneos --show-sdk-path', { encoding: 'utf8' }).trim();
const FW = join(SDK, 'System/Library/Frameworks');
const OUT = process.argv[2] || '/tmp/AppleIntelligence.md';

// ── extractors (verbatim from gen-checklist.mjs) ────────────────────────────────
function extractSwift(text) {
  const types = new Map();
  const add = (t, sig) => { if (!types.has(t)) types.set(t, []); if (sig) types.get(t).push(sig); };
  const stack = [];
  let depth = 0;
  const typeRE = /\b(?:public|open)\b.*?\b(struct|class|enum|protocol|actor)\s+(\w+)/;
  const extRE = /\bextension\s+(?:\w+\.)?(\w+)/;
  const memRE = /\b(?:public|open)\b\s+(?:static\s+|class\s+|final\s+|mutating\s+|nonmutating\s+|override\s+|convenience\s+|required\s+|indirect\s+|weak\s+|unowned\s+)*(func|var|let|init|subscript|case|typealias|associatedtype|operator)\b/;
  const caseRE = /^\s*(?:indirect\s+)?case\s+\w+/;
  const clean = (l) => l.replace(/\s+/g, ' ').replace(/\s*\{\s*$/, '').replace(/\s*$/, '').trim();
  for (const raw of text.split('\n')) {
    const line = raw;
    const opensThis = (line.match(/\{/g) || []).length - (line.match(/\}/g) || []).length;
    const tm = typeRE.exec(line);
    const em = extRE.exec(line);
    if (tm) { add(tm[2], null); stack.push({ name: tm[2], depth }); }
    else if (em && /\bextension\b/.test(line)) { add(em[1], null); stack.push({ name: em[1], depth }); }
    else {
      const top = stack.length ? stack[stack.length - 1].name : '(global)';
      if (memRE.test(line) || caseRE.test(line)) add(top, clean(line));
    }
    depth += opensThis;
    while (stack.length && depth <= stack[stack.length - 1].depth) stack.pop();
  }
  return { types, kind: 'swift' };
}
function extractObjC(text) {
  const types = new Map();
  const add = (t, sig) => { if (!types.has(t)) types.set(t, []); if (sig) types.get(t).push(sig); };
  let cur = null;
  const nested = '(?:[^()]|\\([^()]*\\))*';
  const strip = (l) => l
    .replace(new RegExp(`\\b(?:API_AVAILABLE|API_UNAVAILABLE|API_DEPRECATED(?:_WITH_REPLACEMENT)?|API_DEPRECATED_BEGIN)\\s*\\(${nested}\\)`, 'g'), '')
    .replace(new RegExp(`\\bNS_[A-Z_]+\\s*(?:\\(${nested}\\))?`, 'g'), '')
    .replace(/\s+/g, ' ').replace(/[;,]\s*$/, '').trim();
  for (const raw of text.split('\n')) {
    const line = raw.trim();
    let m;
    if ((m = /^@interface\s+(\w+)/.exec(line))) { cur = m[1]; add(cur, null); continue; }
    if ((m = /^@protocol\s+(\w+)/.exec(line))) { cur = m[1]; add(cur, null); continue; }
    if (/^@end/.test(line)) { cur = null; continue; }
    if (!cur) continue;
    if (/^@property/.test(line)) add(cur, strip(line));
    else if (/^[-+]\s*\(/.test(line)) add(cur, strip(line));
  }
  return { types, kind: 'objc' };
}

async function parseFramework(name) {
  const base = join(FW, `${name}.framework`);
  const mods = join(base, 'Modules', `${name}.swiftmodule`);
  const modFiles = await readdir(mods).catch(() => []);
  const iface = modFiles.find(x => /arm64.*\.swiftinterface$/.test(x));
  if (iface) return extractSwift(await readFile(join(mods, iface), 'utf8'));
  const hdir = join(base, 'Headers');
  const hfiles = (await readdir(hdir).catch(() => [])).filter(f => f.endsWith('.h'));
  if (hfiles.length) {
    let src = '';
    for (const h of hfiles) src += await readFile(join(hdir, h), 'utf8') + '\n';
    return extractObjC(src);
  }
  return null;
}

// ── target set ──────────────────────────────────────────────────────────────────
// SCOPE: real-iOS polyfill for Apple-Intelligence-CAPABILITY-GATED APIs only.
// Shared frameworks (Vision, Speech, Translation, NaturalLanguage, full AppIntents)
// ship & work on ineligible/old devices → already present, NOT polyfill targets.
// Only the frameworks Apple disables on ineligible hardware are listed here.
// full: entire framework is AI-gated. filter: gated subset inside a shipped framework
// (keep types whose name OR any member signature matches the regex).
const TARGETS = [
  { name: 'FoundationModels', note: 'On-device LLM (Apple Intelligence core). iOS 26+. Present on ineligible devices but SystemLanguageModel.availability == .unavailable(.deviceNotEligible). Polyfill: mirror API, route to cloud LLM or local MLX/llama.cpp; @Generable → constrained JSON decode.' },
  { name: 'ImagePlayground', note: 'Image generation + Genmoji. iOS 18.2+. AI-gated. Polyfill: diffusion backend (cloud or CoreML SD).' },
  { name: 'VisualIntelligence', note: 'Camera/onscreen semantic search. iOS 26+. AI-gated. Polyfill: VisionKit DataScanner + vision model.' },
  { name: 'UIKit', filter: /WritingTools|AdaptiveImageGlyph|WritingToolsCoordinator|WritingToolsResult|WritingToolsBehavior/, note: 'Writing Tools + Genmoji adaptive glyphs — AI-gated subset of UIKit (UIKit itself ships). Polyfill: custom UIMenu → LLM backend; glyphs as NSTextAttachment.' },
  { name: 'AppIntents', filter: /AssistantSchema|AssistantIntent|AssistantEntity|AssistantEnum/, note: 'Assistant schemas (AI Siri) — AI-gated subset of AppIntents (AppIntents itself ships). Polyfill: intent-router LLM.' },
];

function renderFramework(name, parsed, note, filterRE) {
  let typeNames = [...parsed.types.keys()].sort();
  if (filterRE) {
    typeNames = typeNames.filter(t => filterRE.test(t) ||
      (parsed.types.get(t) || []).some(s => filterRE.test(s)));
  }
  let nTypes = 0, nMembers = 0, body = '';
  for (const t of typeNames) {
    const sigs = [...new Set(parsed.types.get(t))].sort();
    if (filterRE && sigs.length === 0 && !filterRE.test(t)) continue;
    nTypes++;
    body += `\n### [ ] \`${t}\` — ${sigs.length} member${sigs.length === 1 ? '' : 's'}\n\n`;
    for (const sig of sigs) { nMembers++; body += `- [ ] \`${sig}\`\n`; }
  }
  const kind = parsed.kind === 'swift' ? 'Swift (.swiftinterface)' : 'ObjC (headers)';
  const scope = filterRE ? ` · filtered subset \`${filterRE.source}\`` : ' · full framework';
  const head = `\n\n---\n\n## ${name}${filterRE ? ' (AI subset)' : ''}\n\n` +
    `> ${note}\n\n` +
    `Source: ${SDK.split('/').pop()} · ${kind}${scope}\n\n` +
    `Types: ${nTypes} · Members: ${nMembers}\n`;
  return { md: head + body, nTypes, nMembers };
}

async function main() {
  let out = `# Apple Intelligence — polyfill API checklist\n\n` +
    `Target: real iOS. Scope: only Apple-Intelligence-capability-gated APIs Apple ` +
    `disables on ineligible/old devices. All other SDK frameworks ship to the device ` +
    `and are NOT listed here.\n\n` +
    `Source: \`${SDK.split('/').pop()}\` · real arm64e \`.swiftinterface\`. ` +
    `All boxes unchecked = polyfill TODO.\n`;
  const summary = [];
  for (const t of TARGETS) {
    const parsed = await parseFramework(t.name);
    if (!parsed) { console.log(`SKIP ${t.name}: not found`); continue; }
    const { md, nTypes, nMembers } = renderFramework(t.name, parsed, t.note, t.filter);
    out += md;
    summary.push({ name: t.name + (t.filter ? ' (AI subset)' : ''), nTypes, nMembers });
    console.log(`${t.name}: ${nTypes} types, ${nMembers} members`);
  }
  // index table at top (insert after header)
  let idx = `\n| Framework | Types | Members |\n|---|--:|--:|\n`;
  for (const s of summary) idx += `| ${s.name} | ${s.nTypes} | ${s.nMembers} |\n`;
  idx += `| **TOTAL** | **${summary.reduce((a,b)=>a+b.nTypes,0)}** | **${summary.reduce((a,b)=>a+b.nMembers,0)}** |\n`;
  out = out.replace(/\n$/, '') + '\n' + idx + out.slice(out.indexOf('\n\n---'));
  await writeFile(OUT, out);
  console.log(`\nWrote ${OUT}`);
}
main();
