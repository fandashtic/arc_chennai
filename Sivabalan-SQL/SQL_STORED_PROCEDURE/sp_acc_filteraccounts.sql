CREATE Procedure sp_acc_filteraccounts(@Mode integer,@KeyField nvarchar(30)=N'%',          
@Direction int = 0, @BookMark nvarchar(128) = N'')          
As          
Declare @GroupID int          
Declare @GroupName nvarchar(50)          
          
DECLARE @ALL_ACCOUNTS INT
DECLARE @RECEIPTS_OTHERS INT          
DECLARE @RECEIPTS_EXPENSE INT          
DECLARE @PAYMENTS INT          
DECLARE @OTHERS INT          
DECLARE @CONTRAENTRY INT          
DECLARE @BANKACCOUNTS INT          
DECLARE @ARVPARTY INT          
DECLARE @PETTYCASH INT          
DECLARE @COUPONPROVIDER INT  
DECLARE @NON_CRCARD_BANKACS INT
DECLARE @PARTIES_AND_EXPENSES INT

SET @ALL_ACCOUNTS = 0
SET @RECEIPTS_OTHERS =1          
SET @PAYMENTS = 2          
SET @OTHERS = 3          
SET @CONTRAENTRY= 4          
SET @RECEIPTS_EXPENSE = 5          
SET @BANKACCOUNTS= 6          
SET @ARVPARTY= 7          
SET @PETTYCASH = 8          
SET @COUPONPROVIDER = 9  
SET @NON_CRCARD_BANKACS = 10
SET @PARTIES_AND_EXPENSES = 11

Create Table #tempgroup(GroupID int,GroupName nvarchar(255),[Account Group] nVarchar(100),Status integer)          
          
IF @Mode = @RECEIPTS_OTHERS           
begin          
 /*          
 Groups          
 Profit & Loss = 12,Stock in Trade = 21,Sales=28,Purchase=27,          
 BankAccounts=18,Cash in Hand=19,Cheque in Hand=20,Fixed Asset =13,PostdatedCheque 33          
 Opening Stock=54,CLosing Stock=55          
 Expense Groups 24,25,29          
 Income Groups 26,31          
 Duties&taxes - 9          
 provisions for expenses - 10          
 CreditCard in Hand,Coupons in hand,Others in hand - 50,51,52          
          
 Accounts          
 Net Profit = 20,Net Loss = 21          
 */          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where ParentGroup in (12,21,28,27,18,7,19,20,13,33,54,55,24,25,26,31,9,10,50,51,52,73) and isnull(Active,0)=1          
          
 Declare Parent Cursor Dynamic For          
 Select GroupID,GroupName From #tempgroup where status=1          
 Open Parent          
 Fetch From Parent Into @GroupID,@GroupName          
 While @@Fetch_Status = 0          
 Begin          
  Insert into #tempgroup           
  Select GroupID,GroupName,Null,1 From AccountGroup          
  Where ParentGroup = @GroupID and isnull(Active,0)=1          
            
 Fetch Next From Parent Into @GroupID,@GroupName           
 End          
 Close Parent          
 DeAllocate Parent          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where GroupID in (12,21,28,27,18,7,19,20,13,33,54,55,24,25,26,31,17,8,9,10,50,51,52,73) and isnull(Active,0)=1          
 -- 17-Current Liability, 8-Current Asset (to avoid accounts like bills payable, recivable, claims Payable, recivable)          
          
 Insert #TempGroup          
 select AM.AccountID,AM.AccountName,AG.GroupName,2 from AccountsMaster AM,AccountGroup AG where AM.GroupID           
 not in (Select GroupID from #TempGroup where status=1) and isnull(AM.Active,0)=1          
 and AM.GroupID = AG.GroupID
           
 IF @Direction = 1          
 Begin          
  select GroupID,GroupName,[Account Group] from #tempgroup where Status=2 and GroupID not in (20,21)            
  and GroupName like @KeyField and GroupName > @BookMark          
  order by GroupName,GroupID          
 End          
 Else          
 Begin          
  select GroupID,GroupName,[Account Group] from #tempgroup where Status=2 and GroupID not in (20,21)            
  and GroupName like @KeyField          
  order by GroupName,GroupID          
 End          
 drop table #tempgroup          
end          
Else IF @Mode = @RECEIPTS_EXPENSE          
begin          
 /*          
 Groups          
 Only Expense Groups should come - 24,25,29          
 Accounts          
 Only All expense accounts should come         
 */          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where ParentGroup in (24,25,26,31)          
          
 Declare Parent Cursor Dynamic For          
 Select GroupID,GroupName From #tempgroup where status=1          
 Open Parent  
 Fetch From Parent Into @GroupID,@GroupName          
 While @@Fetch_Status = 0          
 Begin          
  Insert into #tempgroup           
  Select GroupID,GroupName,Null,1 From AccountGroup          
 Where ParentGroup = @GroupID           
            
 Fetch Next From Parent Into @GroupID,@GroupName           
 End          
 Close Parent          
 DeAllocate Parent          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where GroupID in (24,25,26,31)          
          
 Insert #TempGroup          
 select AM.AccountID,AM.AccountName,AG.GroupName,2 from AccountsMaster AM,AccountGroup AG where 
 AM.GroupID in (Select GroupID from #TempGroup where status=1) and isnull(AM.Active,0)=1        
 and AM.GroupID = AG.GroupID
           
 IF @Direction = 1          
 Begin          
  select GroupID,GroupName,[Account Group] from #tempgroup where Status=2 and GroupID not in (20,21)            
  and GroupName like @KeyField and GroupName > @BookMark          
  order by GroupName,GroupID          
 End          
 Else          
 Begin          
  select GroupID,GroupName,[Account Group] from #tempgroup where Status=2 and GroupID not in (20,21)            
  and GroupName like @KeyField          
  order by GroupName,GroupID          
 End          
 drop table #tempgroup          
           
end          
Else If @Mode=@PAYMENTS          
Begin          
 /*          
 Groups          
 Sundry Creditors=11,Profit & Loss = 12,Stock in Trade = 21,Sales=28,Purchase=27,          
 BankAccounts=18,Cash in Hand=19,Cheque in Hand=20,Fixed Asset =13,PostdatedCheque 33          
 Opening Stock=54,CLosing Stock=55          
 Expense Groups 24,25,29          
 Income Groups 26,31          
 Duties&taxes - 9          
 provisions for expenses - 10          
 CreditCard in Hand,Coupons in hand,Others in hand - 50,51,52          
           
 Accounts          
 Net Profit = 20,Net Loss = 21          
 */          
          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where ParentGroup in (12,21,28,27,18,7,19,20,13,33,24,25,26,31,9,10,50,51,52,73)          
          
 Declare Parent Cursor Dynamic For          
 Select GroupID,GroupName From #tempgroup where status=1          
 Open Parent          
 Fetch From Parent Into @GroupID,@GroupName          
 While @@Fetch_Status = 0          
 Begin          
  Insert into #tempgroup           
  Select GroupID,GroupName,Null,1 From AccountGroup          
  Where ParentGroup = @GroupID           
            
 Fetch Next From Parent Into @GroupID,@GroupName           
 End          
 Close Parent          
 DeAllocate Parent          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where GroupID in (12,21,28,27,18,7,19,20,13,33,24,25,26,31,17,8,9,10,50,51,52,73)          
 -- 17-Current Liability, 8-Current Asset (to avoid accounts like bills payable, recivable, claims Payable, recivable)          
          
 Insert #TempGroup          
 select AM.AccountID,AM.AccountName,AG.GroupName,2 from AccountsMaster AM,AccountGroup AG where 
 AM.GroupID not in (Select GroupID from #TempGroup where status=1)        
 and isnull(AM.Active,0)=1 and AM.GroupID = AG.GroupID
           
 IF @Direction = 1          
 Begin          
  select GroupID,GroupName,[Account Group] from #tempgroup where Status=2 and GroupID not in (20,21)            
  and GroupName like @KeyField and GroupName > @BookMark          
  order by GroupName,GroupID          
 End          
 Else        
 Begin          
  select GroupID,GroupName,[Account Group] from #tempgroup where Status=2 and GroupID not in (20,21)            
  and GroupName like @KeyField          
  order by GroupName,GroupID          
 End          
 drop table #tempgroup          
           
end          
Else If @Mode=@OTHERS          
Begin          
 /*          
 Groups          
 Profit & Loss = 12,Stock in Trade = 21,Sales=28,Purchase=27,          
 BankAccounts=18,Cash in Hand=19,Cheque in Hand=20,Fixed Asset =13          
 PostdatedCheque 33          
          
 Accounts          
 Net Profit = 20,Net Loss = 21          
 */          
          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where ParentGroup in (12,21,28,27,18,7,19,20,13,33) and isnull(Active,0)=1          
          
 Declare Parent Cursor Dynamic For          
 Select GroupID,GroupName From #tempgroup where status=1          
 Open Parent          
 Fetch From Parent Into @GroupID,@GroupName          
 While @@Fetch_Status = 0          
 Begin          
  Insert into #tempgroup           
  Select GroupID,GroupName,Null,1 From AccountGroup          
  Where ParentGroup = @GroupID and isnull(Active,0)=1          
            
 Fetch Next From Parent Into @GroupID,@GroupName           
 End          
 Close Parent          
 DeAllocate Parent          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where GroupID in (12,21,28,27,18,7,19,20,13,33)          
          
 Insert #TempGroup          
 select AM.AccountID,AM.AccountName,AG.GroupName,2 from AccountsMaster AM,AccountGroup AG
 where AM.GroupID not in (Select GroupID from #TempGroup where status=1) 
 and isnull(AM.Active,0)=1  and AM.GroupID = AG.GroupID        
           
 IF @Direction = 1          
 Begin          
  select GroupID,GroupName,[Account Group] from #tempgroup where Status=2 and GroupID not in (20,21)            
  and GroupName like @KeyField and GroupName > @BookMark          
  order by GroupName,GroupID          
 End          
 Else          
 Begin          
  select GroupID,GroupName,[Account Group] from #tempgroup where Status=2 and GroupID not in (20,21)            
  and GroupName like @KeyField order by GroupName,GroupID          
 End          
          
          
 drop table #tempgroup          
           
end          
Else If @Mode=@CONTRAENTRY          
Begin          
 /*          
 Groups          
 BankAccounts=18,Cash in Hand=19          
           
 */          
          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where ParentGroup in (18,7,19) and isnull(Active,0)=1          
          
 Declare Parent Cursor Dynamic For          
 Select GroupID,GroupName From #tempgroup where status=1          
 Open Parent          
 Fetch From Parent Into @GroupID,@GroupName          
 While @@Fetch_Status = 0          
 Begin          
  Insert into #tempgroup           
  Select GroupID,GroupName,Null,1 From AccountGroup          
  Where ParentGroup = @GroupID and isnull(Active,0)=1          
            
 Fetch Next From Parent Into @GroupID,@GroupName           
 End          
 Close Parent          
 DeAllocate Parent          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where GroupID in (18,7,19) and isnull(Active,0)=1          
          
 IF @Direction = 1          
 Begin          
  select AM.AccountID,AM.AccountName,AG.GroupName as [Account Group] from AccountsMaster AM,AccountGroup AG where 
  AM.GroupID in (Select GroupID from #TempGroup where status=1) and isnull(AM.Active,0)=1 and AM.GroupID = AG.GroupID
  and AccountName > @BookMark order by AccountName,AccountID          
 End          
 Else          
 Begin          
  select AM.AccountID,AM.AccountName,AG.GroupName as [Account Group] from AccountsMaster AM,AccountGroup AG where 
  AM.GroupID in (Select GroupID from #TempGroup where status=1) and isnull(AM.Active,0)=1 and AM.GroupID = AG.GroupID
  order by AccountName,AccountID          
 End          
          
 Drop table #tempgroup          
           
end          
Else IF @Mode = @BANKACCOUNTS          
begin          
 /*          
 Groups          
 Only Bank Account Groups should come - 18          
 Accounts          
 Only All bank accounts should come          
 */          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where ParentGroup in (18,7) and isnull(Active,0)=1          
          
 Declare Parent Cursor Dynamic For          
Select GroupID,GroupName From #tempgroup where status=1  
 Open Parent          
 Fetch From Parent Into @GroupID,@GroupName          
 While @@Fetch_Status = 0          
 Begin          
  Insert into #tempgroup           
  Select GroupID,GroupName,Null,1 From AccountGroup          
  Where ParentGroup = @GroupID and isnull(Active,0)=1          
            
 Fetch Next From Parent Into @GroupID,@GroupName           
 End          
 Close Parent          
 DeAllocate Parent          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where GroupID in (18,7) and isnull(Active,0)=1          
          
 Insert #TempGroup         
 select AM.AccountID,AM.AccountName,AG.GroupName,2 from AccountsMaster AM,AccountGroup AG 
 where AM.GroupID in (Select GroupID from #TempGroup where status=1) 
 and isnull(AM.Active,0)=1  and AM.GroupID = AG.GroupID
           
 IF @Direction = 1          
 Begin          
  select GroupID,GroupName,[Account Group] from #tempgroup          
  where Status=2 and GroupName like @KeyField          
  and GroupName > @BookMark          
  order by GroupName,GroupID          
 End          
 Else          
 Begin          
  select GroupID,GroupName,[Account Group] from #tempgroup where Status=2 and GroupName like @KeyField          
  order by GroupName,GroupID          
 End          
           
 drop table #tempgroup          
           
end          
Else If @Mode=@ARVPARTY          
Begin          
 /*          
 Groups          
 Profit & Loss = 12,Stock in Trade = 21,Sales=28,Purchase=27,          
 BankAccounts=18,Cash in Hand=19,Cheque in Hand=20,Fixed Asset =13          
 Expense Groups 24,25,29          
 Income Groups 26,31          
 PostdatedCheque 33          
 Accounts          
 Net Profit = 20,Net Loss = 21          
 */          
          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where ParentGroup in (12,13,18,7,19,20,21,24,25,26,27,28,29,31,33,9,10,50,51,52,73) and isnull(Active,0)=1          
          
 Declare Parent Cursor Dynamic For          
 Select GroupID,GroupName From #tempgroup where status=1          
 Open Parent          
 Fetch From Parent Into @GroupID,@GroupName          
 While @@Fetch_Status = 0          
 Begin          
  Insert into #tempgroup         
  Select GroupID,GroupName,Null,1 From AccountGroup          
  Where ParentGroup = @GroupID and isnull(Active,0)=1          
            
 Fetch Next From Parent Into @GroupID,@GroupName           
 End          
 Close Parent          
 DeAllocate Parent          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where GroupID in (12,13,18,7,19,20,21,24,25,26,27,28,29,31,33,17,8,9,10,50,51,52,73) -- 17-Current Liability, 8-Current Asset (to avoid accounts like bills payable, recivable, claims Payable, recivable)          
          
 Insert #TempGroup          
 select AM.AccountID,AM.AccountName,AG.GroupName,2 from AccountsMaster AM,AccountGroup AG 
 where AM.GroupID not in (Select GroupID from #TempGroup where status=1) 
 and isnull(AM.Active,0)=1 and AM.GroupID = AG.GroupID
           
 IF @Direction = 1          
 Begin          
  select GroupID,GroupName,[Account Group] from #tempgroup where Status=2 and GroupID not in (20,21)            
  and GroupName like @KeyField and GroupName > @BookMark          
  order by GroupName,GroupID          
 End          
 Else          
 Begin          
  select GroupID,GroupName,[Account Group] from #tempgroup where Status=2 and GroupID not in (20,21)            
  and GroupName like @KeyField order by GroupName,GroupID          
 End          
 drop table #tempgroup          
end          
else if @Mode = @PETTYCASH           
Begin          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where ParentGroup in (1,12,13,18,7,19,20,21,33,11,22,35,45,27,28) and isnull(Active,0)=1          
                    
 Declare Parent Cursor Dynamic For          
 Select GroupID,GroupName From #tempgroup where status=1          
 Open Parent          
 Fetch From Parent Into @GroupID,@GroupName          
 While @@Fetch_Status = 0          
 Begin          
  Insert into #tempgroup           
  Select GroupID,GroupName,Null,1 From AccountGroup          
  Where ParentGroup = @GroupID and isnull(Active,0)=1          
            
 Fetch Next From Parent Into @GroupID,@GroupName           
 End          
 Close Parent          
 DeAllocate Parent          
 Insert into #tempgroup          
 Select GroupID,GroupName,Null,1 from AccountGroup          
 where GroupID in (1,12,13,18,7,19,20,21,33,11,22,35,45,27,28)           
          
 Insert #TempGroup          
 select AM.AccountID,AM.AccountName,AG.GroupName,2 from AccountsMaster AM,AccountGroup AG where 
 AM.GroupID not in (Select GroupID from #TempGroup where status=1) 
 and isnull(AM.Active,0)=1 and AM.GroupID = AG.GroupID
           
 IF @Direction = 1          
 Begin          
  select GroupID,GroupName,[Account Group] from #tempgroup where Status=2 and GroupID not in (20,21)            
  and GroupName like @KeyField and GroupName > @BookMark          
  order by GroupName,GroupID          
 End          
 Else          
 Begin          
  select GroupID,GroupName,[Account Group] from #tempgroup where Status=2 and GroupID not in (20,21)            
  and GroupName like @KeyField order by GroupName,GroupID          
 End          
 drop table #tempgroup          
End   
Else If @Mode = @COUPONPROVIDER  
Begin  
 Insert Into #TempGroup            
 Select GroupID,GroupName,Null,1 from AccountGroup Where ParentGroup In (48,49,11)   
 And IsNull(Active,0)=1  
            
 Declare Parent Cursor Dynamic For            
 Select GroupID,GroupName From #TempGroup where status=1            
 Open Parent            
 Fetch From Parent Into @GroupID,@GroupName            
 While @@Fetch_Status = 0            
  BegIn            
   Insert Into #TempGroup             
   Select GroupID,GroupName,Null,1 From AccountGroup Where ParentGroup = @GroupID   
   And IsNull(Active,0)=1            
     
   Fetch Next From Parent Into @GroupID,@GroupName             
  End            
 Close Parent            
 DeAllocate Parent            
  
 Insert Into #TempGroup            
 Select GroupID,GroupName,Null,1 from AccountGroup Where GroupID In (48,49,11)   
 And IsNull(Active,0)=1   
            
 Insert Into #TempGroup            
 Select AM.AccountID,AM.AccountName,AG.GroupName,2 from AccountsMaster AM,AccountGroup AG 
 Where AM.GroupID In (Select GroupID from #TempGroup Where status=1) And IsNull(AM.Active,0)=1            
 and AM.GroupID = AG.GroupID

 If @Direction = 1            
  Begin            
   Select GroupID,GroupName,[Account Group] from #TempGroup where Status=2   
   And GroupName like @KeyField and GroupName > @BookMark Order By GroupName,GroupID            
  End            
 Else            
  Begin            
   Select GroupID,GroupName,[Account Group] from #TempGroup where Status=2   
   And GroupName like @KeyField Order By GroupName,GroupID            
  End            
 Drop table #TempGroup  
End 
Else If @Mode = @NON_CRCARD_BANKACS  
Begin  
	Insert into #tempgroup select GroupID,GroupName,Null,1 From AccountGroup      
	Where ParentGroup in (18,7)  
	
	Declare Parent Cursor Dynamic For      
	Select GroupID,GroupName From #tempgroup where status=1      
	Open Parent      
	      
	Fetch From Parent Into @GroupID,@GroupName      
	While @@Fetch_Status = 0      
	Begin      
		Insert into #tempgroup       
		Select GroupID,GroupName,Null,1 From AccountGroup      
		Where ParentGroup = @GroupID      
		   
		Insert into #tempgroup       
		Select AM.AccountID,AM.AccountName,AG.GroupName,2 From AccountsMaster AM,AccountGroup AG      
		Where AM.GroupID = @GroupID And IsNull(AM.Active,0)=1    
		and AM.GroupID = AG.GroupID
	      
		Fetch Next From Parent Into @GroupID,@GroupName       
	End      
	Close Parent      
	DeAllocate Parent      
	  
	Insert into #tempgroup      
	select AM.AccountID,AM.AccountName,AG.GroupName,2 From AccountsMaster AM,AccountGroup AG
	Where AM.GroupID in (18,7) And IsNull(AM.Active,0)=1      
	and AM.GroupID = AG.GroupID
	  
	select Bank.BankID,#TempGroup.GroupName,[Account Group] from #tempgroup ,Bank
	where #TempGroup.GroupID = Bank.AccountID and Status=2 Order By GroupName      
	drop table #tempgroup 
End
Else IF @Mode = @ALL_ACCOUNTS 
Begin
	If @Direction = 1
	Begin
		select AM.AccountID,AM.AccountName,AG.GroupName as [Account Group] 
		from  [AccountsMaster] AM,[AccountGroup] AG where 
		AM.GroupID = AG.GroupId and AM.AccountID not in (22,23,88,89,500) 
		And AccountName like @KeyField and AccountName > @BookMark Order by AccountName,AccountID
	End
	Else
	Begin
		select AM.AccountID,AM.AccountName,AG.GroupName as [Account Group] 
		from  [AccountsMaster] AM,[AccountGroup] AG where 
		AM.GroupID = AG.GroupId and AM.AccountID not in (22,23,88,89,500) 
		And AccountName like @KeyField Order by AccountName,AccountID
	End            
End
Else IF @Mode = @PARTIES_AND_EXPENSES          
Begin          
 Insert Into #TempGroup
 Select GroupID,GroupName,NULL,1 from AccountGroup Where ParentGroup IN (12,21,28,27,18,7,19,20,13,33,9,10,50,51,52,73)
          
 Declare Parent Cursor Dynamic For          
 Select GroupID,GroupName From #TempGroup where Status=1          
 Open Parent          
 Fetch From Parent Into @GroupID,@GroupName          
 While @@Fetch_Status = 0          
 Begin          
  Insert into #TempGroup           
  Select GroupID,GroupName,NULL,1 From AccountGroup          
  Where ParentGroup = @GroupID           
  Fetch Next From Parent Into @GroupID,@GroupName           
 End          
 Close Parent          
 DeAllocate Parent          

 Insert Into #TempGroup          
 Select GroupID,GroupName,NULL,1 from AccountGroup Where GroupID IN (12,21,28,27,18,7,19,20,13,33,17,8,9,10,50,51,52,73)
          
 Insert #TempGroup          
 Select AM.AccountID,AM.AccountName,AG.GroupName,2 from AccountsMaster AM,AccountGroup AG 
 Where AM.GroupID Not IN (Select GroupID from #TempGroup Where Status=1)        
 And IsNULL(AM.Active,0)=1 and AM.GroupID = AG.GroupID

 If @Direction = 1          
 Begin          
  select GroupID,GroupName,[Account Group] from #TempGroup where Status=2 and GroupID not in (20,21)            
  and GroupName like @KeyField and GroupName > @BookMark          
  order by GroupName,GroupID          
 End          
 Else          
 Begin          
  select GroupID,GroupName,[Account Group] from #TempGroup where Status=2 and GroupID not in (20,21)            
  and GroupName like @KeyField          
  order by GroupName,GroupID          
 End          
 Drop Table #TempGroup
End          
