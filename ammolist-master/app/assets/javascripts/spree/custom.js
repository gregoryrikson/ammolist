function runCountDownTimer() {
  var todaysNoon = new Date(),
  nextNoon = new Date();
  todaysNoon.setHours(14, 00, 0);
  if (todaysNoon <= nextNoon) {
    nextNoon.setDate(nextNoon.getDate() + 1);
  }
  nextNoon.setHours(14, 00, 0);
  $('.timer').countdowntimer({
    dateAndTime : nextNoon,
    timeUp : timeisUp,
    regexpMatchFormat: "([0-9]{1,2}):([0-9]{1,2}):([0-9]{1,2}):([0-9]{1,2})",
    regexpReplaceWith: "<li><span class='hours'>$2</span><p class='hours_text'>Hours</p></li><li class='seperator'>:</li><li><span class='minutes'>$3</span><p class='minutes_text'>Minutes</p></li><li class='seperator'>:</li><li><span class='seconds'>$4</span><p class='seconds_text'>Seconds</p></li>"
  });
  function timeisUp() {
    location.reload();
  }
}