import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import Script from "next/script";
import { ThemeProvider } from "@/components/layout/ThemeContext";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Index 389 // Cybersecurity & CTF Knowledge Base",
  description: "Index 389 - Modern cybersecurity knowledge repository, CTF write-ups and technical documentation engine.",
  icons: {
    icon: "/logo.png",
    apple: "/logo.png",
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
      suppressHydrationWarning
    >
      <body className="min-h-full flex flex-col">
        <Script
          id="theme-script"
          strategy="beforeInteractive"
          dangerouslySetInnerHTML={{
            __html: `try{const s=localStorage.getItem("cybernotes_theme");const p=window.matchMedia("(prefers-color-scheme: dark)").matches;if(s==="light"||(!s&&!p)){document.documentElement.classList.add("light");document.documentElement.classList.remove("dark");}else{document.documentElement.classList.add("dark");document.documentElement.classList.remove("light");}}catch(e){}`,
          }}
        />
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  );
}
