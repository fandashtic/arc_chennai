Create Procedure sp_CheckForAmendedOrCancelledCollection(@CollectionID AS Integer,@FormMode as Integer)
As
Begin
	Declare @Flag as integer,@msg as nvarchar(1000)  
		if Exists(Select * From InvoiceWiseCollectionAbstract Where  CollectionID = @CollectionID and (isNull(Status,0) & 128 =128 or isNull(Status,0) & 64 = 64))
		Begin
			--Check for the cancelled or amended collection
			Set  @Flag = 1 
			Set @msg   = N'Collection Already Cancelled/Amended'
		End
		else
		Begin
			--if the collection is in open state then check whether the implicit collection made has been cancelled
			--or amended.
			Declare @ColID as integer, @tmp as integer 
			Create Table #Temp (tmp integer)  
  
			Declare CUR_COLLID CURSOR STATIC FOR  
			Select DocumentID From Collections Where DocumentID in (Select DocumentID From InvoiceWiseCollectionDetail   
			Where CollectionID = ''+@CollectionID+'') And (Status & 128 <> 0 or Isnull(Status,0) & 64 <> 0 Or   
			(IsNull(Deposit_To, 0) <> 0 And IsNULL(Status,0) & 1 <> 0))  
		  
			Set @Flag=0  
			Set @msg=N''  
			Open CUR_COLLID  
			Fetch From CUR_COLLID INTO @ColID  
			While @@FETCH_STATUS = 0    
			Begin   
			 If @Flag=0 And IsNull(@ColID,0)=0  
			 Begin  
			  Delete From #Temp  
			  Insert into #Temp  
			  Exec sp_Can_CancelCollection @ColID   -- To check whether any advance amt in collections been adjusted  
			  Select @tmp=tmp From #Temp  
			  If @tmp=1  
			  Begin  
			   Delete From #Temp  
			   Insert into #Temp  
			   Exec sp_CheckCollectionExist @ColID  -- To check whether implicit collection been created for any invoice  
			   Select @tmp=tmp From #Temp  
			   If @tmp=1  
			   Begin  
			    Set @Flag=1  
			    Set @msg=N'Collection been adjusted against invoice'  
			   End  
			  End  
			  Else  
			  Begin  
			   Set @Flag=1  
			   Set @msg=N'Already been adjusted in collection transaction'  
			  End  
			 End  
			 Else  
			 Begin  
			  Set @Flag=1  
			  Set @msg=N'Either cheques/DD been deposited (or) documents been amended/cancelled in collections'  
			 End  
			 FETCH NEXT FROM CUR_COLLID INTO  @ColID  
			End  
			Close CUR_COLLID  
			Deallocate CUR_COLLID  
			Drop Table #Temp  
		End
Select @Flag,@msg  
End  
