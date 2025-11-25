#!/bin/bash

# Film Roll EXIF Extractor
# Usage: ./extract_exif.sh /path/to/assets/images/film-roll/

FILM_ROLL_DIR="${1:-./assets/images/film-roll}"

if [ ! -d "$FILM_ROLL_DIR" ]; then
  echo "Directory not found: $FILM_ROLL_DIR"
  exit 1
fi

echo "Extracting EXIF data from photos in $FILM_ROLL_DIR..."

# Process each image file
shopt -s nullglob
for img in "$FILM_ROLL_DIR"/*.jpg "$FILM_ROLL_DIR"/*.jpeg "$FILM_ROLL_DIR"/*.JPG "$FILM_ROLL_DIR"/*.JPEG; do
  [ -e "$img" ] || continue
  
  filename=$(basename "$img")
  basename="${filename%.*}"
  exif_file="$FILM_ROLL_DIR/${basename}_exif.txt"
  
  # Skip if EXIF file already exists
  if [ -f "$exif_file" ]; then
    echo "  ✓ $filename (EXIF exists)"
    continue
  fi
  
  echo "  → Processing $filename..."
  
  # Extract EXIF data using exiftool (better than sips/mdls)
  # Remove GPS/location data for privacy
  {
    exiftool -Make -Model -LensModel -FocalLength -FNumber -ISO -ShutterSpeed -ExposureTime \
             -DateTimeOriginal -ImageWidth -ImageHeight -d "%Y-%m-%d %H:%M:%S" \
             "$img" 2>/dev/null | grep -v "File Name" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*:[[:space:]]*/: /'
  } > "$exif_file"
  
  echo "  ✓ Created $exif_file"
done

echo ""
echo "Done! EXIF files created in $FILM_ROLL_DIR"
echo ""
echo "To add captions, create files named: <photo>_caption.txt"
echo "Example: photo001_caption.txt"
