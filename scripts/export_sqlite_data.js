const fs = require('fs');
const path = require('path');
const { DatabaseSync } = require('node:sqlite');

function escapeSql(val) {
  if (val === null || val === undefined) return 'NULL';
  if (typeof val === 'number') return val;
  if (typeof val === 'boolean') return val ? 'TRUE' : 'FALSE';
  return `'${String(val).replace(/'/g, "''")}'`;
}

function run() {
  const dbPath = path.join(__dirname, '..', 'prisma', 'dev.db');
  console.log('Opening local SQLite db at:', dbPath);

  if (!fs.existsSync(dbPath)) {
    console.error('dev.db not found!');
    process.exit(1);
  }

  const db = new DatabaseSync(dbPath);

  const users = db.prepare('SELECT * FROM User').all();
  const categories = db.prepare('SELECT * FROM Category').all();
  const tags = db.prepare('SELECT * FROM Tag').all();
  const documents = db.prepare('SELECT * FROM Document').all();
  const documentTags = db.prepare('SELECT * FROM DocumentTag').all();
  const favorites = db.prepare('SELECT * FROM Favorite').all();

  console.log(`Successfully extracted from local SQLite:
  - ${users.length} Users
  - ${categories.length} Categories
  - ${tags.length} Tags
  - ${documents.length} Notes / Documents
  - ${documentTags.length} Document Tags
  - ${favorites.length} Favorites
  `);

  let sql = `-- ====================================================
-- FULL LOCAL SQLITE DATA EXPORT TO SUPABASE POSTGRES
-- Generated: ${new Date().toISOString()}
-- ====================================================

`;

  // 1. Categories
  sql += `-- 1. Categories\n`;
  for (const c of categories) {
    sql += `INSERT INTO "Category" ("id", "name", "slug", "description", "icon", "color", "createdAt", "updatedAt")
VALUES (${escapeSql(c.id)}, ${escapeSql(c.name)}, ${escapeSql(c.slug)}, ${escapeSql(c.description)}, ${escapeSql(c.icon)}, ${escapeSql(c.color)}, to_timestamp(${c.createdAt ? c.createdAt / 1000 : 'extract(epoch from now())'}), to_timestamp(${c.updatedAt ? c.updatedAt / 1000 : 'extract(epoch from now())'}))
ON CONFLICT ("slug") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon" = EXCLUDED."icon", "color" = EXCLUDED."color";\n`;
  }

  // 2. Tags
  sql += `\n-- 2. Tags\n`;
  for (const t of tags) {
    sql += `INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES (${escapeSql(t.id)}, ${escapeSql(t.name)}, ${escapeSql(t.slug)}, ${escapeSql(t.color)}, to_timestamp(${t.createdAt ? t.createdAt / 1000 : 'extract(epoch from now())'}))
ON CONFLICT ("slug") DO NOTHING;\n`;
  }

  // 3. Users
  sql += `\n-- 3. Users\n`;
  for (const u of users) {
    sql += `INSERT INTO "User" ("id", "email", "name", "passwordHash", "role", "avatarUrl", "createdAt", "updatedAt")
VALUES (${escapeSql(u.id)}, ${escapeSql(u.email)}, ${escapeSql(u.name)}, ${escapeSql(u.passwordHash)}, ${escapeSql(u.role)}, ${escapeSql(u.avatarUrl)}, to_timestamp(${u.createdAt ? u.createdAt / 1000 : 'extract(epoch from now())'}), to_timestamp(${u.updatedAt ? u.updatedAt / 1000 : 'extract(epoch from now())'}))
ON CONFLICT ("email") DO UPDATE SET "name" = EXCLUDED."name", "passwordHash" = EXCLUDED."passwordHash", "role" = EXCLUDED."role";\n`;
  }

  // 4. Documents
  sql += `\n-- 4. Documents / Notes\n`;
  for (const d of documents) {
    sql += `INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES (${escapeSql(d.id)}, ${escapeSql(d.title)}, ${escapeSql(d.slug)}, ${escapeSql(d.description)}, ${escapeSql(d.contentMarkdown)}, ${escapeSql(d.contentHtml)}, ${escapeSql(d.status)}, ${escapeSql(d.visibility)}, ${d.readingTimeMin || 1}, ${escapeSql(d.categoryId)}, ${escapeSql(d.authorId)}, to_timestamp(${d.createdAt ? d.createdAt / 1000 : 'extract(epoch from now())'}), to_timestamp(${d.updatedAt ? d.updatedAt / 1000 : 'extract(epoch from now())'}), ${d.publishedAt ? `to_timestamp(${d.publishedAt / 1000})` : 'NULL'}, ${d.deletedAt ? `to_timestamp(${d.deletedAt / 1000})` : 'NULL'})
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";\n`;
  }

  // 5. Document Tags
  sql += `\n-- 5. Document Tags\n`;
  for (const dt of documentTags) {
    sql += `INSERT INTO "DocumentTag" ("id", "documentId", "tagId", "createdAt")
VALUES (${escapeSql(dt.id)}, ${escapeSql(dt.documentId)}, ${escapeSql(dt.tagId)}, to_timestamp(${dt.createdAt ? dt.createdAt / 1000 : 'extract(epoch from now())'}))
ON CONFLICT ("documentId", "tagId") DO NOTHING;\n`;
  }

  // 6. Favorites
  sql += `\n-- 6. Favorites\n`;
  for (const f of favorites) {
    sql += `INSERT INTO "Favorite" ("id", "userId", "documentId", "createdAt")
VALUES (${escapeSql(f.id)}, ${escapeSql(f.userId)}, ${escapeSql(f.documentId)}, to_timestamp(${f.createdAt ? f.createdAt / 1000 : 'extract(epoch from now())'}))
ON CONFLICT ("userId", "documentId") DO NOTHING;\n`;
  }

  const outPath = path.join(__dirname, '..', 'supabase_import.sql');
  fs.writeFileSync(outPath, sql, 'utf8');
  console.log('\n=============================================');
  console.log('SUCCESS! Generated file: supabase_import.sql');
  console.log('Size:', fs.statSync(outPath).size, 'bytes');
  console.log('=============================================');
}

run();
