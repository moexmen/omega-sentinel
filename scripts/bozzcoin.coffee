# Description:
#   Tracks bozzcoins earned through exercise
#
# Commands: Hubot must be specifically @-mentioned.
#   bozzcoins? - reports how many bozzcoins are in the account.
#   did x (pullups|pushups|situps) - adds bozzcoins to the account depending on the exercise type.
#   prata day - subtracts 10000 bozzcoins.

module.exports = (robot) ->
  # produces a summary of who has contributed bozzcoins
  bozzcoinSummaries = () ->
    output = "\n"
    bozzcoinTracker = robot.brain.get("bozzcoinTracker")
    for name of bozzcoinTracker
      bozzcoinsContributed = bozzcoinTracker[name]
      output += "#{name}: #{bozzcoinsContributed} :bozzcoin: contributed.\n"
    output

  earnRate = (exerciseType) ->
    switch exerciseType
      when "pullups" then return 10
      when "pushups", "situps" then return 1
      else return 0

  convertToBozzcoin = (reps, exerciseType) ->
    return reps * earnRate(exerciseType)

  convertToReps = (bozzcoin, exerciseType) ->
    return bozzcoin / earnRate(exerciseType)

  cheatDayPrices = (cheatType) ->
    switch cheatType
      when "prata" then return 10000

  robot.respond new RegExp("set bozzcoins to (\\d+)", "i"), (res) ->
    if res.message.user.name is "Shell"
      bozzcoinBalance = Number.parseInt(res.match[1])
      robot.brain.set "bozzcoinBalance", bozzcoinBalance
      robot.brain.set "bozzcoinTracker", {}
      res.send "Bozzcoin balance reset to #{bozzcoinBalance} :bozzcoin:. Tracker reset."

  robot.respond /bozzcoins\?/i, (res) ->
    bozzcoinBalance = robot.brain.get('bozzcoinBalance')
    res.send "*#{bozzcoinBalance}* :bozzcoin:"
    res.send bozzcoinSummaries()

  robot.respond new RegExp("did (-?\\d+) (pullups|pushups|situps)", "i"), (res) ->
    username = res.message.user.name
    repsDone = Number.parseInt(res.match[1])
    exerciseType = res.match[2]
    bozzcoinTracker = robot.brain.get("bozzcoinTracker")
    if (username of bozzcoinTracker)
      repsByUser = convertToReps(bozzcoinTracker[username], exerciseType)
    else
      repsByUser = 0
    if repsDone < (-1 * repsByUser)
      res.send "You can't undo more than you have done"
      return
    switch exerciseType
      when "pushups", "situps"
        if repsDone > 60
          res.send "Show the team you can do more #{exerciseType} than :commando:"
          return
      when "pullups"
        if username is "shadowcat"
          res.send "Swings don't count yet."
          return
        else
          if repsDone > 20
            res.send "Even :commando: can't do that many pullups at a go"
            return
    newBozzcoinBalance = robot.brain.get("bozzcoinBalance") + convertToBozzcoin(repsDone, exerciseType)
    robot.brain.set("bozzcoinBalance", newBozzcoinBalance)
    res.send "#{res.match[1]} #{exerciseType} done, *#{newBozzcoinBalance}* :bozzcoin: available!"
    if (username of bozzcoinTracker)
      bozzcoinTracker[username] += convertToBozzcoin(repsDone, exerciseType)
    else
      bozzcoinTracker[username] = convertToBozzcoin(repsDone, exerciseType)
    robot.brain.set("bozzcoinTracker", bozzcoinTracker)

  robot.respond new RegExp("(prata) day", "i"), (res) ->
    cheatType = res.match[1]
    newBozzcoinBalance = robot.brain.get("bozzcoinBalance") - cheatDayPrices(cheatType)
    if newBozzcoinBalance < 0
      res.send "Not enough :bozzcoin: for a #{cheatType} day :("
    else
      robot.brain.set("bozzcoinBalance", newBozzcoinBalance)
      res.send "Happy *#{cheatType} day*!! *#{newBozzcoinBalance}* :bozzcoin: remaining."
