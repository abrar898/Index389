"use client";

import React, { useState, useEffect, useRef } from "react";
import {
  Terminal as TerminalIcon,
  Play,
  Pause,
  RotateCcw,
  Volume2,
  VolumeX,
  FastForward,
  Copy,
  Check,
  Flame,
  ShieldAlert,
  Sparkles,
  Music,
} from "lucide-react";
import { cyberAudio } from "@/lib/cyber-audio";

interface ScriptStep {
  type: "prompt" | "output" | "success" | "warning" | "error" | "hex" | "flag" | "header" | "info";
  text: string;
  delayMs?: number;
}

const HACKER_SCRIPT: ScriptStep[] = [
  // Scene 1: Network Infiltration & Target Recon
  { type: "header", text: "=== ENGAGEMENT #9042 // INITIATING TARGET ACQUISITION ===" },
  { type: "prompt", text: "operator@fsociety:~$ nmap -sS -sV -T4 --min-rate 2500 10.129.201.55" },
  { type: "output", text: "Starting Nmap 7.94 ( https://nmap.org ) at 01:23:44 UTC" },
  { type: "output", text: "Initiating SYN Stealth Scan against 10.129.201.55 [65535 ports]" },
  { type: "success", text: "Discovered open port 22/tcp on 10.129.201.55 (OpenSSH 8.9p1)" },
  { type: "success", text: "Discovered open port 80/tcp on 10.129.201.55 (Apache httpd 2.4.52)" },
  { type: "warning", text: "Discovered open port 8080/tcp on 10.129.201.55 (Apache Tomcat/9.0.43)" },
  { type: "success", text: "Discovered open port 3306/tcp on 10.129.201.55 (MySQL 8.0.35)" },
  { type: "output", text: "Scanning completed in 1.84s. 4 open services identified." },

  // Scene 2: Vulnerability Analysis & Ghostcat CVE Check
  { type: "prompt", text: "operator@fsociety:~$ searchsploit 'Apache Tomcat 9.0.43' --cve" },
  { type: "output", text: "[*] Querying Offensive Security Exploit Database..." },
  { type: "error", text: "[CRITICAL] Apache Tomcat - AJP 'Ghostcat' File Read/Inclusion (CVE-2020-1938)" },
  { type: "warning", text: "[HIGH] Apache HTTP Server 2.4.52 - Path Traversal & Remote Code (CVE-2021-41773)" },

  // Scene 3: Memory Inspection & ROP Chain Staging (Mr. Robot Hex Stream)
  { type: "header", text: "=== CRAFTING BINARY PAYLOAD // ROP CHAIN COMPILATION ===" },
  { type: "prompt", text: "operator@fsociety:~$ ropgadget --binary /opt/srv_auth --ropchain" },
  { type: "output", text: "[*] Analyzing executable sections for gadget alignment..." },
  { type: "hex", text: "0x7fff5fbff8b0:  48 31 c0 48 89 c2 48 89 c6 48 8d 3d 04 00 00 00  |H1.H..H..H.=....|" },
  { type: "hex", text: "0x7fff5fbff8c0:  04 3b 0f 05 2f 62 69 6e 2f 73 68 00 90 90 90 90  |.;../bin/sh.....|" },
  { type: "hex", text: "0x7fff5fbff8d0:  ff e4 00 00 7f 00 00 00 00 11 40 00 00 00 00 00  |..........@.....|" },
  { type: "success", text: "[+] Stack pivot verified: POP RDI (0x4011d3) -> /bin/sh -> EXECVE (0x401030)" },
  { type: "output", text: "[+] Payload staged: 384 bytes. Canary bypass: 0xDEADBEEFCAFE" },

  // Scene 4: Password Cracking Matrix (Instagram Reels / Movie GPU Cracking)
  { type: "header", text: "=== RECOVERING CACHED AUTHENTICATION HASHES ===" },
  { type: "prompt", text: "operator@fsociety:~$ hashcat -m 0 -a 0 hashes.txt /usr/share/wordlists/rockyou.txt" },
  { type: "output", text: "Session..........: hashcat" },
  { type: "output", text: "Status...........: Running" },
  { type: "warning", text: "Hash.Mode........: 0 (MD5)" },
  { type: "output", text: "Speed.#1.........: 14.82 GH/s (NVIDIA RTX 4090 Core Temp: 68C)" },
  { type: "output", text: "Progress.........: 8941209/14344384 (62.3%)" },
  { type: "success", text: "7d0d0e6a32d1656c07:winter2026!  [RECOVERED: administrator]" },
  { type: "success", text: "e10adc3949ba59abbe:cybersec2026   [RECOVERED: lead_operator]" },
  { type: "output", text: "[+] Dictionary attack completed: 2/2 target hashes cracked in 0.94s." },

  // Scene 5: Exploitation & Remote Shell Interception
  { type: "header", text: "=== STAGING LISTENER & SENDING FINAL EXPLOIT ===" },
  { type: "prompt", text: "operator@fsociety:~$ nc -lvnp 4444 &" },
  { type: "output", text: "[1] 41920" },
  { type: "output", text: "Listening on [0.0.0.0] (family 0, port 4444)..." },
  { type: "prompt", text: "operator@fsociety:~$ python3 exploit_ghostcat.py 10.129.201.55 -p 8080 --inject-shell" },
  { type: "output", text: "[*] Establishing raw AJP connection to 10.129.201.55:8009..." },
  { type: "output", text: "[*] Crafting ForwardRequest packet with malicious attributes..." },
  { type: "output", text: "[*] Triggering servlet filter deserialization chain..." },
  { type: "warning", text: "[+] WAF bypass technique: Chunked Transfer Encoding succeeded (HTTP 200)" },
  { type: "success", text: "[+] Connection received from 10.129.201.55:49182 !" },
  { type: "success", text: "[+] PTY terminal allocated: /dev/pts/3 (TERM=xterm-256color)" },

  // Scene 6: Root Privilege Escalation & Flag Capture
  { type: "header", text: "=== POST-EXPLOITATION & ROOT PRIVILEGE ESCALATION ===" },
  { type: "prompt", text: "tomcat@e-corp-srv01:~$ whoami && id" },
  { type: "output", text: "tomcat uid=1001(tomcat) gid=1001(tomcat) groups=1001(tomcat)" },
  { type: "prompt", text: "tomcat@e-corp-srv01:~$ sudo -l" },
  { type: "output", text: "Matching Defaults entries for tomcat on e-corp-srv01:" },
  { type: "warning", text: "    (ALL : ALL) NOPASSWD: /usr/bin/find" },
  { type: "prompt", text: "tomcat@e-corp-srv01:~$ sudo /usr/bin/find . -exec /bin/sh -p \\; -quit" },
  { type: "prompt", text: "root@e-corp-srv01:~# whoami && id" },
  { type: "success", text: "root uid=0(root) gid=0(root) groups=0(root) // FULL SYSTEM COMPROMISE" },
  { type: "prompt", text: "root@e-corp-srv01:~# cat /root/root.txt" },
  { type: "flag", text: "[★] PROOF OF CONCEPT FLAG: HTB{mr_r0b0t_3v1l_c0rp_pwn3d_89f02a}" },

  // Scene 7: Sanitization & Log Wiping
  { type: "header", text: "=== DISK SANITIZATION & FORENSIC LOG PURGE ===" },
  { type: "prompt", text: "root@e-corp-srv01:~# shred -u -z -n 5 /var/log/auth.log /tmp/payload*" },
  { type: "success", text: "[✓] 5-pass cryptographic wipe complete. Traces eliminated." },
  { type: "info", text: "[*] Session closed. Switching to next CIDR block..." },
  { type: "output", text: "================================================================" },
];

export function InteractiveTerminal() {
  const [lines, setLines] = useState<ScriptStep[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isPlaying, setIsPlaying] = useState(true);
  const [speedMultiplier, setSpeedMultiplier] = useState<number>(1); // 1 = Cinematic, 2 = Reels, 3 = Insane
  const [soundEnabled, setSoundEnabled] = useState(false);
  const [isMusicPlaying, setIsMusicPlaying] = useState(false);
  const [recSeconds, setRecSeconds] = useState(148);
  const [copied, setCopied] = useState(false);

  // Manual interactive shell mode
  const [isManualMode, setIsManualMode] = useState(false);
  const [manualInput, setManualInput] = useState("");
  const inputRef = useRef<HTMLInputElement>(null);
  const terminalBodyRef = useRef<HTMLDivElement>(null);

  // Stop music on unmount
  useEffect(() => {
    return () => {
      cyberAudio.stopMusic();
    };
  }, []);

  const handleToggleMusic = () => {
    const active = cyberAudio.toggleMusic();
    setIsMusicPlaying(active);
  };

  const handleToggleSound = () => {
    const next = !soundEnabled;
    setSoundEnabled(next);
    if (next) {
      cyberAudio.init();
      cyberAudio.playKeyClick("flag");
    }
  };

  // Timer counter for recording indicator (00:02:28)
  useEffect(() => {
    const timer = setInterval(() => {
      setRecSeconds((prev) => prev + 1);
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  // Main streaming loop for cinematic Hacker Reel experience
  useEffect(() => {
    if (!isPlaying || isManualMode) return;

    const baseDelay =
      HACKER_SCRIPT[currentIndex]?.type === "header"
        ? 800
        : HACKER_SCRIPT[currentIndex]?.type === "prompt"
        ? 600
        : HACKER_SCRIPT[currentIndex]?.type === "hex"
        ? 150
        : HACKER_SCRIPT[currentIndex]?.type === "flag"
        ? 1200
        : 280;

    const delay = Math.max(80, baseDelay / speedMultiplier);

    const timer = setTimeout(() => {
      const step = HACKER_SCRIPT[currentIndex];
      if (step) {
        setLines((prev) => [...prev, step]);
        if (soundEnabled) {
          cyberAudio.playKeyClick(step.type);
        }
      }

      // Loop back to start when sequence finishes for non-stop reel
      if (currentIndex >= HACKER_SCRIPT.length - 1) {
        setTimeout(() => {
          setLines([]);
          setCurrentIndex(0);
        }, 1500);
      } else {
        setCurrentIndex((prev) => prev + 1);
      }
    }, delay);

    return () => clearTimeout(timer);
  }, [currentIndex, isPlaying, speedMultiplier, isManualMode, soundEnabled]);

  // Keep auto-scroll locked to bottom of terminal
  useEffect(() => {
    if (terminalBodyRef.current) {
      terminalBodyRef.current.scrollTop = terminalBodyRef.current.scrollHeight;
    }
  }, [lines]);

  const handleCopy = () => {
    const text = lines.map((l) => l.text).join("\n");
    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const resetStream = () => {
    setLines([]);
    setCurrentIndex(0);
    setIsPlaying(true);
    setIsManualMode(false);
  };

  const handleManualSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!manualInput.trim()) return;

    setLines((prev) => [
      ...prev,
      { type: "prompt", text: `operator@fsociety:~$ ${manualInput}` },
      { type: "success", text: `[+] Executing: ${manualInput} ... Complete.` },
    ]);
    setManualInput("");
  };

  const formatRecTime = (sec: number) => {
    const m = Math.floor(sec / 60);
    const s = sec % 60;
    return `00:${m < 10 ? "0" : ""}${m}:${s < 10 ? "0" : ""}${s}`;
  };

  return (
    <div className="relative rounded-2xl bg-[#060b13] border border-[#1e3a8a]/70 hover:border-[#2563eb]/60 shadow-[0_4px_24px_rgba(2,6,23,0.7)] overflow-hidden font-mono text-xs transition-colors">
      {/* Top Hacker Movie / Instagram Reels Status HUD */}
      <div className="px-4 py-3 bg-[#08101e] border-b border-[#1e293b] flex flex-wrap items-center justify-between gap-3 select-none relative z-20">
        <div className="flex items-center gap-3">
          {/* OS Window Controls */}
          <div className="flex items-center gap-1.5">
            <span className="w-3 h-3 rounded-full bg-[#f85149] inline-block shadow-sm" />
            <span className="w-3 h-3 rounded-full bg-[#eab308] inline-block shadow-sm" />
            <span className="w-3 h-3 rounded-full bg-[#22c55e] inline-block shadow-sm" />
          </div>

          {/* Live Recording Reel HUD */}
          <div className="flex items-center gap-2 pl-2 border-l border-[#1e293b]">
            <span className="flex items-center gap-1.5 px-2 py-0.5 rounded bg-[#f85149]/15 text-[#f85149] border border-[#f85149]/30 text-[10px] font-bold">
              <span className="w-2 h-2 rounded-full bg-[#f85149] animate-ping" />
              <span>REC {formatRecTime(recSeconds)}</span>
            </span>

            <span className="hidden sm:inline-block text-[11px] text-[#8ba0c3]">
              TARGET: <strong className="text-[#9fef00]">10.129.201.55 (E-CORP)</strong>
            </span>
          </div>
        </div>

        {/* Cinematic Controls */}
        <div className="flex items-center gap-2">
          {/* Speed Selector */}
          <div className="flex items-center gap-1 bg-[#14233c] p-0.5 rounded-lg border border-[#1f3352] text-[10px]">
            <button
              type="button"
              onClick={() => setSpeedMultiplier(1)}
              className={`px-2 py-0.5 rounded transition-colors cursor-pointer ${
                speedMultiplier === 1
                  ? "bg-[#9fef00] text-[#0b121e] font-bold"
                  : "text-[#8ba0c3] hover:text-[#ffffff]"
              }`}
              title="1x Cinematic Mr. Robot Pace"
            >
              1x Movie
            </button>
            <button
              type="button"
              onClick={() => setSpeedMultiplier(2)}
              className={`px-2 py-0.5 rounded transition-colors cursor-pointer ${
                speedMultiplier === 2
                  ? "bg-[#9fef00] text-[#0b121e] font-bold"
                  : "text-[#8ba0c3] hover:text-[#ffffff]"
              }`}
              title="2x Fast Reel Mode"
            >
              2x Reel
            </button>
            <button
              type="button"
              onClick={() => setSpeedMultiplier(4)}
              className={`px-2 py-0.5 rounded transition-colors cursor-pointer ${
                speedMultiplier === 4
                  ? "bg-[#9fef00] text-[#0b121e] font-bold"
                  : "text-[#8ba0c3] hover:text-[#ffffff]"
              }`}
              title="4x Matrix Speed"
            >
              4x Matrix
            </button>
          </div>

          {/* Hacker Mechanical SFX Keystroke Toggle */}
          <button
            type="button"
            onClick={handleToggleSound}
            className={`flex items-center gap-1.5 px-2.5 py-1 rounded-lg border text-[11px] font-mono transition-all cursor-pointer ${
              soundEnabled
                ? "bg-[#9fef00]/25 text-[#9fef00] border-[#9fef00] shadow-[0_0_12px_rgba(159,239,0,0.35)] font-bold animate-pulse"
                : "bg-[#14233c] text-[#8ba0c3] border-[#1f3352] hover:text-[#ffffff]"
            }`}
            title={soundEnabled ? "Mute Hacker Mechanical Keystrokes" : "Enable Hacker Mechanical Keystrokes"}
          >
            {soundEnabled ? (
              <>
                <Volume2 className="w-3.5 h-3.5 text-[#9fef00]" />
                <span>⌨️ KEYS: ON</span>
              </>
            ) : (
              <>
                <VolumeX className="w-3.5 h-3.5" />
                <span>⌨️ KEYS: OFF</span>
              </>
            )}
          </button>

          {/* Mr. Robot Cinematic BGM Toggle */}
          <button
            type="button"
            onClick={handleToggleMusic}
            className={`flex items-center gap-1.5 px-2.5 py-1 rounded-lg border text-[11px] font-mono transition-all cursor-pointer ${
              isMusicPlaying
                ? "bg-[#2de2e6]/25 text-[#2de2e6] border-[#2de2e6] shadow-[0_0_14px_rgba(45,226,230,0.4)] font-bold animate-pulse"
                : "bg-[#14233c] text-[#8ba0c3] border-[#1f3352] hover:text-[#ffffff] hover:bg-[#182844]"
            }`}
            title={isMusicPlaying ? "Stop Mr. Robot Cyber BGM" : "Play Mr. Robot Cyber BGM (Dark Synth & Reel Beat)"}
          >
            <Music className={`w-3.5 h-3.5 ${isMusicPlaying ? "text-[#2de2e6]" : ""}`} />
            <span>{isMusicPlaying ? "🎵 BGM: PLAYING" : "🎵 BGM: OST"}</span>
          </button>

          {/* Play / Pause Toggle */}
          <button
            type="button"
            onClick={() => setIsPlaying(!isPlaying)}
            className="flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-[#14233c] hover:bg-[#182844] border border-[#1f3352] text-[#ffffff] text-[11px] font-semibold transition-colors cursor-pointer"
            title={isPlaying ? "Pause cinematic stream" : "Resume stream"}
          >
            {isPlaying ? (
              <>
                <Pause className="w-3.5 h-3.5 text-[#ff8400]" />
                <span className="hidden sm:inline">Pause</span>
              </>
            ) : (
              <>
                <Play className="w-3.5 h-3.5 text-[#9fef00]" />
                <span className="hidden sm:inline">Stream</span>
              </>
            )}
          </button>

          {/* Reset Stream */}
          <button
            type="button"
            onClick={resetStream}
            className="p-1.5 rounded-lg bg-[#14233c] hover:bg-[#182844] border border-[#1f3352] text-[#8ba0c3] hover:text-[#ffffff] transition-colors cursor-pointer"
            title="Restart terminal stream"
          >
            <RotateCcw className="w-3.5 h-3.5" />
          </button>

          {/* Copy Logs */}
          <button
            type="button"
            onClick={handleCopy}
            className="p-1.5 rounded-lg bg-[#14233c] hover:bg-[#182844] border border-[#1f3352] text-[#8ba0c3] hover:text-[#ffffff] transition-colors cursor-pointer"
            title="Copy stream logs"
          >
            {copied ? <Check className="w-3.5 h-3.5 text-[#9fef00]" /> : <Copy className="w-3.5 h-3.5" />}
          </button>
        </div>
      </div>

      {/* Terminal Screen Body with CRT Scanline Effect */}
      <div
        ref={terminalBodyRef}
        className="crt-screen relative p-6 bg-[#03060a] min-h-[420px] max-h-[500px] overflow-y-auto space-y-1.5 font-mono text-xs leading-relaxed select-text shadow-inner"
        style={{
          boxShadow: "inset 0 0 80px rgba(0, 0, 0, 0.9)",
        }}
      >
        {lines.map((line, idx) => {
          if (line.type === "header") {
            return (
              <div
                key={idx}
                className="pt-3 pb-1 text-[#22c55e] font-bold text-center border-y border-[#1e293b] my-2 hacker-glow-green tracking-widest text-[11px]"
              >
                {line.text}
              </div>
            );
          }
          if (line.type === "prompt") {
            return (
              <div key={idx} className="text-[#38bdf8] font-bold flex items-center gap-1.5 pt-1">
                <span className="text-[#22c55e] hacker-glow-green">root@fsociety:~#</span>
                <span className="text-[#38bdf8]">{line.text.replace(/^.*~[#$]\s*/, "")}</span>
              </div>
            );
          }
          if (line.type === "hex") {
            return (
              <div key={idx} className="text-[#06b6d4] font-mono text-[11px] hacker-glow-cyan opacity-95">
                {line.text}
              </div>
            );
          }
          if (line.type === "success") {
            return (
              <div key={idx} className="text-[#22c55e] flex items-center gap-1.5 hacker-glow-green">
                <span className="font-bold">[+]</span>
                <span>{line.text.replace(/^\[\+\]\s*/, "")}</span>
              </div>
            );
          }
          if (line.type === "warning") {
            return (
              <div key={idx} className="text-[#eab308] flex items-center gap-1.5">
                <span className="font-bold">[!]</span>
                <span>{line.text.replace(/^\[!\]\s*/, "")}</span>
              </div>
            );
          }
          if (line.type === "error") {
            return (
              <div key={idx} className="text-[#f85149] flex items-center gap-1.5 hacker-glow-red font-semibold">
                <span className="font-bold">[-]</span>
                <span>{line.text.replace(/^\[-\]\s*/, "")}</span>
              </div>
            );
          }
          if (line.type === "flag") {
            return (
              <div
                key={idx}
                className="p-3 my-2 rounded-xl bg-[#091b12] border border-[#22c55e]/50 text-[#22c55e] font-bold text-sm tracking-wide hacker-glow-green flex items-center gap-2 shadow-[0_0_20px_rgba(34,197,94,0.3)] animate-pulse"
              >
                <Flame className="w-5 h-5 text-[#eab308] flex-shrink-0" />
                <span>{line.text}</span>
              </div>
            );
          }
          return (
            <div key={idx} className="text-[#94a3b8]">
              {line.text}
            </div>
          );
        })}

        {/* Live Blinking Hacker Cursor */}
        <div className="flex items-center gap-1 pt-1 text-[#9fef00] hacker-glow-green">
          <span className="font-bold">root@fsociety:~#</span>
          <span className="w-2.5 h-4 bg-[#9fef00] inline-block animate-pulse shadow-[0_0_8px_#9fef00]" />
        </div>
      </div>

      {/* Bottom Mode Switch & Interactive Input */}
      <div className="px-4 py-2.5 bg-[#070b13] border-t border-[#1f3352] flex flex-wrap items-center justify-between gap-3 text-xs font-mono relative z-20">
        <div className="flex items-center gap-2 text-[#8ba0c3]">
          <span className="flex items-center gap-1.5 text-[11px] text-[#9fef00]">
            <Sparkles className="w-3.5 h-3.5" />
            <span>MR. ROBOT ENGINE ACTIVE</span>
          </span>
          <span>•</span>
          <span className="text-[10px] text-[#6c7d9c]">Streaming Cyberattack Simulation</span>
        </div>

        <div className="flex items-center gap-2">
          {/* Manual Prompt Injector Toggle */}
          <button
            type="button"
            onClick={() => {
              setIsManualMode(!isManualMode);
              if (!isManualMode) {
                setTimeout(() => inputRef.current?.focus(), 100);
              }
            }}
            className={`px-3 py-1 rounded-lg border text-[11px] font-semibold transition-colors cursor-pointer ${
              isManualMode
                ? "bg-[#9fef00] text-[#0b121e] border-[#9fef00] font-bold"
                : "bg-[#14233c] text-[#8ba0c3] border-[#1f3352] hover:text-[#ffffff]"
            }`}
          >
            {isManualMode ? "Exit Manual Input" : "Type Custom Command"}
          </button>
        </div>
      </div>

      {/* Manual Input Form Bar when user clicks 'Type Custom Command' */}
      {isManualMode && (
        <form
          onSubmit={handleManualSubmit}
          className="p-3 bg-[#111d30] border-t border-[#1f3352] flex items-center gap-2 relative z-20"
        >
          <span className="text-[#9fef00] font-bold text-xs flex-shrink-0">root@fsociety:~#</span>
          <input
            ref={inputRef}
            type="text"
            value={manualInput}
            onChange={(e) => setManualInput(e.target.value)}
            placeholder="Type payload or command (e.g. cat /etc/shadow)..."
            className="flex-1 bg-[#070b13] border border-[#1f3352] px-3 py-1.5 rounded-lg text-xs font-mono text-[#ffffff] focus:border-[#9fef00] focus:outline-none"
          />
          <button
            type="submit"
            className="px-3 py-1.5 rounded-lg bg-[#9fef00] text-[#0b121e] text-xs font-bold hover:bg-[#b4fa1f] transition-colors cursor-pointer"
          >
            Execute
          </button>
        </form>
      )}
    </div>
  );
}
