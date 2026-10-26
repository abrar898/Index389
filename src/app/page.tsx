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
    <div className="min-h-screen bg-[#F0F2F5] dark:bg-[#0b121e] text-[#0D0D1A] dark:text-[var(--foreground)] font-sans cyber-grid relative selection:bg-[#9FEF00]/30 selection:text-[#0D0D1A]">
      {/* Decorative ambient background glows */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[350px] bg-gradient-to-b from-[#00B4D8]/10 via-[#3AAA00]/10 to-transparent dark:from-[#9fef00]/15 dark:via-[#2de2e6]/5 dark:to-transparent blur-[120px] pointer-events-none -z-10" />

      {/* Navigation Header - Permanently Fixed at Top (KEEP #1: Dark #1A1A2E) */}
      <header className="fixed top-0 left-0 right-0 z-50 w-full h-16 border-b border-[#252542] dark:border-[var(--surface-border)] bg-[#1A1A2E]/95 backdrop-blur-md">
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
                <span className="font-mono text-base font-bold tracking-wider text-[#FFFFFF]">
                  INDEX 389
                </span>
                <span className="px-1.5 py-0.2 rounded bg-[#9fef00]/15 text-[#9fef00] text-[9px] font-mono border border-[#9fef00]/30">
                  CTF
                </span>
              </div>
              <span className="text-[10px] font-mono text-[#9A9AB0] tracking-wider">
                CYBERSECURITY & RESEARCH
              </span>
            </div>
          </Link>

          <div className="flex items-center gap-3 sm:gap-6 text-xs font-mono">
            <Link
              href="/notes"
              className="text-[#E2E4EB] hover:text-[#9fef00] transition-colors hidden md:flex items-center gap-1.5"
            >
              <BookOpen className="w-3.5 h-3.5" />
              <span>REPOSITORY</span>
            </Link>
            <Link
              href="/methodology"
              className="text-[#E2E4EB] hover:text-[#9fef00] transition-colors hidden md:flex items-center gap-1.5"
            >
              <CheckSquare className="w-3.5 h-3.5" />
              <span>METHODOLOGY</span>
            </Link>
            <Link
              href="/categories"
              className="text-[#E2E4EB] hover:text-[#9fef00] transition-colors hidden md:flex items-center gap-1.5"
            >
              <Folder className="w-3.5 h-3.5" />
              <span>TAXONOMY</span>
            </Link>

            {/* Theme Selector */}
            <ThemeToggle />

            {user ? (
              <Link
                href="/dashboard"
                className="flex items-center gap-2 px-3 sm:px-4 py-2 rounded-xl bg-white/10 hover:bg-white/15 border border-white/15 text-[#9fef00] font-semibold transition-all shadow-md"
              >
                <Activity className="w-3.5 h-3.5 text-[#9fef00]" />
                <span className="hidden sm:inline">DASHBOARD</span>
                <span className="text-[10px] text-[#9A9AB0] font-mono">[{user.role}]</span>
              </Link>
            ) : (
              <Link
                href="/login"
                className="flex items-center gap-2 px-3.5 sm:px-4 py-2 rounded-xl bg-[#9fef00] hover:bg-[#77C400] text-[#0D0D1A] font-bold text-xs transition-all shadow-lg shadow-[#9fef00]/25 active:scale-95"
              >
                <Lock className="w-3.5 h-3.5" />
                <span>ACCESS</span>
              </Link>
            )}
          </div>
        </div>
      </header>

      {/* Hero Section (FIX #1: #F0F2F5 background) */}
      <section className="relative pt-32 pb-16 px-6">
        <div className="max-w-5xl mx-auto text-center space-y-7 relative z-10">
          {/* FIX #2: Hero Heading #0D0D1A in light mode */}
          <h1 className="text-4xl sm:text-6xl md:text-7xl font-extrabold tracking-tight text-[#0D0D1A] dark:text-[#ffffff] leading-[1.15]">
            Precision Technical Docs for{" "}
            {/* FIX #3: Gradient #3AAA00 -> #0090CC in light mode */}
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#3AAA00] to-[#0090CC] dark:from-[#9fef00] dark:via-[#2de2e6] dark:to-[#9fef00]">
              Security Professionals
            </span>
          </h1>

          {/* FIX #4: Body/Subtitle text #4A4A6A in light mode */}
          <p className="text-base sm:text-lg text-[#4A4A6A] dark:text-[#a4b1cd] max-w-2xl mx-auto leading-relaxed">
            Personal cybersecurity knowledge hub. Write technical writeups, drag & drop Markdown vaults,
            preserve exact terminal commands, test live commands in the shell, and export directly to clean PDF or editable Microsoft Word.
          </p>

          <div className="flex flex-wrap items-center justify-center gap-4 pt-2">
            {/* FIX #5: Explore Knowledge Base button in light mode: bg:#1A1A2E color:#9FEF00 */}
            <Link
              href="/notes"
              className="flex items-center gap-2.5 px-6 py-3.5 rounded-xl bg-[#1A1A2E] text-[#9FEF00] border border-[#9FEF00]/50 hover:bg-[#252542] hover:border-[#9FEF00] dark:bg-[#9fef00] dark:text-[#0b121e] dark:hover:bg-[#b4fa1f] dark:border-transparent font-bold text-sm shadow-xl shadow-[#9FEF00]/15 transition-all active:scale-95"
            >
              <span>Explore Knowledge Base</span>
              <ArrowRight className="w-4 h-4" />
            </Link>

            <Link
              href="/methodology"
              className="flex items-center gap-2 px-6 py-3.5 rounded-xl bg-[#FFFFFF] text-[#0D0D1A] border border-[#E2E4EB] hover:bg-[#F8F9FA] hover:border-[#9FEF00] dark:bg-[#14233c] dark:hover:bg-[#182844] dark:border-[#1f3352] dark:text-[#ffffff] font-mono text-xs transition-all shadow-xs"
            >
              <CheckSquare className="w-4 h-4 text-[#3AAA00] dark:text-[#9fef00]" />
              <span>Assessment Methodology</span>
            </Link>

            <Link
              href="/login"
              className="flex items-center gap-2 px-5 py-3.5 rounded-xl bg-[#FFFFFF] text-[#0D0D1A] border border-[#E2E4EB] hover:bg-[#F8F9FA] hover:border-[#9FEF00] dark:bg-[#14233c] dark:hover:bg-[#182844] dark:border-[#1f3352] dark:text-[#8ba0c3] dark:hover:text-[#ffffff] font-mono text-xs transition-all shadow-xs"
            >
              <Terminal className="w-4 h-4 text-[#0090CC] dark:text-[#2de2e6]" />
              <span>Sign In</span>
            </Link>
          </div>

          {/* Quick Counter Metrics (KEEP #4: 98/100 cyan, 6 green) */}
          <div className="pt-8 flex items-center justify-center gap-8 md:gap-16 text-center text-xs font-mono">
            <div>
              <div className="text-2xl font-bold text-[#0D0D1A] dark:text-[#ffffff]">{totalNotes}</div>
              <div className="text-[#4A4A6A] dark:text-[#6c7d9c] text-[11px] uppercase tracking-wider mt-0.5">
                Technical Notes
              </div>
            </div>
            <div className="w-px h-8 bg-[#E2E4EB] dark:bg-[#1f3352]" />
            <div>
              <div className="text-2xl font-bold text-[#9FEF00]">{totalCategories}</div>
              <div className="text-[#4A4A6A] dark:text-[#6c7d9c] text-[11px] uppercase tracking-wider mt-0.5">
                Security Domains
              </div>
            </div>
            <div className="w-px h-8 bg-[#E2E4EB] dark:bg-[#1f3352]" />
            <div>
              <div className="text-2xl font-bold text-[#00B4D8] dark:text-[#2de2e6]">98/100</div>
              <div className="text-[#4A4A6A] dark:text-[#6c7d9c] text-[11px] uppercase tracking-wider mt-0.5">
                Security Score
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Live Interactive Running Terminal Showcase */}
      <section className="max-w-5xl mx-auto px-6 pb-20">
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2 font-mono text-xs text-[#9fef00]">
              <Terminal className="w-4 h-4" />
              <span>RUNNING OPERATIONAL TERMINAL // TRY TYPING COMMANDS</span>
            </div>
            <span className="hidden sm:inline-block text-[11px] font-mono text-[#6c7d9c]">
              Try &lsquo;nmap&rsquo;, &lsquo;gobuster&rsquo;, &lsquo;sudo -l&rsquo;, or &lsquo;cve-check&rsquo;
            </span>
          </div>

          <InteractiveTerminal />
        </div>
      </section>

      {/* Tactical Platform Capabilities Matrix (FIX #6 & #7: cards #FFFFFF with #E2E4EB border) */}
      <section className="max-w-6xl mx-auto px-6 pb-20">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="p-6 rounded-2xl bg-[#FFFFFF] dark:bg-[#111d30] border border-[#E2E4EB] dark:border-[#1f3352] space-y-3 relative overflow-hidden shadow-xs hover:border-[#9FEF00] transition-all">
            <div className="w-10 h-10 rounded-xl bg-[#E8FFF0] dark:bg-[#9fef00]/10 border border-[#9FEF00]/30 flex items-center justify-center text-[#3AAA00] dark:text-[#9fef00]">
              <Crosshair className="w-5 h-5" />
            </div>
            <h3 className="text-base font-bold text-[#0D0D1A] dark:text-[#ffffff]">Live Parameter Injection</h3>
            <p className="text-xs text-[#4A4A6A] dark:text-[#a4b1cd] leading-relaxed">
              Inject your engagement target parameters (TARGET_IP, LHOST, LPORT) to auto-populate commands across writeups for instant one-click execution.
            </p>
          </div>

          <div className="p-6 rounded-2xl bg-[#FFFFFF] dark:bg-[#111d30] border border-[#E2E4EB] dark:border-[#1f3352] space-y-3 relative overflow-hidden shadow-xs hover:border-[#9FEF00] transition-all">
            <div className="w-10 h-10 rounded-xl bg-[#E6F8FC] dark:bg-[#2de2e6]/10 border border-[#00B4D8]/30 flex items-center justify-center text-[#0090CC] dark:text-[#2de2e6]">
              <CheckSquare className="w-5 h-5" />
            </div>
            <h3 className="text-base font-bold text-[#0D0D1A] dark:text-[#ffffff]">Pentest Methodology Tracker</h3>
            <p className="text-xs text-[#4A4A6A] dark:text-[#a4b1cd] leading-relaxed">
              Interactive 5-phase operational checklists spanning Reconnaissance, Web Exploitation, and Root PrivEsc with progress persistence and Markdown export.
            </p>
          </div>

          <div className="p-6 rounded-2xl bg-[#FFFFFF] dark:bg-[#111d30] border border-[#E2E4EB] dark:border-[#1f3352] space-y-3 relative overflow-hidden shadow-xs hover:border-[#9FEF00] transition-all">
            <div className="w-10 h-10 rounded-xl bg-[#FAF5FF] dark:bg-[#a855f7]/10 border border-[#A855F7]/30 flex items-center justify-center text-[#9333EA] dark:text-[#a855f7]">
              <ShieldCheck className="w-5 h-5" />
            </div>
            <h3 className="text-base font-bold text-[#0D0D1A] dark:text-[#ffffff]">Hardened Security Baseline</h3>
            <p className="text-xs text-[#4A4A6A] dark:text-[#a4b1cd] leading-relaxed">
              Protected by strict Content-Security-Policy, anti-clickjacking frame guards, anti-brute-force rate limiting, and stored XSS sanitization.
            </p>
          </div>
        </div>
      </section>

      {/* Role-Based Permissions Architecture Section (FIX #7: alternating white section) */}
      <section className="border-y border-[#E2E4EB] dark:border-[#1f3352] bg-[#FFFFFF] dark:bg-[#111d30]/60 py-20 px-6 relative">
        <div className="max-w-6xl mx-auto space-y-12">
          <div className="text-center space-y-3">
            <div className="font-mono text-xs text-[#3AAA00] dark:text-[#9fef00] uppercase tracking-widest font-semibold">
              SECURITY ACCESS CONTROL // RBAC
            </div>
            <h2 className="text-3xl md:text-4xl font-extrabold text-[#0D0D1A] dark:text-[#ffffff]">
              Role-Separated Operational Capabilities
            </h2>
            <p className="text-xs md:text-sm text-[#4A4A6A] dark:text-[#a4b1cd] max-w-xl mx-auto">
              Clean separation of responsibilities: analysts freely browse, search, and export, while authorized administrators control the knowledge base.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {/* Standard User / Reader Card (FIX #6: cards with subtle border) */}
            <div className="p-8 rounded-2xl bg-[#F0F2F5] dark:bg-[#14233c]/60 border border-[#E2E4EB] dark:border-[#1f3352] space-y-5 hover:border-[#9FEF00] transition-all">
              <div className="flex items-center justify-between">
                <span className="font-mono text-xs font-bold text-[#0090CC] dark:text-[#2de2e6] px-3 py-1 rounded-full bg-[#E6F8FC] dark:bg-[#2de2e6]/10 border border-[#00B4D8]/30">
                  STANDARD ANALYST // USER
                </span>
                <span className="text-[11px] font-mono text-[#4A4A6A] dark:text-[#6c7d9c] px-2 py-0.5 rounded bg-[#E2E4EB] dark:bg-[#14233c]">
                  READ-ONLY
                </span>
              </div>
              <h3 className="text-xl font-bold text-[#0D0D1A] dark:text-[#ffffff]">Documentation Consumer</h3>
              <p className="text-xs text-[#4A4A6A] dark:text-[#a4b1cd] leading-relaxed">
                Team members and authorized operators can explore, research, search, and export writeups without danger of unintentional modification.
              </p>
              <ul className="space-y-3 text-xs font-mono text-[#4A4A6A] dark:text-[#a4b1cd] pt-2">
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#3AAA00] dark:text-[#9fef00] flex-shrink-0" />
                  <span>Browse all technical categories & writeups</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#3AAA00] dark:text-[#9fef00] flex-shrink-0" />
                  <span>Instant full-text search across commands & CVEs</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#3AAA00] dark:text-[#9fef00] flex-shrink-0" />
                  <span>Export notes to printable PDF and editable Word DOCX</span>
                </li>
                <li className="flex items-center gap-2.5 text-[#9A9AB0] dark:text-[#6c7d9c]">
                  <span className="w-4 h-4 text-center font-bold">✕</span>
                  <span className="line-through">Cannot edit or delete notes</span>
                </li>
                <li className="flex items-center gap-2.5 text-[#9A9AB0] dark:text-[#6c7d9c]">
                  <span className="w-4 h-4 text-center font-bold">✕</span>
                  <span className="line-through">Cannot create categories or upload ZIPs</span>
                </li>
              </ul>
            </div>

            {/* Admin Card */}
            <div className="p-8 rounded-2xl bg-[#F0F2F5] dark:bg-[#14233c]/60 border border-[#9FEF00]/50 dark:border-[#9fef00]/40 space-y-5 shadow-xl shadow-[#9FEF00]/5 relative overflow-hidden hover:border-[#9FEF00] transition-all">
              <div className="absolute top-0 right-0 w-32 h-32 bg-[#9FEF00]/10 rounded-full blur-2xl pointer-events-none" />

              <div className="flex items-center justify-between">
                <span className="font-mono text-xs font-bold text-[#3AAA00] dark:text-[#9fef00] px-3 py-1 rounded-full bg-[#E8FFF0] dark:bg-[#9fef00]/10 border border-[#9FEF00]/40">
                  ADMINISTRATOR // LEAD RESEARCHER
                </span>
                <span className="text-[11px] font-mono text-[#3AAA00] dark:text-[#9fef00] px-2 py-0.5 rounded bg-[#E8FFF0] dark:bg-[#9fef00]/15 font-bold">
                  FULL CONTROL
                </span>
              </div>
              <h3 className="text-xl font-bold text-[#0D0D1A] dark:text-[#ffffff]">Authoring & Knowledge Architect</h3>
              <p className="text-xs text-[#4A4A6A] dark:text-[#a4b1cd] leading-relaxed">
                Full privileges to publish new research, batch import Markdown writeups, manage taxonomy domains, and review immutable audit trails.
              </p>
              <ul className="space-y-3 text-xs font-mono text-[#4A4A6A] dark:text-[#a4b1cd] pt-2">
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#3AAA00] dark:text-[#9fef00] flex-shrink-0" />
                  <span>Split-Screen Live Editor with quick cybersecurity snippets</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#3AAA00] dark:text-[#9fef00] flex-shrink-0" />
                  <span>Create & customize categories directly in UI</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#3AAA00] dark:text-[#9fef00] flex-shrink-0" />
                  <span>Batch drag-and-drop Markdown & ZIP archives</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#3AAA00] dark:text-[#9fef00] flex-shrink-0" />
                  <span>Document versioning and audit log review</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-[#3AAA00] dark:text-[#9fef00] flex-shrink-0" />
                  <span>Soft-delete and document lifecycle management</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Documentation Preview (FIX #6: cards #FFFFFF with #E2E4EB border) */}
      <section className="max-w-6xl mx-auto py-20 px-6 space-y-8">
        <div className="flex items-center justify-between">
          <div>
            <div className="font-mono text-xs text-[#3AAA00] dark:text-[#9fef00]">REPOSITORY SNAPSHOT</div>
            <h2 className="text-2xl font-bold text-[#0D0D1A] dark:text-[#ffffff] mt-1">Featured Research Notes</h2>
          </div>
          <Link
            href="/notes"
            className="text-xs font-mono text-[#0090CC] hover:text-[#3AAA00] dark:text-[#2de2e6] dark:hover:text-[#9fef00] hover:underline flex items-center gap-1.5"
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
              className="group p-6 rounded-2xl bg-[#FFFFFF] dark:bg-[#111d30] border border-[#E2E4EB] dark:border-[#1f3352] hover:border-[#9FEF00] flex flex-col justify-between shadow-xs transition-all"
            >
              <div className="space-y-3">
                <div className="text-[11px] font-mono text-[#3AAA00] dark:text-[#9fef00] flex items-center gap-1.5">
                  <Folder className="w-3.5 h-3.5" />
                  <span>{note.category?.name || "General"}</span>
                </div>
                <h3 className="font-bold text-base text-[#0D0D1A] group-hover:text-[#3AAA00] dark:text-[#ffffff] dark:group-hover:text-[#9fef00] transition-colors line-clamp-2">
                  {note.title}
                </h3>
                <p className="text-xs text-[#4A4A6A] dark:text-[#a4b1cd] line-clamp-2 leading-relaxed">
                  {note.description || "Operational commands and structured technical documentation."}
                </p>
              </div>

              <div className="pt-4 mt-4 border-t border-[#E2E4EB] dark:border-[#1f3352] flex items-center justify-between text-[11px] font-mono text-[#9A9AB0] dark:text-[#6c7d9c]">
                <span>{note.readingTimeMin}m read</span>
                <span className="text-[#3AAA00] dark:text-[#9fef00] group-hover:translate-x-1 transition-transform flex items-center gap-1 font-semibold">
                  Read Note &rarr;
                </span>
              </div>
            </Link>
          ))}
        </div>
      </section>

      {/* Footer (KEEP #2: Stays dark #0D0D1A in both modes) */}
      <footer className="border-t border-[#1A1A2E] bg-[#0D0D1A] py-10 px-6 text-xs font-mono text-[#9A9AB0]">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2.5">
            <div className="w-6 h-6 rounded-md overflow-hidden border border-[#9fef00]/40 flex-shrink-0">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/logo.png" alt="Index 389" className="w-full h-full object-cover" />
            </div>
            <span className="text-[#FFFFFF] font-bold">INDEX 389 PLATFORM</span>
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
