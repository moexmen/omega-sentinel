/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Description:
//   Replies with random quotes from ShaoWei, AKA bozz.
//
//
// Commands:
//   bozz

const quotes = [
  "Come I clap for you",
  "Sooo coool",
  "Mai la",
  "Today is my cheat day",
  "Chicken rice is healthy",
  "For you, for you",
  "Don't sad, don't sad",
  "The number of stories I get... Madness!"
];

module.exports = robot =>
  robot.hear(/bozz\b/i, function(msg) {
    if (Math.random() < 0.3) {
      return msg.reply(`:bozz: ${msg.random(quotes)}`);
    }
  })
;
