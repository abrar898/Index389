import { NextResponse } from "next/server";
import { getMindmapBySlug } from "@/lib/mindmaps";

export async function GET(
  req: Request,
  { params }: { params: Promise<{ slug: string }> }
) {
  try {
    const { slug } = await params;
    const mindmap = await getMindmapBySlug(slug);

    if (!mindmap || !mindmap.htmlContent) {
      return new NextResponse("Mindmap not found", { status: 404 });
    }

    return new NextResponse(mindmap.htmlContent, {
      status: 200,
      headers: {
        "Content-Type": "text/html; charset=utf-8",
        "Cache-Control": "public, max-age=60",
      },
    });
  } catch (error) {
    console.error("Failed to render raw mindmap:", error);
    return new NextResponse("Failed to load mindmap", { status: 500 });
  }
}
