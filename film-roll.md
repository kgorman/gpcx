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
    {% for photo in site.data.film-roll %}
      <figure class="film-roll-item">
        <span class="image-number">#{{ forloop.index }}</span>
        <img src="/assets/images/film-roll/{{ photo.image }}" 
             alt="Photo by {{ photo.photographer | default: 'Kenny Gorman' }}" 
             loading="lazy">
        
        <figcaption class="image-meta">
          <div class="photographer">{{ photo.photographer | default: "Kenny Gorman" }}</div>
          
          {% if photo.caption %}
            <div class="caption">{{ photo.caption }}</div>
          {% endif %}
          
          {% if photo.date or photo.camera or photo.lens or photo.settings %}
            <div class="exif-details">
              {% if photo.date %}<div>{{ photo.date | date: "%B %-d, %Y" }}</div>{% endif %}
              {% if photo.camera %}<div>{{ photo.camera }}</div>{% endif %}
              {% if photo.lens %}<div>{{ photo.lens }}</div>{% endif %}
              {% if photo.settings %}<div>{{ photo.settings }}</div>{% endif %}
            </div>
          {% endif %}
        </figcaption>
      </figure>
    {% endfor %}
  </div>
</div>
