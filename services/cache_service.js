const logger = require('../utils/logger');

// Simple In-memory cache with TTL
class CacheService {
  constructor() {
    this.cache = new Map();
  }

  set(key, data, ttlSeconds) {
    const expiresAt = Date.now() + (ttlSeconds * 1000);
    this.cache.set(key, { data, expiresAt });
    logger.info(`Cache SET for key: ${key}`, { expiresAt: new Date(expiresAt).toISOString() });
  }

  get(key) {
    const entry = this.cache.get(key);
    if (!entry) return null;

    if (Date.now() > entry.expiresAt) {
      logger.info(`Cache EXPIRED for key: ${key}`);
      this.cache.delete(key);
      return null;
    }

    logger.info(`Cache HIT for key: ${key}`);
    return entry.data;
  }

  delete(key) {
    this.cache.delete(key);
  }
}

// Export as a singleton for shared use across warm instances
module.exports = new CacheService();
