function formatMinutes(minutes) {
  if (!minutes) return 0;

  return minutes;
}

function formatSeconds(seconds) {
  return seconds < 10 ? `0${seconds}` : seconds;
}

export default (milliseconds) => {
  const seconds = milliseconds / 1000;
  const minutes = formatMinutes(parseInt(seconds / 60, 10));
  const remainingSeconds = formatSeconds(parseInt(seconds % 60, 10));

  return `${minutes}:${remainingSeconds}`;
};
