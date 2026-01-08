# Using Jupyter Notebooks as Blog Posts

Yes! You can use Jupyter notebooks as blog posts. This guide shows you how.

## 🎯 Quick Start

### Option 1: Convert Notebook to Markdown (Recommended)

Use the provided conversion script:

```bash
cd blog
python3 convert_notebook_to_post.py your_notebook.ipynb --date 2026-01-15 --title "Your Post Title"
```

This will:
- Convert your notebook to a Markdown file in `_posts/`
- Preserve code cells with syntax highlighting
- Save output images to `assets/images/notebooks/`
- Generate proper Jekyll front matter

### Option 2: Manual Conversion

1. **Export notebook to Markdown**:
   ```bash
   jupyter nbconvert --to markdown your_notebook.ipynb
   ```

2. **Add Jekyll front matter** to the generated `.md` file:
   ```yaml
   ---
   layout: post
   title: "Your Post Title"
   date: 2026-01-15
   categories: [data-science, tutorial]
   tags: [jupyter, python, data-analysis]
   author: Your Name
   ---
   ```

3. **Move to `_posts/`** with proper naming:
   ```bash
   mv your_notebook.md _posts/2026-01-15-your-post-title.md
   ```

4. **Move images** to `assets/images/` and update paths in the markdown

---

## 📝 Detailed Instructions

### Using the Conversion Script

1. **Place your notebook** in the blog directory (or any location)

2. **Run the conversion**:
   ```bash
   python3 convert_notebook_to_post.py \
     notebooks/my_analysis.ipynb \
     --date 2026-01-15 \
     --title "My Data Analysis Tutorial"
   ```

3. **Review the generated post** in `_posts/`

4. **Edit if needed**:
   - Update categories and tags
   - Add description for SEO
   - Adjust formatting
   - Add more context

5. **Test locally**:
   ```bash
   bundle exec jekyll serve
   ```

6. **Deploy**:
   ```bash
   git add _posts/2026-01-15-my-data-analysis-tutorial.md
   git commit -m "Add notebook post: My Data Analysis Tutorial"
   git push
   ```

---

## 🔧 Advanced Usage

### Custom Output Path

```bash
python3 convert_notebook_to_post.py notebook.ipynb \
  --output _posts/2026-01-15-custom-name.md \
  --title "Custom Title"
```

### Preserve Notebook Metadata

The script automatically extracts:
- Title from notebook metadata (if available)
- Language from kernel specification
- Code cells with proper syntax highlighting

### Handling Images

The script automatically:
- Extracts images from notebook outputs
- Saves them to `assets/images/notebooks/notebook-name/`
- Updates image references in the markdown

---

## 📊 Best Practices

### 1. Clean Up Your Notebook First

Before converting:
- Remove unnecessary cells
- Add clear markdown explanations
- Ensure code is well-commented
- Test that all cells run successfully

### 2. Add Context

After conversion, enhance the markdown:
- Add an introduction
- Explain the methodology
- Add conclusions
- Include links to related posts

### 3. Optimize Images

- Use high-quality images for outputs
- Compress large images
- Use descriptive alt text
- Consider using SVG for plots when possible

### 4. Code Formatting

The script preserves code cells. Ensure:
- Code is readable
- Comments are clear
- Variable names are descriptive
- Follows Python/R best practices

---

## 🎨 Example Workflow

### Step 1: Create Your Notebook

```python
# In your Jupyter notebook
# Cell 1 (Markdown):
# # My Data Analysis Tutorial
# 
# This tutorial shows how to analyze RNA-seq data.

# Cell 2 (Code):
import pandas as pd
import matplotlib.pyplot as plt

# Cell 3 (Code):
data = pd.read_csv('data.csv')
data.head()
```

### Step 2: Convert

```bash
python3 convert_notebook_to_post.py \
  rnaseq_analysis.ipynb \
  --date 2026-01-15 \
  --title "RNA-seq Data Analysis Tutorial"
```

### Step 3: Review Generated Post

The generated file will have:
- Proper front matter
- Code blocks with syntax highlighting
- Outputs preserved
- Images saved and referenced

### Step 4: Enhance

Edit the generated markdown to add:
- Better introduction
- More explanations
- Links to resources
- Related posts section

---

## 🚀 Alternative: Using nbconvert Directly

If you prefer more control:

```bash
# Convert to markdown
jupyter nbconvert --to markdown notebook.ipynb

# This creates:
# - notebook.md (markdown file)
# - notebook_files/ (images directory)

# Then manually:
# 1. Add Jekyll front matter
# 2. Move to _posts/ with date prefix
# 3. Move images to assets/images/
# 4. Update image paths in markdown
```

---

## 🔍 Troubleshooting

### Images Not Showing?

1. Check image paths are relative to site root
2. Ensure images are in `assets/images/`
3. Use `{{ "/assets/images/..." | relative_url }}` in markdown

### Code Not Highlighting?

- Ensure language is specified in code blocks
- Check that Prism.js is loading (already configured)
- Verify code block syntax: ` ```python ` not ` ``` python `

### Outputs Not Preserved?

- The script preserves text outputs automatically
- For HTML outputs, they're embedded directly
- For images, they're saved and referenced

### Date Format Issues?

- Use format: `YYYY-MM-DD`
- Example: `2026-01-15`
- The script validates the format

---

## 📚 Additional Resources

- [Jupyter nbconvert Documentation](https://nbconvert.readthedocs.io/)
- [Jekyll Markdown Guide](https://jekyllrb.com/docs/posts/)
- [Jupyter Best Practices](https://jupyter-notebook.readthedocs.io/)

---

## 💡 Tips

1. **Keep notebooks organized**: Use clear cell structure
2. **Add markdown cells**: Explain what each code section does
3. **Test before converting**: Ensure notebook runs without errors
4. **Review output**: Check the generated markdown looks good
5. **Version control**: Keep both `.ipynb` and `.md` files if needed

---

**Ready to convert your first notebook?** Run the script and see your Jupyter notebook become a beautiful blog post! 🎉


