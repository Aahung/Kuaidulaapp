// Example model

var mongoose = require('mongoose'),
  Schema = mongoose.Schema;

var Sentence = new Schema({
    words: [String]
});

var Paragraph = new Schema({
    sentences: [Sentence]
});

var Comment = new Schema({
    name: String,
    content: String,
    time: Number
});

var ArticleSchema = new Schema({
  category: String,
  title: String,
  keywords: [String],
  paragraphs: [Paragraph],
  url: String,
  time: Number,
  censor: String,
  censored: Boolean,
  comments: [Comment],
  imgs: [String]
});


// ignore the comments when stringfy whole article
ArticleSchema.methods.toJSON = function() {
  var obj = this.toObject();
  delete obj.comments;
  return obj;
};

mongoose.model('Article', ArticleSchema);

