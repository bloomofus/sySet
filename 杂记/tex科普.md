好的，下面是一个简洁清晰的科普，帮你理清 LaTeX、TeX、XeTeX、pdfTeX 等相关概念之间的关系和区别。

---

### 1. **TeX：排版引擎的鼻祖**
- **TeX** 是由高德纳（Donald Knuth）在 1978 年开发的一套**排版系统**，核心是一个**排版引擎**。
- 它专注于高质量的排版，尤其擅长数学公式。
- TeX 本身使用的是**纯文本命令**，语法原始，比较底层。

---

### 2. **LaTeX：基于 TeX 的宏包（文档准备系统）**
- **LaTeX**（发音 /ˈlɑːtɛx/ 或 /ˈleɪtɛx/）不是独立引擎，而是**建立在 TeX 之上的宏包集合**。
- 它提供了一套**高层命令**（如 `\section{}`、`\begin{equation}`），让你可以专注于内容，而不是排版细节。
- 实际编译时，LaTeX 的 `.tex` 文件仍需通过某个 **TeX 引擎**（如 pdfTeX、XeTeX、LuaTeX）来处理。

✅ 所以说：**你写的是 LaTeX，跑的是 TeX（引擎）**。

---

### 3. **常见 TeX 引擎（用来“跑” LaTeX）**

| 引擎       | 特点                                                         |
| ---------- | ------------------------------------------------------------ |
| **pdfTeX** | 最早支持直接输出 PDF（传统 TeX 只输出 DVI）。默认使用 `inputenc` + `fontenc` 管理编码和字体，对 Unicode 和中文字体支持较弱。 |
| **XeTeX**  | **原生支持 Unicode**，可直接使用系统字体（比如微软雅黑、思源黑体）。**对中文等非拉丁文字非常友好**。编译命令通常是 `xelatex`。 |
| **LuaTeX** | 类似 XeTeX，也支持 Unicode 和系统字体，但用 Lua 语言作为扩展脚本。更现代，但生态略不如 XeTeX 成熟。 |

> 🔸 **日常建议**：如果你需要**中文排版**，**优先用 XeLaTeX（即 XeTeX + LaTeX）**。

---

### 4. **常见编译命令（对应不同引擎）**

| 命令       | 引擎               | 输出格式 | 推荐场景                 |
| ---------- | ------------------ | -------- | ------------------------ |
| `latex`    | Knuth TeX / pdfTeX | `.dvi`   | 古老，少用               |
| `pdflatex` | pdfTeX             | `.pdf`   | 英文文档，无复杂字体需求 |
| `xelatex`  | XeTeX              | `.pdf`   | **含中文、使用系统字体** |
| `lualatex` | LuaTeX             | `.pdf`   | 需要 Lua 脚本扩展        |

---

### 5. **其他相关概念**

- **CTeX 宏包**：专为中文用户设计的 LaTeX 宏包，自动配置中文字体、标题格式等，通常配合 `xelatex` 使用。
- **Overleaf**：在线 LaTeX 编辑平台，默认引擎是 `latex` 或 `pdflatex`，但可手动切换为 `xelatex`。
- **TeX Live / MiKTeX**：TeX 系统的发行版（类似“操作系统发行版”），包含引擎、宏包、工具等。Linux（如 Ubuntu）通常用 **TeX Live**。

---

### 简单总结

- **TeX** 是底层引擎。
- **LaTeX** 是写文档的“语言”（其实是宏包）。
- **XeTeX / pdfTeX / LuaTeX** 是不同的引擎，决定如何处理你的 LaTeX 文件。
- **中文用户 → 用 `xelatex` + `ctex` 宏包** 是最省心的组合。

---

如果你在 Ubuntu 上使用，可以这样安装完整支持中文的环境：

```bash
sudo apt install texlive-full  # 或 texlive-xetex texlive-lang-chinese
```

然后用：

```bash
xelatex yourfile.tex
```

来编译含中文的文档。

需要更具体的例子或模板也可以告诉我。