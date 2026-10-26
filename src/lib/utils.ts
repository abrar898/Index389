import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatDate(date: Date | string | null | undefined): string {
  if (!date) return "Recently";
  const d = new Date(date);
  return d.toLocaleDateString("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

export function getBaseUrl(req?: Request | { headers: Headers; url?: string }): string {
  if (req) {
    const forwardedHost = req.headers.get("x-forwarded-host");
    const forwardedProto = req.headers.get("x-forwarded-proto") || "https";
    if (forwardedHost) {
      return `${forwardedProto}://${forwardedHost}`;
    }
    const host = req.headers.get("host");
    if (host) {
      const isLocal = host.includes("localhost") || host.includes("127.0.0.1");
      const proto = req.headers.get("x-forwarded-proto") || (isLocal ? "http" : "https");
      return `${proto}://${host}`;
    }
    if (req.url) {
      try {
        return new URL(req.url).origin;
      } catch {
        // ignore
      }
    }
  }
  return process.env.NEXT_PUBLIC_APP_URL || "";
}

