-- Create database and schemas
CREATE DATABASE PizzaBI;
GO
USE PizzaBI;
GO

CREATE SCHEMA raw;
CREATE SCHEMA stg;   -- staging
CREATE SCHEMA dim;   -- dimensions
CREATE SCHEMA fact;  -- facts
CREATE SCHEMA mart;  -- aggregated views for Tableau
GO

