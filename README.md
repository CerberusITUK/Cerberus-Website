## Cerberus Website

Cerberus IT's marketing site for showcasing services, insight hubs, and supporting staff content. Built as a static HTML/CSS/JS experience with custom animations and video-driven cards.

### Project structure
- `index.html` – main page markup
- `styles.css` – global styling, component layouts, animations
- `scripts/features.js` – interactive behaviors (parallax, video ping-pong, tabs, etc.)
- `assets/` – images, videos, and fonts

### Local development
1. Open the project folder (`/Users/dan/Documents/web-tests/orbi-3-3`).
2. Edit HTML/CSS/JS files directly (no build step required).
3. Use a simple static server (e.g., `npx serve .`) or a Live Server extension to preview `index.html` while editing.

### Git workflow
```bash
# after making changes
git status
git add <files>
git commit -m "Describe update"
git push origin main
```

### Deployment
Current hosting is manual. To deploy elsewhere (Netlify, Vercel, S3, etc.), point the service at this repo or upload the static files from the project root.
