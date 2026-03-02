const axios = require('axios');
const NodeCache = require('node-cache');
require('dotenv').config();

const FPL_API_BASE = process.env.FPL_API_BASE || 'https://fantasy.premierleague.com/api';

// Initialize cache with standard TTL (600 seconds = 10 minutes)
const cache = new NodeCache({ stdTTL: 600, checkperiod: 120 });

/**
 * Fetch data from FPL API with caching
 * @param {string} endpoint - API endpoint path
 * @param {number} ttl - Time to live in seconds (optional)
 * @returns {Promise<object>} API response data
 */
const fetchWithCache = async (endpoint, ttl = 600) => {
  const cacheKey = `fpl_${endpoint}`;

  // Check cache first
  const cachedData = cache.get(cacheKey);
  if (cachedData) {
    console.log(`Cache hit: ${cacheKey}`);
    return cachedData;
  }

  try {
    console.log(`Fetching FPL API: ${endpoint}`);
    const response = await axios.get(`${FPL_API_BASE}${endpoint}`, {
      timeout: 10000,
    });

    // Cache the result
    cache.set(cacheKey, response.data, ttl);
    return response.data;
  } catch (error) {
    console.error(`FPL API error for ${endpoint}:`, error.message);
    throw new Error(`Failed to fetch from FPL API: ${error.message}`);
  }
};

/**
 * Get bootstrap static data (teams, players, phases, gameweeks)
 * Cached for 6 hours (21600 seconds)
 */
const fetchBootstrapStatic = async () => {
  return fetchWithCache('/bootstrap-static/', 21600);
};

/**
 * Get all fixtures
 * Cached for 30 minutes (1800 seconds) - updates frequently
 */
const fetchFixtures = async () => {
  return fetchWithCache('/fixtures/', 1800);
};

/**
 * Get fixtures for a specific gameweek
 */
const fetchFixturesByGameweek = async (gameweek) => {
  const fixtures = await fetchFixtures();
  const gameweekFixtures = fixtures.filter((fixture) => fixture.event === gameweek);
  return gameweekFixtures;
};

/**
 * Get classic league standings
 * Cached for 10 minutes (600 seconds)
 */
const fetchClassicLeagueStandings = async (leagueId, pageNumber = 1) => {
  const endpoint = `/leagues-classic/${leagueId}/standings/?page_standings=${pageNumber}`;
  return fetchWithCache(endpoint, 600);
};

/**
 * Get H2H league standings
 * Cached for 10 minutes
 */
const fetchH2HLeagueStandings = async (leagueId, pageNumber = 1) => {
  const endpoint = `/leagues-h2h/${leagueId}/standings/?page_standings=${pageNumber}`;
  return fetchWithCache(endpoint, 600);
};

/**
 * Get H2H league matches (head-to-head results)
 * Cached for 10 minutes
 */
const fetchH2HMatches = async (leagueId, gameweek) => {
  const endpoint = `/leagues-h2h-matches/league/${leagueId}/?event=${gameweek}`;
  return fetchWithCache(endpoint, 600);
};

/**
 * Get user team info and league membership
 * Cached for 10 minutes
 */
const fetchUserTeam = async (fplTeamId) => {
  const endpoint = `/entry/${fplTeamId}/`;
  return fetchWithCache(endpoint, 600);
};

/**
 * Get user team history (chip usage, etc.)
 * Cached for 1 hour (3600 seconds)
 */
const fetchUserHistory = async (fplTeamId) => {
  const endpoint = `/entry/${fplTeamId}/history/`;
  return fetchWithCache(endpoint, 3600);
};

/**
 * Get mini standings for a user in a specific gameweek
 * Cached for 10 minutes
 */
const fetchMiniStanding = async (entryId, gameweek) => {
  const endpoint = `/entry/${entryId}/event/${gameweek}/picks/`;
  return fetchWithCache(endpoint, 600);
};

/**
 * Clear specific cache key
 */
const clearCache = (endpoint) => {
  cache.del(`fpl_${endpoint}`);
};

/**
 * Clear all FPL cache
 */
const clearAllCache = () => {
  cache.flushAll();
};

/**
 * Get cache statistics
 */
const getCacheStats = () => {
  return cache.getStats();
};

module.exports = {
  fetchBootstrapStatic,
  fetchFixtures,
  fetchFixturesByGameweek,
  fetchClassicLeagueStandings,
  fetchH2HLeagueStandings,
  fetchH2HMatches,
  fetchUserTeam,
  fetchUserHistory,
  fetchMiniStanding,
  clearCache,
  clearAllCache,
  getCacheStats,
};
