package handlers

import (
	"fmt"
	"net/http"

	"github.com/hashicorp-dev-advocates/hashiconf-escape-room/leaderboard/api/data"
	"github.com/hashicorp/go-hclog"
)

// Health is a HTTP Handler for health checking
type Health struct {
	logger hclog.Logger
	db     data.Connection
}

// NewHealth creates a new Health handler
func NewHealth(l hclog.Logger, db data.Connection) *Health {
	return &Health{l, db}
}

// Liveness endpoint for health checks indicates server has started
func (h *Health) Liveness(rw http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(rw, "%s", "ok")
}

// Readiness endpoint for health checks indicates server is ready to serve traffic
func (h *Health) Readiness(rw http.ResponseWriter, r *http.Request) {
	_, err := h.db.IsConnected()
	if err != nil {
		rw.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(rw, "error %s", err)
	}

	fmt.Fprintf(rw, "%s", "ok")
}
