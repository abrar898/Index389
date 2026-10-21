const { DatabaseSync } = require('node:sqlite');
const path = require('path');
const { Client } = require('pg');

async function migrate() {
  const dbUrl = "postgresql://postgres.gueoryzpydjfmrfgqatu:sup3r-s3cur3-cyb3r-k3y-2026-prod@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true";
  
  console.log('Connecting to Supabase IPv4 Pooler at aws-0-ap-northeast-1.pooler.supabase.com:6543...');
  const pg = new Client({
    connectionString: dbUrl,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await pg.connect();
    console.log('CONNECTED TO SUPABASE!');
  } catch (err) {
    console.error('Failed to connect to Supabase:', err.message);
    process.exit(1);
  }

  const dbPath = path.join(__dirname, '..', 'prisma', 'dev.db');
  const sqlite = new DatabaseSync(dbPath);

  console.log('Reading local SQLite database...');
  const users = sqlite.prepare('SELECT * FROM User').all();
  const categories = sqlite.prepare('SELECT * FROM Category').all();
  const tags = sqlite.prepare('SELECT * FROM Tag').all();
  const documents = sqlite.prepare('SELECT * FROM Document').all();
  const documentTags = sqlite.prepare('SELECT * FROM DocumentTag').all();
  const favorites = sqlite.prepare('SELECT * FROM Favorite').all();

  console.log(`Exporting: ${categories.length} categories, ${users.length} users, ${tags.length} tags, ${documents.length} notes, ${documentTags.length} relations.`);

  try {
    // 1. Categories
    console.log('Inserting Categories...');
    for (const c of categories) {
      await pg.query(`
        INSERT INTO "Category" ("id", "name", "slug", "description", "icon", "color", "createdAt", "updatedAt")
        VALUES ($1, $2, $3, $4, $5, $6, to_timestamp($7), to_timestamp($8))
        ON CONFLICT ("slug") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon" = EXCLUDED."icon", "color" = EXCLUDED."color";
      `, [c.id, c.name, c.slug, c.description, c.icon, c.color, (c.createdAt || Date.now()) / 1000, (c.updatedAt || Date.now()) / 1000]);
    }

    // 2. Users
    console.log('Inserting Users...');
    for (const u of users) {
      await pg.query(`
        INSERT INTO "User" ("id", "email", "name", "passwordHash", "role", "avatarUrl", "createdAt", "updatedAt")
        VALUES ($1, $2, $3, $4, $5, $6, to_timestamp($7), to_timestamp($8))
        ON CONFLICT ("email") DO UPDATE SET "name" = EXCLUDED."name", "passwordHash" = EXCLUDED."passwordHash", "role" = EXCLUDED."role";
      `, [u.id, u.email, u.name, u.passwordHash, u.role, u.avatarUrl, (u.createdAt || Date.now()) / 1000, (u.updatedAt || Date.now()) / 1000]);
    }

    // 3. Tags
    console.log(`Inserting ${tags.length} Tags...`);
    for (const t of tags) {
      await pg.query(`
        INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
        VALUES ($1, $2, $3, $4, to_timestamp($5))
        ON CONFLICT ("slug") DO NOTHING;
      `, [t.id, t.name, t.slug, t.color, (t.createdAt || Date.now()) / 1000]);
    }

    // 4. Documents / Notes
    console.log(`Inserting ${documents.length} Notes...`);
    for (const d of documents) {
      await pg.query(`
        INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, to_timestamp($12), to_timestamp($13), $14, $15)
        ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
      `, [
        d.id, d.title, d.slug, d.description, d.contentMarkdown, d.contentHtml,
        d.status, d.visibility, d.readingTimeMin || 1, d.categoryId, d.authorId,
        (d.createdAt || Date.now()) / 1000, (d.updatedAt || Date.now()) / 1000,
        d.publishedAt ? new Date(d.publishedAt) : null,
        d.deletedAt ? new Date(d.deletedAt) : null
      ]);
    }

    // 5. Document Tags
    console.log(`Inserting ${documentTags.length} Document Tags...`);
    for (const dt of documentTags) {
      await pg.query(`
        INSERT INTO "DocumentTag" ("id", "documentId", "tagId", "createdAt")
        VALUES ($1, $2, $3, to_timestamp($4))
        ON CONFLICT ("documentId", "tagId") DO NOTHING;
      `, [dt.id, dt.documentId, dt.tagId, (dt.createdAt || Date.now()) / 1000]);
    }

    // 6. Favorites
    console.log('Inserting Favorites...');
    for (const f of favorites) {
      await pg.query(`
        INSERT INTO "Favorite" ("id", "userId", "documentId", "createdAt")
        VALUES ($1, $2, $3, to_timestamp($4))
        ON CONFLICT ("userId", "documentId") DO NOTHING;
      `, [f.id, f.userId, f.documentId, (f.createdAt || Date.now()) / 1000]);
    }

    console.log('\n======================================================');
    console.log('🎉 ALL DATA TRANSFERRED TO SUPABASE SUCCESSFULLY! 🎉');
    console.log('======================================================');
  } catch (err) {
    console.error('Migration error:', err);
  } finally {
    await pg.end();
  }
}

migrate();
