"use client";

import React, { useState } from "react";
import { Sidebar } from "@/components/layout/Sidebar";
import { HeaderSearch } from "@/components/layout/HeaderSearch";
import { ThemeToggle } from "@/components/layout/ThemeToggle";
import { SessionUser } from "@/lib/auth";
import Link from "next/link";
import { FocusReadingProvider, useFocusReading } from "./FocusReadingContext";
import { Menu, X, Shield } from "lucide-react";

interface AppShellProps {
  user: SessionUser | null;
  categories: { id: string; name: string; slug: string; _count?: { documents: number } }[];
  tags: { id: string; name: string; slug: string }[];
  children: React.ReactNode;
}

function InnerAppShell({ user, categories, tags, children }: AppShellProps) {
  const { isFocusMode } = useFocusReading();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <div className="flex h-screen overflow-hidden bg-[var(--background)] text-[var(--foreground)] cyber-grid">
      {/* Desktop Left Sidebar: Collapses/Hides in Full Page Focus Mode */}
      {!isFocusMode && (
        <div className="hidden lg:flex h-full flex-shrink-0">
          <Sidebar user={user} categories={categories} tags={tags} />
        </div>
      )}

      {/* Mobile Drawer Backdrop */}
      {mobileMenuOpen && (
        <div
          className="fixed inset-0 bg-black/60 backdrop-blur-xs z-40 lg:hidden"
          onClick={() => setMobileMenuOpen(false)}
        />
      )}

      {/* Mobile Drawer Content */}
      <div
        className={`fixed top-0 bottom-0 left-0 w-72 z-50 transform transition-transform duration-300 ease-in-out lg:hidden ${
          mobileMenuOpen ? "translate-x-0" : "-translate-x-full"
        }`}
      >
        <div className="h-full relative flex flex-col bg-[var(--surface)] shadow-2xl">
          <div className="flex items-center justify-between p-3 border-b border-[var(--surface-border)]">
            <div className="flex items-center gap-2 text-xs font-mono font-bold text-[var(--foreground-bright)]">
              <Shield className="w-4 h-4 text-[#9fef00]" />
              <span>NAVIGATION MENU</span>
            </div>
            <button
              type="button"
              onClick={() => setMobileMenuOpen(false)}
              className="p-1 rounded text-[var(--foreground-muted)] hover:text-[var(--foreground-bright)]"
              aria-label="Close menu"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
          <div className="flex-1 overflow-y-auto" onClick={() => setMobileMenuOpen(false)}>
            <Sidebar user={user} categories={categories} tags={tags} />
          </div>
        </div>
      </div>

      {/* Main Content Column */}
      <div className="flex-1 flex flex-col min-w-0 h-screen overflow-y-auto">
        {/* Top Header Bar */}
        {!isFocusMode && (
          <header className="h-14 border-b border-[var(--surface-border)] glass-panel rounded-none border-t-0 border-l-0 border-r-0 px-4 sm:px-6 flex items-center justify-between sticky top-0 z-20 flex-shrink-0 gap-3">
            <div className="flex items-center gap-3 flex-1 min-w-0 max-w-xl">
              {/* Mobile Hamburger Toggle */}
              <button
                type="button"
                onClick={() => setMobileMenuOpen(true)}
                className="lg:hidden p-1.5 rounded-lg border border-[var(--surface-border)] bg-[var(--surface-card)] text-[var(--foreground)] hover:text-[var(--foreground-bright)] transition-colors cursor-pointer"
                aria-label="Open menu"
              >
                <Menu className="w-4 h-4" />
              </button>

              <div className="flex-1 min-w-0">
                <HeaderSearch />
              </div>
            </div>

            <div className="flex items-center gap-2 sm:gap-3 flex-shrink-0">
              {/* Theme Toggle (Light / Dark / Auto) */}
              <ThemeToggle />

              <div className="hidden sm:flex items-center gap-2 px-2.5 py-1 rounded bg-[var(--surface-card)] border border-[var(--surface-border)] text-[11px] font-mono text-[var(--foreground-muted)]">
                <span className="w-2 h-2 rounded-full bg-[#9fef00] animate-pulse" />
                <span>DEFCON 5</span>
              </div>

              {user?.role === "ADMIN" && (
                <Link
                  href="/admin/security"
                  className="px-2.5 py-1 rounded-lg bg-[var(--surface-card)] hover:bg-[var(--surface-elevated)] border border-[var(--surface-border)] text-xs font-mono text-[#9fef00] transition-colors"
                >
                  <span className="hidden sm:inline">SOC / </span>SECURITY
                </Link>
              )}
            </div>
          </header>
        )}

        {/* Center Content */}
        <main
          className={`flex-1 p-4 sm:p-6 md:p-8 w-full transition-all duration-300 ${
            isFocusMode ? "max-w-5xl mx-auto px-4 sm:px-6 md:px-12" : "max-w-[1600px] mx-auto"
          }`}
        >
          {children}
        </main>
      </div>
    </div>
  );
}

export function AppShell(props: AppShellProps) {
  return (
    <FocusReadingProvider>
      <InnerAppShell {...props} />
    </FocusReadingProvider>
  );
}
