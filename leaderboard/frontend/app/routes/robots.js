import Route from '@ember/routing/route';
import GetTeams from './leaderboard-api';

export default class RobotRoute extends Route {
    async model() {
        return GetTeams("robots");
    }
}
