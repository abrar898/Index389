import { NextResponse } from "next/server";
import prisma from "@/lib/db";
import { getCurrentUser, canEditDocument, logAudit } from "@/lib/auth";
import { parseMarkdownFile } from "@/lib/markdown";

export async function PUT(req: Request, props: { params: Promise<{ slug: string }> }) {
  try {
    const params = await props.params;
    const user = await getCurrentUser();
    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const doc = await prisma.document.findFirst({
      where: {
        OR: [{ id: params.slug }, { slug: params.slug }],
      },
    });

    if (!doc) {
      return NextResponse.json({ error: "Document not found" }, { status: 404 });
    }

    if (!canEditDocument(user, doc.authorId)) {
      return NextResponse.json({ error: "Forbidden: You cannot edit this document." }, { status: 403 });
    }

    const body = await req.json();
    const { title, slug, description, contentMarkdown, categoryId, tags, status } = body;

    const parsed = parseMarkdownFile(contentMarkdown || doc.contentMarkdown);

    // Create a version snapshot before updating
    const versionCount = await prisma.documentVersion.count({ where: { documentId: doc.id } });
    await prisma.documentVersion.create({
      data: {
        documentId: doc.id,
        versionNumber: versionCount + 1,
        title: doc.title,
        contentMarkdown: doc.contentMarkdown,
        changeSummary: "Updated via editor",
        createdById: user.id,
      },
    });

    const updated = await prisma.document.update({
      where: { id: doc.id },
      data: {
        title: title || doc.title,
        slug: slug || doc.slug,
        description: description !== undefined ? description : doc.description,
        contentMarkdown: contentMarkdown || doc.contentMarkdown,
        status: status || doc.status,
        categoryId: categoryId !== undefined ? categoryId : doc.categoryId,
        readingTimeMin: parsed.readingTimeMin,
      },
    });

    if (Array.isArray(tags)) {
      await prisma.documentTag.deleteMany({ where: { documentId: doc.id } });
      for (const tagName of tags) {
        const cleanTag = String(tagName).trim().toLowerCase();
        if (!cleanTag) continue;

        const tagRecord = await prisma.tag.upsert({
          where: { slug: cleanTag },
          update: {},
          create: { name: cleanTag, slug: cleanTag },
        });

        await prisma.documentTag.create({
          data: {
            documentId: doc.id,
            tagId: tagRecord.id,
          },
        });
      }
    }

    await logAudit("UPDATE_DOCUMENT", "Document", doc.id, `Updated document: ${updated.title}`, user.id);

    return NextResponse.json(updated);
  } catch (err: unknown) {
    console.error("Document update error:", err);
    return NextResponse.json({ error: "Failed to update document." }, { status: 500 });
  }
}

export async function DELETE(req: Request, props: { params: Promise<{ slug: string }> }) {
  try {
    const params = await props.params;
    const user = await getCurrentUser();
    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const doc = await prisma.document.findFirst({
      where: {
        OR: [{ id: params.slug }, { slug: params.slug }],
      },
    });

    if (!doc) {
      return NextResponse.json({ error: "Document not found" }, { status: 404 });
    }

    if (!canEditDocument(user, doc.authorId)) {
      return NextResponse.json({ error: "Forbidden" }, { status: 403 });
    }

    await prisma.document.update({
      where: { id: doc.id },
      data: { deletedAt: new Date() },
    });

    await logAudit("DELETE_DOCUMENT", "Document", doc.id, `Soft deleted: ${doc.title}`, user.id);

    return NextResponse.json({ success: true });
  } catch (err: unknown) {
    console.error("Document delete error:", err);
    return NextResponse.json({ error: "Failed to delete document." }, { status: 500 });
  }
}
