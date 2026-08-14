IF DB_ID(N'FilmContestDB') IS NULL
BEGIN
    CREATE DATABASE FilmContestDB;
END;
GO

USE FilmContestDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'iam')
    EXEC('CREATE SCHEMA iam');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'participant')
    EXEC('CREATE SCHEMA participant');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'reference')
    EXEC('CREATE SCHEMA reference');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'contest')
    EXEC('CREATE SCHEMA contest');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'film')
    EXEC('CREATE SCHEMA film');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'submission')
    EXEC('CREATE SCHEMA submission');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'verification')
    EXEC('CREATE SCHEMA verification');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'judging')
    EXEC('CREATE SCHEMA judging');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'result')
    EXEC('CREATE SCHEMA result');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'archive')
    EXEC('CREATE SCHEMA archive');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'audit')
    EXEC('CREATE SCHEMA audit');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'reporting')
    EXEC('CREATE SCHEMA reporting');
GO
