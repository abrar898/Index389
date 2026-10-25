"use client";

import React, { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Shield,
  FileText,
  Upload,
  Plus,
  Search,
  Folder,
  Star,
  Settings,
  ChevronLeft,
  ChevronRight,
  Terminal,
  LogOut,
  UserCheck,
  BookOpen,
  CheckSquare,
  ShieldAlert,
} from "lucide-react";
import { SessionUser } from "@/lib/auth";
import { CreateCategoryModal } from "@/components/categories/CreateCategoryModal";

interface SidebarProps {
  user: SessionUser | null;
  categories: { id: string; name: string; slug: string; _count?: { documents: number } }[];
  tags: { id: string; name: string; slug: string }[];
}

export function Sidebar({ user, categories, tags }: SidebarProps) {
  const pathname = usePathname();
  const [collapsed, setCollapsed] = useState(false);

  const navLinks = [
    { label: "Dashboard", href: "/dashboard", icon: Terminal },
    { label: "All Notes", href: "/notes", icon: FileText },
    { label: "Methodology", href: "/methodology", icon: CheckSquare },
    ...(user?.role === "ADMIN" ? [{ label: "Import Center", href: "/import", icon: Upload }] : []),
    { label: "Favorites", href: "/favorites", icon: Star },
    { label: "Categories", href: "/categories", icon: Folder },
    ...(user?.role === "ADMIN" ? [{ label: "SOC & Security", href: "/admin/security", icon: ShieldAlert }] : []),
    { label: "Settings", href: "/settings", icon: Settings },
  ];

  return (
    <aside
      className={`relative flex flex-col h-full flex-shrink-0 border-r border-[#1f3352] glass-panel rounded-none border-y-0 border-l-0 transition-all duration-300 select-none z-30 ${
        collapsed ? "w-16" : "w-64"
      }`}
    >
      {/* Workspace Brand / Header */}
      <div className="flex items-center justify-between h-14 px-4 border-b border-[#1f3352] flex-shrink-0">
        <Link href="/dashboard" className="flex items-center gap-2.5 overflow-hidden">
          <div className="relative flex items-center justify-center w-9 h-9 rounded-lg overflow-hidden border border-[#9fef00]/40 bg-black/60 shadow-[0_0_12px_rgba(159,239,0,0.2)] flex-shrink-0">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src="/logo.png"
              alt="Index 389 Logo"
              className="w-full h-full object-cover"
            />
          </div>
          {!collapsed && (
            <div className="flex flex-col min-w-0">
              <span className="font-mono text-sm font-bold tracking-wider text-[#ffffff] truncate">
                INDEX 389
              </span>
              <span className="text-[10px] text-[#9fef00] tracking-wider font-mono">
                CTF // RESEARCH
              </span>
            </div>
          )}
        </Link>
        <button
          onClick={() => setCollapsed(!collapsed)}
          className="p-1 rounded text-[#6c7d9c] hover:text-[#ffffff] hover:bg-[#14233c] transition-colors"
          title={collapsed ? "Expand sidebar" : "Collapse sidebar"}
        >
          {collapsed ? <ChevronRight className="w-4 h-4" /> : <ChevronLeft className="w-4 h-4" />}
        </button>
      </div>

      {/* Quick Actions (Admin Only) */}
      {user?.role === "ADMIN" && (
        <div className="p-3 border-b border-[#1f3352]">
          <Link
            href="/notes/new"
            className={`flex items-center justify-center gap-2 w-full py-2 px-3 rounded text-xs font-semibold bg-[#9fef00] text-[#0b121e] hover:bg-[#b4fa1f] transition-all shadow-md active:scale-95 ${
              collapsed ? "px-0" : ""
            }`}
          >
            <Plus className="w-4 h-4" />
            {!collapsed && <span>New Document</span>}
          </Link>
        </div>
      )}

      {/* Navigation Sections */}
      <div className="flex-1 overflow-y-auto px-2 py-3 space-y-4">
        {/* Main Links */}
        <div className="space-y-1">
          {navLinks.map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href || (item.href !== "/dashboard" && pathname.startsWith(item.href));
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`flex items-center gap-3 px-3 py-2 rounded text-xs transition-colors ${
                  isActive
                    ? "bg-[#9fef00]/15 text-[#9fef00] font-semibold border-l-2 border-[#9fef00]"
                    : "text-[#8ba0c3] hover:text-[#ffffff] hover:bg-[#111d30]"
                }`}
                title={collapsed ? item.label : undefined}
              >
                <Icon className={`w-4 h-4 flex-shrink-0 ${isActive ? "text-[#9fef00]" : ""}`} />
                {!collapsed && <span>{item.label}</span>}
              </Link>
            );
          })}
        </div>

        {/* Categories Section */}
        {!collapsed && (
          <div className="pt-2 border-t border-[#1f3352]">
            <div className="px-3 pb-2 flex items-center justify-between">
              <span className="text-[10px] font-semibold tracking-wider text-[#6c7d9c] uppercase">
                Categories
              </span>
              {user?.role === "ADMIN" && (
                <CreateCategoryModal
                  triggerButtonText="+"
                  triggerButtonClassName="w-4 h-4 rounded flex items-center justify-center text-[#9fef00] hover:bg-[#14233c] text-xs font-bold leading-none"
                />
              )}
            </div>
            <div className="space-y-0.5">
              {categories.map((cat) => (
                <Link
                  key={cat.id}
                  href={`/categories/${cat.slug}`}
                  className="flex items-center justify-between px-3 py-1.5 rounded text-xs text-[#8ba0c3] hover:text-[#ffffff] hover:bg-[#111d30] transition-colors"
                >
                  <div className="flex items-center gap-2 truncate">
                    <span className="w-1.5 h-1.5 rounded-full bg-[#9fef00]" />
                    <span className="truncate">{cat.name}</span>
                  </div>
                  {cat._count?.documents !== undefined && (
                    <span className="text-[10px] font-mono bg-[#9fef00]/10 border border-[#9fef00]/30 text-[#9fef00] px-1.5 py-0.5 rounded-full">
                      {cat._count.documents}
                    </span>
                  )}
                </Link>
              ))}
            </div>
          </div>
        )}

        {/* Popular Tags */}
        {!collapsed && tags.length > 0 && (
          <div className="pt-2 border-t border-[#1f3352]">
            <div className="px-3 pb-2 text-[10px] font-semibold tracking-wider text-[#6c7d9c] uppercase">
              Tags
            </div>
            <div className="flex flex-wrap gap-1 px-3">
              {tags.slice(0, 10).map((t) => (
                <Link
                  key={t.id}
                  href={`/notes?tag=${t.slug}`}
                  className="px-2 py-0.5 rounded text-[10px] font-mono bg-[#9fef00]/10 text-[#9fef00] border border-[#9fef00]/30 hover:brightness-125 transition-all"
                >
                  #{t.name}
                </Link>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* User Status Bar */}
      <div className="p-3 border-t border-[#1f3352] bg-[#14233c]/40">
        {user ? (
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2 overflow-hidden">
              <div className="w-7 h-7 rounded bg-[#14233c] border border-[#1f3352] flex items-center justify-center text-xs font-bold text-[#9fef00]">
                {user.name ? user.name[0].toUpperCase() : "U"}
              </div>
              {!collapsed && (
                <div className="flex flex-col truncate">
                  <span className="text-xs font-medium text-[#ffffff] truncate">
                    {user.name || user.email}
                  </span>
                  <span className="text-[10px] font-mono text-[#9fef00]">
                    [{user.role}]
                  </span>
                </div>
              )}
            </div>
            {!collapsed && (
              <form action="/api/auth/logout" method="POST">
                <button
                  type="submit"
                  title="Sign out"
                  className="p-1 rounded text-[#6c7d9c] hover:text-[#ff3366] transition-colors"
                >
                  <LogOut className="w-4 h-4" />
                </button>
              </form>
            )}
          </div>
        ) : (
          <Link
            href="/login"
            className="flex items-center justify-center gap-2 w-full py-1.5 px-3 rounded text-xs text-[#8ba0c3] hover:text-[#ffffff] hover:bg-[#14233c] transition-colors border border-[#1f3352]"
          >
            <UserCheck className="w-4 h-4 text-[#9fef00]" />
            {!collapsed && <span>Sign In</span>}
          </Link>
        )}
      </div>
    </aside>
  );
}
