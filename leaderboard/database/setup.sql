set time zone 'UTC';
create extension pgcrypto;

CREATE TABLE teams (
    id serial PRIMARY KEY,
    name VARCHAR (255) NOT NULL UNIQUE,
    time DECIMAL NOT NULL,
    created_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);