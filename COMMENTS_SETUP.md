# Comment System Setup Guide

This blog supports comments using **Giscus** (recommended) or **Disqus**. Giscus is free, privacy-friendly, and uses GitHub Discussions.

## Setting Up Giscus (Recommended)

### Step 1: Install Giscus GitHub App

**IMPORTANT**: You must install the Giscus app first!

1. Go to **https://github.com/apps/giscus**
2. Click **Install** or **Configure**
3. Select your account/organization
4. Choose which repositories to grant access:
   - **All repositories** (recommended), OR
   - **Only select repositories** → Choose `haibol2016.github.io`
5. Click **Install** or **Save**
6. Grant the requested permissions

### Step 2: Enable GitHub Discussions

1. Go to your GitHub repository: `https://github.com/haibol2016/haibol2016.github.io`
2. Click **Settings** → **General**
3. Scroll down to **Features**
4. Check **Discussions** to enable it
5. Click **Set up discussions**

### Step 3: Create a Discussion Category

1. In your repository, go to **Discussions** tab
2. Create a category (e.g., "Announcements" or "General")
3. Note the category name

### Step 4: Get Giscus Configuration

1. Go to **https://giscus.app/**
2. Sign in with your GitHub account
3. Select your repository: `haibol2016/haibol2016.github.io`
   - If you see "giscus is not installed", go back to Step 1
4. Choose the discussion category you created
5. Configure settings:
   - **Page ↔ Discussions mapping**: Pathname
   - **Discussion category**: Select your category
   - **Features**: Enable reactions, enable input position (bottom)
   - **Theme**: Light (or match your site theme)
6. Copy the configuration values shown

### Step 5: Update `_config.yml`

Edit `_config.yml` and update the `giscus` section with your values:

```yaml
giscus:
  repo: "haibol2016/haibol2016.github.io"
  repo_id: "YOUR_REPO_ID"  # From giscus.app
  category: "Announcements"  # Your category name
  category_id: "YOUR_CATEGORY_ID"  # From giscus.app
```

### Step 6: Deploy

1. Commit and push your changes
2. Wait for GitHub Pages to rebuild
3. Comments will appear at the bottom of each blog post

## Alternative: Disqus Setup

If you prefer Disqus:

1. Sign up at **https://disqus.com/**
2. Create a site
3. Get your Disqus shortname
4. In `_config.yml`, comment out the `giscus` section and uncomment `disqus`:

```yaml
# giscus:
#   repo: "haibol2016/haibol2016.github.io"
#   ...

disqus:
  shortname: "your-disqus-shortname"
```

## Customization

You can customize the comment appearance by editing `_includes/comments.html`:
- Change theme (light/dark)
- Adjust position
- Modify styling in the `<style>` section

## Troubleshooting

- **"giscus is not installed on this repository"**: 
  - Go to https://github.com/apps/giscus and install the app
  - Grant access to your repository
  - Wait a few minutes and try again
- **Comments not showing**: 
  - Make sure GitHub Discussions is enabled in your repository
  - Verify Giscus app is installed (see above)
  - Check browser console for errors
- **Wrong repository**: Verify the `repo` field matches your GitHub repository
- **Category not found**: Ensure the category exists and matches exactly (case-sensitive)

