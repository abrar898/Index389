import { NextRequest, NextResponse } from "next/server";
import { cookies } from "next/headers";
import { getBaseUrl } from "@/lib/utils";

export async function POST(req: NextRequest) {
  const cookieStore = await cookies();
  cookieStore.delete("cyber_session");
  const origin = getBaseUrl(req) || req.nextUrl?.origin;
  return NextResponse.redirect(new URL("/login", origin), { status: 303 });
}

export async function GET(req: NextRequest) {
  const cookieStore = await cookies();
  cookieStore.delete("cyber_session");
  const origin = getBaseUrl(req) || req.nextUrl?.origin;
  return NextResponse.redirect(new URL("/login", origin), { status: 303 });
}

