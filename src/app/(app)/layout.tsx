import React from "react";
import { AppShell } from "@/components/layout/AppShell";
import { getCurrentUser } from "@/lib/auth";
import prisma from "@/lib/db";

export default async function AppLayout({ children }: { children: React.ReactNode }) {
  const user = await getCurrentUser();

  const [categories, tags] = await Promise.all([
    prisma.category.findMany({
      include: {
        _count: {
          select: { documents: true },
        },
      },
      orderBy: { name: "asc" },
    }),
    prisma.tag.findMany({
      take: 15,
      orderBy: { name: "asc" },
    }),
  ]);

  return (
    <AppShell user={user} categories={categories} tags={tags}>
      {children}
    </AppShell>
  );
}
