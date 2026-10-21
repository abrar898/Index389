import { SignJWT, jwtVerify } from "jose";
import { cookies } from "next/headers";
import bcrypt from "bcryptjs";
import prisma from "@/lib/db";

const SECRET_KEY = process.env.JWT_SECRET || "fallback-secret-cybersecurity-notes-platform-987456";
const key = new TextEncoder().encode(SECRET_KEY);

export type UserRole = "ADMIN" | "EDITOR" | "AUTHOR" | "READER";

export interface SessionUser {
  id: string;
  email: string;
  name: string | null;
  role: UserRole;
  avatarUrl: string | null;
}

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 10);
}

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}

export async function createSessionToken(user: SessionUser): Promise<string> {
  return new SignJWT({
    id: user.id,
    email: user.email,
    name: user.name,
    role: user.role,
    avatarUrl: user.avatarUrl,
  })
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime("7d")
    .sign(key);
}

export async function verifySessionToken(token: string): Promise<SessionUser | null> {
  try {
    const { payload } = await jwtVerify(token, key);
    return {
      id: payload.id as string,
      email: payload.email as string,
      name: (payload.name as string) || null,
      role: (payload.role as UserRole) || "READER",
      avatarUrl: (payload.avatarUrl as string) || null,
    };
  } catch {
    return null;
  }
}

export async function getCurrentUser(): Promise<SessionUser | null> {
  const cookieStore = await cookies();
  const token = cookieStore.get("cyber_session")?.value;
  if (!token) return null;
  return verifySessionToken(token);
}

export function canEditDocument(user: SessionUser | null, authorId?: string): boolean {
  if (!user) return false;
  return user.role === "ADMIN";
}

export function canPublishDocument(user: SessionUser | null): boolean {
  if (!user) return false;
  return user.role === "ADMIN";
}

export function canManageUsers(user: SessionUser | null): boolean {
  if (!user) return false;
  return user.role === "ADMIN";
}

export async function logAudit(
  action: string,
  entity: string,
  entityId?: string,
  details?: string,
  userId?: string
) {
  try {
    await prisma.auditLog.create({
      data: {
        action,
        entity,
        entityId: entityId || null,
        details: details || null,
        userId: userId || null,
      },
    });
  } catch (err) {
    console.error("Failed to write audit log:", err);
  }
}
