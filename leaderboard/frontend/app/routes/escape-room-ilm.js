import Route from '@ember/routing/route';
import GetTeams from './leaderboard-api';

export default class EscapeRoomILMRoute extends Route {
  async model() {
    return GetTeams("ilm");
  }
}