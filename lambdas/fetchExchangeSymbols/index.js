let AWS = require('aws-sdk');
AWS.config.update({region: 'us-east-2'});

var docClient;

const request = require('request');

const baseExchangesUrl = "https://cloud.iexapis.com/v1/ref-data/exchange/[exchange]/symbols?token=";

let API_KEY = process.env.API_KEY;

exports.handler = function (event, context, callback) {
    if (!docClient) {
        docClient = new AWS.DynamoDB.DocumentClient();
    }

    var exchange = event.pathParameters.exchange;

    var queryParams = {
        TableName: "exchange_symbols",
        KeyConditionExpression: "#exchange = :exchange",
        ProjectionExpression: "exchange, #name, symbol",
        ExpressionAttributeNames: {
            "#exchange": "exchange",
            "#name": "name"
        },
        ExpressionAttributeValues: {
            ":exchange": exchange
        }
    };

    console.log("Checking db for existing exchange symbols...");
    docClient.query(queryParams, function(err, data) {
        if (err) {
            return console.log(err);
        }

        if (data["Items"].length == 0) {
            console.log("Fetching exchange symbols from API...");
            request(baseExchangesUrl.replace("[exchange]", exchange) + API_KEY, {}, (err, res, body) => {
                if (err) {
                    return console.log(err);
                }

                const s3 = new AWS.S3();

                let symbols = minimizeJSON(JSON.parse(body));

                const params = {
                    Bucket: "stocktracker-symbols",
                    Key: exchange + "-symbols",
                    Body: JSON.stringify({"exchange": exchange, "symbols": symbols}),
                    ContentType: "json"
                };

                console.log("Saving exchange symbols to S3...");
                s3.putObject(params, function(error, data) {
                    if (error) {
                        console.error('Error invoking S3 putObject', error);
                    }
                });

                console.log("Serving exchange symbols from the API");
                const response = {
                    statusCode: 200,
                    body: symbols,
                    headers: {
                      "Access-Control-Allow-Origin": "*"
                    }
                };

                callback(null, response);
            });
        } else {
            console.log("Serving exchange symbols from the db");
            console.log(data["Items"].length);

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

function minimizeJSON(symbols) {
    var returnJSON = [];

    symbols.forEach(function(symbol) {
        returnJSON.push({
            'exchange': symbol.exchange,
            'symbol': symbol.symbol,
            'name': symbol.name,
        })
    });

    return JSON.stringify(returnJSON);
}