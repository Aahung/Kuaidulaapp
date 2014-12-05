var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res) {
    res.end('Welcome to kuaidula.com');
});

// get detail of article
router.get('/articles/:id', function(req, res) {
    var Article = require('../class/article.js');
    var article = new Article(req.params.id);
    article.get();
    res.end(JSON.stringify(article));
});

// get article list
router.get('/articles/', function(req, res) {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    var articles = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    res.end(JSON.stringify(articles));
});

module.exports = router;
