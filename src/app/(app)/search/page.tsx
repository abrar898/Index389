import Link from "next/link";
import prisma from "@/lib/db";
import { Search as SearchIcon, FileText, ArrowRight, Folder } from "lucide-react";

export default async function SearchResultsPage(props: {
  searchParams: Promise<{ q?: string }>;
}) {
  const searchParams = await props.searchParams;
  const q = searchParams.q?.trim() || "";

  const results = q
    ? await prisma.document.findMany({
        where: {
          deletedAt: null,
          OR: [
            { title: { contains: q } },
            { description: { contains: q } },
            { contentMarkdown: { contains: q } },
          ],
        },
        include: {
          category: true,
          tags: { include: { tag: true } },
        },
        orderBy: { updatedAt: "desc" },
      })
    : [];

  return (
    <div className="space-y-6">
      <div className="p-6 rounded-xl border border-[#1f3352] glass-panel space-y-2">
        <div className="flex items-center gap-2 font-mono text-xs text-[#9fef00]">
          <SearchIcon className="w-4 h-4" />
          <span>SEARCH DISCOVERY ENGINE</span>
        </div>
        <h1 className="text-2xl font-bold text-[#ffffff]">
          Search Results for: &ldquo;<span className="text-[#9fef00] font-mono">{q}</span>&rdquo;
        </h1>
        <p className="text-xs text-[#a4b1cd] font-mono">Found {results.length} matching document(s)</p>
      </div>

      <div className="space-y-3">
        {results.length === 0 ? (
          <div className="p-12 text-center rounded-xl border border-[#1f3352] glass-panel text-[#6c7d9c]">
            <p className="text-sm">No notes or commands match your query.</p>
          </div>
        ) : (
          results.map((doc) => (
            <Link
              key={doc.id}
              href={`/notes/${doc.slug}`}
              className="group block p-5 rounded-xl border border-[#1f3352] glass-panel hover:border-[#9fef00]/60 hover:bg-[#14233c]/80 transition-all"
            >
              <div className="flex items-center justify-between text-xs mb-2">
                {doc.category ? (
                  <span className="font-mono text-[#9fef00] flex items-center gap-1">
                    <Folder className="w-3.5 h-3.5" />
                    {doc.category.name}
                  </span>
                ) : (
                  <span className="text-[#6c7d9c]">Uncategorized</span>
                )}
                <span className="font-mono text-[#8ba0c3]">{doc.readingTimeMin} min read</span>
              </div>
              <h2 className="text-base font-bold text-[#ffffff] group-hover:text-[#9fef00] transition-colors">
                {doc.title}
              </h2>
              {doc.description && (
                <p className="text-xs text-[#a4b1cd] mt-1.5 line-clamp-2 leading-relaxed">
                  {doc.description}
                </p>
              )}
            </Link>
          ))
        )}
      </div>
    </div>
  );
}
