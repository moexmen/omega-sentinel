// Description:
//   Consolidates waffle orders
//
//
// Commands:
//   waffles? - start listening for and consolidating waffle orders
//   <flavour> - when waffles is active, add order for that flavour
//   <flavour> for <name> - when waffles is active, adds order for someone else
//   waffles cancel - when waffles is active, cancels all of your orders
//   waffles help - display waffles-specific help
//   waffles orders - when waffles is active, display all orders
//   waffles stop - when waffles is active, terminate order period immediately
//

module.exports = (robot) => {
  const waffleTypes = ['plain', 'kaya', 'butter', 'peanut', 'redbean', 'blueberry', 'cheese'];
  const wafflePrices = {
    plain: 1.2, kaya: 1.5, butter: 1.5, peanut: 1.5, redbean: 1.5, blueberry: 1.8, cheese: 1.8, chocolate: 1.8,
  };
  const waffleReminders = [5, 3, 1]; // minutes till timeout
  const TIMEOUT = 15 * 60 * 1000;

  // produces a summary of current orders
  const summaries = () => {
    let output = 'Orders so far:\n';
    waffleTypes.forEach((waffleType) => {
      const nameList = robot.brain.get(waffleType);
      const numType = nameList.length;
      const names = `(${nameList.join(', ')})`;
      if (numType !== 0) { output += `*${waffleType}*: ${numType} ${names}\n`; }
    });
    return output;
  };

  const calcPrice = () => {
    let totalPrice = 0;
    waffleTypes.forEach((waffleType) => {
      const nameList = robot.brain.get(waffleType);
      const numType = nameList.length;
      totalPrice += numType * wafflePrices[waffleType];
    });
    return `${totalPrice.toFixed(2)}`;
  };

  const finalSummary = () => `*No more orders!* ${summaries()}\n`
    + `Total Price: $${calcPrice()}\nCall *6469 3360* to order.`;

  const addOrder = (waffleType, name) => {
    const nameList = robot.brain.get(waffleType);
    nameList.push(name);
    return robot.brain.set(waffleType, nameList);
  };

  const deleteOrders = (name) => {
    const result = [];
    waffleTypes.forEach((waffleType) => {
      const nameList = robot.brain.get(waffleType)
        .filter(orderName => (orderName !== name) && !orderName.endsWith(` _via ${name}_`));
      result.push(robot.brain.set(waffleType, nameList));
    });
    return result;
  };

  // returns true if the waffles? command was issued within the last 15 minutes
  // false otherwise
  const isOrderActive = () => {
    const waffleTime = robot.brain.get('waffleTime');
    const now = Date.now();

    // if it's within 15 minutes
    return ((now - TIMEOUT) < waffleTime);
  };

  // listen out for waffles? to start consolidating
  robot.hear(/waffles\?/i, (res) => {
    if (isOrderActive()) {
      res.reply('Already consolidating waffle orders!');
      return 0;
    }
    
    res.send('@here: Consolidating waffle orders...\n'
      + `*Available flavours*: ${waffleTypes.join(', ')}\n`
      + '*Need help?* say `waffles help`');
    const date = Date.now();
    // start a new order by setting the current time and setting the order keys to empty arrays
    // the array will store the list of user names
    robot.brain.set('waffleTime', date);
    waffleTypes.forEach((waffleType) => {
      robot.brain.set(waffleType, []);
    });
    // set countdown reminders
    waffleReminders.forEach(reminder => setTimeout((() => {
      if (isOrderActive() && (robot.brain.get('waffleTime') === date)) {
        res.send(`Waffle orders will stop in ${reminder} min!`);
      }
    }), (TIMEOUT - (reminder * 60 * 1000))));
    // set end action
    return setTimeout((() => {
      if (robot.brain.get('waffleTime') === date) {
        res.send(finalSummary());
      }
    }), TIMEOUT);
  });

  robot.hear(new RegExp(`^(${waffleTypes.join('|')})$`, 'i'), (res) => {
    if (isOrderActive()) {
      const waffleType = res.match[1].toLowerCase();
      addOrder(waffleType, res.message.user.name);
      res.reply(summaries());
    }
  });

  robot.hear(new RegExp(`^(${waffleTypes.join('|')}) for (.*)$`, 'i'), (res) => {
    if (isOrderActive()) {
      const waffleType = res.match[1].toLowerCase();
      const recipientName = res.match[2];
      addOrder(waffleType, `${recipientName} _via ${res.message.user.name}_`);
      res.reply(summaries());
    }
  });

  robot.hear(/^waffles cancel$/i, (res) => {
    if (isOrderActive()) {
      deleteOrders(res.message.user.name);
      res.reply(summaries());
    }
  });

  robot.hear(/^waffles help$/i, (res) => {
    if (isOrderActive()) {
      res.reply('\n*Add an order*: `<flavour>`\n'
        + '*Add an order for someone else*: `<flavour> for <name>`\n'
        + '*Cancel all your orders*: `waffles cancel`\n'
        + '*List current orders*: `waffles orders`\n'
        + '*Stop collecting orders*: `waffles stop`');
    }
    res.reply('\n*To start collecting orders*: say `waffles?`');
  });

  robot.hear(/^waffles orders$/i, (res) => {
    if (isOrderActive()) {
      res.reply(summaries());
    }
  });

  return robot.hear(/^waffles stop$/i, (res) => {
    if (isOrderActive()) {
      robot.brain.set('waffleTime', Date.now() - TIMEOUT);
      res.reply(finalSummary());
    }
  });
};
