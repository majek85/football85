const football = require('../../services/football_service');
const events = require('../../services/event_detection');
const logger = require('../../utils/logger');

exports.handler = async (event, context) => {
  const path = event.path.split('/').pop();
  const id = event.queryStringParameters.id;

  try {
    let data;

    switch (path) {
      case 'todayMatches':
        data = await football.getTodayMatches();
        break;

      case 'liveMatches':
        data = await football.getLiveMatches();
        // Run event detection background process (simulation in serverless)
        events.detect(data);
        break;

      case 'matchDetails':
        if (!id) throw new Error('Match ID is required');
        // Specific detailed fetch would go here
        data = await football.fetchWithThrottling(`fixtures?id=${id}`, {}, `match_${id}`, 60);
        break;

      default:
        return {
          statusCode: 404,
          body: JSON.stringify({ error: 'Endpoint not found' })
        };
    }

    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*', // CORS for frontend
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    };

  } catch (error) {
    logger.error('Function execution failed', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message || 'Internal Server Error' })
    };
  }
};
