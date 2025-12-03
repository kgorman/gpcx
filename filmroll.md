---
layout: default
title: Film Roll
permalink: /filmroll/
---

<div class="home">
  <h1>Film Roll</h1>
  <p style="color: #666; margin-bottom: 2rem;">Photo galleries from the trail. Mobile-optimized, minimal text.</p>
  
  <ul class="post-list">
    {% assign filmroll_posts = site.posts | where_exp: "post", "post.tags contains 'filmroll'" %}
    {% for post in filmroll_posts %}
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
            <span class="post-tag tag-filmroll">film roll</span>
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
          {% elsif post.images and post.images.first %}
            <a href="{{ post.url | relative_url }}">
              <img src="{{ post.images.first.src | relative_url }}" alt="{{ post.title }}" class="post-image" />
            </a>
          {% endif %}
        </article>
      </li>
    {% endfor %}
  </ul>
  
  {% if filmroll_posts.size == 0 %}
    <p style="color: #666; font-style: italic;">No film rolls yet. Check back soon.</p>
  {% endif %}
</div>