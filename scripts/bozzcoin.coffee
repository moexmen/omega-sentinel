# Description:
#   Tracks bozzcoins earned through exercise
#
# Commands: Hubot must be specifically @-mentioned.
#   bozzcoins? - reports how many bozzcoins are in the account.
#   did x (pullups|pushups|situps|squats|lunges|racket steps) - adds bozzcoins to the account depending on the exercise type.
#   ran x km - adds 100 bozzcoins per km.
#   (prata|starbucks|macs) day - subtracts bozzcoins depending on the cheat type.

module.exports = (robot) ->
  # number of days bozz can go without exercising
  bozziplierThreshold = 2
  # multiplier decay for bozziplier
  bozziplierDecay = 0.8

  # produces a summary of who has contributed bozzcoins
  bozzcoinSummaries = () ->
    output = "\n"
    bozzcoinTracker = robot.brain.get("bozzcoinTracker")
    sortedBozzcoinTracker = (Object.keys bozzcoinTracker).sort((a, b) -> bozzcoinTracker[b] - bozzcoinTracker[a])
    for name in sortedBozzcoinTracker
      bozzcoinsContributed = bozzcoinTracker[name]
      output += (if name is "rurouni" then "*#{name}*" else name) + ": #{bozzcoinsContributed} :bozzcoin: contributed.\n"
    output

  earnRate = (exerciseType) ->
    switch exerciseType
      when "cycle" then return 20
      when "pullups" then return 10
      when "pushups", "situps", "squats", "lunges" then return 1
      when "run" then return 50
      when "racket steps" then return 1 / 18
      else return 0

  verbToExerciseType = (verb) ->
    switch verb
      when "ran" then return "run"
      when "cycled" then return "cycle"
      else return verb

  # returns true if bozziplier is reset
  updateBozziplier = (username) ->
    if username is "rurouni"
      robot.brain.set("bozzLastExercised", new Date())
      robot.brain.set("bozziplier", 1)
      return true
    else
      bozzLastExercised = robot.brain.get("bozzLastExercised")
      if !bozzLastExercised || new Date().getTime() - new Date(bozzLastExercised).getTime() > bozziplierThreshold * 86400000 # threshold times milliseconds in a day
        bozziplier = robot.brain.get("bozziplier")
        if !bozziplier
          bozziplier = 1
          robot.brain.set("bozzLastExercised", new Date())
        newBozziplier = bozziplier * bozziplierDecay
        robot.brain.set("bozziplier", newBozziplier)
    return false

  convertToBozzcoin = (reps, exerciseType) ->
    return Math.round(reps * earnRate(exerciseType) * robot.brain.get("bozziplier"))

  convertToReps = (bozzcoin, exerciseType) ->
    return bozzcoin / earnRate(exerciseType)

  cheatDayPrices = (cheatType) ->
    switch cheatType
      when "prata" then return 12000
      when "starbucks" then return 5000
      when "macs" then return 7000

  robot.respond new RegExp("set bozzcoins to (\\d+)", "i"), (res) ->
    if res.message.user.name is "lockheed"
      bozzcoinBalance = Number.parseInt(res.match[1])
      robot.brain.set "bozzcoinBalance", bozzcoinBalance
      robot.brain.set "bozzcoinTracker", {}
      res.send "Bozzcoin balance reset to #{bozzcoinBalance} :bozzcoin:. Tracker reset."

  robot.respond /bozzcoins\?/i, (res) ->
    bozzcoinBalance = robot.brain.get('bozzcoinBalance')
    res.send "*#{bozzcoinBalance}* :bozzcoin:"
    res.send bozzcoinSummaries()

  robot.respond new RegExp("did (-?\\d+) (pullups|pushups|situps|squats|lunges|racket steps)", "i"), (res) ->
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
      when "pushups", "situps", "squats", "lunges"
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
      when "racket steps"
        if repsDone > 13000
          res.send "Are you sure you can play longer than :pohneo:?"
          return
    if repsDone > 0 && updateBozziplier(username)
      res.send ":bozz: Bozziplier reset like a bozz"
    bozziplier = robot.brain.get("bozziplier")
    bozzcoinEarned = convertToBozzcoin(repsDone, exerciseType)
    newBozzcoinBalance = robot.brain.get("bozzcoinBalance") + bozzcoinEarned
    robot.brain.set("bozzcoinBalance", newBozzcoinBalance)
    res.send "#{res.match[1]} #{exerciseType} done, earned *#{bozzcoinEarned}* :bozzcoin: with bozziplier of #{bozziplier}.\n*#{newBozzcoinBalance}* :bozzcoin: available!"
    if (username of bozzcoinTracker)
      bozzcoinTracker[username] += convertToBozzcoin(repsDone, exerciseType)
    else
      bozzcoinTracker[username] = convertToBozzcoin(repsDone, exerciseType)
    robot.brain.set("bozzcoinTracker", bozzcoinTracker)

  robot.respond new RegExp("(ran|cycled) (-?\\d+.?\\d*) ?km", "i"), (res) ->
    username = res.message.user.name
    verb = res.match[1]
    distanceInKm = Number.parseFloat(res.match[2])
    bozzcoinTracker = robot.brain.get("bozzcoinTracker")
    if (username of bozzcoinTracker)
      distanceByUser = convertToReps(bozzcoinTracker[username], verbToExerciseType(verb))
    else
      distanceByUser = 0
    if distanceInKm < (-1 * distanceByUser)
      res.send "You can't undo more than you have done"
      return
    if distanceInKm > 0 && updateBozziplier(username)
      res.send ":bozz: Bozziplier reset like a bozz"
    bozziplier = robot.brain.get("bozziplier")
    bozzcoinEarned = convertToBozzcoin(distanceInKm, verbToExerciseType(verb))
    newBozzcoinBalance = robot.brain.get("bozzcoinBalance") + bozzcoinEarned
    robot.brain.set("bozzcoinBalance", newBozzcoinBalance)
    res.send "#{distanceInKm.toFixed(3)} km #{verb}, earned *#{bozzcoinEarned}* :bozzcoin: with bozziplier of #{bozziplier}.\n*#{newBozzcoinBalance}* :bozzcoin: available!"
    if (username of bozzcoinTracker)
      bozzcoinTracker[username] += bozzcoinEarned
    else
      bozzcoinTracker[username] = bozzcoinEarned
    robot.brain.set("bozzcoinTracker", bozzcoinTracker)

  robot.respond new RegExp("(prata|starbucks|macs) day", "i"), (res) ->
    cheatType = res.match[1]
    newBozzcoinBalance = robot.brain.get("bozzcoinBalance") - cheatDayPrices(cheatType)
    if newBozzcoinBalance < 0
      res.send "Not enough :bozzcoin: for a #{cheatType} day :("
    else
      robot.brain.set("bozzcoinBalance", newBozzcoinBalance)
      res.send "Happy *#{cheatType} day*!! *#{newBozzcoinBalance}* :bozzcoin: remaining."
