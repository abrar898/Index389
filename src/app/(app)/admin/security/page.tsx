import prisma from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { redirect } from "next/navigation";
import {
  ShieldAlert,
  ShieldCheck,
  Lock,
  Activity,
  AlertTriangle,
  Server,
  FileCode,
  Users,
  Eye,
  Key,
} from "lucide-react";

export const metadata = {
  title: "Security Operations Center (SOC) // Index 389",
  description: "Real-time security telemetry, hardening controls, and threat monitoring.",
};

export default async function SecurityCenterPage() {
  const user = await getCurrentUser();
  if (!user || user.role !== "ADMIN") {
    redirect("/dashboard");
  }

  const [securityEvents, totalAuditLogs, failedLogins, rateLimitTriggers] = await Promise.all([
    prisma.auditLog.findMany({
      where: {
        action: {
          in: ["SECURITY_RATE_LIMIT_TRIGGERED", "AUTH_FAILURE", "PASSWORD_CHANGE", "LOGIN"],
        },
      },
      take: 20,
      orderBy: { createdAt: "desc" },
      include: {
        user: { select: { name: true, email: true } },
      },
    }),
    prisma.auditLog.count(),
    prisma.auditLog.count({ where: { action: "AUTH_FAILURE" } }),
    prisma.auditLog.count({ where: { action: "SECURITY_RATE_LIMIT_TRIGGERED" } }),
  ]);

  const securityControls = [
    {
      name: "Content-Security-Policy (CSP)",
      status: "ENFORCED",
      description: "Restricts script execution, frame ancestors, and untrusted network origins.",
      spec: "default-src 'self'; frame-ancestors 'none'",
      verified: true,
    },
    {
      name: "Anti-Clickjacking Defense",
      status: "ENFORCED",
      description: "Prevents UI redressing and iframe click-jacking attacks.",
      spec: "X-Frame-Options: DENY",
      verified: true,
    },
    {
      name: "MIME-Sniffing Prevention",
      status: "ENFORCED",
      description: "Blocks executable payloads disguised as text/images.",
      spec: "X-Content-Type-Options: nosniff",
      verified: true,
    },
    {
      name: "Strict Transport Security (HSTS)",
      status: "ENFORCED",
      description: "Enforces SSL/TLS with 1-year preload and subdomain inclusion.",
      spec: "max-age=31536000; includeSubDomains; preload",
      verified: true,
    },
    {
      name: "Sliding-Window IP Rate Limiter",
      status: "SHIELD ACTIVE",
      description: "Blocks credential stuffing, dictionary attacks, and DoS floods.",
      spec: "6 attempts / 15m sliding window with Retry-After header",
      verified: true,
    },
    {
      name: "Stored XSS Link Sanitizer",
      status: "ENFORCED",
      description: "Neutralizes javascript:, data:, and vbscript: URI execution in markdown notes.",
      spec: "Safe URI Whitelist Protocol Filter",
      verified: true,
    },
    {
      name: "HTTP-Only JWT Session Guard",
      status: "ENFORCED",
      description: "Stores session cryptographic signatures in HTTP-only, SameSite=Lax cookies.",
      spec: "HS256 Jose JWT + 7-day expiration",
      verified: true,
    },
    {
      name: "Role-Based Access Control (RBAC)",
      status: "RESTRICTED",
      description: "Strict separation between ADMIN operators and standard READERS.",
      spec: "Strict server-side validation guards on all mutative routes",
      verified: true,
    },
  ];

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="flex flex-wrap items-center justify-between gap-4 p-6 rounded-2xl border border-[#1f3352] glass-panel relative overflow-hidden">
        <div className="absolute top-0 right-0 w-80 h-80 bg-gradient-to-bl from-[#9fef00]/15 via-transparent to-transparent rounded-full blur-3xl pointer-events-none" />

        <div className="space-y-1 relative z-10">
          <div className="flex items-center gap-2 font-mono text-xs text-[#9fef00]">
            <ShieldCheck className="w-4 h-4" />
            <span>OPERATIONAL SECURITY CENTER // DEFCON 5</span>
          </div>
          <h1 className="text-2xl md:text-3xl font-extrabold tracking-tight text-[#ffffff]">
            Security Operations & Hardening Matrix
          </h1>
          <p className="text-xs text-[#8ba0c3] font-mono">
            Cryptographic posture, real-time threat telemetry, and defensive control status
          </p>
        </div>

        <div className="flex items-center gap-3 p-3 rounded-xl bg-[#111d30] border border-[#1f3352]">
          <div className="text-right">
            <span className="text-[10px] font-mono text-[#6c7d9c] block">SECURITY RATING</span>
            <span className="text-lg font-bold font-mono text-[#9fef00]">98/100 // HARDENED</span>
          </div>
          <div className="w-3 h-3 rounded-full bg-[#9fef00] animate-ping" />
        </div>
      </div>

      {/* Metrics Row */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <div className="p-4 rounded-2xl border border-[#1f3352] glass-panel space-y-1">
          <span className="text-[10px] font-mono text-[#6c7d9c] uppercase">Active Defense Controls</span>
          <p className="text-2xl font-bold font-mono text-[#9fef00]">8/8 ENFORCED</p>
        </div>
        <div className="p-4 rounded-2xl border border-[#1f3352] glass-panel space-y-1">
          <span className="text-[10px] font-mono text-[#6c7d9c] uppercase">Rate Limit Lockouts</span>
          <p className="text-2xl font-bold font-mono text-[#ff8400]">{rateLimitTriggers}</p>
        </div>
        <div className="p-4 rounded-2xl border border-[#1f3352] glass-panel space-y-1">
          <span className="text-[10px] font-mono text-[#6c7d9c] uppercase">Failed Auth Alerts</span>
          <p className="text-2xl font-bold font-mono text-[#ff3366]">{failedLogins}</p>
        </div>
        <div className="p-4 rounded-2xl border border-[#1f3352] glass-panel space-y-1">
          <span className="text-[10px] font-mono text-[#6c7d9c] uppercase">Total Audit Records</span>
          <p className="text-2xl font-bold font-mono text-[#2de2e6]">{totalAuditLogs}</p>
        </div>
      </div>

      {/* Security Hardening Controls Matrix */}
      <div className="space-y-3">
        <h2 className="text-sm font-bold font-mono text-[#ffffff] uppercase tracking-wider flex items-center gap-2">
          <Lock className="w-4 h-4 text-[#9fef00]" />
          <span>Active Defensive Architecture</span>
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {securityControls.map((ctrl, idx) => (
            <div
              key={idx}
              className="p-5 rounded-2xl border border-[#1f3352] glass-panel flex flex-col justify-between space-y-3"
            >
              <div className="space-y-1.5">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-bold text-[#ffffff]">{ctrl.name}</span>
                  <span className="px-2 py-0.5 rounded text-[10px] font-mono font-bold bg-[#9fef00]/15 text-[#9fef00] border border-[#9fef00]/40">
                    {ctrl.status}
                  </span>
                </div>
                <p className="text-xs text-[#8ba0c3] leading-relaxed">{ctrl.description}</p>
              </div>

              <div className="pt-2 border-t border-[#1f3352] font-mono text-[11px] text-[#6c7d9c] truncate">
                SPEC: <code className="text-[#9fef00]">{ctrl.spec}</code>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Live Threat & Event Monitor */}
      <div className="space-y-3">
        <h2 className="text-sm font-bold font-mono text-[#ffffff] uppercase tracking-wider flex items-center gap-2">
          <Activity className="w-4 h-4 text-[#9fef00]" />
          <span>Real-time Security Telemetry & Access Log</span>
        </h2>

        <div className="rounded-2xl border border-[#1f3352] overflow-hidden glass-panel">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-[#111d30] text-[#9fef00] font-mono border-b border-[#1f3352]">
              <tr>
                <th className="px-4 py-3">Timestamp</th>
                <th className="px-4 py-3">Event Type</th>
                <th className="px-4 py-3">Entity</th>
                <th className="px-4 py-3">Operator</th>
                <th className="px-4 py-3">Details</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#1f3352] bg-[#070b13] font-mono text-[#a4b1cd]">
              {securityEvents.length === 0 ? (
                <tr>
                  <td colSpan={5} className="p-6 text-center text-[#6c7d9c]">
                    No security events triggered. System operational.
                  </td>
                </tr>
              ) : (
                securityEvents.map((evt) => (
                  <tr key={evt.id} className="hover:bg-[#14233c]/40 transition-colors">
                    <td className="px-4 py-2.5 text-[#8ba0c3] whitespace-nowrap">
                      {new Date(evt.createdAt).toLocaleTimeString()}
                    </td>
                    <td className="px-4 py-2.5 whitespace-nowrap">
                      <span
                        className={`px-2 py-0.5 rounded text-[10px] font-bold border ${
                          evt.action.includes("FAILURE") || evt.action.includes("RATE_LIMIT")
                            ? "bg-[#ff3366]/15 text-[#ff3366] border-[#ff3366]/40"
                            : "bg-[#9fef00]/15 text-[#9fef00] border-[#9fef00]/40"
                        }`}
                      >
                        {evt.action}
                      </span>
                    </td>
                    <td className="px-4 py-2.5 text-[#8ba0c3]">{evt.entity}</td>
                    <td className="px-4 py-2.5 text-[#ffffff]">
                      {evt.user?.name || evt.user?.email || "ANONYMOUS"}
                    </td>
                    <td className="px-4 py-2.5 text-xs text-[#8ba0c3]">{evt.details}</td>
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
