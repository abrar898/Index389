import React from "react";
import Link from "next/link";
import { getCurrentUser } from "@/lib/auth";
import { getAllMindmaps } from "@/lib/mindmaps";
import {
  Network,
  Plus,
  Upload,
  Search,
  ExternalLink,
  Layers,
  Terminal,
  Clock,
  Sparkles,
  Maximize2,
  FileCode,
  Shield,
  ArrowRight,
} from "lucide-react";
import { MindmapCardList } from "@/components/mindmaps/MindmapCardList";

export const dynamic = "force-dynamic";

export default async function MindmapsPage(props: {
  searchParams: Promise<{ q?: string; category?: string; tag?: string }>;
}) {
  const user = await getCurrentUser();
  const searchParams = await props.searchParams;
  const allMindmaps = await getAllMindmaps();

  const totalNodes = allMindmaps.reduce((acc, m) => acc + (m.nodeCount || 0), 0);
  const totalPhases = allMindmaps.reduce((acc, m) => acc + (m.phaseCount || 0), 0);
  const totalCommands = allMindmaps.reduce((acc, m) => acc + (m.commandCount || 0), 0);

  return (
    <div className="space-y-8">
      {/* Hero Header */}
      <div className="relative overflow-hidden rounded-2xl glass-panel border-[#1f3352] p-8 shadow-2xl relative glow-emerald-box">
        <div className="absolute top-0 right-0 w-80 h-80 bg-gradient-to-bl from-[#9fef00]/15 via-[#2de2e6]/5 to-transparent rounded-full blur-3xl pointer-events-none" />

        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div className="space-y-2.5">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#9fef00]/10 text-[#9fef00] border border-[#9fef00]/30 font-mono text-xs shadow-sm">
              <span className="w-2 h-2 rounded-full bg-[#9fef00] animate-pulse" />
              <span>CANVAS VISUALIZATION SUITE // INDEX 389</span>
            </div>
            <h1 className="text-3xl font-extrabold tracking-tight text-[#ffffff]">
              Security & Exam <span className="text-[#9fef00]">Mindmaps</span>
            </h1>
            <p className="text-xs md:text-sm text-[#a4b1cd] max-w-2xl leading-relaxed">
              Explore dynamic, pan-and-zoom attack trees, methodology cheat sheets, and certification roadmaps.
              Easily create custom mindmaps by uploading or editing HTML code directly within the platform.
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-3">
            <Link
              href="/mindmaps/new"
              className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-[#9fef00] hover:bg-[#b4fa1f] text-xs font-bold text-[#0b121e] transition-all shadow-lg shadow-[#9fef00]/20 active:scale-95"
            >
              <Plus className="w-4 h-4" />
              <span>Create Mindmap</span>
            </Link>
          </div>
        </div>
      </div>

      {/* Overview Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="p-4 sm:p-5 rounded-2xl glass-panel flex items-center justify-between border-[var(--surface-border)]">
          <div>
            <div className="text-[11px] font-mono uppercase tracking-wider text-[var(--foreground-muted)]">
              Interactive Mindmaps
            </div>
            <div className="text-2xl sm:text-3xl font-extrabold font-mono text-[var(--foreground-bright)] mt-1">
              {allMindmaps.length}
            </div>
            <div className="text-[10px] font-mono text-[#9fef00] mt-0.5">Active Visualizers</div>
          </div>
          <div className="w-11 h-11 rounded-xl bg-[#9fef00]/10 border border-[#9fef00]/20 flex items-center justify-center text-[#9fef00]">
            <Network className="w-5 h-5" />
          </div>
        </div>

        <div className="p-4 sm:p-5 rounded-2xl glass-panel flex items-center justify-between border-[var(--surface-border)]">
          <div>
            <div className="text-[11px] font-mono uppercase tracking-wider text-[var(--foreground-muted)]">
              Canvas Nodes
            </div>
            <div className="text-2xl sm:text-3xl font-extrabold font-mono text-[#2de2e6] mt-1">
              {totalNodes}
            </div>
            <div className="text-[10px] font-mono text-[#2de2e6] mt-0.5">Draggable Modules</div>
          </div>
          <div className="w-11 h-11 rounded-xl bg-[#2de2e6]/10 border border-[#2de2e6]/20 flex items-center justify-center text-[#2de2e6]">
            <Layers className="w-5 h-5" />
          </div>
        </div>

        <div className="p-4 sm:p-5 rounded-2xl glass-panel flex items-center justify-between border-[var(--surface-border)]">
          <div>
            <div className="text-[11px] font-mono uppercase tracking-wider text-[var(--foreground-muted)]">
              Tactical Phases
            </div>
            <div className="text-2xl sm:text-3xl font-extrabold font-mono text-[#ff8400] mt-1">
              {totalPhases}
            </div>
            <div className="text-[10px] font-mono text-[#ff8400] mt-0.5">Recon to Reporting</div>
          </div>
          <div className="w-11 h-11 rounded-xl bg-[#ff8400]/10 border border-[#ff8400]/20 flex items-center justify-center text-[#ff8400]">
            <Shield className="w-5 h-5" />
          </div>
        </div>

        <div className="p-4 sm:p-5 rounded-2xl glass-panel flex items-center justify-between border-[var(--surface-border)]">
          <div>
            <div className="text-[11px] font-mono uppercase tracking-wider text-[var(--foreground-muted)]">
              Executable Payloads
            </div>
            <div className="text-2xl sm:text-3xl font-extrabold font-mono text-[#a855f7] mt-1">
              {totalCommands}+
            </div>
            <div className="text-[10px] font-mono text-[#a855f7] mt-0.5">One-Click Copy</div>
          </div>
          <div className="w-11 h-11 rounded-xl bg-[#a855f7]/10 border border-[#a855f7]/20 flex items-center justify-center text-[#a855f7]">
            <Terminal className="w-5 h-5" />
          </div>
        </div>
      </div>

      {/* Featured CPTS Exam Mindmap Showcase */}
      {allMindmaps.find((m) => m.slug === "cpts-exam-mindmap") && (
        <div className="p-6 rounded-2xl border-2 border-[#9fef00]/40 bg-gradient-to-r from-[#111d30] via-[#14233c] to-[#070b13] relative overflow-hidden shadow-2xl">
          <div className="absolute top-0 right-0 px-4 py-1 bg-[#9fef00] text-[#0b121e] font-mono text-[10px] font-bold uppercase tracking-wider rounded-bl-xl shadow-md">
            FLAGSHIP CERTIFICATION ROADMAP
          </div>

          <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
            <div className="space-y-3 max-w-2xl">
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-[#9fef00] animate-ping" />
                <span className="font-mono text-xs font-bold text-[#9fef00]">
                  HTB CPTS COMPREHENSIVE CANVAS
                </span>
              </div>
              <h2 className="text-2xl font-bold text-[#ffffff]">
                Certified Penetration Testing Specialist (CPTS) Mindmap
              </h2>
              <p className="text-xs sm:text-sm text-[#cbd5e1] leading-relaxed">
                Complete 9-phase pentesting blueprint featuring Reconnaissance, Nmap, Active Directory,
                Privilege Escalation, Web Attacks, Pivoting, Metasploit, and Reporting. Built-in live token substitution
                for LHOST, LPORT, RHOST, and credentials.
              </p>
              <div className="flex flex-wrap items-center gap-2 pt-1">
                {["Active Directory", "SQLi & Web", "Pivoting & Chisel", "Linux & Win PrivEsc", "Token Substitution"].map(
                  (badge) => (
                    <span
                      key={badge}
                      className="px-2.5 py-1 rounded-lg bg-[#070b13]/80 border border-[#1f3352] text-[11px] font-mono text-[#8ba0c3]"
                    >
                      {badge}
                    </span>
                  )
                )}
              </div>
            </div>

            <div className="flex flex-col sm:flex-row items-stretch lg:items-center gap-3 flex-shrink-0">
              <a
                href="/mindmaps/cpts-exam-mindmap.html"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center justify-center gap-2 px-4 py-3 rounded-xl border border-[#1f3352] bg-[#111d30] hover:bg-[#182844] text-xs font-semibold text-[#ffffff] transition-all"
              >
                <ExternalLink className="w-4 h-4 text-[#9fef00]" />
                <span>Open Standalone</span>
              </a>
              <Link
                href="/mindmaps/cpts-exam-mindmap"
                className="flex items-center justify-center gap-2 px-6 py-3 rounded-xl bg-[#9fef00] hover:bg-[#b4fa1f] text-xs font-bold text-[#0b121e] transition-all shadow-lg shadow-[#9fef00]/30 active:scale-95"
              >
                <Maximize2 className="w-4 h-4" />
                <span>Launch Interactive Canvas</span>
              </Link>
            </div>
          </div>
        </div>
      )}

      {/* Mindmap List & Filter Component */}
      <MindmapCardList mindmaps={allMindmaps} user={user} />
    </div>
  );
}
