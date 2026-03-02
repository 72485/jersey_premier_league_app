const express = require('express');
const fplController = require('../controllers/fplController');

const router = express.Router();

/**
 * GET /api/fpl/bootstrap-static
 * Get bootstrap static data (teams, players, phases, gameweeks)
 */
router.get('/bootstrap-static', fplController.getBootstrapStatic);

/**
 * GET /api/fpl/fixtures
 * Get all fixtures
 */
router.get('/fixtures', fplController.getAllFixtures);

/**
 * GET /api/fpl/fixtures/:gameweek
 * Get fixtures for a specific gameweek
 */
router.get('/fixtures/:gameweek', fplController.getFixtures);

/**
 * GET /api/fpl/league/classic/:leagueId
 * Get classic league standings
 */
router.get('/league/classic/:leagueId', fplController.getClassicLeagueStandings);

/**
 * GET /api/fpl/league/h2h/:leagueId
 * Get H2H league standings
 */
router.get('/league/h2h/:leagueId', fplController.getH2HLeagueStandings);

/**
 * GET /api/fpl/league/h2h/:leagueId/:gameweek
 * Get H2H league matches for a gameweek
 */
router.get('/league/h2h/:leagueId/:gameweek', fplController.getH2HMatches);

/**
 * GET /api/fpl/cache/stats
 * Get cache statistics
 */
router.get('/cache/stats', fplController.getCacheStats);

/**
 * POST /api/fpl/cache/clear
 * Clear FPL cache
 */
router.post('/cache/clear', fplController.clearCache);

module.exports = router;
