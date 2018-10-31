# Description:
#   Consolidates waffle orders
#
#
# Commands:
#   waffles? - start listening for and consolidating waffle orders
#   <flavour> - when active, typing a flavour adds it to the order
#   <flavour> for <name> - when active, adds someone else's flavour to the order for them
#   cancel - when active, cancels all of your orders
#

waffleTypesLeft = ['plain', 'kaya', 'butter', 'peanut', 'redbean', 'blueberry', 'cheese']
waffleTypesRight = ['plain', 'margarine', 'redbean', 'kaya', 'peanut', 'blueberry', 'strawberry', 'chocolate', 'cheese', 'margarinechickenfloss', 'hamcheese']
wafflePricesLeft = {'plain': 1.2, 'kaya': 1.5, 'butter': 1.5, 'peanut': 1.5, 'redbean': 1.5, 'blueberry': 1.8, 'cheese': 1.8, 'chocolate': 1.8}
wafflePricesRight = {'plain': 1.2, 'margarine': 1.4, 'redbean': 1.4, 'kaya': 1.4, 'peanut': 1.6, 'blueberry': 1.6, 'strawberry': 1.6, 'chocolate': 1.6, 'cheese': 1.7, 'margarinechickenfloss': 2.0, 'hamcheese': 2.0}
waffleReminders = [5, 3, 1] # minutes till timeout
TIMEOUT = 15 * 60 * 1000

module.exports = (robot) ->
  # produces a summary of current orders
  summaries = () ->
    output = 'Orders so far:\n'
    waffleTypes = []
    if robot.brain.get('direction') == 'left'
      waffleTypes = waffleTypesLeft
    else
      waffleTypes = waffleTypesRight

    for waffleType in waffleTypes
      nameList = robot.brain.get(waffleType)
      numType = nameList.length
      names = "(#{nameList.join(', ')})"
      output += "*#{waffleType}*: #{numType} #{names}\n" if numType != 0
    output

  calcPrice = () ->
    totalPrice = 0
    waffleTypes = []
    wafflePrices = {}
    if robot.brain.get('direction') == 'left'
      waffleTypes = waffleTypesLeft
      wafflePrices = wafflePricesLeft
    else
      waffleTypes = waffleTypesRight
      wafflePrices = wafflePricesRight

    for waffleType in waffleTypes
      nameList = robot.brain.get(waffleType)
      numType = nameList.length
      totalPrice += numType * wafflePrices[waffleType]
    "#{totalPrice.toFixed 2}"

  finalSummary = () ->
    orderMethod = ''
    if robot.brain.get('direction') == 'left'
      orderMethod = "Call *6469 3360*"
    else
      orderMethod = "Take a walk"
    '*No more orders!* ' + summaries() + "\nTotal Price: $" + calcPrice() + "\n" + orderMethod + " to order."

  addOrder = (waffleType, name) ->
    nameList = robot.brain.get(waffleType)
    nameList.push(name)
    robot.brain.set(waffleType, nameList)

  deleteOrders = (name) ->
    waffleTypes = []
    if robot.brain.get('direction') == 'left'
      waffleTypes = waffleTypesLeft
    else
      waffleTypes = waffleTypesRight

    for waffleType in waffleTypes
      nameList = robot.brain.get(waffleType)
        .filter (order_name) ->
          order_name != name and not order_name.endsWith " _via #{name}_"
      robot.brain.set waffleType, nameList

  # returns true if the waffles? command was issued within the last 15 minutes
  # false otherwise
  isOrderActive = () ->
    waffleTime = robot.brain.get('waffleTime')
    now = Date.now()

    # if it's within 15 minutes
    if (now - TIMEOUT) < waffleTime
      true
    else
      false

  # listen out for waffles? to start consolidating
  robot.hear /^waffles\?/i, (msg) ->
    msg.send "\n*To start collecting orders*: say `waffles left?` or `waffles right?`"

  robot.hear /waffles left\?/i, (msg) ->
    msg.send "@here: Consolidating waffle orders...\n" +
      "*Available flavours*: #{waffleTypesLeft.join(', ')}\n" +
      "*Need help?* say `waffles help`"
    date = Date.now()
    # start a new order by setting the current time and setting the order keys to empty arrays
    # the array will store the list of user names
    robot.brain.set 'waffleTime', date
    robot.brain.set 'direction', 'left'
    robot.brain.set(waffleType, []) for waffleType in waffleTypesLeft
    # set countdown reminders
    waffleReminders.forEach (reminder) ->
      setTimeout (->
        if isOrderActive() and robot.brain.get('waffleTime') == date
          msg.send "Waffle orders will stop in #{reminder} min!"
      ), (TIMEOUT - reminder * 60 * 1000)
    # set end action
    setTimeout (->
      if robot.brain.get('waffleTime') == date
        msg.send finalSummary()
    ), TIMEOUT

  robot.hear new RegExp("^(#{waffleTypesLeft.join('|')})$", 'i'), (msg) ->
    if isOrderActive() and robot.brain.get('direction') == 'left'
      waffleType = msg.match[1].toLowerCase()
      addOrder(waffleType, msg.message.user.name)
      msg.reply summaries()

  robot.hear new RegExp("^(#{waffleTypesLeft.join('|')}) for (.*)$", 'i'), (msg) ->
    if isOrderActive() and robot.brain.get('direction') == 'left'
      waffleType = msg.match[1].toLowerCase()
      recipientName = msg.match[2]
      addOrder(waffleType, "#{recipientName} _via #{msg.message.user.name}_")
      msg.reply summaries()

  robot.hear /waffles right\?/i, (msg) ->
    msg.send "@here: Consolidating waffle orders...\n" +
      "*Available flavours*: #{waffleTypesRight.join(', ')}\n" +
      "*Need help?* say `waffles help`"
    date = Date.now()
    # start a new order by setting the current time and setting the order keys to empty arrays
    # the array will store the list of user names
    robot.brain.set 'waffleTime', date
    robot.brain.set 'direction', 'right'
    robot.brain.set(waffleType, []) for waffleType in waffleTypesRight
    # set countdown reminders
    waffleReminders.forEach (reminder) ->
      setTimeout (->
        if isOrderActive() and robot.brain.get('waffleTime') == date
          msg.send "Waffle orders will stop in #{reminder} min!"
      ), (TIMEOUT - reminder * 60 * 1000)
    # set end action
    setTimeout (->
      if robot.brain.get('waffleTime') == date
        msg.send finalSummary()
    ), TIMEOUT

  robot.hear new RegExp("^(#{waffleTypesRight.join('|')})$", 'i'), (msg) ->
    if isOrderActive() and robot.brain.get('direction') == 'right'
      waffleType = msg.match[1].toLowerCase()
      addOrder(waffleType, msg.message.user.name)
      msg.reply summaries()

  robot.hear new RegExp("^(#{waffleTypesRight.join('|')}) for (.*)$", 'i'), (msg) ->
    if isOrderActive() and robot.brain.get('direction') == 'right'
      waffleType = msg.match[1].toLowerCase()
      recipientName = msg.match[2]
      addOrder(waffleType, "#{recipientName} _via #{msg.message.user.name}_")
      msg.reply summaries()

  robot.hear /^waffles cancel$/i, (msg) ->
    if isOrderActive()
      deleteOrders(msg.message.user.name)
      msg.reply summaries()

  robot.hear /^waffles help$/i, (msg) ->
    if isOrderActive()
      msg.reply "\n*Add an order*: `<flavour>`\n" +
        "*Add an order for someone else*: `<flavour> for <name>`\n" +
        "*Cancel all your orders*: `waffles cancel`\n" +
        "*List current orders*: `waffles orders`\n" +
        "*Stop collecting orders*: `waffles stop`"
    else
      msg.reply "\n*To start collecting orders*: say `waffles?`"

  robot.hear /^waffles orders$/i, (msg) ->
    if isOrderActive()
      msg.reply summaries()

  robot.hear /^waffles stop$/i, (msg) ->
    if isOrderActive()
      robot.brain.set('waffleTime', Date.now() - TIMEOUT)
      msg.reply finalSummary()
