const I18n = window.LoginGov.I18n;

function pluralize(word, count) {
  return `${word}${count !== 1 ? 's' : ''}`;
}

function formatMinutes(minutes) {
  if (!minutes) return 0;

  return `${minutes} ${pluralize('minute', minutes)}`;
}

function formatSeconds(seconds) {
  return `${seconds} ${pluralize('second', seconds)}`;
}

export default (milliseconds) => {
  const seconds = milliseconds / 1000;
  const minutes = parseInt(seconds / 60, 10);
  const remainingSeconds = parseInt(seconds % 60, 10);

  const displayMinutes = I18n.t('shared.time.minutes', { count: minutes });
  const displaySeconds = I18n.t('shared.time.seconds', { count: remainingSeconds });

  return `${displayMinutes} and ${displaySeconds}`;
};
