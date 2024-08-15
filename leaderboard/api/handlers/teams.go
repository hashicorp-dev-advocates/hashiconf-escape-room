package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/hashicorp-dev-advocates/hashiconf-escape-room/leaderboard/api/data"
	"github.com/hashicorp/go-hclog"
)

// Team -
type Team struct {
	con data.Connection
	log hclog.Logger
}

// NewTeam
func NewTeam(con data.Connection, l hclog.Logger) *Team {
	return &Team{con, l}
}

func (c *Team) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	c.log.Info("Handle Teams")

	var teamID *int

	teams, err := c.con.GetTeams(teamID)
	if err != nil {
		c.log.Error("Unable to get teams from database", "error", err)
		http.Error(rw, "Unable to list teams", http.StatusInternalServerError)
		return
	}

	d, err := teams.ToJSON()
	if err != nil {
		c.log.Error("Unable to convert teams to JSON", "error", err)
		http.Error(rw, "Unable to list teams", http.StatusInternalServerError)
		return
	}

	rw.Write(d)
}

// CreateTeam creates a new order
func (c *Team) CreateTeam(rw http.ResponseWriter, r *http.Request) {
	c.log.Info("Handle Teams | CreateTeam")

	body := data.Team{}

	err := json.NewDecoder(r.Body).Decode(&body)
	if err != nil {
		c.log.Error("Unable to decode JSON", "error", err)
		http.Error(rw, "Unable to parse request body", http.StatusInternalServerError)
		return
	}

	team, err := c.con.CreateTeam(&body)
	if err != nil {
		c.log.Error("Unable to create new team", "error", err)
		http.Error(rw, "Unable to create new team", http.StatusInternalServerError)
		return
	}

	d, err := team.ToJSON()
	if err != nil {
		c.log.Error("Unable to convert team to JSON", "error", err)
		http.Error(rw, "Unable to create new team", http.StatusInternalServerError)
	}

	rw.Write(d)
}

// GetTeams gets a list of teams in order of speed
func (c *Team) GetTeams(rw http.ResponseWriter, r *http.Request) {
	c.log.Info("Handle Teams | GetTeams")

	teams, err := c.con.GetTeams(nil)
	if err != nil {
		c.log.Error("Unable to get teams from database", "error", err)
		http.Error(rw, "Unable to list teams", http.StatusInternalServerError)
		return
	}

	d, err := teams.ToJSON()
	if err != nil {
		c.log.Error("Unable to convert team to JSON", "error", err)
		http.Error(rw, "Unable to list team", http.StatusInternalServerError)
		return
	}

	rw.Write(d)
}

// GetTeamsByActivation gets a list of teams by activation in order of speed
func (c *Team) GetTeamsByActivation(rw http.ResponseWriter, r *http.Request) {
	c.log.Info("Handle Teams | GetTeamsByActivation")

	vars := mux.Vars(r)

	activation, ok := vars["name"]
	if !ok {
		c.log.Error("activation provided could not be converted to a string")
		http.Error(rw, "Unable to list team", http.StatusInternalServerError)
		return
	}

	teams, err := c.con.GetTeamsByActivation(activation)
	if err != nil {
		c.log.Error("Unable to get teams from database", "error", err)
		http.Error(rw, "Unable to list teams", http.StatusInternalServerError)
		return
	}

	d, err := teams.ToJSON()
	if err != nil {
		c.log.Error("Unable to convert team to JSON", "error", err)
		http.Error(rw, "Unable to list team", http.StatusInternalServerError)
		return
	}

	rw.Write(d)
}

// GetTeam gets a specific team
func (c *Team) GetTeam(rw http.ResponseWriter, r *http.Request) {
	c.log.Info("Handle Teams | GetTeam")

	vars := mux.Vars(r)

	teamID, err := strconv.Atoi(vars["id"])
	if err != nil {
		c.log.Error("teamID provided could not be converted to an integer", "error", err)
		http.Error(rw, "Unable to list team", http.StatusInternalServerError)
		return
	}

	teams, err := c.con.GetTeams(&teamID)
	if err != nil {
		c.log.Error("Unable to get team from database", "error", err)
		http.Error(rw, "Unable to list team", http.StatusInternalServerError)
		return
	}

	team := data.Team{}

	if len(teams) > 0 {
		team = teams[0]
	}

	d, err := team.ToJSON()
	if err != nil {
		c.log.Error("Unable to convert team to JSON", "error", err)
		http.Error(rw, "Unable to list team", http.StatusInternalServerError)
		return
	}

	rw.Write(d)
}

// DeleteTeam deletes a team
func (c *Team) DeleteTeam(rw http.ResponseWriter, r *http.Request) {
	c.log.Info("Handle Teams | DeleteTeam")

	vars := mux.Vars(r)

	teamID, err := strconv.Atoi(vars["id"])
	if err != nil {
		c.log.Error("teamID provided could not be converted to an integer", "error", err)
		http.Error(rw, "Unable to delete team", http.StatusInternalServerError)
		return
	}

	err = c.con.DeleteTeam(teamID)
	if err != nil {
		c.log.Error("Unable to delete team from database", "error", err)
		http.Error(rw, "Unable to delete team", http.StatusInternalServerError)
		return
	}

	fmt.Fprintf(rw, "%s", "Deleted team")
}
