"use client";

import React, { useState, useEffect } from "react";
import {
  User,
  Shield,
  Key,
  Monitor,
  FileDown,
  Database,
  CheckCircle,
  AlertCircle,
  LogOut,
  Sliders,
  Type,
  Code2,
  Lock,
  Save,
  Wrench,
  Sun,
  Moon,
  Laptop,
} from "lucide-react";
import { SessionUser } from "@/lib/auth";
import { SecurityToolkit } from "./SecurityToolkit";
import { useTheme, ThemeMode } from "@/components/layout/ThemeContext";

interface SettingsClientProps {
  user: SessionUser | null;
  stats: {
    totalDocs: number;
    totalCategories: number;
    totalTags: number;
    totalFavorites: number;
  };
}

export function SettingsClient({ user, stats }: SettingsClientProps) {
  const [activeTab, setActiveTab] = useState<"profile" | "reading" | "export" | "system" | "tools">("profile");
  const { theme, setTheme, resolvedTheme } = useTheme();

  // Reading preferences (loaded from localStorage)
  const [fontSize, setFontSize] = useState("normal");
  const [codeTheme, setCodeTheme] = useState("emerald");
  const [showLineNumbers, setShowLineNumbers] = useState(true);
  const [smoothScroll, setSmoothScroll] = useState(true);

  // Export preferences
  const [defaultExport, setDefaultExport] = useState("pdf");
  const [includeAuthor, setIncludeAuthor] = useState(true);
  const [includeToc, setIncludeToc] = useState(true);
  const [classificationBanner, setClassificationBanner] = useState("TLP:AMBER");

  // Password state
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [passwordLoading, setPasswordLoading] = useState(false);
  const [passwordStatus, setPasswordStatus] = useState<{ type: "success" | "error"; msg: string } | null>(null);

  // Preference save status
  const [prefSaved, setPrefSaved] = useState(false);

  useEffect(() => {
    if (typeof window !== "undefined") {
      const savedFontSize = localStorage.getItem("cyber_pref_font_size");
      if (savedFontSize) setFontSize(savedFontSize);
      const savedTheme = localStorage.getItem("cyber_pref_code_theme");
      if (savedTheme) setCodeTheme(savedTheme);
      const savedLines = localStorage.getItem("cyber_pref_line_numbers");
      if (savedLines !== null) setShowLineNumbers(savedLines === "true");
      const savedScroll = localStorage.getItem("cyber_pref_smooth_scroll");
      if (savedScroll !== null) setSmoothScroll(savedScroll === "true");
    }
  }, []);

  const saveReadingPrefs = () => {
    if (typeof window !== "undefined") {
      localStorage.setItem("cyber_pref_font_size", fontSize);
      localStorage.setItem("cyber_pref_code_theme", codeTheme);
      localStorage.setItem("cyber_pref_line_numbers", String(showLineNumbers));
      localStorage.setItem("cyber_pref_smooth_scroll", String(smoothScroll));
      setPrefSaved(true);
      setTimeout(() => setPrefSaved(false), 2500);
    }
  };

  const handlePasswordChange = async (e: React.FormEvent) => {
    e.preventDefault();
    setPasswordStatus(null);

    if (newPassword !== confirmPassword) {
      setPasswordStatus({ type: "error", msg: "New passwords do not match" });
      return;
    }

    if (newPassword.length < 8) {
      setPasswordStatus({ type: "error", msg: "New password must be at least 8 characters" });
      return;
    }

    setPasswordLoading(true);
    try {
      const res = await fetch("/api/auth/change-password", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ currentPassword, newPassword }),
      });

      const data = await res.json();
      if (!res.ok) {
        setPasswordStatus({ type: "error", msg: data.error || "Failed to update password" });
      } else {
        setPasswordStatus({ type: "success", msg: "Password updated successfully!" });
        setCurrentPassword("");
        setNewPassword("");
        setConfirmPassword("");
      }
    } catch {
      setPasswordStatus({ type: "error", msg: "An unexpected error occurred" });
    } finally {
      setPasswordLoading(false);
    }
  };

  const handleLogout = async () => {
    try {
      await fetch("/api/auth/logout", { method: "POST" });
      window.location.href = "/login";
    } catch {
      window.location.href = "/login";
    }
  };

  return (
    <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 items-start">
      {/* Settings Navigation Sidebar */}
      <div className="p-4 rounded-2xl border border-[#1f3352] glass-panel space-y-1">
        <span className="text-[10px] font-mono uppercase text-[#6c7d9c] tracking-wider px-3 block mb-2">
          Configuration
        </span>
        <button
          type="button"
          onClick={() => setActiveTab("profile")}
          className={`w-full flex items-center gap-3 px-3 py-2 rounded-lg text-xs font-mono transition-colors cursor-pointer ${
            activeTab === "profile"
              ? "bg-[#9fef00]/15 text-[#9fef00] font-bold border-l-2 border-[#9fef00]"
              : "text-[#8ba0c3] hover:text-[#ffffff] hover:bg-[#14233c]"
          }`}
        >
          <User className="w-4 h-4" />
          <span>Profile & Security</span>
        </button>

        <button
          type="button"
          onClick={() => setActiveTab("reading")}
          className={`w-full flex items-center gap-3 px-3 py-2 rounded-lg text-xs font-mono transition-colors cursor-pointer ${
            activeTab === "reading"
              ? "bg-[#9fef00]/15 text-[#9fef00] font-bold border-l-2 border-[#9fef00]"
              : "text-[#8ba0c3] hover:text-[#ffffff] hover:bg-[#14233c]"
          }`}
        >
          <Monitor className="w-4 h-4" />
          <span>Reading & Display</span>
        </button>

        <button
          type="button"
          onClick={() => setActiveTab("export")}
          className={`w-full flex items-center gap-3 px-3 py-2 rounded-lg text-xs font-mono transition-colors cursor-pointer ${
            activeTab === "export"
              ? "bg-[#9fef00]/15 text-[#9fef00] font-bold border-l-2 border-[#9fef00]"
              : "text-[#8ba0c3] hover:text-[#ffffff] hover:bg-[#14233c]"
          }`}
        >
          <FileDown className="w-4 h-4" />
          <span>Export Defaults</span>
        </button>

        <button
          type="button"
          onClick={() => setActiveTab("system")}
          className={`w-full flex items-center gap-3 px-3 py-2 rounded-lg text-xs font-mono transition-colors cursor-pointer ${
            activeTab === "system"
              ? "bg-[#9fef00]/15 text-[#9fef00] font-bold border-l-2 border-[#9fef00]"
              : "text-[#8ba0c3] hover:text-[#ffffff] hover:bg-[#14233c]"
          }`}
        >
          <Database className="w-4 h-4" />
          <span>System & Stats</span>
        </button>

        <button
          type="button"
          onClick={() => setActiveTab("tools")}
          className={`w-full flex items-center gap-3 px-3 py-2 rounded-lg text-xs font-mono transition-colors cursor-pointer ${
            activeTab === "tools"
              ? "bg-[#9fef00]/15 text-[#9fef00] font-bold border-l-2 border-[#9fef00]"
              : "text-[#8ba0c3] hover:text-[#ffffff] hover:bg-[#14233c]"
          }`}
        >
          <Wrench className="w-4 h-4" />
          <span>Security Toolkit</span>
        </button>

        <div className="pt-4 mt-4 border-t border-[#1f3352]">
          <button
            type="button"
            onClick={handleLogout}
            className="w-full flex items-center gap-3 px-3 py-2 rounded-lg text-xs font-mono text-[#ff3366] hover:bg-[#ff3366]/10 transition-colors cursor-pointer"
          >
            <LogOut className="w-4 h-4" />
            <span>End Session (Logout)</span>
          </button>
        </div>
      </div>

      {/* Main Settings Content Panels */}
      <div className="lg:col-span-3 space-y-6">
        {/* TAB 1: Profile & Security */}
        {activeTab === "profile" && (
          <div className="space-y-6">
            {/* Account Info Card */}
            <div className="p-6 rounded-2xl glass-panel border-[#1f3352] space-y-4">
              <div className="flex items-center justify-between pb-4 border-b border-[#1f3352]">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-xl bg-[#14233c] border border-[#1f3352] flex items-center justify-center text-lg font-bold text-[#9fef00]">
                    {user?.name ? user.name[0].toUpperCase() : "U"}
                  </div>
                  <div>
                    <h2 className="text-base font-bold text-[#ffffff]">{user?.name || "Security Researcher"}</h2>
                    <p className="text-xs text-[#8ba0c3] font-mono">{user?.email}</p>
                  </div>
                </div>

                <div className="flex flex-col items-end gap-1">
                  <span className="text-[10px] font-mono text-[#6c7d9c] uppercase">Assigned Role</span>
                  <span
                    className={`px-2.5 py-0.5 rounded-full text-xs font-mono font-bold uppercase border ${
                      user?.role === "ADMIN"
                        ? "bg-[#9fef00]/15 text-[#9fef00] border-[#9fef00]/40"
                        : "bg-[#2de2e6]/15 text-[#2de2e6] border-[#2de2e6]/40"
                    }`}
                  >
                    {user?.role || "READER"}
                  </span>
                </div>
              </div>

              {/* RBAC Capabilities Breakdown */}
              <div className="space-y-2">
                <span className="text-xs font-mono text-[#8ba0c3] block font-semibold">Active Permissions:</span>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs font-mono">
                  <div className="flex items-center gap-2 p-2.5 rounded-lg bg-[#111d30] border border-[#1f3352] text-[#ffffff]">
                    <CheckCircle className="w-3.5 h-3.5 text-[#9fef00]" />
                    <span>Read Technical Writeups</span>
                  </div>
                  <div className="flex items-center gap-2 p-2.5 rounded-lg bg-[#111d30] border border-[#1f3352] text-[#ffffff]">
                    <CheckCircle className="w-3.5 h-3.5 text-[#9fef00]" />
                    <span>Bookmark & Favorite Notes</span>
                  </div>
                  <div className="flex items-center gap-2 p-2.5 rounded-lg bg-[#111d30] border border-[#1f3352] text-[#ffffff]">
                    <CheckCircle className="w-3.5 h-3.5 text-[#9fef00]" />
                    <span>Export to PDF & DOCX</span>
                  </div>
                  <div className="flex items-center gap-2 p-2.5 rounded-lg bg-[#111d30] border border-[#1f3352] text-[#ffffff]">
                    {user?.role === "ADMIN" ? (
                      <>
                        <CheckCircle className="w-3.5 h-3.5 text-[#9fef00]" />
                        <span>Manage Notes & Categories</span>
                      </>
                    ) : (
                      <>
                        <Lock className="w-3.5 h-3.5 text-[#6c7d9c]" />
                        <span className="text-[#8ba0c3]">Write / Edit Notes (Admin Only)</span>
                      </>
                    )}
                  </div>
                </div>
              </div>
            </div>

            {/* Change Password Card */}
            <div className="p-6 rounded-2xl glass-panel border-[#1f3352] space-y-4">
              <div className="flex items-center gap-2 text-sm font-bold text-[#ffffff]">
                <Key className="w-4 h-4 text-[#9fef00]" />
                <span>Change Operator Password</span>
              </div>
              <p className="text-xs text-[#8ba0c3]">
                Keep your cybersecurity session secure with strong credentials (minimum 8 characters).
              </p>

              {passwordStatus && (
                <div
                  className={`p-3 rounded-lg border text-xs font-mono flex items-center gap-2 ${
                    passwordStatus.type === "success"
                      ? "bg-[#9fef00]/15 text-[#9fef00] border-[#9fef00]/40"
                      : "bg-[#ff3366]/15 text-[#ff3366] border-[#ff3366]/40"
                  }`}
                >
                  {passwordStatus.type === "success" ? (
                    <CheckCircle className="w-4 h-4 flex-shrink-0" />
                  ) : (
                    <AlertCircle className="w-4 h-4 flex-shrink-0" />
                  )}
                  <span>{passwordStatus.msg}</span>
                </div>
              )}

              <form onSubmit={handlePasswordChange} className="space-y-3 max-w-md">
                <div>
                  <label className="block text-xs font-mono text-[#8ba0c3] mb-1">Current Password</label>
                  <input
                    type="password"
                    value={currentPassword}
                    onChange={(e) => setCurrentPassword(e.target.value)}
                    required
                    className="w-full px-3 py-2 rounded-lg bg-[#111d30] border border-[#1f3352] text-xs font-mono text-[#ffffff] focus:border-[#9fef00] focus:outline-none"
                    placeholder="Enter current password..."
                  />
                </div>

                <div>
                  <label className="block text-xs font-mono text-[#8ba0c3] mb-1">New Password</label>
                  <input
                    type="password"
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    required
                    minLength={8}
                    className="w-full px-3 py-2 rounded-lg bg-[#111d30] border border-[#1f3352] text-xs font-mono text-[#ffffff] focus:border-[#9fef00] focus:outline-none"
                    placeholder="At least 8 characters..."
                  />
                </div>

                <div>
                  <label className="block text-xs font-mono text-[#8ba0c3] mb-1">Confirm New Password</label>
                  <input
                    type="password"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    required
                    minLength={8}
                    className="w-full px-3 py-2 rounded-lg bg-[#111d30] border border-[#1f3352] text-xs font-mono text-[#ffffff] focus:border-[#9fef00] focus:outline-none"
                    placeholder="Repeat new password..."
                  />
                </div>

                <button
                  type="submit"
                  disabled={passwordLoading}
                  className="px-4 py-2 rounded-xl bg-[#9fef00] hover:bg-[#b4fa1f] text-[#0b121e] text-xs font-mono font-bold transition-all shadow-md active:scale-95 disabled:opacity-50 cursor-pointer"
                >
                  {passwordLoading ? "Updating..." : "Update Password"}
                </button>
              </form>
            </div>
          </div>
        )}

        {/* TAB 2: Reading & Display */}
        {activeTab === "reading" && (
          <div className="p-6 rounded-2xl glass-panel border-[#1f3352] space-y-6">
            <div className="flex items-center justify-between pb-4 border-b border-[#1f3352]">
              <div>
                <h2 className="text-base font-bold text-[#ffffff]">Reading & Display Preferences</h2>
                <p className="text-xs text-[#8ba0c3]">
                  Customize typography, syntax highlighting, and layout ergonomics for research sessions.
                </p>
              </div>

              {prefSaved && (
                <span className="flex items-center gap-1.5 text-xs font-mono text-[#9fef00] bg-[#9fef00]/15 px-3 py-1 rounded-full border border-[#9fef00]/30">
                  <CheckCircle className="w-3.5 h-3.5" />
                  Saved!
                </span>
              )}
            </div>

            {/* Theme & Color Scheme */}
            <div className="space-y-2">
              <label className="text-xs font-mono text-[#8ba0c3] block font-semibold flex items-center gap-1.5">
                <Sun className="w-3.5 h-3.5 text-[#9fef00]" />
                Appearance Mode (Light / White / Dark / System)
              </label>
              <div className="grid grid-cols-3 gap-3">
                {[
                  { id: "light" as ThemeMode, label: "White / Light", desc: "Clean paper white background", icon: Sun },
                  { id: "dark" as ThemeMode, label: "Hack The Box Dark", desc: "Electric cyber darkroom", icon: Moon },
                  { id: "system" as ThemeMode, label: "Browser Sync", desc: "Matches OS system mode", icon: Laptop },
                ].map((item) => {
                  const Icon = item.icon;
                  const isSelected = theme === item.id;
                  return (
                    <button
                      key={item.id}
                      type="button"
                      onClick={() => setTheme(item.id)}
                      className={`p-3 rounded-xl border text-left font-mono transition-all cursor-pointer ${
                        isSelected
                          ? "bg-[#9fef00]/15 border-[#9fef00] text-[#9fef00]"
                          : "bg-[#111d30] border-[#1f3352] text-[#8ba0c3] hover:border-[#6c7d9c]"
                      }`}
                    >
                      <div className="flex items-center gap-2">
                        <Icon className="w-4 h-4 flex-shrink-0" />
                        <span className="text-xs font-bold text-[#ffffff]">{item.label}</span>
                      </div>
                      <div className="text-[10px] text-[#6c7d9c] mt-1">{item.desc}</div>
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Typography Size */}
            <div className="space-y-2">
              <label className="text-xs font-mono text-[#8ba0c3] block font-semibold flex items-center gap-1.5">
                <Type className="w-3.5 h-3.5 text-[#9fef00]" />
                Article Typography Scale
              </label>
              <div className="grid grid-cols-3 gap-3">
                {[
                  { id: "compact", label: "Compact (14px)", desc: "Maximum screen density" },
                  { id: "normal", label: "Standard (16px)", desc: "Optimal balance" },
                  { id: "large", label: "Comfort (18px)", desc: "Large long-form reading" },
                ].map((item) => (
                  <button
                    key={item.id}
                    type="button"
                    onClick={() => setFontSize(item.id)}
                    className={`p-3 rounded-xl border text-left font-mono transition-all cursor-pointer ${
                      fontSize === item.id
                        ? "bg-[#9fef00]/15 border-[#9fef00] text-[#9fef00]"
                        : "bg-[#111d30] border-[#1f3352] text-[#8ba0c3] hover:border-[#6c7d9c]"
                    }`}
                  >
                    <div className="text-xs font-bold text-[#ffffff]">{item.label}</div>
                    <div className="text-[10px] text-[#6c7d9c] mt-0.5">{item.desc}</div>
                  </button>
                ))}
              </div>
            </div>

            {/* Code Theme */}
            <div className="space-y-2">
              <label className="text-xs font-mono text-[#8ba0c3] block font-semibold flex items-center gap-1.5">
                <Code2 className="w-3.5 h-3.5 text-[#9fef00]" />
                Terminal & Code Highlight Palette
              </label>
              <div className="grid grid-cols-3 gap-3">
                {[
                  { id: "emerald", label: "HTB Emerald", color: "#9fef00" },
                  { id: "cyan", label: "Cyber Cyan", color: "#2de2e6" },
                  { id: "monokai", label: "Matrix Orange", color: "#ff8400" },
                ].map((item) => (
                  <button
                    key={item.id}
                    type="button"
                    onClick={() => setCodeTheme(item.id)}
                    className={`p-3 rounded-xl border text-left font-mono transition-all cursor-pointer flex items-center gap-2 ${
                      codeTheme === item.id
                        ? "bg-[#14233c] border-[#9fef00] text-[#9fef00]"
                        : "bg-[#111d30] border-[#1f3352] text-[#8ba0c3] hover:border-[#6c7d9c]"
                    }`}
                  >
                    <span className="w-3 h-3 rounded-full" style={{ backgroundColor: item.color }} />
                    <span className="text-xs font-semibold text-[#ffffff]">{item.label}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Toggles */}
            <div className="space-y-3 pt-2">
              <label className="flex items-center justify-between p-3 rounded-xl bg-[#111d30] border border-[#1f3352] cursor-pointer">
                <div>
                  <span className="text-xs font-semibold text-[#ffffff] block">Display Line Numbers</span>
                  <span className="text-[11px] text-[#8ba0c3]">Show syntax line numbering on bash and python code blocks</span>
                </div>
                <input
                  type="checkbox"
                  checked={showLineNumbers}
                  onChange={(e) => setShowLineNumbers(e.target.checked)}
                  className="w-4 h-4 accent-[#9fef00] cursor-pointer"
                />
              </label>

              <label className="flex items-center justify-between p-3 rounded-xl bg-[#111d30] border border-[#1f3352] cursor-pointer">
                <div>
                  <span className="text-xs font-semibold text-[#ffffff] block">Smooth Scroll Headings</span>
                  <span className="text-[11px] text-[#8ba0c3]">Animate viewport smoothly when clicking Table of Contents anchors</span>
                </div>
                <input
                  type="checkbox"
                  checked={smoothScroll}
                  onChange={(e) => setSmoothScroll(e.target.checked)}
                  className="w-4 h-4 accent-[#9fef00] cursor-pointer"
                />
              </label>
            </div>

            <div className="pt-4 border-t border-[#1f3352]">
              <button
                type="button"
                onClick={saveReadingPrefs}
                className="flex items-center gap-2 px-4 py-2 rounded-xl bg-[#9fef00] hover:bg-[#b4fa1f] text-[#0b121e] text-xs font-mono font-bold transition-all shadow-md active:scale-95 cursor-pointer"
              >
                <Save className="w-3.5 h-3.5" />
                <span>Save Reading Preferences</span>
              </button>
            </div>
          </div>
        )}

        {/* TAB 3: Export Defaults */}
        {activeTab === "export" && (
          <div className="p-6 rounded-2xl glass-panel border-[#1f3352] space-y-6">
            <div>
              <h2 className="text-base font-bold text-[#ffffff]">Export & Reporting Standards</h2>
              <p className="text-xs text-[#8ba0c3]">
                Set publication parameters for Microsoft Word DOCX and Print-to-PDF deliverables.
              </p>
            </div>

            <div className="space-y-4">
              <div className="space-y-2">
                <label className="text-xs font-mono text-[#8ba0c3] block font-semibold">
                  Default Quick Export Format
                </label>
                <div className="flex gap-4">
                  <label className="flex items-center gap-2 text-xs font-mono text-[#ffffff] cursor-pointer">
                    <input
                      type="radio"
                      name="exportType"
                      value="pdf"
                      checked={defaultExport === "pdf"}
                      onChange={() => setDefaultExport("pdf")}
                      className="accent-[#9fef00]"
                    />
                    <span>Clean Print PDF</span>
                  </label>
                  <label className="flex items-center gap-2 text-xs font-mono text-[#ffffff] cursor-pointer">
                    <input
                      type="radio"
                      name="exportType"
                      value="docx"
                      checked={defaultExport === "docx"}
                      onChange={() => setDefaultExport("docx")}
                      className="accent-[#9fef00]"
                    />
                    <span>Microsoft Word (.docx)</span>
                  </label>
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-xs font-mono text-[#8ba0c3] block font-semibold">
                  Classification Banner
                </label>
                <select
                  value={classificationBanner}
                  onChange={(e) => setClassificationBanner(e.target.value)}
                  className="px-3 py-2 rounded-lg bg-[#111d30] border border-[#1f3352] text-xs font-mono text-[#ffffff] focus:border-[#9fef00] focus:outline-none"
                >
                  <option value="TLP:AMBER">TLP:AMBER // LIMITED DISCLOSURE</option>
                  <option value="TLP:RED">TLP:RED // STRICTLY CONFIDENTIAL</option>
                  <option value="INTERNAL">INTERNAL RESEARCH ONLY</option>
                  <option value="PUBLIC">PUBLIC RELEASE</option>
                </select>
              </div>

              <div className="space-y-3 pt-2">
                <label className="flex items-center justify-between p-3 rounded-xl bg-[#111d30] border border-[#1f3352] cursor-pointer">
                  <div>
                    <span className="text-xs font-semibold text-[#ffffff] block">Include Author Metadata</span>
                    <span className="text-[11px] text-[#8ba0c3]">Embed researcher name, email, and timestamp on document cover page</span>
                  </div>
                  <input
                    type="checkbox"
                    checked={includeAuthor}
                    onChange={(e) => setIncludeAuthor(e.target.checked)}
                    className="w-4 h-4 accent-[#9fef00] cursor-pointer"
                  />
                </label>

                <label className="flex items-center justify-between p-3 rounded-xl bg-[#111d30] border border-[#1f3352] cursor-pointer">
                  <div>
                    <span className="text-xs font-semibold text-[#ffffff] block">Embed Heading Table of Contents</span>
                    <span className="text-[11px] text-[#8ba0c3]">Generate automatic table of contents at the beginning of export documents</span>
                  </div>
                  <input
                    type="checkbox"
                    checked={includeToc}
                    onChange={(e) => setIncludeToc(e.target.checked)}
                    className="w-4 h-4 accent-[#9fef00] cursor-pointer"
                  />
                </label>
              </div>
            </div>
          </div>
        )}

        {/* TAB 4: System Diagnostics */}
        {activeTab === "system" && (
          <div className="p-6 rounded-2xl glass-panel border-[#1f3352] space-y-6">
            <div>
              <h2 className="text-base font-bold text-[#ffffff]">System Telemetry & Architecture</h2>
              <p className="text-xs text-[#8ba0c3]">
                Runtime state, storage indices, and platform health telemetry.
              </p>
            </div>

            {/* Quick Metrics */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
              <div className="p-4 rounded-xl bg-[#111d30] border border-[#1f3352] space-y-1">
                <span className="text-[10px] font-mono text-[#6c7d9c] uppercase">Documents</span>
                <p className="text-xl font-bold font-mono text-[#9fef00]">{stats.totalDocs}</p>
              </div>
              <div className="p-4 rounded-xl bg-[#111d30] border border-[#1f3352] space-y-1">
                <span className="text-[10px] font-mono text-[#6c7d9c] uppercase">Categories</span>
                <p className="text-xl font-bold font-mono text-[#2de2e6]">{stats.totalCategories}</p>
              </div>
              <div className="p-4 rounded-xl bg-[#111d30] border border-[#1f3352] space-y-1">
                <span className="text-[10px] font-mono text-[#6c7d9c] uppercase">Tags</span>
                <p className="text-xl font-bold font-mono text-[#a855f7]">{stats.totalTags}</p>
              </div>
              <div className="p-4 rounded-xl bg-[#111d30] border border-[#1f3352] space-y-1">
                <span className="text-[10px] font-mono text-[#6c7d9c] uppercase">Your Favorites</span>
                <p className="text-xl font-bold font-mono text-[#ff8400]">{stats.totalFavorites}</p>
              </div>
            </div>

            {/* System Breakdown */}
            <div className="rounded-xl border border-[#1f3352] bg-[#111d30] divide-y divide-[#1f3352] text-xs font-mono">
              <div className="p-3 flex items-center justify-between">
                <span className="text-[#8ba0c3]">Platform Kernel</span>
                <span className="text-[#ffffff]">Next.js 16.4.2 (App Router)</span>
              </div>
              <div className="p-3 flex items-center justify-between">
                <span className="text-[#8ba0c3]">Database Layer</span>
                <span className="text-[#ffffff]">PostgreSQL + Prisma ORM</span>
              </div>
              <div className="p-3 flex items-center justify-between">
                <span className="text-[#8ba0c3]">Document Rendering</span>
                <span className="text-[#ffffff]">Unified / Remark / Rehype + PrismJS</span>
              </div>
              <div className="p-3 flex items-center justify-between">
                <span className="text-[#8ba0c3]">Export Engines</span>
                <span className="text-[#ffffff]">Native docx buffer & CSS Paged Media PDF</span>
              </div>
              <div className="p-3 flex items-center justify-between">
                <span className="text-[#8ba0c3]">Operational State</span>
                <span className="text-[#9fef00] flex items-center gap-1.5">
                  <span className="w-2 h-2 rounded-full bg-[#9fef00] animate-pulse" />
                  DEFCON 5 // SYSTEM NORMAL
                </span>
              </div>
            </div>
          </div>
        )}

        {/* TAB 5: Security Toolkit */}
        {activeTab === "tools" && <SecurityToolkit />}
      </div>
    </div>
  );
}
