# CYBERNOTES // Cybersecurity Knowledge Base & Research Platform

A production-ready technical cybersecurity documentation platform inspired by the clean documentation experiences of **Hack The Box Academy** and **HackIndex**.

---

## ⚡ Core Features

- **Personal Documentation Engine**: Dark charcoal technical theme (`#0d1117`) with terminal emerald green (`#10b981`) and cyan (`#06b6d4`) accents.
- **Tri-Column HTB Layout**:
  - **Left Sidebar**: Workspace navigation, categories, popular tags, and operator status.
  - **Center Column**: Breadcrumbs, document metadata, rendered technical Markdown, command blocks with copy buttons, and adjacent note navigation.
  - **Right Sidebar**: Auto-generated live Table of Contents, scroll progress indicator, export triggers, and related research notes.
- **Markdown Batch Ingestion Center (`/import`)**:
  - Upload single `.md` files, multi-file uploads, or full `.zip` archives.
  - Automatically parses YAML frontmatter (title, description, category, tags, status).
  - Automatically derives title from first `# Heading 1` when frontmatter is absent.
  - Live preview with reading time calculation before publishing.
- **Dedicated Markdown Editor (`/notes/new` & `/notes/[slug]/edit`)**:
  - Live Split-Screen view, Editor-only view, and Rendered Preview-only view.
  - Quick insertion helpers for bash terminal commands, Python exploit scripts, note callouts, and tables.
  - Metadata controls (title, slug, category, description, tags, status).
- **Document Export Pipeline**:
  - **Native Microsoft Word (`.docx`)**: Generated using `docx`, preserving headings, callout notes, bullet lists, and styled monospace code blocks.
  - **Clean PDF**: Print-optimized layout (`/notes/[slug]/pdf`) with headers, footers, metadata, and print CSS.
- **Database & RBAC**:
  - Database powered by Prisma ORM (`User`, `Document`, `Category`, `Tag`, `DocumentTag`, `DocumentVersion`, `UploadedAsset`, `Favorite`, `AuditLog`).
  - Roles: `ADMIN`, `EDITOR`, `AUTHOR`, `READER`.
  - Immutable version history snapshots on document edits.
  - Audit logs tracking actions, timestamps, and operators.

---

## 🚀 Getting Started

### 1. Requirements
- Node.js 18+ (tested with Node 24)
- npm 9+

### 2. Setup & Installation
```bash
# Clone or navigate to the project directory
cd index389

# Install dependencies
npm install

# Initialize database schema and generate Prisma client
npx prisma db push

# Seed initial operator account, categories, and technical notes
node prisma/seed.js
```

### 3. Run Development Server
```bash
npm run dev
```
Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## 🔐 Pre-configured Operator Credentials

The seed script creates the initial administrator account:
- **Email**: `admin@cybersec.local`
- **Password**: `CyberSecAdmin2026!`
- **Role**: `ADMIN`

---

## 📂 Project Architecture

```
src/
├── app/
│   ├── (app)/
│   │   ├── layout.tsx              # Tri-column shell & top header
│   │   ├── dashboard/page.tsx      # Metrics, recent research, shortcuts
│   │   ├── notes/
│   │   │   ├── page.tsx            # Central repository & category filter
│   │   │   ├── new/page.tsx        # Note creation studio
│   │   │   └── [slug]/
│   │   │       ├── page.tsx        # Document reader with right TOC
│   │   │       ├── edit/page.tsx   # Note editor
│   │   │       └── pdf/page.tsx    # Clean print/PDF export template
│   │   ├── import/page.tsx         # Drag-and-drop Markdown & ZIP importer
│   │   ├── categories/page.tsx     # Taxonomy overview
│   │   ├── search/page.tsx         # Title, description & content search
│   │   └── admin/audit-logs/       # Security audit trail
│   ├── api/
│   │   ├── auth/login/route.ts     # Session token authentication
│   │   ├── auth/logout/route.ts    # Session destruction
│   │   └── documents/              # Document CRUD, import & docx/pdf exports
│   └── login/page.tsx              # Dark cybersecurity auth terminal
├── components/
│   ├── layout/                     # Sidebar, RightSidebar, HeaderSearch
│   ├── markdown/                   # MarkdownRenderer, TerminalBlock, CodeBlock
│   └── editor/                     # NoteEditor split view studio
├── lib/
│   ├── auth.ts                     # JWT & RBAC permission helpers
│   ├── db.ts                       # Prisma singleton
│   ├── docx.ts                     # Word document generator
│   └── markdown.ts                 # Frontmatter, TOC & parser engine
prisma/
├── schema.prisma                   # Normalized models
└── seed.js                         # Database seeder
```
