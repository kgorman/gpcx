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
        
        {% if photo.caption %}
          <div class="caption">{{ photo.caption }}</div>
        {% endif %}
        
        <div class="image-meta">
          {% assign meta_parts = "" | split: "" %}
          {% if photo.photographer %}{% assign meta_parts = meta_parts | push: photo.photographer %}{% else %}{% assign meta_parts = meta_parts | push: "Kenny Gorman" %}{% endif %}
          {% if photo.date %}{% assign date_str = photo.date | date: "%B %-d, %Y" %}{% assign meta_parts = meta_parts | push: date_str %}{% endif %}
          {% if photo.camera %}{% assign meta_parts = meta_parts | push: photo.camera %}{% endif %}
          {% if photo.lens %}{% assign meta_parts = meta_parts | push: photo.lens %}{% endif %}
          {% if photo.settings %}{% assign meta_parts = meta_parts | push: photo.settings %}{% endif %}
          {{ meta_parts | join: " • " }}
        </div>
      </figure>
    {% endfor %}
  </div>
</div>
