"use client";

import React, { useState, useRef, useEffect } from "react";
import { useTheme, ThemeMode } from "./ThemeContext";
import { Sun, Moon, Laptop, Check } from "lucide-react";

export function ThemeToggle({ compact = false }: { compact?: boolean }) {
  const { theme, resolvedTheme, setTheme } = useTheme();
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const options: { mode: ThemeMode; label: string; icon: React.ElementType }[] = [
    { mode: "light", label: "Light Theme", icon: Sun },
    { mode: "dark", label: "Dark (HTB)", icon: Moon },
    { mode: "system", label: "System Default", icon: Laptop },
  ];

  return (
    <div className="relative inline-block text-left" ref={dropdownRef}>
      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-2 px-2.5 py-1.5 rounded-lg bg-[var(--surface-card)] hover:bg-[var(--surface-elevated)] border border-[var(--surface-border)] text-xs font-mono text-[var(--foreground)] hover:text-[var(--foreground-bright)] transition-colors cursor-pointer shadow-sm"
        title={`Current theme: ${theme} (${resolvedTheme})`}
        aria-label="Toggle theme"
      >
        {resolvedTheme === "light" ? (
          <Sun className="w-3.5 h-3.5 text-amber-500 animate-spin-slow" />
        ) : (
          <Moon className="w-3.5 h-3.5 text-[#9fef00]" />
        )}
        {!compact && (
          <span className="hidden sm:inline uppercase text-[11px] font-semibold">
            {theme === "system" ? "Auto" : theme}
          </span>
        )}
      </button>

      {isOpen && (
        <div className="absolute right-0 mt-2 w-44 rounded-xl bg-[var(--surface-card)] border border-[var(--surface-border)] shadow-2xl p-1.5 z-50 animate-in fade-in zoom-in-95 duration-150">
          <div className="px-2 py-1 text-[10px] font-mono uppercase text-[var(--foreground-muted)] tracking-wider">
            Appearance Mode
          </div>
          {options.map((opt) => {
            const Icon = opt.icon;
            const isSelected = theme === opt.mode;
            return (
              <button
                key={opt.mode}
                type="button"
                onClick={() => {
                  setTheme(opt.mode);
                  setIsOpen(false);
                }}
                className={`w-full flex items-center justify-between px-2.5 py-1.5 rounded-lg text-xs font-mono transition-colors text-left cursor-pointer ${
                  isSelected
                    ? "bg-[var(--primary)]/15 text-[var(--primary)] font-bold"
                    : "text-[var(--foreground)] hover:text-[var(--foreground-bright)] hover:bg-[var(--surface-elevated)]"
                }`}
              >
                <div className="flex items-center gap-2">
                  <Icon className="w-3.5 h-3.5 flex-shrink-0" />
                  <span>{opt.label}</span>
                </div>
                {isSelected && <Check className="w-3.5 h-3.5 flex-shrink-0" />}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}
