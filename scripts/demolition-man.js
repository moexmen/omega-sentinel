// Description:
//   Watch your language!
//
// Dependencies:
//   None
//
// Configuration:
//   None
//
// Commands:
//
// Author:
//   whitman, jan0sch

module.exports = (robot) => {
  const words = [
    'arsch',
    'arschloch',
    'arse',
    'ass',
    'bastard',
    'bitch',
    'bugger',
    'bollocks',
    'bullshit',
    'cock',
    'cunt',
    'damn',
    'damnit',
    'depp',
    'dick',
    'douche',
    'fag',
    'fotze',
    'fuck',
    'fucked',
    'fucking',
    'kacke',
    'piss',
    'pisse',
    'scheisse',
    'schlampe',
    'shit',
    'wank',
    'wichser',
  ];
  const regex = new RegExp(`(?:^|\\s)(${words.join('|')})(?:\\s|\\.|\\?|!|$)`, 'i');

  return robot.hear(
    regex,
    res => res.send('You have been fined one credit for a violation of the verbal morality statute.'),
  );
};
