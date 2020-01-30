CREATE Procedure Sp_Get_SubDetailParam(@ID int,@TFromdate datetime)
As
set dateformat mdy
Declare @SubDetParamid int
Declare @IsDetail int
Declare @tempname nvarchar(100)
Declare @tempvbval int

Create Table #tempSql (SqlVal nvarchar(100),VbVal int)
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

print @Tfromdate

IF exists(Select Actiondata,Parameters,Action From ReportData Where ID=@ID)
	Begin	
		Select @SubDetParamid=Parameters,
		@IsDetail=Case Action When 2 then 1 Else 0 End
		From ReportData Where ID=@ID

		IF (@SubDetParamID=0)
		Begin
		     IF (@IsDetail=1) -- By default something has to be passes						
		     Begin
			Select @tempname=systypes.name from Sysobjects,Syscolumns,Systypes,Reportdata
			Where Sysobjects.name=Reportdata.Actiondata
			and Syscolumns.id=Sysobjects.id
			and Systypes.xusertype=Syscolumns.xusertype
			and Reportdata.id=@ID
			
			Select @tempvbval=vbval from #tempsql Where Sqlval=@tempname

			if (@tempvbval=7)
			sELECT @tfROMDATE,7 from #tempsql Where Sqlval=@tempname
			Else				
			sELECT 0,vbval from #tempsql Where Sqlval=@tempname				
					
 		     End
		End
		Else
		Begin			
			Exec spr_Fetch_TopProcParam  @ID ,@TFromdate,@TFromdate
		End
	End

drop table #tempSql








