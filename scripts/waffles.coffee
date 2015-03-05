# Description:
#   Consolidates waffle orders
#
#
# Commands:
#   waffles?
#

waffleTypes = ['chocolate', 'cheese', 'kaya', 'peanut', 'blueberry', 'plain']

module.exports = (robot) ->
  timeoutId = null

  getOrders = () ->
    output = 'Orders so far:\n'
    for waffleType in waffleTypes
      numType = robot.brain.get(waffleType)
      output += "#{waffleType}: #{numType}\n" if numType != 0
    timeoutId = null
    output

  isOrderActive = () ->
    waffleTime = robot.brain.get('waffleTime')
    now = new Date()
    #
    # if it's within 15 minutes
    if (now - 15 * 60 * 1000) < waffleTime
      true
    else
      false

  robot.hear /waffles\?/i, (msg) ->
    msg.reply "Consolidating waffle orders..."
    date = new Date()
    # start a new order by setting the current time and zero-ing the orders
    robot.brain.set 'waffleTime', date
    robot.brain.set(waffleType, 0) for waffleType in waffleTypes

  robot.hear /(chocolate|cheese|kaya|peanut|blueberry|plain)/i, (msg) ->
    if isOrderActive()
      waffleType = msg.match[1].toLowerCase()
      numType = robot.brain.get(waffleType)
      numType += 1
      robot.brain.set waffleType, numType
      msg.reply "#{waffleType} order received!"

      # if timeoutId is not null (existing timeout), clear it
      if timeoutId?
        clearTimeout(timeoutId)
        timeoutId = null

      timeoutId = setTimeout () ->
          msg.reply getOrders()
        , 5 * 1000

  robot.hear /(consolidate|orders)/i, (msg) ->
    if isOrderActive()
      msg.reply getOrders()
