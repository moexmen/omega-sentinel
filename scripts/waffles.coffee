# Description:
#   Consolidates waffle orders
#
#
# Commands:
#   waffles? - start listening for and consolidating waffle orders
#   <flavour> - when active, typing a flavour adds it to the order
#

waffleTypes = ['chocolate', 'cheese', 'kaya', 'peanut', 'blueberry', 'plain']

module.exports = (robot) ->
  # produces a summary of current orders
  summaries = () ->
    output = 'Orders so far:\n'
    for waffleType in waffleTypes
      nameList = robot.brain.get(waffleType)
      numType = nameList.length
      names = getNames nameList
      output += "#{waffleType}: #{numType} #{names}\n" if numType != 0
    output

  # produces a nice comma separated string of names surrounded by parantheses
  getNames = (nameList) ->
    names = '('
    for name in nameList
      names += "#{name}, "
    names = names[0..-3]
    names += ')'

  # produces a nice string of available flavours
  getAvailableFlavours = () ->
    available = 'Available flavours are '
    for waffleType in waffleTypes
      available += "#{waffleType}, "
    available[0..-3]

  # returns true if the waffles? command was issued within the last 15 minutes
  # false otherwise
  isOrderActive = () ->
    waffleTime = robot.brain.get('waffleTime')
    now = new Date()

    # if it's within 15 minutes
    if (now - 15 * 60 * 1000) < waffleTime
      true
    else
      false

  # listen out for waffles? to start consolidating
  robot.hear /waffles\?/i, (msg) ->
    msg.reply "Consolidating waffle orders...\n#{getAvailableFlavours()}"
    date = new Date()
    # start a new order by setting the current time and setting the order keys to empty arrays
    # the array will store the list of user names
    robot.brain.set 'waffleTime', date
    robot.brain.set(waffleType, []) for waffleType in waffleTypes

  robot.hear /^(chocolate|cheese|kaya|peanut|blueberry|plain)$/i, (msg) ->
    if isOrderActive()
      waffleType = msg.match[1].toLowerCase()
      nameList = robot.brain.get(waffleType)
      nameList.push(msg.message.user.name)
      robot.brain.set waffleType, nameList
      msg.reply "#{summaries()}"

  robot.hear /(summaries|consolidate|orders)/i, (msg) ->
    if isOrderActive()
      msg.reply summaries()
