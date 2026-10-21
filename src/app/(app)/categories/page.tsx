import Link from "next/link";
import prisma from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { Folder, FileText, ArrowRight } from "lucide-react";
import { CreateCategoryModal } from "@/components/categories/CreateCategoryModal";

export default async function CategoriesPage() {
  const user = await getCurrentUser();
  const categories = await prisma.category.findMany({
    include: {
      _count: {
        select: { documents: { where: { deletedAt: null } } },
      },
    },
    orderBy: { name: "asc" },
  });

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4 p-6 rounded-2xl glass-panel border-[#1f3352]">
        <div className="space-y-1">
          <div className="flex items-center gap-2 font-mono text-xs text-[#9fef00]">
            <Folder className="w-4 h-4" />
            <span>TAXONOMY & ARCHITECTURE</span>
          </div>
          <h1 className="text-2xl font-bold text-[#ffffff]">Knowledge Domains & Categories</h1>
          <p className="text-xs text-[#a4b1cd]">
            Structured domains grouping penetration testing techniques, enumeration, and exploitation guides.
          </p>
        </div>

        {/* Modal button to create custom categories (Admin Only) */}
        {user?.role === "ADMIN" && (
          <CreateCategoryModal
            triggerButtonText="Create Category"
            triggerButtonClassName="flex items-center gap-2 px-4 py-2 rounded-xl bg-[#9fef00] hover:bg-[#b4fa1f] text-xs font-bold text-[#0b121e] transition-all shadow-md active:scale-95"
          />
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {categories.map((cat) => (
          <Link
            key={cat.id}
            href={`/notes?category=${cat.slug}`}
            className="group p-5 rounded-2xl glass-panel glass-panel-hover border-[#1f3352] hover:border-[#9fef00] transition-all flex flex-col justify-between"
          >
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="font-mono text-xs font-bold text-[#9fef00] flex items-center gap-2">
                  <span
                    className="w-2.5 h-2.5 rounded-full inline-block"
                    style={{ backgroundColor: cat.color || "#9fef00" }}
                  />
                  {cat.name}
                </span>
                <span className="text-xs font-mono px-2 py-0.5 rounded bg-[#111d30] border border-[#1f3352] text-[#8ba0c3]">
                  {cat._count.documents} notes
                </span>
              </div>
              <p className="text-xs text-[#a4b1cd] leading-relaxed">
                {cat.description || "Collection of operational technical documentation."}
              </p>
            </div>

            <div className="pt-4 mt-4 border-t border-[#1f3352] flex items-center justify-between text-xs text-[#9fef00] font-mono group-hover:underline">
              <span>Explore category</span>
              <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
