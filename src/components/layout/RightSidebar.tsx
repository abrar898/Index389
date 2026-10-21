"use client";

import React, { useEffect, useState, useMemo } from "react";
import Link from "next/link";
import { TocItem } from "@/lib/markdown";
import {
  Clock,
  FileDown,
  ArrowUpRight,
  Menu,
  X,
  ChevronDown,
  ChevronRight,
  CheckCircle2,
  ListOrdered,
} from "lucide-react";

interface RightSidebarProps {
  toc: TocItem[];
  readingTimeMin: number;
  relatedNotes?: { title: string; slug: string }[];
  documentSlug?: string;
  isOpen?: boolean;
  onToggleOpen?: (open: boolean) => void;
}

interface TocModule {
  id: string;
  number: string;
  title: string;
  subsections: TocItem[];
  isCompleted?: boolean;
}

export function RightSidebar({
  toc,
  readingTimeMin,
  relatedNotes = [],
  documentSlug,
  isOpen = true,
  onToggleOpen,
}: RightSidebarProps) {
  const [activeId, setActiveId] = useState<string>("");
  const [scrollProgress, setScrollProgress] = useState(0);
  const [isMobileDrawerOpen, setIsMobileDrawerOpen] = useState(false);
  const [isDesktopVisible, setIsDesktopVisible] = useState(isOpen);
  const [expandedModules, setExpandedModules] = useState<Record<string, boolean>>({});

  // Sync external open state
  useEffect(() => {
    setIsDesktopVisible(isOpen);
    setIsMobileDrawerOpen(isOpen);
  }, [isOpen]);

  const handleClose = () => {
    setIsDesktopVisible(false);
    setIsMobileDrawerOpen(false);
    if (onToggleOpen) onToggleOpen(false);
  };

  // Group flat headings into structured Academy-style chapters/modules
  const modules: TocModule[] = useMemo(() => {
    if (!toc || toc.length === 0) return [];

    const result: TocModule[] = [];
    let currentModule: TocModule | null = null;
    let fallbackCounter = 1;

    toc.forEach((item) => {
      // Treat level 1 or level 2 as main numbered chapters
      // If no level 1 exists, level 2 headers form the primary modules
      const isTopLevel = item.level === 1 || (item.level === 2 && !toc.some((t) => t.level === 1));

      if (isTopLevel) {
        currentModule = {
          id: item.id,
          number: item.sectionNumber || String(fallbackCounter++),
          title: item.text,
          subsections: [],
        };
        result.push(currentModule);
      } else {
        if (!currentModule) {
          currentModule = {
            id: item.id,
            number: item.sectionNumber || String(fallbackCounter++),
            title: item.text,
            subsections: [],
          };
          result.push(currentModule);
        } else {
          currentModule.subsections.push(item);
        }
      }
    });

    return result;
  }, [toc]);

  // Expand the active module automatically
  useEffect(() => {
    if (!activeId || modules.length === 0) return;
    for (const mod of modules) {
      if (mod.id === activeId || mod.subsections.some((sub) => sub.id === activeId)) {
        setExpandedModules((prev) => ({ ...prev, [mod.id]: true }));
        break;
      }
    }
  }, [activeId, modules]);

  // Initial expand state: first module opened
  useEffect(() => {
    if (modules.length > 0) {
      setExpandedModules((prev) => {
        if (Object.keys(prev).length === 0) {
          return { [modules[0].id]: true };
        }
        return prev;
      });
    }
  }, [modules]);

  // Scroll listener for reading progress & active heading
  useEffect(() => {
    const handleScroll = () => {
      const totalScroll = document.documentElement.scrollHeight - window.innerHeight;
      if (totalScroll > 0) {
        setScrollProgress(Math.min(100, Math.max(0, (window.scrollY / totalScroll) * 100)));
      }

      const headingElements = toc.map((item) => document.getElementById(item.id)).filter(Boolean);
      for (let i = headingElements.length - 1; i >= 0; i--) {
        const el = headingElements[i];
        if (el && el.getBoundingClientRect().top <= 150) {
          setActiveId(el.id);
          return;
        }
      }
      if (headingElements.length > 0 && window.scrollY < 120) {
        setActiveId(headingElements[0]?.id || "");
      }
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, [toc]);

  const toggleModule = (id: string) => {
    setExpandedModules((prev) => ({
      ...prev,
      [id]: !prev[id],
    }));
  };

  const SidebarContent = () => (
    <div className="flex flex-col h-full space-y-4">
      {/* Academy Header */}
      <div className="flex items-center justify-between pb-2.5 border-b border-[var(--surface-border)]">
        <div className="flex items-center gap-1.5">
          <ListOrdered className="w-3.5 h-3.5 text-[#9fef00]" />
          <h2 className="font-mono text-xs font-bold text-[var(--foreground-bright)] tracking-tight">
            Table of Contents
          </h2>
        </div>
        <div className="flex items-center gap-2.5 text-[11px] font-mono text-[var(--foreground-muted)]">
          <span className="flex items-center gap-1">
            <Clock className="w-3 h-3 text-[#9fef00]" />
            {readingTimeMin}m
          </span>
          <span className="font-bold text-[#9fef00]">{Math.round(scrollProgress)}%</span>
          {/* Close button (X) */}
          <button
            type="button"
            onClick={handleClose}
            className="p-1 rounded text-[var(--foreground-muted)] hover:text-[var(--foreground-bright)] hover:bg-[var(--surface-elevated)] transition-colors cursor-pointer"
            title="Hide Table of Contents"
            aria-label="Close Table of Contents"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>

      {/* Progress Track */}
      <div className="w-full h-1 bg-[var(--surface)] rounded-full overflow-hidden border border-[var(--surface-border)]">
        <div
          className="h-full bg-gradient-to-r from-[#9fef00] to-[#2de2e6] transition-all duration-200"
          style={{ width: `${scrollProgress}%` }}
        />
      </div>

      {/* Structured Academy Modules List with Visible Scrollbar - Compact Cards */}
      <div className="flex-1 overflow-y-auto pr-1.5 space-y-1.5 academy-scrollbar">
        {modules.length === 0 ? (
          <p className="text-[var(--foreground-muted)] italic text-[11px] py-4 text-center">
            No sections detected.
          </p>
        ) : (
          modules.map((mod) => {
            const isExpanded = !!expandedModules[mod.id];
            const isModuleActive =
              activeId === mod.id || mod.subsections.some((sub) => sub.id === activeId);

            return (
              <div
                key={mod.id}
                className={`rounded-lg border transition-all overflow-hidden ${
                  isModuleActive
                    ? "bg-[var(--surface-card)] border-[#9fef00]/50 shadow-sm shadow-[#9fef00]/5"
                    : "bg-[var(--surface)] border-[var(--surface-border)] hover:border-[var(--surface-border-hover)]"
                }`}
              >
                {/* Module Accordion Header Card - Compact Sizing */}
                <div
                  className="flex items-center justify-between p-2 gap-1.5 cursor-pointer select-none"
                  onClick={() => toggleModule(mod.id)}
                >
                  <a
                    href={`#${mod.id}`}
                    onClick={(e) => {
                      e.stopPropagation();
                      setIsMobileDrawerOpen(false);
                    }}
                    className="flex items-center gap-2 min-w-0 flex-1 group"
                  >
                    {/* Badge number circle */}
                    <div
                      className={`w-5 h-5 rounded-md flex items-center justify-center text-[10px] font-mono font-bold flex-shrink-0 transition-colors ${
                        isModuleActive
                          ? "bg-[#9fef00] text-[#0b121e]"
                          : "bg-[var(--surface-elevated)] text-[var(--foreground-bright)] group-hover:bg-[#9fef00]/20 group-hover:text-[#9fef00]"
                      }`}
                    >
                      {mod.number}
                    </div>

                    {/* Section Title - Exact Text from Note Markdown */}
                    <span
                      className={`text-[11.5px] font-medium truncate transition-colors leading-tight ${
                        isModuleActive
                          ? "text-[#9fef00] font-semibold"
                          : "text-[var(--foreground-bright)] group-hover:text-[#9fef00]"
                      }`}
                      title={mod.title}
                    >
                      {mod.title}
                    </span>
                  </a>

                  {/* Accordion Toggle (only if child headings exist) */}
                  {mod.subsections.length > 0 && (
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        toggleModule(mod.id);
                      }}
                      className="text-[var(--foreground-muted)] hover:text-[var(--foreground-bright)] transition-colors p-0.5 flex-shrink-0"
                      aria-label="Toggle section"
                    >
                      {isExpanded ? (
                        <ChevronDown className="w-3.5 h-3.5" />
                      ) : (
                        <ChevronRight className="w-3.5 h-3.5" />
                      )}
                    </button>
                  )}
                </div>

                {/* Subsections Drawer - Exact Child Headings with Hierarchical Numbering (1.1, 1.2, etc.) */}
                {isExpanded && mod.subsections.length > 0 && (
                  <div className="px-2 pb-2 pt-0.5 space-y-0.5 border-t border-[var(--surface-border)]/60 bg-[var(--surface-elevated)]/40">
                    {mod.subsections.map((sub) => {
                      const isSubActive = activeId === sub.id;
                      return (
                        <a
                          key={sub.id}
                          href={`#${sub.id}`}
                          onClick={() => setIsMobileDrawerOpen(false)}
                          className={`flex items-center gap-1.5 py-1 px-2 rounded-md text-[11px] transition-all group ${
                            isSubActive
                              ? "bg-[#9fef00]/15 text-[#9fef00] font-semibold"
                              : "text-[var(--foreground-muted)] hover:text-[var(--foreground-bright)] hover:bg-[var(--surface-card)]"
                          }`}
                        >
                          {sub.sectionNumber ? (
                            <span
                              className={`text-[9.5px] font-mono px-1 py-0.2 rounded font-semibold flex-shrink-0 transition-colors ${
                                isSubActive
                                  ? "bg-[#9fef00] text-[#0b121e]"
                                  : "bg-[var(--surface-card)] text-[var(--foreground-muted)] group-hover:text-[#9fef00]"
                              }`}
                            >
                              {sub.sectionNumber}
                            </span>
                          ) : (
                            <span
                              className={`w-1.5 h-1.5 rounded-full flex-shrink-0 transition-colors ${
                                isSubActive ? "bg-[#9fef00]" : "bg-[var(--foreground-muted)]/50 group-hover:bg-[#9fef00]"
                              }`}
                            />
                          )}
                          <span className="truncate leading-snug">{sub.text}</span>
                        </a>
                      );
                    })}
                  </div>
                )}
              </div>
            );
          })
        )}
      </div>

      {/* Export Options */}
      {documentSlug && (
        <div className="pt-2 border-t border-[var(--surface-border)] space-y-1.5">
          <span className="text-[9.5px] font-mono uppercase text-[var(--foreground-muted)] tracking-wider block">
            Export Options
          </span>
          <div className="grid grid-cols-2 gap-1.5">
            <a
              href={`/api/documents/${documentSlug}/export/pdf`}
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center justify-center gap-1.5 px-2 py-1.5 rounded-lg bg-[var(--surface)] hover:bg-[var(--surface-elevated)] border border-[var(--surface-border)] text-[var(--foreground-bright)] text-[11px] font-medium transition-colors shadow-sm"
            >
              <FileDown className="w-3 h-3 text-[#ff3366]" />
              <span>PDF</span>
            </a>
            <a
              href={`/api/documents/${documentSlug}/export/docx`}
              className="flex items-center justify-center gap-1.5 px-2 py-1.5 rounded-lg bg-[var(--surface)] hover:bg-[var(--surface-elevated)] border border-[var(--surface-border)] text-[var(--foreground-bright)] text-[11px] font-medium transition-colors shadow-sm"
            >
              <FileDown className="w-3 h-3 text-[#2de2e6]" />
              <span>DOCX</span>
            </a>
          </div>
        </div>
      )}

      {/* Related Notes */}
      {relatedNotes.length > 0 && (
        <div className="pt-2 border-t border-[var(--surface-border)] space-y-1">
          <span className="text-[9.5px] font-mono uppercase text-[var(--foreground-muted)] tracking-wider block">
            Related Research
          </span>
          <div className="space-y-0.5">
            {relatedNotes.slice(0, 3).map((note) => (
              <Link
                key={note.slug}
                href={`/notes/${note.slug}`}
                onClick={() => setIsMobileDrawerOpen(false)}
                className="block text-[var(--foreground-muted)] hover:text-[#9fef00] truncate text-[10.5px] transition-colors py-0.5"
              >
                • {note.title}
              </Link>
            ))}
          </div>
        </div>
      )}
    </div>
  );

  return (
    <>
      {/* 1. Desktop Sticky Academy TOC Sidebar (screens >= 1024px, toggleable by user) */}
      {isDesktopVisible && (
        <aside className="w-72 border border-[var(--surface-border)] p-3 hidden lg:flex flex-col text-xs sticky top-[7.25rem] h-[calc(100vh-8.5rem)] overflow-hidden rounded-xl glass-panel flex-shrink-0 animate-in fade-in slide-in-from-right-4 duration-200">
          <SidebarContent />
        </aside>
      )}

      {/* 2. Floating Toggle Button (screens < 1024px) */}
      <div className="lg:hidden fixed bottom-6 right-6 z-40">
        <button
          onClick={() => setIsMobileDrawerOpen(!isMobileDrawerOpen)}
          className="flex items-center gap-2 px-4 py-2.5 rounded-full bg-[#9fef00] hover:bg-[#b4fa1f] text-[#0b121e] font-bold text-xs shadow-2xl shadow-[#9fef00]/30 border border-[#9fef00]/40 active:scale-95 transition-all cursor-pointer"
          aria-label="Toggle Table of Contents"
        >
          <Menu className="w-4 h-4" />
          <span>Table of Contents</span>
          <span className="px-1.5 py-0.5 rounded-full bg-[#0b121e]/20 text-[10px] font-mono">
            {Math.round(scrollProgress)}%
          </span>
        </button>
      </div>

      {/* 3. Mobile Slide-over Drawer (screens < 1024px) */}
      {isMobileDrawerOpen && (
        <div className="lg:hidden fixed inset-0 z-50 flex justify-end">
          <div
            className="fixed inset-0 bg-black/75 backdrop-blur-xs animate-in fade-in duration-200"
            onClick={handleClose}
          />

          <div className="relative w-80 max-w-[88vw] h-full bg-[var(--surface)] border-l border-[var(--surface-border)] p-4 shadow-2xl flex flex-col z-10 animate-in slide-in-from-right duration-250">
            <div className="flex items-center justify-between pb-2.5 border-b border-[var(--surface-border)] mb-3">
              <span className="font-mono text-xs font-bold text-[var(--foreground-bright)]">
                TABLE OF CONTENTS
              </span>
              <button
                onClick={handleClose}
                className="p-1 rounded-lg text-[var(--foreground-muted)] hover:text-[var(--foreground-bright)] transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="flex-1 overflow-hidden">
              <SidebarContent />
            </div>
          </div>
        </div>
      )}
    </>
  );
}
