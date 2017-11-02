# Description:
#   Randomly respond with a boss pic
#

module.exports = (robot) ->
  robot.listen(
    (message) -> # Match function
      message.user.name is "rurouni" and Math.random() < 0.005
    (response) ->
      if Math.random() < 0.2
        response.reply "*LIKE A MINION*!! :shaowei:"
      else
        response.reply "*LIKE A BOSS*!! :shaowei:"
  )
