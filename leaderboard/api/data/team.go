package data

import (
	"database/sql"
	"encoding/json"
	"io"
)

// Teams is a list of Team
type Teams []Team

// FromJSON serializes data from json
func (t *Teams) FromJSON(data io.Reader) error {
	de := json.NewDecoder(data)
	return de.Decode(t)
}

// ToJSON converts the collection to json
func (t *Teams) ToJSON() ([]byte, error) {
	return json.Marshal(t)
}

type Team struct {
	ID         int            `db:"id" json:"id"`
	Name       string         `db:"name" json:"name"`
	Activation string         `db:"activation" json:"activation"`
	Time       float64        `db:"time" json:"time"`
	CreatedAt  string         `db:"created_at" json:"-"`
	DeletedAt  sql.NullString `db:"deleted_at" json:"-"`
}

// FromJSON serializes data from json
func (t *Team) FromJson(data io.Reader) error {
	de := json.NewDecoder(data)
	return de.Decode(t)
}

// ToJSON converts the collection to json
func (t *Team) ToJSON() ([]byte, error) {
	return json.Marshal(t)
}
