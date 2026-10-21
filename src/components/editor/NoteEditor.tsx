"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { MarkdownRenderer } from "@/components/markdown/MarkdownRenderer";
import { parseMarkdownFile } from "@/lib/markdown";
import {
  Save,
  Eye,
  Columns,
  Code,
  ArrowLeft,
  Check,
  AlertCircle,
  FileText,
  Heading,
  Terminal,
  Table as TableIcon,
  Quote,
  List,
} from "lucide-react";
import { CreateCategoryModal } from "@/components/categories/CreateCategoryModal";

interface NoteEditorProps {
  initialDocument?: {
    id: string;
    title: string;
    slug: string;
    description: string | null;
    contentMarkdown: string;
    status: string;
    categoryId: string | null;
    tags: string[];
  };
  categories: { id: string; name: string }[];
}

export function NoteEditor({ initialDocument, categories }: NoteEditorProps) {
  const router = useRouter();

  const [title, setTitle] = useState(initialDocument?.title || "");
  const [slug, setSlug] = useState(initialDocument?.slug || "");
  const [description, setDescription] = useState(initialDocument?.description || "");
  const [contentMarkdown, setContentMarkdown] = useState(
    initialDocument?.contentMarkdown ||
      `# New Technical Note\n\n## Overview\n\nDocument your cybersecurity findings, commands, and proof of concept below.\n\n\`\`\`bash\n# Run reconnaissance\nnmap -sV -sC target.local\n\`\`\`\n\n> **Note:** Only test systems you own or have explicit written permission to assess.\n`
  );
  const [categoryId, setCategoryId] = useState(initialDocument?.categoryId || "");
  const [categoryList, setCategoryList] = useState(categories);
  const [tagsInput, setTagsInput] = useState(initialDocument?.tags?.join(", ") || "linux, recon");
  const [status, setStatus] = useState(initialDocument?.status || "PUBLISHED");

  const [viewMode, setViewMode] = useState<"split" | "edit" | "preview">("edit");
  const [isSaving, setIsSaving] = useState(false);
  const [saveSuccess, setSaveSuccess] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  // Default to split mode on larger desktop screens once mounted
  useEffect(() => {
    if (typeof window !== "undefined" && window.innerWidth >= 1024) {
      setViewMode("split");
    }
  }, []);

  // Autosave title & slug generator
  const handleTitleChange = (val: string) => {
    setTitle(val);
    if (!initialDocument) {
      setSlug(
        val
          .toLowerCase()
          .trim()
          .replace(/[^\w\s-]/g, "")
          .replace(/\s+/g, "-")
      );
    }
  };

  const insertSnippet = (snippet: string) => {
    setContentMarkdown((prev) => prev + "\n" + snippet);
  };

  const handleSave = async () => {
    if (!title.trim()) {
      setErrorMessage("Please enter a document title.");
      return;
    }
    if (!slug.trim()) {
      setErrorMessage("Please enter a unique URL slug.");
      return;
    }

    setIsSaving(true);
    setErrorMessage("");

    try {
      const res = await fetch(
        initialDocument ? `/api/documents/${initialDocument.id}` : "/api/documents",
        {
          method: initialDocument ? "PUT" : "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            title,
            slug,
            description,
            contentMarkdown,
            categoryId: categoryId || null,
            tags: tagsInput.split(",").map((t) => t.trim()).filter(Boolean),
            status,
          }),
        }
      );

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || "Failed to save document.");
      }

      setSaveSuccess(true);
      setTimeout(() => setSaveSuccess(false), 2500);

      if (!initialDocument) {
        router.push(`/notes/${data.slug}`);
      } else {
        router.refresh();
      }
    } catch (err: unknown) {
      if (err instanceof Error) {
        setErrorMessage(err.message);
      } else {
        setErrorMessage("An unknown error occurred.");
      }
    } finally {
      setIsSaving(false);
    }
  };

  const parsed = parseMarkdownFile(contentMarkdown);

  return (
    <div className="space-y-4">
      {/* Top Action Bar */}
      <div className="flex flex-wrap items-center justify-between gap-4 p-4 rounded-xl border border-[#1f3352] glass-panel">
        <div className="flex items-center gap-3">
          <button
            onClick={() => router.back()}
            className="p-1.5 rounded-lg bg-[#14233c] hover:bg-[#182844] border border-[#1f3352] text-[#8ba0c3] hover:text-[#ffffff] transition-colors"
            title="Go back"
          >
            <ArrowLeft className="w-4 h-4" />
          </button>
          <div>
            <h1 className="text-base font-bold text-[#ffffff]">
              {initialDocument ? `Editing: ${initialDocument.title}` : "Create Technical Note"}
            </h1>
            <p className="text-xs font-mono text-[#6c7d9c]">/notes/{slug || "slug-preview"}</p>
          </div>
        </div>

        {/* View mode toggle & Save buttons */}
        <div className="flex items-center gap-2">
          <div className="flex items-center bg-[#111d30] p-1 rounded-lg border border-[#1f3352]">
            <button
              onClick={() => setViewMode("edit")}
              className={`p-1.5 rounded text-xs transition-colors flex items-center gap-1 ${
                viewMode === "edit"
                  ? "bg-[#9fef00]/15 text-[#9fef00] font-semibold"
                  : "text-[#8ba0c3] hover:text-[#ffffff]"
              }`}
              title="Markdown Mode"
            >
              <Code className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Editor</span>
            </button>
            <button
              onClick={() => setViewMode("split")}
              className={`p-1.5 rounded text-xs transition-colors flex items-center gap-1 ${
                viewMode === "split"
                  ? "bg-[#9fef00]/15 text-[#9fef00] font-semibold"
                  : "text-[#8ba0c3] hover:text-[#ffffff]"
              }`}
              title="Split Mode"
            >
              <Columns className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Split</span>
            </button>
            <button
              onClick={() => setViewMode("preview")}
              className={`p-1.5 rounded text-xs transition-colors flex items-center gap-1 ${
                viewMode === "preview"
                  ? "bg-[#9fef00]/15 text-[#9fef00] font-semibold"
                  : "text-[#8ba0c3] hover:text-[#ffffff]"
              }`}
              title="Rendered Preview"
            >
              <Eye className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Preview</span>
            </button>
          </div>

          <button
            onClick={handleSave}
            disabled={isSaving}
            className="flex items-center gap-2 px-4 py-2 rounded-xl bg-[#9fef00] text-[#0b121e] hover:bg-[#b4fa1f] font-bold text-xs shadow-md transition-all active:scale-95 disabled:opacity-50"
          >
            {isSaving ? (
              <span>Saving...</span>
            ) : saveSuccess ? (
              <>
                <Check className="w-4 h-4" />
                <span>Saved!</span>
              </>
            ) : (
              <>
                <Save className="w-4 h-4" />
                <span>Save Note</span>
              </>
            )}
          </button>
        </div>
      </div>

      {errorMessage && (
        <div className="p-3 rounded-lg bg-[#f85149]/10 border border-[#f85149]/30 text-[#f85149] text-xs flex items-center gap-2">
          <AlertCircle className="w-4 h-4 flex-shrink-0" />
          <span>{errorMessage}</span>
        </div>
      )}

      {/* Metadata Configuration */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-3 p-4 rounded-2xl border border-[#1f3352] glass-panel">
        <div className="space-y-1">
          <label className="text-xs font-mono text-[#8ba0c3]">Note Title</label>
          <input
            type="text"
            value={title}
            onChange={(e) => handleTitleChange(e.target.value)}
            placeholder="e.g. Linux Privilege Escalation via SUID"
            className="w-full px-3 py-1.5 rounded-lg bg-[#111d30] border border-[#1f3352] text-xs text-[#ffffff] focus:border-[#9fef00] focus:outline-none"
          />
        </div>

        <div className="space-y-1">
          <label className="text-xs font-mono text-[#8ba0c3]">URL Slug</label>
          <input
            type="text"
            value={slug}
            onChange={(e) => setSlug(e.target.value)}
            placeholder="e.g. linux-privesc-suid"
            className="w-full px-3 py-1.5 rounded-lg bg-[#111d30] border border-[#1f3352] text-xs text-[#ffffff] font-mono focus:border-[#9fef00] focus:outline-none"
          />
        </div>

        <div className="space-y-1">
          <div className="flex items-center justify-between">
            <label className="text-xs font-mono text-[#8ba0c3]">Category</label>
            <CreateCategoryModal
              triggerButtonText="+ New"
              triggerButtonClassName="text-[10px] font-mono text-[#9fef00] hover:underline"
              onCategoryCreated={(newCat) => {
                setCategoryList((prev) => [...prev, newCat]);
                setCategoryId(newCat.id);
              }}
            />
          </div>
          <select
            value={categoryId}
            onChange={(e) => setCategoryId(e.target.value)}
            className="w-full px-3 py-1.5 rounded-lg bg-[#111d30] border border-[#1f3352] text-xs text-[#ffffff] focus:border-[#9fef00] focus:outline-none"
          >
            <option value="">Select Category...</option>
            {categoryList.map((cat) => (
              <option key={cat.id} value={cat.id}>
                {cat.name}
              </option>
            ))}
          </select>
        </div>

        <div className="space-y-1 md:col-span-2">
          <label className="text-xs font-mono text-[#8ba0c3]">Description</label>
          <input
            type="text"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Brief technical summary..."
            className="w-full px-3 py-1.5 rounded-lg bg-[#111d30] border border-[#1f3352] text-xs text-[#ffffff] focus:border-[#9fef00] focus:outline-none"
          />
        </div>

        <div className="space-y-1">
          <label className="text-xs font-mono text-[#8ba0c3]">Tags (comma separated)</label>
          <input
            type="text"
            value={tagsInput}
            onChange={(e) => setTagsInput(e.target.value)}
            placeholder="linux, privesc, cve"
            className="w-full px-3 py-1.5 rounded-lg bg-[#111d30] border border-[#1f3352] text-xs text-[#ffffff] font-mono focus:border-[#9fef00] focus:outline-none"
          />
        </div>
      </div>

      {/* Editor Snippet Toolbar */}
      <div className="flex flex-wrap items-center gap-1.5 p-2 rounded-xl bg-[#14233c] border border-[#1f3352] text-xs">
        <span className="text-[10px] font-mono text-[#6c7d9c] uppercase px-2 font-bold">Snippets:</span>
        <button
          onClick={() => insertSnippet("```bash\n# Terminal command\nwhoami\n```")}
          className="flex items-center gap-1 px-2 py-1 rounded-lg bg-[#111d30] hover:bg-[#182844] text-[#9fef00] border border-[#1f3352] transition-colors"
        >
          <Terminal className="w-3 h-3" />
          <span>Bash Command</span>
        </button>
        <button
          onClick={() => insertSnippet("```python\n# Exploit script\nimport socket\n```")}
          className="flex items-center gap-1 px-2 py-1 rounded-lg bg-[#111d30] hover:bg-[#182844] text-[#2de2e6] border border-[#1f3352] transition-colors"
        >
          <Code className="w-3 h-3" />
          <span>Python Code</span>
        </button>
        <button
          onClick={() => insertSnippet("> **Note:** Only test systems you own or are authorized to test.")}
          className="flex items-center gap-1 px-2 py-1 rounded-lg bg-[#111d30] hover:bg-[#182844] text-[#ff8400] border border-[#1f3352] transition-colors"
        >
          <Quote className="w-3 h-3" />
          <span>Callout Note</span>
        </button>
        <button
          onClick={() => insertSnippet("| Port | Service | Vulnerability |\n| :--- | :--- | :--- |\n| 80/tcp | HTTP | Directory Traversal |")}
          className="flex items-center gap-1 px-2 py-1 rounded-lg bg-[#111d30] hover:bg-[#182844] text-[#8ba0c3] border border-[#1f3352] transition-colors"
        >
          <TableIcon className="w-3 h-3" />
          <span>Table</span>
        </button>
      </div>

      {/* Main Workspace (Split / Full Editor / Preview) */}
      <div
        className={`grid gap-4 ${
          viewMode === "split" ? "grid-cols-1 lg:grid-cols-2" : "grid-cols-1"
        }`}
      >
        {/* Editor Column */}
        {(viewMode === "split" || viewMode === "edit") && (
          <div className="flex flex-col rounded-2xl border border-[#1f3352] bg-[#070b13] overflow-hidden min-h-[550px]">
            <div className="px-4 py-2 bg-[#111d30] border-b border-[#1f3352] flex items-center justify-between text-xs text-[#8ba0c3] font-mono">
              <span>MARKDOWN SOURCE</span>
              <span>{contentMarkdown.length} chars</span>
            </div>
            <textarea
              value={contentMarkdown}
              onChange={(e) => setContentMarkdown(e.target.value)}
              className="flex-1 w-full p-4 bg-transparent text-[#ffffff] font-mono text-xs leading-relaxed resize-none focus:outline-none"
              placeholder="Write Markdown or paste notes..."
              spellCheck={false}
            />
          </div>
        )}

        {/* Live Preview Column */}
        {(viewMode === "split" || viewMode === "preview") && (
          <div className="flex flex-col rounded-2xl border border-[#1f3352] glass-panel overflow-hidden min-h-[550px]">
            <div className="px-4 py-2 bg-[#111d30] border-b border-[#1f3352] flex items-center justify-between text-xs text-[#8ba0c3] font-mono">
              <span className="text-[#9fef00] font-semibold">LIVE RENDERED PREVIEW</span>
              <span>{parsed.readingTimeMin}m read</span>
            </div>
            <div className="p-6 overflow-y-auto max-h-[750px]">
              <MarkdownRenderer content={parsed.cleanMarkdown} />
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
