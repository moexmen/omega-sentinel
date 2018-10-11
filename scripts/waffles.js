/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Description:
//   Consolidates waffle orders
//
//
// Commands:
//   waffles? - start listening for and consolidating waffle orders
//   <flavour> - when active, typing a flavour adds it to the order
//   <flavour> for <name> - when active, adds someone else's flavour to the order for them
//   cancel - when active, cancels all of your orders
//

const waffleTypes = ['plain', 'kaya', 'butter', 'peanut', 'redbean', 'blueberry', 'cheese'];
const wafflePrices = {'plain': 1.2, 'kaya': 1.5, 'butter': 1.5, 'peanut': 1.5, 'redbean': 1.5, 'blueberry': 1.8, 'cheese': 1.8, 'chocolate': 1.8};
const waffleReminders = [5, 3, 1]; // minutes till timeout
const TIMEOUT = 15 * 60 * 1000;

module.exports = function(robot) {
  // produces a summary of current orders
  const summaries = function() {
    let output = 'Orders so far:\n';
    for (let waffleType of Array.from(waffleTypes)) {
      const nameList = robot.brain.get(waffleType);
      const numType = nameList.length;
      const names = `(${nameList.join(', ')})`;
      if (numType !== 0) { output += `*${waffleType}*: ${numType} ${names}\n`; }
    }
    return output;
  };

  const calcPrice = function() {
    let totalPrice = 0;
    for (let waffleType of Array.from(waffleTypes)) {
      const nameList = robot.brain.get(waffleType);
      const numType = nameList.length;
      totalPrice += numType * wafflePrices[waffleType];
    }
    return `${totalPrice.toFixed(2)}`;
  };

  const addOrder = function(waffleType, name) {
    const nameList = robot.brain.get(waffleType);
    nameList.push(name);
    return robot.brain.set(waffleType, nameList);
  };

  const deleteOrders = name =>
    (() => {
      const result = [];
      for (let waffleType of Array.from(waffleTypes)) {
        const nameList = robot.brain.get(waffleType)
          .filter(order_name => (order_name !== name) && !order_name.endsWith(` _via ${name}_`));
        result.push(robot.brain.set(waffleType, nameList));
      }
      return result;
    })()
  ;

  // returns true if the waffles? command was issued within the last 15 minutes
  // false otherwise
  const isOrderActive = function() {
    const waffleTime = robot.brain.get('waffleTime');
    const now = Date.now();

    // if it's within 15 minutes
    if ((now - TIMEOUT) < waffleTime) {
      return true;
    } else {
      return false;
    }
  };

  // listen out for waffles? to start consolidating
  robot.hear(/waffles\?/i, function(msg) {
    msg.send("@here: Consolidating waffle orders...\n" +
      `*Available flavours*: ${waffleTypes.join(', ')}\n` +
      "*Need help?* say `waffles help`"
    );
    const date = Date.now();
    // start a new order by setting the current time and setting the order keys to empty arrays
    // the array will store the list of user names
    robot.brain.set('waffleTime', date);
    for (let waffleType of Array.from(waffleTypes)) { robot.brain.set(waffleType, []); }
    // set countdown reminders
    waffleReminders.forEach(reminder =>
      setTimeout((function() {
        if (isOrderActive() && (robot.brain.get('waffleTime') === date)) {
          return msg.send(`Waffle orders will stop in ${reminder} min!`);
        }
      }), (TIMEOUT - (reminder * 60 * 1000)))
    );
    // set end action
    return setTimeout((function() {
      if (robot.brain.get('waffleTime') === date) {
        return msg.send(`*No more orders!* ${summaries()}\nCall *6469 3360* to order.`);
      }
    }), TIMEOUT);
  });

  robot.hear(new RegExp(`^(${waffleTypes.join('|')})$`, 'i'), function(msg) {
    if (isOrderActive()) {
      const waffleType = msg.match[1].toLowerCase();
      addOrder(waffleType, msg.message.user.name);
      return msg.reply(summaries());
    }
  });

  robot.hear(new RegExp(`^(${waffleTypes.join('|')}) for (.*)$`, 'i'), function(msg) {
    if (isOrderActive()) {
      const waffleType = msg.match[1].toLowerCase();
      const recipientName = msg.match[2];
      addOrder(waffleType, `${recipientName} _via ${msg.message.user.name}_`);
      return msg.reply(summaries());
    }
  });

  robot.hear(/^waffles cancel$/i, function(msg) {
    if (isOrderActive()) {
      deleteOrders(msg.message.user.name);
      return msg.reply(summaries());
    }
  });

  robot.hear(/^waffles help$/i, function(msg) {
    if (isOrderActive()) {
      return msg.reply("\n*Add an order*: `<flavour>`\n" +
        "*Add an order for someone else*: `<flavour> for <name>`\n" +
        "*Cancel all your orders*: `waffles cancel`\n" +
        "*List current orders*: `waffles orders`\n" +
        "*Stop collecting orders*: `waffles stop`"
      );
    } else {
      return msg.reply("\n*To start collecting orders*: say `waffles?`");
    }
  });

  robot.hear(/^waffles orders$/i, function(msg) {
    if (isOrderActive()) {
      return msg.reply(summaries());
    }
  });

  return robot.hear(/^waffles stop$/i, function(msg) {
    if (isOrderActive()) {
      robot.brain.set('waffleTime', Date.now() - TIMEOUT);
      return msg.reply(`*No more orders!* ${summaries()}\nTotal Price: $${calcPrice()}\nCall *6469 3360* to order.`);
    }
  });
};

