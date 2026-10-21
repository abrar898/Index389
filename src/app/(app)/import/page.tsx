import prisma from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { ImportCenter } from "@/components/import/ImportCenter";
import { redirect } from "next/navigation";

export default async function ImportPage() {
  const user = await getCurrentUser();
  if (!user || user.role !== "ADMIN") {
    redirect("/dashboard");
  }

  const categories = await prisma.category.findMany({
    orderBy: { name: "asc" },
    select: { id: true, name: true },
  });

  return <ImportCenter categories={categories} />;
}
