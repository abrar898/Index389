import { notFound } from "next/navigation";
import Link from "next/link";
import prisma from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { Folder, FileText, Plus, Clock, ArrowRight, ArrowLeft } from "lucide-react";
import { FavoriteButton } from "@/components/notes/FavoriteButton";

export default async function CategoryDetailPage(props: {
  params: Promise<{ slug: string }>;
  searchParams: Promise<{ tag?: string }>;
}) {
  const params = await props.params;
  const searchParams = await props.searchParams;
  const user = await getCurrentUser();

  const category = await prisma.category.findUnique({
    where: { slug: params.slug },
    include: {
      _count: {
        select: { documents: { where: { deletedAt: null } } },
      },
    },
  });

  if (!category) {
    notFound();
  }

  // Fetch documents belonging to this category
  const whereClause: Record<string, unknown> = {
    categoryId: category.id,
    deletedAt: null,
  };

  if (searchParams.tag) {
    whereClause.tags = {
      some: { tag: { slug: searchParams.tag } },
    };
  }

  const [documents, userFavorites] = await Promise.all([
    prisma.document.findMany({
      where: whereClause,
      orderBy: { updatedAt: "desc" },
      include: {
        tags: { include: { tag: true } },
        author: { select: { name: true, email: true } },
      },
    }),
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
      {/* Breadcrumb Navigation */}
      <nav className="flex items-center gap-2 text-xs font-mono text-[#6c7d9c]">
        <Link href="/categories" className="hover:text-[#9fef00] transition-colors flex items-center gap-1">
          <ArrowLeft className="w-3.5 h-3.5" />
          <span>ALL CATEGORIES</span>
        </Link>
        <span>/</span>
        <span className="text-[#ffffff] font-semibold uppercase">{category.name}</span>
      </nav>

      {/* Category Banner */}
      <div className="flex flex-wrap items-center justify-between gap-4 p-6 rounded-2xl border border-[#1f3352] glass-panel relative overflow-hidden">
        <div
          className="absolute top-0 right-0 w-80 h-80 rounded-full blur-3xl pointer-events-none opacity-15"
          style={{ backgroundColor: category.color || "#9fef00" }}
        />

        <div className="space-y-1 relative z-10">
          <div className="flex items-center gap-2 font-mono text-xs">
            <span
              className="w-2.5 h-2.5 rounded-full inline-block"
              style={{ backgroundColor: category.color || "#9fef00" }}
            />
            <span style={{ color: category.color || "#9fef00" }}>DOMAIN TAXONOMY</span>
          </div>
          <h1 className="text-2xl md:text-3xl font-extrabold tracking-tight text-[#ffffff]">
            {category.name}
          </h1>
          <p className="text-xs md:text-sm text-[#a4b1cd] max-w-2xl leading-relaxed">
            {category.description || "Collection of operational penetration testing guides, tactics, and procedures."}
          </p>
          <div className="pt-2 font-mono text-xs text-[#6c7d9c]">
            <span>{category._count.documents} verified document(s) in this domain</span>
          </div>
        </div>

        {user?.role === "ADMIN" && (
          <Link
            href="/notes/new"
            className="flex items-center gap-2 px-4 py-2 rounded-xl bg-[#9fef00] hover:bg-[#b4fa1f] text-xs font-bold text-[#0b121e] transition-all shadow-md active:scale-95"
          >
            <Plus className="w-4 h-4" />
            <span>New Note in Category</span>
          </Link>
        )}
      </div>

      {/* Documents Grid */}
      {documents.length === 0 ? (
        <div className="p-12 text-center rounded-2xl border border-[#1f3352] glass-panel text-[#8ba0c3] space-y-4">
          <FileText className="w-10 h-10 mx-auto text-[#6c7d9c]" />
          <div className="space-y-1">
            <h3 className="text-base font-bold text-[#ffffff]">No Notes Found</h3>
            <p className="text-xs text-[#8ba0c3]">
              No technical writeups have been published in this category yet.
            </p>
          </div>
          {user?.role === "ADMIN" && (
            <Link
              href="/notes/new"
              className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-[#9fef00] hover:bg-[#b4fa1f] text-xs font-bold text-[#0b121e] transition-all shadow-md"
            >
              <Plus className="w-4 h-4" />
              <span>Create First Document</span>
            </Link>
          )}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {documents.map((doc) => (
            <div
              key={doc.id}
              className="group p-5 rounded-2xl border border-[#1f3352] glass-panel glass-panel-hover hover:border-[#9fef00]/60 transition-all flex flex-col justify-between shadow-lg"
            >
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-[11px] font-mono text-[#8ba0c3]">
                    {category.name}
                  </span>
                  <FavoriteButton
                    documentId={doc.id}
                    initialFavorited={favoriteIds.has(doc.id)}
                    showText={false}
                    className="p-1 px-1.5"
                  />
                </div>

                <Link href={`/notes/${doc.slug}`} className="block">
                  <h3 className="text-base font-bold text-[#ffffff] group-hover:text-[#9fef00] transition-colors leading-snug">
                    {doc.title}
                  </h3>
                </Link>

                {doc.description && (
                  <p className="text-xs text-[#a4b1cd] line-clamp-2 leading-relaxed">
                    {doc.description}
                  </p>
                )}

                {doc.tags.length > 0 && (
                  <div className="flex flex-wrap gap-1 pt-1">
                    {doc.tags.map(({ tag }) => (
                      <span
                        key={tag.id}
                        className="px-1.5 py-0.5 rounded bg-[#111d30] border border-[#1f3352] font-mono text-[10px] text-[#8ba0c3]"
                      >
                        #{tag.name}
                      </span>
                    ))}
                  </div>
                )}
              </div>

              <div className="pt-4 mt-4 border-t border-[#1f3352] flex items-center justify-between text-xs text-[#6c7d9c] font-mono">
                <div className="flex items-center gap-2 text-[11px]">
                  <Clock className="w-3 h-3 text-[#9fef00]" />
                  <span>{doc.readingTimeMin} min read</span>
                </div>

                <Link
                  href={`/notes/${doc.slug}`}
                  className="flex items-center gap-1 text-[#9fef00] hover:underline"
                >
                  <span>Explore</span>
                  <ArrowRight className="w-3 h-3 group-hover:translate-x-1 transition-transform" />
                </Link>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
