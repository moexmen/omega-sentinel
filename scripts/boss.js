// Description:
//   Randomly respond with a boss pic
//

module.exports = robot => robot.listen(
  message => (message.user.name === 'rurouni') && (Math.random() < 0.005),
  (res) => {
    if (Math.random() < 0.2) {
      res.reply('*LIKE A MINION*!! :shaowei:');
    } else {
      res.reply('*LIKE A BOSS*!! :shaowei:');
    }
  },
);
