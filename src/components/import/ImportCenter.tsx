"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { parseMarkdownFile } from "@/lib/markdown";
import { MarkdownRenderer } from "@/components/markdown/MarkdownRenderer";
import {
  Upload,
  FileCode,
  Archive,
  CheckCircle,
  AlertCircle,
  ArrowRight,
  Folder,
  Tag,
  Clock,
  Eye,
  RefreshCw,
} from "lucide-react";
import JSZip from "jszip";

interface ImportCenterProps {
  categories: { id: string; name: string }[];
}

interface ProcessedFile {
  filename: string;
  title: string;
  slug: string;
  description: string;
  category: string;
  tags: string[];
  markdown: string;
  readingTimeMin: number;
  status: "ready" | "imported" | "error";
  errorMessage?: string;
}

export function ImportCenter({ categories }: ImportCenterProps) {
  const router = useRouter();

  const [files, setFiles] = useState<ProcessedFile[]>([]);
  const [selectedFileIdx, setSelectedFileIdx] = useState<number>(0);
  const [isProcessing, setIsProcessing] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const [overallMessage, setOverallMessage] = useState("");

  const processTextContent = (filename: string, content: string): ProcessedFile => {
    const parsed = parseMarkdownFile(content);
    const slug = (parsed.title || filename.replace(/\.md$/, ""))
      .toLowerCase()
      .trim()
      .replace(/[^\w\s-]/g, "")
      .replace(/\s+/g, "-");

    return {
      filename,
      title: parsed.title,
      slug,
      description: parsed.description,
      category: parsed.category,
      tags: parsed.tags,
      markdown: content,
      readingTimeMin: parsed.readingTimeMin,
      status: "ready",
    };
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const uploadedFiles = e.target.files;
    if (!uploadedFiles || uploadedFiles.length === 0) return;

    setIsProcessing(true);
    setOverallMessage("");
    const processed: ProcessedFile[] = [];

    for (let i = 0; i < uploadedFiles.length; i++) {
      const file = uploadedFiles[i];

      if (file.name.endsWith(".zip")) {
        try {
          const zip = new JSZip();
          const zipData = await zip.loadAsync(file);

          for (const relativePath of Object.keys(zipData.files)) {
            const zipEntry = zipData.files[relativePath];
            if (!zipEntry.dir && relativePath.endsWith(".md")) {
              const text = await zipEntry.async("string");
              processed.push(processTextContent(relativePath, text));
            }
          }
        } catch (err) {
          console.error("ZIP extract error:", err);
        }
      } else if (file.name.endsWith(".md") || file.name.endsWith(".markdown") || file.name.endsWith(".txt")) {
        const text = await file.text();
        processed.push(processTextContent(file.name, text));
      }
    }

    setFiles((prev) => [...prev, ...processed]);
    setIsProcessing(false);
    if (processed.length > 0) {
      setOverallMessage(`Successfully processed ${processed.length} file(s). Review and publish.`);
    }
  };

  const handlePublishAll = async () => {
    if (files.length === 0) return;

    setIsUploading(true);
    let successCount = 0;

    const updatedFiles = [...files];

    for (let i = 0; i < updatedFiles.length; i++) {
      const f = updatedFiles[i];
      if (f.status === "imported") continue;

      try {
        const res = await fetch("/api/documents/import", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            title: f.title,
            slug: f.slug,
            description: f.description,
            categoryName: f.category,
            tags: f.tags,
            contentMarkdown: f.markdown,
          }),
        });

        if (!res.ok) {
          const data = await res.json();
          f.status = "error";
          f.errorMessage = data.error || "Failed to publish.";
        } else {
          f.status = "imported";
          successCount++;
        }
      } catch (err: unknown) {
        f.status = "error";
        f.errorMessage = err instanceof Error ? err.message : "Network error.";
      }
    }

    setFiles(updatedFiles);
    setIsUploading(false);
    setOverallMessage(`Published ${successCount} notes to the knowledge base!`);

    if (successCount > 0) {
      setTimeout(() => {
        router.push("/notes");
      }, 1500);
    }
  };

  const selected = files[selectedFileIdx];

  return (
    <div className="space-y-6">
      {/* Title & Introduction */}
      <div className="p-6 rounded-2xl glass-panel border-[#1f3352] space-y-2">
        <div className="flex items-center gap-2 font-mono text-xs text-[#9fef00]">
          <Upload className="w-4 h-4" />
          <span>BATCH DOCUMENTATION INGESTION ENGINE</span>
        </div>
        <h1 className="text-2xl font-bold text-[#ffffff]">Markdown Import Center</h1>
        <p className="text-sm text-[#a4b1cd] max-w-3xl leading-relaxed">
          Upload single or multiple <code className="text-[#9fef00] font-mono">.md</code> files, or a{" "}
          <code className="text-[#9fef00] font-mono">.zip</code> archive containing your technical writeups.
          Frontmatter metadata, titles, and command blocks are parsed automatically.
        </p>
      </div>

      {/* Drag & Drop Upload Zone */}
      <div className="relative border-2 border-dashed border-[#1f3352] hover:border-[#9fef00] bg-[#111d30] rounded-2xl p-8 text-center transition-all group">
        <input
          type="file"
          multiple
          accept=".md,.markdown,.txt,.zip"
          onChange={handleFileUpload}
          className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10"
        />
        <div className="flex flex-col items-center justify-center space-y-3 pointer-events-none">
          <div className="w-12 h-12 rounded-full bg-[#14233c] border border-[#1f3352] flex items-center justify-center text-[#9fef00] group-hover:scale-110 transition-transform shadow-md">
            <Upload className="w-6 h-6" />
          </div>
          <div>
            <div className="text-sm font-semibold text-[#ffffff]">
              Drag & Drop Markdown files or ZIP archives here
            </div>
            <div className="text-xs text-[#8ba0c3] mt-1 font-mono">
              Supports .md, .markdown, .zip (e.g. HTB writeup folders, Obsidian vaults)
            </div>
          </div>
        </div>
      </div>

      {overallMessage && (
        <div className="p-3.5 rounded-xl bg-[#9fef00]/10 border border-[#9fef00]/30 text-[#9fef00] text-xs flex items-center justify-between">
          <span className="flex items-center gap-2">
            <CheckCircle className="w-4 h-4" />
            {overallMessage}
          </span>
          {files.length > 0 && files.some((f) => f.status === "imported") && (
            <button
              onClick={() => router.push("/notes")}
              className="font-mono text-xs underline font-bold"
            >
              Go to Notes &rarr;
            </button>
          )}
        </div>
      )}

      {/* Imported Files Staging & Preview */}
      {files.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* File Queue List */}
          <div className="lg:col-span-1 rounded-2xl border border-[#1f3352] glass-panel overflow-hidden flex flex-col h-[600px]">
            <div className="p-3.5 bg-[#111d30] border-b border-[#1f3352] flex items-center justify-between text-xs font-mono">
              <span className="text-[#8ba0c3]">STAGED DOCUMENTS ({files.length})</span>
              <button
                onClick={handlePublishAll}
                disabled={isUploading}
                className="flex items-center gap-1.5 px-3 py-1 rounded-xl bg-[#9fef00] text-[#0b121e] font-bold text-xs hover:bg-[#b4fa1f] transition-all disabled:opacity-50"
              >
                {isUploading ? <RefreshCw className="w-3.5 h-3.5 animate-spin" /> : <CheckCircle className="w-3.5 h-3.5" />}
                <span>Publish All</span>
              </button>
            </div>

            <div className="flex-1 overflow-y-auto divide-y divide-[#1f3352]">
              {files.map((file, idx) => (
                <div
                  key={idx}
                  onClick={() => setSelectedFileIdx(idx)}
                  className={`p-3 cursor-pointer transition-colors ${
                    selectedFileIdx === idx
                      ? "bg-[#14233c] border-l-2 border-[#9fef00]"
                      : "hover:bg-[#14233c]/50"
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-semibold text-[#ffffff] truncate max-w-[180px]">
                      {file.title}
                    </span>
                    {file.status === "imported" ? (
                      <span className="text-[10px] font-mono text-[#9fef00] flex items-center gap-1">
                        <CheckCircle className="w-3 h-3" /> Published
                      </span>
                    ) : file.status === "error" ? (
                      <span className="text-[10px] font-mono text-[#ff3366] flex items-center gap-1">
                        <AlertCircle className="w-3 h-3" /> Error
                      </span>
                    ) : (
                      <span className="text-[10px] font-mono text-[#6c7d9c]">Ready</span>
                    )}
                  </div>
                  <div className="flex items-center gap-2 mt-1 text-[11px] font-mono text-[#6c7d9c]">
                    <span>{file.category}</span>
                    <span>•</span>
                    <span>{file.readingTimeMin}m read</span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Staged Document Preview */}
          <div className="lg:col-span-2 rounded-2xl border border-[#1f3352] glass-panel flex flex-col h-[600px] overflow-hidden">
            {selected ? (
              <>
                <div className="p-3.5 bg-[#111d30] border-b border-[#1f3352] flex items-center justify-between text-xs">
                  <div className="flex items-center gap-2 truncate">
                    <Eye className="w-4 h-4 text-[#9fef00]" />
                    <span className="font-semibold text-[#ffffff] truncate">{selected.title}</span>
                  </div>
                  <span className="font-mono text-[#8ba0c3] text-[11px]">
                    Category: {selected.category}
                  </span>
                </div>

                <div className="flex-1 p-6 overflow-y-auto bg-[#070b13]/60">
                  <MarkdownRenderer content={selected.markdown} />
                </div>
              </>
            ) : (
              <div className="flex items-center justify-center h-full text-xs text-[#8ba0c3]">
                Select a document from the queue to preview.
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
