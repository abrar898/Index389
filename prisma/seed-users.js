const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");

const prisma = new PrismaClient();

async function main() {
  console.log("Seeding cybersecurity platform accounts...");

  // 1. Admin Operator Account
  const adminPassword = process.env.INITIAL_ADMIN_PASSWORD || "CyberSecAdmin2026!";
  const adminHash = await bcrypt.hash(adminPassword, 10);

  const admin = await prisma.user.upsert({
    where: { email: "admin@cybersec.local" },
    update: {
      role: "ADMIN",
      name: "Lead Security Researcher",
      passwordHash: adminHash,
    },
    create: {
      email: "admin@cybersec.local",
      name: "Lead Security Researcher",
      passwordHash: adminHash,
      role: "ADMIN",
    },
  });

  // 2. Reader / Standard Analyst Account (Read-Only)
  const readerPassword = "Analyst2026!";
  const readerHash = await bcrypt.hash(readerPassword, 10);

  const reader = await prisma.user.upsert({
    where: { email: "analyst@cybersec.local" },
    update: {
      role: "READER",
      name: "Security Analyst (Read-Only)",
      passwordHash: readerHash,
    },
    create: {
      email: "analyst@cybersec.local",
      name: "Security Analyst (Read-Only)",
      passwordHash: readerHash,
      role: "READER",
    },
  });

  console.log(`Admin account ready: ${admin.email} (ADMIN - full edit/add/delete rights)`);
  console.log(`User account ready: ${reader.email} (READER - read-only browsing & exports)`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
