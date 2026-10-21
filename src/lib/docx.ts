import { Document, Paragraph, TextRun, HeadingLevel, Table, TableRow, TableCell, BorderStyle, WidthType, AlignmentType } from "docx";

interface DocxSection {
  type: "heading" | "paragraph" | "code" | "quote" | "list";
  level?: number;
  content: string;
  lang?: string;
}

export function parseMarkdownToDocxSections(markdown: string): DocxSection[] {
  const lines = markdown.split(/\r?\n/);
  const sections: DocxSection[] = [];
  let inCodeBlock = false;
  let codeBuffer: string[] = [];
  let codeLang = "";

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    if (line.startsWith("```")) {
      if (inCodeBlock) {
        sections.push({
          type: "code",
          content: codeBuffer.join("\n"),
          lang: codeLang,
        });
        codeBuffer = [];
        inCodeBlock = false;
      } else {
        inCodeBlock = true;
        codeLang = line.replace("```", "").trim();
      }
      continue;
    }

    if (inCodeBlock) {
      codeBuffer.push(line);
      continue;
    }

    if (line.startsWith("# ")) {
      sections.push({ type: "heading", level: 1, content: line.slice(2).trim() });
    } else if (line.startsWith("## ")) {
      sections.push({ type: "heading", level: 2, content: line.slice(3).trim() });
    } else if (line.startsWith("### ")) {
      sections.push({ type: "heading", level: 3, content: line.slice(4).trim() });
    } else if (line.startsWith("> ")) {
      sections.push({ type: "quote", content: line.slice(2).trim() });
    } else if (line.startsWith("- ") || line.startsWith("* ")) {
      sections.push({ type: "list", content: line.slice(2).trim() });
    } else if (line.trim().length > 0) {
      sections.push({ type: "paragraph", content: line.trim() });
    }
  }

  return sections;
}

export async function generateDocxBuffer(title: string, description: string, markdown: string): Promise<Buffer> {
  const sections = parseMarkdownToDocxSections(markdown);
  const children: (Paragraph | Table)[] = [];

  // Title Header
  children.push(
    new Paragraph({
      text: title,
      heading: HeadingLevel.TITLE,
      spacing: { after: 120, before: 100 },
    })
  );

  if (description) {
    children.push(
      new Paragraph({
        children: [
          new TextRun({
            text: description,
            italics: true,
            color: "555555",
            size: 22,
          }),
        ],
        spacing: { after: 240 },
      })
    );
  }

  for (const sec of sections) {
    if (sec.type === "heading") {
      let hl: (typeof HeadingLevel)[keyof typeof HeadingLevel] = HeadingLevel.HEADING_1;
      if (sec.level === 2) hl = HeadingLevel.HEADING_2;
      if (sec.level === 3) hl = HeadingLevel.HEADING_3;

      children.push(
        new Paragraph({
          text: sec.content,
          heading: hl,
          spacing: { before: 240, after: 120 },
        })
      );
    } else if (sec.type === "quote") {
      children.push(
        new Paragraph({
          children: [
            new TextRun({
              text: `[NOTE] ${sec.content}`,
              italics: true,
              color: "107C41",
            }),
          ],
          indent: { left: 720 },
          spacing: { before: 120, after: 120 },
        })
      );
    } else if (sec.type === "list") {
      children.push(
        new Paragraph({
          children: [new TextRun({ text: `• ${sec.content}` })],
          indent: { left: 360 },
          spacing: { before: 60, after: 60 },
        })
      );
    } else if (sec.type === "code") {
      // Create a styled monospace code table block
      const codeLines = sec.content.split("\n");
      children.push(
        new Table({
          width: { size: 100, type: WidthType.PERCENTAGE },
          borders: {
            top: { style: BorderStyle.SINGLE, size: 1, color: "333333" },
            bottom: { style: BorderStyle.SINGLE, size: 1, color: "333333" },
            left: { style: BorderStyle.SINGLE, size: 12, color: "9FEF00" },
            right: { style: BorderStyle.SINGLE, size: 1, color: "333333" },
          },
          rows: [
            new TableRow({
              children: [
                new TableCell({
                  shading: { fill: "F3F4F6" },
                  children: codeLines.map(
                    (cl) =>
                      new Paragraph({
                        children: [
                          new TextRun({
                            text: cl || " ",
                            font: "Consolas",
                            size: 19,
                            color: "111827",
                          }),
                        ],
                        spacing: { before: 30, after: 30 },
                      })
                  ),
                }),
              ],
            }),
          ],
        })
      );
      children.push(new Paragraph({ text: "", spacing: { after: 120 } }));
    } else {
      children.push(
        new Paragraph({
          children: [new TextRun({ text: sec.content, size: 22 })],
          spacing: { after: 120 },
        })
      );
    }
  }

  const doc = new Document({
    sections: [
      {
        properties: {},
        children,
      },
    ],
  });

  const { Packer } = await import("docx");
  return Packer.toBuffer(doc);
}
