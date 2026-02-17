# Architectus Documentation - Claude Instructions

## Overview

Public documentation hub for architectus.dev. Hub-and-spoke Antora architecture.

## Key Files

- `antora-playbook.yml` - Site configuration, component sources
- `docs/antora.yml` - Home component with global attributes
- `docs/modules/ROOT/nav.adoc` - Navigation structure
- `docs/modules/ROOT/pages/` - Content pages

## Attributes

All reusable values defined in `docs/antora.yml`. Use attributes instead of hardcoding:

```asciidoc
// CORRECT
{author-cervantes} wrote {book-quijote}.

// WRONG
Miguel de Cervantes wrote Don Quijote.
```

## Bilingual Content

- English: `pages/*.adoc` (default)
- Spanish: `pages/lang/es/*.adoc`

## Content Domains

| Domain | Description |
|--------|-------------|
| technology | IT, security, networking, automation |
| literature | Cervantes, García Márquez, Reina Valera |
| mathematics | Foundations, applications |
| music | Theory, composition |
| languages | Spanish B2→C2 journey |
| philosophy | Faith, reason, worldview |

## Build Commands

```bash
make          # Build site
make serve    # Build and serve locally
make clean    # Remove build artifacts
```

## Public Site

This is PUBLIC content. Do not include:
- Internal IPs or hostnames
- Credentials or secrets
- Employer-specific information
- Consulting/business details

## Style

- Professional but personal
- Faith content: thoughtful, not preachy
- Literature: academic engagement
- Technology: vendor-agnostic concepts + vendor-specific implementation
