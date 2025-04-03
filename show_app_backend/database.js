const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./shows.db');

// Convert db.run to promise
db.runAsync = function (sql, params) {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function (err) {
      if (err) reject(err);
      else resolve(this);
    });
  });
};

// Convert db.get to promise
db.getAsync = function (sql, params) {
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, result) => {
      if (err) reject(err);
      else resolve(result);
    });
  });
};

// Convert db.all to promise
db.allAsync = function (sql, params) {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) reject(err);
      else resolve(rows);
    });
  });
};

// Fonction pour ajouter un utilisateur
function addUser(email, password) {
  return new Promise((resolve, reject) => {
    const sql = `INSERT INTO users (email, password) VALUES (?, ?)`;
    db.run(sql, [email, password], function (err) {
      if (err) {
        reject(err);
      } else {
        resolve(`Utilisateur ajouté avec succès, ID: ${this.lastID}`);
      }
    });
  });
}

// Exemple pour ajouter un utilisateur spécifique
addUser('meryembahoum@devoir.com', 'Bahoum123')
  .then(result => console.log(result))
  .catch(err => console.error('Erreur lors de l\'ajout de l\'utilisateur:', err));

db.serialize(() => {
  // Create shows table
  db.run(`CREATE TABLE IF NOT EXISTS shows (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT CHECK(category IN ('movie', 'anime', 'serie')) NOT NULL,
    image TEXT
  )`);

  // Create users table
  db.run(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  // Create images table
  db.run(`CREATE TABLE IF NOT EXISTS images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT NOT NULL,
    path TEXT NOT NULL,
    category TEXT CHECK(category IN ('movie', 'anime', 'serie')) NOT NULL,
    show_id INTEGER,
    FOREIGN KEY (show_id) REFERENCES shows (id)
  )`);
});

module.exports = db;
