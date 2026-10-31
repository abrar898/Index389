"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  Search,
  Network,
  ExternalLink,
  Edit,
  Trash2,
  Maximize2,
  Clock,
  Layers,
  Terminal,
  Filter,
} from "lucide-react";
import { MindmapSummary } from "@/lib/mindmaps";
import { SessionUser } from "@/lib/auth";

interface MindmapCardListProps {
  mindmaps: MindmapSummary[];
  user: SessionUser | null;
}

export function MindmapCardList({ mindmaps, user }: MindmapCardListProps) {
  const router = useRouter();
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<string>("ALL");
  const [isDeleting, setIsDeleting] = useState<string | null>(null);

  const categories = ["ALL", ...Array.from(new Set(mindmaps.map((m) => m.category).filter(Boolean)))];

  const filtered = mindmaps.filter((m) => {
    const matchCategory = selectedCategory === "ALL" || m.category === selectedCategory;
    const matchSearch =
      m.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      m.description?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      m.tags?.some((t) => t.toLowerCase().includes(searchTerm.toLowerCase()));
    return matchCategory && matchSearch;
  });

  const handleDelete = async (slug: string, title: string) => {
    if (!confirm(`Are you sure you want to delete "${title}"?`)) return;

    setIsDeleting(slug);
    try {
      const res = await fetch(`/api/mindmaps/${slug}`, { method: "DELETE" });
      if (!res.ok) {
        const data = await res.json();
        alert(data.error || "Failed to delete mindmap.");
      } else {
        router.refresh();
      }
    } catch {
      alert("Failed to delete mindmap.");
    } finally {
      setIsDeleting(null);
    }
  };

  return (
    <div className="space-y-6">
      {/* Search and Filters Bar */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4 p-4 rounded-2xl glass-panel border-[#1f3352]">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[#6c7d9c]" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Search mindmaps, attacks, categories..."
            className="w-full bg-[#111d30] border border-[#1f3352] focus:border-[#9fef00] text-xs text-[#ffffff] pl-9 pr-4 py-2 rounded-xl outline-none transition-colors"
          />
        </div>

        {/* Category Pills */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0">
          <span className="text-[11px] font-mono text-[#6c7d9c] mr-1 hidden lg:inline">
            <Filter className="w-3.5 h-3.5 inline mr-1" />
            FILTER:
          </span>
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-3 py-1.5 rounded-xl text-xs font-mono transition-all whitespace-nowrap ${
                selectedCategory === cat
                  ? "bg-[#9fef00] text-[#0b121e] font-bold shadow-md shadow-[#9fef00]/20"
                  : "bg-[#111d30] hover:bg-[#14233c] text-[#8ba0c3] hover:text-[#ffffff] border border-[#1f3352]"
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* Grid of Mindmap Cards */}
      {filtered.length === 0 ? (
        <div className="p-12 text-center rounded-2xl border border-dashed border-[#1f3352] glass-panel space-y-3">
          <Network className="w-10 h-10 text-[#6c7d9c] mx-auto opacity-50" />
          <h3 className="text-sm font-bold text-[#ffffff]">No mindmaps found</h3>
          <p className="text-xs text-[#8ba0c3] max-w-sm mx-auto">
            Try adjusting your search criteria, or create a new mindmap with your custom HTML code.
          </p>
          <Link
            href="/mindmaps/new"
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-[#9fef00] text-[#0b121e] text-xs font-bold mt-2"
          >
            Create Mindmap
          </Link>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filtered.map((item) => (
            <div
              key={item.slug}
              className="flex flex-col justify-between rounded-2xl border border-[#1f3352] bg-[#111d30] hover:border-[#9fef00]/60 transition-all duration-200 overflow-hidden shadow-lg group hover:shadow-xl hover:shadow-[#9fef00]/5"
            >
              {/* Card Header & Body */}
              <div className="p-5 space-y-3">
                <div className="flex items-center justify-between">
                  <span className="px-2 py-0.5 rounded-md font-mono text-[10px] font-bold bg-[#14233c] text-[#9fef00] border border-[#1f3352]">
                    {item.category}
                  </span>
                  {item.isDefault && (
                    <span className="font-mono text-[10px] text-[#2de2e6] font-bold">★ DEFAULT</span>
                  )}
                </div>

                <div>
                  <Link href={`/mindmaps/${item.slug}`}>
                    <h3 className="text-base font-bold text-[#ffffff] group-hover:text-[#9fef00] transition-colors truncate">
                      {item.title}
                    </h3>
                  </Link>
                  <p className="text-xs text-[#8ba0c3] mt-1 line-clamp-2 leading-relaxed">
                    {item.description}
                  </p>
                </div>

                {/* Node & Command Specs */}
                <div className="flex items-center gap-3 pt-2 text-[11px] font-mono text-[#6c7d9c] border-t border-[#1f3352]/60">
                  <span className="flex items-center gap-1">
                    <Layers className="w-3.5 h-3.5 text-[#2de2e6]" />
                    {item.nodeCount || 10}+ Nodes
                  </span>
                  {item.phaseCount > 0 && <span>•</span>}
                  {item.phaseCount > 0 && <span>{item.phaseCount} Phases</span>}
                  {item.commandCount > 0 && (
                    <>
                      <span>•</span>
                      <span className="text-[#9fef00] flex items-center gap-1">
                        <Terminal className="w-3 h-3" />
                        {item.commandCount}
                      </span>
                    </>
                  )}
                </div>

                {/* Tags */}
                {item.tags && item.tags.length > 0 && (
                  <div className="flex flex-wrap gap-1 pt-1">
                    {item.tags.slice(0, 4).map((tag) => (
                      <span
                        key={tag}
                        className="px-1.5 py-0.5 rounded text-[10px] font-mono bg-[#070b13] text-[#8ba0c3] border border-[#1f3352]"
                      >
                        #{tag}
                      </span>
                    ))}
                  </div>
                )}
              </div>

              {/* Card Footer Actions */}
              <div className="flex items-center justify-between px-5 py-3 bg-[#0b121e] border-t border-[#1f3352]">
                <div className="flex items-center gap-1">
                  {user && (
                    <Link
                      href={`/mindmaps/${item.slug}/edit`}
                      className="p-1.5 rounded-lg text-[#6c7d9c] hover:text-[#2de2e6] hover:bg-[#14233c] transition-colors"
                      title="Edit HTML code"
                    >
                      <Edit className="w-3.5 h-3.5" />
                    </Link>
                  )}
                  {user?.role === "ADMIN" && !item.isDefault && (
                    <button
                      onClick={() => handleDelete(item.slug, item.title)}
                      disabled={isDeleting === item.slug}
                      className="p-1.5 rounded-lg text-[#6c7d9c] hover:text-[#ff3366] hover:bg-[#14233c] transition-colors"
                      title="Delete mindmap"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  )}
                  <a
                    href={`/mindmaps/${item.slug}.html`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="p-1.5 rounded-lg text-[#6c7d9c] hover:text-[#ffffff] hover:bg-[#14233c] transition-colors"
                    title="Open pure HTML in new tab"
                  >
                    <ExternalLink className="w-3.5 h-3.5" />
                  </a>
                </div>

                <Link
                  href={`/mindmaps/${item.slug}`}
                  className="flex items-center gap-1 text-xs font-bold text-[#9fef00] hover:text-[#b4fa1f] transition-colors"
                >
                  <span>Explore Canvas</span>
                  <Maximize2 className="w-3.5 h-3.5" />
                </Link>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
