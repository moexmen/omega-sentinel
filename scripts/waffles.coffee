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

waffleTypes = ['plain', 'kaya', 'butter', 'peanut', 'redbean', 'chocolate', 'blueberry', 'cheese']
waffleReminders = [5, 3, 1] # minutes till timeout
TIMEOUT = 15 * 60 * 1000

module.exports = (robot) ->
  # produces a summary of current orders
  summaries = () ->
    output = 'Orders so far:\n'
    for waffleType in waffleTypes
      nameList = robot.brain.get(waffleType)
      numType = nameList.length
      names = "(#{nameList.join(', ')})"
      output += "*#{waffleType}*: #{numType} #{names}\n" if numType != 0
    output


  addOrder = (waffleType, name) ->
    nameList = robot.brain.get(waffleType)
    nameList.push(name)
    robot.brain.set(waffleType, nameList)

  deleteOrders = (name) ->
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
  robot.hear /waffles\?/i, (msg) ->
    msg.send "@here: Consolidating waffle orders...\n" +
      "*Available flavours*: #{waffleTypes.join(', ')}\n" +
      "*Need help?* say `waffles help`"
    date = Date.now()
    # start a new order by setting the current time and setting the order keys to empty arrays
    # the array will store the list of user names
    robot.brain.set 'waffleTime', date
    robot.brain.set(waffleType, []) for waffleType in waffleTypes
    # set countdown reminders
    waffleReminders.forEach (reminder) ->
      setTimeout (->
        if isOrderActive() and robot.brain.get('waffleTime') == date
          msg.send "Waffle orders will stop in #{reminder} min!"
      ), (TIMEOUT - reminder * 60 * 1000)
    # set end action
    setTimeout (->
      if robot.brain.get('waffleTime') == date
        msg.send '*No more orders!* ' + summaries() + "\nCall *6469 3360* to order."
    ), TIMEOUT

  robot.hear new RegExp("^(#{waffleTypes.join('|')})$", 'i'), (msg) ->
    if isOrderActive()
      waffleType = msg.match[1].toLowerCase()
      addOrder(waffleType, msg.message.user.name)
      msg.reply summaries()

  robot.hear new RegExp("^(#{waffleTypes.join('|')}) for (.*)$", 'i'), (msg) ->
    if isOrderActive()
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
      msg.reply '*No more orders!* ' + summaries() + "\nCall *6469 3360* to order."

