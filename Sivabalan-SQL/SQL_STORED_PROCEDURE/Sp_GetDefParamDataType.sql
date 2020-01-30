CREATE Procedure Sp_GetDefParamDataType(@repid int)
As
Create Table #tempSql (SqlVal nvarchar(100),VbVal int)
Declare @SqlRetVal nvarchar(100)

Insert into #tempSql Values ('bigint',20)
Insert into #tempSql Values('binary',128)
Insert into #tempSql Values('char',200)
Insert into #tempSql Values ('datetime',7)
Insert into #tempSql Values ('decimal',14)
Insert into #tempSql Values ('float',14)
Insert into #tempSql Values ('int',3)
Insert into #tempSql Values ('money',6)
Insert into #tempSql Values ('nchar',200)
Insert into #tempSql Values ('ntext',200)
Insert into #tempSql Values ('numeric',3)
Insert into #tempSql Values ('nvarchar',200)
Insert into #tempSql Values ('real',14)
Insert into #tempSql Values ('smalldatetime',7)
Insert into #tempSql Values ('smallint',3)
Insert into #tempSql Values ('smallmoney',6)
Insert into #tempSql Values ('text',200)
Insert into #tempSql Values ('tinyint',3)
Insert into #tempSql Values ('varbinary',128)
Insert into #tempSql Values ('nvarchar',200)


Select @SqlRetVal=Systypes.name from Sysobjects,Syscolumns,Systypes,Reportdata
Where Sysobjects.name=Reportdata.Actiondata
and Syscolumns.id=Sysobjects.id
and Syscolumns.Colorder=1
and Systypes.xusertype=Syscolumns.xusertype
and Reportdata.id=@repid

Select VbVal From #tempsql
 where #tempSql.sqlval=@SqlRetVal

drop table #tempSql













