# Description:
#   Randomly respond with a boss pic
#

module.exports = (robot) ->
  robot.listen(
    (message) -> # Match function
      message.user.name is "rurouni" and Math.random() < 0.1 ** 3
    (response) ->
      response.reply "Like a bozz!! https://media.licdn.com/mpr/mpr/shrinknp_200_200/AAEAAQAAAAAAAAKeAAAAJGNmMjZkMmI5LWE2ZDQtNGY4Mi1hYjYxLTMxZWUwYzk0ZWY4ZA.jpg"
  )
