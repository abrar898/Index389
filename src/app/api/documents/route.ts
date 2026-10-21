import { NextResponse } from "next/server";
import prisma from "@/lib/db";
import { getCurrentUser, logAudit } from "@/lib/auth";
import { parseMarkdownFile } from "@/lib/markdown";

export async function POST(req: Request) {
  try {
    const user = await getCurrentUser();
    if (!user || user.role !== "ADMIN") {
      return NextResponse.json({ error: "Forbidden: Only administrators can create documents." }, { status: 403 });
    }

    const body = await req.json();
    const { title, slug, description, contentMarkdown, categoryId, tags, status } = body;

    if (!title || !slug || !contentMarkdown) {
      return NextResponse.json({ error: "Title, slug, and content are required." }, { status: 400 });
    }

    // Check slug uniqueness
    const existing = await prisma.document.findUnique({
      where: { slug },
    });

    let finalSlug = slug;
    if (existing) {
      finalSlug = `${slug}-${Math.floor(1000 + Math.random() * 9000)}`;
    }

    const parsed = parseMarkdownFile(contentMarkdown);

    const doc = await prisma.document.create({
      data: {
        title,
        slug: finalSlug,
        description: description || parsed.description,
        contentMarkdown,
        status: status || "PUBLISHED",
        readingTimeMin: parsed.readingTimeMin,
        categoryId: categoryId || null,
        authorId: user.id,
      },
    });

    // Attach tags if provided
    if (Array.isArray(tags)) {
      for (const tagName of tags) {
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
    }

    await logAudit("CREATE_DOCUMENT", "Document", doc.id, `Created document: ${doc.title}`, user.id);

    return NextResponse.json(doc, { status: 201 });
  } catch (err: unknown) {
    console.error("Document creation error:", err);
    return NextResponse.json({ error: "Failed to create document." }, { status: 500 });
  }
}
