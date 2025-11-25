# Film Roll Workflow Guide

**For AI Agent:** This guide explains the complete workflow for processing and publishing trail photos to the Film Roll page.

---

## Overview

Film Roll uses a simple YAML data file (`_data/film-roll.yml`) to manage photos. Each entry points to an image in `/assets/images/film-roll/` with optional caption and camera metadata.

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
- Preserves EXIF data for extraction

---

### 2. Extract EXIF Data (Optional)

**Script location:** `/Users/kgorman/workspace/Github/gpcx/bin/extract_exif.sh`

**Command:**
```bash
cd /Users/kgorman/workspace/Github/gpcx
./bin/extract_exif.sh
```

**What this does:**
- Creates `<photo>_exif.txt` files with camera metadata
- Use this as reference when adding entries to `_data/film-roll.yml`
- **EXCLUDES GPS/location data for privacy**

---

### 3. Add Photos to YAML File

**File:** `_data/film-roll.yml`

**Format:**
```yaml
- image: photo-filename.jpeg
  caption: "Your terse caption here"
  date: "2025-11-24"
  camera: "DJI Action 5 Pro"
  lens: "Wide angle"
  settings: "4K/60fps, f/2.8, ISO 100"
  photographer: "Kenny Gorman"
```

**Required fields:**
- `image`: Filename (must exist in `/assets/images/film-roll/`)

**Optional fields:**
- `caption`: 1-2 sentence caption (terse, observational)
- `date`: YYYY-MM-DD format
- `camera`: Camera model
- `lens`: Lens info
- `settings`: Aperture, ISO, shutter, etc.
- `photographer`: Defaults to "Kenny Gorman" if omitted

**Order:** Photos appear in the order they're listed (top = #1)

---

### 4. Verify and Commit

**Check the YAML syntax:**
```bash
cd /Users/kgorman/workspace/Github/gpcx
cat _data/film-roll.yml
```

**Commit:**
```bash
git add assets/images/film-roll/ _data/film-roll.yml
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

2. **Extract EXIF data for reference:**
   ```bash
   cd /Users/kgorman/workspace/Github/gpcx
   ./bin/extract_exif.sh
   ```

3. **Read EXIF files and add entries to YAML:**
   For each photo, read its `_exif.txt` file and add an entry to `_data/film-roll.yml`:
   ```bash
   cat assets/images/film-roll/photo-name_exif.txt
   ```
   Then add to YAML with proper formatting.

4. **Ask about captions:**
   "Do you want captions for any of these photos? Tell me the photo filename and caption text."

5. **Commit and push:**
   ```bash
   git add assets/images/film-roll/ _data/film-roll.yml
   git commit -m "Add film roll photos"
   git push origin main
   ```

---

## Example YAML Entry

```yaml
- image: emma-long-descent.jpeg
  caption: "A little bit of descent on the MTe"
  date: "2025-11-24"
  camera: "DJI Action 5 Pro"
  settings: "4K/60fps, Auto exposure"
  photographer: "Kenny Gorman"

- image: walnut-creek-climb.jpeg
  caption: "Steep technical section through the rocks"
  date: "2025-11-23"
  camera: "iPhone 15 Pro"
  lens: "24mm equivalent"
  settings: "f/1.8, 1/500s, ISO 64"
```

---

## How It Works

**Data file:** `_data/film-roll.yml` contains array of photo objects  
**Frontend:** `film-roll.md` loops through the YAML data  
**Images:** Served from `/assets/images/film-roll/`  
**Display order:** Same as YAML file order (top to bottom = #1 to #N)

---

## Caption Style

- 1-2 sentences max
- Observational, terse, zine aesthetic
- No flowery language
- Examples:
  - "A little bit of descent on the MTe"
  - "Technical climbing through the rocks"
  - "Emma Long smiles for miles"

---
