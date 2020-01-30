CREATE PROCEDURE BeforeProcedureUpdate
AS
if exists (select * from dbo.sysobjects where id = object_id(N'[UpgradeTables]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [UpgradeTables]
CREATE TABLE [UpgradeTables] (
	[TableID] [int] IDENTITY (1, 1) NOT NULL ,
	[TableName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[UpgradeCriteria] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	CONSTRAINT [PK_UpgradeTables] PRIMARY KEY  CLUSTERED 
	(
		[TableID]
	)  ON [PRIMARY] ,
	CONSTRAINT [IX_UpgradeTables] UNIQUE  NONCLUSTERED 
	(
		[TableName]
	)  ON [PRIMARY] 
) ON [PRIMARY]
