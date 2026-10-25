import Link from "next/link";
import prisma from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import {
  Terminal,
  FileText,
  Upload,
  Shield,
  Clock,
  ArrowRight,
  Folder,
  Tag,
  Bookmark,
  Sparkles,
  Layers,
  Activity,
  Flame,
} from "lucide-react";

export default async function DashboardPage() {
  const user = await getCurrentUser();

  const [recentDocs, totalDocs, totalCategories, totalTags] = await Promise.all([
    prisma.document.findMany({
      where: { deletedAt: null },
      orderBy: { updatedAt: "desc" },
      take: 6,
      include: {
        category: true,
        tags: { include: { tag: true } },
        author: { select: { name: true, email: true } },
      },
    }),
    prisma.document.count({ where: { deletedAt: null } }),
    prisma.category.count(),
    prisma.tag.count(),
  ]);

  return (
    <div className="space-y-8">
      {/* Welcome Hero Banner with HTB Slate & Green Glow */}
      <div className="relative overflow-hidden rounded-2xl glass-panel border-[#1f3352] p-8 shadow-2xl relative glow-emerald-box">
        <div className="absolute top-0 right-0 w-80 h-80 bg-gradient-to-bl from-[#9fef00]/15 via-[#2de2e6]/5 to-transparent rounded-full blur-3xl pointer-events-none" />

        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div className="space-y-2.5">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#9fef00]/10 text-[#9fef00] border border-[#9fef00]/30 font-mono text-xs shadow-sm">
              <span className="w-2 h-2 rounded-full bg-[#9fef00] animate-pulse" />
              <span>TERMINAL ENGAGED // INDEX 389 REPO</span>
            </div>
            <h1 className="text-3xl font-extrabold tracking-tight text-[#ffffff]">
              Welcome back, <span className="text-[#9fef00]">{user?.name || "Security Researcher"}</span>
            </h1>
            <p className="text-xs md:text-sm text-[#a4b1cd] max-w-2xl leading-relaxed">
              Personal cybersecurity knowledge repository and documentation engine. Upload Markdown logs,
              preserve command syntax, and export to publication-ready PDF or Word documents.
            </p>
          </div>

          {user?.role === "ADMIN" && (
            <div className="flex flex-wrap items-center gap-3">
              <Link
                href="/import"
                className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-[#14233c] hover:bg-[#182844] border border-[#1f3352] text-xs font-semibold text-[#ffffff] transition-all shadow-sm active:scale-95"
              >
                <Upload className="w-4 h-4 text-[#9fef00]" />
                <span>Import Vault</span>
              </Link>
              <Link
                href="/notes/new"
                className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-[#9fef00] hover:bg-[#b4fa1f] text-xs font-bold text-[#0b121e] transition-all shadow-lg shadow-[#9fef00]/20 active:scale-95"
              >
                <FileText className="w-4 h-4" />
                <span>Create Note</span>
              </Link>
            </div>
          )}
        </div>
      </div>

      {/* Quick Metrics Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="p-4 sm:p-5 rounded-2xl glass-panel glass-panel-hover flex items-center justify-between border-[var(--surface-border)]">
          <div>
            <div className="text-[11px] font-mono uppercase tracking-wider text-[var(--foreground-muted)]">
              Documentation
            </div>
            <div className="text-2xl sm:text-3xl font-extrabold font-mono text-[var(--foreground-bright)] mt-1">{totalDocs}</div>
            <div className="text-[10px] font-mono text-[#9fef00] mt-0.5">Active writeups</div>
          </div>
          <div className="w-10 h-10 sm:w-11 sm:h-11 rounded-xl bg-[#9fef00]/10 border border-[#9fef00]/20 flex items-center justify-center text-[#9fef00] flex-shrink-0">
            <FileText className="w-5 h-5" />
          </div>
        </div>

        <div className="p-4 sm:p-5 rounded-2xl glass-panel glass-panel-hover flex items-center justify-between border-[var(--surface-border)]">
          <div>
            <div className="text-[11px] font-mono uppercase tracking-wider text-[var(--foreground-muted)]">
              Taxonomy Domains
            </div>
            <div className="text-2xl sm:text-3xl font-extrabold font-mono text-[var(--foreground-bright)] mt-1">{totalCategories}</div>
            <div className="text-[10px] font-mono text-[#2de2e6] mt-0.5">Structured domains</div>
          </div>
          <div className="w-10 h-10 sm:w-11 sm:h-11 rounded-xl bg-[#2de2e6]/10 border border-[#2de2e6]/20 flex items-center justify-center text-[#2de2e6] flex-shrink-0">
            <Folder className="w-5 h-5" />
          </div>
        </div>

        <div className="p-4 sm:p-5 rounded-2xl glass-panel glass-panel-hover flex items-center justify-between border-[var(--surface-border)]">
          <div>
            <div className="text-[11px] font-mono uppercase tracking-wider text-[var(--foreground-muted)]">
              Research Tags
            </div>
            <div className="text-2xl sm:text-3xl font-extrabold font-mono text-[var(--foreground-bright)] mt-1">{totalTags}</div>
            <div className="text-[10px] font-mono text-[#ff8400] mt-0.5">Indexed flags & CVEs</div>
          </div>
          <div className="w-10 h-10 sm:w-11 sm:h-11 rounded-xl bg-[#ff8400]/10 border border-[#ff8400]/20 flex items-center justify-center text-[#ff8400] flex-shrink-0">
            <Tag className="w-5 h-5" />
          </div>
        </div>

        <div className="p-4 sm:p-5 rounded-2xl glass-panel glass-panel-hover flex items-center justify-between border-[var(--surface-border)]">
          <div>
            <div className="text-[11px] font-mono uppercase tracking-wider text-[var(--foreground-muted)]">
              Operator Status
            </div>
            <div className="text-sm font-extrabold font-mono text-[#9fef00] mt-2">
              [{user?.role || "GUEST"}]
            </div>
            <div className="text-[10px] font-mono text-[var(--foreground-muted)] mt-0.5">
              {user?.role === "ADMIN" ? "Full Control Access" : "Read-Only Access"}
            </div>
          </div>
          <div className="w-10 h-10 sm:w-11 sm:h-11 rounded-xl bg-[#9fef00]/10 border border-[#9fef00]/20 flex items-center justify-center text-[#9fef00] flex-shrink-0">
            <Shield className="w-5 h-5" />
          </div>
        </div>
      </div>

      {/* Recent Notes Section */}
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <Activity className="w-4 h-4 text-[#9fef00]" />
            <h2 className="text-base font-bold text-[#ffffff]">Recently Indexed Research</h2>
          </div>
          <Link
            href="/notes"
            className="text-xs font-mono text-[#9fef00] hover:underline flex items-center gap-1.5"
          >
            <span>View complete repository</span>
            <ArrowRight className="w-3.5 h-3.5" />
          </Link>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {recentDocs.map((doc) => (
            <Link
              key={doc.id}
              href={`/notes/${doc.slug}`}
              className="group flex flex-col justify-between p-5 rounded-2xl glass-panel glass-panel-hover border-[#1f3352]"
            >
              <div className="space-y-3">
                <div className="flex items-center justify-between text-[11px]">
                  {doc.category ? (
                    <span className="font-mono text-[#9fef00] flex items-center gap-1.5 bg-[#9fef00]/10 px-2.5 py-0.5 rounded-full border border-[#9fef00]/20">
                      <Folder className="w-3 h-3" />
                      {doc.category.name}
                    </span>
                  ) : (
                    <span className="text-[#6c7d9c]">Uncategorized</span>
                  )}
                  <span className="font-mono text-[#6c7d9c]">{doc.readingTimeMin}m read</span>
                </div>

                <h3 className="font-bold text-base text-[#ffffff] group-hover:text-[#9fef00] transition-colors line-clamp-1">
                  {doc.title}
                </h3>

                <p className="text-xs text-[#a4b1cd] line-clamp-2 leading-relaxed">
                  {doc.description || "Technical cybersecurity notes and operational walkthrough."}
                </p>
              </div>

              <div className="pt-4 mt-4 border-t border-[#1f3352] flex items-center justify-between text-[11px] text-[#6c7d9c]">
                <div className="flex items-center gap-1.5">
                  {doc.tags.slice(0, 2).map(({ tag }) => (
                    <span
                      key={tag.id}
                      className="px-2 py-0.5 rounded-md bg-[#111d30] border border-[#1f3352] font-mono text-[10px] text-[#8ba0c3]"
                    >
                      #{tag.name}
                    </span>
                  ))}
                </div>
                <span className="font-mono text-[10px]">
                  {new Date(doc.updatedAt).toLocaleDateString("en-US", {
                    month: "short",
                    day: "numeric",
                  })}
                </span>
              </div>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
