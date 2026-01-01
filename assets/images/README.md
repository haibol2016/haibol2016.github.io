# Images Directory

Place your blog post images in this directory.

## Usage in Markdown Posts

Reference images in your blog posts using one of these methods:

### Method 1: Using relative URL (Recommended)
```markdown
![Alt text]({{ "/assets/images/your-image.png" | relative_url }})
```

### Method 2: Using HTML img tag (for more control)
```html
<img src="{{ "/assets/images/your-image.png" | relative_url }}" alt="Alt text" />
```

### Method 3: Direct path (works but less flexible)
```markdown
![Alt text](/assets/images/your-image.png)
```

## Supported Formats
- PNG (.png)
- JPEG/JPG (.jpg, .jpeg)
- SVG (.svg)
- GIF (.gif)
- WebP (.webp)

## Example
If you have an image file named `diagram.png` in this directory, reference it in your post like this:

```markdown
![My Diagram]({{ "/assets/images/diagram.png" | relative_url }})
```

## Organizing Images
You can create subdirectories to organize images by post or topic:
- `assets/images/posts/2025/12/22/` - for post-specific images
- `assets/images/diagrams/` - for diagrams
- `assets/images/screenshots/` - for screenshots


