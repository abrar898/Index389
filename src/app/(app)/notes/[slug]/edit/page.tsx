import { notFound, redirect } from "next/navigation";
import prisma from "@/lib/db";
import { getCurrentUser, canEditDocument } from "@/lib/auth";
import { NoteEditor } from "@/components/editor/NoteEditor";

export default async function EditNotePage(props: { params: Promise<{ slug: string }> }) {
  const params = await props.params;
  const user = await getCurrentUser();
  if (!user) {
    redirect("/login");
  }

  const doc = await prisma.document.findUnique({
    where: { slug: params.slug },
    include: {
      tags: { include: { tag: true } },
    },
  });

  if (!doc || doc.deletedAt) {
    notFound();
  }

  if (!canEditDocument(user, doc.authorId)) {
    redirect(`/notes/${doc.slug}`);
  }

  const categories = await prisma.category.findMany({
    orderBy: { name: "asc" },
    select: { id: true, name: true },
  });

  const formattedDoc = {
    id: doc.id,
    title: doc.title,
    slug: doc.slug,
    description: doc.description,
    contentMarkdown: doc.contentMarkdown,
    status: doc.status,
    categoryId: doc.categoryId,
    tags: doc.tags.map((t) => t.tag.name),
  };

  return <NoteEditor initialDocument={formattedDoc} categories={categories} />;
}
