"use client";

import React, { useState, useEffect } from "react";
import { Star } from "lucide-react";

interface FavoriteButtonProps {
  documentId: string;
  initialFavorited?: boolean;
  className?: string;
  showText?: boolean;
  onToggle?: (favorited: boolean) => void;
}

export function FavoriteButton({
  documentId,
  initialFavorited = false,
  className = "",
  showText = true,
  onToggle,
}: FavoriteButtonProps) {
  const [favorited, setFavorited] = useState(initialFavorited);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setFavorited(initialFavorited);
  }, [initialFavorited]);

  const handleToggle = async (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();

    if (loading) return;

    // Optimistic toggle
    const nextState = !favorited;
    setFavorited(nextState);
    setLoading(true);

    try {
      const res = await fetch("/api/favorites", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ documentId }),
      });

      if (!res.ok) {
        // Rollback
        setFavorited(!nextState);
      } else {
        const data = await res.json();
        setFavorited(data.favorited);
        if (onToggle) onToggle(data.favorited);
      }
    } catch {
      // Rollback
      setFavorited(!nextState);
    } finally {
      setLoading(false);
    }
  };

  return (
    <button
      type="button"
      onClick={handleToggle}
      disabled={loading}
      className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg border text-xs font-mono transition-all cursor-pointer ${
        favorited
          ? "bg-[#ff8400]/15 text-[#ff8400] border-[#ff8400]/40 shadow-sm shadow-[#ff8400]/20 hover:bg-[#ff8400]/25"
          : "bg-[#14233c] text-[#8ba0c3] border-[#1f3352] hover:text-[#ff8400] hover:border-[#ff8400]/40 hover:bg-[#182844]"
      } ${className}`}
      title={favorited ? "Remove from favorites" : "Save to favorites"}
    >
      <Star
        className={`w-3.5 h-3.5 transition-transform duration-200 ${
          favorited ? "fill-[#ff8400] text-[#ff8400] scale-110" : "text-[#6c7d9c]"
        } ${loading ? "animate-spin" : ""}`}
      />
      {showText && <span>{favorited ? "Favorited" : "Favorite"}</span>}
    </button>
  );
}
