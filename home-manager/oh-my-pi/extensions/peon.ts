/**
 * peon-ping for oh-my-pi (omp) — Lightweight sound pack player
 *
 * Reads the CESP/OpenPeon active pack from ~/.openpeon/ and plays
 * random sound clips on lifecycle events using macOS afplay.
 *
 * Pack management (install, list, switch) is handled by the peon CLI:
 *   brew install PeonPing/tap/peon-ping
 *   peon packs install jarvis-mk2
 *   peon packs use jarvis-mk2
 *
 * Directory layout:
 *   ~/.openpeon/
 *     config.json          { default_pack: "jarvis-mk2", volume: 0.5 }
 *     packs/<pack>/
 *       openpeon.json      CESP manifest
 *       sounds/*.mp3|*.wav Clip files
 */

import * as fs from "node:fs/promises";
import * as path from "node:path";
import * as os from "node:os";
import { spawn } from "node:child_process";
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

// ── Constants ────────────────────────────────────────────────────────

const OPENPEON_DIR = path.join(os.homedir(), ".openpeon");
const CONFIG_PATH = path.join(OPENPEON_DIR, "config.json");
const PACKS_DIR = path.join(OPENPEON_DIR, "packs");
const DEFAULT_PACK = "jarvis-mk2";

// ── Types ────────────────────────────────────────────────────────────

interface PackManifest {
  categories?: Record<string, { sounds: Array<{ file: string }> }>;
}

interface PeonConfig {
  default_pack?: string;
  volume?: number;
}

// ── Helpers (pure, async) ────────────────────────────────────────────

/** Read and parse a JSON file, returning undefined on failure. */
const readJson = async <T>(filePath: string): Promise<T | undefined> => {
  try {
    const raw = await fs.readFile(filePath, "utf-8");
    return JSON.parse(raw) as T;
  } catch {
    return undefined;
  }
};

/** Resolve the active pack name from config or fallback to default. */
const getActivePack = async (): Promise<string> => {
  const cfg = await readJson<PeonConfig>(CONFIG_PATH);
  return cfg?.default_pack ?? DEFAULT_PACK;
};

/** Read pack manifest for a given pack name, or undefined. */
const readManifest = async (packName: string): Promise<PackManifest | undefined> =>
  readJson<PackManifest>(path.join(PACKS_DIR, packName, "openpeon.json"));

/** Get a random sound file path for a CESP category, or null. */
const pickSound = async (packName: string, category: string): Promise<string | null> => {
  const manifest = await readManifest(packName);
  const sounds = manifest?.categories?.[category]?.sounds;
  if (!sounds?.length) return null;

  const entry = sounds[Math.floor(Math.random() * sounds.length)];
  return path.join(PACKS_DIR, packName, entry.file);
};

/** Return true if file exists at the given path. */
const fileExists = async (filePath: string): Promise<boolean> => {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
};

/** Play a sound file asynchronously using afplay. */
const playSound = (filePath: string): void => {
  try {
    const proc = spawn("afplay", [filePath], { stdio: "ignore" });
    proc.unref();
  } catch {
    // silently ignore playback failures
  }
};

/** Dispatch: resolves active pack and plays a random sound for the category. */
const play = async (category: string): Promise<void> => {
  const pack = await getActivePack();
  const file = await pickSound(pack, category);
  if (file && (await fileExists(file))) playSound(file);
};

// ── Extension Entry Point ────────────────────────────────────────────

export default (pi: ExtensionAPI): void => {
  getActivePack().then((pack) => console.log(`[peon] active pack: ${pack}`));

  pi.on("session_start", async () => play("session.start"));
  pi.on("turn_end", async () => play("task.complete"));
  pi.on("tool_result", async (event) => {
    if (event.isError) await play("task.error");
  });
  pi.on("auto_compaction_start", async () => play("resource.limit"));
  pi.on("session_shutdown", async () => play("session.end"));
};
