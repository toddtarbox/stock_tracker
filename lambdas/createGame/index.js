const mysql = require('mysql');

const con = mysql.createConnection({
  host     : process.env.RDS_HOSTNAME,
  user     : process.env.RDS_USERNAME,
  password : process.env.RDS_PASSWORD,
  port     : process.env.RDS_PORT,
  database : process.env.RDS_DATABASE
});

exports.handler = (event, context, callback) => {
  // allows for using callbacks as finish/error-handlers
  context.callbackWaitsForEmptyEventLoop = false;

  const market = event.market;
  const exchange = event.exchange;
  const numDays = event.numDays;
  
  console.log(market);
  console.log(exchange);
  console.log(numDays);
  
  const now = new Date();

  const id = Date.now();
  
  const end_date = new Date();
  end_date.setDate(now.getDate() + 5);

  const expiration_date = new Date();
  expiration_date.setDate(now.getDate() + 1);
  
  const sql = "INSERT INTO games (id, game_type, name, market, exchange, min_players, max_players, end_date, expiration_date) VALUES ('" + id + "', 'test game type', 'Test Game', '" + market + "', '" + exchange + "', 5, 20, '" + end_date.toISOString() + "', '" + expiration_date.toISOString() + "' )";
  console.log(sql);
  
  con.query(sql, (err, res) => {
    if (err) {
      throw err
    }
    callback(null, '1 records inserted.');
  })
};
