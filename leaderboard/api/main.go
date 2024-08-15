package main

import (
	"math"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
	"github.com/hashicorp-dev-advocates/hashiconf-escape-room/leaderboard/api/data"
	"github.com/hashicorp-dev-advocates/hashiconf-escape-room/leaderboard/api/handlers"
	"github.com/hashicorp/go-hclog"
	"github.com/nicholasjackson/env"
	"github.com/rs/cors"
)

type Config struct {
	DBConnection           string  `json:"db_connection"`
	BindAddress            string  `json:"bind_address"`
	MaxRetries             int     `json:"max_retries"`
	BackoffExponentialBase float64 `json:"backoff_exponential_base"`
}

var conf *Config
var logger hclog.Logger

var dbConnection = env.String("DB_CONNECTION", true, "", "db connection string")
var bindAddress = env.String("BIND_ADDRESS", false, "0.0.0.0:9090", "Bind address")
var maxRetries = env.Int("MAX_RETRIES", false, 60, "Maximum number of connection retries")
var backoffExponentialBase = env.Float64("BACKOFF_EXPONENTIAL_BASE", false, 1, "Exponential base number to calculate the backoff")

type Team struct {
	ID            string `json:"id"`
	Name          string `json:"name"`
	TimeCompleted int    `json:"time_completed"`
}

func main() {
	logger = hclog.Default()

	err := env.Parse()
	if err != nil {
		logger.Error("Error parsing flags", "error", err)
		os.Exit(1)
	}

	conf = &Config{
		DBConnection:           *dbConnection,
		BindAddress:            *bindAddress,
		MaxRetries:             *maxRetries,
		BackoffExponentialBase: *backoffExponentialBase,
	}

	db, err := retryDBUntilReady()
	if err != nil {
		logger.Error("Timeout waiting for database connection")
		os.Exit(1)
	}

	r := mux.NewRouter()

	// Enable CORS for all hosts
	r.Use(cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
		AllowedMethods: []string{"POST", "GET", "OPTIONS", "PUT", "DELETE"},
		AllowedHeaders: []string{"Accept", "content-type", "Content-Length", "Accept-Encoding", "X-CSRF-Token", "Authorization"},
	}).Handler)

	healthHandler := handlers.NewHealth(logger, db)
	r.HandleFunc("/health/livez", healthHandler.Liveness).Methods("GET")
	r.HandleFunc("/health/readyz", healthHandler.Readiness).Methods("GET")

	teamHandler := handlers.NewTeam(db, logger)
	r.HandleFunc("/teams", teamHandler.GetTeams).Methods("GET")
	r.HandleFunc("/teams/{id:[0-9]+}", teamHandler.GetTeam).Methods("GET")
	r.HandleFunc("/teams/activations/{name}", teamHandler.GetTeamsByActivation).Methods("GET")
	r.HandleFunc("/teams", teamHandler.CreateTeam).Methods("POST")
	r.HandleFunc("/teams/{id:[0-9]+}", teamHandler.DeleteTeam).Methods("DELETE")

	logger.Info("Starting service", "bind", conf.BindAddress)
	err = http.ListenAndServe(conf.BindAddress, r)
	if err != nil {
		logger.Error("Unable to start server", "bind", conf.BindAddress, "error", err)
	}
}

func retryDBUntilReady() (data.Connection, error) {
	maxRetries := conf.MaxRetries
	backoffExponentialBase := conf.BackoffExponentialBase
	dt := 0

	retries := 0
	backoff := time.Duration(0) // backoff before attempting to conection

	for {
		db, err := data.New(conf.DBConnection)
		if err == nil {
			return db, nil
		}

		logger.Error("Unable to connect to database", "error", err)

		// check if current retry reaches the max number of allowed retries
		if retries > maxRetries {
			return nil, err
		}

		// retry
		retries++
		dt = int(math.Pow(backoffExponentialBase, float64(retries)))
		backoff = time.Duration(dt) * time.Second
		time.Sleep(backoff)
	}
}
