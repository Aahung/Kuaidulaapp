var path = require('path'),
    rootPath = path.normalize(__dirname + '/..'),
    env = process.env.NODE_ENV || 'development';

var config = {
  development: {
    root: rootPath,
    app: {
      name: 'kuaidula'
    },
    port: 3000,
    db: 'mongodb://localhost/kuaidula-development'
    
  },

  test: {
    root: rootPath,
    app: {
      name: 'kuaidula'
    },
    port: 3000,
    db: 'mongodb://localhost/kuaidula-test'
    
  },

  production: {
    root: rootPath,
    app: {
      name: 'kuaidula'
    },
    port: 3000,
    db: 'mongodb://localhost/kuaidula-production'
    
  }
};

module.exports = config[env];
