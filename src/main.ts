/**
 * IFrame Preview Application
 * Allows users to preview any website in an embedded iframe with flexible layout options
 */

interface IFrameControls {
  button: HTMLButtonElement;
  input: HTMLInputElement;
  iframe: HTMLIFrameElement;
  iframeContainer: HTMLElement;
  checkBox: HTMLInputElement;
}

class IFramePreviewApp {
  private controls: IFrameControls;
  private resizeObserver: ResizeObserver | null = null;

  constructor() {
    this.controls = this.initializeControls();
    this.attachEventListeners();
  }

  private initializeControls(): IFrameControls {
    const button = document.getElementById('iframe-button') as HTMLButtonElement;
    const input = document.getElementById('iframe-input') as HTMLInputElement;
    const iframe = document.getElementById('iframe') as HTMLIFrameElement;
    const checkBox = document.getElementById('iframe-checkbox') as HTMLInputElement;

    if (!button || !input || !iframe || !checkBox) {
      throw new Error('Required DOM elements not found');
    }

    const iframeContainer = iframe.parentElement;
    if (!iframeContainer) {
      throw new Error('IFrame container not found');
    }

    return { button, input, iframe, iframeContainer, checkBox };
  }

  private attachEventListeners(): void {
    // Load button click handler
    this.controls.button.addEventListener('click', () => this.loadUrl());

    // Enter key in input field
    this.controls.input.addEventListener('keypress', (e: KeyboardEvent) => {
      if (e.key === 'Enter') {
        this.loadUrl();
      }
    });

    // Flexible height toggle
    this.controls.checkBox.addEventListener('change', (event: Event) => {
      const target = event.target as HTMLInputElement;
      this.toggleFlexibleHeight(target.checked);
    });
  }

  private loadUrl(): void {
    const url = this.controls.input.value.trim();

    if (!url) {
      this.showError('Please enter a URL');
      return;
    }

    // Ensure URL has a protocol
    const formattedUrl = this.formatUrl(url);

    try {
      new URL(formattedUrl); // Validate URL
      this.controls.iframe.src = formattedUrl;
      this.clearError();
    } catch {
      this.showError('Please enter a valid URL');
    }
  }

  private formatUrl(url: string): string {
    if (!/^https?:\/\//i.test(url)) {
      return `https://${url}`;
    }
    return url;
  }

  private toggleFlexibleHeight(enabled: boolean): void {
    if (enabled) {
      this.enableFlexibleHeight();
    } else {
      this.disableFlexibleHeight();
    }
  }

  private enableFlexibleHeight(): void {
    const { iframe, iframeContainer } = this.controls;

    document.body.classList.add('is-flexible');
    iframe.style.height = '0px';

    // Allow time for layout to settle
    setTimeout(() => {
      this.updateIframeSize();
    }, 100);

    // Set up resize observer
    this.resizeObserver = new ResizeObserver(() => {
      iframe.style.height = '0px';
      requestAnimationFrame(() => {
        this.updateIframeSize();
      });
    });

    this.resizeObserver.observe(iframeContainer);
  }

  private disableFlexibleHeight(): void {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
      this.resizeObserver = null;
    }

    document.body.classList.remove('is-flexible');
    this.controls.iframe.style.height = '600px';
    this.controls.iframe.style.width = '';
  }

  private updateIframeSize(): void {
    const { iframe, iframeContainer } = this.controls;
    const rect = iframeContainer.getBoundingClientRect();

    iframe.style.height = `${rect.height - 8}px`;
    iframe.style.width = `${rect.width}px`;
  }

  private showError(message: string): void {
    this.controls.input.setAttribute('aria-invalid', 'true');
    this.controls.input.title = message;
    this.controls.input.classList.add('error');
  }

  private clearError(): void {
    this.controls.input.removeAttribute('aria-invalid');
    this.controls.input.title = '';
    this.controls.input.classList.remove('error');
  }
}

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  new IFramePreviewApp();
});
