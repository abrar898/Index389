"use client";

import React, { useState, useRef } from "react";
import Link from "next/link";
import { MarkdownRenderer } from "@/components/markdown/MarkdownRenderer";
import { RightSidebar } from "@/components/layout/RightSidebar";
import { TocItem } from "@/lib/markdown";
import { useFocusReading } from "@/components/layout/FocusReadingContext";
import {
  Folder,
  Clock,
  Calendar,
  Edit3,
  FileDown,
  ArrowLeft,
  ArrowRight,
  Expand,
  Shrink,
  Search,
  ChevronDown,
  ChevronUp,
  X,
} from "lucide-react";
import { FavoriteButton } from "@/components/notes/FavoriteButton";
import { TargetVariablesBar } from "@/components/notes/TargetVariablesBar";
import { AcademyNoteNavbar } from "@/components/notes/AcademyNoteNavbar";

interface NoteViewerContainerProps {
  doc: {
    id: string;
    title: string;
    slug: string;
    description: string | null;
    updatedAt: Date | string;
    readingTimeMin: number;
    category?: { name: string; slug: string } | null;
    tags: { tag: { id: string; name: string } }[];
    author: { name: string | null; email: string };
  };
  cleanMarkdown: string;
  toc: TocItem[];
  userCanEdit: boolean;
  initialFavorited?: boolean;
  prevDoc: { title: string; slug: string } | null;
  nextDoc: { title: string; slug: string } | null;
  relatedNotes: { title: string; slug: string }[];
}

export function NoteViewerContainer({
  doc,
  cleanMarkdown,
  toc,
  userCanEdit,
  initialFavorited = false,
  prevDoc,
  nextDoc,
  relatedNotes,
}: NoteViewerContainerProps) {
  const { isFocusMode, toggleFocusMode } = useFocusReading();
  const [searchTerm, setSearchTerm] = useState("");
  const [activeMatchIndex, setActiveMatchIndex] = useState(0);
  const [matchCount, setMatchCount] = useState(0);
  const activeElementRef = useRef<HTMLElement | null>(null);

  const clearHighlight = () => {
    if (activeElementRef.current) {
      activeElementRef.current.classList.remove(
        "ring-2",
        "ring-[#9fef00]",
        "bg-[#9fef00]/25",
        "rounded-md",
        "shadow-[0_0_15px_rgba(159,239,0,0.4)]"
      );
      activeElementRef.current = null;
    }
  };

  const highlightAndScrollTo = (target: HTMLElement) => {
    clearHighlight();
    target.scrollIntoView({ behavior: "smooth", block: "center" });
    target.classList.add(
      "ring-2",
      "ring-[#9fef00]",
      "bg-[#9fef00]/25",
      "rounded-md",
      "shadow-[0_0_15px_rgba(159,239,0,0.4)]",
      "transition-all",
      "duration-200"
    );
    activeElementRef.current = target;
  };

  // In-page search logic: scrolls to text within article and highlights
  const handleSearch = (term: string) => {
    setSearchTerm(term);
    if (!term.trim()) {
      clearHighlight();
      setMatchCount(0);
      setActiveMatchIndex(0);
      return;
    }

    if (typeof window !== "undefined") {
      const articleEl = document.getElementById("note-article-content");
      if (!articleEl) return;

      const walker = document.createTreeWalker(articleEl, NodeFilter.SHOW_TEXT);
      let node;
      const matchingNodes: Node[] = [];
      const lower = term.toLowerCase();

      while ((node = walker.nextNode())) {
        if (node.nodeValue && node.nodeValue.toLowerCase().includes(lower)) {
          matchingNodes.push(node);
        }
      }

      setMatchCount(matchingNodes.length);
      if (matchingNodes.length > 0) {
        setActiveMatchIndex(1);
        const target = matchingNodes[0].parentElement;
        if (target) {
          highlightAndScrollTo(target);
        }
      } else {
        clearHighlight();
        setActiveMatchIndex(0);
      }
    }
  };

  const handleNextMatch = () => {
    if (matchCount === 0 || !searchTerm.trim()) return;
    const nextIdx = activeMatchIndex >= matchCount ? 1 : activeMatchIndex + 1;
    setActiveMatchIndex(nextIdx);

    const articleEl = document.getElementById("note-article-content");
    if (!articleEl) return;

    const walker = document.createTreeWalker(articleEl, NodeFilter.SHOW_TEXT);
    let node;
    const matchingNodes: Node[] = [];
    const lower = searchTerm.toLowerCase();

    while ((node = walker.nextNode())) {
      if (node.nodeValue && node.nodeValue.toLowerCase().includes(lower)) {
        matchingNodes.push(node);
      }
    }

    const targetNode = matchingNodes[nextIdx - 1];
    if (targetNode?.parentElement) {
      highlightAndScrollTo(targetNode.parentElement);
    }
  };

  const handlePrevMatch = () => {
    if (matchCount === 0 || !searchTerm.trim()) return;
    const prevIdx = activeMatchIndex <= 1 ? matchCount : activeMatchIndex - 1;
    setActiveMatchIndex(prevIdx);

    const articleEl = document.getElementById("note-article-content");
    if (!articleEl) return;

    const walker = document.createTreeWalker(articleEl, NodeFilter.SHOW_TEXT);
    let node;
    const matchingNodes: Node[] = [];
    const lower = searchTerm.toLowerCase();

    while ((node = walker.nextNode())) {
      if (node.nodeValue && node.nodeValue.toLowerCase().includes(lower)) {
        matchingNodes.push(node);
      }
    }

    const targetNode = matchingNodes[prevIdx - 1];
    if (targetNode?.parentElement) {
      highlightAndScrollTo(targetNode.parentElement);
    }
  };

  const [tocOpen, setTocOpen] = useState(true);

  return (
    <div className="w-full transition-all duration-300 relative space-y-6">
      {/* Academy Note Sub-Navbar (fixed/sticky directly under top navbar, never moves on scroll) */}
      {!isFocusMode && (
        <div className="-mx-4 sm:-mx-6 md:-mx-8 -mt-4 sm:-mt-6 md:-mt-8 mb-6 sticky top-14 z-20">
          <AcademyNoteNavbar
            title={doc.title}
            category={doc.category}
            documentId={doc.id}
            slug={doc.slug}
            initialFavorited={initialFavorited}
            userCanEdit={userCanEdit}
            onToggleTocDrawer={() => setTocOpen(!tocOpen)}
          />
        </div>
      )}

      <div className="flex gap-6 items-start w-full relative">
        {/* Center Main Content (Expands to 100% full width when TOC is closed or Focus Mode is active) */}
        <div
          className={`min-w-0 transition-all duration-300 ${
            isFocusMode || !tocOpen ? "w-full max-w-full flex-1" : "flex-1 max-w-[calc(100%-19.5rem)]"
          }`}
        >
          {/* Document Header Panel: Scrolls up and hides away naturally as content scrolls */}
          {!isFocusMode && (
            <div className="mb-6">
              {/* Breadcrumbs */}
              <nav className="flex items-center gap-2 text-xs font-mono text-[#6c7d9c] mb-3">
                <Link href="/notes" className="hover:text-[#9fef00] transition-colors">
                  NOTES
                </Link>
              <span>/</span>
              {doc.category ? (
                <>
                  <Link
                    href={`/categories/${doc.category.slug}`}
                    className="hover:text-[#9fef00] transition-colors uppercase"
                  >
                    {doc.category.name}
                  </Link>
                  <span>/</span>
                </>
              ) : null}
              <span className="text-[#ffffff] truncate font-semibold uppercase">{doc.title}</span>
            </nav>

            {/* Header Card */}
            <div className="p-6 rounded-2xl glass-panel border-[#1f3352] space-y-4 shadow-xl glow-emerald-box">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div className="flex items-center gap-2 flex-wrap">
                  {doc.category && (
                    <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded bg-[#9fef00]/10 text-[#9fef00] border border-[#9fef00]/30 font-mono text-xs font-semibold">
                      <Folder className="w-3.5 h-3.5" />
                      {doc.category.name}
                    </span>
                  )}
                  {doc.tags.map(({ tag }) => (
                    <span
                      key={tag.id}
                      className="px-2 py-0.5 rounded bg-[#070b13] border border-[#1f3352] font-mono text-xs text-[#8ba0c3]"
                    >
                      #{tag.name}
                    </span>
                  ))}
                </div>

                {/* Action Toolbar */}
                <div className="flex items-center gap-2">
                  <FavoriteButton
                    documentId={doc.id}
                    initialFavorited={initialFavorited}
                  />

                  {userCanEdit && (
                    <Link
                      href={`/notes/${doc.slug}/edit`}
                      className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[#14233c] hover:bg-[#182844] border border-[#1f3352] text-xs font-medium text-[#ffffff] transition-colors"
                    >
                      <Edit3 className="w-3.5 h-3.5 text-[#9fef00]" />
                      <span>Edit Note</span>
                    </Link>
                  )}

                  <a
                    href={`/api/documents/${doc.slug}/export/pdf`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[#14233c] hover:bg-[#182844] border border-[#1f3352] text-xs font-medium text-[#ffffff] transition-colors"
                    title="Download PDF"
                  >
                    <FileDown className="w-3.5 h-3.5 text-[#ff3366]" />
                    <span>PDF</span>
                  </a>

                  <a
                    href={`/api/documents/${doc.slug}/export/docx`}
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[#14233c] hover:bg-[#182844] border border-[#1f3352] text-xs font-medium text-[#ffffff] transition-colors"
                    title="Download DOCX"
                  >
                    <FileDown className="w-3.5 h-3.5 text-[#2de2e6]" />
                    <span>DOCX</span>
                  </a>
                </div>
              </div>

              <h1 className="text-3xl font-extrabold tracking-tight text-white leading-snug">
                {doc.title}
              </h1>

              {doc.description && (
                <p className="text-xs text-[#a4b1cd] leading-relaxed border-l-2 border-[#9fef00] pl-3">
                  {doc.description}
                </p>
              )}

              <div className="flex flex-wrap items-center gap-4 pt-3 border-t border-[#1f3352] text-xs text-[#6c7d9c] font-mono">
                <span className="flex items-center gap-1.5">
                  <Calendar className="w-3.5 h-3.5 text-[#9fef00]" />
                  {new Date(doc.updatedAt).toLocaleDateString("en-US", {
                    year: "numeric",
                    month: "short",
                    day: "numeric",
                  })}
                </span>
                <span>•</span>
                <span className="flex items-center gap-1.5">
                  <Clock className="w-3.5 h-3.5 text-[#9fef00]" />
                  {doc.readingTimeMin} min read
                </span>
                <span>•</span>
                <span>Author: {doc.author.name || doc.author.email}</span>
              </div>
            </div>
          </div>
        )}

        {/* Content Box with Sticky In-Card Controls Header (Search + Expand/Standard View Button) */}
        <div
          className={`glass-panel rounded-2xl border-[#1f3352] shadow-2xl transition-all mx-auto w-full`}
        >
          {/* Top In-Content Sticky Header Bar with Search Box and Action Button INSIDE the Card */}
          <div className="sticky top-0 z-30 px-5 py-3 bg-[#111d30]/95 backdrop-blur-xl border-b border-[#1f3352] rounded-t-2xl flex flex-wrap items-center justify-between gap-3 shadow-lg">
            {/* Search Box directly on the content card */}
            <div className="relative flex-1 min-w-[240px] max-w-md">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#6c7d9c]" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => handleSearch(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                    if (e.shiftKey) {
                      handlePrevMatch();
                    } else {
                      handleNextMatch();
                    }
                  } else if (e.key === "Escape") {
                    handleSearch("");
                  }
                }}
                placeholder="Search note content (Press Enter for next)..."
                className="w-full pl-9 pr-28 py-1.5 rounded-lg bg-[#0b121e] border border-[#1f3352] text-xs font-mono text-[#ffffff] placeholder-[#6c7d9c] focus:border-[#9fef00] focus:ring-1 focus:ring-[#9fef00] focus:outline-none transition-all"
              />

              {searchTerm.trim() !== "" && (
                <div className="absolute right-2 top-1/2 -translate-y-1/2 flex items-center gap-1 text-[11px] font-mono">
                  {matchCount > 0 ? (
                    <span className="px-1.5 py-0.5 rounded bg-[#9fef00]/20 text-[#9fef00] font-semibold text-[10px]">
                      {activeMatchIndex}/{matchCount}
                    </span>
                  ) : (
                    <span className="px-1.5 py-0.5 rounded bg-[#ff3366]/20 text-[#ff3366] text-[10px]">
                      0 found
                    </span>
                  )}
                  <button
                    type="button"
                    onClick={handlePrevMatch}
                    disabled={matchCount === 0}
                    className="p-1 text-[#6c7d9c] hover:text-[#9fef00] disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
                    title="Previous match (Shift+Enter)"
                  >
                    <ChevronUp className="w-3.5 h-3.5" />
                  </button>
                  <button
                    type="button"
                    onClick={handleNextMatch}
                    disabled={matchCount === 0}
                    className="p-1 text-[#6c7d9c] hover:text-[#9fef00] disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
                    title="Next match (Enter)"
                  >
                    <ChevronDown className="w-3.5 h-3.5" />
                  </button>
                  <button
                    type="button"
                    onClick={() => handleSearch("")}
                    className="p-1 text-[#6c7d9c] hover:text-[#ff3366] transition-colors"
                    title="Clear search (Esc)"
                  >
                    <X className="w-3.5 h-3.5" />
                  </button>
                </div>
              )}
            </div>

            <div className="flex items-center gap-2 flex-shrink-0">
              {/* In-Card Favorite Button */}
              <FavoriteButton
                documentId={doc.id}
                initialFavorited={initialFavorited}
                showText={false}
                className="py-1.5 px-2.5 rounded-xl bg-[#14233c] border-[#1f3352]"
              />

              {/* Standard View / Whole Page Display Button located INSIDE the content box */}
              <button
                type="button"
                onClick={toggleFocusMode}
                className={`flex items-center gap-2 px-3.5 py-1.5 rounded-xl text-xs font-mono font-bold transition-all shadow-md active:scale-95 flex-shrink-0 cursor-pointer ${
                  isFocusMode
                    ? "bg-[#9fef00] hover:bg-[#b4fa1f] text-[#0b121e] border border-[#9fef00]/40 shadow-[#9fef00]/30 hover:shadow-lg"
                    : "bg-[#14233c] text-[#8ba0c3] hover:text-[#9fef00] border border-[#1f3352] hover:border-[#9fef00]/60 hover:bg-[#182844]"
                }`}
                title={isFocusMode ? "Revert to standard view" : "Extend to whole page display"}
              >
                {isFocusMode ? (
                  <>
                    <Shrink className="w-3.5 h-3.5 text-[#0b121e]" />
                    <span>Standard View &larr;</span>
                  </>
                ) : (
                  <>
                    <span>Whole Page Display</span>
                    <Expand className="w-3.5 h-3.5 text-[#9fef00]" />
                  </>
                )}
              </button>
            </div>
          </div>

          {/* Rendered Technical Markdown Content Article */}
          <article
            id="note-article-content"
            className={`p-6 md:p-12 leading-relaxed transition-all rounded-b-2xl ${
              isFocusMode ? "text-base leading-loose" : "text-sm"
            }`}
          >
            <MarkdownRenderer content={cleanMarkdown} />
          </article>
        </div>

        {/* Previous / Next Document Navigation */}
        <div className="mt-8 pt-6 border-t border-[#1f3352] grid grid-cols-1 md:grid-cols-2 gap-4">
          {prevDoc ? (
            <Link
              href={`/notes/${prevDoc.slug}`}
              className="flex flex-col p-4 rounded-xl border border-[#1f3352] bg-[#111d30] hover:border-[#9fef00] transition-all group"
            >
              <span className="text-[10px] font-mono text-[#6c7d9c] flex items-center gap-1">
                <ArrowLeft className="w-3 h-3 group-hover:-translate-x-1 transition-transform text-[#9fef00]" />
                PREVIOUS NOTE
              </span>
              <span className="text-xs font-semibold text-[#ffffff] group-hover:text-[#9fef00] mt-1 truncate">
                {prevDoc.title}
              </span>
            </Link>
          ) : (
            <div />
          )}

          {nextDoc ? (
            <Link
              href={`/notes/${nextDoc.slug}`}
              className="flex flex-col items-end p-4 rounded-lg border border-[#1f3352] bg-[#111d30] hover:border-[#9fef00] transition-all group text-right"
            >
              <span className="text-[10px] font-mono text-[#6c7d9c] flex items-center gap-1">
                NEXT NOTE
                <ArrowRight className="w-3 h-3 group-hover:translate-x-1 transition-transform text-[#9fef00]" />
              </span>
              <span className="text-xs font-semibold text-[#ffffff] group-hover:text-[#9fef00] mt-1 truncate">
                {nextDoc.title}
              </span>
            </Link>
          ) : (
            <div />
          )}
        </div>
      </div>

      {/* Right Table of Contents Sidebar: Automatically hidden in Whole Page Display */}
      {!isFocusMode && (
        <RightSidebar
          toc={toc}
          readingTimeMin={doc.readingTimeMin}
          relatedNotes={relatedNotes}
          documentSlug={doc.slug}
          isOpen={tocOpen}
          onToggleOpen={(open) => setTocOpen(open)}
        />
      )}
      </div>
    </div>
  );
}
