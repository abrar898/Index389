import { NextResponse } from "next/server";
import prisma from "@/lib/db";
import { verifyPassword, createSessionToken, logAudit } from "@/lib/auth";
import { checkRateLimit, getClientIp } from "@/lib/rate-limit";
import { cookies } from "next/headers";

export async function POST(req: Request) {
  try {
    const ip = getClientIp(req);

    // Apply strict rate limiting: max 6 login attempts per 15 minutes
    const rateLimit = await checkRateLimit(`login:${ip}`, {
      maxRequests: 6,
      windowMs: 15 * 60 * 1000,
    });

    if (!rateLimit.success) {
      return NextResponse.json(
        {
          error: `Too many authentication attempts. Security lockout active for ${rateLimit.resetInSeconds}s.`,
        },
        {
          status: 429,
          headers: {
            "Retry-After": String(rateLimit.resetInSeconds),
          },
        }
      );
    }

    const { email, password } = await req.json();

    if (!email || !password) {
      return NextResponse.json({ error: "Email and password are required." }, { status: 400 });
    }

    const user = await prisma.user.findUnique({
      where: { email: email.toLowerCase().trim() },
    });

    if (!user) {
      await logAudit("AUTH_FAILURE", "User", undefined, `Failed login attempt for unknown user: ${email} from IP: ${ip}`);
      return NextResponse.json({ error: "Invalid operator credentials." }, { status: 401 });
    }

    const isValid = await verifyPassword(password, user.passwordHash);
    if (!isValid) {
      await logAudit("AUTH_FAILURE", "User", user.id, `Failed password attempt for user: ${email} from IP: ${ip}`);
      return NextResponse.json({ error: "Invalid operator credentials." }, { status: 401 });
    }

    const token = await createSessionToken({
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role as any,
      avatarUrl: user.avatarUrl,
    });

    const cookieStore = await cookies();
    cookieStore.set("cyber_session", token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      path: "/",
      maxAge: 60 * 60 * 24 * 7, // 7 days
    });

    await logAudit("LOGIN", "User", user.id, `User logged in: ${user.email}`, user.id);

    return NextResponse.json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
      },
    });
  } catch (err: unknown) {
    console.error("Login error:", err);
    return NextResponse.json({ error: "Authentication system error." }, { status: 500 });
  }
}
