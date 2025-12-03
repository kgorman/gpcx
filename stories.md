---
layout: default
title: Stories
permalink: /stories/
body_class: page-stories
---

<div class="home">
  <p style="color: #666; margin-bottom: 1rem; font-size: 0.9rem;">Long-form narrative pieces. Deep dives, project retrospectives, ride reports with full context.</p>
  
  <ul class="post-list">
    {% for post in site.posts %}
      {% if post.tags contains "stories" %}
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
              <span class="post-tag tag-stories">stories</span>
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
      {% endif %}
    {% endfor %}
  </ul>
</div>
