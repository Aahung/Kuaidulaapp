// Example model

var mongoose = require('mongoose'),
  Schema = mongoose.Schema;

var Sentence = new Schema({
    words: [String]
});

var Paragraph = new Schema({
    sentences: [Sentence]
});

var ArticleSchema = new Schema({
  title: String,
  keywords: [String],
  paragraphs: [Paragraph],
  url: String,
  time: Number,
  censor: String,
  censored: Boolean
});

mongoose.model('Article', ArticleSchema);

