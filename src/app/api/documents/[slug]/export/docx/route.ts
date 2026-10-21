import { NextResponse } from "next/server";
import prisma from "@/lib/db";
import { generateDocxBuffer } from "@/lib/docx";

export async function GET(req: Request, props: { params: Promise<{ slug: string }> }) {
  try {
    const params = await props.params;
    const doc = await prisma.document.findUnique({
      where: { slug: params.slug },
    });

    if (!doc || doc.deletedAt) {
      return NextResponse.json({ error: "Document not found" }, { status: 404 });
    }

    const docxBuffer = await generateDocxBuffer(
      doc.title,
      doc.description || "",
      doc.contentMarkdown
    );

    const safeFilename = `${doc.slug || "document"}.docx`;

    return new NextResponse(docxBuffer as unknown as BodyInit, {
      status: 200,
      headers: {
        "Content-Type": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "Content-Disposition": `attachment; filename="${safeFilename}"`,
      },
    });
  } catch (err: unknown) {
    console.error("DOCX generation error:", err);
    return NextResponse.json({ error: "Failed to generate DOCX document." }, { status: 500 });
  }
}
