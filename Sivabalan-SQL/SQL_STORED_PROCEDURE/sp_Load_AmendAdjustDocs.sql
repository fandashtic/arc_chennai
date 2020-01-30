
Create Procedure sp_Load_AmendAdjustDocs(@InvCollID int, @CustID nvarchar(15), @ParentTranID nvarchar(50), @netaddr as nVarchar(100))  
As  
Begin  
	Declare @Adj_DocID as nvarchar(50),@Adj_DocDate as datetime,@Adj_Netval as decimal(18,6),@Adj_TranID as int  
	Declare @Adj_TranType as int,@Adj_TranName as nvarchar(50),@Adj_Adjusted as decimal(18,6),@Adj_Bal as decimal(18,6)  
	Declare @Adj_DocRef as nvarchar(255),@TableID as int  
	Declare @CollID as int, @AdjustedAmount as decimal(18,6), @DocID nvarchar(50)
	Declare @Str as nVarchar(1000)
	
	Create Table #Tmp1 (TableID int)
	Create Table #Tmp2 (AdjVal decimal(18,6))
	
	Create Table #PendList (DocumentID nvarchar(50),DocumentDate datetime,Netvalue decimal(18,6),Balance decimal(18,6),InvoiceID int,  
	InvoiceType int,TypeName nvarchar(50),AddlDisc decimal(18,6),DocReference nvarchar(255))  
	  
	Create Table #AmendedPendList (DocumentID nvarchar(50),DocumentDate datetime,Netvalue decimal(18,6),Balance decimal(18,6),  
	InvoiceType int,ExtraCollection decimal(18,6),DocReference nvarchar(255),Adjustment decimal(18,6),InvoiceID int,
	TypeName nvarchar(50),AdjAmount decimal(18,6),AddlDisc decimal(18,6),Discount decimal(18,6),DisableEdit int,ChequeonHand decimal(18,6),Flag int)  

	Select Distinct @CollID=CollectionID From CollectionDetail 
	Where CollectionID=(Select iwcd.DocumentID From CollectionDetail cd, InvoicewiseCollectionDetail iwcd 
	Where iwcd.CollectionID=@InvCollID And iwcd.DocumentID=cd.CollectionID And cd.OriginalID=@ParentTranID)
	
	Insert into #AmendedPendList
	exec sp_get_AmendedCollection @CollID
	
	Insert into #PendList
	Select DocumentID,DocumentDate,NetValue,Balance,InvoiceID,InvoiceType,TypeName,AddlDisc,DocReference From #AmendedPendList 
	Where InvoiceType in (1,2,3)
	
	Insert into #PendList   
	exec sp_list_Amendcollections @CustID, @CollID 
	
	Set @Str = 'Insert Into #Tmp1 Select TableID From ##' + @netaddr + ' Where CustID = ''' + @CustID + ''' And ParentTranID = ''' + @ParentTranID + ''''

	Exec sp_executesql @Str
	If Not Exists(Select * From #Tmp1)  
	Begin  
 		Set @Str = 'Insert into ##' + @netaddr
 		Set @Str = @Str + ' Select ''' + @ParentTranID + ''',''' + @CustID + ''',DocumentID,DocumentDate,NetValue,Balance,InvoiceID,InvoiceType,TypeName,0,Balance,DocReference,0 from #PendList where InvoiceType in (1,2,3)  '
		Exec sp_executesql @Str
	End  
	  
	Declare COL_CURSOR CURSOR STATIC FOR    
	Select OriginalID,DocumentDate,DocumentValue,DocumentID,DocumentType,(case DocumentType when 1 then N'Sales Return'   
	when 2 then N'Credit Note' when 3 then N'Advance Collection' end),AdjustedAmount,0,DocRef From CollectionDetail   
	Where CollectionID=@CollID And DocumentType in (1,2,3)  
	  
	Open COL_CURSOR    
	Fetch From COL_CURSOR INTO @Adj_DocID,@Adj_DocDate,@Adj_Netval,@Adj_TranID,@Adj_TranType,@Adj_TranName,@Adj_Adjusted,@Adj_Bal,@Adj_DocRef  
	While @@FETCH_STATUS = 0    
	Begin    
		Truncate Table #Tmp1

		Set @Str = 'Insert Into #Tmp1 Select TableID From ##' + @netaddr + ' Where CustID = ''' + @CustID + ''' And ParentTranID = ''' + @ParentTranID + ''''

		Exec sp_executesql @Str
		
		If Exists(Select * From #Tmp1)  
		Begin  
			Set @Str='Update ##' + @netaddr + ' Set OutStanding=Netval, Adjusted = ' + cast(@Adj_Adjusted as nVarchar) + ','
			Set @Str = @Str + 'Balance=(Netval - ' + cast(@Adj_Adjusted as nVarchar) + ') Where CustID = ''' + @CustID + ''' And ParentTranID = ''' + @ParentTranID + ''' And TranID = ' + cast(@Adj_TranID as nVarchar) + ' And TranType = ' +  cast(@Adj_TranType as nVarchar)
			Exec sp_executesql @Str
		End  
		Else  
		Begin  
			Set @Str = 'Insert into ##' + @netaddr + ' Values (''' + @ParentTranID + ''',''' + @CustID + ''',''' + @Adj_DocID + ''',''' + cast(@Adj_DocDate as nVarchar) + ''',' + cast(@Adj_Netval as nVarchar) + ',' + cast(@Adj_Adjusted as nVarchar) + ',  '
			Set @Str = @Str + cast(@Adj_TranID as nVarchar) + ',' + cast(@Adj_TranType as nVarchar) + ',''' + @Adj_TranName+ ''',' + cast(@Adj_Adjusted as nVarchar) + ',' + cast(@Adj_Bal as nVarchar) + ',''' + @Adj_DocRef + ''',0)  '
			Exec sp_executesql @Str
		End  
		Set @Str = 'Select TableID From ##' + @netaddr + ' Where ParentTranID = ''' + @ParentTranID + ''' And CustID = ''' + @CustID + ''' And TranID = ' + cast(@Adj_TranID as nVarchar) + ' And TranType = ' + cast(@Adj_TranType as nVarchar)
		Truncate Table #Tmp1
		Insert Into #Tmp1 Exec sp_executesql @Str
		Select @TableID=TableID From #Tmp1

		Set @Str = 'Update ##' + @netaddr + ' Set PrevAdj=(PrevAdj + ' + cast(@Adj_Adjusted as nVarchar) + ') Where TableID < ' + cast(@TableID as nVarchar) + ' And TranID = ' + cast(@Adj_TranID as nVarchar) + ' And TranType = ' + cast(@Adj_TranType as nVarchar)
		Exec sp_executesql @Str

		Set @Str = 'Select IsNull(Sum(Adjusted),0) From ##' + @netaddr + ' Where TableID < ' + cast(@TableID as nVarchar) + ' And TranID = ' + cast(@Adj_TranID as nVarchar) + ' And TranType=' + cast(@Adj_TranType as nVarchar)  
		Truncate Table #Tmp2
		Insert Into #Tmp2 Exec sp_executesql @Str
		Select @Adj_Adjusted=AdjVal From #Tmp2

		Set @Str = 'Update ##' + @netaddr + ' Set OutStanding=(OutStanding-' + cast(@Adj_Adjusted as nVarchar) + '), Balance=(OutStanding-(' + cast(@Adj_Adjusted as nVarchar) + '+Adjusted)) Where TableID = ' + cast(@TableID as nVarchar) + ' And TranID = ' + cast(@Adj_TranID as nVarchar) + ' And TranType= ' + cast(@Adj_TranType as nVarchar)  
		Exec sp_executesql @Str
		FETCH NEXT FROM COL_CURSOR INTO @Adj_DocID,@Adj_DocDate,@Adj_Netval,@Adj_TranID,@Adj_TranType,@Adj_TranName,@Adj_Adjusted,@Adj_Bal,@Adj_DocRef  
	End  
	Close COL_CURSOR  
	Deallocate COL_CURSOR  
	Set @Adj_Adjusted=0  

	Set @Str = 'Select IsNull(Sum(Adjusted),0) From ##' + @netaddr + ' Where CustID = ''' + @CustID + ''' And ParentTranID = ''' + @ParentTranID + ''''
	Truncate Table #Tmp2
	Insert Into #Tmp2 
	Exec sp_executesql @Str

	Select IsNull(AdjVal,0) From #Tmp2

	Drop Table #PendList 
	Drop Table #AmendedPendList 
	Drop Table #Tmp1
	Drop Table #Tmp2
End  
