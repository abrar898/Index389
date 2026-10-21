import Link from "next/link";
import prisma from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { FileText, Folder, Tag, Calendar, Clock, Filter, Plus } from "lucide-react";
import { FavoriteButton } from "@/components/notes/FavoriteButton";

export default async function AllNotesPage(props: {
  searchParams: Promise<{ category?: string; tag?: string; status?: string }>;
}) {
  const searchParams = await props.searchParams;
  const user = await getCurrentUser();

  const whereClause: Record<string, unknown> = {
    deletedAt: null,
  };

  if (searchParams.category) {
    whereClause.category = { slug: searchParams.category };
  }

  if (searchParams.tag) {
    whereClause.tags = {
      some: { tag: { slug: searchParams.tag } },
    };
  }

  const [notes, categories, userFavorites] = await Promise.all([
    prisma.document.findMany({
      where: whereClause,
      orderBy: { updatedAt: "desc" },
      include: {
        category: true,
        tags: { include: { tag: true } },
        author: { select: { name: true, email: true } },
      },
    }),
    prisma.category.findMany({ orderBy: { name: "asc" } }),
    user
      ? prisma.favorite.findMany({
          where: { userId: user.id },
          select: { documentId: true },
        })
      : [],
  ]);

  const favoriteIds = new Set(userFavorites.map((f) => f.documentId));

  return (
    <div className="space-y-6">
      {/* Header Bar */}
      <div className="flex flex-wrap items-center justify-between gap-4 p-6 rounded-2xl glass-panel border-[#1f3352]">
        <div>
          <div className="flex items-center gap-2 font-mono text-xs text-[#9fef00]">
            <FileText className="w-4 h-4" />
            <span>CENTRAL REPOSITORY</span>
          </div>
          <h1 className="text-2xl font-bold text-[#ffffff] mt-1">Cybersecurity Documentation</h1>
          <p className="text-xs text-[#8ba0c3] font-mono mt-0.5">
            Showing {notes.length} verified technical research notes
          </p>
        </div>

        {user?.role === "ADMIN" && (
          <Link
            href="/notes/new"
            className="flex items-center gap-2 px-4 py-2 rounded-xl bg-[#9fef00] hover:bg-[#b4fa1f] text-xs font-bold text-[#0b121e] transition-all shadow-md active:scale-95"
          >
            <Plus className="w-4 h-4" />
            <span>New Document</span>
          </Link>
        )}
      </div>

      {/* Filter Tabs */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1 text-xs">
        <Link
          href="/notes"
          className={`px-3 py-1.5 rounded-lg border font-mono transition-colors ${
            !searchParams.category && !searchParams.tag
              ? "bg-[#9fef00]/15 text-[#9fef00] border-[#9fef00]/50 font-semibold"
              : "bg-[#14233c] text-[#8ba0c3] border-[#1f3352] hover:text-[#ffffff]"
          }`}
        >
          All
        </Link>

        {categories.map((c) => (
          <Link
            key={c.id}
            href={`/notes?category=${c.slug}`}
            className={`px-3 py-1.5 rounded-lg border font-mono transition-colors flex items-center gap-1.5 whitespace-nowrap ${
              searchParams.category === c.slug
                ? "bg-[#9fef00]/15 text-[#9fef00] border-[#9fef00]/50 font-semibold"
                : "bg-[#14233c] text-[#8ba0c3] border-[#1f3352] hover:text-[#ffffff]"
            }`}
          >
            <Folder className="w-3 h-3 text-[#9fef00]" />
            <span>{c.name}</span>
          </Link>
        ))}
      </div>

      {/* Notes List */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {notes.length === 0 ? (
          <div className="col-span-full p-12 text-center rounded-2xl glass-panel border-[#1f3352] text-[#8ba0c3] space-y-3">
            <FileText className="w-8 h-8 mx-auto text-[#6c7d9c]" />
            <p className="text-sm">No documentation notes match your criteria.</p>
            <Link
              href="/notes/new"
              className="inline-block font-mono text-xs text-[#9fef00] hover:underline"
            >
              Create your first note &rarr;
            </Link>
          </div>
        ) : (
          notes.map((note) => (
            <div
              key={note.id}
              className="group flex flex-col justify-between p-5 rounded-2xl glass-panel glass-panel-hover border-[#1f3352] hover:border-[#9fef00]/70 transition-all shadow-md"
            >
              <div className="space-y-3">
                <div className="flex items-center justify-between text-xs">
                  {note.category ? (
                    <span className="font-mono text-[#9fef00] flex items-center gap-1 text-[11px]">
                      <Folder className="w-3 h-3" />
                      {note.category.name}
                    </span>
                  ) : (
                    <span className="text-[#6c7d9c] text-[11px]">Uncategorized</span>
                  )}
                  <div className="flex items-center gap-2">
                    <span className="font-mono text-[10px] text-[#6c7d9c]">{note.readingTimeMin}m read</span>
                    <FavoriteButton
                      documentId={note.id}
                      initialFavorited={favoriteIds.has(note.id)}
                      showText={false}
                      className="p-1 px-1.5"
                    />
                  </div>
                </div>

                <Link href={`/notes/${note.slug}`} className="block">
                  <h3 className="font-bold text-base text-[#ffffff] group-hover:text-[#9fef00] transition-colors line-clamp-2">
                    {note.title}
                  </h3>
                </Link>

                <p className="text-xs text-[#a4b1cd] line-clamp-2 leading-relaxed">
                  {note.description || "Operational commands and structured technical documentation."}
                </p>
              </div>

              <div className="pt-4 mt-4 border-t border-[#1f3352] flex items-center justify-between text-xs text-[#6c7d9c] font-mono">
                <div className="flex items-center gap-1">
                  {note.tags.slice(0, 3).map(({ tag }) => (
                    <span
                      key={tag.id}
                      className="px-1.5 py-0.5 rounded bg-[#111d30] border border-[#1f3352] text-[10px] text-[#8ba0c3]"
                    >
                      #{tag.name}
                    </span>
                  ))}
                </div>
                <Link
                  href={`/notes/${note.slug}`}
                  className="text-[11px] text-[#9fef00] hover:underline font-mono"
                >
                  Read &rarr;
                </Link>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
