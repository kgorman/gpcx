---
layout: default
title: Film Roll
permalink: /film-roll/
---

<div class="film-roll-page">
  <header class="film-roll-page-header">
    <h1>Film Roll</h1>
    <p class="film-roll-intro">Trail photography. Raw, unfiltered, no HDR fake bullshit.</p>
  </header>

  <div class="film-roll-grid">
    {% assign image_files = site.static_files | where_exp: "file", "file.path contains '/assets/images/film-roll/'" | where_exp: "file", "file.extname == '.jpg' or file.extname == '.jpeg' or file.extname == '.JPG' or file.extname == '.JPEG'" | sort: "modified_time" | reverse %}
    
    {% for image in image_files %}
      {% assign basename = image.basename %}
      {% assign caption_file = basename | append: "_caption.txt" %}
      {% assign exif_file = basename | append: "_exif.txt" %}
      
      <figure class="film-roll-item">
        <span class="image-number">#{{ forloop.index }}</span>
        <img src="{{ image.path | relative_url }}" 
             alt="Photo by Kenny Gorman" 
             loading="lazy">
        
        <figcaption class="image-meta">
          <div class="photographer">Kenny Gorman</div>
          
          {% comment %}Check for caption file{% endcomment %}
          {% assign caption_path = '/assets/images/film-roll/' | append: caption_file %}
          {% for file in site.static_files %}
            {% if file.path == caption_path %}
              <div class="caption">{{ file.content }}</div>
            {% endif %}
          {% endfor %}
          
          {% comment %}Check for EXIF file{% endcomment %}
          {% assign exif_path = '/assets/images/film-roll/' | append: exif_file %}
          {% for file in site.static_files %}
            {% if file.path == exif_path %}
              <div class="exif-details">
                <details>
                  <summary>Details</summary>
                  <pre>{{ file.content }}</pre>
                </details>
              </div>
            {% endif %}
          {% endfor %}
        </figcaption>
      </figure>
    {% endfor %}
  </div>
</div>
