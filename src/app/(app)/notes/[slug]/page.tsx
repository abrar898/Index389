import { notFound } from "next/navigation";
import prisma from "@/lib/db";
import { getCurrentUser, canEditDocument } from "@/lib/auth";
import { parseMarkdownFile } from "@/lib/markdown";
import { NoteViewerContainer } from "@/components/notes/NoteViewerContainer";

export default async function NoteDetailPage(props: { params: Promise<{ slug: string }> }) {
  const params = await props.params;
  const user = await getCurrentUser();

  const doc = await prisma.document.findUnique({
    where: { slug: params.slug },
    include: {
      category: true,
      tags: { include: { tag: true } },
      author: { select: { id: true, name: true, email: true } },
    },
  });

  if (!doc || doc.deletedAt) {
    notFound();
  }

  // Parse markdown for TOC and clean body
  const parsed = parseMarkdownFile(doc.contentMarkdown);

  // Fetch adjacent notes for previous/next navigation
  const [prevDoc, nextDoc] = await Promise.all([
    prisma.document.findFirst({
      where: { createdAt: { lt: doc.createdAt }, deletedAt: null },
      orderBy: { createdAt: "desc" },
      select: { title: true, slug: true },
    }),
    prisma.document.findFirst({
      where: { createdAt: { gt: doc.createdAt }, deletedAt: null },
      orderBy: { createdAt: "asc" },
      select: { title: true, slug: true },
    }),
  ]);

  // Fetch related notes in the same category
  const relatedNotes = doc.categoryId
    ? await prisma.document.findMany({
        where: {
          categoryId: doc.categoryId,
          id: { not: doc.id },
          deletedAt: null,
        },
        take: 4,
        select: { title: true, slug: true },
      })
    : [];

  const userCanEdit = canEditDocument(user, doc.authorId);

  // Check if user bookmarked this note
  const isFavorited = user
    ? !!(await prisma.favorite.findUnique({
        where: {
          userId_documentId: {
            userId: user.id,
            documentId: doc.id,
          },
        },
      }))
    : false;

  return (
    <NoteViewerContainer
      doc={{
        id: doc.id,
        title: doc.title,
        slug: doc.slug,
        description: doc.description,
        updatedAt: doc.updatedAt,
        readingTimeMin: doc.readingTimeMin,
        category: doc.category,
        tags: doc.tags,
        author: doc.author,
      }}
      cleanMarkdown={parsed.cleanMarkdown}
      toc={parsed.toc}
      userCanEdit={userCanEdit}
      initialFavorited={isFavorited}
      prevDoc={prevDoc}
      nextDoc={nextDoc}
      relatedNotes={relatedNotes}
    />
  );
}
