---
title: Introducing `presenterm`
sub_title: (from a sand castle)
author: github.com/loicreynier
theme:
  name: dark
  override:
    default:
      colors:
        background: 1e1e1e
---

<!-- markdownlint-disable MD025 -->

Title slide

The title slide can be defined by using a YAML frontmatter block
at the beginning of the Markdown file:

```yaml
---
title: My presentation title
sub_title: An optional subtitle
author: Author name
---
```

The slide's theme can also be configured in the front matter:

```yaml
---
theme:
  name: dark # from built-in themes
  path: ./themes/epic.yaml # or specify the path for it
  override: # or override part of the them
    default:
      colors:
        foreground: white
---
```

<!-- end_slide -->

## Slides

The slide is delimited by a CommonMark setext header
and a `end_slide` HTML command:

```markdown
## Title

## Subheaders

### ... and more

<!-- end_slide -->
```

---

# Pauses

Slides can be paused by using the `pause` HTML command:

```html
<!-- pause -->
```

This allows you to:

<!-- pause -->

- Create suspense.
<!-- pause -->
- Have more interactive presentations.
<!-- pause -->
- Possibly more!

# Columns

<!-- column_layout: [2, 1] -->

<!-- column: 0 -->

Column layouts let you
organize content into columns.

<!-- column: 1 -->

```markdown
<!-- column_layout: [2, 1] -->

<!-- column: 0 -->

Column layouts let you
organize content into columns.

<!-- column: 1 -->

...

<!-- reset_layout -->
```

<!-- reset_layout -->
