CREATE TABLE [dbo].[Users] (
    [UserId]    INT            NOT NULL,
    [Email]     NVARCHAR (255) NOT NULL,
    [CreatedAt] DATETIME2 (7)  CONSTRAINT [DF_Users_CreatedAt] DEFAULT (sysdatetime()) NOT NULL,
    [MyColumn]  INT            NULL,
    [LatestColumn] NCHAR(10) NULL, 
    CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([UserId] ASC)
);

