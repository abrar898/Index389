import { getCurrentUser } from "@/lib/auth";
import prisma from "@/lib/db";
import { NoteEditor } from "@/components/editor/NoteEditor";
import { redirect } from "next/navigation";

export default async function NewNotePage() {
  const user = await getCurrentUser();
  if (!user || user.role !== "ADMIN") {
    redirect("/dashboard");
  }

  const categories = await prisma.category.findMany({
    orderBy: { name: "asc" },
    select: { id: true, name: true },
  });

  return <NoteEditor categories={categories} />;
}
