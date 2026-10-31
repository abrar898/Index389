import { NextResponse } from "next/server";
import { getCurrentUser } from "@/lib/auth";
import { getMindmapBySlug, saveMindmap, deleteMindmap } from "@/lib/mindmaps";

export async function GET(
  req: Request,
  { params }: { params: Promise<{ slug: string }> }
) {
  try {
    const { slug } = await params;
    const mindmap = await getMindmapBySlug(slug);

    if (!mindmap) {
      return NextResponse.json({ error: "Mindmap not found." }, { status: 404 });
    }

    return NextResponse.json({ mindmap });
  } catch (error) {
    console.error("Failed to fetch mindmap:", error);
    return NextResponse.json({ error: "Failed to load mindmap" }, { status: 500 });
  }
}

export async function PUT(
  req: Request,
  { params }: { params: Promise<{ slug: string }> }
) {
  try {
    const user = await getCurrentUser();
    if (!user) {
      return NextResponse.json({ error: "Unauthorized." }, { status: 401 });
    }

    const { slug } = await params;
    const body = await req.json();
    const { title, description, category, tags, htmlContent } = body;

    if (!title || !title.trim()) {
      return NextResponse.json({ error: "Mindmap title is required." }, { status: 400 });
    }

    if (!htmlContent || !htmlContent.trim()) {
      return NextResponse.json({ error: "HTML content cannot be empty." }, { status: 400 });
    }

    const updated = await saveMindmap({
      slug,
      title,
      description,
      category,
      tags: Array.isArray(tags) ? tags : typeof tags === "string" ? tags.split(",").map((t: string) => t.trim()).filter(Boolean) : [],
      htmlContent,
    });

    return NextResponse.json({ success: true, mindmap: updated });
  } catch (error: unknown) {
    console.error("Failed to update mindmap:", error);
    const msg = error instanceof Error ? error.message : "Internal server error";
    return NextResponse.json({ error: msg }, { status: 500 });
  }
}

export async function DELETE(
  req: Request,
  { params }: { params: Promise<{ slug: string }> }
) {
  try {
    const user = await getCurrentUser();
    if (!user || user.role !== "ADMIN") {
      return NextResponse.json({ error: "Only administrators can delete mindmaps." }, { status: 403 });
    }

    const { slug } = await params;
    await deleteMindmap(slug);

    return NextResponse.json({ success: true });
  } catch (error: unknown) {
    console.error("Failed to delete mindmap:", error);
    const msg = error instanceof Error ? error.message : "Internal server error";
    return NextResponse.json({ error: msg }, { status: 500 });
  }
}
