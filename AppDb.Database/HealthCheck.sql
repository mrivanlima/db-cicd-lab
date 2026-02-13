CREATE TABLE [dbo].[HealthCheck]
(
    [HealthCheckId] INT IDENTITY(1,1) NOT NULL,
    [CreatedOn]      DATETIME2(0) NOT NULL
        CONSTRAINT [DF_HealthCheck_CreatedOn] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_HealthCheck] PRIMARY KEY CLUSTERED ([HealthCheckId] ASC)
);
