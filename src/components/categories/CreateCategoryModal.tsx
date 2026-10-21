"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { FolderPlus, Plus, X, Check, AlertCircle } from "lucide-react";

interface CreateCategoryModalProps {
  onCategoryCreated?: (newCategory: { id: string; name: string; slug: string }) => void;
  triggerButtonText?: string;
  triggerButtonClassName?: string;
}

export function CreateCategoryModal({
  onCategoryCreated,
  triggerButtonText = "Add Category",
  triggerButtonClassName,
}: CreateCategoryModalProps) {
  const router = useRouter();
  const [isOpen, setIsOpen] = useState(false);
  const [name, setName] = useState("");
  const [slug, setSlug] = useState("");
  const [description, setDescription] = useState("");
  const [color, setColor] = useState("#9fef00");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  const handleNameChange = (val: string) => {
    setName(val);
    setSlug(
      val
        .toLowerCase()
        .trim()
        .replace(/[^\w\s-]/g, "")
        .replace(/[\s_-]+/g, "-")
    );
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) {
      setError("Please specify a category name.");
      return;
    }

    setIsSubmitting(true);
    setError("");

    try {
      const res = await fetch("/api/categories", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: name.trim(),
          slug: slug.trim(),
          description: description.trim(),
          color,
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || "Failed to create category.");
      }

      setSuccess(true);
      if (onCategoryCreated) {
        onCategoryCreated(data);
      }

      setTimeout(() => {
        setIsOpen(false);
        setSuccess(false);
        setName("");
        setSlug("");
        setDescription("");
        router.refresh();
      }, 1000);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "An error occurred.");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <>
      <button
        type="button"
        onClick={() => setIsOpen(true)}
        className={
          triggerButtonClassName ||
          "flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[#14233c] hover:bg-[#182844] border border-[#1f3352] text-xs font-mono text-[#9fef00] transition-all shadow-sm active:scale-95"
        }
      >
        <Plus className="w-3.5 h-3.5" />
        <span>{triggerButtonText}</span>
      </button>

      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/75 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="relative w-full max-w-md rounded-2xl border border-[#1f3352] glass-panel p-6 shadow-2xl space-y-4 font-sans text-xs">
            {/* Header */}
            <div className="flex items-center justify-between border-b border-[#1f3352] pb-3">
              <div className="flex items-center gap-2">
                <div className="w-7 h-7 rounded bg-[#111d30] border border-[#1f3352] flex items-center justify-center text-[#9fef00]">
                  <FolderPlus className="w-4 h-4" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-[#ffffff]">Create Knowledge Domain</h3>
                  <p className="text-[10px] font-mono text-[#6c7d9c]">NEW TAXONOMY CATEGORY</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setIsOpen(false)}
                className="p-1 rounded text-[#6c7d9c] hover:text-[#ffffff] hover:bg-[#14233c] transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {error && (
              <div className="p-2.5 rounded-lg bg-[#ff3366]/10 border border-[#ff3366]/30 text-[#ff3366] flex items-center gap-2">
                <AlertCircle className="w-4 h-4 flex-shrink-0" />
                <span>{error}</span>
              </div>
            )}

            {success && (
              <div className="p-2.5 rounded-lg bg-[#9fef00]/10 border border-[#9fef00]/30 text-[#9fef00] flex items-center gap-2">
                <Check className="w-4 h-4 flex-shrink-0" />
                <span>Category created successfully!</span>
              </div>
            )}

            {/* Form */}
            <form onSubmit={handleSubmit} className="space-y-3 font-mono">
              <div className="space-y-1">
                <label className="text-[#8ba0c3] text-[11px]">CATEGORY NAME</label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => handleNameChange(e.target.value)}
                  placeholder="e.g. Reverse Engineering & Malware Analysis"
                  required
                  className="w-full px-3 py-2 rounded-lg bg-[#111d30] border border-[#1f3352] text-[#ffffff] focus:border-[#9fef00] focus:outline-none"
                />
              </div>

              <div className="space-y-1">
                <label className="text-[#8ba0c3] text-[11px]">URL SLUG</label>
                <input
                  type="text"
                  value={slug}
                  onChange={(e) => setSlug(e.target.value)}
                  placeholder="e.g. reverse-engineering"
                  required
                  className="w-full px-3 py-2 rounded-lg bg-[#111d30] border border-[#1f3352] text-[#ffffff] focus:border-[#9fef00] focus:outline-none"
                />
              </div>

              <div className="space-y-1">
                <label className="text-[#8ba0c3] text-[11px]">DESCRIPTION</label>
                <textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder="Decompilation, Ghidra, x64dbg, shellcode analysis, and binary exploitation."
                  rows={2}
                  className="w-full px-3 py-2 rounded-lg bg-[#111d30] border border-[#1f3352] text-[#ffffff] focus:border-[#9fef00] focus:outline-none resize-none font-sans"
                />
              </div>

              <div className="space-y-1">
                <label className="text-[#8ba0c3] text-[11px]">ACCENT COLOR</label>
                <div className="flex items-center gap-2">
                  <input
                    type="color"
                    value={color}
                    onChange={(e) => setColor(e.target.value)}
                    className="w-8 h-8 rounded border border-[#1f3352] bg-transparent cursor-pointer"
                  />
                  <span className="text-[#ffffff]">{color}</span>
                </div>
              </div>

              <div className="pt-2 flex items-center justify-end gap-2 border-t border-[#1f3352]">
                <button
                  type="button"
                  onClick={() => setIsOpen(false)}
                  className="px-3 py-1.5 rounded-lg bg-[#14233c] text-[#8ba0c3] hover:text-[#ffffff] transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting || success}
                  className="flex items-center gap-1.5 px-4 py-1.5 rounded-xl bg-[#9fef00] text-[#0b121e] font-bold hover:bg-[#b4fa1f] transition-all shadow-md active:scale-95 disabled:opacity-50"
                >
                  {isSubmitting ? <span>Saving...</span> : <span>Create Category</span>}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
}
