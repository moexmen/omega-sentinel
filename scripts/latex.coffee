# Description:
#   Renders LaTeX equations using Google Charts API
#
# Commands:
#   hubot $e^{\pi i} - 1 = 0$
#
#

module.exports = (robot) ->
  robot.respond /\$(.*)\$/i, (msg) ->
    query = msg.match[1].replace(/\ /g,'%20')
    url = "http://chart.apis.google.com/chart?cht=tx&chl=" + query
    msg.send url
