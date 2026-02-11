#!/bin/bash
# Update system
sudo yum update -y

# Install Node.js (Amazon Linux 2)----------------try to do it by your own-----------
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs git

# Create app directory
mkdir -p /home/ec2-user/express_app
cd /home/ec2-user/express_app

# Initialize Node project
npm init -y

# Install dependencies
npm install express body-parser @aws-sdk/client-dynamodb @aws-sdk/lib-dynamodb

# Create Express app
cat <<'EOF' > app.js
const express = require('express');
const bodyParser = require('body-parser');
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand } = require('@aws-sdk/lib-dynamodb');

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));

// DynamoDB client (uses IAM role attached to EC2)
const client = new DynamoDBClient({ region: 'us-east-1' });
const ddb = DynamoDBDocumentClient.from(client);

const TABLE_NAME = "mytable"

const HTML_FORM = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <h1>Dynamo db simple app</h1>
    <h2>Add file to dynamo db</h2>
    <form id="form" method="post" action="submit">
        <input type="text" name="USERID" id="USERID" placeholder="enter user id" required>
        <input type="email" name="EMAIL" id="EMAIL" placeholder="enter email" required>
        <button type="submit">submit</button>
    </form>
</body>
</html>
`;

app.get("/",(req,res)=>{
  res.send(HTML_FORM)
});

app.post('/submit', async (req, res) => {
  const { UserID, Email } = req.body;

  try {
    await ddb.send(
      new PutCommand({
        TableName: TABLE_NAME,
        Item: { USERID, EMAIL }
      })
    );

    res.send(`
      <b>✅ User saved successfully!</b><br>
      UserID: ${USERID}<br>
      Email: ${EMAIL}<br><br>
      <a href="/">← Go Back</a>
    `);
  } catch (err) {
    res.send(`❌ Error saving user: ${err.message}`);
  }
});

app.listen(80, '0.0.0.0', () => {
  console.log('Server running on port 80');
});
EOF

# Run app in background
sudo nohup node /home/ec2-user/express_app/app.js \
> /home/ec2-user/express_app/app.log 2>&1 &