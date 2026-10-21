import { NextResponse } from "next/server";
import prisma from "@/lib/db";
import { getCurrentUser, logAudit } from "@/lib/auth";
import { parseMarkdownFile } from "@/lib/markdown";

export async function POST(req: Request) {
  try {
    const user = await getCurrentUser();
    if (!user || user.role !== "ADMIN") {
      return NextResponse.json({ error: "Forbidden: Only administrators can import documents." }, { status: 403 });
    }

    const body = await req.json();
    const { title, slug, description, categoryName, tags, contentMarkdown } = body;

    if (!title || !contentMarkdown) {
      return NextResponse.json({ error: "Title and markdown content are required." }, { status: 400 });
    }

    const parsed = parseMarkdownFile(contentMarkdown);

    // Resolve or create category
    let categoryId = null;
    if (categoryName) {
      const catSlug = categoryName
        .toLowerCase()
        .trim()
        .replace(/[^\w\s-]/g, "")
        .replace(/\s+/g, "-");

      const catRecord = await prisma.category.upsert({
        where: { slug: catSlug },
        update: {},
        create: {
          name: categoryName,
          slug: catSlug,
          description: `Imported category for ${categoryName}`,
        },
      });
      categoryId = catRecord.id;
    }

    // Determine unique slug
    let baseSlug = (slug || parsed.title)
      .toLowerCase()
      .trim()
      .replace(/[^\w\s-]/g, "")
      .replace(/\s+/g, "-");

    if (!baseSlug) baseSlug = `note-${Date.now()}`;

    let finalSlug = baseSlug;
    const existing = await prisma.document.findUnique({ where: { slug: finalSlug } });
    if (existing) {
      finalSlug = `${baseSlug}-${Math.floor(1000 + Math.random() * 9000)}`;
    }

    const doc = await prisma.document.create({
      data: {
        title: title || parsed.title,
        slug: finalSlug,
        description: description || parsed.description,
        contentMarkdown,
        status: "PUBLISHED",
        readingTimeMin: parsed.readingTimeMin,
        categoryId,
        authorId: user.id,
      },
    });

    // Link tags
    const allTags = [...(Array.isArray(tags) ? tags : []), ...parsed.tags];
    for (const tagName of allTags) {
      const cleanTag = String(tagName).trim().toLowerCase();
      if (!cleanTag) continue;

      const tagRecord = await prisma.tag.upsert({
        where: { slug: cleanTag },
        update: {},
        create: { name: cleanTag, slug: cleanTag },
      });

      await prisma.documentTag.upsert({
        where: {
          documentId_tagId: {
            documentId: doc.id,
            tagId: tagRecord.id,
          },
        },
        update: {},
        create: {
          documentId: doc.id,
          tagId: tagRecord.id,
        },
      });
    }

    await logAudit("IMPORT_DOCUMENT", "Document", doc.id, `Imported Markdown document: ${doc.title}`, user.id);

    return NextResponse.json({ success: true, slug: doc.slug });
  } catch (err: unknown) {
    console.error("Import error:", err);
    return NextResponse.json({ error: "Failed to import Markdown document." }, { status: 500 });
  }
}
