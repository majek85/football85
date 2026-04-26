const logger = require('../utils/logger');

class NotificationService {
  async sendPushNotification(topic, title, body, data = {}) {
    logger.info(`Sending Push Notification to topic: ${topic}`, { title, body });
    
    // In a production environment, you would use:
    // admin.messaging().send({ topic, notification: { title, body }, data });
    
    return { success: true, messageId: `mock_${Date.now()}` };
  }

  async notifyGoal(match, scoringTeam) {
    const title = '⚽ Goal!';
    const body = `${scoringTeam} scored! ${match.homeTeam} ${match.score.home} - ${match.score.away} ${match.awayTeam}`;
    
    // Notify match topic and individual team topics
    await this.sendPushNotification(`match_${match.id}`, title, body);
    await this.sendPushNotification(`team_${scoringTeam.replace(/\s+/g, '_')}`, title, body);
  }

  async notifyRedCard(match, team, player) {
    const title = '🟥 Red Card!';
    const body = `Red card for ${player} (${team}) in ${match.homeTeam} vs ${match.awayTeam}`;
    await this.sendPushNotification(`match_${match.id}`, title, body);
  }
}

module.exports = new NotificationService();
