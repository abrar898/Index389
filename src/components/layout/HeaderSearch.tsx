"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { Search } from "lucide-react";

export function HeaderSearch() {
  const [query, setQuery] = useState("");
  const router = useRouter();

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (query.trim()) {
      router.push(`/search?q=${encodeURIComponent(query.trim())}`);
    }
  };

  return (
    <form onSubmit={handleSearch} className="relative w-full max-w-md">
      <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#6c7d9c]" />
      <input
        type="text"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search notes, CVEs, commands (e.g. nmap, privesc)..."
        className="w-full pl-9 pr-4 py-1.5 rounded-md bg-[#111d30] border border-[#1f3352] text-xs text-[#ffffff] placeholder-[#6c7d9c] focus:outline-none focus:border-[#9fef00] focus:ring-1 focus:ring-[#9fef00] transition-all font-mono"
      />
    </form>
  );
}
