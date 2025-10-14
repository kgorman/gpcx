---
layout: page
title: posts
permalink: /posts/
---

<div class="posts">
  {% for post in site.posts %}
    <div class="post py3">
      <p class="post-meta">{{ post.date | date: site.date_format }}</p>
      <a href="{{ post.url | relative_url }}" class="post-link"><h3 class="h2 post-title">{{ post.title }}</h3></a>
      <span class="post-summary">
        {% if post.description %}
          {{ post.description }}
        {% else %}
          {{ post.excerpt | strip_html | truncatewords: 50 }}
        {% endif %}
      </span>
      <p class="post-meta" style="margin-top: 10px;">
        {% if post.tags.size > 0 %}
        <span class="post-tags">
          {% for tag in post.tags %}
            #{{ tag }}{% unless forloop.last %} {% endunless %}
          {% endfor %}
        </span>
        {% endif %}
      </p>
    </div>
  {% endfor %}
</div>
