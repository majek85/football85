const logger = require('../utils/logger');
const notifications = require('./notification_service');

class EventDetectionService {
  constructor() {
    this.prevMatchesState = new Map();
  }

  detect(currentMatches) {
    if (!Array.isArray(currentMatches)) return;

    for (const match of currentMatches) {
      const prevState = this.prevMatchesState.get(match.id);

      if (prevState) {
        this.compareAndNotify(prevState, match);
      }

      // Update state for next check
      this.prevMatchesState.set(match.id, match);
    }
  }

  compareAndNotify(prev, current) {
    // 1. Detect Goals
    if (current.score.home > prev.score.home) {
      notifications.notifyGoal(current, current.homeTeam);
    }
    if (current.score.away > prev.score.away) {
      notifications.notifyGoal(current, current.awayTeam);
    }

    // 2. Detect Red Cards (Checking events array)
    const prevRedCards = prev.events.filter(e => e.type === 'Card' && e.detail === 'Red Card').length;
    const currentRedCards = current.events.filter(e => e.type === 'Card' && e.detail === 'Red Card');

    if (currentRedCards.length > prevRedCards) {
      const lastRed = currentRedCards[currentRedCards.length - 1];
      notifications.notifyRedCard(current, lastRed.team.name, lastRed.player.name);
    }
  }
}

module.exports = new EventDetectionService();
