// App parameters - configure your API endpoint here
export const appParams = {
  appId: 'football85',
  token: '',
  functionsVersion: 'v1',
  appBaseUrl: typeof window !== 'undefined' ? window.location.origin : '',
};

// Netlify functions base URL (Old)
// export const API_BASE = '/.netlify/functions/api';

// Vercel serverless functions base URL
export const API_BASE = '/api';
