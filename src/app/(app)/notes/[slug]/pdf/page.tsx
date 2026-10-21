import { notFound } from "next/navigation";
import prisma from "@/lib/db";
import { parseMarkdownFile } from "@/lib/markdown";
import { MarkdownRenderer } from "@/components/markdown/MarkdownRenderer";
import { Shield, Printer } from "lucide-react";
import { PrintButton } from "./PrintButton";

export default async function DocumentPdfView(props: { params: Promise<{ slug: string }> }) {
  const params = await props.params;

  const doc = await prisma.document.findUnique({
    where: { slug: params.slug },
    include: {
      category: true,
      author: { select: { name: true, email: true } },
    },
  });

  if (!doc || doc.deletedAt) {
    notFound();
  }

  const parsed = parseMarkdownFile(doc.contentMarkdown);

  return (
    <div className="min-h-screen bg-white text-gray-900 p-8 md:p-14 max-w-4xl mx-auto font-sans leading-relaxed">
      {/* Top action toolbar (hidden when printed) */}
      <div className="no-print mb-8 pb-4 border-b border-gray-200 flex items-center justify-between">
        <div className="flex items-center gap-2 text-sm text-gray-500 font-mono">
          <Shield className="w-4 h-4 text-emerald-600" />
          <span>CYBERNOTES // EXPORT ENGINE</span>
        </div>
        <PrintButton />
      </div>

      {/* Document Header */}
      <div className="border-b-2 border-gray-900 pb-6 mb-8 space-y-3">
        <div className="text-xs uppercase font-mono tracking-widest text-emerald-600 font-bold">
          {doc.category ? doc.category.name : "Technical Cybersecurity Documentation"}
        </div>
        <h1 className="text-3xl font-bold tracking-tight text-gray-900">{doc.title}</h1>
        {doc.description && <p className="text-sm text-gray-600 italic">{doc.description}</p>}
        <div className="flex items-center gap-4 text-xs font-mono text-gray-500 pt-2">
          <span>Author: {doc.author.name || doc.author.email}</span>
          <span>•</span>
          <span>
            Date:{" "}
            {new Date(doc.updatedAt).toLocaleDateString("en-US", {
              year: "numeric",
              month: "short",
              day: "numeric",
            })}
          </span>
          <span>•</span>
          <span>Est. Reading: {doc.readingTimeMin} min</span>
        </div>
      </div>

      {/* Rendered Markdown Body */}
      <div className="prose max-w-none text-gray-800 text-sm">
        <MarkdownRenderer content={parsed.cleanMarkdown} />
      </div>

      {/* Document Footer */}
      <div className="mt-16 pt-6 border-t border-gray-200 text-xs font-mono text-gray-400 flex items-center justify-between">
        <span>Confidential & Proprietary // Cybersecurity Knowledge Base</span>
        <span>Generated via CyberNotes Platform</span>
      </div>
    </div>
  );
}
