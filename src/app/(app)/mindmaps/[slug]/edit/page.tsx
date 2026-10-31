import React from "react";
import { notFound, redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { getMindmapBySlug } from "@/lib/mindmaps";
import { MindmapEditor } from "@/components/mindmaps/MindmapEditor";

export default async function EditMindmapPage(props: {
  params: Promise<{ slug: string }>;
}) {
  const user = await getCurrentUser();
  if (!user) {
    redirect("/login");
  }

  const { slug } = await props.params;
  const mindmap = await getMindmapBySlug(slug);

  if (!mindmap) {
    notFound();
  }

  return <MindmapEditor initialMindmap={mindmap} />;
}
