let AWS = require('aws-sdk');
AWS.config.update({region: 'us-east-2'});

var docClient;
var s3;

exports.handler = async (event, context, callback) => {
    if (!docClient) {
        docClient = new AWS.DynamoDB.DocumentClient();
        s3 = new AWS.S3();
    }

    let s3Object = event.Records[0].s3;

    const params = {
        Bucket: s3Object.bucket.name,
        Key: s3Object.object.key
    };
    let symbolsObject = await s3.getObject(params).promise();
    let symbolsJSON = JSON.parse(symbolsObject.Body);
    let exchange = symbolsJSON.exchange;
    console.log("Exchange: " + exchange);

    var symbols = JSON.parse(symbolsJSON.symbols);
    console.log("Saving " + symbols.length + " fetched exchange symbols to db...");

    // Build the batches (25 per batch max)
    var batches = [];
    var current_batch = [];
    var item_count = 0;

    let expirationDate = Date.now() + 1; // Expire in 1 day

    symbols.forEach(function(symbol) {
        item_count++;

        var putRequest = {
            PutRequest: {
                Item: {
                    "exchange": exchange,
                    "name": symbol.name,
                    "symbol": symbol.symbol,
                    "expires": expirationDate
                }
            }
        };
        current_batch.push(putRequest);

        if (item_count % 25 == 0) {
            batches.push(current_batch);
            current_batch = [];
        }
    });

    if(current_batch.length > 0 && current_batch.length != 25) {
        batches.push(current_batch);
    }

    let count = 1;
    function processItemsCallback(data) {
//        console.log(`Response Data: ${JSON.stringify(data)}`);
        let itemsLost = data.UnprocessedItems;
        // Check if Object size is greater than 0 so we can process missed items if needed
        if (itemsLost.constructor === Object && Object.keys(itemsLost).length === 0) {
          return;
        } else {
          console.log('Re-sending missed items');

          setTimeout(function() {
            let params = {};
            params.RequestItems = itemsLost;
            dynamoDB.batchWriteItem(params, processItemsCallback);
          }, 1000 * count);

          // Exponentially raise the backoff time
          count *= 2;
          if (count > 100) {
            count = 100;
          }
        }
    }

    for (x in batches) {
        let batch = batches[x];

        let params = {
            RequestItems: {
                "exchange_symbols": batch
            }
        };

        try {
            let result = await docClient.batchWrite(params).promise();
            processItemsCallback(result);
        } catch (err) {
            console.error("Error saving batch", err);
        }
    }
};
