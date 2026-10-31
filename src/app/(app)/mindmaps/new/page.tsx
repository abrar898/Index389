import React from "react";
import { getCurrentUser } from "@/lib/auth";
import { redirect } from "next/navigation";
import { MindmapEditor } from "@/components/mindmaps/MindmapEditor";

export default async function NewMindmapPage() {
  const user = await getCurrentUser();
  if (!user) {
    redirect("/login");
  }

  return <MindmapEditor />;
}
