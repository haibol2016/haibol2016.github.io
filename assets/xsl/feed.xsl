<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:atom="http://www.w3.org/2005/Atom">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>
  
  <xsl:template match="/">
    <html>
      <head>
        <title>RSS Feed - <xsl:value-of select="atom:feed/atom:title"/></title>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <style>
          * {
            box-sizing: border-box;
          }
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: #24292e;
            background: #fff;
            margin: 0;
            padding: 20px;
          }
          .container {
            max-width: 800px;
            margin: 0 auto;
          }
          header {
            border-bottom: 1px solid #e1e4e8;
            padding-bottom: 20px;
            margin-bottom: 30px;
          }
          h1 {
            color: #24292e;
            margin: 0 0 10px 0;
            font-size: 2em;
          }
          .subtitle {
            color: #586069;
            margin: 10px 0;
          }
          .feed-info {
            background: #f6f8fa;
            border: 1px solid #e1e4e8;
            border-radius: 6px;
            padding: 15px;
            margin: 20px 0;
          }
          .feed-info p {
            margin: 5px 0;
          }
          .feed-info a {
            color: #0366d6;
            text-decoration: none;
          }
          .feed-info a:hover {
            text-decoration: underline;
          }
          .entry {
            border-bottom: 1px solid #e1e4e8;
            padding: 20px 0;
          }
          .entry:last-child {
            border-bottom: none;
          }
          .entry-title {
            margin: 0 0 10px 0;
          }
          .entry-title a {
            color: #0366d6;
            text-decoration: none;
            font-size: 1.3em;
            font-weight: 600;
          }
          .entry-title a:hover {
            text-decoration: underline;
          }
          .entry-meta {
            color: #586069;
            font-size: 0.9em;
            margin: 10px 0;
          }
          .entry-content {
            margin: 15px 0;
            color: #24292e;
          }
          .entry-content p {
            margin: 10px 0;
          }
          .entry-link {
            display: inline-block;
            margin-top: 10px;
            color: #0366d6;
            text-decoration: none;
          }
          .entry-link:hover {
            text-decoration: underline;
          }
          footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #e1e4e8;
            text-align: center;
            color: #586069;
            font-size: 0.9em;
          }
          @media (max-width: 768px) {
            body {
              padding: 15px;
            }
            h1 {
              font-size: 1.5em;
            }
          }
        </style>
      </head>
      <body>
        <div class="container">
          <header>
            <h1><xsl:value-of select="atom:feed/atom:title"/></h1>
            <div class="subtitle"><xsl:value-of select="atom:feed/atom:subtitle"/></div>
            <div class="feed-info">
              <p><strong>Author:</strong> <xsl:value-of select="atom:feed/atom:author/atom:name"/></p>
              <p><strong>Updated:</strong> <xsl:value-of select="atom:feed/atom:updated"/></p>
              <p><strong>Website:</strong> <a href="{atom:feed/atom:link[@rel='alternate']/@href}"><xsl:value-of select="atom:feed/atom:link[@rel='alternate']/@href"/></a></p>
              <p><strong>Feed URL:</strong> <a href="{atom:feed/atom:link[@rel='self']/@href}"><xsl:value-of select="atom:feed/atom:link[@rel='self']/@href"/></a></p>
            </div>
          </header>
          
          <div class="entries">
            <xsl:for-each select="atom:feed/atom:entry">
              <div class="entry">
                <h2 class="entry-title">
                  <a href="{atom:link/@href}">
                    <xsl:value-of select="atom:title"/>
                  </a>
                </h2>
                <div class="entry-meta">
                  <strong>Published:</strong> <xsl:value-of select="atom:published"/>
                  <xsl:if test="atom:updated != atom:published">
                    | <strong>Updated:</strong> <xsl:value-of select="atom:updated"/>
                  </xsl:if>
                </div>
                <div class="entry-content">
                  <xsl:value-of select="atom:content" disable-output-escaping="yes"/>
                </div>
                <a href="{atom:link/@href}" class="entry-link">Read full article →</a>
              </div>
            </xsl:for-each>
          </div>
          
          <footer>
            <p>This is an RSS feed. Subscribe using an <a href="/feed.html">RSS reader</a> to stay updated.</p>
          </footer>
        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

