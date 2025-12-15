---
layout: default
title: Film Roll
permalink: /film-roll/
body_class: page-film-roll
---

<div class="film-roll-page">
  <p class="filter-description">Trail photography. Raw, unfiltered, no HDR fake bullshit.</p>

  <div class="film-roll-grid">
    {% assign total = site.data.film-roll | size %}
    {% for photo in site.data.film-roll %}
      {% assign photo_id = photo.image | remove: '.jpeg' | remove: '.jpg' | remove: '.JPEG' | remove: '.JPG' %}
      {% assign reversed_number = total | minus: forloop.index0 %}
      <figure class="film-roll-item" id="{{ photo_id }}">
        <a href="#{{ photo_id }}" class="image-number">#{{ reversed_number }}</a>
        <img src="/assets/images/film-roll/{{ photo.image }}" 
             alt="Photo by {{ photo.photographer | default: 'Kenny Gorman' }}" 
             loading="lazy"
             onclick="openLightbox(this)">
        
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
        
        {% if photo.full_res %}
          {% assign base_name = photo.image | split: '.' | first %}
          {% assign extension = photo.image | split: '.' | last %}
          {% assign full_res_filename = base_name | append: '_full_res.' | append: extension %}
          {% capture full_res_path %}/assets/images/film-roll/{{ full_res_filename }}{% endcapture %}
          <div class="download-link">
            <a href="{{ full_res_path }}" download="{{ full_res_filename }}" class="full-res-download">↓ download full resolution</a>
          </div>
        {% endif %}
      </figure>
    {% endfor %}
  </div>
</div>

<script>
// Lightbox for film roll images
function openLightbox(img) {
  const lightbox = document.createElement('div');
  lightbox.className = 'lightbox-overlay';
  lightbox.innerHTML = `
    <div class="lightbox-content">
      <span class="lightbox-close">&times;</span>
      <img src="${img.src}" alt="${img.alt}" class="lightbox-image">
    </div>
  `;
  
  document.body.appendChild(lightbox);
  document.body.style.overflow = 'hidden';
  
  // Close on click outside or on close button
  lightbox.addEventListener('click', function(e) {
    if (e.target === lightbox || e.target.classList.contains('lightbox-close')) {
      closeLightbox(lightbox);
    }
  });
  
  // Close on escape key
  const escapeHandler = function(e) {
    if (e.key === 'Escape') {
      closeLightbox(lightbox);
      document.removeEventListener('keydown', escapeHandler);
    }
  };
  document.addEventListener('keydown', escapeHandler);
  
  // Prevent scrolling behind lightbox
  document.body.style.overflow = 'hidden';
}

function closeLightbox(lightbox) {
  document.body.removeChild(lightbox);
  document.body.style.overflow = '';
}
</script>
