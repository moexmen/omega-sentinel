# Description:
# Sends all chat messages to Log Stash for archival.
#
# Commands:
# No commands.
#

URL = process.env.HUBOT_HISTORIAN_URL || "http://192.168.100.242:56400"

module.exports = (robot) ->
  # robot.hear /.*/i, (msg) ->
  #   log = "#{new Date()} | #{msg.message.room} | #{msg.message.user.name} | #{msg.message}"
  #   robot.http(URL)
  #   .header('Content-Type', 'application/text')
  #   .post(log)
