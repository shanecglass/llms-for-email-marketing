## Instructions to deploy to Cloud Run

0. Add in a KEY in main.py:
```
# Line 12
app.config['SECRET_KEY'] = 'REPLACE-ME'
```

1. Enable the services on GCP:
```
./init
```

2. Build the container
```
./bld
```

3. Deploy the container
```
./deploy
```

If you run into permissions executing the scripts above, make sure you have permission to run them:
```
chmod +x init
chmod +x bld
chmod +x deploy
```
