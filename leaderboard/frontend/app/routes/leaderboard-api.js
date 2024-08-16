import config from '../config/environment';

async function GetTeams(activation) {
    let url = encodeURI(config.APP.LEADERBOARD_API + '/teams/activations/' + activation);
    let response = await fetch(url);
    let data = await response.json();
    return data.map((model, index) => {
      let rank = index + 1;
      return { rank, ...model };
    });
}

export default GetTeams;