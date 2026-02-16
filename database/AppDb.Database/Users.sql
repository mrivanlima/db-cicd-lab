CREATE TABLE [dbo].[Users]
(
    [UserId] INT NOT NULL,
    [Email] NVARCHAR(255) NOT NULL,
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT (SYSDATETIME()),
    [MyColumn] int,
    CONSTRAINT PK_Users PRIMARY KEY CLUSTERED ([UserId])
);
