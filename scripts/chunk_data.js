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
  const chunksDir = path.join(__dirname, '..', 'supabase_chunks');
  if (!fs.existsSync(chunksDir)) {
    fs.mkdirSync(chunksDir);
  }

  const db = new DatabaseSync(dbPath);

  const users = db.prepare('SELECT * FROM User').all();
  const categories = db.prepare('SELECT * FROM Category').all();
  const tags = db.prepare('SELECT * FROM Tag').all();
  const documents = db.prepare('SELECT * FROM Document').all();
  const documentTags = db.prepare('SELECT * FROM DocumentTag').all();
  const favorites = db.prepare('SELECT * FROM Favorite').all();

  // Part 1: Categories & Users
  let sql1 = `-- 1. Categories & Users\n`;
  for (const c of categories) {
    sql1 += `INSERT INTO "Category" ("id", "name", "slug", "description", "icon", "color", "createdAt", "updatedAt")
VALUES (${escapeSql(c.id)}, ${escapeSql(c.name)}, ${escapeSql(c.slug)}, ${escapeSql(c.description)}, ${escapeSql(c.icon)}, ${escapeSql(c.color)}, to_timestamp(${c.createdAt ? c.createdAt / 1000 : 'extract(epoch from now())'}), to_timestamp(${c.updatedAt ? c.updatedAt / 1000 : 'extract(epoch from now())'}))
ON CONFLICT ("slug") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon" = EXCLUDED."icon", "color" = EXCLUDED."color";\n`;
  }
  for (const u of users) {
    sql1 += `INSERT INTO "User" ("id", "email", "name", "passwordHash", "role", "avatarUrl", "createdAt", "updatedAt")
VALUES (${escapeSql(u.id)}, ${escapeSql(u.email)}, ${escapeSql(u.name)}, ${escapeSql(u.passwordHash)}, ${escapeSql(u.role)}, ${escapeSql(u.avatarUrl)}, to_timestamp(${u.createdAt ? u.createdAt / 1000 : 'extract(epoch from now())'}), to_timestamp(${u.updatedAt ? u.updatedAt / 1000 : 'extract(epoch from now())'}))
ON CONFLICT ("email") DO UPDATE SET "name" = EXCLUDED."name", "passwordHash" = EXCLUDED."passwordHash", "role" = EXCLUDED."role";\n`;
  }
  fs.writeFileSync(path.join(chunksDir, '01_categories_and_users.sql'), sql1);

  // Part 2: Tags
  let sql2 = `-- 2. Tags\n`;
  for (const t of tags) {
    sql2 += `INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES (${escapeSql(t.id)}, ${escapeSql(t.name)}, ${escapeSql(t.slug)}, ${escapeSql(t.color)}, to_timestamp(${t.createdAt ? t.createdAt / 1000 : 'extract(epoch from now())'}))
ON CONFLICT ("slug") DO NOTHING;\n`;
  }
  fs.writeFileSync(path.join(chunksDir, '02_tags.sql'), sql2);

  // Part 3: Documents chunked into sets of 10
  const docChunks = [];
  for (let i = 0; i < documents.length; i += 10) {
    docChunks.push(documents.slice(i, i + 10));
  }

  docChunks.forEach((chunk, idx) => {
    let sqlDoc = `-- Documents Part ${idx + 1}\n`;
    for (const d of chunk) {
      sqlDoc += `INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES (${escapeSql(d.id)}, ${escapeSql(d.title)}, ${escapeSql(d.slug)}, ${escapeSql(d.description)}, ${escapeSql(d.contentMarkdown)}, ${escapeSql(d.contentHtml)}, ${escapeSql(d.status)}, ${escapeSql(d.visibility)}, ${d.readingTimeMin || 1}, ${escapeSql(d.categoryId)}, ${escapeSql(d.authorId)}, to_timestamp(${d.createdAt ? d.createdAt / 1000 : 'extract(epoch from now())'}), to_timestamp(${d.updatedAt ? d.updatedAt / 1000 : 'extract(epoch from now())'}), ${d.publishedAt ? `to_timestamp(${d.publishedAt / 1000})` : 'NULL'}, ${d.deletedAt ? `to_timestamp(${d.deletedAt / 1000})` : 'NULL'})
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";\n`;
    }
    fs.writeFileSync(path.join(chunksDir, `03_notes_part_${idx + 1}.sql`), sqlDoc);
  });

  // Part 4: DocumentTags and Favorites
  let sqlRel = `-- Document Tags & Favorites\n`;
  for (const dt of documentTags) {
    sqlRel += `INSERT INTO "DocumentTag" ("id", "documentId", "tagId", "createdAt")
VALUES (${escapeSql(dt.id)}, ${escapeSql(dt.documentId)}, ${escapeSql(dt.tagId)}, to_timestamp(${dt.createdAt ? dt.createdAt / 1000 : 'extract(epoch from now())'}))
ON CONFLICT ("documentId", "tagId") DO NOTHING;\n`;
  }
  for (const f of favorites) {
    sqlRel += `INSERT INTO "Favorite" ("id", "userId", "documentId", "createdAt")
VALUES (${escapeSql(f.id)}, ${escapeSql(f.userId)}, ${escapeSql(f.documentId)}, to_timestamp(${f.createdAt ? f.createdAt / 1000 : 'extract(epoch from now())'}))
ON CONFLICT ("userId", "documentId") DO NOTHING;\n`;
  }
  fs.writeFileSync(path.join(chunksDir, '04_tags_mapping_and_favorites.sql'), sqlRel);

  console.log('Successfully created small bite-sized chunks in /supabase_chunks/ folder:');
  fs.readdirSync(chunksDir).forEach(f => {
    const sizeKb = (fs.statSync(path.join(chunksDir, f)).size / 1024).toFixed(1);
    console.log(`- ${f} (${sizeKb} KB)`);
  });
}

run();
