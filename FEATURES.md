# Blog Features & Customizations

This document outlines all the features and customizations added to your Jekyll blog.

## 🎨 Styling Enhancements

### Modern Design
- **Gradient backgrounds** - Beautiful gradient header and background
- **Card-based layout** - Posts displayed in attractive cards with hover effects
- **Smooth animations** - Fade-in animations and hover transitions
- **Professional color scheme** - Blue/green gradient theme perfect for bioinformatics
- **Shadow effects** - Subtle shadows for depth and modern look

### Responsive Design
- **Mobile-first** - Fully responsive for all screen sizes
- **Tablet optimized** - Great experience on tablets
- **Print styles** - Clean print layout

## 🚀 New Features

### 1. Navigation Menu
- Clean navigation bar with active page highlighting
- Links to Home, About, Archive, and RSS feed
- Smooth hover effects

### 2. Social Media Links
- GitHub, Twitter, LinkedIn, and Email icons in header
- Configure in `_config.yml` under `social:` section
- Hover animations

### 3. Reading Time Estimates
- Automatically calculates reading time based on word count
- Shows "X min read" on post list and individual posts
- Based on average reading speed of 180 words/minute

### 4. Table of Contents (TOC)
- Automatic table of contents for posts
- Enable by adding `toc: true` to post front matter
- Styled in a nice box with smooth scrolling links

### 5. Related Posts
- Automatically shows related posts at the bottom of each post
- Based on categories
- Shows up to 3 related posts

### 6. Archive Page
- Complete archive of all posts organized by year
- Easy navigation to find old posts
- Accessible from navigation menu

### 7. About Page
- Professional about page template
- Customize with your information
- Contact information section

### 8. Enhanced Code Highlighting
- Dark theme for code blocks (Prism Tomorrow theme)
- Support for multiple languages:
  - Python
  - Bash/Shell
  - R
  - Groovy
  - YAML
  - JSON
- Line numbers support
- Better contrast and readability

### 9. Improved Post Display
- Reading time on post list
- Better tag styling with gradient backgrounds
- Enhanced excerpt display
- Smooth hover effects on post cards

### 10. Better Typography
- Improved line spacing
- Better heading hierarchy
- Enhanced blockquote styling
- Professional table styling

## 📝 How to Use Features

### Enable Table of Contents
Add to your post front matter:
```yaml
toc: true
```

### Configure Social Links
Edit `_config.yml`:
```yaml
social:
  github: yourusername
  twitter: yourusername
  linkedin: yourusername
  email: your.email@example.com
```

### Customize Colors
Edit CSS variables in `assets/css/main.css`:
```css
:root {
  --primary-color: #1976D2;
  --secondary-color: #4CAF50;
  --accent-color: #FF9800;
  /* ... */
}
```

## 🎯 Best Practices

1. **Use tags and categories** - Helps with organization and related posts
2. **Add excerpts** - Makes post list more engaging
3. **Use TOC for long posts** - Improves navigation
4. **Include images** - They'll be automatically styled nicely
5. **Use code blocks** - Syntax highlighting is automatic

## 📱 Mobile Optimization

- Navigation collapses nicely on mobile
- Touch-friendly buttons and links
- Optimized font sizes
- Responsive images
- Fast loading

## 🔧 Technical Details

- **CSS Variables** - Easy theming system
- **Modern CSS** - Flexbox, Grid, and animations
- **Accessibility** - Semantic HTML and ARIA labels
- **Performance** - Optimized CSS and minimal JavaScript
- **SEO Ready** - Proper meta tags and structure

## 🚀 Future Enhancements (Optional)

Consider adding:
- Search functionality
- Dark mode toggle
- Comment system (Disqus, Giscus)
- Newsletter signup
- Analytics integration
- Social sharing buttons

Enjoy your beautiful, feature-rich blog! 🎉

