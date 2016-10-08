# Description:
#   Randomly respond with a boss pic
#

module.exports = (robot) ->
  robot.listen(
    (message) -> # Match function
      message.user.name is "rurouni" and Math.random() < 0.03
    (response) ->
      response.reply "*LIKE A BOSS*!! :shaowei:"
  )
