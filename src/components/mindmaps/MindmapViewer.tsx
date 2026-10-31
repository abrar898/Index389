"use client";

import React, { useState, useRef } from "react";
import Link from "next/link";
import {
  Maximize2,
  Minimize2,
  ExternalLink,
  Edit,
  Download,
  Share2,
  Network,
  Tag,
  Folder,
  Layers,
  Terminal,
  Check,
  ArrowLeft,
  Sparkles,
} from "lucide-react";
import { MindmapItem } from "@/lib/mindmaps-shared";
import { SessionUser } from "@/lib/auth";

interface MindmapViewerProps {
  mindmap: MindmapItem;
  user: SessionUser | null;
}

export function MindmapViewer({ mindmap, user }: MindmapViewerProps) {
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [copied, setCopied] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const iframeRef = useRef<HTMLIFrameElement>(null);

  const toggleFullscreen = () => {
    if (!containerRef.current) return;

    if (!document.fullscreenElement) {
      containerRef.current.requestFullscreen().catch((err) => {
        console.error("Error attempting to enable fullscreen:", err);
      });
      setIsFullscreen(true);
    } else {
      document.exitFullscreen().catch((err) => {
        console.error("Error attempting to exit fullscreen:", err);
      });
      setIsFullscreen(false);
    }
  };

  const handleDownload = () => {
    const blob = new Blob([mindmap.htmlContent], { type: "text/html;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `${mindmap.slug}.html`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  const handleCopyLink = () => {
    if (typeof window !== "undefined") {
      navigator.clipboard.writeText(window.location.href);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  // Standalone public HTML path
  const rawHtmlUrl = `/mindmaps/${mindmap.slug}.html`;

  return (
    <div
      ref={containerRef}
      className={`flex flex-col bg-[#070b13] transition-all duration-200 ${
        isFullscreen ? "fixed inset-0 z-50 h-screen w-screen" : "h-[calc(100vh-5.5rem)] rounded-2xl border border-[#1f3352] overflow-hidden shadow-2xl"
      }`}
    >
      {/* Top Controls & Navigation Header */}
      <div className="flex flex-wrap items-center justify-between gap-3 px-4 py-2.5 bg-[#0b121e] border-b border-[#1f3352] flex-shrink-0 z-20">
        <div className="flex items-center gap-3 min-w-0">
          {!isFullscreen && (
            <Link
              href="/mindmaps"
              className="p-1.5 rounded-lg border border-[#1f3352] bg-[#111d30] hover:bg-[#14233c] text-[#8ba0c3] hover:text-[#ffffff] transition-colors"
              title="Back to all mindmaps"
            >
              <ArrowLeft className="w-4 h-4" />
            </Link>
          )}

          <div className="flex items-center gap-2 truncate">
            <div className="w-7 h-7 rounded-md bg-[#9fef00]/10 border border-[#9fef00]/30 flex items-center justify-center text-[#9fef00] flex-shrink-0">
              <Network className="w-4 h-4" />
            </div>
            <div className="flex flex-col min-w-0">
              <div className="flex items-center gap-2">
                <span className="font-bold text-sm text-[#ffffff] truncate">{mindmap.title}</span>
                {mindmap.isDefault && (
                  <span className="px-1.5 py-0.2 rounded font-mono text-[9px] font-bold bg-[#9fef00]/15 text-[#9fef00] border border-[#9fef00]/30">
                    FEATURED EXAM CANVAS
                  </span>
                )}
              </div>
              <div className="flex items-center gap-2 text-[11px] font-mono text-[#6c7d9c] truncate">
                <span>{mindmap.category}</span>
                <span>•</span>
                <span>{mindmap.nodeCount || 30}+ Nodes</span>
                <span>•</span>
                <span>{mindmap.phaseCount || 9} Phases</span>
                {mindmap.commandCount > 0 && (
                  <>
                    <span>•</span>
                    <span className="text-[#9fef00]">{mindmap.commandCount} Commands</span>
                  </>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex items-center gap-1.5 sm:gap-2">
          {user && (
            <Link
              href={`/mindmaps/${mindmap.slug}/edit`}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-[#1f3352] bg-[#111d30] hover:bg-[#14233c] text-xs font-medium text-[#8ba0c3] hover:text-[#ffffff] transition-all"
            >
              <Edit className="w-3.5 h-3.5 text-[#2de2e6]" />
              <span className="hidden sm:inline">Edit HTML</span>
            </Link>
          )}

          <a
            href={rawHtmlUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-[#1f3352] bg-[#111d30] hover:bg-[#14233c] text-xs font-medium text-[#8ba0c3] hover:text-[#ffffff] transition-all"
            title="Open pure HTML in new tab"
          >
            <ExternalLink className="w-3.5 h-3.5 text-[#9fef00]" />
            <span className="hidden sm:inline">New Tab</span>
          </a>

          <button
            onClick={handleDownload}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-[#1f3352] bg-[#111d30] hover:bg-[#14233c] text-xs font-medium text-[#8ba0c3] hover:text-[#ffffff] transition-all"
            title="Download standalone HTML file"
          >
            <Download className="w-3.5 h-3.5" />
            <span className="hidden sm:inline">Export</span>
          </button>

          <button
            onClick={handleCopyLink}
            className="p-1.5 sm:px-3 sm:py-1.5 rounded-lg border border-[#1f3352] bg-[#111d30] hover:bg-[#14233c] text-xs font-medium text-[#8ba0c3] hover:text-[#ffffff] transition-all"
            title="Copy share link"
          >
            {copied ? (
              <span className="flex items-center gap-1 text-[#9fef00]">
                <Check className="w-3.5 h-3.5" /> <span className="hidden sm:inline">Copied!</span>
              </span>
            ) : (
              <span className="flex items-center gap-1">
                <Share2 className="w-3.5 h-3.5" /> <span className="hidden sm:inline">Share</span>
              </span>
            )}
          </button>

          <button
            onClick={toggleFullscreen}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[#9fef00] hover:bg-[#b4fa1f] text-xs font-bold text-[#0b121e] transition-all shadow-md active:scale-95"
            title={isFullscreen ? "Exit Fullscreen" : "Enter Fullscreen Mode"}
          >
            {isFullscreen ? (
              <>
                <Minimize2 className="w-3.5 h-3.5" />
                <span>Exit Fullscreen</span>
              </>
            ) : (
              <>
                <Maximize2 className="w-3.5 h-3.5" />
                <span>Fullscreen</span>
              </>
            )}
          </button>
        </div>
      </div>

      {/* Embedded Mindmap Canvas Frame */}
      <div className="relative flex-1 w-full h-full bg-[#000000] overflow-hidden">
        <iframe
          ref={iframeRef}
          src={rawHtmlUrl}
          className="w-full h-full border-none outline-none block"
          title={mindmap.title}
          allow="clipboard-read; clipboard-write; fullscreen"
          sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-modals"
        />
      </div>
    </div>
  );
}
