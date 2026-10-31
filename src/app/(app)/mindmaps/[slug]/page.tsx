import React from "react";
import { notFound } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { getMindmapBySlug } from "@/lib/mindmaps";
import { MindmapViewer } from "@/components/mindmaps/MindmapViewer";

export const dynamic = "force-dynamic";

export default async function MindmapDetailPage(props: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await props.params;
  const user = await getCurrentUser();
  const mindmap = await getMindmapBySlug(slug);

  if (!mindmap) {
    notFound();
  }

  return <MindmapViewer mindmap={mindmap} user={user} />;
}
