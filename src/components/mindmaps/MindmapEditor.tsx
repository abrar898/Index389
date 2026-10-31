"use client";

import React, { useState, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import {
  Save,
  Code,
  Eye,
  Columns,
  Upload,
  ArrowLeft,
  Sparkles,
  Check,
  AlertCircle,
  FileCode,
  Layers,
  RefreshCw,
  Terminal,
  Download,
} from "lucide-react";
import { MindmapItem, MINDMAP_TEMPLATES, generateSlug } from "@/lib/mindmaps-shared";

interface MindmapEditorProps {
  initialMindmap?: MindmapItem;
}

export function MindmapEditor({ initialMindmap }: MindmapEditorProps) {
  const router = useRouter();

  const [title, setTitle] = useState(initialMindmap?.title || "");
  const [slug, setSlug] = useState(initialMindmap?.slug || "");
  const [description, setDescription] = useState(
    initialMindmap?.description ||
      "Interactive security mindmap with customizable commands, phases, and nodes."
  );
  const [category, setCategory] = useState(initialMindmap?.category || "Certifications & Exams");
  const [tagsInput, setTagsInput] = useState(
    initialMindmap?.tags?.join(", ") || "mindmap, pentest, cheatsheet"
  );
  const [htmlContent, setHtmlContent] = useState(
    initialMindmap?.htmlContent || MINDMAP_TEMPLATES[0].html
  );

  const [viewMode, setViewMode] = useState<"split" | "code" | "preview">("split");
  const [isSaving, setIsSaving] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");
  const [previewKey, setPreviewKey] = useState(1);

  const fileInputRef = useRef<HTMLInputElement>(null);

  // Default to split mode on larger screens
  useEffect(() => {
    if (typeof window !== "undefined" && window.innerWidth < 1024) {
      setViewMode("code");
    }
  }, []);

  const handleTitleChange = (val: string) => {
    setTitle(val);
    if (!initialMindmap) {
      setSlug(generateSlug(val));
    }
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      const content = event.target?.result as string;
      if (content) {
        setHtmlContent(content);

        // Try extracting title from <title> tag if current title is empty
        const titleMatch = content.match(/<title>([^<]+)<\/title>/i);
        if (titleMatch && titleMatch[1] && !title) {
          handleTitleChange(titleMatch[1].trim());
        } else if (!title) {
          handleTitleChange(file.name.replace(/\.html?$/i, ""));
        }

        setPreviewKey((k) => k + 1);
        setSuccessMessage(`Loaded "${file.name}" into editor!`);
        setTimeout(() => setSuccessMessage(""), 3000);
      }
    };
    reader.readAsText(file);
  };

  const loadTemplate = (templateHtml: string, templateName: string) => {
    if (
      htmlContent.trim() &&
      htmlContent !== MINDMAP_TEMPLATES[0].html &&
      !confirm("Replace current editor code with template?")
    ) {
      return;
    }
    setHtmlContent(templateHtml);
    if (!title) {
      handleTitleChange(templateName);
    }
    setPreviewKey((k) => k + 1);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    // Support Tab indent inside code textarea
    if (e.key === "Tab") {
      e.preventDefault();
      const target = e.target as HTMLTextAreaElement;
      const start = target.selectionStart;
      const end = target.selectionEnd;

      const updated = htmlContent.substring(0, start) + "  " + htmlContent.substring(end);
      setHtmlContent(updated);

      setTimeout(() => {
        target.selectionStart = target.selectionEnd = start + 2;
      }, 0);
    }
  };

  const handleSave = async () => {
    if (!title.trim()) {
      setErrorMessage("Please enter a title for this mindmap.");
      return;
    }
    if (!htmlContent.trim()) {
      setErrorMessage("HTML content cannot be empty.");
      return;
    }

    setIsSaving(true);
    setErrorMessage("");

    const tags = tagsInput
      .split(",")
      .map((t) => t.trim())
      .filter(Boolean);

    try {
      const endpoint = initialMindmap
        ? `/api/mindmaps/${initialMindmap.slug}`
        : "/api/mindmaps";
      const method = initialMindmap ? "PUT" : "POST";

      const res = await fetch(endpoint, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          title,
          slug: slug || generateSlug(title),
          description,
          category,
          tags,
          htmlContent,
        }),
      });

      const data = await res.json();

      if (!res.ok) {
        setErrorMessage(data.error || "Failed to save mindmap.");
        setIsSaving(false);
        return;
      }

      setSuccessMessage("Mindmap saved successfully! Redirecting...");
      setTimeout(() => {
        router.push(`/mindmaps/${data.mindmap.slug}`);
      }, 800);
    } catch (err: unknown) {
      setErrorMessage(err instanceof Error ? err.message : "Failed to connect to server.");
      setIsSaving(false);
    }
  };

  return (
    <div className="flex flex-col h-[calc(100vh-5rem)] space-y-4">
      {/* Top Header Bar */}
      <div className="flex flex-wrap items-center justify-between gap-4 p-4 rounded-2xl glass-panel border-[#1f3352] flex-shrink-0">
        <div className="flex items-center gap-3">
          <button
            onClick={() => router.back()}
            className="p-2 rounded-xl border border-[#1f3352] bg-[#111d30] hover:bg-[#14233c] text-[#8ba0c3] hover:text-[#ffffff] transition-colors"
            title="Go back"
          >
            <ArrowLeft className="w-4 h-4" />
          </button>
          <div>
            <div className="flex items-center gap-2 font-mono text-[11px] text-[#9fef00]">
              <FileCode className="w-3.5 h-3.5" />
              <span>{initialMindmap ? "MINDMAP CODE STUDIO // EDIT" : "MINDMAP ENGINE // NEW CANVAS"}</span>
            </div>
            <h1 className="text-xl font-bold text-[#ffffff]">
              {initialMindmap ? `Editing: ${initialMindmap.title}` : "Create Interactive Mindmap"}
            </h1>
          </div>
        </div>

        {/* View mode switcher & Save action */}
        <div className="flex items-center gap-2">
          {/* File Upload Trigger */}
          <input
            ref={fileInputRef}
            type="file"
            accept=".html,.htm"
            onChange={handleFileUpload}
            className="hidden"
          />
          <button
            type="button"
            onClick={() => fileInputRef.current?.click()}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-[#1f3352] bg-[#111d30] hover:bg-[#14233c] text-xs font-medium text-[#8ba0c3] hover:text-[#ffffff] transition-all"
            title="Upload an existing HTML mindmap file"
          >
            <Upload className="w-3.5 h-3.5 text-[#2de2e6]" />
            <span className="hidden sm:inline">Import HTML File</span>
          </button>

          {/* View Mode Toggle */}
          <div className="hidden sm:flex items-center bg-[#111d30] border border-[#1f3352] rounded-xl p-1">
            <button
              onClick={() => setViewMode("code")}
              className={`flex items-center gap-1.5 px-3 py-1 rounded-lg text-xs font-medium transition-all ${
                viewMode === "code"
                  ? "bg-[#9fef00] text-[#0b121e] font-bold shadow-sm"
                  : "text-[#8ba0c3] hover:text-[#ffffff]"
              }`}
            >
              <Code className="w-3.5 h-3.5" />
              <span>HTML Code</span>
            </button>
            <button
              onClick={() => {
                setViewMode("split");
                setPreviewKey((k) => k + 1);
              }}
              className={`flex items-center gap-1.5 px-3 py-1 rounded-lg text-xs font-medium transition-all ${
                viewMode === "split"
                  ? "bg-[#9fef00] text-[#0b121e] font-bold shadow-sm"
                  : "text-[#8ba0c3] hover:text-[#ffffff]"
              }`}
            >
              <Columns className="w-3.5 h-3.5" />
              <span>Split Studio</span>
            </button>
            <button
              onClick={() => {
                setViewMode("preview");
                setPreviewKey((k) => k + 1);
              }}
              className={`flex items-center gap-1.5 px-3 py-1 rounded-lg text-xs font-medium transition-all ${
                viewMode === "preview"
                  ? "bg-[#9fef00] text-[#0b121e] font-bold shadow-sm"
                  : "text-[#8ba0c3] hover:text-[#ffffff]"
              }`}
            >
              <Eye className="w-3.5 h-3.5" />
              <span>Live Preview</span>
            </button>
          </div>

          {/* Save Button */}
          <button
            onClick={handleSave}
            disabled={isSaving}
            className="flex items-center gap-2 px-5 py-2 rounded-xl bg-[#9fef00] hover:bg-[#b4fa1f] text-xs font-bold text-[#0b121e] transition-all shadow-lg shadow-[#9fef00]/20 disabled:opacity-50 active:scale-95"
          >
            {isSaving ? <RefreshCw className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
            <span>{isSaving ? "Publishing..." : "Save & Launch"}</span>
          </button>
        </div>
      </div>

      {/* Status Banners */}
      {errorMessage && (
        <div className="p-3 rounded-xl bg-[#ff3366]/10 border border-[#ff3366]/30 text-[#ff3366] text-xs flex items-center gap-2 flex-shrink-0">
          <AlertCircle className="w-4 h-4 flex-shrink-0" />
          <span>{errorMessage}</span>
        </div>
      )}
      {successMessage && (
        <div className="p-3 rounded-xl bg-[#9fef00]/10 border border-[#9fef00]/30 text-[#9fef00] text-xs flex items-center gap-2 flex-shrink-0">
          <Check className="w-4 h-4 flex-shrink-0" />
          <span>{successMessage}</span>
        </div>
      )}

      {/* Metadata Configuration Bar */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3 p-4 rounded-2xl glass-panel border-[#1f3352] flex-shrink-0">
        <div className="lg:col-span-2 space-y-1">
          <label className="text-[11px] font-mono text-[#8ba0c3]">MINDMAP TITLE</label>
          <input
            type="text"
            value={title}
            onChange={(e) => handleTitleChange(e.target.value)}
            placeholder="e.g. Active Directory Penetration Testing Mindmap"
            className="w-full bg-[#111d30] border border-[#1f3352] focus:border-[#9fef00] text-[#ffffff] px-3 py-1.5 rounded-lg text-xs outline-none transition-colors"
          />
        </div>

        <div className="space-y-1">
          <label className="text-[11px] font-mono text-[#8ba0c3]">URL SLUG</label>
          <input
            type="text"
            value={slug}
            onChange={(e) => setSlug(e.target.value)}
            placeholder="ad-pentest-mindmap"
            className="w-full bg-[#111d30] border border-[#1f3352] focus:border-[#9fef00] text-[#9fef00] font-mono px-3 py-1.5 rounded-lg text-xs outline-none transition-colors"
          />
        </div>

        <div className="space-y-1">
          <label className="text-[11px] font-mono text-[#8ba0c3]">CATEGORY</label>
          <input
            type="text"
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            placeholder="e.g. Certifications & Exams"
            className="w-full bg-[#111d30] border border-[#1f3352] focus:border-[#9fef00] text-[#ffffff] px-3 py-1.5 rounded-lg text-xs outline-none transition-colors"
          />
        </div>

        <div className="space-y-1">
          <label className="text-[11px] font-mono text-[#8ba0c3]">TAGS (COMMA SEPARATED)</label>
          <input
            type="text"
            value={tagsInput}
            onChange={(e) => setTagsInput(e.target.value)}
            placeholder="cpts, web, privesc"
            className="w-full bg-[#111d30] border border-[#1f3352] focus:border-[#9fef00] text-[#ffffff] px-3 py-1.5 rounded-lg text-xs outline-none transition-colors"
          />
        </div>
      </div>

      {/* Templates Selector Drawer */}
      <div className="flex items-center gap-2 overflow-x-auto py-1 px-1 flex-shrink-0">
        <span className="text-[11px] font-mono text-[#6c7d9c] flex items-center gap-1 flex-shrink-0">
          <Sparkles className="w-3.5 h-3.5 text-[#9fef00]" /> STARTER TEMPLATES:
        </span>
        {MINDMAP_TEMPLATES.map((tmpl) => (
          <button
            key={tmpl.id}
            type="button"
            onClick={() => loadTemplate(tmpl.html, tmpl.name)}
            className="px-2.5 py-1 rounded-lg text-[11px] font-mono bg-[#111d30] hover:bg-[#14233c] text-[#8ba0c3] hover:text-[#9fef00] border border-[#1f3352] transition-colors whitespace-nowrap"
          >
            {tmpl.name}
          </button>
        ))}
      </div>

      {/* Editor & Preview Workspace Container */}
      <div className="flex-1 grid grid-cols-1 lg:grid-cols-2 gap-4 min-h-0">
        {/* Code View Column */}
        {(viewMode === "code" || viewMode === "split") && (
          <div
            className={`flex flex-col rounded-2xl border border-[#1f3352] bg-[#0b121e] overflow-hidden shadow-xl ${
              viewMode === "code" ? "lg:col-span-2" : ""
            }`}
          >
            <div className="flex items-center justify-between px-4 py-2 bg-[#111d30] border-b border-[#1f3352] flex-shrink-0 text-xs font-mono">
              <span className="text-[#9fef00] flex items-center gap-1.5">
                <Code className="w-3.5 h-3.5" /> HTML CODE (FULL JAVASCRIPT & STYLES)
              </span>
              <div className="flex items-center gap-3 text-[#6c7d9c]">
                <span>{htmlContent.length} chars</span>
                <span>{htmlContent.split("\n").length} lines</span>
              </div>
            </div>

            <textarea
              value={htmlContent}
              onChange={(e) => setHtmlContent(e.target.value)}
              onKeyDown={handleKeyDown}
              spellCheck={false}
              placeholder="Paste or write your <!DOCTYPE html> code here..."
              className="flex-1 w-full p-4 bg-[#070b13] text-[#e2e8f0] font-mono text-xs leading-relaxed outline-none resize-none overflow-y-auto selection:bg-[#9fef00]/30 selection:text-[#ffffff]"
            />
          </div>
        )}

        {/* Live Preview View Column */}
        {(viewMode === "preview" || viewMode === "split") && (
          <div
            className={`flex flex-col rounded-2xl border border-[#1f3352] bg-[#000000] overflow-hidden shadow-xl ${
              viewMode === "preview" ? "lg:col-span-2" : ""
            }`}
          >
            <div className="flex items-center justify-between px-4 py-2 bg-[#111d30] border-b border-[#1f3352] flex-shrink-0 text-xs font-mono">
              <span className="text-[#2de2e6] flex items-center gap-1.5">
                <Eye className="w-3.5 h-3.5" /> LIVE INTERACTIVE PREVIEW
              </span>
              <button
                type="button"
                onClick={() => setPreviewKey((k) => k + 1)}
                className="flex items-center gap-1 text-[11px] text-[#8ba0c3] hover:text-[#ffffff] transition-colors"
                title="Reload preview iframe"
              >
                <RefreshCw className="w-3 h-3" /> Reload Preview
              </button>
            </div>

            <div className="flex-1 w-full h-full relative bg-[#000000]">
              <iframe
                key={previewKey}
                srcDoc={htmlContent}
                className="w-full h-full border-none outline-none block"
                title="Mindmap Live Preview"
                sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-modals"
              />
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
