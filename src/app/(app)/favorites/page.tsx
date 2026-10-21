import Link from "next/link";
import prisma from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { Star, Shield, Lock } from "lucide-react";
import { FavoritesClient } from "@/components/favorites/FavoritesClient";

export const metadata = {
  title: "Favorites & Bookmarks // CyberNotes KB",
  description: "Quick-access pinned cybersecurity research notes, exploits, and cheat-sheets.",
};

export default async function FavoritesPage() {
  const user = await getCurrentUser();

  if (!user) {
    return (
      <div className="p-12 text-center rounded-2xl border border-[#1f3352] glass-panel text-[#8ba0c3] space-y-4 max-w-lg mx-auto my-12">
        <div className="w-12 h-12 rounded-xl bg-[#111d30] border border-[#1f3352] flex items-center justify-center mx-auto text-[#ff8400]">
          <Lock className="w-6 h-6" />
        </div>
        <div className="space-y-1">
          <h2 className="text-xl font-bold text-[#ffffff]">Authentication Required</h2>
          <p className="text-xs text-[#8ba0c3]">
            Log in to save and sync bookmarked research notes across your cybersecurity sessions.
          </p>
        </div>
        <Link
          href="/login"
          className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-[#9fef00] hover:bg-[#b4fa1f] text-xs font-bold text-[#0b121e] transition-all shadow-md active:scale-95"
        >
          <span>Sign In to Access Favorites</span>
        </Link>
      </div>
    );
  }

  const [favorites, categories] = await Promise.all([
    prisma.favorite.findMany({
      where: {
        userId: user.id,
        document: { deletedAt: null },
      },
      orderBy: { createdAt: "desc" },
      include: {
        document: {
          include: {
            category: true,
            tags: { include: { tag: true } },
            author: { select: { name: true, email: true } },
          },
        },
      },
    }),
    prisma.category.findMany({
      orderBy: { name: "asc" },
      select: { id: true, name: true, slug: true },
    }),
  ]);

  const initialNotes = favorites.map((f) => f.document);

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="flex flex-wrap items-center justify-between gap-4 p-6 rounded-2xl border border-[#1f3352] glass-panel relative overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-[#ff8400]/10 via-transparent to-transparent rounded-full blur-2xl pointer-events-none" />

        <div className="space-y-1 relative z-10">
          <div className="flex items-center gap-2 font-mono text-xs text-[#ff8400]">
            <Star className="w-4 h-4 fill-[#ff8400]" />
            <span>RAPID ENGAGEMENT VAULT</span>
          </div>
          <h1 className="text-2xl font-extrabold tracking-tight text-[#ffffff]">
            Pinned & Favorite Writeups
          </h1>
          <p className="text-xs text-[#8ba0c3] font-mono">
            {initialNotes.length} pinned document(s) saved by {user.name || user.email}
          </p>
        </div>
      </div>

      {/* Interactive Client Component */}
      <FavoritesClient initialNotes={initialNotes} categories={categories} />
    </div>
  );
}
