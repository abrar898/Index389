-- 1. Categories & Users
INSERT INTO "Category" ("id", "name", "slug", "description", "icon", "color", "createdAt", "updatedAt")
VALUES ('cmvcr40e20001idhk6vkop6a0', 'Privilege Escalation', 'privilege-escalation', 'Linux and Windows local privilege escalation, SUID exploitation, and token manipulation.', 'folder', '#10b981', to_timestamp(1792262993.403), to_timestamp(1792262993.403))
ON CONFLICT ("slug") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon" = EXCLUDED."icon", "color" = EXCLUDED."color";
INSERT INTO "Category" ("id", "name", "slug", "description", "icon", "color", "createdAt", "updatedAt")
VALUES ('cmvcr40ee0002idhkpge09kog', 'Network & Recon', 'network-recon', 'Port scanning, service enumeration, OSINT, and active directory reconnaissance.', 'folder', '#06b6d4', to_timestamp(1792262993.414), to_timestamp(1792262993.414))
ON CONFLICT ("slug") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon" = EXCLUDED."icon", "color" = EXCLUDED."color";
INSERT INTO "Category" ("id", "name", "slug", "description", "icon", "color", "createdAt", "updatedAt")
VALUES ('cmvcr40ei0003idhk0436llul', 'Web Security', 'web-security', 'OWASP Top 10, SSRF, SQLi, IDOR, template injection, and API penetration testing.', 'folder', '#f59e0b', to_timestamp(1792262993.418), to_timestamp(1792262993.418))
ON CONFLICT ("slug") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon" = EXCLUDED."icon", "color" = EXCLUDED."color";
INSERT INTO "Category" ("id", "name", "slug", "description", "icon", "color", "createdAt", "updatedAt")
VALUES ('cmvcr40eo0004idhk7qpiqkv4', 'Active Directory', 'active-directory', 'Kerberoasting, AS-REP roasting, BloodHound analysis, and domain compromise paths.', 'folder', '#8b5cf6', to_timestamp(1792262993.424), to_timestamp(1792262993.424))
ON CONFLICT ("slug") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon" = EXCLUDED."icon", "color" = EXCLUDED."color";
INSERT INTO "Category" ("id", "name", "slug", "description", "icon", "color", "createdAt", "updatedAt")
VALUES ('cmvcsa9i0000hidr0sh1y58oz', 'CPTS', 'cpts', NULL, 'folder', '#e22908', to_timestamp(1792264964.761), to_timestamp(1792264964.761))
ON CONFLICT ("slug") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon" = EXCLUDED."icon", "color" = EXCLUDED."color";
INSERT INTO "Category" ("id", "name", "slug", "description", "icon", "color", "createdAt", "updatedAt")
VALUES ('cmvfonfhr00ayida0a37aijsy', 'CWES', 'cwes', NULL, 'folder', '#9fef00', to_timestamp(1792440259.119), to_timestamp(1792440259.119))
ON CONFLICT ("slug") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon" = EXCLUDED."icon", "color" = EXCLUDED."color";
INSERT INTO "User" ("id", "email", "name", "passwordHash", "role", "avatarUrl", "createdAt", "updatedAt")
VALUES ('cmvcr40dj0000idhkp489xa3k', 'admin@cybersec.local', 'Lead Security Researcher', '$2b$10$VqwAI4Y5.yLIicGb/v4lEuFfq2eyGHp5lUynOjiuqXmBS6/UNBMne', 'ADMIN', NULL, to_timestamp(1792262993.382), to_timestamp(1792276923.835))
ON CONFLICT ("email") DO UPDATE SET "name" = EXCLUDED."name", "passwordHash" = EXCLUDED."passwordHash", "role" = EXCLUDED."role";
INSERT INTO "User" ("id", "email", "name", "passwordHash", "role", "avatarUrl", "createdAt", "updatedAt")
VALUES ('cmvcsh4td0001idc8x3ww5gnn', 'analyst@cybersec.local', 'Security Analyst (Read-Only)', '$2b$10$mDHzDvzI7LskKFPJrI78leJ8ElytVwebPfGPgtcJYadbIxDOnvwwe', 'READER', NULL, to_timestamp(1792265285.281), to_timestamp(1792265285.281))
ON CONFLICT ("email") DO UPDATE SET "name" = EXCLUDED."name", "passwordHash" = EXCLUDED."passwordHash", "role" = EXCLUDED."role";
