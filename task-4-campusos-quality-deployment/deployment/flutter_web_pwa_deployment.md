# CampusOS --- Flutter Web & PWA Deployment Guide

**Document Version:** 1.0  
**Phase:** Task 4 / Phase 1 — Development Infrastructure  
**Author:** Ansh (QA & Deployment Lead)  
**Authoritative References:**  
- [02_SRD.md Section 13](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/02_SRD.md#L384-L402)
- [05_ANTIGRAVITY_GITHUB_EXECUTION.md Section 16](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/05_ANTIGRAVITY_GITHUB_EXECUTION.md#L682-L710)

---

## 1. Overview

CampusOS is delivered as a high-performance Flutter Web application and an installable Progressive Web App (PWA). The single codebase serves both desktop browser administration and responsive mobile student interfaces.

Release builds are produced using:
```bash
flutter build web --release
```

---

## 2. Prerequisites & Build Configuration

### 2.1 Web Renderer Strategy
Flutter Web supports two rendering pipelines:
1. **CanvasKit / Skia** (Default on desktop): High graphical fidelity, smooth animations, identical font rendering across platforms.
2. **HTML / CanvasKit Auto** (Default on mobile): Faster initial download for mobile devices.

Recommended production build command:
```bash
flutter build web --release \
  --web-renderer auto \
  --dart-define=SUPABASE_URL="https://YOUR_PROJECT_REF.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR_PUBLIC_ANON_KEY"
```

### 2.2 PWA Manifest Configuration (`web/manifest.json`)
Ensure `web/manifest.json` matches the CampusOS branding:

```json
{
  "name": "CampusOS - Campus Operating Layer",
  "short_name": "CampusOS",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0F172A",
  "theme_color": "#2563EB",
  "description": "Smart, trackable campus workflows and intelligence platform.",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-maskable-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable"
    },
    {
      "src": "icons/Icon-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ]
}
```

### 2.3 Single-Page Application (SPA) URL Strategy
Flutter Web uses HTML5 path URL routing (e.g., `/student/issues` rather than `/#/student/issues`).  
**Crucial Requirement**: Any web server serving CampusOS must redirect 404 routes back to `/index.html` with HTTP 200 so the Flutter client router handles the path directly.

---

## 3. Hosting Platform Recipes

### 3.1 Vercel Deployment
Create `vercel.json` in the web root or repository root:
```json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options", "value": "SAMEORIGIN" }
      ]
    }
  ]
}
```

Deploy command:
```bash
vercel deploy --prod build/web
```

---

### 3.2 Netlify Deployment
Create `_redirects` file inside `build/web/`:
```text
/*    /index.html   200
```

Deploy command:
```bash
netlify deploy --prod --dir=build/web
```

---

### 3.3 GitHub Pages Deployment
For GitHub Pages hosting, copy `build/web/index.html` to `build/web/404.html` so direct deep links trigger the Flutter engine:
```bash
cp build/web/index.html build/web/404.html
```

---

### 3.4 Docker & Nginx Deployment
For containerized deployments or self-hosted servers, use the preconfigured Docker template in:
`task-4-campusos-quality-deployment/deployment/docker/Dockerfile`

Run:
```bash
docker build -t campusos-web -f task-4-campusos-quality-deployment/deployment/docker/Dockerfile .
docker run -p 8080:80 campusos-web
```
Access at `http://localhost:8080`.

---

## 4. Verification Post-Deployment

1. Open site in Chrome or Safari.
2. Check browser address bar for padlock icon (HTTPS confirmed).
3. Check browser DevTools -> Application tab -> Manifest (manifest loaded without errors).
4. Refresh on `/student/issues` to verify SPA fallback does not return a 404 error page.
