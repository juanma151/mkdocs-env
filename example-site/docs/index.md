---
title: Indice
description: El índice
---

# MkDocs – Test básico

Esta es una página de prueba para comprobar que tu entorno Nix de MkDocs funciona correctamente.

## Comprobaciones

- ✅ MkDocs y mkdocs-material se cargan correctamente.
- ✅ El tema **Material** se aplica (mira el aspecto del sitio).
- ✅ El plugin `mermaidxform` se puede importar sin error de MkDocs.

Prueba a ejecutar:

```bash
nix develop .#mkdocs-pdf
cd example-site
mkdocs serve
```

