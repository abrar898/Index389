import { NextRequest, NextResponse } from "next/server";
import { getBaseUrl } from "@/lib/utils";

export async function GET(req: NextRequest, props: { params: Promise<{ slug: string }> }) {
  const params = await props.params;
  const origin = getBaseUrl(req) || req.nextUrl?.origin;
  // Redirect to the dedicated clean print/pdf layout
  return NextResponse.redirect(new URL(`/notes/${params.slug}/pdf`, origin));
}

