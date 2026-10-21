"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
import {
  ArrowLeft,
  Heart,
  Globe,
  FileCode,
  Sparkles,
  Edit3,
  HelpCircle,
  ListOrdered,
  Maximize2,
  Minimize2,
} from "lucide-react";
import { FavoriteButton } from "./FavoriteButton";
import { useFocusReading } from "@/components/layout/FocusReadingContext";

interface AcademyNoteNavbarProps {
  title: string;
  category?: { name: string; slug: string } | null;
  documentId: string;
  slug: string;
  initialFavorited?: boolean;
  userCanEdit?: boolean;
  onToggleTocDrawer?: () => void;
}

export function AcademyNoteNavbar({
  title,
  category,
  documentId,
  slug,
  initialFavorited = false,
  userCanEdit = false,
  onToggleTocDrawer,
}: AcademyNoteNavbarProps) {
  const [scrollProgress, setScrollProgress] = useState(0);
  const { isFocusMode, toggleFocusMode } = useFocusReading();

  useEffect(() => {
    const handleScroll = () => {
      const totalScroll = document.documentElement.scrollHeight - window.innerHeight;
      if (totalScroll > 0) {
        setScrollProgress(Math.min(100, Math.max(0, (window.scrollY / totalScroll) * 100)));
      }
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const progressRounded = Math.round(scrollProgress);

  return (
    <div className="w-full bg-[#0d1624] border-b border-[#1f3352] text-[#a4b1cd] px-3 sm:px-6 py-2.5 flex items-center justify-between gap-3 shadow-md backdrop-blur-md">
      {/* Left Section: Back arrow, module icon, title & lime progress pill */}
      <div className="flex items-center gap-3 sm:gap-4 min-w-0">
        <Link
          href="/notes"
          className="p-1 rounded-lg hover:bg-[#14233c] text-[#8ba0c3] hover:text-[#ffffff] transition-colors flex-shrink-0"
          title="Back to notes"
        >
          <ArrowLeft className="w-4 h-4" />
        </Link>

        {/* Cyber / Academy Module Icon */}
        <div className="w-7 h-7 rounded-lg bg-[#14233c] border border-[#1f3352] flex items-center justify-center text-[#9fef00] flex-shrink-0 shadow-sm">
          <span className="font-mono text-xs font-bold">⚡</span>
        </div>

        {/* Title and Progress Bar */}
        <div className="flex items-center gap-3 min-w-0">
          <div className="flex flex-col min-w-0">
            <div className="flex items-center gap-2">
              <span className="text-xs sm:text-sm font-bold text-[#ffffff] truncate">
                {title}
              </span>
              <span className="text-[11px] font-mono text-[#8ba0c3] flex-shrink-0">
                {progressRounded}%
              </span>
            </div>

            {/* Lime Progress Bar (matching screenshot) */}
            <div className="w-24 sm:w-36 h-1.5 bg-[#14233c] rounded-full overflow-hidden mt-1 border border-[#1f3352]/70">
              <div
                className="h-full bg-[#9fef00] rounded-full transition-all duration-150"
                style={{ width: `${progressRounded}%` }}
              />
            </div>
          </div>
        </div>

        <div className="h-6 w-px bg-[#1f3352] hidden sm:block mx-1 flex-shrink-0" />

        {/* Favorite Heart Button (matching screenshot) */}
        <div className="flex-shrink-0">
          <FavoriteButton
            documentId={documentId}
            initialFavorited={initialFavorited}
            showText={false}
            className="p-1.5 rounded-lg border-0 bg-transparent hover:bg-[#14233c] text-[#ff3366] hover:text-[#ff3366]"
          />
        </div>
      </div>

      {/* Right Section: Academy utility icons matching screenshot */}
      <div className="flex items-center gap-1.5 sm:gap-3 text-xs font-mono text-[#8ba0c3] flex-shrink-0">
        {/* Language selector */}
        <div className="hidden md:flex items-center gap-1 px-2.5 py-1 rounded-lg bg-[#111d30] border border-[#1f3352] text-[11px] text-[#cbd5e1]">
          <Globe className="w-3.5 h-3.5 text-[#9fef00]" />
          <span>English (Original)</span>
        </div>

        <div className="h-4 w-px bg-[#1f3352] hidden md:block" />

        {/* Icon 1: File Code */}
        <button
          type="button"
          onClick={() => {
            const el = document.getElementById("note-article-content");
            if (el) el.scrollIntoView({ behavior: "smooth" });
          }}
          className="p-1.5 rounded-lg hover:bg-[#14233c] hover:text-[#ffffff] transition-colors"
          title="Jump to code & content"
        >
          <FileCode className="w-4 h-4" />
        </button>

        {/* Icon 2: Sparkles / AI Assistant */}
        <button
          type="button"
          onClick={() => {
            alert("AI Operational Assistant: Ready for cybersecurity query decomposition.");
          }}
          className="p-1.5 rounded-lg hover:bg-[#14233c] hover:text-[#9fef00] transition-colors"
          title="Interactive AI Helper"
        >
          <Sparkles className="w-4 h-4" />
        </button>

        {/* Icon 3: Edit (if permitted) */}
        {userCanEdit && (
          <Link
            href={`/notes/${slug}/edit`}
            className="p-1.5 rounded-lg hover:bg-[#14233c] hover:text-[#9fef00] transition-colors"
            title="Edit Document"
          >
            <Edit3 className="w-4 h-4" />
          </Link>
        )}

        {/* Icon 4: Help */}
        <Link
          href="/methodology"
          className="p-1.5 rounded-lg hover:bg-[#14233c] hover:text-[#ffffff] transition-colors"
          title="Methodology & Help"
        >
          <HelpCircle className="w-4 h-4" />
        </Link>

        {/* Icon 5: Table of Contents Toggle (Orange / Lime highlighted button from screenshot) */}
        <button
          type="button"
          onClick={onToggleTocDrawer}
          className="flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-[#ff6b00]/15 hover:bg-[#ff6b00]/25 text-[#ff6b00] border border-[#ff6b00]/40 text-xs font-bold transition-all shadow-sm"
          title="Toggle Table of Contents"
        >
          <ListOrdered className="w-4 h-4" />
          <span className="hidden sm:inline">TOC</span>
        </button>

        {/* Full Page View Button */}
        <button
          type="button"
          onClick={toggleFocusMode}
          className="p-1.5 rounded-lg hover:bg-[#14233c] hover:text-[#9fef00] transition-colors"
          title={isFocusMode ? "Standard View" : "Full Page Display"}
        >
          {isFocusMode ? <Minimize2 className="w-4 h-4" /> : <Maximize2 className="w-4 h-4" />}
        </button>
      </div>
    </div>
  );
}
