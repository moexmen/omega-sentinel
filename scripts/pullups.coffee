# Description:
#   Tracks pullups to prata day!!!
#
# Commands: Hubot must be specifically @-mentioned.
#   pullups? - reports how many pullups are left till prata day.
#   reset pullups to x - set pullup counter to x.
#   did x pullups - reduces pullup counter by x. negative numbers can be used to undo the count.

module.exports = (robot) ->
  # produces a summary of who has done how many pullups
  pullupSummaries = () ->
    output = "\n"
    pullupTracker = robot.brain.get("pullupTracker")
    for name of pullupTracker
      pullupsDone = pullupTracker[name]
      if name is "shadowcat"
        output += "#{name}: #{pullupsDone} swings done."
      else
        output += "#{name}: #{pullupsDone} pullups contributed."
    output

  robot.respond new RegExp("reset pullups to (\\d+)", "i"), (res) ->
    pullupCount = Number.parseInt(res.match[1])
    robot.brain.set "pullupCount", pullupCount
    robot.brain.set "pullupTracker", {}
    res.send "Pullup count reset to #{pullupCount}. Tracker reset."

  robot.respond /pullups\?/i, (res) ->
    res.send "#{robot.brain.get('pullupCount')} pullups to prata day!!"
    res.send pullupSummaries()

  robot.hear /test/, (res) ->
    pullupTracker = robot.brain.get("pullupTracker")
    res.send "#{pullupTracker}"
    for name of pullupTracker
      res.send "#{name}"

  robot.respond new RegExp("did (-?\\d+) pullups", "i"), (res) ->
    username = res.message.user.name
    if username is "shadowcat"
      res.send "Swings don't count yet."
    else
      pullups_done = Number.parseInt(res.match[1])
      pullups_remaining = robot.brain.get("pullupCount") - pullups_done
      robot.brain.set("pullupCount", pullups_remaining)
      res.send "#{res.match[1]} pullups done, #{pullups_remaining} pullups left to prata day!!!"
    pullupTracker = robot.brain.get("pullupTracker")
    if (username in pullupTracker)
      pullupTracker[username] += pullups_done
    else
      pullupTracker[username] = pullups_done
    robot.brain.set("pullupTracker", pullupTracker)
