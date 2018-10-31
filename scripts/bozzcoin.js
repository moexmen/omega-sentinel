// Description:
//   Tracks bozzcoins earned through exercise
//
// Commands:
//   hubot bozzcoins? - reports how many bozzcoins are in the account.
//   hubot did x (pullups|pushups|situps|squats|lunges|sport steps|gym reps)
//      - adds bozzcoins to the account depending on the exercise type.
//   hubot ran x km - adds 100 bozzcoins per km.
//   hubot (prata|starbucks|macs) day - subtracts bozzcoins depending on the cheat type.

module.exports = (robot) => {
  // number of days bozz can go without exercising
  const bozziplierThreshold = 2;
  // multiplier decay for bozziplier
  const bozziplierDecay = 0.8;
  // the number of bozzcoins to earn to uncover each cell of the picture.
  // prata day cost divided by total number of cells in the picture.
  const bozzcoinsPerPictureCell = 10;
  const prataDayCost = 12000;

  // produces a summary of who has contributed bozzcoins
  function bozzcoinSummaries() {
    const output = [];
    const bozzcoinTracker = robot.brain.get('bozzcoinTracker');
    const sortedBozzcoinTracker = Object.keys(bozzcoinTracker).sort((a, b) => bozzcoinTracker[b] - bozzcoinTracker[a]);
    sortedBozzcoinTracker.forEach((name) => {
      const bozzcoinsContributed = bozzcoinTracker[name];
      output.push(`${(name === 'rurouni' ? `*${name}*` : name)}: ${bozzcoinsContributed} :bozzcoin: contributed.`);
    });
    return `\n${output.join('\n')}`;
  }

  function pictureURL(bozzcoinBalance) {
    const pictureNumber = Math.min(Math.floor(bozzcoinBalance / bozzcoinsPerPictureCell),
      prataDayCost / bozzcoinsPerPictureCell);
    return `https://bozzbojio.me/prata-progress/prata-bozz-${pictureNumber}.jpg`;
  }

  function earnRate(exerciseType) {
    switch (exerciseType) {
      case 'cycle': return 20;
      case 'pullups': return 7;
      case 'pushups': case 'situps': case 'squats': case 'lunges': case 'gym reps': return 1;
      case 'run': return 50;
      case 'sport steps': return 1 / 18;
      default: return 0;
    }
  }

  function verbToExerciseType(verb) {
    switch (verb) {
      case 'ran': return 'run';
      case 'cycled': return 'cycle';
      default: return verb;
    }
  }

  // returns true if bozziplier is reset
  function updateBozzExerciseTime(username) {
    if (username === 'rurouni') {
      robot.brain.set('bozzLastExercised', new Date());
      return true;
    }
    // Initialize bozzLastExercised if it has not been set before.
    const bozzLastExercised = robot.brain.get('bozzLastExercised');
    if (!bozzLastExercised) {
      robot.brain.set('bozzLastExercised', new Date());
    }
    return false;
  }

  function calculateBozziplier() {
    const thresholdInMilliSecs = bozziplierThreshold * 86400000;
    const bozzLastExercised = robot.brain.get('bozzLastExercised');
    const numberOfThresholdPeriods = Math.floor((new Date().getTime()
      - new Date(bozzLastExercised).getTime()) / thresholdInMilliSecs);

    return bozziplierDecay ** numberOfThresholdPeriods;
  }

  function convertToBozzcoin(reps, exerciseType) {
    return Math.round(reps * earnRate(exerciseType) * calculateBozziplier());
  }

  function convertToReps(bozzcoin, exerciseType) {
    return bozzcoin / earnRate(exerciseType);
  }

  function cheatDayPrices(cheatType) {
    switch (cheatType.toLowerCase()) {
      case 'prata': return prataDayCost;
      case 'starbucks': return 5000;
      case 'macs': return 7000;
      default: return 0;
    }
  }

  robot.respond(new RegExp('set bozzcoins to (\\d+)', 'i'), (res) => {
    if (res.message.user.name === 'lockheed') {
      const bozzcoinBalance = Number.parseInt(res.match[1], 10);
      robot.brain.set('bozzcoinBalance', bozzcoinBalance);
      robot.brain.set('bozzcoinTracker', {});
      res.send(`Bozzcoin balance reset to ${bozzcoinBalance} :bozzcoin:. Tracker reset.`);
    }
  });

  robot.respond(/bozzcoins\?/i, (res) => {
    const bozzcoinBalance = robot.brain.get('bozzcoinBalance');
    res.send(`*${bozzcoinBalance}* :bozzcoin:`);
    res.send(bozzcoinSummaries());
    res.send(pictureURL(bozzcoinBalance));
  });

  robot.respond(new RegExp('did (-?\\d+) (pullups|pushups|situps|squats|lunges|sport steps|gym reps)', 'i'), (res) => {
    let repsByUser;
    const username = res.message.user.name;
    const repsDone = Number.parseInt(res.match[1], 10);
    const exerciseType = res.match[2];
    const bozzcoinTracker = robot.brain.get('bozzcoinTracker');
    if (username in bozzcoinTracker) {
      repsByUser = convertToReps(bozzcoinTracker[username], exerciseType);
    } else {
      repsByUser = 0;
    }
    if (repsDone < (-1 * repsByUser)) {
      res.send('You can\'t undo more than you have done');
      return;
    }
    switch (exerciseType) {
      case 'pushups': case 'situps': case 'squats': case 'lunges': case 'gym reps':
        if (repsDone > 100) {
          res.send(`Show the team you can do more ${exerciseType} than :commando:`);
          return;
        }
        break;
      case 'pullups':
        if (username === 'shadowcat') {
          res.send('Swings don\'t count yet.');
          return;
        }
        if (repsDone > 20) {
          res.send('Even :commando: can\'t do that many pullups at a go');
          return;
        }
        break;
      case 'sport steps':
        if (repsDone > 13000) {
          res.send('Are you sure you can play longer than :pohneo:?');
          return;
        }
        break;
      default:
        res.send(`Please consult the committee on the legitimacy of _${exerciseType}_.`);
    }
    if ((repsDone > 0) && updateBozzExerciseTime(username)) {
      res.send(':bozz: Bozziplier reset like a bozz');
    }
    const bozziplier = calculateBozziplier();
    const bozzcoinEarned = convertToBozzcoin(repsDone, exerciseType);
    const newBozzcoinBalance = robot.brain.get('bozzcoinBalance') + bozzcoinEarned;
    robot.brain.set('bozzcoinBalance', newBozzcoinBalance);
    res.send(`${res.match[1]} ${exerciseType} done, earned *${bozzcoinEarned}* :bozzcoin: with bozziplier of ${bozziplier}.\n*${newBozzcoinBalance}* :bozzcoin: available!`); // eslint-disable-line max-len
    if (username in bozzcoinTracker) {
      bozzcoinTracker[username] += convertToBozzcoin(repsDone, exerciseType);
    } else {
      bozzcoinTracker[username] = convertToBozzcoin(repsDone, exerciseType);
    }
    robot.brain.set('bozzcoinTracker', bozzcoinTracker);
  });

  robot.respond(new RegExp('(ran|cycled) (-?\\d+.?\\d*) ?km', 'i'), (res) => {
    let distanceByUser;
    const username = res.message.user.name;
    const verb = res.match[1];
    const distanceInKm = Number.parseFloat(res.match[2]);
    const bozzcoinTracker = robot.brain.get('bozzcoinTracker');
    if (username in bozzcoinTracker) {
      distanceByUser = convertToReps(bozzcoinTracker[username], verbToExerciseType(verb));
    } else {
      distanceByUser = 0;
    }
    if (distanceInKm < (-1 * distanceByUser)) {
      res.send('You can\'t undo more than you have done');
      return;
    }
    if ((distanceInKm > 0) && updateBozzExerciseTime(username)) {
      res.send(':bozz: Bozziplier reset like a bozz');
    }
    const bozziplier = calculateBozziplier();
    const bozzcoinEarned = convertToBozzcoin(distanceInKm, verbToExerciseType(verb));
    const newBozzcoinBalance = robot.brain.get('bozzcoinBalance') + bozzcoinEarned;
    robot.brain.set('bozzcoinBalance', newBozzcoinBalance);
    res.send(`${distanceInKm.toFixed(3)} km ${verb}, earned *${bozzcoinEarned}* :bozzcoin: with bozziplier of ${bozziplier}.\n*${newBozzcoinBalance}* :bozzcoin: available!`); // eslint-disable-line max-len
    if (username in bozzcoinTracker) {
      bozzcoinTracker[username] += bozzcoinEarned;
    } else {
      bozzcoinTracker[username] = bozzcoinEarned;
    }
    robot.brain.set('bozzcoinTracker', bozzcoinTracker);
  });

  robot.respond(new RegExp('(prata|starbucks|macs) day', 'i'), (res) => {
    const cheatType = res.match[1];
    const newBozzcoinBalance = robot.brain.get('bozzcoinBalance') - cheatDayPrices(cheatType);
    if (newBozzcoinBalance < 0) {
      res.send(`Not enough :bozzcoin: for a ${cheatType} day :(`);
      return;
    }
    robot.brain.set('bozzcoinBalance', newBozzcoinBalance);
    res.send(`Happy *${cheatType} day*!! *${newBozzcoinBalance}* :bozzcoin: remaining.`);
  });
};
