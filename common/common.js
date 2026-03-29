class Watermark extends HTMLElement {
  connectedCallback() {
    this.innerHTML = `<img src="/common/waterMark.webp" class="watermark" />`;
  }
}
customElements.define("ll06-watermark", Watermark);
class Copyright extends HTMLElement {
  connectedCallback() {
    const date = new Date();
    this.innerHTML = `&copy; ${date.getFullYear()} LordLichi, All rights reserved.`;
  }
}
customElements.define("ll06-copyright", Copyright);
