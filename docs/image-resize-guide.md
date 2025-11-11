# How to Resize Images for the Blog

To ensure images look great and load fast on the blog, follow these steps:

## 1. Resize to Blog-Friendly Dimensions
- Use an image editor (Preview, Photoshop, GIMP, etc.)
- Target width: **1200px** (for full-width images)
- Target height: **auto** (let the editor keep aspect ratio)
- Save as JPEG for best balance of quality and file size

## 2. Compress for Web
- Use [TinyPNG](https://tinypng.com/) or [ImageOptim](https://imageoptim.com/mac) to reduce file size
- Aim for images under **300KB** if possible

## 3. Save to the Right Folder
- Place images in `assets/images/`
- Use descriptive, lowercase filenames (e.g. `sb150_trail.jpg`)

## 4. Reference in Markdown
```
![alt text](/assets/images/your-image.jpg)
```

## 5. Repeat for New Images
- Apply the same steps for every new image you upload

---
**Tip:** If you want all images to display at a specific width, add this to your Markdown:
```
<img src="/assets/images/your-image.jpg" width="800" />
```
Or use CSS to style `.post-content img { max-width: 100%; height: auto; }`

---
**Summary:**
- Resize to 1200px wide
- Compress for web
- Save in `assets/images/`
- Reference in Markdown
- Repeat for all new images

---

## AI Assistant Reference: Automated Resize Using sips (macOS)

**NOTE: This section is for AI assistants working on this repository.**

When resizing images for this blog, use the macOS `sips` command-line tool to resize images to 1200px max width while preserving aspect ratio.

### Single Image Resize
```bash
cd /Users/kgorman/workspace/Github/gpcx/assets/images
sips -Z 1200 filename.jpg
```

### Batch Resize Multiple Images
```bash
cd /Users/kgorman/workspace/Github/gpcx/assets/images
for f in pattern_*.jpg; do 
  [ -f "$f" ] || continue
  sips -Z 1200 "$f"
  echo "Resized: $f"
done
```

### With Backup (Optional)
```bash
cd /Users/kgorman/workspace/Github/gpcx/assets/images
for f in pattern_*.jpg; do 
  [ -f "$f" ] || continue
  cp "$f" "$f.bak"
  sips -Z 1200 "$f"
  echo "Resized: $f"
done
# Remember: DO NOT commit .bak files
```

### Check File Sizes After Resize
```bash
cd /Users/kgorman/workspace/Github/gpcx/assets/images
ls -lh pattern_*.jpg | awk '{print $9, $5}'
```

**Target specifications:**
- Max width: 1200px
- Aspect ratio: preserved automatically
- Format: JPEG
- Target file size: under 300KB (ideally), up to 600KB acceptable
- Existing blog images range: 86KB–671KB (most are 200KB–500KB)

**Important:** Always remove `.bak` files before committing (`rm -f *.bak`)

````
