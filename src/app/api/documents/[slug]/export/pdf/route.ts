import { NextResponse } from "next/server";

export async function GET(req: Request, props: { params: Promise<{ slug: string }> }) {
  const params = await props.params;
  const url = new URL(req.url);
  // Redirect to the dedicated clean print/pdf layout
  return NextResponse.redirect(new URL(`/notes/${params.slug}/pdf`, url.origin));
}
