# Description:
#   Replies with random quotes from ShaoWei, AKA bozz.
#
#
# Commands:
#   bozz

quotes = [
  "Come I clap for you",
  "Sooo coool",
  "Mai la",
  "Today is my cheat day",
  "Chicken rice is healthy",
  "The number of stories I get... Madness!"
]

module.exports = (robot) ->
  robot.hear /bozz\b/i, (msg) ->
    if Math.random() < 0.3
      msg.reply ":bozz: #{msg.random quotes}"
