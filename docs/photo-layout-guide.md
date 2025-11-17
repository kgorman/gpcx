# Photo Layout Guide

## Single Photo with Caption

Use this for a single photo with a caption underneath:

```markdown
<div class="photo-caption">
  <img src="/assets/images/your-image.jpg" alt="Description">
  <span class="caption">your caption text here</span>
</div>
```

**Example:**
```markdown
<div class="photo-caption">
  <img src="/assets/images/rattler_finish_line.jpg" alt="Finish line">
  <span class="caption">crossing the line at 95th place — not DNF!</span>
</div>
```

---

## Two Photos Side by Side

Use this for two photos next to each other (stacks on mobile):

```markdown
<div class="photo-grid">
  <div>
    <img src="/assets/images/photo1.jpg" alt="Description 1">
    <span class="caption">caption for photo 1</span>
  </div>
  <div>
    <img src="/assets/images/photo2.jpg" alt="Description 2">
    <span class="caption">caption for photo 2</span>
  </div>
</div>
```

**Example:**
```markdown
<div class="photo-grid">
  <div>
    <img src="/assets/images/clik_tire.jpg" alt="Old Presta valve">
    <span class="caption">presta — finicky and leaky</span>
  </div>
  <div>
    <img src="/assets/images/clik_tire2.jpg" alt="New Clik valve">
    <span class="caption">clik — clean and fast</span>
  </div>
</div>
```

---

## Tips

- Captions are optional — just omit the `<span class="caption">` line if you don't want one
- Photos automatically stack vertically on mobile (under 768px)
- Keep captions short and lowercase for the site's style
- Images still get rounded corners automatically
- Use regular Markdown `![alt](/path/to/image.jpg)` syntax for simple photos without captions

---

## Regular Photo (no caption)

For regular photos without captions, just use standard Markdown:

```markdown
![description](/assets/images/your-image.jpg)
```
