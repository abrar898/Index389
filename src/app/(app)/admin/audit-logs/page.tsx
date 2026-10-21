import prisma from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { ShieldAlert, User, Clock, Terminal } from "lucide-react";
import { redirect } from "next/navigation";

export default async function AuditLogsPage() {
  const user = await getCurrentUser();
  if (!user || user.role !== "ADMIN") {
    redirect("/dashboard");
  }

  const logs = await prisma.auditLog.findMany({
    take: 50,
    orderBy: { createdAt: "desc" },
    include: {
      user: { select: { name: true, email: true, role: true } },
    },
  });

  return (
    <div className="space-y-6">
      <div className="p-6 rounded-2xl border border-[#1f3352] glass-panel space-y-1">
        <div className="flex items-center gap-2 font-mono text-xs text-[#9fef00]">
          <ShieldAlert className="w-4 h-4" />
          <span>SECURITY & AUDIT TRAILS</span>
        </div>
        <h1 className="text-2xl font-bold text-[#ffffff]">System Audit Logs</h1>
        <p className="text-xs text-[#8ba0c3]">
          Immutable access and modification history for documents, permissions, and imports.
        </p>
      </div>

      {/* Desktop & Tablet Table (Horizontally Scrollable on smaller screens) */}
      <div className="rounded-2xl border border-[var(--surface-border)] overflow-hidden glass-panel">
        <div className="overflow-x-auto w-full">
          <table className="w-full text-left border-collapse text-xs min-w-[640px]">
            <thead className="bg-[var(--surface)] text-[#9fef00] font-mono border-b border-[var(--surface-border)]">
              <tr>
                <th className="px-4 py-3">Timestamp</th>
                <th className="px-4 py-3">Action</th>
                <th className="px-4 py-3">Entity</th>
                <th className="px-4 py-3">User</th>
                <th className="px-4 py-3">Details</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[var(--surface-border)] bg-[var(--surface-card)] font-mono text-[var(--foreground)]">
              {logs.length === 0 ? (
                <tr>
                  <td colSpan={5} className="p-6 text-center text-[var(--foreground-muted)]">
                    No audit logs recorded yet.
                  </td>
                </tr>
              ) : (
                logs.map((log) => (
                  <tr key={log.id} className="hover:bg-[var(--surface-elevated)] transition-colors">
                    <td className="px-4 py-2.5 text-[var(--foreground-muted)] whitespace-nowrap">
                      {new Date(log.createdAt).toLocaleString()}
                    </td>
                    <td className="px-4 py-2.5 whitespace-nowrap">
                      <span className="px-2 py-0.5 rounded bg-[var(--surface)] border border-[var(--surface-border)] text-[#9fef00] font-bold">
                        {log.action}
                      </span>
                    </td>
                    <td className="px-4 py-2.5 whitespace-nowrap">{log.entity}</td>
                    <td className="px-4 py-2.5 text-[#2de2e6] whitespace-nowrap">
                      {log.user?.email || "System"}
                    </td>
                    <td className="px-4 py-2.5 text-[var(--foreground)] truncate max-w-xs">
                      {log.details || "-"}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
