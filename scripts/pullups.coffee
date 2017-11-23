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
        output += "#{name}: #{pullupsDone} swings done.\n"
      else
        output += "#{name}: #{pullupsDone} pullups contributed.\n"
    output

  robot.respond new RegExp("reset pullups to (\\d+)", "i"), (res) ->
    if res.message.user.name is "lockheed"
      pullupCount = Number.parseInt(res.match[1])
      robot.brain.set "pullupCount", pullupCount
      robot.brain.set "pullupTracker", {}
      res.send "Pullup count reset to #{pullupCount}. Tracker reset."

  robot.respond /pullups\?/i, (res) ->
    res.send "#{robot.brain.get('pullupCount')} pullups to prata day!!"
    res.send pullupSummaries()

  robot.respond new RegExp("did (-?\\d+) pullups", "i"), (res) ->
    username = res.message.user.name
    if username is "shadowcat"
      res.send "Swings don't count yet."
    else
      pullupsDone = Number.parseInt(res.match[1])
      if pullupsDone > 20 or pullupsDone < -20
        res.send "Even :commando: can't do that many pullups at a go"
        return
      pullups_remaining = robot.brain.get("pullupCount") - pullupsDone
      robot.brain.set("pullupCount", pullups_remaining)
      res.send "*#{res.match[1]} pullups done, #{pullups_remaining} pullups left to prata day!!!*"
    pullupTracker = robot.brain.get("pullupTracker")
    if (username in pullupTracker)
      pullupTracker[username] += pullupsDone
    else
      pullupTracker[username] = pullupsDone
    robot.brain.set("pullupTracker", pullupTracker)
