# IFrame Preview App

A modern TypeScript-based web application for previewing websites in an embedded iframe with flexible layout options.

## Features

- 🎨 **Modern UI** - Clean, user-friendly interface with a professional design
- 📱 **Responsive** - Works seamlessly on desktop, tablet, and mobile devices
- ⚡ **TypeScript** - Fully typed for better development experience and code reliability
- 🔄 **Flexible Layout** - Toggle between fixed and flexible height modes
- ⌨️ **Keyboard Support** - Press Enter to load URLs, full keyboard navigation
- 🎯 **URL Validation** - Automatic URL formatting and validation
- ♿ **Accessible** - ARIA labels and keyboard-friendly controls

## Tech Stack

- **TypeScript** - Type-safe JavaScript
- **Vite** - Fast build tool and dev server
- **Modern CSS** - CSS custom properties, flexbox, responsive design

## Getting Started

### Prerequisites

- Node.js (v16 or higher)
- npm or yarn

### Installation

```bash
# Install dependencies
npm install
```

### Development

```bash
# Start development server with hot reload
npm run dev
```

Open [http://localhost:5173](http://localhost:5173) in your browser.

### Build

```bash
# Type check
npm run type-check

# Build for production
npm run build

# Preview production build
npm run preview
```

## Usage

1. Enter any website URL in the input field (e.g., `example.com` or `https://example.com`)
2. Click "Load Preview" or press Enter
3. The website will load in the iframe below
4. Toggle "Flexible height" to make the iframe fill the available space

## Project Structure

```
gift-a.github.io/
├── src/
│   ├── main.ts        # Main TypeScript application code
│   └── styles.css     # Modern CSS styles
├── dist/              # Production build output
├── index.html         # Main HTML template
├── package.json       # Project dependencies
├── tsconfig.json      # TypeScript configuration
├── vite.config.ts     # Vite build configuration
└── README.md          # This file
```

## Features Explained

### URL Formatting

The app automatically adds `https://` to URLs that don't have a protocol, making it easier to quickly preview websites.

### Flexible Height Mode

When enabled, the iframe will resize to fill the available vertical space, perfect for viewing full-page content without scrolling.

### Error Handling

Invalid URLs are caught and displayed with visual feedback (red border on input field).

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)

## Live Demo

https://gift-a.github.io/

## License

MIT
