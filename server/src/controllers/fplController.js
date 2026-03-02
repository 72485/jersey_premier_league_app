const fplService = require('../utils/fplService');

/**
 * Get fixtures for a specific gameweek
 */
const getFixtures = async (req, res, next) => {
  try {
    const { gameweek } = req.params;

    if (!gameweek || isNaN(gameweek)) {
      return res.status(400).json({
        success: false,
        error: 'Valid gameweek number required',
        code: 'INVALID_GAMEWEEK',
      });
    }

    const fixtures = await fplService.fetchFixturesByGameweek(parseInt(gameweek));

    return res.json({
      success: true,
      data: fixtures,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error.message,
      code: 'FPL_API_ERROR',
    });
  }
};

/**
 * Get all fixtures
 */
const getAllFixtures = async (req, res, next) => {
  try {
    const fixtures = await fplService.fetchFixtures();

    return res.json({
      success: true,
      data: fixtures,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error.message,
      code: 'FPL_API_ERROR',
    });
  }
};

/**
 * Get bootstrap static data (teams, players, phases)
 */
const getBootstrapStatic = async (req, res, next) => {
  try {
    const data = await fplService.fetchBootstrapStatic();

    return res.json({
      success: true,
      data,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error.message,
      code: 'FPL_API_ERROR',
    });
  }
};

/**
 * Get classic league standings
 */
const getClassicLeagueStandings = async (req, res, next) => {
  try {
    const { leagueId } = req.params;
    const { page = 1 } = req.query;

    if (!leagueId) {
      return res.status(400).json({
        success: false,
        error: 'League ID required',
        code: 'MISSING_LEAGUE_ID',
      });
    }

    const standings = await fplService.fetchClassicLeagueStandings(leagueId, parseInt(page));

    return res.json({
      success: true,
      data: standings,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error.message,
      code: 'FPL_API_ERROR',
    });
  }
};

/**
 * Get H2H league standings
 */
const getH2HLeagueStandings = async (req, res, next) => {
  try {
    const { leagueId } = req.params;
    const { page = 1 } = req.query;

    if (!leagueId) {
      return res.status(400).json({
        success: false,
        error: 'League ID required',
        code: 'MISSING_LEAGUE_ID',
      });
    }

    const standings = await fplService.fetchH2HLeagueStandings(leagueId, parseInt(page));

    return res.json({
      success: true,
      data: standings,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error.message,
      code: 'FPL_API_ERROR',
    });
  }
};

/**
 * Get H2H league matches
 */
const getH2HMatches = async (req, res, next) => {
  try {
    const { leagueId, gameweek } = req.params;

    if (!leagueId || !gameweek) {
      return res.status(400).json({
        success: false,
        error: 'League ID and gameweek required',
        code: 'MISSING_PARAMS',
      });
    }

    const matches = await fplService.fetchH2HMatches(leagueId, parseInt(gameweek));

    return res.json({
      success: true,
      data: matches,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error.message,
      code: 'FPL_API_ERROR',
    });
  }
};

/**
 * Get cache statistics
 */
const getCacheStats = async (req, res, next) => {
  try {
    const stats = fplService.getCacheStats();

    return res.json({
      success: true,
      data: stats,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error.message,
      code: 'ERROR',
    });
  }
};

/**
 * Clear FPL cache
 */
const clearCache = async (req, res, next) => {
  try {
    fplService.clearAllCache();

    return res.json({
      success: true,
      message: 'Cache cleared successfully',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error.message,
      code: 'ERROR',
    });
  }
};

module.exports = {
  getFixtures,
  getAllFixtures,
  getBootstrapStatic,
  getClassicLeagueStandings,
  getH2HLeagueStandings,
  getH2HMatches,
  getCacheStats,
  clearCache,
};
