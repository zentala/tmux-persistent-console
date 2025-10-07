ming Notes — Persistent Virtual Terminal Project

## 🔧 Concept
Tool that provides a **persistent, reconnectable terminal environment**  
built on `tmux`, accessible via SSH, with multiple virtual terminals and a lightweight GUI bar.  
Goal: never lose your workspace, even after disconnects.

---

## 🧠 Core Idea
> “Persistent virtual shell hub.”  
> “Attach once. Stay forever.”  
> “A terminal that never dies.”

---

## 🏷️ Preferred Name
### **Permashell**
- ✅ conveys permanence, stability, and Unix spirit  
- easy to pronounce, type, and remember  
- scales well for CLI, service, and docs (`permashell up`, `permashell attach`)  

---

## 💡 Alternative Candidates
| Name | Meaning | Style |
|------|----------|--------|
| **StayTTY** | stay + tty → console that stays alive | modern/devops |
| **PermaTTY** | permanent TTY | geeky/Unix |
| **TermKeep** | terminal keeper | clean, sysadmin |
| **ShellHold** | shell that holds on | descriptive |
| **AliveTTY** | alive console | literal, minimal |
| **VTermal** | virtual terminal alive | modern/system |
| **StayShell** | shell that stays | friendly |
| **Persist** | minimalist, abstract | elegant brand |

---

## 🧩 Keyword Groups

### 1️⃣ **Persistence & Continuity**
words expressing *never dying*, *always on*, *restorable*
- **perma**, **persist**, **keep**, **stay**, **hold**, **alive**, **resume**, **continuum**, **retain**, **lasting**, **forever**, **immortal**
> evoke reliability, uptime, and durability — ideal for your core theme

---

### 2️⃣ **Terminal & Shell Concepts**
the domain itself — console, CLI, interactive environments
- **shell**, **term**, **tty**, **console**, **vterm**, **cli**, **session**
> anchor words; combine with persistence for clarity (e.g. `Permashell`, `StayTTY`)

---

### 3️⃣ **Virtualization & Multiplexing**
emphasize that it hosts *multiple logical terminals*
- **virtual**, **v**, **multi**, **mux**, **hub**, **deck**, **matrix**, **pane**, **switch**
> give connotation of structure, grouping, workspace, switching

---

### 4️⃣ **Service / Daemon / Infrastructure**
adds sense of automation, always-running service
- **daemon**, **d**, **svc**, **mgr**, **core**, **engine**, **system**, **orchestrator**
> communicates background operation or resilience (e.g. `permashelld`)

---

### 5️⃣ **Human / Workspace / Practical**
evoke developer friendliness and daily use
- **workspace**, **env**, **station**, **base**, **dock**, **nest**, **home**
> good for UI/UX tone if you want “personal terminal space” vibe

---

## 💬 Tagline Ideas
- “Your shell that never dies 🐚”
- “Persistent SSH workspace for long-running tasks.”
- “The tmux you never lose connection to.”
- “Attach once. Stay forever.”

---

## 🧱 Example CLI Usage
```bash
permashell up         # start background daemon
permashell attach     # enter live session
permashell new api    # create new terminal
permashell gui        # open bottom bar

