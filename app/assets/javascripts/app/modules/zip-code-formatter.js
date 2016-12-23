import { DelimitedTextFormatter } from 'field-kit';

/**
 * @const
 * @private
 */
const DIGITS_PATTERN = /^[A-Za-z0-9]*$/;

/**
 * @extends DelimitedTextFormatter
 */
class ZipCodeFormatter extends DelimitedTextFormatter {
  constructor() {
    super(' ', true);
    this.maximumLength = 6 + 1;
  }

  /**
   * @param {number} index
   * @returns {boolean}
   */
  hasDelimiterAtIndex(index) {
    return index === 3;
  }

  /**
   * Determines whether the given change should be allowed and, if so, whether
   * it should be altered.
   *
   * @param {TextFieldStateChange} change
   * @param {function(string)} error
   * @returns {boolean}
   */
  isChangeValid(change, error) {
    change.proposed.text = change.proposed.text.toUpperCase();
    if (DIGITS_PATTERN.test(change.inserted.text)) {
      return super.isChangeValid(change, error);
    }

    return false;
  }
}

export default ZipCodeFormatter;
