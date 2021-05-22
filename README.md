# TopScore

TopScore is a ruby on rails based json web app for collecting player scores and presenting player stats.

## Prerequisites

This application has been developed in Linux under a ruby environment managed by `rvm`.  It is highly recommended that you use `rvm` or `rbenv` to manage the ruby environment for this application.  If you have `rvm` installed it will guide you through setting up your environment when you change into the source directory on the command line.

It should run under OSX and windows with WSL but I do not have the environments to test this.  If you have a problem please create a ticket in github.

It is assumed you have a recent version of `docker` and `docker-compose` setup and running on your system.

The application also requires a postgresql database which we will run in docker.

## Installation

Clone the code from github, change into the directory and run bundle install using the commands given bellow.

```console
git clone https://github.com/emiddleton/top_score.git
cd top_score
bundle install
```

## Database setup

For local development and running tests you will need to setup a dockerized postgresql server using the following commands.

```console
docker run -e POSTGRES_USER=developer \
           -e POSTGRES_PASSWORD=development-password \
           -p 0.0.0.0:5432:5432 \
           -d postgres \
           postgres -N 1000
```

When this completes you will need to create the initial database with

```console
rails db:create
rails db:migrate
```

### What to do if you have an existing postgresql server running
  
If you have an existing postgresql server running on your machine the port it is using will conflict with the one the docker instance is exposed on.  You will need to either stop the existing server before running the above command or change the port number the dockerized postgresql is exposed on.  The process for running docker on a different port is explained bellow.  Start by running the dockerized postgresql with the below command which will expose it on the first available port

```console
docker run -e POSTGRES_USER=developer \
           -e POSTGRES_PASSWORD=development-password \
           -p 0.0.0.0:0:5432 \
           -d postgres \
           postgres -N 1000
```

To find which port was, used run the `docker ps` command.  In the example below postgresql is being exposed on port 49153

```console
$ docker ps
CONTAINER ID   IMAGE      COMMAND                  CREATED          STATUS          PORTS                     NAMES
702e80ab39a6   postgres   "docker-entrypoint.s…"   4 seconds ago    Up 2 seconds    0.0.0.0:49153->5432/tcp   suspicious_wilbur
```

You will now need to update the database port number in the `config/database.yml` file to point to the port your database is exposed on, as shown in this example bellow (in the examples the port is 49143).

```yaml
..
development_default: &development_default
  <<: *default
  host: 127.0.0.1
  port: 49153
...
```

When this completes you will need to create the initial database with

```console
rails db:create
rails db:migrate
```

## Running Tests

Tests are implemented in `rspec`.  To run all test type `rspec` in the source root directory.  Code coverage report will be generated in coverage/index.html when the test complete.

## Testing the Production Like Environment

You can run the application locally using docker-compose with the following command which will start the application in a production like environment, using its own database and exposing an API on localhost port 80

```console
docker-compose run web-api rails db:create db:migrate && \
  docker-compose up
```

you can use control-c to stop the running containers

## Upgrading the Production Like Environment

To upgrade just the rails containers

1. use control-c to stop the running containers

2. run the following.

```console
docker-compose rm --force web-api && \
  docker-compose up --no-start --no-recreate --build web-api && \
  docker-compose up
```

## Removing the Production Like Environment

**WARN: this will loose all data in the containers database**

1. Use control-c to stop running containers

2. remove all running and stopped containers (WARN: this will destroy all data in database)

```console
docker-compose kill && \
  docker-compose rm
```

## API

The API has five endpoints listed below.  The API calls are documented in more detail below.

```
Prefix Verb   URI Pattern              Controller#Action
scores GET    /scores(.:format)        scores#index       Get all scores
       POST   /scores(.:format)        scores#create      Add a score
 score GET    /scores/:id(.:format)    scores#show        Get a score by id
       DELETE /scores/:id(.:format)    scores#destroy     Delete a score by id
       GET    /players/:name(.:format) players#show       Get stats on a player
```

All requests should use the following headers

```
Accept:       application/json
Content-type: application/json
```

All datetimes should be in UTC and ISO8601 encoded (e.g. YYYY-MM-DDTHH:MM:SS.mmmZ)

Scores use a database generated UUID for their `id`.

### Get all scores

#### Filters - optional

Query filters are given as url query parameters.  They have the form

```
'q[' + attribute '_' + predicate + ']=' value
```

where attribute is one of `name`, `score` or `time` and the predicates are any of those listed
on the ransack site at https://github.com/activerecord-hackery/ransack#search-matchers

In the following example we are filtering on the `time` field for values greater then `gt` the time
`2020-02-01T10:20:00.000Z`,

```
Request
  Method:   GET
  URL:      /scores

  Optional Filter
    QUERY:    q[attribute_predicate]=value

Response:

  Headers:
            Current-Page: The page that was returned
            Page-Items:   Number of items per page
            Total-Pages:  Total number of pages
            Total-Count:  Total number of scores

  Body:     "[
              {
                "id":   "UUID",
                "name": "PLAYER_NAME",
                "score": SCORE,
                "time": "DATE_SCORE_OCCURRED"
              }
              ...
            ]"
```

### Add a score

```
Request
  Method:   POST
  URL:      /scores

  BODY:     "{
              "score": {
                "name": "PLAYER_NAME",
                "score": SCORE,
                "time": "DATE_SCORE_OCCURRED"
              }
            }"

Response:
  Status:   200 OK   
  Body:     "{
              "id":   "UUID",
              "name": "PLAYER_NAME",
              "score": SCORE,
              "time": "DATE_SCORE_OCCURRED"
            }"

Failure:
  Status:   422 Unprocessable Entity
  Body:     "{"message":"Validation failed: VALIDATION_FAILURE_MESSAGE"}

  Status:   422 Unprocessable Entity
  Body:     "{"message":"This score has already been posted."}
```

### Get a score by id

```
Request
  Method:   GET
  URL:      /scores/:UUID

Response:
  Status:   200 OK   
  Body:     "{
              "id":   "UUID",
              "name": "PLAYER_NAME",
              "score": SCORE,
              "time": "DATETIME_SCORE_OCCURRED"
            }"

Failure:
  Status:   404 Not Found
  Body:     "{
              "message": "Couldn't find Score with 'id'=UUID"
            }"
```

### Delete score by id

```
Request
  Method:   DELETE
  URL:      /scores/:UUID

Response:
  Status:   204 No Content

Failure:
  Status:   404 Not Found
  Body:     "{
              "message": "Couldn't find Score with 'id'=UUID"
            }"
```

### Get stats on player

The player name in the url must be percentage encoded if it contains non alphanumeric characters.
https://en.wikipedia.org/wiki/Percent-encoding

```
Request
  Method:   GET
  URL:      /players/:PERCENTAGE_ENCODED_PLAYER_NAME

Response:
  Status:   200 OK   
  Body:     "{
              "name": "PLAYER_NAME",
              "top_score": TOP_SCORE,
              "low_score": LOW_SCORE,
              "average_score": AVERAGE_SCORE,
              "history": [
                {
                  "score": SCORE,
                  "time": "DATETIME_SCORE_OCCURRED"
                },
                ...
              ]
            }"

Failure:
  Status:   404 Not Found
  Body:     "{
              "message": "Couldn't find Player"
            }"
```

## Usage

You can test the production like API with `curl` using the following `curl` commands.

The examples below use `jq` to pretty print the json output.  You can find installation instructions for `jq` here
https://stedolan.github.io/jq/

* adding a score

```console
curl -v -H "Accept: application/json" \
        -H "Content-type: application/json" \
        -X POST -d '{"score":{"name":"test","score":100,"time":"2020-02-01T10:20:00"}}' \
        http://localhost/scores | jq
```

* deleting a score

```console
curl -v -H "Accept: application/json" \
        -H "Content-type: application/json" \
        -X DELETE http://localhost/scores/ba0b2580-3a8c-42a3-9f1b-5577c6631bf9 | jq
```

* getting all scores

```console
curl -v -H "Accept: application/json" \
        -H "Content-type: application/json" \
        -X GET http://localhost/scores | jq
```

### Filters

Query filters are given as url query parameters.  They have the form

```
'q[' + attribute '_' + predicate + ']=' value
```

where attribute is one of `name`, `score` or `time` and the predicates are any of those listed
on the ransack site at https://github.com/activerecord-hackery/ransack#search-matchers

In the following example we are filtering on the `time` field for values greater then `gt` the time
`2020-02-01T10:20:00.000Z`,

* getting all scores occurring more recently then 10:00 am on February 1st 2020

```console
curl -v -H "Accept: application/json" \
        -H "Content-type: application/json" \
        -X GET -G http://localhost/scores -d "q[time_gt]=2020-02-01T10:20:00.000Z" | jq    
```

* getting scores in a time range

```console
curl -v -H "Accept: application/json" \
        -H "Content-type: application/json" \
        -X GET -G http://localhost/scores \
        -d "q[time_gt]=2020-02-01T10:20:00.000Z&q[time_lt]=2020-02-01T20:20:00.000Z" | jq
```

### Player Stats

* getting stats for a player with name `Mr. player name`

The name needs to be percent-encoded if it contains special characters.
https://en.wikipedia.org/wiki/Percent-encoding

```console
curl -v -H "Accept: application/json" \
        -H "Content-type: application/json" \
        -X GET -G http://localhost/players/Mr%2E%20player%20name | jq    
```