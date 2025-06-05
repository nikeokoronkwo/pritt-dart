export default function (date: Date, { days = 0, hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }) {
  const totalMs =
    (((days * 24 + hours) * 60 + minutes) * 60 + seconds) * 1000 + milliseconds;
  return new Date(date.getTime() + totalMs);
}