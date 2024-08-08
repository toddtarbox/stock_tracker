let AWS = require('aws-sdk');
AWS.config.update({region: 'us-east-2'});

require('aws-sdk/clients/apigatewaymanagementapi');

var docClient;

const request = require("request-promise");

const baseQuoteUrl = "https://cloud.iexapis.com/v1/stock/[symbol]/quote?token=";

let API_KEY = process.env.API_KEY;

exports.handler = async (event) => {
    if (!docClient) {
        docClient = new AWS.DynamoDB.DocumentClient();
    }

    console.log(event);

    let symbol = event.pathParameters.symbol;

    var queryParams = {
        TableName: "stock_quote",
        KeyConditionExpression: "#symbol = :symbol",
        ExpressionAttributeNames: {
            "#symbol": "symbol"
        },
        ExpressionAttributeValues: {
            ":symbol": symbol
        }
    };

    console.log("Checking db for existing symbol quote...");
    var data;
    try {
        data = await docClient.query(queryParams).promise();

        let items = data["Items"];
        let now = new Date();

        var response;
        if (items.length == 0) {
            response = fetchAndSave(symbol);
        } else {
            let quote = items[0];
            let lastFetch = new Date(quote.lastFetch);

            if (now - lastFetch > 1*60*1000) {
                console.log("Last fetch over a minute ago, re-fetching from API");
                response = await fetchAndSave(symbol);
            } else {
                console.log("Serving symbol quote from the db");
                response = {
                    statusCode: 200,
                    body: JSON.stringify(quote),
                    headers: {
                      "Access-Control-Allow-Origin": "*"
                    }
                };
            }
        }

        return response;
    } catch (err) {
        console.log(err);
        return {
            statusCode: 500,
            body: err
        }
    }
};

async function fetchAndSave(symbol) {
    console.log("Fetching symbol quote from API...");
    var body;
    try {
        body = await request(baseQuoteUrl.replace("[symbol]", symbol) + API_KEY);
    } catch (err) {
        console.log(err);
        return {
            statusCode: 500,
            body: err
        }
    }

    console.log("Serving symbol quote from the API");
    const response = {
        statusCode: 200,
        body: body,
        headers: {
          "Access-Control-Allow-Origin": "*"
        }
    };

    let fetchDate = Date.now();
    let expires = Date.now() + 30; // Expire in 30 days

    console.log("Saving fetched symbol quote to db...");
    var quote = JSON.parse(body);
    var params = {
        TableName: "stock_quote",
        Item: {
          "companyName": quote.companyName,
          "symbol": quote.symbol,
          "open": quote.open,
          "high": quote.high,
          "low": quote.low,
          "week52High": quote.week52High,
          "week52Low": quote.week52Low,
          "volume": quote.volume,
          "avgTotalVolume": quote.avgTotalVolume,
          "marketCap": quote.marketCap,
          "peRatio": quote.peRatio,
          "previousClose": quote.previousClose,
          "latestPrice": quote.latestPrice,
          "latestUpdate": quote.latestUpdate,
          "lastFetch": fetchDate,
          "expires": expires,
          "isUSMarketOpen": quote.isUSMarketOpen
        }
    };

    var result;
    try {
        result = await docClient.put(params).promise();
        console.log("PutItem succeeded:", quote.symbol);
    } catch (err) {
        console.error("Unable to add quote", quote.symbol, ". Error JSON:", JSON.stringify(err, null, 2));
    }

    return response;
}
