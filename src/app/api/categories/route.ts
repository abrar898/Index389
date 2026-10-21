import { NextResponse } from "next/server";
import prisma from "@/lib/db";
import { getCurrentUser, logAudit } from "@/lib/auth";

export async function GET() {
  try {
    const categories = await prisma.category.findMany({
      include: {
        _count: {
          select: { documents: { where: { deletedAt: null } } },
        },
      },
      orderBy: { name: "asc" },
    });
    return NextResponse.json(categories);
  } catch (err: unknown) {
    console.error("Fetch categories error:", err);
    return NextResponse.json({ error: "Failed to fetch categories." }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const user = await getCurrentUser();
    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    // Role check: Strictly ADMIN can create new categories
    if (user.role !== "ADMIN") {
      return NextResponse.json(
        { error: "Forbidden: Only administrators can create categories." },
        { status: 403 }
      );
    }

    const body = await req.json();
    const { name, slug, description, color } = body;

    if (!name || typeof name !== "string" || !name.trim()) {
      return NextResponse.json({ error: "Category name is required." }, { status: 400 });
    }

    // Generate or clean slug
    let finalSlug = (slug || name)
      .toLowerCase()
      .trim()
      .replace(/[^\w\s-]/g, "")
      .replace(/[\s_-]+/g, "-")
      .replace(/^-+|-+$/g, "");

    if (!finalSlug) {
      finalSlug = `category-${Date.now()}`;
    }

    // Check for duplicate name or slug
    const existing = await prisma.category.findFirst({
      where: {
        OR: [{ name: name.trim() }, { slug: finalSlug }],
      },
    });

    if (existing) {
      return NextResponse.json(
        { error: "A category with this name or slug already exists." },
        { status: 409 }
      );
    }

    const category = await prisma.category.create({
      data: {
        name: name.trim(),
        slug: finalSlug,
        description: description?.trim() || null,
        color: color || "#9fef00",
      },
    });

    await logAudit(
      "CREATE_CATEGORY",
      "Category",
      category.id,
      `Created category: ${category.name} (${category.slug})`,
      user.id
    );

    return NextResponse.json(category, { status: 201 });
  } catch (err: unknown) {
    console.error("Create category error:", err);
    return NextResponse.json({ error: "Failed to create category." }, { status: 500 });
  }
}
