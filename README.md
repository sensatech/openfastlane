### Setup local mongodb environment


#### Prepare 

See .env-mongo and setup your LOCAL environment accordingly.
As that example file is checked into git, it is not a good idea to put your credentials there.

Therefore, we use "password" as password for the user "ofl" in the following examples,
to indicate how unsafe that is.

#### Start mongodb

```bash
docker-compose -f docker-compose.yml up -d
```

#### Create a mongodb user

```bash
mongosh "mongodb://ofl:password@localhost:27027/" --username ofl
```
```python
use openfastlane
db.createUser({
    user: "ofl",
    pwd: "password",
    roles: [
        {role: "readWrite", db: "openfastlane"},
// Add more roles if needed
    ]
})
```

#### Test connection works DIRECTLY FOR DATABASE !!!11!!

```bash
mongosh "mongodb://ofl:password@localhost:27027/openfastlane" --username ofl
```

Must succeed! Otherwise database and user are not set up correctly.