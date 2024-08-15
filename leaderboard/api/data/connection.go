package data

import (
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

type Connection interface {
	IsConnected() (bool, error)
	GetTeams(teamid *int) (Teams, error)
	GetTeamsByActivation(activation string) (Teams, error)
	CreateTeam(*Team) (Team, error)
	DeleteTeam(teamID int) error
}

type PostgresSQL struct {
	db *sqlx.DB
}

// New creates a new connection to the database
func New(connection string) (Connection, error) {
	db, err := sqlx.Connect("postgres", connection)
	if err != nil {
		return nil, err
	}

	return &PostgresSQL{db}, nil
}

// IsConnected checks the connection to the database and returns an error if not connected
func (c *PostgresSQL) IsConnected() (bool, error) {
	err := c.db.Ping()
	if err != nil {
		return false, err
	}

	return true, nil
}

// GetTeams returns all teams from the database
func (c *PostgresSQL) GetTeams(teamid *int) (Teams, error) {
	teams := Teams{}

	if teamid != nil {
		err := c.db.Select(&teams, "SELECT * FROM teams WHERE id = $1", &teamid)
		if err != nil {
			return nil, err
		}
	} else {
		err := c.db.Select(&teams, "SELECT * FROM teams WHERE deleted_at IS NULL ORDER BY time;")
		if err != nil {
			return nil, err
		}
	}

	return teams, nil
}

// GetTeamsByActivation returns all teams from the database by activation
func (c *PostgresSQL) GetTeamsByActivation(activation string) (Teams, error) {
	teams := Teams{}

	err := c.db.Select(&teams, "SELECT * FROM teams WHERE activation = $1 AND deleted_at IS NULL ORDER BY time;", activation)
	if err != nil {
		return nil, err
	}

	return teams, nil
}

// CreateTeam creates a new team
func (c *PostgresSQL) CreateTeam(team *Team) (Team, error) {
	t := Team{}

	rows, err := c.db.NamedQuery(
		`INSERT INTO teams (name, time, activation, created_at)
		VALUES(:name, :time, :activation, now())
		RETURNING id, name, activation, time;`, map[string]interface{}{
			"name":       team.Name,
			"activation": team.Activation,
			"time":       team.Time,
		})

	if err != nil {
		return t, err
	}
	defer rows.Close()

	if rows.Next() {
		err := rows.StructScan(&t)
		if err != nil {
			return t, err
		}
	}

	return t, nil
}

// DeleteTeam deletes an existing team in the database
func (c *PostgresSQL) DeleteTeam(teamID int) error {
	tx := c.db.MustBegin()

	_, err := tx.NamedExec(
		`UPDATE teams SET deleted_at = now()
		WHERE id = :id AND deleted_at IS NULL`, map[string]interface{}{
			"id": teamID,
		})
	if err != nil {
		tx.Rollback()
		return err
	}

	err = tx.Commit()
	if err != nil {
		return err
	}

	return nil
}
