-- 2. Tags
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvcr40et0005idhkk1yo23s2', 'linux', 'linux', '#06b6d4', to_timestamp(1792262993.429))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvcr40ey0006idhk1z1g0xn2', 'privesc', 'privesc', '#06b6d4', to_timestamp(1792262993.434))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvcr40f40007idhksu8650qu', 'enumeration', 'enumeration', '#06b6d4', to_timestamp(1792262993.44))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvcr40f90008idhkjqurrmlm', 'nmap', 'nmap', '#06b6d4', to_timestamp(1792262993.445))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvcr40ff0009idhkbi07hz1u', 'recon', 'recon', '#06b6d4', to_timestamp(1792262993.451))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvcr40fm000aidhkf3ektk2s', 'web', 'web', '#06b6d4', to_timestamp(1792262993.458))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvcr40fu000bidhki4atof99', 'sqli', 'sqli', '#06b6d4', to_timestamp(1792262993.466))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvcr40g3000cidhkple1l3y8', 'ad', 'ad', '#06b6d4', to_timestamp(1792262993.476))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvcryyuj0004idr036zfl7ct', 'http verb tampering', 'http verb tampering', '#06b6d4', to_timestamp(1792264437.739))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvcryyv30007idr0mtr2harg', 'idor', 'idor', '#06b6d4', to_timestamp(1792264437.759))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvcryyvw000aidr0yj2hs59y', 'xxe', 'xxe', '#06b6d4', to_timestamp(1792264437.788))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74eln0005idi4t43i7nmc', 'kerberoasting', 'kerberoasting', '#06b6d4', to_timestamp(1792350351.852))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74em50008idi44ka5hym7', 'llmnr/nbt-ns poisoning', 'llmnr/nbt-ns poisoning', '#06b6d4', to_timestamp(1792350351.869))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74emn000bidi4p4jxtypt', 'asreproasting', 'asreproasting', '#06b6d4', to_timestamp(1792350351.887))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74en5000eidi4nr6fw35h', 'dcsync', 'dcsync', '#06b6d4', to_timestamp(1792350351.905))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74enl000hidi4ygn5w251', 'bloodhound', 'bloodhound', '#06b6d4', to_timestamp(1792350351.921))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74eo1000kidi4gy0x470m', 'responder', 'responder', '#06b6d4', to_timestamp(1792350351.937))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74eoi000nidi4ut1bl2cd', 'crackmapexec', 'crackmapexec', '#06b6d4', to_timestamp(1792350351.954))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74eoy000qidi4cdoi8kvg', 'impacket', 'impacket', '#06b6d4', to_timestamp(1792350351.971))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74epg000tidi48yp7afyj', 'powerview', 'powerview', '#06b6d4', to_timestamp(1792350351.988))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74epw000widi4acvl19pf', 'mimikatz', 'mimikatz', '#06b6d4', to_timestamp(1792350352.004))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74eqc000zidi4lgewd92w', 'rubeus', 'rubeus', '#06b6d4', to_timestamp(1792350352.02))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74eqt0012idi4zhyydbs6', 'password spraying', 'password spraying', '#06b6d4', to_timestamp(1792350352.037))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74er90015idi4l9dbea0j', 'acl abuse', 'acl abuse', '#06b6d4', to_timestamp(1792350352.053))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74erp0018idi4llf3okld', 'domain trusts', 'domain trusts', '#06b6d4', to_timestamp(1792350352.07))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74es5001bidi4cvcn0jtc', 'ldap', 'ldap', '#06b6d4', to_timestamp(1792350352.085))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74esl001eidi444okqe2r', 'smb', 'smb', '#06b6d4', to_timestamp(1792350352.102))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74et1001hidi4jwvt629n', 'active directory', 'active directory', '#06b6d4', to_timestamp(1792350352.117))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74etr001nidi4lujh4mtr', 'lateral movement', 'lateral movement', '#06b6d4', to_timestamp(1792350352.143))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74ev1001qidi4hwg9sl93', 'cve-2021-42278', 'cve-2021-42278', '#06b6d4', to_timestamp(1792350352.189))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74evi001tidi45qyyiy8z', 'cve-2021-34527', 'cve-2021-34527', '#06b6d4', to_timestamp(1792350352.207))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74ew2001widi4bvxcmht9', 'cve-2021-36942', 'cve-2021-36942', '#06b6d4', to_timestamp(1792350352.226))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74ewh001zidi4jeap5k74', 'cpts', 'cpts', '#06b6d4', to_timestamp(1792350352.242))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve74ewz0022idi47bry3auc', 'penetration testing', 'penetration testing', '#06b6d4', to_timestamp(1792350352.259))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve77oot002cidi47clhr4n3', 'network enumeration', 'network enumeration', '#06b6d4', to_timestamp(1792350504.893))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve77op9002fidi4hux90dzv', 'host discovery', 'host discovery', '#06b6d4', to_timestamp(1792350504.909))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve77opp002iidi4y0qtf8ow', 'port scanning', 'port scanning', '#06b6d4', to_timestamp(1792350504.926))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve77oq6002lidi4v7k2tmy3', 'service enumeration', 'service enumeration', '#06b6d4', to_timestamp(1792350504.943))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve77oqn002oidi489pmd3y4', 'nse', 'nse', '#06b6d4', to_timestamp(1792350504.959))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve77or3002ridi4xgirdenv', 'scripting engine', 'scripting engine', '#06b6d4', to_timestamp(1792350504.975))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve77ork002uidi4htz2kbnn', 'firewall evasion', 'firewall evasion', '#06b6d4', to_timestamp(1792350504.992))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve77os2002xidi4jppyeed8', 'ids evasion', 'ids evasion', '#06b6d4', to_timestamp(1792350505.01))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve77osk0030idi4tt4xsr9o', 'ips evasion', 'ips evasion', '#06b6d4', to_timestamp(1792350505.028))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve77ott0039idi4jel3b39l', 'htb academy', 'htb academy', '#06b6d4', to_timestamp(1792350505.074))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve77oul003fidi4m9zgw9oc', 'penetration testinglinux', 'penetration testinglinux', '#06b6d4', to_timestamp(1792350505.101))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7anwi003pidi4hcn0ybq8', 'ffuf', 'ffuf', '#06b6d4', to_timestamp(1792350643.842))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7anx1003sidi4m4jl2dx6', 'web fuzzing', 'web fuzzing', '#06b6d4', to_timestamp(1792350643.861))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7anxi003vidi4hbol13sd', 'directory fuzzing', 'directory fuzzing', '#06b6d4', to_timestamp(1792350643.878))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7anxz003yidi4v2loqt91', 'page fuzzing', 'page fuzzing', '#06b6d4', to_timestamp(1792350643.895))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7anyf0041idi4xndhxsrf', 'recursive fuzzing', 'recursive fuzzing', '#06b6d4', to_timestamp(1792350643.912))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7anyw0044idi49i37asnv', 'subdomain fuzzing', 'subdomain fuzzing', '#06b6d4', to_timestamp(1792350643.928))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7anzf0047idi4mmg8kaa1', 'vhost fuzzing', 'vhost fuzzing', '#06b6d4', to_timestamp(1792350643.947))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7anzu004aidi4fhkwtf55', 'parameter fuzzing', 'parameter fuzzing', '#06b6d4', to_timestamp(1792350643.963))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ao0a004didi44btcfq5r', 'get fuzzing', 'get fuzzing', '#06b6d4', to_timestamp(1792350643.978))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ao0r004gidi4y6kr151f', 'post fuzzing', 'post fuzzing', '#06b6d4', to_timestamp(1792350643.995))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ao17004jidi45ftertrf', 'value fuzzing', 'value fuzzing', '#06b6d4', to_timestamp(1792350644.012))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ao1n004midi4fomb7jae', 'dns', 'dns', '#06b6d4', to_timestamp(1792350644.028))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ao23004pidi4wvqi4n03', 'wordlists', 'wordlists', '#06b6d4', to_timestamp(1792350644.043))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ao2j004sidi4xeftgti1', 'web enumeration', 'web enumeration', '#06b6d4', to_timestamp(1792350644.059))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3m5005eidi4wid1cger', 'lfi', 'lfi', '#06b6d4', to_timestamp(1792351037.454))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3mm005hidi4luvcj306', 'rfi', 'rfi', '#06b6d4', to_timestamp(1792351037.471))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3n6005kidi432j2b4go', 'file inclusion', 'file inclusion', '#06b6d4', to_timestamp(1792351037.49))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3nm005nidi4075k11r0', 'path traversal', 'path traversal', '#06b6d4', to_timestamp(1792351037.506))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3o3005qidi4705q17vc', 'php wrappers', 'php wrappers', '#06b6d4', to_timestamp(1792351037.523))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3ol005tidi484zsuvzj', 'php filters', 'php filters', '#06b6d4', to_timestamp(1792351037.542))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3p2005widi4o6pmz990', 'log poisoning', 'log poisoning', '#06b6d4', to_timestamp(1792351037.558))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3pi005zidi4e170a4c4', 'php session poisoning', 'php session poisoning', '#06b6d4', to_timestamp(1792351037.574))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3py0062idi4tuxcjl6t', 'null bytes', 'null bytes', '#06b6d4', to_timestamp(1792351037.59))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3qd0065idi43vcen63y', 'encoding bypass', 'encoding bypass', '#06b6d4', to_timestamp(1792351037.605))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3qu0068idi47c43ccks', 'zip upload', 'zip upload', '#06b6d4', to_timestamp(1792351037.622))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3rc006bidi489unbwhz', 'phar upload', 'phar upload', '#06b6d4', to_timestamp(1792351037.64))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3rs006eidi4cy1seq53', 'data wrapper', 'data wrapper', '#06b6d4', to_timestamp(1792351037.656))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3s8006hidi4zd10drbq', 'input wrapper', 'input wrapper', '#06b6d4', to_timestamp(1792351037.673))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3sn006kidi4itzhgjv8', 'expect wrapper', 'expect wrapper', '#06b6d4', to_timestamp(1792351037.687))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3t2006nidi42dkg06f6', 'source code disclosure', 'source code disclosure', '#06b6d4', to_timestamp(1792351037.702))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7j3ti006qidi47tp9xcww', 'web vulnerabilities', 'web vulnerabilities', '#06b6d4', to_timestamp(1792351037.718))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lvt2007cidi4i64f7th2', 'file transfers', 'file transfers', '#06b6d4', to_timestamp(1792351167.302))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lvti007fidi4sr3ivuwi', 'powershell', 'powershell', '#06b6d4', to_timestamp(1792351167.319))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lvud007lidi4bwqf0ygz', 'ftp', 'ftp', '#06b6d4', to_timestamp(1792351167.349))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lvuw007oidi427kcopnb', 'scp', 'scp', '#06b6d4', to_timestamp(1792351167.369))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lvvf007ridi4oc8ufhu6', 'ssh', 'ssh', '#06b6d4', to_timestamp(1792351167.387))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lvvx007uidi46hbds6p1', 'wget', 'wget', '#06b6d4', to_timestamp(1792351167.405))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lvwe007xidi4gbnevpmc', 'curl', 'curl', '#06b6d4', to_timestamp(1792351167.422))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lvwu0080idi4kd4s26om', 'netcat', 'netcat', '#06b6d4', to_timestamp(1792351167.439))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lvxb0083idi48uwvb3fl', 'ncat', 'ncat', '#06b6d4', to_timestamp(1792351167.456))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lvxs0086idi4qjk4twfu', 'rdp', 'rdp', '#06b6d4', to_timestamp(1792351167.472))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lvya0089idi4gkd7g2jq', 'base64', 'base64', '#06b6d4', to_timestamp(1792351167.49))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lvyr008cidi46motitrb', 'fileless', 'fileless', '#06b6d4', to_timestamp(1792351167.508))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lvz8008fidi4k5t3difk', 'python', 'python', '#06b6d4', to_timestamp(1792351167.524))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lvzp008iidi4ele9de4j', 'php', 'php', '#06b6d4', to_timestamp(1792351167.541))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lw06008lidi43ud32axo', 'ruby', 'ruby', '#06b6d4', to_timestamp(1792351167.558))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lw0n008oidi4o5j6x7na', 'perl', 'perl', '#06b6d4', to_timestamp(1792351167.576))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lw15008ridi4ulncgtw1', 'javascript', 'javascript', '#06b6d4', to_timestamp(1792351167.593))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lw1o008uidi4mmaaydmk', 'vbscript', 'vbscript', '#06b6d4', to_timestamp(1792351167.612))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lw25008xidi41ebc3y5x', 'lolbins', 'lolbins', '#06b6d4', to_timestamp(1792351167.629))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lw2m0090idi4xvsy4u6t', 'gtfobins', 'gtfobins', '#06b6d4', to_timestamp(1792351167.647))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lw320093idi4pabe1h04', 'lolbas', 'lolbas', '#06b6d4', to_timestamp(1792351167.663))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lw3i0096idi4shk0798a', 'openssl', 'openssl', '#06b6d4', to_timestamp(1792351167.678))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lw3y0099idi4gc8kp7xv', 'nginx', 'nginx', '#06b6d4', to_timestamp(1792351167.695))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lw4e009cidi4ezgionau', 'encryption', 'encryption', '#06b6d4', to_timestamp(1792351167.71))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lw4u009fidi4gykb8bsi', 'user agent evasion', 'user agent evasion', '#06b6d4', to_timestamp(1792351167.726))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lw5a009iidi4z6y8g102', 'living off the land', 'living off the land', '#06b6d4', to_timestamp(1792351167.742))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7lw5q009lidi44fr74wr2', 'windows', 'windows', '#06b6d4', to_timestamp(1792351167.758))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofin00a4idi4f0zu2kcd', 'brute forcing', 'brute forcing', '#06b6d4', to_timestamp(1792351286.16))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofj600a7idi4l2a4o24t', 'hydra', 'hydra', '#06b6d4', to_timestamp(1792351286.178))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofjm00aaidi4j62f1xvb', 'medusa', 'medusa', '#06b6d4', to_timestamp(1792351286.194))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofk300adidi4r6zo1ywz', 'password cracking', 'password cracking', '#06b6d4', to_timestamp(1792351286.211))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofkj00agidi4mdzu85kt', 'dictionary attack', 'dictionary attack', '#06b6d4', to_timestamp(1792351286.228))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofl200ajidi4lr3849bq', 'hybrid attack', 'hybrid attack', '#06b6d4', to_timestamp(1792351286.246))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7oflj00amidi4i5qdkl0z', 'credential stuffing', 'credential stuffing', '#06b6d4', to_timestamp(1792351286.263))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofmb00asidi40dvy7mfe', 'cupp', 'cupp', '#06b6d4', to_timestamp(1792351286.292))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofmr00avidi4iwhxja02', 'username anarchy', 'username anarchy', '#06b6d4', to_timestamp(1792351286.307))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofn700ayidi4nlqi7sq6', 'http basic auth', 'http basic auth', '#06b6d4', to_timestamp(1792351286.323))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofnn00b1idi4vam2aqfq', 'login forms', 'login forms', '#06b6d4', to_timestamp(1792351286.339))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofp300bdidi4zw4zi7c2', 'web services', 'web services', '#06b6d4', to_timestamp(1792351286.391))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofpj00bgidi4o9565oas', 'password policy', 'password policy', '#06b6d4', to_timestamp(1792351286.408))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofq000bjidi4tu4b7ija', 'default credentials', 'default credentials', '#06b6d4', to_timestamp(1792351286.425))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofqi00bmidi4k856e1u5', 'http-post-form', 'http-post-form', '#06b6d4', to_timestamp(1792351286.442))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7ofqy00bpidi4miwpf69m', 'burp suite', 'burp suite', '#06b6d4', to_timestamp(1792351286.459))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qetb00c8idi405tovofy', 'metasploit', 'metasploit', '#06b6d4', to_timestamp(1792351378.56))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qett00cbidi4znmjqrd8', 'msfconsole', 'msfconsole', '#06b6d4', to_timestamp(1792351378.577))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qeub00ceidi4pu6gobfj', 'msfvenom', 'msfvenom', '#06b6d4', to_timestamp(1792351378.595))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qeuq00chidi4m6xranj3', 'meterpreter', 'meterpreter', '#06b6d4', to_timestamp(1792351378.611))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qev700ckidi4hq2k98kl', 'payloads', 'payloads', '#06b6d4', to_timestamp(1792351378.628))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qevp00cnidi4p51yv0ph', 'encoders', 'encoders', '#06b6d4', to_timestamp(1792351378.645))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qew400cqidi4ljh2fgf8', 'exploits', 'exploits', '#06b6d4', to_timestamp(1792351378.66))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qewj00ctidi4cq9pwj0p', 'modules', 'modules', '#06b6d4', to_timestamp(1792351378.676))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qewy00cwidi40pkjxj68', 'stagers', 'stagers', '#06b6d4', to_timestamp(1792351378.691))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qexe00czidi4oas9k7fo', 'stages', 'stages', '#06b6d4', to_timestamp(1792351378.707))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qexu00d2idi4jobn2bza', 'sessions', 'sessions', '#06b6d4', to_timestamp(1792351378.723))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qeyb00d5idi4fl0n4n5p', 'plugins', 'plugins', '#06b6d4', to_timestamp(1792351378.74))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qeys00d8idi40x3nemk0', 'mixins', 'mixins', '#06b6d4', to_timestamp(1792351378.756))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qez700dbidi4uu58vtew', 'postgresql', 'postgresql', '#06b6d4', to_timestamp(1792351378.772))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qezn00deidi4izwsrxet', 'workspaces', 'workspaces', '#06b6d4', to_timestamp(1792351378.787))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qf1d00dtidi4r6aeodae', 'packers', 'packers', '#06b6d4', to_timestamp(1792351378.849))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qf1s00dwidi4pnugc6lo', 'shellcode', 'shellcode', '#06b6d4', to_timestamp(1792351378.864))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qf2800dzidi4aq48bbbu', 'reverse shell', 'reverse shell', '#06b6d4', to_timestamp(1792351378.88))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7qf2n00e2idi4ltt8b29s', 'local exploit suggester', 'local exploit suggester', '#06b6d4', to_timestamp(1792351378.896))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7sldf00eridi44jajfgrt', 'owasp zap', 'owasp zap', '#06b6d4', to_timestamp(1792351480.371))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7sldu00euidi4ahz1kbup', 'web proxies', 'web proxies', '#06b6d4', to_timestamp(1792351480.387))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7sleb00exidi438sar70h', 'intercept', 'intercept', '#06b6d4', to_timestamp(1792351480.404))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7sler00f0idi44nqf7ufw', 'repeater', 'repeater', '#06b6d4', to_timestamp(1792351480.419))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7slf800f3idi4nhaoprxw', 'intruder', 'intruder', '#06b6d4', to_timestamp(1792351480.436))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7slfo00f6idi41u0apx3z', 'zap fuzzer', 'zap fuzzer', '#06b6d4', to_timestamp(1792351480.453))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7slg500f9idi4iz3yzian', 'burp scanner', 'burp scanner', '#06b6d4', to_timestamp(1792351480.469))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7slgl00fcidi44wjaf22q', 'zap scanner', 'zap scanner', '#06b6d4', to_timestamp(1792351480.486))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7slh400ffidi4rywyan9r', 'foxyproxy', 'foxyproxy', '#06b6d4', to_timestamp(1792351480.504))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7slhl00fiidi4xxzkjirz', 'proxychains', 'proxychains', '#06b6d4', to_timestamp(1792351480.522))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7sli200flidi4gq94brik', 'ca certificate', 'ca certificate', '#06b6d4', to_timestamp(1792351480.538))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7slij00foidi4qcd8ms1j', 'url encoding', 'url encoding', '#06b6d4', to_timestamp(1792351480.556))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7slj000fridi4rsdp1e1y', 'match and replace', 'match and replace', '#06b6d4', to_timestamp(1792351480.572))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7sljf00fuidi48vlpi7x7', 'zap replacer', 'zap replacer', '#06b6d4', to_timestamp(1792351480.587))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7sljv00fxidi4qfsul4fo', 'spider', 'spider', '#06b6d4', to_timestamp(1792351480.603))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7slkb00g0idi4iwcbkruy', 'crawler', 'crawler', '#06b6d4', to_timestamp(1792351480.62))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7slkt00g3idi4b6pyc8x8', 'active scanner', 'active scanner', '#06b6d4', to_timestamp(1792351480.637))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7sll900g6idi43k0q5a19', 'passive scanner', 'passive scanner', '#06b6d4', to_timestamp(1792351480.653))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7sllo00g9idi4zybxowjv', 'bapp store', 'bapp store', '#06b6d4', to_timestamp(1792351480.668))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7slm300gcidi4zug0w802', 'zap marketplace', 'zap marketplace', '#06b6d4', to_timestamp(1792351480.683))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7slmv00giidi4rmno8ufa', 'web application testing', 'web application testing', '#06b6d4', to_timestamp(1792351480.712))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uezc00gyidi45tz4xpz5', 'vulnerability assessment', 'vulnerability assessment', '#06b6d4', to_timestamp(1792351565.4))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uezt00h1idi4uznj97kc', 'nessus', 'nessus', '#06b6d4', to_timestamp(1792351565.417))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf0800h4idi423n6xhhv', 'openvas', 'openvas', '#06b6d4', to_timestamp(1792351565.432))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf0o00h7idi4vipz1eol', 'cvss', 'cvss', '#06b6d4', to_timestamp(1792351565.448))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf1400haidi41omz66rh', 'cve', 'cve', '#06b6d4', to_timestamp(1792351565.464))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf1i00hdidi4gq09h1ae', 'oval', 'oval', '#06b6d4', to_timestamp(1792351565.479))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf1z00hgidi4cr133b1z', 'responsible disclosure', 'responsible disclosure', '#06b6d4', to_timestamp(1792351565.495))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf2f00hjidi4mh76ilkm', 'asset management', 'asset management', '#06b6d4', to_timestamp(1792351565.512))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf2w00hmidi4uqt98uzl', 'compliance', 'compliance', '#06b6d4', to_timestamp(1792351565.528))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf3d00hpidi4ynqk0e3e', 'pci-dss', 'pci-dss', '#06b6d4', to_timestamp(1792351565.545))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf3v00hsidi4y0vqo1rb', 'ptes', 'ptes', '#06b6d4', to_timestamp(1792351565.563))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf4b00hvidi4q0qxrp6s', 'owasp', 'owasp', '#06b6d4', to_timestamp(1792351565.579))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf4s00hyidi4gb3gpnrn', 'scan policies', 'scan policies', '#06b6d4', to_timestamp(1792351565.596))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf5700i1idi491r4j8sb', 'nessus plugins', 'nessus plugins', '#06b6d4', to_timestamp(1792351565.612))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf5m00i4idi4cj5y3g5c', 'credentialed scanning', 'credentialed scanning', '#06b6d4', to_timestamp(1792351565.627))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf6200i7idi48srmi7ha', 'vulnerability scanning', 'vulnerability scanning', '#06b6d4', to_timestamp(1792351565.642))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf6h00iaidi4ptw73i5l', 'reporting', 'reporting', '#06b6d4', to_timestamp(1792351565.658))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf6y00ididi420ms947m', 'executive summary', 'executive summary', '#06b6d4', to_timestamp(1792351565.674))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve7uf7e00igidi457kzip0p', 'risk scoring', 'risk scoring', '#06b6d4', to_timestamp(1792351565.69))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve833zh00iwidi40zoi612j', 'command injection', 'command injection', '#06b6d4', to_timestamp(1792351971.054))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve833zy00izidi4cvr1vaju', 'os command injection', 'os command injection', '#06b6d4', to_timestamp(1792351971.07))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8341200j8idi4du9p07hi', 'filter bypass', 'filter bypass', '#06b6d4', to_timestamp(1792351971.11))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8341j00jbidi4lwca0fcu', 'blacklist evasion', 'blacklist evasion', '#06b6d4', to_timestamp(1792351971.127))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8342000jeidi44jm7tq3x', 'bashfuscator', 'bashfuscator', '#06b6d4', to_timestamp(1792351971.145))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8342i00jhidi4fwqe6b6a', 'dosfuscation', 'dosfuscation', '#06b6d4', to_timestamp(1792351971.162))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8342z00jkidi4ud7mvwxv', 'base64 obfuscation', 'base64 obfuscation', '#06b6d4', to_timestamp(1792351971.179))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8344000jtidi4pdqbgu0l', 'nodejs', 'nodejs', '#06b6d4', to_timestamp(1792351971.216))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8344r00jzidi4501s6s0t', 'windows cmd', 'windows cmd', '#06b6d4', to_timestamp(1792351971.243))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8345h00k5idi430m6vuax', 'bash', 'bash', '#06b6d4', to_timestamp(1792351971.27))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8345y00k8idi4g5fyy8rn', 'waf evasion', 'waf evasion', '#06b6d4', to_timestamp(1792351971.286))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8346e00kbidi4yqj4rxt6', 'input validation', 'input validation', '#06b6d4', to_timestamp(1792351971.303))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve87gm400kridi4m0tdyg8g', 'shells', 'shells', '#06b6d4', to_timestamp(1792352174.044))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve87gn800l0idi4grjx80wx', 'bind shell', 'bind shell', '#06b6d4', to_timestamp(1792352174.085))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve87goe00l9idi46jf16vy5', 'web shells', 'web shells', '#06b6d4', to_timestamp(1792352174.126))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve87gou00lcidi40fgsf1ep', 'laudanum', 'laudanum', '#06b6d4', to_timestamp(1792352174.143))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve87gpe00lfidi4xoesov2r', 'antak', 'antak', '#06b6d4', to_timestamp(1792352174.163))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve87gpx00liidi4swroxnvv', 'php web shell', 'php web shell', '#06b6d4', to_timestamp(1792352174.182))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve87gqp00llidi476luz8hv', 'interactive shell', 'interactive shell', '#06b6d4', to_timestamp(1792352174.209))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve87gru00luidi4avv3jau2', 'unix', 'unix', '#06b6d4', to_timestamp(1792352174.25))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve87gsb00lxidi48qde046h', 'shell spawning', 'shell spawning', '#06b6d4', to_timestamp(1792352174.267))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve87gtf00m6idi43qo5qk9h', 'payload delivery', 'payload delivery', '#06b6d4', to_timestamp(1792352174.307))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve87gtw00m9idi4ymssgly3', 'evasion', 'evasion', '#06b6d4', to_timestamp(1792352174.325))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve87gud00mcidi4dhxwg4rn', 'detection', 'detection', '#06b6d4', to_timestamp(1792352174.341))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve87guv00mfidi4oqsrdisi', 'prevention', 'prevention', '#06b6d4', to_timestamp(1792352174.359))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff1p00mvidi4fugacs7o', 'web recon', 'web recon', '#06b6d4', to_timestamp(1792352545.261))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff2500myidi42n4olv5v', 'whois', 'whois', '#06b6d4', to_timestamp(1792352545.277))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff3300n4idi4akjzxfme', 'dig', 'dig', '#06b6d4', to_timestamp(1792352545.312))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff3k00n7idi475b8zevd', 'dnsenum', 'dnsenum', '#06b6d4', to_timestamp(1792352545.328))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff4100naidi4ws3bouei', 'zone transfer', 'zone transfer', '#06b6d4', to_timestamp(1792352545.345))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff4h00ndidi4w9keb3jo', 'subdomains', 'subdomains', '#06b6d4', to_timestamp(1792352545.361))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff4y00ngidi4kni5zf83', 'virtual hosts', 'virtual hosts', '#06b6d4', to_timestamp(1792352545.378))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff5f00njidi4h45p5gfk', 'gobuster', 'gobuster', '#06b6d4', to_timestamp(1792352545.396))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff5y00nmidi4miocbwym', 'certificate transparency', 'certificate transparency', '#06b6d4', to_timestamp(1792352545.415))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff6i00npidi422jlq1n1', 'crt.sh', 'crt.sh', '#06b6d4', to_timestamp(1792352545.434))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff7900nsidi411qs3mrw', 'fingerprinting', 'fingerprinting', '#06b6d4', to_timestamp(1792352545.461))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff7t00nvidi4dkgh1tml', 'banner grabbing', 'banner grabbing', '#06b6d4', to_timestamp(1792352545.482))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff8b00nyidi49iykqa4c', 'wafw00f', 'wafw00f', '#06b6d4', to_timestamp(1792352545.499))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff8s00o1idi4oimee08d', 'nikto', 'nikto', '#06b6d4', to_timestamp(1792352545.516))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff9800o4idi485mycosh', 'web crawling', 'web crawling', '#06b6d4', to_timestamp(1792352545.532))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ff9o00o7idi48xe93v5p', 'scrapy', 'scrapy', '#06b6d4', to_timestamp(1792352545.548))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ffa400oaidi4dz2dle9b', 'reconspider', 'reconspider', '#06b6d4', to_timestamp(1792352545.564))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ffak00odidi4iricek9s', 'robots.txt', 'robots.txt', '#06b6d4', to_timestamp(1792352545.58))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ffb000ogidi4717ev2th', 'well-known uris', 'well-known uris', '#06b6d4', to_timestamp(1792352545.596))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ffbg00ojidi48kbxpx7z', 'google dorking', 'google dorking', '#06b6d4', to_timestamp(1792352545.612))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ffbw00omidi4dc8mp9v4', 'search operators', 'search operators', '#06b6d4', to_timestamp(1792352545.629))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ffcc00opidi47f54lkqe', 'wayback machine', 'wayback machine', '#06b6d4', to_timestamp(1792352545.644))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ffcs00osidi43luqb1c6', 'finalrecon', 'finalrecon', '#06b6d4', to_timestamp(1792352545.661))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ffd900ovidi441hv5snp', 'passive recon', 'passive recon', '#06b6d4', to_timestamp(1792352545.678))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8ffdp00oyidi4razkljh5', 'active recon', 'active recon', '#06b6d4', to_timestamp(1792352545.693))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m21y00poidi4whtscle7', 'web attacks', 'web attacks', '#06b6d4', to_timestamp(1792352855.015))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m22e00pridi496efn3b8', 'web application security', 'web application security', '#06b6d4', to_timestamp(1792352855.03))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m23100pxidi4lwafuljo', 'http methods', 'http methods', '#06b6d4', to_timestamp(1792352855.053))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m23g00q0idi48ayijt6y', 'authentication bypass', 'authentication bypass', '#06b6d4', to_timestamp(1792352855.069))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m23v00q3idi44j8yfkzv', 'security filter bypass', 'security filter bypass', '#06b6d4', to_timestamp(1792352855.083))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m24a00q6idi4kk8a8xqx', 'insecure configuration', 'insecure configuration', '#06b6d4', to_timestamp(1792352855.099))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m25100qcidi4fqd7ik98', 'insecure direct object references', 'insecure direct object references', '#06b6d4', to_timestamp(1792352855.125))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m25j00qfidi4lqva8w3a', 'access control', 'access control', '#06b6d4', to_timestamp(1792352855.143))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m26000qiidi4o02re29q', 'mass enumeration', 'mass enumeration', '#06b6d4', to_timestamp(1792352855.161))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m26j00qlidi4y6d4xp20', 'encoded references', 'encoded references', '#06b6d4', to_timestamp(1792352855.179))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m27200qoidi4pie8za4n', 'api security', 'api security', '#06b6d4', to_timestamp(1792352855.199))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m27k00qridi4709btzeu', 'information disclosure', 'information disclosure', '#06b6d4', to_timestamp(1792352855.217))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m28300quidi47pnu0rxu', 'xml external entity', 'xml external entity', '#06b6d4', to_timestamp(1792352855.235))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m28z00r0idi4vvl6xnaf', 'xml injection', 'xml injection', '#06b6d4', to_timestamp(1792352855.267))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m29i00r3idi4bqnucs2e', 'xml dtd', 'xml dtd', '#06b6d4', to_timestamp(1792352855.286))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m2a200r6idi4pbhmbl85', 'local file disclosure', 'local file disclosure', '#06b6d4', to_timestamp(1792352855.306))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m2al00r9idi4rpvjk2hh', 'error-based xxe', 'error-based xxe', '#06b6d4', to_timestamp(1792352855.325))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m2b400rcidi4p3dubsx6', 'blind xxe', 'blind xxe', '#06b6d4', to_timestamp(1792352855.344))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m2bm00rfidi424bxlejz', 'out-of-band exfiltration', 'out-of-band exfiltration', '#06b6d4', to_timestamp(1792352855.362))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m2c500riidi4q0d36dm4', 'xxeinjector', 'xxeinjector', '#06b6d4', to_timestamp(1792352855.381))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m2d000roidi4xam79cyi', 'exploitation', 'exploitation', '#06b6d4', to_timestamp(1792352855.413))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8m2dj00rridi4py3ujmff', 'remediation', 'remediation', '#06b6d4', to_timestamp(1792352855.431))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8w9y700s7idi4zt9xsflm', 'cross-site scripting', 'cross-site scripting', '#06b6d4', to_timestamp(1792353331.808))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8w9ys00saidi44abogr1h', 'xss', 'xss', '#06b6d4', to_timestamp(1792353331.828))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8w9za00sdidi4l5agdm3d', 'stored xss', 'stored xss', '#06b6d4', to_timestamp(1792353331.846))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8w9zr00sgidi4k62u23d5', 'persistent xss', 'persistent xss', '#06b6d4', to_timestamp(1792353331.863))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa0800sjidi4oftoqvfm', 'reflected xss', 'reflected xss', '#06b6d4', to_timestamp(1792353331.88))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa0p00smidi4gfob3i10', 'non-persistent xss', 'non-persistent xss', '#06b6d4', to_timestamp(1792353331.898))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa1700spidi461abuttw', 'dom-based xss', 'dom-based xss', '#06b6d4', to_timestamp(1792353331.915))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa1o00ssidi4hqgaukor', 'blind xss', 'blind xss', '#06b6d4', to_timestamp(1792353331.932))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa2500svidi481tguxk5', 'client-side security', 'client-side security', '#06b6d4', to_timestamp(1792353331.949))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa3000t1idi4nxla1756', 'dom manipulation', 'dom manipulation', '#06b6d4', to_timestamp(1792353331.98))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa3g00t4idi4v38krli4', 'sources and sinks', 'sources and sinks', '#06b6d4', to_timestamp(1792353331.997))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa3x00t7idi4gwtv3hlo', 'innerhtml', 'innerhtml', '#06b6d4', to_timestamp(1792353332.013))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa4d00taidi4y7taiuxt', 'document.write', 'document.write', '#06b6d4', to_timestamp(1792353332.029))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa4s00tdidi4ob9cyzo1', 'xss discovery', 'xss discovery', '#06b6d4', to_timestamp(1792353332.044))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa5800tgidi4uqssewaw', 'xss testing', 'xss testing', '#06b6d4', to_timestamp(1792353332.061))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa5p00tjidi4wz9br6z8', 'xsstrike', 'xsstrike', '#06b6d4', to_timestamp(1792353332.077))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa6r00tsidi4iaxq3khm', 'manual testing', 'manual testing', '#06b6d4', to_timestamp(1792353332.115))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa7600tvidi4cwsw0be5', 'code review', 'code review', '#06b6d4', to_timestamp(1792353332.13))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa7n00tyidi4pj2f9ui2', 'website defacement', 'website defacement', '#06b6d4', to_timestamp(1792353332.147))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa8300u1idi4p88a7koj', 'xss phishing', 'xss phishing', '#06b6d4', to_timestamp(1792353332.164))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa8j00u4idi4uee9msjn', 'session hijacking', 'session hijacking', '#06b6d4', to_timestamp(1792353332.179))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa9200u7idi4xtbx9x5b', 'cookie security', 'cookie security', '#06b6d4', to_timestamp(1792353332.198))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wa9j00uaidi4s4hj0g97', 'httponly', 'httponly', '#06b6d4', to_timestamp(1792353332.215))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8waa000udidi4eezjn6d7', 'content security policy', 'content security policy', '#06b6d4', to_timestamp(1792353332.233))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8waai00ugidi4ac7tlqp7', 'csp', 'csp', '#06b6d4', to_timestamp(1792353332.251))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8waay00ujidi4eh5y453b', 'output encoding', 'output encoding', '#06b6d4', to_timestamp(1792353332.267))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve8wabf00umidi4eoj071hu', 'input sanitization', 'input sanitization', '#06b6d4', to_timestamp(1792353332.283))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve9dhj200v8idi4xxpsxmmq', 'attacking ftp', 'attacking ftp', '#06b6d4', to_timestamp(1792354134.782))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve9dhji00vbidi45bku06o1', 'attacking rdp', 'attacking rdp', '#06b6d4', to_timestamp(1792354134.799))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve9dhk500veidi42vxgldj6', 'attacking dns attacking', 'attacking dns attacking', '#06b6d4', to_timestamp(1792354134.822))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve9dhkn00vhidi4ed3ouq8m', 'email services', 'email services', '#06b6d4', to_timestamp(1792354134.839))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve9dhl500vkidi4jzs8r24x', 'attacking sql databases', 'attacking sql databases', '#06b6d4', to_timestamp(1792354134.857))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmve9dhlm00vnidi4rizj2b4e', 'attacking smb services', 'attacking smb services', '#06b6d4', to_timestamp(1792354134.874))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6br0002ida06i1palsv', 'file upload', 'file upload', '#06b6d4', to_timestamp(1792403109.063))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6ch0005ida0m73q8xg9', 'web shell', 'web shell', '#06b6d4', to_timestamp(1792403109.089))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6df000bida0u1vc84hy', 'arbitrary file upload', 'arbitrary file upload', '#06b6d4', to_timestamp(1792403109.123))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6dy000eida0ftjyiams', 'client-side bypass', 'client-side bypass', '#06b6d4', to_timestamp(1792403109.142))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6ei000hida0t9u3gwgk', 'blacklist bypass', 'blacklist bypass', '#06b6d4', to_timestamp(1792403109.162))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6f3000kida0lcgyxj0o', 'whitelist bypass', 'whitelist bypass', '#06b6d4', to_timestamp(1792403109.183))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6fm000nida0y6ct0u1c', 'double extension', 'double extension', '#06b6d4', to_timestamp(1792403109.202))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6g2000qida0fby5t850', 'null byte', 'null byte', '#06b6d4', to_timestamp(1792403109.219))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6gi000tida01tg6x24y', 'magic bytes', 'magic bytes', '#06b6d4', to_timestamp(1792403109.234))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6gx000wida0m9utjnml', 'mime spoofing', 'mime spoofing', '#06b6d4', to_timestamp(1792403109.249))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6hc000zida000zx1qnc', 'content-type', 'content-type', '#06b6d4', to_timestamp(1792403109.264))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6ht0012ida0ur9qajr4', 'character injection', 'character injection', '#06b6d4', to_timestamp(1792403109.281))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6ia0015ida08pgn5fl9', 'svg xss', 'svg xss', '#06b6d4', to_timestamp(1792403109.298))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6j3001bida08pxr3bix', 'exif injection', 'exif injection', '#06b6d4', to_timestamp(1792403109.327))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6ji001eida06okploak', 'decompression bomb', 'decompression bomb', '#06b6d4', to_timestamp(1792403109.342))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6jx001hida0avm0u6t0', 'pixel flood', 'pixel flood', '#06b6d4', to_timestamp(1792403109.358))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6ky001qida03jampbds', 'wappalyzer', 'wappalyzer', '#06b6d4', to_timestamp(1792403109.394))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6le001tida09ubyuc51', 'imagemagick', 'imagemagick', '#06b6d4', to_timestamp(1792403109.411))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6lu001wida0vhfjbnow', 'ffmpeg', 'ffmpeg', '#06b6d4', to_timestamp(1792403109.426))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6ma001zida0zkfzygir', 'windows 8.3', 'windows 8.3', '#06b6d4', to_timestamp(1792403109.443))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6mr0022ida0o43rj23k', 'rce', 'rce', '#06b6d4', to_timestamp(1792403109.459))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2j6n90025ida0rrg89ovw', 'dos', 'dos', '#06b6d4', to_timestamp(1792403109.477))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydki002lida0z8pz6si9', 'sqlmap', 'sqlmap', '#06b6d4', to_timestamp(1792403818.29))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydkz002oida0f6p389rr', 'sql injection', 'sql injection', '#06b6d4', to_timestamp(1792403818.307))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydlf002rida0z14yebco', 'boolean blind', 'boolean blind', '#06b6d4', to_timestamp(1792403818.324))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydlv002uida0u3z78pg5', 'error-based', 'error-based', '#06b6d4', to_timestamp(1792403818.34))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydmc002xida0vxr0y8io', 'union-based', 'union-based', '#06b6d4', to_timestamp(1792403818.356))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydmt0030ida0cyx0kn2t', 'time-based blind', 'time-based blind', '#06b6d4', to_timestamp(1792403818.373))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydn80033ida0jdbghxk9', 'stacked queries', 'stacked queries', '#06b6d4', to_timestamp(1792403818.389))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydno0036ida0cloya77s', 'out-of-band', 'out-of-band', '#06b6d4', to_timestamp(1792403818.405))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydo40039ida0lte2xe4x', 'waf bypass', 'waf bypass', '#06b6d4', to_timestamp(1792403818.421))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydol003cida0lueq9vr3', 'tamper scripts', 'tamper scripts', '#06b6d4', to_timestamp(1792403818.437))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydp2003fida0b57stncn', 'csrf bypass', 'csrf bypass', '#06b6d4', to_timestamp(1792403818.454))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydpi003iida06n6hl8az', 'tor', 'tor', '#06b6d4', to_timestamp(1792403818.47))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydpy003lida058t7op6d', 'proxy', 'proxy', '#06b6d4', to_timestamp(1792403818.487))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydqq003rida02owcgv7v', 'os shell', 'os shell', '#06b6d4', to_timestamp(1792403818.514))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydr7003uida01rit8gl3', 'file read', 'file read', '#06b6d4', to_timestamp(1792403818.532))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydro003xida0ugc6xewb', 'file write', 'file write', '#06b6d4', to_timestamp(1792403818.548))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2yds50040ida0etv3ym0w', 'database enumeration', 'database enumeration', '#06b6d4', to_timestamp(1792403818.565))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf2ydsl0043ida0gil2ui9f', 'mysql', 'mysql', '#06b6d4', to_timestamp(1792403818.581))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf32eny004vida0c79eypu6', 'union injection', 'union injection', '#06b6d4', to_timestamp(1792404006.334))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf32eq2005aida0jmze1bar', 'information_schema', 'information_schema', '#06b6d4', to_timestamp(1792404006.411))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf32eql005dida0kzq4sd7q', 'load_file', 'load_file', '#06b6d4', to_timestamp(1792404006.429))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf32er4005gida0183bn1vr', 'into outfile', 'into outfile', '#06b6d4', to_timestamp(1792404006.448))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf32esw005sida0q2s7p07q', 'mariadb', 'mariadb', '#06b6d4', to_timestamp(1792404006.512))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf32ete005vida0ah54ee7j', 'or injection', 'or injection', '#06b6d4', to_timestamp(1792404006.53))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf32etw005yida04zis81bg', 'comment injection', 'comment injection', '#06b6d4', to_timestamp(1792404006.549))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf32eue0061ida0dzu5fb7y', 'prepared statements', 'prepared statements', '#06b6d4', to_timestamp(1792404006.567))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf32evr006aida0loneyxje', 'waf', 'waf', '#06b6d4', to_timestamp(1792404006.615))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf32ewa006dida0i8zjebxh', 'modsecurity', 'modsecurity', '#06b6d4', to_timestamp(1792404006.634))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf32ewr006gida0aofm1aoy', 'least privilege', 'least privilege', '#06b6d4', to_timestamp(1792404006.652))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jbj006wida0yblkkd00', 'linux privilege escalation', 'linux privilege escalation', '#06b6d4', to_timestamp(1792407604.879))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jc5006zida0nphnekvh', 'linpeas', 'linpeas', '#06b6d4', to_timestamp(1792407604.901))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jcn0072ida0ymrm8djf', 'suid', 'suid', '#06b6d4', to_timestamp(1792407604.919))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jd40075ida0jxasycns', 'sgid', 'sgid', '#06b6d4', to_timestamp(1792407604.936))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jdl0078ida02ec038fd', 'sudo abuse', 'sudo abuse', '#06b6d4', to_timestamp(1792407604.954))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jee007eida0wa6pravb', 'capabilities', 'capabilities', '#06b6d4', to_timestamp(1792407604.982))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jev007hida0lms083mz', 'path abuse', 'path abuse', '#06b6d4', to_timestamp(1792407604.999))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jfa007kida0710bfh6f', 'wildcard abuse', 'wildcard abuse', '#06b6d4', to_timestamp(1792407605.015))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jfp007nida0yy0f3i91', 'cron job abuse', 'cron job abuse', '#06b6d4', to_timestamp(1792407605.029))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jg6007qida0i70qp2i3', 'restricted shell escape', 'restricted shell escape', '#06b6d4', to_timestamp(1792407605.046))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jgm007tida06pr0p6dx', 'rbash', 'rbash', '#06b6d4', to_timestamp(1792407605.063))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jh2007wida0wwkstrt6', 'lxd', 'lxd', '#06b6d4', to_timestamp(1792407605.079))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jhj007zida05ssc2zd6', 'docker', 'docker', '#06b6d4', to_timestamp(1792407605.096))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jhy0082ida0s6hu1ofn', 'container escape', 'container escape', '#06b6d4', to_timestamp(1792407605.111))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jid0085ida0oh2kadj5', 'nfs', 'nfs', '#06b6d4', to_timestamp(1792407605.125))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jiu0088ida03shqen95', 'tmux', 'tmux', '#06b6d4', to_timestamp(1792407605.142))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jj9008bida0s0pkk11k', 'shared object hijacking', 'shared object hijacking', '#06b6d4', to_timestamp(1792407605.158))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jjp008eida011ncten3', 'ld_preload', 'ld_preload', '#06b6d4', to_timestamp(1792407605.173))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jk4008hida0gtoie6ym', 'python library hijacking', 'python library hijacking', '#06b6d4', to_timestamp(1792407605.189))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jkk008kida0zs18oz84', 'kernel exploits', 'kernel exploits', '#06b6d4', to_timestamp(1792407605.204))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jl0008nida093fvdqs1', 'dirtycow', 'dirtycow', '#06b6d4', to_timestamp(1792407605.22))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jlg008qida0qap7onpv', 'dirtypipe', 'dirtypipe', '#06b6d4', to_timestamp(1792407605.236))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jlx008tida0va5nyfk0', 'polkit', 'polkit', '#06b6d4', to_timestamp(1792407605.253))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jmc008wida0rlzrzpxp', 'netfilter', 'netfilter', '#06b6d4', to_timestamp(1792407605.268))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jmt008zida045hwytre', 'pwnkit', 'pwnkit', '#06b6d4', to_timestamp(1792407605.285))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jn90092ida098sxrpos', 'baron samedit', 'baron samedit', '#06b6d4', to_timestamp(1792407605.302))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jnq0095ida0ytfr4ot3', 'logrotate', 'logrotate', '#06b6d4', to_timestamp(1792407605.318))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jo70098ida09gvw3obb', 'pspy', 'pspy', '#06b6d4', to_timestamp(1792407605.335))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jon009bida0u1gi4udx', 'strace', 'strace', '#06b6d4', to_timestamp(1792407605.351))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvf57jp3009eida0hjmsx2xf', 'privileged groups', 'privileged groups', '#06b6d4', to_timestamp(1792407605.367))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfo2ezf00a5ida0ppecaa1z', 'documentation', 'documentation', '#06b6d4', to_timestamp(1792439278.683))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfo2ezy00a8ida0jpxhgeem', 'pentest-report', 'pentest-report', '#06b6d4', to_timestamp(1792439278.702))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfo2f0g00abida0a9ynm0ua', 'executive-summary', 'executive-summary', '#06b6d4', to_timestamp(1792439278.72))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfo2f0x00aeida0rfbiw99l', 'findings', 'findings', '#06b6d4', to_timestamp(1792439278.737))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfo2f1e00ahida0nbqwhrnj', 'attack-chain', 'attack-chain', '#06b6d4', to_timestamp(1792439278.754))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfo2f1u00akida0xdpr82n6', 'notetaking', 'notetaking', '#06b6d4', to_timestamp(1792439278.77))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfo2f2a00anida0lzngoueo', 'obsidian', 'obsidian', '#06b6d4', to_timestamp(1792439278.786))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfo2f3100atida05f6buchb', 'ctf-writeup', 'ctf-writeup', '#06b6d4', to_timestamp(1792439278.813))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfop7n000b6ida0runcrgbs', 'http-verb-tampering', 'http-verb-tampering', '#06b6d4', to_timestamp(1792440342.252))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfop7o200bfida0qwjkwc9w', 'burp', 'burp', '#06b6d4', to_timestamp(1792440342.291))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfop7ok00biida0uhoposbi', 'access-control', 'access-control', '#06b6d4', to_timestamp(1792440342.308))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfop7p000blida0x1dvz8k7', 'htb', 'htb', '#06b6d4', to_timestamp(1792440342.324))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfoss6o00bvida0348w8b66', 'privilege-escalation', 'privilege-escalation', '#06b6d4', to_timestamp(1792440508.848))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfoss8000c7ida0wzxrwl4b', 'active-directory', 'active-directory', '#06b6d4', to_timestamp(1792440508.896))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfoss8r00cdida0pkgdcuen', 'potato', 'potato', '#06b6d4', to_timestamp(1792440508.923))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfoss9800cgida0gxdx98j1', 'uac', 'uac', '#06b6d4', to_timestamp(1792440508.941))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfoss9p00cjida0hrlmqe73', 'kernel-exploit', 'kernel-exploit', '#06b6d4', to_timestamp(1792440508.957))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfoyodp00drida024zy95d8', 'pentest', 'pentest', '#06b6d4', to_timestamp(1792440783.854))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvfoyoel00dxida017p1dy61', 'pivoting', 'pivoting', '#06b6d4', to_timestamp(1792440783.885))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh6hb000aidhw5i8ut7zh', 'deobfuscation', 'deobfuscation', '#06b6d4', to_timestamp(1792500433.679))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh6ib000didhwqenc0muh', 'obfuscation', 'obfuscation', '#06b6d4', to_timestamp(1792500433.715))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh6jc000gidhw31zw7prd', 'packer', 'packer', '#06b6d4', to_timestamp(1792500433.752))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh6kb000jidhwqo64llqz', 'unpacker', 'unpacker', '#06b6d4', to_timestamp(1792500433.787))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh6l9000midhw9uhw44md', 'code analysis', 'code analysis', '#06b6d4', to_timestamp(1792500433.821))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh6m1000pidhwms1v6kkv', 'reverse engineering', 'reverse engineering', '#06b6d4', to_timestamp(1792500433.849))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh6mu000sidhw1ydfv46n', 'minification', 'minification', '#06b6d4', to_timestamp(1792500433.878))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh6nn000vidhwxfbuo9xx', 'eval', 'eval', '#06b6d4', to_timestamp(1792500433.907))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh6oe000yidhwz42ssldy', 'xmlhttprequest', 'xmlhttprequest', '#06b6d4', to_timestamp(1792500433.935))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh6xg0014idhwuabd7tt9', 'http requests', 'http requests', '#06b6d4', to_timestamp(1792500434.26))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh70w001aidhw12irto47', 'hex', 'hex', '#06b6d4', to_timestamp(1792500434.385))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh71q001didhw241ci7aw', 'rot13', 'rot13', '#06b6d4', to_timestamp(1792500434.414))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh72g001gidhw669z1sg6', 'encoding', 'encoding', '#06b6d4', to_timestamp(1792500434.441))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh739001jidhwa8i7859l', 'decoding', 'decoding', '#06b6d4', to_timestamp(1792500434.469))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh742001midhwfwitjzuq', 'beautifier', 'beautifier', '#06b6d4', to_timestamp(1792500434.498))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh74z001pidhw1j06dkp4', 'prettier', 'prettier', '#06b6d4', to_timestamp(1792500434.531))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh75t001sidhwxl9dwo6w', 'obfuscator.io', 'obfuscator.io', '#06b6d4', to_timestamp(1792500434.561))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh76l001vidhwipbwzyj4', 'jsconsole', 'jsconsole', '#06b6d4', to_timestamp(1792500434.589))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgoh77z0021idhw9pbss3gb', 'client-side', 'client-side', '#06b6d4', to_timestamp(1792500434.639))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgophuv0033idhwpqxivtwl', 'server-side attacks', 'server-side attacks', '#06b6d4', to_timestamp(1792500821.672))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgophvh0036idhw6ubplwc6', 'ssrf', 'ssrf', '#06b6d4', to_timestamp(1792500821.693))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgophw60039idhwbzikiwy4', 'blind ssrf', 'blind ssrf', '#06b6d4', to_timestamp(1792500821.718))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgophwv003cidhwa9b90vqu', 'ssti', 'ssti', '#06b6d4', to_timestamp(1792500821.744))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgophxf003fidhw3ruwi7fg', 'ssi injection', 'ssi injection', '#06b6d4', to_timestamp(1792500821.763))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgophy3003iidhwqhcn90ll', 'xslt injection', 'xslt injection', '#06b6d4', to_timestamp(1792500821.787))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgophys003lidhweq6ryn7b', 'jinja2', 'jinja2', '#06b6d4', to_timestamp(1792500821.813))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgophzi003oidhwmn4a8b5v', 'twig', 'twig', '#06b6d4', to_timestamp(1792500821.838))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgopi0x003xidhw0qk0spnf', 'flask', 'flask', '#06b6d4', to_timestamp(1792500821.889))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgopi1k0040idhw67w7y7gv', 'symfony', 'symfony', '#06b6d4', to_timestamp(1792500821.912))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgopi260043idhw91u2crrc', 'gopher', 'gopher', '#06b6d4', to_timestamp(1792500821.935))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgopi2t0046idhwqppkig99', 'gopherus', 'gopherus', '#06b6d4', to_timestamp(1792500821.957))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgopi9l004xidhwkrfv4jmv', 'sstimap', 'sstimap', '#06b6d4', to_timestamp(1792500822.201))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgopiad0050idhwl002c91g', 'libxslt', 'libxslt', '#06b6d4', to_timestamp(1792500822.229))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgopib30053idhwztgaqjqu', 'cloud metadata', 'cloud metadata', '#06b6d4', to_timestamp(1792500822.255))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgopibt0056idhwer48fkhj', 'whitelisting', 'whitelisting', '#06b6d4', to_timestamp(1792500822.281))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzdl5h005gidhw8f72nkz1', 'graphql', 'graphql', '#06b6d4', to_timestamp(1792518741.845))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzdl65005jidhwegpswahd', 'api-security', 'api-security', '#06b6d4', to_timestamp(1792518741.869))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzdl6t005midhwv4fppiip', 'introspection', 'introspection', '#06b6d4', to_timestamp(1792518741.894))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzdl7x005sidhwrrgqo5ni', 'sql-injection', 'sql-injection', '#06b6d4', to_timestamp(1792518741.934))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzdl8l005vidhwtt4hyefm', 'mutations', 'mutations', '#06b6d4', to_timestamp(1792518741.957))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzdl95005yidhwdj1p7pu2', 'graphw00f', 'graphw00f', '#06b6d4', to_timestamp(1792518741.977))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzdl9r0061idhwo4wo4eb1', 'inql', 'inql', '#06b6d4', to_timestamp(1792518741.999))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxbz006hidhwltbfryqz', 'broken authentication', 'broken authentication', '#06b6d4', to_timestamp(1792518897.6))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxd0006nidhwixw4tp0r', 'user enumeration', 'user enumeration', '#06b6d4', to_timestamp(1792518897.637))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxdm006qidhw4bke57mj', 'brute force', 'brute force', '#06b6d4', to_timestamp(1792518897.658))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxey006zidhw9zlw09cy', '2fa bypass', '2fa bypass', '#06b6d4', to_timestamp(1792518897.706))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxfm0072idhwftkhuswf', 'totp', 'totp', '#06b6d4', to_timestamp(1792518897.73))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxg60075idhwlf9ckgx3', 'mfa', 'mfa', '#06b6d4', to_timestamp(1792518897.75))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxgr0078idhwon11utsc', 'password reset', 'password reset', '#06b6d4', to_timestamp(1792518897.771))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxhc007bidhwuwv4kce0', 'reset token', 'reset token', '#06b6d4', to_timestamp(1792518897.792))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxic007hidhwji9sm2yx', 'session fixation', 'session fixation', '#06b6d4', to_timestamp(1792518897.828))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxiy007kidhw3mnxw2a7', 'session tokens', 'session tokens', '#06b6d4', to_timestamp(1792518897.851))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxjl007nidhwite9jq4e', 'jwt', 'jwt', '#06b6d4', to_timestamp(1792518897.873))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxk6007qidhwfh0t4h8h', 'rate limiting', 'rate limiting', '#06b6d4', to_timestamp(1792518897.895))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxkt007tidhwiwa1j5cs', 'captcha bypass', 'captcha bypass', '#06b6d4', to_timestamp(1792518897.918))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxlf007widhwkknyabmv', 'x-forwarded-for', 'x-forwarded-for', '#06b6d4', to_timestamp(1792518897.939))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvgzgxmk0082idhw6vpwz56n', 'parameter tampering', 'parameter tampering', '#06b6d4', to_timestamp(1792518897.981))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3jg008uidhwnob7tk00', 'web applications', 'web applications', '#06b6d4', to_timestamp(1792520631.917))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3k1008xidhwmkj4hvaj', 'owasp top 10', 'owasp top 10', '#06b6d4', to_timestamp(1792520631.937))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3kl0090idhwqzzw2gaq', 'front end', 'front end', '#06b6d4', to_timestamp(1792520631.958))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3l80093idhwd5c4pk3x', 'back end', 'back end', '#06b6d4', to_timestamp(1792520631.98))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3lt0096idhwaz2rkmcx', 'html', 'html', '#06b6d4', to_timestamp(1792520632.002))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3mg0099idhwiye9pags', 'css', 'css', '#06b6d4', to_timestamp(1792520632.024))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3ng009fidhwkfq2jgi1', 'dom', 'dom', '#06b6d4', to_timestamp(1792520632.06))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3og009lidhwppaxlehk', 'sensitive data exposure', 'sensitive data exposure', '#06b6d4', to_timestamp(1792520632.096))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3p0009oidhwnksu22zj', 'html injection', 'html injection', '#06b6d4', to_timestamp(1792520632.117))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3q3009uidhwxzn5w2kf', 'csrf', 'csrf', '#06b6d4', to_timestamp(1792520632.155))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3rs00a6idhwj17h878e', 'web servers', 'web servers', '#06b6d4', to_timestamp(1792520632.216))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3sc00a9idhwg0z71hve', 'apache', 'apache', '#06b6d4', to_timestamp(1792520632.236))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3tj00afidhw9cnsm6rc', 'iis', 'iis', '#06b6d4', to_timestamp(1792520632.279))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3u800aiidhwyhpk2upx', 'databases', 'databases', '#06b6d4', to_timestamp(1792520632.304))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3uy00alidhw7diwryjg', 'sql', 'sql', '#06b6d4', to_timestamp(1792520632.33))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3vp00aoidhwe1p0b474', 'nosql', 'nosql', '#06b6d4', to_timestamp(1792520632.357))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3wi00aridhwbhzn85aa', 'rest api', 'rest api', '#06b6d4', to_timestamp(1792520632.386))
ON CONFLICT ("slug") DO NOTHING;
INSERT INTO "Tag" ("id", "name", "slug", "color", "createdAt")
VALUES ('cmvh0i3xa00auidhwmwxxkx0q', 'soap', 'soap', '#06b6d4', to_timestamp(1792520632.415))
ON CONFLICT ("slug") DO NOTHING;
