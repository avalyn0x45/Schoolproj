// addons/addon-fit/src/FitAddon.ts
var MINIMUM_COLS = 2;
var MINIMUM_ROWS = 1;
var FitAddon = class {
  activate(terminal) {
    this._terminal = terminal;
  }
  dispose() {
  }
  fit() {
    const dims = this.proposeDimensions();
    if (!dims || !this._terminal || isNaN(dims.cols) || isNaN(dims.rows)) {
      return;
    }
    const core = this._terminal._core;
    if (this._terminal.rows !== dims.rows || this._terminal.cols !== dims.cols) {
      core._renderService.clear();
      this._terminal.resize(dims.cols, dims.rows);
    }
  }
  proposeDimensions() {
    if (!this._terminal) {
      return void 0;
    }
    if (!this._terminal.element || !this._terminal.element.parentElement) {
      return void 0;
    }
    const core = this._terminal._core;
    const dims = core._renderService.dimensions;
    if (dims.css.cell.width === 0 || dims.css.cell.height === 0) {
      return void 0;
    }
    const scrollbarWidth = this._terminal.options.scrollback === 0 ? 0 : this._terminal.options.overviewRuler?.width || 14 /* DEFAULT_SCROLL_BAR_WIDTH */;
    const parentElementStyle = window.getComputedStyle(this._terminal.element.parentElement);
    const parentElementHeight = parseInt(parentElementStyle.getPropertyValue("height"));
    const parentElementWidth = Math.max(0, parseInt(parentElementStyle.getPropertyValue("width")));
    const elementStyle = window.getComputedStyle(this._terminal.element);
    const elementPadding = {
      top: parseInt(elementStyle.getPropertyValue("padding-top")),
      bottom: parseInt(elementStyle.getPropertyValue("padding-bottom")),
      right: parseInt(elementStyle.getPropertyValue("padding-right")),
      left: parseInt(elementStyle.getPropertyValue("padding-left"))
    };
    const elementPaddingVer = elementPadding.top + elementPadding.bottom;
    const elementPaddingHor = elementPadding.right + elementPadding.left;
    const availableHeight = parentElementHeight - elementPaddingVer;
    const availableWidth = parentElementWidth - elementPaddingHor - scrollbarWidth;
    const geometry = {
      cols: Math.max(MINIMUM_COLS, Math.floor(availableWidth / dims.css.cell.width)),
      rows: Math.max(MINIMUM_ROWS, Math.floor(availableHeight / dims.css.cell.height))
    };
    return geometry;
  }
};
export {
  FitAddon
};
/**
 * Copyright (c) 2024 The xterm.js authors. All rights reserved.
 * @license MIT
 */
/**
 * Copyright (c) 2017 The xterm.js authors. All rights reserved.
 * @license MIT
 */
//# sourceMappingURL=addon-fit.mjs.map
