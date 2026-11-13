# 🐷 SIBA Admin — Panel Web Oficial de Monitoreo (UFPSO)

Panel administrativo web oficial para el **Sistema de Bienestar Animal (SIBA)** de la **Universidad Francisco de Paula Santander Ocaña (UFPSO)**, enfocado en el seguimiento zootécnico y cumplimiento de la **Resolución 136 de 2020** y normativas del **ICA**.

---

## 🚀 Despliegue Inmediato en Vercel (Gratis en 2 Minutos)

### Opción 1: Despliegue con GitHub (Recomendado)
1. Sube esta carpeta `siba-admin-web` a tu repositorio en **GitHub**.
2. Entra a [vercel.com](https://vercel.com) e inicia sesión con GitHub.
3. Haz clic en **"Add New Project"** y selecciona tu repositorio.
4. Vercel detectará automáticamente el archivo `vercel.json` y el `index.html`.
5. Haz clic en **"Deploy"** y en 30 segundos tendrás tu enlace público (ejemplo: `https://siba-admin-ufpso.vercel.app`).

### Opción 2: Despliegue con Vercel CLI
```bash
npm install -g vercel
vercel
```

---

## ⚡ Conexión con Base de Datos Gratuita en Supabase

1. Crea tu cuenta gratuita en [supabase.com](https://supabase.com).
2. Crea un nuevo proyecto llamado `siba-db`.
3. Ve a la pestaña **SQL Editor** en el menú izquierdo de Supabase.
4. Abre el archivo `supabase_schema.sql` incluido en esta carpeta, copia todo el contenido y dale clic a **RUN**.
5. Ve a **Settings -> API** en Supabase y copia:
   - **Project URL** (ejemplo: `https://xyzcompany.supabase.co`)
   - **anon / public key**
6. En el panel web, haz clic en el botón de **Configuración (⚙️)** en el encabezado superior y pega tu URL y Key. ¡Listo! Cada vez que la app móvil sincronice, los datos aparecerán en tiempo real.

---

## 📊 Funcionalidades del Panel Administrativo

- **Monitoreo en Tiempo Real:** Visualización de todas las evaluaciones realizadas en campo por docentes, evaluadores y operarios.
- **Exportación Oficial a Excel (.xlsx):** Genera la sábana consolidada o la ficha individual estructurada mediante SheetJS.
- **Gráficos Bioestadísticos:** Promedios de cumplimiento normativo por categoría (Recursos, Animal, Gestión) con Chart.js.
- **Semáforo Cromático de Bienestar:** Excelente (verde), Bueno (amarillo), Regular (naranja) y Crítico (rojo).
- **Evidencias Fotográficas:** Consulta in situ de fotografías capturadas con la cámara del celular.
- **Biblioteca Normativa en Línea:** Acceso directo a las resoluciones del Ministerio de Agricultura y metodologías del ICA en PDF.
