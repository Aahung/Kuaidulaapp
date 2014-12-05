function Article(id) {
    this._id = id;
}

Article.prototype.get = function() {
    // fetch detail of article from database
    this._title = '';
    this._keywords = [];
    this._paragraphs = [[]]; // second level is sentences
    this._time = '';
};

module.exports = Article;