# Description:
#   Counts responses to a poll question
#
#
# Commands:
#   yay or nay? - Start counting responses
#   yes|yay|y - When active, counts as a yes vote
#   no|nay|n - When active, counts as a no vote
#

responseTypes = ['yay', 'nay']

URL = process.env.HUBOT_SPOT_URL || "http://localhost:5051"

# Send a request to spot
spotRequest = (message, path, action, options, callback) ->
  message.http("#{URL}#{path}")
    .query(options)[action]() (err, res, body) ->
      callback(err,res,body)

module.exports = (robot) ->
  # produces a summary of current orders
  summaries = () ->
    output = 'Responses so far:\n'
    for responseType in responseTypes
      nameList = robot.brain.get(responseType)
      numType = nameList.length
      names = getNames nameList
      output += "#{responseType}: #{numType} #{names}\n" if numType != 0
    output

  # produces a nice comma separated string of names surrounded by parantheses
  getNames = (nameList) ->
    names = '('
    for name in nameList
      names += "#{name}, "
    names = names[0..-3]
    names += ')'

  # returns true if the yay or nay? command was issued within the last 15 minutes
  # false otherwise
  isPollActive = () ->
    pollTime = robot.brain.get('pollTime')
    now = new Date()

    # if it's within 15 minutes
    if (now - 15 * 60 * 1000) < pollTime
      true
    else
      false

  # listen out for yay or nay? to start consolidating
  robot.hear /(yay or nay)\?/i, (msg) ->
    msg.reply "Consolidating poll responses..."
    date = new Date()
    # start a new order by setting the current time and setting the order keys to empty arrays
    # the array will store the list of user names
    robot.brain.set 'pollTime', date
    robot.brain.set(responseType, []) for responseType in responseTypes
    params = {what: 'Starting a new poll'}
    spotRequest msg, '/say', 'put', params, (err, res, body) ->
      null

  robot.hear /^(yes|yay|y|no|nay|n)$/i, (msg) ->
    if isPollActive()
      # get first character of response
      response = msg.match[1].toLowerCase().charAt(0)
      responseType = if response == 'y' then 'yay' else 'nay'
      nameList = robot.brain.get(responseType)
      nameList.push(msg.message.user.name)
      robot.brain.set responseType, nameList
      msg.reply "#{summaries()}"

  robot.hear /(summaries|consolidate|orders)/i, (msg) ->
    if isPollActive()
      msg.reply summaries()
