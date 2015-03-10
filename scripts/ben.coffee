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
  "Want to be DD Ops? Can rub shoulders with Yoke Chun. :stuck_out_tongue:",
  "This is good, all to read and internalize.",
  "Would you like to give a talk on the book? :-) ",
  "Calling API is not sufficient for ESTL.",
  "Principle of leadership: When things screw up, you take",
  "I need a deputy to take one for me (#{emojis.weiqing} looks around)",
  "好不好?",
  "修身齐家治国平天下。",
  "Commando #{emojis.eugene} must go in there and plant flag!! (bang table)"
]

module.exports = (robot) ->
  robot.hear /ben/i, (msg) ->
    msg.reply "#{emojis.ben} #{msg.random quotes}"
