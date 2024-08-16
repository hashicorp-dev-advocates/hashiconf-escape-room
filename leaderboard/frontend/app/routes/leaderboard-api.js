import config from '../config/environment';

async function GetTeams(activation) {
    let url = encodeURI(config.leaderboardAPI + '/teams/activations/' + activation);
    let response = await fetch(url);
    let data = await response.json();
    return data.map((model, index) => {
      let rank = index + 1;
      let time = convertTime(model.time);

      return { rank, ...model, time };
    });
}

function convertTime(time) {
  let minutes = Math.floor(time / 60);
  let seconds = Math.floor(time - (minutes * 60));
  let milliseconds = Math.round(time % 1 * 1000);
  return minutes.toString().padStart(2, '0') + ':' + seconds.toString().padStart(2, '0') + '.' + milliseconds.toString().padEnd(3, '0');
}

export default GetTeams;