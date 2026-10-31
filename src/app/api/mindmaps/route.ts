import { NextResponse } from "next/server";
import { getCurrentUser } from "@/lib/auth";
import { getAllMindmaps, saveMindmap } from "@/lib/mindmaps";

export async function GET() {
  try {
    const mindmaps = await getAllMindmaps();
    return NextResponse.json({ mindmaps });
  } catch (error) {
    console.error("Failed to fetch mindmaps:", error);
    return NextResponse.json({ error: "Failed to load mindmaps" }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const user = await getCurrentUser();
    // Allow admins and authors to create mindmaps
    if (!user) {
      return NextResponse.json({ error: "Unauthorized. Please sign in." }, { status: 401 });
    }

    const body = await req.json();
    const { title, slug, description, category, tags, htmlContent } = body;

    if (!title || !title.trim()) {
      return NextResponse.json({ error: "Mindmap title is required." }, { status: 400 });
    }

    if (!htmlContent || !htmlContent.trim()) {
      return NextResponse.json({ error: "HTML content is required for the mindmap." }, { status: 400 });
    }

    const saved = await saveMindmap({
      title,
      slug,
      description,
      category,
      tags: Array.isArray(tags) ? tags : typeof tags === "string" ? tags.split(",").map((t: string) => t.trim()).filter(Boolean) : [],
      htmlContent,
    });

    return NextResponse.json({ success: true, mindmap: saved }, { status: 201 });
  } catch (error: unknown) {
    console.error("Failed to create mindmap:", error);
    const msg = error instanceof Error ? error.message : "Internal server error";
    return NextResponse.json({ error: msg }, { status: 500 });
  }
}
