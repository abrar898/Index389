import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";

export async function GET(req: NextRequest) {
  try {
    const user = await getCurrentUser();
    if (!user) {
      return NextResponse.json({ favorites: [] }, { status: 200 });
    }

    const favorites = await prisma.favorite.findMany({
      where: { userId: user.id },
      select: { documentId: true },
    });

    return NextResponse.json({ favorites: favorites.map((f) => f.documentId) });
  } catch (error) {
    console.error("GET /api/favorites error:", error);
    return NextResponse.json({ error: "Failed to fetch favorites" }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    const user = await getCurrentUser();
    if (!user) {
      return NextResponse.json(
        { error: "Authentication required to bookmark notes" },
        { status: 401 }
      );
    }

    const body = await req.json();
    const { documentId } = body;

    if (!documentId) {
      return NextResponse.json(
        { error: "documentId is required" },
        { status: 400 }
      );
    }

    // Check if document exists
    const doc = await prisma.document.findUnique({
      where: { id: documentId },
      select: { id: true, title: true },
    });

    if (!doc) {
      return NextResponse.json(
        { error: "Document not found" },
        { status: 404 }
      );
    }

    // Check existing favorite
    const existing = await prisma.favorite.findUnique({
      where: {
        userId_documentId: {
          userId: user.id,
          documentId,
        },
      },
    });

    if (existing) {
      // Remove favorite
      await prisma.favorite.delete({
        where: { id: existing.id },
      });

      return NextResponse.json({
        favorited: false,
        message: `Removed "${doc.title}" from favorites`,
      });
    } else {
      // Add favorite
      await prisma.favorite.create({
        data: {
          userId: user.id,
          documentId,
        },
      });

      // Audit log entry
      try {
        await prisma.auditLog.create({
          data: {
            userId: user.id,
            action: "FAVORITE_ADD",
            entity: "DOCUMENT",
            entityId: documentId,
            details: `Bookmarked "${doc.title}"`,
          },
        });
      } catch {
        // non-blocking audit log
      }

      return NextResponse.json({
        favorited: true,
        message: `Saved "${doc.title}" to favorites`,
      });
    }
  } catch (error) {
    console.error("POST /api/favorites error:", error);
    return NextResponse.json({ error: "Failed to update favorite" }, { status: 500 });
  }
}
