import { MethodologyClient } from "@/components/methodology/MethodologyClient";
import { CheckSquare } from "lucide-react";

export const metadata = {
  title: "Pentesting Methodology & Checklist // CyberNotes KB",
  description: "Operational checklists, tactical reconnaissance steps, and privilege escalation procedures.",
};

export default function MethodologyPage() {
  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="flex flex-wrap items-center justify-between gap-4 p-6 rounded-2xl border border-[#1f3352] glass-panel relative overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-[#9fef00]/10 via-transparent to-transparent rounded-full blur-2xl pointer-events-none" />

        <div className="space-y-1 relative z-10">
          <div className="flex items-center gap-2 font-mono text-xs text-[#9fef00]">
            <CheckSquare className="w-4 h-4" />
            <span>OPERATIONAL PLAYBOOKS</span>
          </div>
          <h1 className="text-2xl font-extrabold tracking-tight text-[#ffffff]">
            Penetration Testing Methodology
          </h1>
          <p className="text-xs text-[#a4b1cd] font-mono">
            Track real-time engagement progress across Recon, Web Exploitation, and Root Privilege Escalation
          </p>
        </div>
      </div>

      <MethodologyClient />
    </div>
  );
}
