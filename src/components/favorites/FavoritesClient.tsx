"use client";

import React, { useState } from "react";
import Link from "next/link";
import { Star, Search, Folder, Clock, FileDown, ArrowRight, BookOpen } from "lucide-react";
import { FavoriteButton } from "@/components/notes/FavoriteButton";

interface NoteSummary {
  id: string;
  title: string;
  slug: string;
  description: string | null;
  updatedAt: Date;
  readingTimeMin: number;
  category: { id: string; name: string; slug: string } | null;
  tags: { tag: { id: string; name: string; slug: string } }[];
  author: { name: string | null; email: string };
}

interface FavoritesClientProps {
  initialNotes: NoteSummary[];
  categories: { id: string; name: string; slug: string }[];
}

export function FavoritesClient({ initialNotes, categories }: FavoritesClientProps) {
  const [notes, setNotes] = useState<NoteSummary[]>(initialNotes);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<string>("all");

  const handleToggle = (docId: string, favorited: boolean) => {
    if (!favorited) {
      setNotes((prev) => prev.filter((n) => n.id !== docId));
    }
  };

  const filteredNotes = notes.filter((note) => {
    const matchesSearch =
      searchQuery.trim() === "" ||
      note.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (note.description && note.description.toLowerCase().includes(searchQuery.toLowerCase())) ||
      note.tags.some((t) => t.tag.name.toLowerCase().includes(searchQuery.toLowerCase()));

    const matchesCategory =
      selectedCategory === "all" || note.category?.slug === selectedCategory;

    return matchesSearch && matchesCategory;
  });

  return (
    <div className="space-y-6">
      {/* Search and Category Filters */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4 p-4 rounded-2xl border border-[#1f3352] glass-panel">
        {/* Search Input */}
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#6c7d9c]" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search saved notes..."
            className="w-full pl-9 pr-4 py-1.5 rounded-lg bg-[#111d30] border border-[#1f3352] text-xs font-mono text-[#ffffff] placeholder-[#6c7d9c] focus:border-[#9fef00] focus:outline-none transition-all"
          />
        </div>

        {/* Category Tabs */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 text-xs">
          <button
            type="button"
            onClick={() => setSelectedCategory("all")}
            className={`px-3 py-1 rounded-lg border font-mono transition-colors cursor-pointer ${
              selectedCategory === "all"
                ? "bg-[#9fef00]/15 text-[#9fef00] border-[#9fef00]/50 font-semibold"
                : "bg-[#14233c] text-[#8ba0c3] border-[#1f3352] hover:text-[#ffffff]"
            }`}
          >
            All ({notes.length})
          </button>
          {categories.map((c) => {
            const count = notes.filter((n) => n.category?.slug === c.slug).length;
            if (count === 0) return null;
            return (
              <button
                key={c.id}
                type="button"
                onClick={() => setSelectedCategory(c.slug)}
                className={`px-3 py-1 rounded-lg border font-mono transition-colors flex items-center gap-1.5 whitespace-nowrap cursor-pointer ${
                  selectedCategory === c.slug
                    ? "bg-[#9fef00]/15 text-[#9fef00] border-[#9fef00]/50 font-semibold"
                    : "bg-[#14233c] text-[#8ba0c3] border-[#1f3352] hover:text-[#ffffff]"
                }`}
              >
                <span>{c.name}</span>
                <span className="text-[10px] text-[#6c7d9c]">({count})</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Grid of Favorite Notes */}
      {filteredNotes.length === 0 ? (
        <div className="p-12 text-center rounded-2xl border border-[#1f3352] glass-panel text-[#8ba0c3] space-y-4">
          <div className="w-12 h-12 rounded-xl bg-[#111d30] border border-[#1f3352] flex items-center justify-center mx-auto text-[#ff8400]">
            <Star className="w-6 h-6" />
          </div>
          <div className="space-y-1">
            <h3 className="text-base font-bold text-[#ffffff]">
              {notes.length === 0 ? "No Saved Favorites Yet" : "No Matching Favorites"}
            </h3>
            <p className="text-xs text-[#8ba0c3] max-w-md mx-auto">
              {notes.length === 0
                ? "Click the star icon on any technical writeup, cheat-sheet, or command guide to pin it here for rapid operational access."
                : "Try clearing your search query or selecting a different category filter."}
            </p>
          </div>
          {notes.length === 0 && (
            <Link
              href="/notes"
              className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-[#9fef00] hover:bg-[#b4fa1f] text-xs font-bold text-[#0b121e] transition-all shadow-md active:scale-95"
            >
              <BookOpen className="w-4 h-4" />
              <span>Explore Central Repository</span>
            </Link>
          )}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredNotes.map((note) => (
            <div
              key={note.id}
              className="group p-5 rounded-2xl border border-[#1f3352] glass-panel glass-panel-hover hover:border-[#9fef00]/60 transition-all flex flex-col justify-between shadow-lg relative"
            >
              <div className="space-y-3">
                {/* Card Top: Category & Favorite Toggle */}
                <div className="flex items-center justify-between gap-2">
                  {note.category ? (
                    <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded bg-[#9fef00]/10 text-[#9fef00] border border-[#9fef00]/30 font-mono text-[11px] font-semibold">
                      <Folder className="w-3 h-3" />
                      {note.category.name}
                    </span>
                  ) : (
                    <span className="text-[11px] font-mono text-[#6c7d9c]">General</span>
                  )}

                  <FavoriteButton
                    documentId={note.id}
                    initialFavorited={true}
                    showText={false}
                    className="p-1.5 px-2"
                    onToggle={(favorited) => handleToggle(note.id, favorited)}
                  />
                </div>

                {/* Title */}
                <Link href={`/notes/${note.slug}`} className="block">
                  <h3 className="text-base font-bold text-[#ffffff] group-hover:text-[#9fef00] transition-colors leading-snug">
                    {note.title}
                  </h3>
                </Link>

                {/* Description */}
                {note.description && (
                  <p className="text-xs text-[#a4b1cd] line-clamp-2 leading-relaxed">
                    {note.description}
                  </p>
                )}

                {/* Tags */}
                {note.tags.length > 0 && (
                  <div className="flex flex-wrap gap-1 pt-1">
                    {note.tags.map(({ tag }) => (
                      <span
                        key={tag.id}
                        className="px-1.5 py-0.5 rounded bg-[#111d30] border border-[#1f3352] font-mono text-[10px] text-[#8ba0c3]"
                      >
                        #{tag.name}
                      </span>
                    ))}
                  </div>
                )}
              </div>

              {/* Card Footer: Metadata and Quick Read */}
              <div className="pt-4 mt-4 border-t border-[#1f3352] flex items-center justify-between text-xs text-[#6c7d9c] font-mono">
                <div className="flex items-center gap-3 text-[11px]">
                  <span className="flex items-center gap-1">
                    <Clock className="w-3 h-3 text-[#9fef00]" />
                    {note.readingTimeMin}m
                  </span>
                  <span>•</span>
                  <span>
                    {new Date(note.updatedAt).toLocaleDateString("en-US", {
                      month: "short",
                      day: "numeric",
                    })}
                  </span>
                </div>

                <div className="flex items-center gap-2">
                  <a
                    href={`/api/documents/${note.slug}/export/pdf`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="p-1 rounded text-[#6c7d9c] hover:text-[#ff3366] hover:bg-[#14233c] transition-colors"
                    title="Export PDF"
                  >
                    <FileDown className="w-3.5 h-3.5" />
                  </a>
                  <Link
                    href={`/notes/${note.slug}`}
                    className="flex items-center gap-1 text-[#9fef00] hover:underline"
                  >
                    <span>Read</span>
                    <ArrowRight className="w-3 h-3 group-hover:translate-x-1 transition-transform" />
                  </Link>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
