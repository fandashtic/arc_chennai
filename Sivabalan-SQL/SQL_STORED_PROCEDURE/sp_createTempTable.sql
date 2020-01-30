
Create Procedure sp_createTempTable(@netaddr as nVarchar(100))
As
Begin
	Declare @Str nVarchar(1000), @spid int
	Create Table #Tmp1(TableID int)
	
	Set @Str = 'Insert into #Tmp1 Select Top 1 ID From tempdb..sysobjects Where name like ''##' + @netaddr + ''''
	
	Exec sp_executesql @Str
	
	If Not Exists(Select TableID From #Tmp1)
	Begin
		Set @Str='Create Table ##' + @netaddr + ' (TableID int identity,ParentTranID nvarchar(50),CustID nvarchar(15),DocID nvarchar(50),DocDate datetime,Netval decimal(18,6),
		OutStanding decimal(18,6),TranID int,TranType int,TranName nvarchar(50),Adjusted decimal(18,6),Balance decimal(18,6),DocRef nvarchar(255),PrevAdj decimal(18,6))'
	
		exec sp_executesql @Str
	End
	Else
	Begin
		Set @Str = 'Truncate Table ##' + @netaddr
		exec sp_executesql @Str
	End
	
	Drop Table #Tmp1
End
