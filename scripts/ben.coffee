# Description:
#   Replies with random quotes from Ben Leong
#
#
# Commands:
#   quote ben
#   ben
#
#

emojis =
  ben: ":ben:",
  weiqing: ":twq:",
  eugene: ":eug:"

quotes = [
  "Want my job?",
  "Sai understand?",
  "People matter, sales matter, execution matters.",
  "Eugene will plunk his server and woohoo! Settle already!",
  "Time out. Time out. Time out.",
  "Can we have someone to look into this? (awkward silence)",
  "This is good, all to read and internalize.",
  "Would you like to give a talk on the book? :-) ",
  "Calling API is not sufficient for ESTL.",
  "Principle of leadership: When things screw up, you take",
  "I need a deputy to take one for me (#{emojis.weiqing} looks around)",
  "好不好?",
  "修身齐家治国平天下。",
  "Commando #{emojis.eugene} must go in there and plant flag!! (bang table)",
  "Our lives are like shit. This is something we have to embrace!",
  "Hard is the norm, impossible is the standard!",
  "Hari-kiri is in fashion nowadays.",
  "There is theory and there is practice.",
  "I'm quite stunned that you all are quite stunned by this thing.",
  "Before you're married, you're single.",
  "I can do it in my sleep!"
]

module.exports = (robot) ->
  robot.hear /ben\b/i, (msg) ->
    if Math.random() < 0.3
      msg.reply "#{emojis.ben} #{msg.random quotes}"
