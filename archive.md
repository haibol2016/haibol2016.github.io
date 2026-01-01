---
layout: default
title: Archive
---

# Archive

All posts organized by year.

{% if site.posts.size > 0 %}
  {% assign date = "" %}
{% for post in site.posts %}
  {% assign currentdate = post.date | date: "%Y" %}
  {% if currentdate != date %}
      {% unless forloop.first %}</ul></div>{% endunless %}
    <div class="archive-year">
      <h2 id="y{{post.date | date: "%Y"}}">{{ currentdate }}</h2>
      <ul class="archive-posts">
    {% assign date = currentdate %}
  {% endif %}
    <li class="archive-item">
      <span class="archive-date">{{ post.date | date: "%b %-d" }}</span>
      <a class="archive-link" href="{{ post.url | relative_url }}">{{ post.title | escape }}</a>
        </li>
  {% if forloop.last %}</ul></div>{% endif %}
{% endfor %}
{% else %}
  <p>No posts found.</p>
{% endif %}

