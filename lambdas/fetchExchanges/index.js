let AWS = require('aws-sdk');
AWS.config.update({region: 'us-east-2'});

var docClient = new AWS.DynamoDB.DocumentClient();

const request = require('request');

const baseExchangesUrl = 'https://cloud.iexapis.com/v1/ref-data/exchanges?token=';

let API_KEY = process.env.API_KEY;

exports.handler = function (event, context, callback) {
  var queryParams = {
    TableName: "exchanges",
    ProjectionExpression: "exchange, description",
  };

  console.log("Checking db for existing exchanges...");
  docClient.scan(queryParams, function(err, data) {
    if (err) { 
       return console.log(err);
    }
    
    if (data["Items"].length == 0) {
      console.log("fetching exchanges from API...");
      request(baseExchangesUrl + API_KEY, {}, (err, res, body) => {
        if (err) {
           return console.log(err);
        }

        const response = {
          statusCode: 200,
          body: body,
          headers: {
            "Access-Control-Allow-Origin": "*"
          }
        };

        console.log("Serving exchanges from the API");
        console.log(body);
        callback(null, response);

        let expirationDate = Date.now() + 30; // Expire in 30 days

        console.log("Saving fetched exchanges to db...");
        var exchanges = JSON.parse(body);
        exchanges.forEach(function(exchange) {
          var params = {
            TableName: "exchanges",
            Item: {
              "exchange": exchange.exchange,
              "region": exchange.region,
              "description": exchange.description,
              "mic": exchange.mic,
              "expires": expirationDate
            }
          };

          docClient.put(params, function(err, data) {
            if (err) {
              console.error("Unable to add exchange", exchange.exchange, ". Error JSON:", JSON.stringify(err, null, 2));
            } else {
              console.log("PutItem succeeded:", exchange.exchange);
            }
          });
        });
      });      
    } else {
      console.log("Serving exchanges from the db");
      
      const response = {
        statusCode: 200,
        body: JSON.stringify(data["Items"]),
        headers: {
          "Access-Control-Allow-Origin": "*"
        }
      };

      callback(null, response);
    }
  });
};
