/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Description:
//   Randomly respond with a boss pic
//

module.exports = robot =>
  robot.listen(
    message => // Match function
      (message.user.name === "rurouni") && (Math.random() < 0.005)
    ,
    function(response) {
      if (Math.random() < 0.2) {
        return response.reply("*LIKE A MINION*!! :shaowei:");
      } else {
        return response.reply("*LIKE A BOSS*!! :shaowei:");
      }
  })
;
