package data

import (
	"bytes"
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestTeamsDeserializeFromJSON(t *testing.T) {
	teams := Teams{}

	err := teams.FromJSON(bytes.NewReader([]byte(teamsData)))
	assert.NoError(t, err)

	assert.Len(t, teams, 2)
	assert.Equal(t, 1, teams[0].ID)
	assert.Equal(t, 2, teams[1].ID)
}

func TestTeamsSerializesToJSON(t *testing.T) {
	c := Teams{
		Team{ID: 1, Name: "test", Time: 120.12, Activation: "ilm"},
	}

	d, err := c.ToJSON()
	assert.NoError(t, err)

	cd := make([]map[string]interface{}, 0)
	err = json.Unmarshal(d, &cd)
	assert.NoError(t, err)

	assert.Equal(t, float64(1), cd[0]["id"])
	assert.Equal(t, "test", cd[0]["name"])
	assert.Equal(t, float64(120.12), cd[0]["time"])
	assert.Equal(t, "ilm", cd[0]["activation"])
}

var teamsData = `
[
	{
		"id": 1,
		"name": "HashiFans",
		"time": 300.0,
		"activation": "ilm"
	},
	{
		"id": 2,
		"name": "Americano",
		"price": 206.78,
		"activation": "slm"
	}
]
`
