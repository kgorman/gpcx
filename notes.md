---
layout: default
title: Notes
permalink: /notes/
body_class: page-notes
---

<div class="home">
  <p style="color: #666; margin-bottom: 1rem; font-size: 0.9rem;">Short, incremental posts. Ride notes, shop updates, progress photos, half-formed thoughts. The live feed.</p>
  
  <ul class="post-list">
    {% assign notes_posts = site.posts | where_exp: "post", "post.tags contains 'notes'" %}
    {% for post in notes_posts %}
      <li class="post-item">
        <article class="post-preview">
          <h2>
            <a class="post-link" href="{{ post.url | relative_url }}">
              {{ post.title | escape }}
            </a>
          </h2>
          <p class="post-meta">
            {{ post.date | date: "%B %-d, %Y" }}
            {% if post.author %} by {{ post.author }}{% endif %}
            <span class="post-tag tag-notes">notes</span>
          </p>
          {% if post.homeimage %}
            <a href="{{ post.url | relative_url }}">
              <img src="{{ post.homeimage | relative_url }}" alt="{{ post.title }}" class="post-image" />
            </a>
          {% elsif post.headimage %}
            <a href="{{ post.url | relative_url }}">
              <img src="{{ post.headimage | relative_url }}" alt="{{ post.title }}" class="post-image" />
            </a>
          {% elsif post.image %}
            <a href="{{ post.url | relative_url }}">
              <img src="{{ post.image | relative_url }}" alt="{{ post.title }}" class="post-image" />
            </a>
          {% endif %}
          <p class="post-excerpt">
            {{ post.excerpt | strip_html | truncatewords: 40 }}
          </p>
          <p><a class="read-more" href="{{ post.url | relative_url }}">open the story →</a></p>
        </article>
      </li>
    {% endfor %}
  </ul>
  
  {% if notes_posts.size == 0 %}
    <p style="color: #666; font-style: italic;">No notes yet. Check back soon.</p>
  {% endif %}
</div>