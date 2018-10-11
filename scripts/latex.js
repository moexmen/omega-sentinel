/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Description:
//   Renders LaTeX equations using Google Charts API
//
// Commands:
//   hubot $e^{\pi i} - 1 = 0$
//
//

module.exports = robot =>
  robot.respond(/\$(.*)\$/i, function(msg) {
    const query = msg.match[1].replace(/\ /g,'%20');
    const url = `http://chart.apis.google.com/chart?cht=tx&chl=${query}`;
    return msg.send(url);
  })
;
