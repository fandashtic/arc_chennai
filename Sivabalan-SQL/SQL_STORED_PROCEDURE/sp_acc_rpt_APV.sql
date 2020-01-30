CREATE Procedure sp_acc_rpt_APV(@FromDate DateTime, @ToDate DateTime, @AccountID INT = 0,@Active INT = 0)  
As  
DECLARE @APV INT  
DECLARE @APVCOLORINFO INT  
DECLARE @GroupID INT  
DECLARE @TempAccountID INT  
DECLARE @AccountName nVarChar(255)  
DECLARE @LOCAPV nVarChar(255)
  
Set @APV = 46  
Set @APVCOLORINFO = 28  
Set @ToDate = dbo.StripDateFromTime(@ToDate)  
Set @ToDate = DateAdd(s, 0-1, DateAdd(dd, 1, @ToDate))                  
Set @LOCAPV = dbo.LookupDictionaryItem('APV',Default)

CREATE Table #TempGroup(GroupID INT)  
CREATE Table #TempAll(PartyID int,APVID nVarchar(255), APVDate DateTime, DocRef nVarChar(255),Amount Decimal(18,6), Discount Decimal(18,6), ExpenseFor nVarChar(255), DocID INT, DocType INT, Info nText, ApprovedBy nVarChar(255), Status nVarChar(255), Remarks nVarChar(4000), HighLight INT)  
  
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
  
  Declare APVALLAccounts Cursor Dynamic For  
  Select AccountID from AccountsMaster Where GroupID Not In (Select GroupID from #TempGroup) And AccountID Not In (20,21,500) Order By AccountName
  Open APVALLAccounts  
   Fetch From APVALLAccounts Into @TempAccountID  
   While @@Fetch_Status = 0  
    Begin  
	If @Active = 0
	Begin
	     If Exists (Select * from APVAbstract Where PartyAccountID = @TempAccountID And APVDate Between @FromDate And @ToDate)  
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
	       Select @TempAccountID, dbo.getvoucherprefix('ACCOUNTS PAYABLE VOUCHER') + Cast(APVID As nVarChar),  
	       dbo.StripDateFromTime(APVDate), DocumentReference, AmountApproved, OtherValue,  
	       dbo.getAccountName(ExpenseFor), DocumentID, @APV, @LOCAPV, dbo.getAccountName(ApprovedBy),  
	       'Status' = Case When (IsNULL(Status,0) & 64) = 64 then dbo.LookupDictionaryItem('Closed',Default) When (IsNULL(Status,0) & 128) = 128 then dbo.LookupDictionaryItem('Amended',Default) When IsNULL(RefDocID,0) <> 0 then dbo.LookupDictionaryItem('Amendment',Default) Else '' END,  
	       APVRemarks, @APVCOLORINFO from APVAbstract Where PartyAccountID = @TempAccountID And APVDate Between @FromDate And @ToDate Order By APVDate

		   Insert into #TempAll (DocRef,Amount,HighLight)
		   Select 'Sub Total',ISNULL(sum(isnull(Amount,0)),0),1 from #TempAll 
		   Where PartyID = @TempAccountID and Status not in (dbo.LookupDictionaryItem('Closed',Default),dbo.LookupDictionaryItem('Amended',Default))
	
	       Insert Into #TempAll(HighLight)  
	       Values(5)  
	      End
	End
    Else
	Begin
	     If Exists (Select * from APVAbstract Where PartyAccountID = @TempAccountID And isnull(status,0)=0 and (APVDate Between @FromDate And @ToDate))  
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
	       Select @TempAccountID, dbo.getvoucherprefix('ACCOUNTS PAYABLE VOUCHER') + Cast(APVID As nVarChar),  
	       dbo.StripDateFromTime(APVDate), DocumentReference, AmountApproved, OtherValue,  
	       dbo.getAccountName(ExpenseFor), DocumentID, @APV, @LOCAPV, dbo.getAccountName(ApprovedBy),  
	       'Status' = Case When IsNULL(RefDocID,0) <> 0 then dbo.LookupDictionaryItem('Amendment',Default) Else '' END,  
	       APVRemarks, @APVCOLORINFO from APVAbstract Where PartyAccountID = @TempAccountID 
		   And isnull(status,0) = 0  and (APVDate Between @FromDate And @ToDate ) Order By APVDate

		   Insert into #TempAll (DocRef,Amount,HighLight)
		   Select 'Sub Total',ISNULL(sum(isnull(Amount,0)),0),1 from #TempAll 
		   Where PartyID = @TempAccountID and Status not in (dbo.LookupDictionaryItem('Closed',Default),dbo.LookupDictionaryItem('Amended',Default))
	
	       Insert Into #TempAll(HighLight)  
	       Values(5)  
	      End 
	End
     Fetch Next From APVALLAccounts Into @TempAccountID  
    End  
  Close APVALLAccounts            
  DeAllocate APVALLAccounts        
 End  
Else  
 Begin  
	If @Active = 0 
	Begin
	  	If Exists (Select * from APVAbstract Where PartyAccountID = @AccountID And APVDate Between @FromDate And @ToDate)
		Begin
		  Insert Into #TempAll  
		  Select @AccountID,dbo.getvoucherprefix('ACCOUNTS PAYABLE VOUCHER') + Cast(APVID As nVarChar),  
		  dbo.StripDateFromTime(APVDate), DocumentReference, AmountApproved, OtherValue,   
		  dbo.getAccountName(ExpenseFor), DocumentID, @APV, @LOCAPV, dbo.getAccountName(ApprovedBy),  
		  'Status' = Case When (IsNULL(Status,0) & 64) = 64 then dbo.LookupDictionaryItem('Closed',Default) When (IsNULL(Status,0) & 128) = 128 then dbo.LookupDictionaryItem('Amended',Default) When IsNULL(RefDocID,0) <> 0 then dbo.LookupDictionaryItem('Amendment',Default) Else '' END,  
		  APVRemarks, @APVCOLORINFO from APVAbstract Where PartyAccountID = @AccountID And APVDate Between @FromDate And @ToDate Order By APVDate

	   	  Insert Into #TempAll(HighLight)  
	   	  Values(5)  
		End
	End
	Else
	Begin
	  	If Exists (Select * from APVAbstract Where PartyAccountID = @AccountID And isnull(status,0)=0 and (APVDate Between @FromDate And @ToDate))  
		Begin
		  Insert Into #TempAll  
		  Select @AccountID,dbo.getvoucherprefix('ACCOUNTS PAYABLE VOUCHER') + Cast(APVID As nVarChar),  
		  dbo.StripDateFromTime(APVDate), DocumentReference, AmountApproved, OtherValue,   
		  dbo.getAccountName(ExpenseFor), DocumentID, @APV, @LOCAPV, dbo.getAccountName(ApprovedBy),  
		  'Status' = Case When IsNULL(RefDocID,0) <> 0 then dbo.LookupDictionaryItem('Amendment',Default) Else '' END,  
		  APVRemarks, @APVCOLORINFO from APVAbstract Where PartyAccountID = @AccountID And Isnull(status,0) =0 and
		  (APVDate Between @FromDate And @ToDate) Order By APVDate
	
	   	  Insert Into #TempAll(HighLight)  
	   	  Values(5)  
		End
	End
 End  
  
/* Insert Net Total */
if (Select count(1) from #TempAll) > 0 
Begin
	Insert into #TempAll (DocRef,Amount,HighLight)
	Select dbo.LookupDictionaryItem('Net Total',Default),ISNULL(sum(isnull(Amount,0)),0),1 from #TempAll 
	Where Status not in (dbo.LookupDictionaryItem('Closed',Default),dbo.LookupDictionaryItem('Amended',Default)) and isnull(PartyID,0) <> 0
End

Select 'APV ID' = APVID, 'APV Date' = APVDate, 'Document Reference' = DocRef, 'APV Amount' = Amount,  
'Discount' = Discount, 'Expense For' = IsNULL(ExpenseFor,N''), 'DocID' = DocID, 'DocType' = DocType,   
'Info' = Info, 'Approved By' = IsNULL(ApprovedBy,N''), 'Status' = IsNULL(Status,N''),   
'Remarks' = IsNULL(Remarks,N''), 'HighLight' = HighLight from #TempAll  
  
Drop Table #TempAll  
Drop Table #TempGroup  
