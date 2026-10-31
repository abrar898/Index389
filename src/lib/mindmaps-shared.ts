export interface MindmapItem {
  id: string;
  slug: string;
  title: string;
  description: string;
  category: string;
  tags: string[];
  htmlContent: string;
  nodeCount: number;
  phaseCount: number;
  commandCount: number;
  createdAt: string;
  updatedAt: string;
  isDefault?: boolean;
}

export type MindmapSummary = Omit<MindmapItem, "htmlContent">;

export interface MindmapInput {
  title: string;
  slug?: string;
  description?: string;
  category?: string;
  tags?: string[];
  htmlContent: string;
}

export function extractMindmapStats(html: string) {
  // Count items, phases, and commands from the HTML code
  const nodeMatches = html.match(/id:\s*['"][a-zA-Z0-9_-]+['"]/g) || [];
  const phaseMatches = html.match(/PHASE\s+\d+|Phase\s+\d+/gi) || [];
  const cmdMatches = html.match(/\bc\s*\(\s*['"][^'"]+['"]\s*,\s*['"]/g) || [];

  return {
    nodeCount: Math.max(nodeMatches.length, 1),
    phaseCount: Math.max(new Set(phaseMatches.map((p) => p.toUpperCase())).size, 1),
    commandCount: Math.max(cmdMatches.length, 0),
  };
}

export function generateSlug(title: string): string {
  return title
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, "")
    .replace(/\s+/g, "-")
    .replace(/-+/g, "-");
}

// Starter Mindmap Templates for user to quickly create new ones
export const MINDMAP_TEMPLATES = [
  {
    id: "interactive-canvas",
    name: "Interactive Canvas Map (Draggable & Connected)",
    description: "Multi-node draggable mindmap with auto SVG elbow connectors, zoom & pan.",
    html: `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Interactive Security Mindmap</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{width:100vw;height:100vh;overflow:hidden;background:#070b13;color:#e2e8f0;font-family:'Segoe UI',system-ui,sans-serif}
#toolbar{position:fixed;top:0;left:0;right:0;height:48px;background:#0f172a;border-bottom:1px solid #1e293b;z-index:9999;display:flex;align-items:center;gap:12px;padding:0 16px}
#toolbar h1{font-size:14px;font-weight:700;color:#9fef00;letter-spacing:1px}
#toolbar button{background:#1e293b;border:1px solid #334155;color:#f8fafc;padding:5px 12px;border-radius:6px;cursor:pointer;font-size:12px;transition:0.2s}
#toolbar button:hover{background:#334155}
#cv{position:fixed;top:48px;left:0;right:0;bottom:0;overflow:hidden;cursor:grab}
#cv.panning{cursor:grabbing}
#wd{position:absolute;transform-origin:0 0}
svg#lines{position:absolute;top:0;left:0;pointer-events:none;z-index:0}
.nd{position:absolute;background:#0f172a;border:1px solid #334155;border-left:4px solid #9fef00;border-radius:8px;padding:12px;min-width:220px;box-shadow:0 8px 24px rgba(0,0,0,0.6);z-index:10}
.nd-hd{font-weight:700;font-size:13px;color:#9fef00;cursor:move;user-select:none;margin-bottom:8px}
.nd-item{font-size:12px;color:#94a3b8;padding:4px 0;border-bottom:1px solid #1e293b}
.nd-item code{color:#38bdf8;background:#0284c71a;padding:2px 4px;border-radius:4px;font-family:monospace}
</style>
</head>
<body>
<div id="toolbar">
  <h1>RESEARCH MAP</h1>
  <button onclick="resetView()">Reset View</button>
  <span style="font-size:11px;color:#64748b">Drag headers to move nodes · Drag canvas to pan · Scroll to zoom</span>
</div>
<div id="cv">
  <div id="wd">
    <svg id="lines" width="4000" height="4000"></svg>
    <div class="nd" id="n1" style="left:80px;top:80px">
      <div class="nd-hd">Phase 1: Discovery</div>
      <div class="nd-item">Passive DNS & WHOIS</div>
      <div class="nd-item">Port Scanning <code>nmap -sV</code></div>
    </div>
    <div class="nd" id="n2" style="left:380px;top:80px">
      <div class="nd-hd" style="color:#38bdf8">Phase 2: Enumeration</div>
      <div class="nd-item">Directory Fuzzing <code>ffuf</code></div>
      <div class="nd-item">Service Fingerprinting</div>
    </div>
    <div class="nd" id="n3" style="left:680px;top:80px">
      <div class="nd-hd" style="color:#f43f5e">Phase 3: Exploitation</div>
      <div class="nd-item">Initial Access Web Shell</div>
      <div class="nd-item">Privilege Escalation</div>
    </div>
  </div>
</div>
<script>
const cv=document.getElementById('cv'), wd=document.getElementById('wd'), svg=document.getElementById('lines');
let tx=0,ty=0,scale=1,panning=false,px=0,py=0;
function update(){wd.style.transform=\`translate(\${tx}px,\${ty}px) scale(\${scale})\`}
cv.addEventListener('mousedown',e=>{if(e.target.closest('.nd')||e.target.closest('#toolbar'))return;panning=true;px=e.clientX;py=e.clientY;cv.classList.add('panning')});
document.addEventListener('mousemove',e=>{if(!panning)return;tx+=e.clientX-px;ty+=e.clientY-py;px=e.clientX;py=e.clientY;update()});
document.addEventListener('mouseup',()=>{panning=false;cv.classList.remove('panning')});
cv.addEventListener('wheel',e=>{e.preventDefault();const d=e.deltaY>0?0.9:1.1;scale=Math.max(0.2,Math.min(2.5,scale*d));update()},{passive:false});
function resetView(){tx=40;ty=40;scale=1;update()}

// Draggable nodes
document.querySelectorAll('.nd').forEach(el=>{
  const hd=el.querySelector('.nd-hd');
  let drag=false,ox=0,oy=0;
  hd.addEventListener('mousedown',e=>{
    e.stopPropagation();drag=true;
    ox=(e.clientX-tx)/scale-el.offsetLeft;
    oy=(e.clientY-ty)/scale-el.offsetTop;
    const onMove=e=>{
      if(!drag)return;
      el.style.left=((e.clientX-tx)/scale-ox)+'px';
      el.style.top=((e.clientY-ty)/scale-oy)+'px';
      drawLines();
    };
    const onUp=()=>{drag=false;document.removeEventListener('mousemove',onMove);document.removeEventListener('mouseup',onUp)};
    document.addEventListener('mousemove',onMove);document.addEventListener('mouseup',onUp);
  });
});

function drawLines(){
  svg.innerHTML='';
  const pairs=[['n1','n2'],['n2','n3']];
  pairs.forEach(([id1,id2])=>{
    const e1=document.getElementById(id1), e2=document.getElementById(id2);
    if(!e1||!e2)return;
    const x1=e1.offsetLeft+e1.offsetWidth, y1=e1.offsetTop+30;
    const x2=e2.offsetLeft, y2=e2.offsetTop+30;
    const path=document.createElementNS('http://www.w3.org/2000/svg','path');
    path.setAttribute('d',\`M \${x1} \${y1} C \${x1+60} \${y1}, \${x2-60} \${y2}, \${x2} \${y2}\`);
    path.setAttribute('stroke','#334155');
    path.setAttribute('stroke-width','2');
    path.setAttribute('fill','none');
    svg.appendChild(path);
  });
}
drawLines();
</script>
</body>
</html>`,
  },
  {
    id: "cheat-sheet-tree",
    name: "Modern Tree Cheat Sheet",
    description: "Hierarchical collapsible tree mindmap with search and copyable terminal snippets.",
    html: `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Security Attack Tree</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{background:#0b121e;color:#cbd5e1;font-family:'Segoe UI',sans-serif;padding:30px}
h1{color:#9fef00;font-size:22px;margin-bottom:20px;display:flex;align-items:center;gap:10px}
.tree{display:flex;flex-direction:column;gap:16px;max-width:900px;margin:0 auto}
.branch{background:#111d30;border:1px solid #1f3352;border-radius:12px;overflow:hidden}
.branch-hd{background:#14233c;padding:12px 18px;font-weight:700;color:#f8fafc;cursor:pointer;display:flex;justify-content:space-between;align-items:center}
.branch-hd:hover{background:#182844}
.branch-body{padding:14px 18px;display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:12px}
.leaf{background:#070b13;border:1px solid #1e293b;border-radius:8px;padding:10px}
.leaf-title{font-size:12px;font-weight:600;color:#38bdf8;margin-bottom:6px}
.cmd{background:#020617;color:#9fef00;padding:6px 10px;border-radius:6px;font-family:monospace;font-size:11px;cursor:pointer;display:flex;justify-content:space-between;align-items:center}
.cmd:hover{background:#0f172a}
</style>
</head>
<body>
<h1>🌿 PENETRATION TESTING TREE</h1>
<div class="tree">
  <div class="branch">
    <div class="branch-hd">🌐 Web Application Exploitation <span>▼</span></div>
    <div class="branch-body">
      <div class="leaf">
        <div class="leaf-title">SQL Injection (UNION)</div>
        <div class="cmd" onclick="navigator.clipboard.writeText(this.innerText)">' UNION SELECT 1,2,3-- -</div>
      </div>
      <div class="leaf">
        <div class="leaf-title">Local File Inclusion (LFI)</div>
        <div class="cmd" onclick="navigator.clipboard.writeText(this.innerText)">/../../../../etc/passwd</div>
      </div>
    </div>
  </div>
  <div class="branch">
    <div class="branch-hd">🛡 Active Directory Enumeration <span>▼</span></div>
    <div class="branch-body">
      <div class="leaf">
        <div class="leaf-title">Kerberoasting</div>
        <div class="cmd" onclick="navigator.clipboard.writeText(this.innerText)">impacket-GetUserSPNs -request DOMAIN/user:pass</div>
      </div>
      <div class="leaf">
        <div class="leaf-title">AS-REP Roasting</div>
        <div class="cmd" onclick="navigator.clipboard.writeText(this.innerText)">impacket-GetNPUsers DOMAIN/ -no-pass -usersfile users.txt</div>
      </div>
    </div>
  </div>
</div>
</body>
</html>`,
  },
];
