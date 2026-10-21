import prisma from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { Settings, Shield, Sliders } from "lucide-react";
import { SettingsClient } from "@/components/settings/SettingsClient";

export const metadata = {
  title: "Settings & Configuration // CyberNotes KB",
  description: "User preferences, typography settings, export templates, and telemetry.",
};

export default async function SettingsPage() {
  const user = await getCurrentUser();

  const [totalDocs, totalCategories, totalTags, totalFavorites] = await Promise.all([
    prisma.document.count({ where: { deletedAt: null } }),
    prisma.category.count(),
    prisma.tag.count(),
    user ? prisma.favorite.count({ where: { userId: user.id } }) : 0,
  ]);

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="flex flex-wrap items-center justify-between gap-4 p-6 rounded-2xl border border-[#1f3352] glass-panel relative overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-[#9fef00]/10 via-transparent to-transparent rounded-full blur-2xl pointer-events-none" />

        <div className="space-y-1 relative z-10">
          <div className="flex items-center gap-2 font-mono text-xs text-[#9fef00]">
            <Sliders className="w-4 h-4" />
            <span>OPERATING ENVIRONMENT CONTROLS</span>
          </div>
          <h1 className="text-2xl font-extrabold tracking-tight text-[#ffffff]">
            Platform Settings & Preferences
          </h1>
          <p className="text-xs text-[#a4b1cd] font-mono">
            Manage your credentials, reading aesthetics, export configurations, and security profiles
          </p>
        </div>
      </div>

      {/* Settings Client Interface */}
      <SettingsClient
        user={user}
        stats={{
          totalDocs,
          totalCategories,
          totalTags,
          totalFavorites,
        }}
      />
    </div>
  );
}
