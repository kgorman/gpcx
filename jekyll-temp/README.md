# Jekyll on Render

This repository contains a simple Jekyll site that can be deployed on Render. Jekyll is a static site generator that transforms your plain text into beautiful static websites and blogs.

## Features

- Simple, blog-aware static site generator
- No database required
- Content written in Markdown
- Easy deployment on Render
- Fast loading times

## Deployment Instructions

### On Render

1. Fork this repository to your GitHub account
2. Log in to your Render account
3. Click on "New" and select "Static Site"
4. Connect to your GitHub account and select this repository
5. Configure the build settings:
   - Build Command: `bundle exec jekyll build`
   - Publish Directory: `_site`
6. Click "Create Static Site"

That's it! Your Jekyll site will be live at your Render URL once the build completes.

## Local Development

To run this site locally:

```bash
# Install dependencies
bundle install

# Start the Jekyll server
bundle exec jekyll serve
```

Then visit `http://localhost:4000` in your browser.

## Customization

- Edit `_config.yml` to change your site settings
- Add or modify posts in the `_posts` directory
- Update page content in Markdown files
- Add custom styles in the `assets` directory

## Learn More

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [Render Static Sites Documentation](https://render.com/docs/static-sites)
