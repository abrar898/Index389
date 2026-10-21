import { NextRequest } from "next/server";
import prisma from "@/lib/db";

interface RateLimitConfig {
  maxRequests: number;
  windowMs: number;
}

interface ClientRecord {
  timestamps: number[];
}

// In-memory sliding window cache
const rateLimitMap = new Map<string, ClientRecord>();

// Periodically clean up stale entries (every 5 minutes)
if (typeof setInterval !== "undefined") {
  setInterval(() => {
    const now = Date.now();
    for (const [key, record] of rateLimitMap.entries()) {
      record.timestamps = record.timestamps.filter((ts) => now - ts < 3600000);
      if (record.timestamps.length === 0) {
        rateLimitMap.delete(key);
      }
    }
  }, 300000);
}

export function getClientIp(req: Request | NextRequest): string {
  const forwarded = req.headers.get("x-forwarded-for");
  if (forwarded) {
    return forwarded.split(",")[0].trim();
  }
  const realIp = req.headers.get("x-real-ip");
  if (realIp) return realIp.trim();
  const cfIp = req.headers.get("cf-connecting-ip");
  if (cfIp) return cfIp.trim();
  return "127.0.0.1";
}

export async function checkRateLimit(
  key: string,
  config: RateLimitConfig = { maxRequests: 60, windowMs: 60000 }
): Promise<{
  success: boolean;
  limit: number;
  remaining: number;
  resetInSeconds: number;
}> {
  const now = Date.now();
  let record = rateLimitMap.get(key);

  if (!record) {
    record = { timestamps: [] };
    rateLimitMap.set(key, record);
  }

  // Filter timestamps within current sliding window
  record.timestamps = record.timestamps.filter((ts) => now - ts < config.windowMs);

  if (record.timestamps.length >= config.maxRequests) {
    const oldest = record.timestamps[0];
    const resetInSeconds = Math.ceil((oldest + config.windowMs - now) / 1000);

    // Non-blocking security audit log
    try {
      await prisma.auditLog.create({
        data: {
          action: "SECURITY_RATE_LIMIT_TRIGGERED",
          entity: "IP_SHIELD",
          details: `Rate limit exceeded for key [${key}]. ${record.timestamps.length} requests in window.`,
        },
      });
    } catch {
      // ignore
    }

    return {
      success: false,
      limit: config.maxRequests,
      remaining: 0,
      resetInSeconds: Math.max(1, resetInSeconds),
    };
  }

  // Record this request
  record.timestamps.push(now);

  return {
    success: true,
    limit: config.maxRequests,
    remaining: config.maxRequests - record.timestamps.length,
    resetInSeconds: Math.ceil(config.windowMs / 1000),
  };
}
