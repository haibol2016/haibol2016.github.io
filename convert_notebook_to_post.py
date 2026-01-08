#!/usr/bin/env python3
"""
Convert Jupyter Notebook to Jekyll blog post

Usage:
    python convert_notebook_to_post.py notebook.ipynb [--date YYYY-MM-DD] [--title "Post Title"]

This script converts a Jupyter notebook to a Markdown file suitable for Jekyll,
preserving code cells, outputs, and markdown cells.
"""

import json
import sys
import argparse
from datetime import datetime
from pathlib import Path

def convert_notebook_to_markdown(notebook_path, output_path=None, date=None, title=None):
    """Convert a Jupyter notebook to Jekyll markdown format."""
    
    # Read notebook
    with open(notebook_path, 'r', encoding='utf-8') as f:
        notebook = json.load(f)
    
    # Extract metadata
    if title is None:
        title = notebook.get('metadata', {}).get('title', Path(notebook_path).stem.replace('_', ' ').title())
    
    if date is None:
        date = datetime.now().strftime('%Y-%m-%d')
    
    # Generate filename
    if output_path is None:
        safe_title = title.lower().replace(' ', '-').replace('_', '-')
        safe_title = ''.join(c for c in safe_title if c.isalnum() or c == '-')
        output_path = f"_posts/{date}-{safe_title}.md"
    
    # Start building markdown
    front_matter = f"""---
layout: post
title: "{title}"
date: {date}
categories: [data-science, tutorial]
tags: [jupyter, python, data-analysis]
author: {get_author()}
---
"""
    
    markdown_content = [front_matter]
    
    # Process cells
    for cell in notebook.get('cells', []):
        cell_type = cell.get('cell_type')
        
        if cell_type == 'markdown':
            # Markdown cell - add directly
            source = ''.join(cell.get('source', []))
            markdown_content.append(source)
            markdown_content.append('\n')
        
        elif cell_type == 'code':
            # Code cell
            source = ''.join(cell.get('source', []))
            
            # Determine language from metadata or default to python
            language = 'python'
            if 'metadata' in cell:
                if 'language' in cell['metadata']:
                    language = cell['metadata']['language']
                elif 'kernelspec' in notebook.get('metadata', {}):
                    kernel = notebook['metadata']['kernelspec'].get('name', '')
                    if 'r' in kernel.lower():
                        language = 'r'
                    elif 'julia' in kernel.lower():
                        language = 'julia'
            
            # Add code block
            markdown_content.append(f"```{language}\n{source}\n```\n")
            
            # Add outputs if present
            outputs = cell.get('outputs', [])
            if outputs:
                markdown_content.append("\n**Output:**\n\n")
                for output in outputs:
                    output_type = output.get('output_type', '')
                    
                    if output_type == 'stream':
                        text = ''.join(output.get('text', []))
                        markdown_content.append(f"```\n{text}\n```\n")
                    
                    elif output_type == 'execute_result' or output_type == 'display_data':
                        # Try to get text/plain first
                        data = output.get('data', {})
                        if 'text/plain' in data:
                            text = ''.join(data['text/plain'])
                            markdown_content.append(f"```\n{text}\n```\n")
                        elif 'text/html' in data:
                            html = ''.join(data['text/html'])
                            markdown_content.append(f"\n{html}\n")
                        elif 'image/png' in data:
                            # Save image and reference it
                            image_data = data['image/png']
                            image_path = save_image(image_data, notebook_path, len(markdown_content))
                            markdown_content.append(f"![Output]({image_path})\n")
        
        elif cell_type == 'raw':
            # Raw cell - add as-is
            source = ''.join(cell.get('source', []))
            markdown_content.append(f"```\n{source}\n```\n")
    
    # Write output
    output_file = Path(output_path)
    output_file.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(''.join(markdown_content))
    
    print(f"✓ Converted notebook to: {output_file}")
    print(f"  Title: {title}")
    print(f"  Date: {date}")
    return output_file

def get_author():
    """Get author from config or default."""
    try:
        import yaml
        config_path = Path('_config.yml')
        if config_path.exists():
            with open(config_path, 'r') as f:
                config = yaml.safe_load(f)
                return config.get('author', 'Your Name')
    except:
        pass
    return 'Your Name'

def save_image(image_data, notebook_path, index):
    """Save base64 image and return path."""
    import base64
    
    # Create images directory for this notebook
    notebook_name = Path(notebook_path).stem
    images_dir = Path('assets/images/notebooks') / notebook_name
    images_dir.mkdir(parents=True, exist_ok=True)
    
    # Save image
    image_path = images_dir / f"output_{index}.png"
    
    # Handle base64 data (may include data:image/png;base64, prefix)
    if ',' in image_data:
        image_data = image_data.split(',')[1]
    
    image_bytes = base64.b64decode(image_data)
    with open(image_path, 'wb') as f:
        f.write(image_bytes)
    
    return f"/assets/images/notebooks/{notebook_name}/output_{index}.png"

def main():
    parser = argparse.ArgumentParser(description='Convert Jupyter notebook to Jekyll post')
    parser.add_argument('notebook', help='Path to Jupyter notebook (.ipynb)')
    parser.add_argument('--date', help='Post date (YYYY-MM-DD)', default=None)
    parser.add_argument('--title', help='Post title', default=None)
    parser.add_argument('--output', help='Output file path', default=None)
    
    args = parser.parse_args()
    
    if not Path(args.notebook).exists():
        print(f"Error: Notebook file not found: {args.notebook}")
        sys.exit(1)
    
    try:
        convert_notebook_to_markdown(
            args.notebook,
            args.output,
            args.date,
            args.title
        )
    except Exception as e:
        print(f"Error converting notebook: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()


