# Bioinformatics & Data Science Blog

A Jekyll blog for sharing bioinformatics and data science content, hosted on GitHub Pages.

## Setup Instructions

### 1. Install Dependencies

```bash
# Install Ruby (if not already installed)
# macOS: Ruby comes pre-installed
# Linux: sudo apt-get install ruby-full
# Windows: Use RubyInstaller

# Install Bundler
gem install bundler

# Install Jekyll and dependencies
bundle install
```

### 2. Run Locally

```bash
bundle exec jekyll serve
```

Then visit `http://localhost:4000` in your browser.

### 3. Deploy to GitHub Pages

#### Option A: Using GitHub Actions (Recommended)

1. Create a new repository on GitHub (e.g., `yourusername.github.io`)
2. Push this blog directory to the repository
3. Go to Settings > Pages in your GitHub repository
4. Select "GitHub Actions" as the source
5. Create `.github/workflows/jekyll.yml`:

```yaml
name: Jekyll site CI

on:
  push:
    branches:
      - main
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.1'
          bundler-cache: true
      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v4
      - name: Build with Jekyll
        run: bundle exec jekyll build --baseurl "${{ steps.pages.outputs.base_path }}"
        env:
          JEKYLL_ENV: production
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

#### Option B: Using gh-pages Branch

1. Create a new repository on GitHub
2. Push this blog directory to the `main` branch
3. Run:
```bash
bundle exec jekyll build
git checkout -b gh-pages
git add _site
git commit -m "Deploy site"
git push origin gh-pages
```

### 4. Customize

- Edit `_config.yml` to update site settings
- Modify `_layouts/` for custom layouts
- Update `assets/css/main.css` for styling
- Write posts in `_posts/` directory

## Writing Posts

Create new posts in `_posts/` directory with the format:
`YYYY-MM-DD-post-title.md`

Example front matter:
```yaml
---
layout: post
title: "Your Post Title"
date: 2024-01-15
categories: [bioinformatics, data-science]
tags: [nextflow, genomics]
author: Your Name
---
```

## Features

- ✅ Responsive design
- ✅ Syntax highlighting (Prism.js)
- ✅ Math equations (MathJax)
- ✅ RSS feed
- ✅ Sitemap
- ✅ Tag support
- ✅ Clean, modern design

## Resources

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Liquid Template Language](https://shopify.github.io/liquid/)

Happy blogging! 🧬📊

