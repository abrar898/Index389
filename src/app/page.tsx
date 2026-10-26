import Link from "next/link";
import prisma from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import {
  Shield,
  FileText,
  Terminal,
  Folder,
  ArrowRight,
  BookOpen,
  CheckSquare,
  Lock,
  Layers,
  Sparkles,
  Search,
  Crosshair,
  ShieldCheck,
  CheckCircle2,
  Activity,
} from "lucide-react";
import { InteractiveTerminal } from "@/components/home/InteractiveTerminal";
import { ThemeToggle } from "@/components/layout/ThemeToggle";

export const metadata = {
  title: "Index 389 // Cybersecurity Research & CTF Knowledge Base",
  description:
    "Production-grade cybersecurity documentation and knowledge base engine for Index 389.",
};

export default async function HomePage() {
  const user = await getCurrentUser();

  const [recentNotes, totalNotes, totalCategories] = await Promise.all([
    prisma.document.findMany({
      where: { deletedAt: null },
      orderBy: { updatedAt: "desc" },
      take: 6,
      include: {
        category: true,
        tags: { include: { tag: true } },
      },
    }),
    prisma.document.count({ where: { deletedAt: null } }),
    prisma.category.count(),
  ]);

  return (
    <div className="min-h-screen bg-[var(--background)] text-[var(--foreground)] font-sans selection:bg-[#9fef00] selection:text-[#0b121e] cyber-grid relative">
      {/* Decorative ambient background glows */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[350px] bg-gradient-to-b from-[#9fef00]/15 via-[#2de2e6]/5 to-transparent blur-[120px] pointer-events-none -z-10" />

      {/* Navigation Header - Permanently Fixed at Top */}
      <header className="fixed top-0 left-0 right-0 z-50 w-full h-16 border-b border-[var(--surface-border)] bg-[var(--surface)]/95 backdrop-blur-md">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 h-full flex items-center justify-between">
          <Link href="/" className="flex items-center gap-3 group">
            <div className="relative w-10 h-10 rounded-xl overflow-hidden border border-[#9fef00]/40 group-hover:border-[#9fef00] bg-black/60 shadow-lg shadow-[#9fef00]/10 transition-all flex items-center justify-center flex-shrink-0">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                src="/logo.png"
                alt="Index 389 Logo"
                className="w-full h-full object-cover group-hover:scale-105 transition-transform"
              />
            </div>
            <div className="flex flex-col">
              <div className="flex items-center gap-1.5">
                <span className="font-mono text-base font-bold tracking-wider text-[var(--foreground-bright)]">
                  INDEX 389
                </span>
                <span className="px-1.5 py-0.2 rounded bg-[#9fef00]/10 text-[#9fef00] text-[9px] font-mono border border-[#9fef00]/30">
                  CTF
                </span>
              </div>
              <span className="text-[10px] font-mono text-[var(--foreground-muted)] tracking-wider">
                CYBERSECURITY & RESEARCH
              </span>
            </div>
          </Link>

          <div className="flex items-center gap-3 sm:gap-6 text-xs font-mono">
            <Link
              href="/notes"
              className="nav-tag-item hidden md:inline-flex"
            >
              <BookOpen className="w-3.5 h-3.5" />
              <span>REPOSITORY</span>
            </Link>
            <Link
              href="/methodology"
              className="nav-tag-item hidden md:inline-flex"
            >
              <CheckSquare className="w-3.5 h-3.5" />
              <span>METHODOLOGY</span>
            </Link>
            <Link
              href="/categories"
              className="nav-tag-item hidden md:inline-flex"
            >
              <Folder className="w-3.5 h-3.5" />
              <span>TAXONOMY</span>
            </Link>

            {/* Theme Selector */}
            <ThemeToggle />

            {user ? (
              <Link
                href="/dashboard"
                className="flex items-center gap-2 px-3 sm:px-4 py-2 rounded-xl bg-[var(--surface-card)] hover:bg-[var(--surface-elevated)] border border-[var(--surface-border)] text-[#9fef00] font-semibold transition-all shadow-md"
              >
                <Activity className="w-3.5 h-3.5 text-[#9fef00]" />
                <span className="hidden sm:inline">DASHBOARD</span>
                <span className="text-[10px] text-[var(--foreground-muted)] font-mono">[{user.role}]</span>
              </Link>
            ) : (
              <Link
                href="/login"
                className="flex items-center gap-2 px-3.5 sm:px-4 py-2 rounded-xl bg-[#9fef00] hover:bg-[#b4fa1f] text-[#0b121e] font-bold text-xs transition-all shadow-lg shadow-[#9fef00]/20 active:scale-95"
              >
                <Lock className="w-3.5 h-3.5" />
                <span>ACCESS</span>
              </Link>
            )}
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="landing-hero-section relative pt-32 pb-16 px-6">
        <div className="max-w-5xl mx-auto text-center space-y-7 relative z-10">
          <h1 className="landing-hero-title text-4xl sm:text-6xl md:text-7xl font-extrabold tracking-tight text-slate-900 dark:text-white leading-[1.15]">
            Precision Technical Docs for{" "}
            <span className="landing-hero-accent text-[#9fef00] drop-shadow-[0_0_35px_rgba(159,239,0,0.5)]">
              Security Professionals
            </span>
          </h1>

          <p className="landing-hero-desc text-base sm:text-lg text-slate-600 dark:text-[#a4b1cd] max-w-2xl mx-auto leading-relaxed">
            Personal cybersecurity knowledge hub. Write technical writeups, drag &amp; drop Markdown vaults,
            preserve exact terminal commands, test live commands in the shell, and export directly to clean PDF or editable Microsoft Word.
          </p>

          <div className="flex flex-wrap items-center justify-center gap-4 pt-2">
            <Link
              href="/notes"
              className="flex items-center gap-2.5 px-6 py-3.5 rounded-xl bg-[#9fef00] hover:bg-[#b4fa1f] text-[#0b121e] font-bold text-sm shadow-xl shadow-[#9fef00]/25 transition-all active:scale-95"
            >
              <span>Explore Knowledge Base</span>
              <ArrowRight className="w-4 h-4" />
            </Link>

            <Link
              href="/methodology"
              className="landing-sec-btn flex items-center gap-2 px-6 py-3.5 rounded-xl bg-white dark:bg-[#14233c] hover:bg-slate-100 dark:hover:bg-[#182844] border border-slate-200 dark:border-[#1f3352] text-slate-900 dark:text-white font-mono text-xs transition-all shadow-xs"
            >
              <CheckSquare className="w-4 h-4 text-[#9fef00]" />
              <span>Assessment Methodology</span>
            </Link>

            <Link
              href="/login"
              className="landing-sec-btn flex items-center gap-2 px-5 py-3.5 rounded-xl bg-white dark:bg-[#14233c] hover:bg-slate-100 dark:hover:bg-[#182844] border border-slate-200 dark:border-[#1f3352] text-slate-700 dark:text-[#8ba0c3] hover:text-slate-900 dark:hover:text-white font-mono text-xs transition-all shadow-xs"
            >
              <Terminal className="w-4 h-4 text-cyan-600 dark:text-[#2de2e6]" />
              <span>Sign In</span>
            </Link>
          </div>

          {/* Quick Counter Metrics */}
          <div className="pt-8 flex items-center justify-center gap-8 md:gap-16 text-center text-xs font-mono">
            <div>
              <div className="landing-stat-num text-2xl font-bold text-slate-900 dark:text-white">{totalNotes}</div>
              <div className="text-slate-500 dark:text-[#6c7d9c] text-[11px] uppercase tracking-wider mt-0.5">
                Technical Notes
              </div>
            </div>
            <div className="w-px h-8 bg-slate-200 dark:bg-[#1f3352]" />
            <div>
              <div className="text-2xl font-bold text-[#9fef00]">{totalCategories}</div>
              <div className="text-slate-500 dark:text-[#6c7d9c] text-[11px] uppercase tracking-wider mt-0.5">
                Security Domains
              </div>
            </div>
            <div className="w-px h-8 bg-slate-200 dark:bg-[#1f3352]" />
            <div>
              <div className="text-2xl font-bold text-cyan-600 dark:text-[#2de2e6]">98/100</div>
              <div className="text-slate-500 dark:text-[#6c7d9c] text-[11px] uppercase tracking-wider mt-0.5">
                Security Score
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Live Interactive Running Terminal Showcase */}
      <section className="landing-terminal-section max-w-5xl mx-auto px-6 pb-20">
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2 font-mono text-xs text-[#9fef00]">
              <Terminal className="w-4 h-4" />
              <span>RUNNING OPERATIONAL TERMINAL // TRY TYPING COMMANDS</span>
            </div>
            <span className="hidden sm:inline-block text-[11px] font-mono text-slate-500 dark:text-[#6c7d9c]">
              Try &lsquo;nmap&rsquo;, &lsquo;gobuster&rsquo;, &lsquo;sudo -l&rsquo;, or &lsquo;cve-check&rsquo;
            </span>
          </div>

          <InteractiveTerminal />
        </div>
      </section>

      {/* Tactical Platform Capabilities Matrix */}
      <section className="landing-features-section max-w-6xl mx-auto px-6 pb-20">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="p-6 rounded-2xl bg-white dark:bg-[#14233c]/80 border border-slate-200 dark:border-[#1f3352] space-y-3 relative overflow-hidden shadow-xs hover:border-[#9fef00]/50 transition-all">
            <div className="w-10 h-10 rounded-xl bg-[#9fef00]/10 border border-[#9fef00]/30 flex items-center justify-center text-[#9fef00]">
              <Crosshair className="w-5 h-5" />
            </div>
            <h3 className="text-base font-bold text-slate-900 dark:text-white">Live Parameter Injection</h3>
            <p className="text-xs text-slate-600 dark:text-[#a4b1cd] leading-relaxed">
              Inject your engagement target parameters (TARGET_IP, LHOST, LPORT) to auto-populate commands across writeups for instant one-click execution.
            </p>
          </div>

          <div className="p-6 rounded-2xl bg-white dark:bg-[#14233c]/80 border border-slate-200 dark:border-[#1f3352] space-y-3 relative overflow-hidden shadow-xs hover:border-[#9fef00]/50 transition-all">
            <div className="w-10 h-10 rounded-xl bg-cyan-500/10 border border-cyan-500/30 flex items-center justify-center text-cyan-600 dark:text-[#2de2e6]">
              <CheckSquare className="w-5 h-5" />
            </div>
            <h3 className="text-base font-bold text-slate-900 dark:text-white">Pentest Methodology Tracker</h3>
            <p className="text-xs text-slate-600 dark:text-[#a4b1cd] leading-relaxed">
              Interactive 5-phase operational checklists spanning Reconnaissance, Web Exploitation, and Root PrivEsc with progress persistence and Markdown export.
            </p>
          </div>

          <div className="p-6 rounded-2xl bg-white dark:bg-[#14233c]/80 border border-slate-200 dark:border-[#1f3352] space-y-3 relative overflow-hidden shadow-xs hover:border-[#9fef00]/50 transition-all">
            <div className="w-10 h-10 rounded-xl bg-purple-500/10 border border-purple-500/30 flex items-center justify-center text-purple-600 dark:text-[#a855f7]">
              <ShieldCheck className="w-5 h-5" />
            </div>
            <h3 className="text-base font-bold text-slate-900 dark:text-white">Hardened Security Baseline</h3>
            <p className="text-xs text-slate-600 dark:text-[#a4b1cd] leading-relaxed">
              Protected by strict Content-Security-Policy, anti-clickjacking frame guards, anti-brute-force rate limiting, and stored XSS sanitization.
            </p>
          </div>
        </div>
      </section>

      {/* Role-Based Permissions Architecture Section */}
      <section className="landing-rbac-section border-y border-slate-200 dark:border-[#1f3352] bg-slate-100/70 dark:bg-[#111d30]/60 py-20 px-6 relative">
        <div className="max-w-6xl mx-auto space-y-12">
          <div className="text-center space-y-3">
            <div className="font-mono text-xs text-[#9fef00] uppercase tracking-widest font-semibold">
              SECURITY ACCESS CONTROL // RBAC
            </div>
            <h2 className="landing-green-heading text-3xl md:text-4xl font-extrabold text-[#9fef00] drop-shadow-[0_0_25px_rgba(159,239,0,0.35)]">
              Role-Separated Operational Capabilities
            </h2>
            <p className="text-xs md:text-sm text-slate-600 dark:text-[#a4b1cd] max-w-xl mx-auto">
              Clean separation of responsibilities: analysts freely browse, search, and export, while authorized administrators control the knowledge base.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {/* Standard User / Reader Card */}
            <div className="p-8 rounded-2xl bg-white dark:bg-[#14233c]/80 border border-slate-200 dark:border-[#1f3352] space-y-5 shadow-xs">
              <div className="flex items-center justify-between">
                <span className="font-mono text-xs font-bold text-cyan-600 dark:text-[#2de2e6] px-3 py-1 rounded-full bg-cyan-500/10 border border-cyan-500/20">
                  STANDARD ANALYST // USER
                </span>
                <span className="text-[11px] font-mono text-slate-600 dark:text-[#6c7d9c] px-2 py-0.5 rounded bg-slate-100 dark:bg-[#14233c]">
                  READ-ONLY
                </span>
              </div>
              <h3 className="text-xl font-bold text-slate-900 dark:text-white">Documentation Consumer</h3>
              <p className="text-xs text-slate-600 dark:text-[#a4b1cd] leading-relaxed">
                Team members and authorized operators can explore, research, search, and export writeups without danger of unintentional modification.
              </p>
              <ul className="space-y-3 text-xs font-mono text-slate-700 dark:text-[#a4b1cd] pt-2">
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#9fef00] flex-shrink-0" />
                  <span>Browse all technical categories & writeups</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#9fef00] flex-shrink-0" />
                  <span>Instant full-text search across commands & CVEs</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#9fef00] flex-shrink-0" />
                  <span>Export notes to printable PDF and editable Word DOCX</span>
                </li>
                <li className="flex items-center gap-2.5 text-slate-400 dark:text-[#6c7d9c]">
                  <span className="w-4 h-4 text-center font-bold">✕</span>
                  <span className="line-through">Cannot edit or delete notes</span>
                </li>
                <li className="flex items-center gap-2.5 text-slate-400 dark:text-[#6c7d9c]">
                  <span className="w-4 h-4 text-center font-bold">✕</span>
                  <span className="line-through">Cannot create categories or upload ZIPs</span>
                </li>
              </ul>
            </div>

            {/* Admin Card */}
            <div className="p-8 rounded-2xl bg-white dark:bg-[#14233c]/80 border-2 border-[#9fef00]/50 space-y-5 shadow-xl shadow-[#9fef00]/5 relative overflow-hidden">
              <div className="absolute top-0 right-0 w-32 h-32 bg-[#9fef00]/10 rounded-full blur-2xl pointer-events-none" />

              <div className="flex items-center justify-between">
                <span className="font-mono text-xs font-bold text-[#9fef00] px-3 py-1 rounded-full bg-[#9fef00]/10 border border-[#9fef00]/30">
                  ADMINISTRATOR // LEAD RESEARCHER
                </span>
                <span className="text-[11px] font-mono text-[#9fef00] px-2 py-0.5 rounded bg-[#9fef00]/15 font-bold">
                  FULL CONTROL
                </span>
              </div>
              <h3 className="text-xl font-bold text-slate-900 dark:text-white">Authoring & Knowledge Architect</h3>
              <p className="text-xs text-slate-600 dark:text-[#a4b1cd] leading-relaxed">
                Full privileges to publish new research, batch import Markdown writeups, manage taxonomy domains, and review immutable audit trails.
              </p>
              <ul className="space-y-3 text-xs font-mono text-slate-700 dark:text-[#a4b1cd] pt-2">
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#9fef00] flex-shrink-0" />
                  <span>Split-Screen Live Editor with quick cybersecurity snippets</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#9fef00] flex-shrink-0" />
                  <span>Create & customize categories directly in UI</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#9fef00] flex-shrink-0" />
                  <span>Batch drag-and-drop Markdown & ZIP archives</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#9fef00] flex-shrink-0" />
                  <span>Document versioning and audit log review</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#9fef00] flex-shrink-0" />
                  <span>Soft-delete and document lifecycle management</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Documentation Preview */}
      <section className="landing-notes-section max-w-6xl mx-auto py-20 px-6 space-y-8">
        <div className="flex items-center justify-between">
          <div>
            <div className="font-mono text-xs text-[#9fef00]">REPOSITORY SNAPSHOT</div>
            <h2 className="text-2xl font-bold text-slate-900 dark:text-white mt-1">Featured Research Notes</h2>
          </div>
          <Link
            href="/notes"
            className="text-xs font-mono text-cyan-700 dark:text-[#2de2e6] hover:text-[#9fef00] hover:underline flex items-center gap-1.5"
          >
            <span>Browse Full Repository ({totalNotes})</span>
            <ArrowRight className="w-4 h-4" />
          </Link>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {recentNotes.map((note) => (
            <Link
              key={note.id}
              href={`/notes/${note.slug}`}
              className="group p-6 rounded-2xl bg-white dark:bg-[#14233c]/80 border border-slate-200 dark:border-[#1f3352] shadow-xs hover:shadow-md hover:border-[#9fef00]/50 transition-all flex flex-col justify-between"
            >
              <div className="space-y-3">
                <div className="text-[11px] font-mono text-[#9fef00] flex items-center gap-1.5 font-semibold">
                  <Folder className="w-3.5 h-3.5" />
                  <span>{note.category?.name || "General"}</span>
                </div>
                <h3 className="font-bold text-base text-slate-900 dark:text-white group-hover:text-[#9fef00] transition-colors line-clamp-2">
                  {note.title}
                </h3>
                <p className="text-xs text-slate-600 dark:text-[#a4b1cd] line-clamp-2 leading-relaxed">
                  {note.description || "Operational commands and structured technical documentation."}
                </p>
              </div>

              <div className="pt-4 mt-4 border-t border-slate-100 dark:border-[#1f3352] flex items-center justify-between text-[11px] font-mono text-slate-500 dark:text-[#6c7d9c]">
                <span>{note.readingTimeMin}m read</span>
                <span className="text-[#9fef00] group-hover:translate-x-1 transition-transform flex items-center gap-1 font-semibold">
                  Read Note &rarr;
                </span>
              </div>
            </Link>
          ))}
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-slate-200 dark:border-[#1f3352] bg-[#0D1321] py-10 px-6 text-xs font-mono text-[#94A3B8]">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2.5">
            <div className="w-6 h-6 rounded-md overflow-hidden border border-[#9fef00]/40 flex-shrink-0">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/logo.png" alt="Index 389" className="w-full h-full object-cover" />
            </div>
            <span className="text-[#ffffff] font-bold">INDEX 389 PLATFORM</span>
            <span>•</span>
            <span>CTF Team & Technical Cybersecurity Research Engine</span>
          </div>

          <div className="flex items-center gap-6">
            <Link href="/notes" className="hover:text-[#9fef00] transition-colors">
              Repository
            </Link>
            <Link href="/categories" className="hover:text-[#9fef00] transition-colors">
              Categories
            </Link>
            <Link href="/login" className="hover:text-[#9fef00] transition-colors">
              Operator Sign In
            </Link>
          </div>
        </div>
      </footer>
    </div>
  );
}
