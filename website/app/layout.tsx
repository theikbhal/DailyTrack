import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "DailyTrack",
  description: "Single-user daily tracker for zikir, namaz, rest and life.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
