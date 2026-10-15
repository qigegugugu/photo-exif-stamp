# 光影印章 · 照片 EXIF 水印工具

一个**单文件、零依赖、纯本地**的网页工具：读取照片 EXIF 信息（机身、镜头、拍摄参数），把参数以排版好的方式"盖"在照片上，导出时**不压缩画质、不裁切照片**。

整个工具就是一个 `index.html`（约 160 KB），没有构建步骤、没有后端、没有 CDN 依赖，双击就能用。

---

## 为什么它适合挂在 GitHub Pages

| 条件 | 本工具 |
|---|---|
| 纯静态，无服务端 | ✅ 全部逻辑在浏览器里 |
| 无构建步骤 | ✅ 不用 npm / vite |
| 无外部依赖 | ✅ 零 CDN、零外链请求 |
| 入口文件名 | ✅ 就是 `index.html` |

GitHub Pages 要求"仓库根目录有个 `index.html`"，本工具天然满足，上传即上线。

---

## 功能

**支持的图片格式**
- JPEG / JPG（EXIF 解析最完整）
- PNG / WebP（读取其中嵌入的 EXIF）
- **索尼 ARW**（RAW）：解析 TIFF 容器 EXIF，并抽取机身内嵌预览图用于显示

**读取的信息**
机身厂商、机型、镜头、焦距、光圈、快门、ISO、曝光补偿、测光模式、白平衡、拍摄时间等，可自由勾选要显示哪些。

**内置 10 套版式**
`bar` 底部条 / `card` 卡片 / `minimal` 极简 / `center` 居中 / `hairline` 细线 / `corner` 角落微标 / `glass` 玻璃拟态 / `polaroid` 白框留白 / `film` 胶片条 / `ticket` 票根

**可调项**
- 内边距、行间距、距画面边缘距离、整体大小、字号
- 署名文字 + 左右对齐
- 自定义 Logo 图片（自动压缩到长边 512px 存入浏览器本地）、三种位置、大小、不透明度

**预设系统**
版式可命名保存到浏览器本地（localStorage），支持套用、改名、删除，以及导出 / 导入 JSON（用于换设备或分享给别人）。同名保存即覆盖。

**多图处理**
- 默认**全局同步**：一套版式应用到所有导入的图片
- 可切换到**每张单独调整**：各图独立样式，缩略图右上角会亮琥珀点标记；一键"把这张的版式应用到全部"可再统一回来

---

## 隐私说明

**照片不会离开你的设备。**

页面的全部处理都在浏览器 canvas 中完成，代码里没有任何 `fetch` / `XMLHttpRequest` / `WebSocket` / `sendBeacon` / 外部资源引用（唯一出现的 `http://` 字面量是 XMP 命名空间标识，不发起请求）。

浏览器本地存储（localStorage）里只保存**你的设置和预设**（含自定义 Logo 的 dataURL），**不保存任何照片**。图片本身无法持久化，关闭页面即消失。

> 注意：这只保证"本工具不上传照片"。托管平台（GitHub Pages / 自己的服务器）在服务层仍会有常规的访问日志（IP、时间、User-Agent），这是所有网站都有的，与本工具无关。想彻底避免，把 `index.html` 下载到本地双击打开即可。

---

## 画质保证

导出时采用 **JPEG 分段手术**方式：
- 保留原图的 EXIF / IPTC / ICC 色彩配置，只改写像素尺寸标签
- 宽色域照片（AdobeRGB / ProPhoto）走 `colorSpaceConversion: 'none'` + ICC 透传，**不做 sRGB 转换**，避免颜色被削
- 画布按"画布变大、照片不裁"的几何逻辑排版（白框类模板会扩画布，照片原样贴入）

实测：照片主体区域与原图对比，PSNR 71.47 dB，最大像素误差 3/255，99.78% 的像素零误差。

---

## 本地使用

下载 `index.html`，双击用浏览器打开即可。推荐 Chrome / Edge / Safari 较新版本。

---

## 部署到 GitHub Pages

### 方式 A：网页上传（不用装任何东西，推荐）

1. 登录 GitHub，右上角 **+ → New repository**
2. 仓库名填 `photo-exif-stamp`，可见性选 **Public**，点 **Create repository**
3. 进入新仓库，点 **uploading an existing file**，把 `index.html` 拖进去，点 **Commit changes**
4. 仓库页 **Settings → Pages**
5. **Source** 选 `Deploy from a branch`，**Branch** 选 `main`，目录选 `/ (root)`，点 **Save**
6. 等 1–2 分钟，刷新页面，顶部会出现地址：

   ```
   https://<你的用户名>.github.io/photo-exif-stamp/
   ```

### 方式 B：命令行

若仓库已初始化并提交，先关联远端再推送：

```bash
git remote add origin https://github.com/<你的用户名>/photo-exif-stamp.git
git branch -M main
git push -u origin main
```

推送后按上面第 4 步在 Settings → Pages 里开启即可。

### 自定义域名

在 **Settings → Pages → Custom domain** 填写自己的域名，并在域名服务商处添加 CNAME 记录指向 `<你的用户名>.github.io`。仓库根目录的 `CNAME` 文件由 GitHub 自动生成。

---

## 改完之后怎么同步回 GitHub

项目目录里有一个 **`同步到GitHub.bat`**，双击它就行：

1. 自动挑出你改过的文件
2. 自动提交（提交信息带时间戳）
3. 推送到 GitHub，Pages 过 1～2 分钟自动更新

首次运行会问你一次 GitHub 用户名，用来关联仓库、设置提交署名。第一次推送时会弹出 GitHub 登录窗口，**登录一次以后凭据就记住了**，往后双击即同步。

> 桌面上的 `同步网站到GitHub.bat` 是同一个脚本的入口，双击它效果一样。

### 想改提交署名

默认用你的 GitHub 用户名。想换成别的，在项目目录里跑一次即可：

```bash
git config user.name "你的名字"
git config user.email "你的邮箱"
```

### 不想用脚本，手动推

```bash
git add -A
git commit -m "更新"
git push
```

### 推送被拒绝：`! [rejected] main -> main (fetch first)`

完整报错长这样：

```
! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'https://github.com/<用户名>/photo-exif-stamp.git'
hint: Updates were rejected because the remote contains work that you do not
hint: have locally.
```

**这不是仓库地址写错了。** 真实原因是：远端存在你本地没有的提交。最典型的触发方式是在 GitHub 网页上点过 **`uploading an existing file`** 直接拖文件上传 —— 那会在远端生成一个提交，而本地仓库是独立 `git init` 的，两边**没有共同祖先**，Git 就会拒绝推送。

**现在的 `同步到GitHub.bat` 会自动处理**：推送前先跟远端对一次，发现远端有本地没有的提交就自动合并（冲突时以本地版本为准），然后正常推送。远端那个提交会保留在历史里，不会丢。

脚本万一没搞定，手动兜底：

```bash
git fetch origin
git merge --allow-unrelated-histories --no-edit -X ours origin/main
git push -u origin main
```

> `-X ours` 表示冲突时以本地版本为准。补救一次之后两边历史就接上了，后续正常同步不会再报这个错。
>
> **想彻底避免**：不要在 GitHub 网页上手动上传/编辑文件，统一在本地改，然后双击脚本推送。

---

## 国内访问的备选方案

GitHub Pages 的 `*.github.io` 域名在中国大陆的访问速度**不稳定**（时快时慢，偶尔需要代理）。如果主要给国内的人用，可以考虑：

- **Gitee Pages**：国内速度快，但需要实名认证，且 Pages 服务需人工审核、每次更新后要手动点"更新"
- **Cloudflare Pages / Vercel / Netlify**：免费、自动 HTTPS、国内访问通常比 github.io 顺畅，绑定自定义域名后体验更好

这三个平台都是"连仓库 → 自动构建 → 给域名"，本工具因为不需要构建，直接指定根目录即可。

---

## 许可

MIT License，详见 `LICENSE`。

---

## 技术备注

- EXIF 解析器为手写实现，支持小端 / 大端字节序、SubIFD 指针、GPS IFD
- 索尼机型可读名映射（如 `ILCE-1` → `SONY A1`）
- 宽色域转换矩阵经 lcms 校验（最大误差 2/255）
