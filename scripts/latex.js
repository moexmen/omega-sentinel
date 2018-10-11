// Description:
//   Renders LaTeX equations using Google Charts API
//
// Commands:
//   hubot $e^{\pi i} - 1 = 0$
//
//

module.exports = robot => robot.respond(/\$(.*)\$/i, (res) => {
  const query = res.match[1].replace(/ /g, '%20');
  const url = `http://chart.apis.google.com/chart?cht=tx&chl=${query}`;
  return res.send(url);
});
