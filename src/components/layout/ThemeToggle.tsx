"use client";

import React from "react";
import { useTheme } from "./ThemeContext";
import { Sun, Moon } from "lucide-react";

export function ThemeToggle({ compact = false }: { compact?: boolean }) {
  const { resolvedTheme, toggleTheme } = useTheme();
  const isLight = resolvedTheme === "light";

  return (
    <button
      type="button"
      onClick={toggleTheme}
      className="group relative flex items-center gap-2 px-2.5 py-1.5 rounded-xl border border-[var(--surface-border)] bg-[var(--surface)] hover:bg-[var(--surface-elevated)] transition-all duration-200 cursor-pointer shadow-xs select-none focus:outline-none focus:ring-2 focus:ring-[#059669]/30"
      title={isLight ? "Switch to Dark Theme" : "Switch to Light Theme"}
      aria-label="Toggle light/dark theme"
    >
      {/* Tactile Sliding Switch Pill */}
      <div className="relative w-9 h-5 rounded-full bg-[var(--surface-elevated)] border border-[var(--surface-border)] p-0.5 flex items-center transition-colors">
        <div
          className={`w-3.5 h-3.5 rounded-full flex items-center justify-center transition-all duration-300 transform shadow-xs ${
            isLight
              ? "translate-x-4 bg-amber-500 text-white"
              : "translate-x-0 bg-[#9fef00] text-black"
          }`}
        >
          {isLight ? (
            <Sun className="w-2.5 h-2.5 text-white" />
          ) : (
            <Moon className="w-2.5 h-2.5 text-black" />
          )}
        </div>
      </div>

      {!compact && (
        <span className="font-mono text-[11px] font-bold tracking-wider text-[var(--foreground)] group-hover:text-[var(--foreground-bright)] uppercase transition-colors hidden sm:inline-block">
          {isLight ? "Light" : "Dark"}
        </span>
      )}
    </button>
  );
}
