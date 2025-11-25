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
for img in "$FILM_ROLL_DIR"/*.{jpg,jpeg,JPG,JPEG} 2>/dev/null; do
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
  
  # Extract EXIF data using sips (macOS built-in)
  # Remove GPS/location data for privacy
  {
    echo "Date: $(sips -g creation "$img" 2>/dev/null | grep creation | awk '{print $2, $3}')"
    echo "Camera: $(sips -g format "$img" 2>/dev/null | grep format | awk '{print $2}')"
    
    # Try to get additional metadata using mdls
    if command -v mdls &> /dev/null; then
      camera_model=$(mdls -name kMDItemAcquisitionModel "$img" 2>/dev/null | cut -d'"' -f2)
      [ -n "$camera_model" ] && echo "Model: $camera_model"
      
      focal_length=$(mdls -name kMDItemFocalLength "$img" 2>/dev/null | awk '{print $3}')
      [ -n "$focal_length" ] && [ "$focal_length" != "(null)" ] && echo "Focal Length: ${focal_length}mm"
      
      fstop=$(mdls -name kMDItemFNumber "$img" 2>/dev/null | awk '{print $3}')
      [ -n "$fstop" ] && [ "$fstop" != "(null)" ] && echo "Aperture: f/$fstop"
      
      iso=$(mdls -name kMDItemISOSpeed "$img" 2>/dev/null | awk '{print $3}')
      [ -n "$iso" ] && [ "$iso" != "(null)" ] && echo "ISO: $iso"
      
      exposure=$(mdls -name kMDItemExposureTimeSeconds "$img" 2>/dev/null | awk '{print $3}')
      [ -n "$exposure" ] && [ "$exposure" != "(null)" ] && echo "Shutter: ${exposure}s"
    fi
    
    # Dimensions
    width=$(sips -g pixelWidth "$img" 2>/dev/null | grep pixelWidth | awk '{print $2}')
    height=$(sips -g pixelHeight "$img" 2>/dev/null | grep pixelHeight | awk '{print $2}')
    [ -n "$width" ] && [ -n "$height" ] && echo "Size: ${width}x${height}"
    
  } > "$exif_file"
  
  echo "  ✓ Created $exif_file"
done

echo ""
echo "Done! EXIF files created in $FILM_ROLL_DIR"
echo ""
echo "To add captions, create files named: <photo>_caption.txt"
echo "Example: photo001_caption.txt"
