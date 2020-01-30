CREATE Procedure sp_acc_rpt_ARV(@FromDate DateTime, @ToDate DateTime, @AccountID INT = 0,@Active INT = 0)  
As  
DECLARE @ARV INT  
DECLARE @ARVCOLORINFO INT  
DECLARE @GroupID INT  
DECLARE @TempAccountID INT  
DECLARE @AccountName nVarChar(255)  
DECLARE @LOCARV nVarChar(255)
  
Set @ARV = 48  
Set @ARVCOLORINFO = 68  
Set @ToDate = dbo.StripDateFromTime(@ToDate)  
Set @ToDate = DateAdd(s, 0-1, DateAdd(dd, 1, @ToDate))                  
Set @LOCARV = dbo.LookupDictionaryItem('ARV',Default)

CREATE Table #TempGroup(GroupID INT)  
CREATE Table #TempAll(PartyID int,ARVID nVarchar(255), ARVDate DateTime, DocRef nVarChar(255),Amount Decimal(18,6), TaxAmount Decimal(18,6), NetAmount Decimal(18,6), DocID INT, DocType INT, Info nText, ApprovedBy nVarChar(255), Status nVarChar(255), Remarks nVarChar(4000),
 HighLight INT)  
  
If @AccountID = 0  
 Begin  
  Insert Into #TempGroup            
  Select GroupID from AccountGroup            
  Where ParentGroup In (12,13,18,7,19,20,21,24,25,26,27,28,29,31,33,9,10,50,51,52) --And IsNULL(Active,0)= 1            
  
  Declare ParentGrp Cursor Dynamic For            
  Select GroupID From #TempGroup  
  Open ParentGrp            
   Fetch From ParentGrp Into @GroupID  
   While @@Fetch_Status = 0            
   Begin            
    Insert into #TempGroup           
    Select GroupID From AccountGroup            
    Where ParentGroup = @GroupID --And IsNULL(Active,0)= 1    
               
    Fetch Next From ParentGrp Into @GroupID  
   End            
  Close ParentGrp            
  DeAllocate ParentGrp            
  
  Insert into #tempgroup            
  Select GroupID from AccountGroup            
  Where GroupID In (12,13,18,7,19,20,21,24,25,26,27,28,29,31,33,17,8,9,10,50,51,52)  
  
  Declare ARVALLAccounts Cursor Dynamic For  
  Select AccountID from AccountsMaster Where GroupID Not In (Select GroupID from #TempGroup) And AccountID Not In (20,21,500) Order By AccountName
  Open ARVALLAccounts  
   Fetch From ARVALLAccounts Into @TempAccountID  
   While @@Fetch_Status = 0  
   Begin  
		If @Active = 0
		Begin
	     	If Exists (Select * from ARVAbstract Where PartyAccountID = @TempAccountID And ARVDate Between @FromDate And @ToDate)  
	      	Begin  
	       		Select @AccountName = AccountName from AccountsMaster Where AccountID = @TempAccountID  
	       		If Patindex(N'% '+(dbo.LookupDictionaryItem('Account',Default)),@Accountname) = 0      
	        	Begin      
	         		Insert Into #TempAll(DocRef,HighLight)  
	         		Values(LTrim(RTrim(@AccountName)) + N' ' + dbo.LookupDictionaryItem('Account',Default), 1)      
	        	End      
	       		Else      
	        	Begin      
	         		Insert Into #TempAll(DocRef,HighLight)  
	         		Values(@AccountName, 1)      
	        	End      
	       		Insert Into #TempAll  
	       		Select @TempAccountID,dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID As nVarChar),  
	       		dbo.StripDateFromTime(ARVDate), DocRef, Amount - IsNULL(TotalSalesTax,0), IsNULL(TotalSalesTax,0),  
	       		Amount, DocumentID, @ARV, @LOCARV, dbo.getAccountName(ApprovedBy),  
	       		'Status' = Case When (IsNULL(Status,0) & 64) = 64 then dbo.LookupDictionaryItem('Closed',Default) When (IsNULL(Status,0) & 128) = 128 then dbo.LookupDictionaryItem('Amended',Default) When IsNULL(RefDocID,0) <> 0 then dbo.LookupDictionaryItem('Amendment',Default) Else '' END,  
	       		ARVRemarks, @ARVCOLORINFO from ARVAbstract Where PartyAccountID = @TempAccountID And ARVDate Between @FromDate And @ToDate Order By ARVDate

				Insert into #TempAll (DocRef,Amount,HighLight)
				Select 'Sub Total',ISNULL(sum(isnull(Amount,0)),0),1 from #TempAll 
				Where PartyID = @TempAccountID and Status not in (dbo.LookupDictionaryItem('Closed',Default),dbo.LookupDictionaryItem('Amended',Default))
	       
				Insert Into #TempAll(HighLight)  
	       		Values(5)  
			End
		End
		Else
		Begin
	     	If Exists (Select * from ARVAbstract Where PartyAccountID = @TempAccountID And isnull(status,0) = 0 and (ARVDate Between @FromDate And @ToDate) ) 
	      	Begin  
	       		Select @AccountName = AccountName from AccountsMaster Where AccountID = @TempAccountID  
	       		If Patindex(N'% '+(dbo.LookupDictionaryItem('Account',Default)),@Accountname) = 0      
	  			Begin      
	         		Insert Into #TempAll(DocRef,HighLight)  
	         		Values(LTrim(RTrim(@AccountName)) + N' ' + dbo.LookupDictionaryItem('Account',Default), 1)      
	        	End      
	       		Else      
	        	Begin      
	         		Insert Into #TempAll(DocRef,HighLight)  
	         		Values(@AccountName, 1)      
	        	End      
	       		Insert Into #TempAll  
	       		Select @TempAccountID,dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID As nVarChar),  
	       		dbo.StripDateFromTime(ARVDate), DocRef, Amount - IsNULL(TotalSalesTax,0), IsNULL(TotalSalesTax,0),  
	       		Amount, DocumentID, @ARV, @LOCARV, dbo.getAccountName(ApprovedBy),  
	       		'Status' = Case When IsNULL(RefDocID,0) <> 0 then dbo.LookupDictionaryItem('Amendment',Default) Else '' END,  
	       		ARVRemarks, @ARVCOLORINFO from ARVAbstract Where PartyAccountID = @TempAccountID And Isnull(status,0) = 0 and
				(ARVDate Between @FromDate And @ToDate) Order By ARVDate

				Insert into #TempAll (DocRef,Amount,HighLight)
				Select 'Sub Total',ISNULL(sum(isnull(Amount,0)),0),1 from #TempAll 
				Where PartyID = @TempAccountID and Status not in (dbo.LookupDictionaryItem('Closed',Default),dbo.LookupDictionaryItem('Amended',Default))
	       
				Insert Into #TempAll(HighLight)  
	       		Values(5)  
			End
		End	     
	Fetch Next From ARVALLAccounts Into @TempAccountID  
  End  
  Close ARVALLAccounts            
  DeAllocate ARVALLAccounts        
 End  
Else  
 Begin  
	If @Active = 0
	Begin
	 	If Exists (Select * from ARVAbstract Where PartyAccountID = @AccountID And ARVDate Between @FromDate And @ToDate)
	  	Begin  
		  Insert Into #TempAll  
		  Select PartyAccountID,dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID As nVarChar),  
		  dbo.StripDateFromTime(ARVDate), DocRef, Amount - IsNULL(TotalSalesTax,0), IsNULL(TotalSalesTax,0),   
		  Amount, DocumentID, @ARV, @LOCARV, dbo.getAccountName(ApprovedBy),  
		  'Status' = Case When (IsNULL(Status,0) & 64) = 64 then dbo.LookupDictionaryItem('Closed',Default) When (IsNULL(Status,0) & 128) = 128 then dbo.LookupDictionaryItem('Amended',Default) When IsNULL(RefDocID,0) <> 0 then dbo.LookupDictionaryItem('Amendment',Default) Else '' END,  
		  ARVRemarks, @ARVCOLORINFO from ARVAbstract Where PartyAccountID = @AccountID And ARVDate Between @FromDate And @ToDate Order By ARVDate
	
		  Insert Into #TempAll(HighLight)  
		  Values(5)  
		End
	End
	Else
	Begin
	 	If Exists (Select * from ARVAbstract Where PartyAccountID = @AccountID And isnull(status,0) = 0 and (ARVDate Between @FromDate And @ToDate) ) 
	  	Begin  
		  Insert Into #TempAll  
		  Select PartyAccountID,dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID As nVarChar),  
		  dbo.StripDateFromTime(ARVDate), DocRef, Amount - IsNULL(TotalSalesTax,0), IsNULL(TotalSalesTax,0),   
		  Amount, DocumentID, @ARV, @LOCARV, dbo.getAccountName(ApprovedBy),  
		  'Status' = Case When IsNULL(RefDocID,0) <> 0 then dbo.LookupDictionaryItem('Amendment',Default) Else '' END,  
		  ARVRemarks, @ARVCOLORINFO from ARVAbstract Where PartyAccountID = @AccountID And isnull(status,0) = 0 and
		  (ARVDate Between @FromDate And @ToDate) Order By ARVDate
	
		  Insert Into #TempAll(HighLight)  
		  Values(5)  
		End
	End
 End  

/* Insert Net Total */
if (Select count(1) from #TempAll) > 0 
Begin
	Insert into #TempAll (DocRef,Amount,HighLight)
	Select 'Net Total',ISNULL(sum(isnull(Amount,0)),0),1 from #TempAll 
	Where Status not in (dbo.LookupDictionaryItem('Closed',Default),dbo.LookupDictionaryItem('Amended',Default)) and isnull(PartyID,0) <> 0
End
  
Select 'ARV ID' = ARVID, 'ARV Date' = ARVDate, 'Document Reference' = DocRef, 'Gross Amount' = Amount,  
'Tax Amount' = TaxAmount, 'Net Amount' = NetAmount, 'DocID' = DocID, 'DocType' = DocType,   
'Info' = Info, 'Approved By' = IsNULL(ApprovedBy,N''), 'Status' = IsNULL(Status,N''),   
'Remarks' = IsNULL(Remarks,N''), 'HighLight' = HighLight from #TempAll  
  
Drop Table #TempAll  
Drop Table #TempGroup  
