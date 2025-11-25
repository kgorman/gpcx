---
layout: default
title: Weekly Digest
permalink: /digest/
---

<div class="home">
  <h1>Weekly Digest</h1>
  <p style="color: #666; margin-bottom: 2rem;">Weekly updates from the trail, garage, and journey. <a href="https://gpcx.substack.com/?showWelcome=true" target="_blank" rel="noopener">Sign up for the newsletter</a> for email delivery.</p>
  
  <ul class="post-list">
    {% for digest in site.data.digests %}
      <li>
        <article class="post-preview">
          <h2>
            <a class="post-link" href="{{ digest.url }}" target="_blank" rel="noopener">
              {{ digest.title | escape }}
            </a>
          </h2>
          <p class="post-meta">{{ digest.date | date: "%B %-d, %Y" }} • <a href="{{ digest.url }}" target="_blank" rel="noopener">Read on Substack →</a></p>
          {% if digest.subtitle %}
            <p style="font-style: italic; color: #666; margin-top: 0.5rem;">{{ digest.subtitle }}</p>
          {% endif %}
          {% if digest.image %}
            <a href="{{ digest.url }}" target="_blank" rel="noopener">
              <img src="{{ digest.image }}" alt="{{ digest.title }}" class="post-image" />
            </a>
          {% endif %}
          <p class="post-excerpt">
            {{ digest.excerpt }}
          </p>
          <p><a href="{{ digest.url }}" target="_blank" rel="noopener">read the digest →</a></p>
        </article>
      </li>
    {% endfor %}
  </ul>
  
  <div style="margin: 3rem 0; padding: 2rem; border: 2px dashed #ddd; border-radius: 8px; text-align: center;">
    <h3 style="margin-top: 0;">Get Weekly Updates</h3>
    <p style="color: #666;">Delivered to your inbox every Friday.</p>
    <a href="https://gpcx.substack.com/?showWelcome=true" target="_blank" rel="noopener" style="display: inline-block; padding: 0.75rem 1.5rem; background: #111; color: #fff; text-decoration: none; border-radius: 4px; font-weight: 500;">Sign Up for Newsletter</a>
  </div>
</div>
