package handlers

import (
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gorilla/mux"
	"github.com/hashicorp-dev-advocates/hashiconf-escape-room/leaderboard/api/data"
	"github.com/hashicorp/go-hclog"
	"github.com/stretchr/testify/assert"
)

func setupTeamHandler(_ *testing.T) (*Team, *httptest.ResponseRecorder) {
	c := &data.MockConnection{}

	testTeam := data.Team{
		ID:         1,
		Name:       "HashiFans",
		Time:       200.6,
		Activation: "ilm",
	}

	testTeam2 := data.Team{
		ID:         2,
		Name:       "FastRunners",
		Time:       100.5,
		Activation: "slm",
	}

	c.On("GetTeam").Return(data.Teams{testTeam}, nil)
	c.On("GetTeams").Return(data.Teams{testTeam2, testTeam}, nil)
	c.On("GetTeamsByActivation").Return(data.Teams{testTeam2}, nil)
	c.On("CreateTeam").Return(testTeam, nil)
	c.On("UpdateTeam").Return(testTeam, nil)
	c.On("DeleteTeam").Return(nil)

	l := hclog.Default()

	return &Team{c, l}, httptest.NewRecorder()
}

func setupFailedTeamHandler(_ *testing.T) (*Team, *httptest.ResponseRecorder) {
	c := &data.MockConnection{}

	c.On("GetTeams").Return(nil, errors.New("Unable to retrieve team"))
	c.On("GetTeams").Return(nil, errors.New("Unable to retrieve team"))
	c.On("GetTeamsByActivation").Return(nil, errors.New("Unable to retrieve team"))
	c.On("CreateTeam").Return(nil, errors.New("Unable to create team"))
	c.On("UpdateTeam").Return(nil, errors.New("Unable to update team"))
	c.On("DeleteTeam").Return(errors.New("Unable to delete team"))

	l := hclog.Default()

	return &Team{c, l}, httptest.NewRecorder()
}

// TestReturnsTeams - Tests success criteria
func TestReturnsTeams(t *testing.T) {
	c, rw := setupTeamHandler(t)

	r := httptest.NewRequest("GET", "/teams", nil)

	c.GetTeams(rw, r)

	assert.Equal(t, http.StatusOK, rw.Code)

	bd := data.Teams{}
	err := json.Unmarshal(rw.Body.Bytes(), &bd)

	assert.NoError(t, err)
	assert.Len(t, bd, 2)
	assert.Equal(t, "FastRunners", bd[0].Name)
}

// TestReturnsTeamsByActivation - Tests success criteria
func TestReturnsTeamsByActivation(t *testing.T) {
	c, rw := setupTeamHandler(t)

	r := httptest.NewRequest("GET", "/teams/activations/{name}", nil)

	// set activation to slm
	vars := map[string]string{"name": "slm"}
	r = mux.SetURLVars(r, vars)

	c.GetTeamsByActivation(rw, r)

	assert.Equal(t, http.StatusOK, rw.Code)

	bd := data.Teams{}
	err := json.Unmarshal(rw.Body.Bytes(), &bd)

	assert.NoError(t, err)
	assert.Len(t, bd, 1)
	assert.Equal(t, "FastRunners", bd[0].Name)
}

// TestUnableToReturnTeams - Tests failure criteria
func TestUnableToReturnTeams(t *testing.T) {
	c, rw := setupFailedTeamHandler(t)

	r := httptest.NewRequest("GET", "/teams", nil)

	c.GetTeams(rw, r)

	assert.Equal(t, http.StatusInternalServerError, rw.Code)

	bd := data.Teams{}
	err := json.Unmarshal(rw.Body.Bytes(), &bd)

	assert.Error(t, err)
	assert.Equal(t, "Unable to list teams\n", rw.Body.String())
}

// TestCreateTeam - Tests success criteria
func TestCreateTeam(t *testing.T) {
	c, rw := setupTeamHandler(t)

	r := httptest.NewRequest("POST", "/teams", nil)

	rb := strings.NewReader(`{"name":"NewTeam","time":201.12}`)
	r.Body = io.NopCloser(rb)

	c.CreateTeam(rw, r)

	assert.Equal(t, http.StatusOK, rw.Code)

	bd := data.Team{}
	err := json.Unmarshal(rw.Body.Bytes(), &bd)

	assert.NoError(t, err)
}

// TestUnableToCreateTeam - Tests failure criteria
func TestUnableToCreateTeam(t *testing.T) {
	c, rw := setupFailedTeamHandler(t)

	r := httptest.NewRequest("POST", "/teams", nil)

	rb := strings.NewReader(`{"name":"NewTeam","time":null}`)
	r.Body = io.NopCloser(rb)

	c.CreateTeam(rw, r)

	assert.Equal(t, http.StatusInternalServerError, rw.Code)

	bd := data.Team{}
	err := json.Unmarshal(rw.Body.Bytes(), &bd)

	assert.Error(t, err)
	assert.Equal(t, "Unable to create new team\n", rw.Body.String())
}

// TestReturnSpecificTeam - Tests success criteria
func TestReturnSpecificTeam(t *testing.T) {
	c, rw := setupTeamHandler(t)

	r := httptest.NewRequest("GET", "/teams/{id:[0-9]+}", nil)

	// set teamID to 1
	vars := map[string]string{"id": "1"}
	r = mux.SetURLVars(r, vars)

	c.GetTeam(rw, r)

	assert.Equal(t, http.StatusOK, rw.Code)

	bd := data.Team{}
	err := json.Unmarshal(rw.Body.Bytes(), &bd)

	assert.NoError(t, err)
}

// TestUnableToReturnSpecificTeam - Tests failure criteria
func TestUnableToReturnSpecificTeam(t *testing.T) {
	c, rw := setupFailedTeamHandler(t)

	r := httptest.NewRequest("GET", "/teams/{id:[0-9]+}", nil)

	// set orderID to 1
	vars := map[string]string{"id": "1"}
	r = mux.SetURLVars(r, vars)

	c.GetTeam(rw, r)

	assert.Equal(t, http.StatusInternalServerError, rw.Code)

	bd := data.Team{}
	err := json.Unmarshal(rw.Body.Bytes(), &bd)

	assert.Error(t, err)
	assert.Equal(t, "Unable to list team\n", rw.Body.String())
}

// TestDelete - Tests success criteria
func TestDelete(t *testing.T) {
	c, rw := setupTeamHandler(t)

	r := httptest.NewRequest("DELETE", "/teams/{id:[0-9]+}", nil)

	// set teamID to 1
	vars := map[string]string{"id": "1"}
	r = mux.SetURLVars(r, vars)

	c.DeleteTeam(rw, r)

	assert.Equal(t, http.StatusOK, rw.Code)
	assert.Equal(t, "Deleted team", rw.Body.String())
}

// TestUnableToDelete - Tests failure criteria
func TestUnableToDelete(t *testing.T) {
	c, rw := setupFailedTeamHandler(t)

	r := httptest.NewRequest("DELETE", "/teams/{id:[0-9]+}", nil)

	// set orderID to 1
	vars := map[string]string{"id": "1"}
	r = mux.SetURLVars(r, vars)

	c.DeleteTeam(rw, r)

	assert.Equal(t, http.StatusInternalServerError, rw.Code)
	assert.Equal(t, "Unable to delete team\n", rw.Body.String())
}
