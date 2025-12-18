# Deploying Your Blog to GitHub Pages

This guide will help you deploy your Jekyll blog to GitHub Pages.

## Step 1: Create GitHub Repository

### Option A: Using GitHub Web Interface (Recommended)

1. Go to [GitHub](https://github.com) and sign in
2. Click the **"+"** icon in the top right corner
3. Select **"New repository"**
4. Repository settings:
   - **Repository name**: `yourusername.github.io` (replace `yourusername` with your GitHub username)
   - **Description**: "My bioinformatics and data science blog"
   - **Visibility**: Public (required for free GitHub Pages)
   - **DO NOT** initialize with README, .gitignore, or license
5. Click **"Create repository"**

### Option B: Using GitHub CLI

If you have GitHub CLI installed:

```bash
gh repo create yourusername.github.io --public --description "My bioinformatics and data science blog"
```

## Step 2: Initialize Git and Push to GitHub

Run these commands in your blog directory:

```bash
cd /Users/haiboliu/nextflow_general/blog

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Jekyll blog setup"

# Add remote repository (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_USERNAME.github.io.git

# Rename branch to main (if needed)
git branch -M main

# Push to GitHub
git push -u origin main
```

## Step 3: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** (top menu)
3. Scroll down to **Pages** (left sidebar)
4. Under **Source**, select:
   - **Branch**: `main`
   - **Folder**: `/ (root)`
5. Click **Save**

## Step 4: Configure GitHub Actions (Already Set Up!)

The blog already has GitHub Actions workflow configured (`.github/workflows/jekyll.yml`). 
Once you push to GitHub, it will automatically:
- Build your Jekyll site
- Deploy to GitHub Pages
- Rebuild on every push to main branch

## Step 5: Update Configuration

After deploying, update `_config.yml`:

```yaml
url: "https://YOUR_USERNAME.github.io"
baseurl: ""
```

Then commit and push:

```bash
git add _config.yml
git commit -m "Update site URL"
git push
```

## Step 6: Access Your Blog

Your blog will be available at:
- `https://YOUR_USERNAME.github.io`

**Note**: It may take a few minutes for the site to be available after the first deployment.

## Troubleshooting

### If GitHub Actions fails:
1. Check the **Actions** tab in your repository
2. Look for error messages
3. Common issues:
   - Missing dependencies (should be handled by Gemfile)
   - Build errors (check Jekyll build locally first)

### If site doesn't load:
1. Wait 5-10 minutes after first push
2. Check repository Settings > Pages for deployment status
3. Verify the Actions workflow completed successfully

### Custom Domain (Optional)

If you have a custom domain:
1. Add a `CNAME` file in the blog root with your domain
2. Configure DNS settings with your domain provider
3. Update `_config.yml` with your custom domain

## Future Updates

To update your blog:

```bash
cd /Users/haiboliu/nextflow_general/blog

# Make your changes
# ... edit files ...

# Add, commit, and push
git add .
git commit -m "Update: description of changes"
git push
```

GitHub Actions will automatically rebuild and deploy your site!

## Quick Reference

```bash
# Initial setup (one time)
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_USERNAME.github.io.git
git branch -M main
git push -u origin main

# Regular updates
git add .
git commit -m "Your commit message"
git push
```

Happy blogging! 🚀

