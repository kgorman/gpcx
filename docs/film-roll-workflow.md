# Film Roll Workflow Guide

**For AI Agent:** This guide explains the complete workflow for processing and publishing trail photos to the Film Roll page.

---

## Overview

Film Roll is a data-driven photo gallery that automatically displays images from `/assets/images/film-roll/`. Each photo can have optional caption and EXIF metadata files.

---

## Complete Workflow

### 1. Resize Photos for Web

**Location:** User will drop photos in `/assets/images/film-roll/`

**Command to resize:**
```bash
cd /Users/kgorman/workspace/Github/gpcx/assets/images/film-roll
sips -Z 1200 *.jpg *.jpeg *.JPG *.JPEG 2>/dev/null
```

**What this does:**
- Resizes to max 1200px width/height while maintaining aspect ratio
- Reduces file size for web delivery
- Preserves EXIF data for next step
- Works on all JPEG files in the directory

**Quality check:**
```bash
# Verify dimensions after resize
sips -g pixelWidth -g pixelHeight *.jpg | grep -E "pixelWidth|pixelHeight"
```

---

### 2. Extract EXIF Data

**Script location:** `/Users/kgorman/workspace/Github/gpcx/bin/extract_exif.sh`

**Command:**
```bash
cd /Users/kgorman/workspace/Github/gpcx
./bin/extract_exif.sh
```

**What this does:**
- Scans `/assets/images/film-roll/` for JPEG files
- Creates `<photo>_exif.txt` for each image
- Extracts: date, camera model, focal length, aperture, ISO, shutter speed, dimensions
- **EXCLUDES GPS/location data for privacy**
- Skips photos that already have EXIF files

**Output example:** `ride-photo.jpg` → `ride-photo_exif.txt`

---

### 3. Add Captions (Optional)

If user wants captions on specific photos:

**Create caption files:**
```bash
cd /Users/kgorman/workspace/Github/gpcx/assets/images/film-roll
echo "Caption text goes here" > photo-name_caption.txt
```

**Naming convention:** 
- Photo: `ride-photo.jpg`
- Caption: `ride-photo_caption.txt`
- Must match exactly (case-sensitive, excluding extension)

**Caption style:**
- 1-2 sentences max
- Observational, terse, zine aesthetic
- Example: "Emma Long smiles for miles. Technical climbing through the rocks."

---

### 4. Verify Files

**Check what's ready:**
```bash
cd /Users/kgorman/workspace/Github/gpcx/assets/images/film-roll
ls -lh
```

**Expected structure:**
```
ride-photo-01.jpg           # The photo (resized to 1200px)
ride-photo-01_exif.txt      # Auto-generated EXIF data
ride-photo-01_caption.txt   # Optional caption
ride-photo-02.jpg
ride-photo-02_exif.txt
```

---

### 5. Commit and Push

**Commands:**
```bash
cd /Users/kgorman/workspace/Github/gpcx
git add assets/images/film-roll/
git commit -m "Add film roll photos from [ride name/date]"
git push origin main
```

---

## When User Says "Build the Film Roll"

Execute this sequence:

1. **Resize all new photos:**
   ```bash
   cd /Users/kgorman/workspace/Github/gpcx/assets/images/film-roll
   sips -Z 1200 *.jpg *.jpeg *.JPG *.JPEG 2>/dev/null
   ```

2. **Extract EXIF data:**
   ```bash
   cd /Users/kgorman/workspace/Github/gpcx
   ./bin/extract_exif.sh
   ```

3. **Ask about captions:**
   "Do you want captions for any of these photos? If so, tell me the photo filename and caption text."

4. **Verify and report:**
   ```bash
   cd /Users/kgorman/workspace/Github/gpcx/assets/images/film-roll
   ls -lh *.jpg *.txt 2>/dev/null | grep -v README
   ```
   Tell user: "Found X photos ready to publish."

5. **Commit and push:**
   ```bash
   cd /Users/kgorman/workspace/Github/gpcx
   git add assets/images/film-roll/
   git commit -m "Add film roll photos"
   git push origin main
   ```

---

## How It Works

**Frontend (film-roll.md):**
- Jekyll scans `/assets/images/film-roll/` for JPEG files
- Auto-numbers photos sequentially (#1, #2, #3...)
- Displays most recent first (sorted by modified time)
- Shows photographer credit: "Kenny Gorman"
- Looks for matching `_caption.txt` and `_exif.txt` files
- Renders captions directly below photos
- EXIF details in collapsible `<details>` dropdown

**No database needed** - fully file-based and automatic.

---

## File Matching Logic

Jekyll matches files by basename (filename without extension):

```
photo-001.jpg         → basename: "photo-001"
photo-001_caption.txt → matches if basename + "_caption.txt"
photo-001_exif.txt    → matches if basename + "_exif.txt"
```

**Case sensitivity:** macOS is case-insensitive, but Git/Jekyll are case-sensitive. Use lowercase for consistency.

---

## Troubleshooting

**Photos not showing up?**
- Check file extension: `.jpg` or `.jpeg` only
- Verify location: must be in `/assets/images/film-roll/`
- Check Jekyll build output for errors

**EXIF data not showing?**
- Run `./bin/extract_exif.sh` again
- Verify `_exif.txt` file exists next to photo
- Check filename matches exactly (except extension)

**Captions not appearing?**
- Verify filename: `photo_caption.txt` (not `photo-caption.txt`)
- Check file encoding: must be plain text UTF-8
- Ensure exact basename match with photo

---

## Privacy Note

The EXIF extraction script **automatically excludes GPS/location data**. Only camera settings and timestamps are included.

---

## Example Session

```bash
# User drops 5 photos in film-roll directory
# Agent executes:

cd /Users/kgorman/workspace/Github/gpcx/assets/images/film-roll
sips -Z 1200 *.jpg

cd /Users/kgorman/workspace/Github/gpcx
./bin/extract_exif.sh

# User wants caption on one photo
echo "Steep technical climb at mile 8" > photo-003_caption.txt

# Commit
git add assets/images/film-roll/
git commit -m "Add film roll photos from Emma Long ride"
git push origin main
```

Done! Photos live on https://gpcx.cc/film-roll/
