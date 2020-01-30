
Create Procedure sp_getAdjustmentDocs
(
	@SmanID nvarchar(15) = N'',
	@BtID nvarchar(50) = N'',
	@CustID nvarchar(15),
	@ParentTranID nvarchar(50),
	@InvCollID int = 0,
	@netaddr as nVarchar(100) = N''
)
As
Begin
Declare @Str nVarchar(1000), @spid as nvarchar(10)

Create Table #Tmp1(TabID int)
Create Table #Tmp2(TabID int)

Create Table #PendList (DocumentID nvarchar(50),DocumentDate datetime,Netvalue decimal(18,6),Balance decimal(18,6),InvoiceID int,
InvoiceType int,TypeName nvarchar(50),AddlDisc decimal(18,6),DocReference nvarchar(255))

Insert into #PendList 
exec sp_list_Collections @CustID

Set @Str='Insert Into #Tmp1 Select TableID From ##' + @netaddr + ' Where CustID=''' + @CustID + ''''

Exec sp_executesql @Str

Set @Str='Insert Into #Tmp2 Select TableID From ##' + @netaddr + ' Where CustID='''+ @CustID + ''' And ParentTranID=''' + @ParentTranID +''''

Exec sp_executesql @Str

If Exists(Select * From #Tmp1)
Begin
	If Exists(Select * From #Tmp2)
	Begin
		Set @Str = 'Select ParentTranID,CustID,DocID,DocDate,Netval,''OutStanding''=(OutStanding - PrevAdj), TranID,TranType,'
		Set @Str = @Str + 'TranName,Adjusted,''Balance''=(Balance - PrevAdj),DocRef,PrevAdj From ##' + @netaddr
		Set @Str = @Str + ' Where CustID=''' + @CustID + ''' And ParentTranID=''' + @ParentTranID + ''''

		Exec sp_executesql @Str
	End
	Else
	Begin
		Set @Str = 'Insert into ##' + @netaddr
		Set @Str = @Str + ' Select ''' + @ParentTranID + ''',''' + @CustID +''',DocumentID,DocumentDate,NetValue,(Balance-(Select Isnull(Sum(Adjusted),0) From ##' + @netaddr 
		Set @Str = @Str + ' Where TranID=pl.InvoiceID And TranType=pl.InvoiceType And ParentTranID <> ''' + @ParentTranID + ''')),InvoiceID,InvoiceType,TypeName,0,(Balance-(Select IsNull(Sum(Adjusted),0) From ##' + @netaddr 
		Set @Str = @Str + ' Where TranID=pl.InvoiceID And TranType=pl.InvoiceType And ParentTranID <> ''' + @ParentTranID + ''')),DocReference,0 from #PendList pl where InvoiceType in (1,2,3)'
		
		Exec sp_executesql @Str

		Set @Str = 'Select * From ##' + @netaddr + ' Where CustID=''' + @CustID + ''' And ParentTranID=''' + @ParentTranID + ''''
		Exec sp_executesql @Str
	End
End
Else
Begin
	Set @Str = 'Insert into ##' + @netaddr
	Set @Str = @Str + ' Select ''' + @ParentTranID + ''',''' + @CustID + ''',DocumentID,DocumentDate,NetValue,Balance,InvoiceID,InvoiceType,TypeName,0,Balance,DocReference,0 from #PendList where InvoiceType in (1,2,3)'
	
	Exec sp_executesql @Str

	Set @Str = 'Select * From ##' + @netaddr + ' Where CustID=''' + @CustID + ''' And ParentTranID=''' + @ParentTranID + ''''

	Exec sp_executesql @Str
End

Drop Table #PendList
Drop Table #Tmp1
Drop Table #Tmp2
End
