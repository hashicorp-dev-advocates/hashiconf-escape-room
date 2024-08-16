import Route from '@ember/routing/route';
import GetTeams from './leaderboard-api';

export default class EscapeRoomSLMRoute extends Route {
  async model() {
    return GetTeams("slm");
  }
}
