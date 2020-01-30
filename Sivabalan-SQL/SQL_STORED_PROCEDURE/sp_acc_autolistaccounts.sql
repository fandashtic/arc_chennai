CREATE Procedure sp_acc_autolistaccounts(@ParentID integer,@mode integer,            
@KeyField nvarchar(30)='%',@Direction int = 0, @BookMark nvarchar(128) = N'')            
As      
      
Declare @GroupID int            
Declare @GroupName nvarchar(255)            
            
If @mode =1             
Begin            
 Create Table #tempgroup(AccountID int,AccountName nvarchar(255),[Account Group] nVarchar(100),Status integer)             
            
 Insert into #tempgroup select GroupID,GroupName,Null,1 From AccountGroup            
 Where ParentGroup = @ParentID            
             
 Declare Parent Cursor Dynamic For            
 Select AccountID,AccountName From #tempgroup where status=1            
 Open Parent            
             
 Fetch From Parent Into @GroupID,@GroupName            
 While @@Fetch_Status = 0            
 Begin            
  Insert into #tempgroup             
  Select GroupID,GroupName,Null,1 From AccountGroup            
  Where ParentGroup = @GroupID            
              
  Insert into #tempgroup             
  Select AM.AccountID,AM.AccountName,AG.GroupName,2 From AccountsMaster AM,AccountGroup AG 
  Where AM.GroupID = @GroupID and isnull(AM.Active,0)=1 and AM.GroupID = AG.GroupID
             
 Fetch Next From Parent Into @GroupID,@GroupName             
 End            
 Close Parent            
 DeAllocate Parent            
 Insert into #tempgroup            
 select AM.AccountID,AM.AccountName,AG.GroupName,2 From AccountsMaster  AM,AccountGroup AG 
 Where AM.GroupID = @ParentID and isnull(AM.Active,0)=1 and AM.GroupID = AG.GroupID
             
 IF @Direction = 1            
 Begin            
  select Top 9 AccountID,AccountName,[Account Group] from #tempgroup where Status=2            
  and AccountName like @KeyField and AccountName > @BookMark            
  order by AccountName            
 End            
 Else            
 Begin            
  select Top 9 AccountID,AccountName,[Account Group] from #tempgroup where Status=2            
  and AccountName like @KeyField            
  order by AccountName            
 End            
 drop table #tempgroup            
End            
Else if @mode =2             
Begin            
 Create Table #tempgroup1(AccountID int,AccountName nvarchar(255),Status integer)            
       
 Insert into #tempgroup1 select GroupID,GroupName,1 From AccountGroup            
 Where ParentGroup = @ParentID or ParentGroup in (1,12,18,19,20,21,33,45)            
       
 Declare Parent Cursor Dynamic For            
 Select AccountID,AccountName From #tempgroup1 where status=1            
 Open Parent            
       
 Fetch From Parent Into @GroupID,@GroupName            
 While @@Fetch_Status = 0            
 Begin            
  Insert into #tempgroup1             
  Select GroupID,GroupName,1 From AccountGroup            
  Where ParentGroup = @GroupID             
        
  Insert into #tempgroup1             
  Select AccountID,AccountName,2 From AccountsMaster 
  Where GroupID = @GroupID and isnull(Active,0)=1
             
 Fetch Next From Parent Into @GroupID,@GroupName             
 End            
 Close Parent            
 DeAllocate Parent            
       
 Insert into #tempgroup1            
 select AccountID,AccountName,2 From AccountsMaster 
 Where GroupID = @ParentID or GroupID in (1,12,18,19,20,21,33,45) and 
 isnull(Active,0)=1 
             
 IF @Direction = 1            
 Begin            
  select Top 9 AM.AccountID,AM.AccountName,AG.GroupName as [Account Group] from AccountsMaster AM,AccountGroup AG
  where AM.AccountID not in(select AccountID from #tempgroup1 where Status=2)            
  and isnull(AM.Active,0)=1 and AccountName like @keyfield            
  and AccountName > @BookMark and AM.GroupID = AG.GroupID
  order by AccountName            
 End            
 Else            
 Begin            
  select Top 9 AM.AccountID,AM.AccountName,AG.GroupName as [Account Group] from AccountsMaster AM,AccountGroup AG
  where AM.AccountID not in(select AccountID from #tempgroup1 where Status=2)            
  and isnull(AM.Active,0)=1 and AccountName like @keyfield and AM.GroupID = AG.GroupID
  order by AccountName            
 End            
 drop table #tempgroup1            
End            
Else if @mode =3            
Begin            
 Create Table #tempgroup2(GroupID int)            
             
 Insert into #tempgroup2 select GroupID From AccountGroup            
 Where GroupID in (1,12,13,20,21,33,45)             
             
 Declare Parent Cursor Dynamic For            
 Select GroupID From #tempgroup2       
 Open Parent            
      
 Fetch From Parent Into @GroupID      
 While @@Fetch_Status = 0            
 Begin            
  Insert into #tempgroup2             
  Select GroupID From AccountGroup       
  Where ParentGroup = @GroupID            
             
 Fetch Next From Parent Into @GroupID      
 End            
 Close Parent            
 DeAllocate Parent            
      
 IF @Direction = 1            
 Begin            
  select Top 9 AM.AccountID,AM.AccountName,AG.GroupName as [Account Group] from AccountsMaster AM,AccountGroup AG 
  where AM.GroupID not in (select GroupID from #tempgroup2)            
  and isnull(AM.Active,0)=1 and AccountName like @keyfield            
  and AccountName > @BookMark  and AM.GroupID = AG.GroupID
  order by AccountName            
 End            
 Else            
 Begin            
  select Top 9 AM.AccountID,AM.AccountName,AG.GroupName as [Account Group] from AccountsMaster AM,AccountGroup AG 
  where AM.GroupID not in (select GroupID from #tempgroup2)      
  and isnull(AM.Active,0)=1 and AccountName like @keyfield and AM.GroupID = AG.GroupID
  order by AccountName            
 End             
 drop table #tempgroup2            
End            
Else if @mode = 4            
Begin            
 Create Table #tempgroup3(AccountID int,AccountName nvarchar(255),Status integer)            
 Create Table #tempgroup4(AccountID int,AccountName nvarchar(255),Status integer)            
             
 Insert into #tempgroup3 select GroupID,GroupName,1 From AccountGroup            
 Where ParentGroup in (1,12,13,21)            
       
 Declare Parent Cursor Dynamic For            
 Select AccountID,AccountName From #tempgroup3 where status=1            
 Open Parent            
       
 Fetch From Parent Into @GroupID,@GroupName            
 While @@Fetch_Status = 0            
 Begin            
  Insert into #tempgroup3             
  Select GroupID,GroupName,1 From AccountGroup            
  Where ParentGroup = @GroupID             
        
  Insert into #tempgroup3             
  Select AccountID,AccountName,2 From AccountsMaster            
  Where GroupID = @GroupID and isnull(Active,0)=1            
             
 Fetch Next From Parent Into @GroupID,@GroupName             
 End            
 Close Parent            
 DeAllocate Parent            
            
 Insert into #tempgroup3            
 select AccountID,AccountName,2 From AccountsMaster             
 Where GroupID in (1,12,13,21) and isnull(Active,0)=1          
       
 Insert into #tempgroup4            
 select AccountID,AccountName,2 from AccountsMaster            
 where AccountID not in(select AccountID from #tempgroup3 where Status=2)            
 and isnull(Active,0)=1             
       
 select AccountID from #tempgroup4            
 where AccountID = @ParentID            
       
 drop table #tempgroup3            
 drop table #tempgroup4            
End            
Else if @mode = 5            
Begin            
 Create Table #tempgroup5(AccountID int,AccountName nvarchar(255),Status integer)            
 Create Table #tempgroup6(AccountID int,AccountName nvarchar(255),Status integer)            
    
 Insert into #tempgroup5 select GroupID,GroupName,1 From AccountGroup            
 Where ParentGroup = 13            
             
 Declare Parent Cursor Dynamic For            
 Select AccountID,AccountName From #tempgroup5 where status=1            
 Open Parent            
             
 Fetch From Parent Into @GroupID,@GroupName            
 While @@Fetch_Status = 0            
 Begin        
  Insert into #tempgroup5             
  Select GroupID,GroupName,1 From AccountGroup            
  Where ParentGroup = @GroupID             
              
  Insert into #tempgroup5             
  Select AccountID,AccountName,2 From AccountsMaster            
  Where GroupID = @GroupID and isnull(Active,0)=1            
             
 Fetch Next From Parent Into @GroupID,@GroupName     
 End            
 Close Parent            
 DeAllocate Parent            
            
 Insert into #tempgroup5            
 select AccountID,AccountName,2 From AccountsMaster             
 Where GroupID = 13 and isnull(Active,0)=1          
       
 Insert into #tempgroup6            
 select AccountID,AccountName,2 from #tempgroup5 where Status=2            
       
 select AccountID from #tempgroup6            
 where AccountID = @ParentID            
       
 drop table #tempgroup5            
 drop table #tempgroup6            
End            
Else if @mode = 6            
Begin            
-- for petty cash            
 Create Table #tempgroup7(AccountID int,AccountName nvarchar(255),Status integer)            
       
 Insert into #tempgroup7 select GroupID,GroupName,1 From AccountGroup            
 Where ParentGroup = @ParentID or ParentGroup in (1,12,18,19,20,21,33,11,22,18,35,45,            
 27,28)         
       
 Declare Parent Cursor Dynamic For            
 Select AccountID,AccountName From #tempgroup7 where status=1            
 Open Parent            
       
 Fetch From Parent Into @GroupID,@GroupName            
 While @@Fetch_Status = 0            
 Begin            
  Insert into #tempgroup7             
  Select GroupID,GroupName,1 From AccountGroup            
  Where ParentGroup = @GroupID             
        
  Insert into #tempgroup7             
  Select AccountID,AccountName,2 From AccountsMaster            
  Where GroupID = @GroupID and isnull(Active,0)=1            
             
 Fetch Next From Parent Into @GroupID,@GroupName             
 End            
 Close Parent            
 DeAllocate Parent            
       
 Insert into #tempgroup7            
 select AccountID,AccountName,2 From AccountsMaster             
 Where GroupID = @ParentID or GroupID in (1,12,18,19,20,21,33,11,22,18,35,45,27,28) 
 and isnull(Active,0)=1          
             
 IF @Direction = 1            
 Begin            
  select Top 9 AM.AccountID,AM.AccountName,AG.GroupName as [Account Group]  from AccountsMaster AM,AccountGroup AG
  where AM.AccountID not in(select AccountID from #tempgroup7 where Status=2)            
  and isnull(AM.Active,0)=1 and AccountName like @keyfield            
  and AccountName > @BookMark and AM.GroupID = AG.GroupID
  order by AccountName            
 End            
 Else            
 Begin            
  select Top 9 AM.AccountID,AM.AccountName,AG.GroupName as [Account Group]  from AccountsMaster AM,AccountGroup AG
  where AM.AccountID not in(select AccountID from #tempgroup7 where Status=2)            
  and isnull(AM.Active,0)=1 and AccountName like @keyfield and AM.GroupID = AG.GroupID
  order by AccountName            
 End            
 drop table #tempgroup7            
End             
Else if @mode = 7            
Begin            
 /*            
 Groups            
 Only Expense Groups should come - 24,25,29            
 Accounts            
 Only All expense accounts should come            
 */            
 Create Table #tempgroup8(GroupID int,GroupName nvarchar(255),[Account Group] nVarchar(100),Status integer)            
 Insert into #tempgroup8            
 Select GroupID,GroupName,Null,1 from AccountGroup            
 where ParentGroup in (24,25,26,31)            
            
 Declare Parent Cursor Dynamic For            
 Select GroupID,GroupName From #tempgroup8 where status=1            
 Open Parent            
 Fetch From Parent Into @GroupID,@GroupName            
 While @@Fetch_Status = 0            
 Begin            
  Insert into #tempgroup8             
  Select GroupID,GroupName,Null,1 From AccountGroup            
  Where ParentGroup = @GroupID             
 Fetch Next From Parent Into @GroupID,@GroupName             
 End            
 Close Parent            
 DeAllocate Parent            
      
 Insert into #tempgroup8            
 Select GroupID,GroupName,Null,1 from AccountGroup            
 where GroupID in (24,25,26,31)            
            
 Insert #tempgroup8            
 select AM.AccountID,AM.AccountName,AG.GroupName,2 from AccountsMaster AM,AccountGroup AG  
 where AM.GroupID in (Select GroupID from #tempgroup8 where status=1) and isnull(AM.Active,0)=1          
 and AM.GroupID = AG.GroupID

 IF @Direction = 1            
 Begin            
  select Top 9 GroupID,GroupName,[Account Group] from #tempgroup8 where Status=2 and GroupID not in (20,21)              
  and GroupName like @KeyField and GroupName > @BookMark            
  order by GroupName            
 End            
 Else            
 Begin            
  select Top 9 GroupID,GroupName,[Account Group] from #tempgroup8 where Status=2 and GroupID not in (20,21)              
  and GroupName like @KeyField            
  order by GroupName            
 End            
 drop table #tempgroup8            
End            
Else if @mode = 8            
Begin            
/*            
 List all user accounts under chequeinhand             
*/        
 Create Table #tempgroup9(GroupID int,GroupName nvarchar(255),[Account Group] nVarchar(100),Status integer)            
 Insert into #tempgroup9            
 Select GroupID,GroupName,Null,1 from AccountGroup            
 where ParentGroup in (20,50)            
            
 Declare Parent Cursor Dynamic For            
 Select GroupID,GroupName From #tempgroup9 where status=1            
 Open Parent            
 Fetch From Parent Into @GroupID,@GroupName            
 While @@Fetch_Status = 0            
 Begin            
  Insert into #tempgroup9             
  Select GroupID,GroupName,Null,1 From AccountGroup            
  Where ParentGroup = @GroupID             
 Fetch Next From Parent Into @GroupID,@GroupName             
 End            
 Close Parent            
 DeAllocate Parent            
      
 Insert into #tempgroup9            
 Select GroupID,GroupName,Null,1 from AccountGroup            
 where GroupID in (20,50)            
            
 Insert #tempgroup9            
 select AM.AccountID,AM.AccountName,AG.GroupName,2 from AccountsMaster  AM,AccountGroup AG
 where AM.GroupID in (Select GroupID from #tempgroup9 where status=1)            
 and IsNull(AM.RetailPaymentMode,0)<> 0 and isnull(AM.Active,0)=1          
 and AM.GroupID = AG.GroupID

 select GroupID,GroupName,[Account Group] from #tempgroup9 where Status=2             
 and GroupID = @ParentID            
            
 drop table #tempgroup9            
End            
Else if @mode = 9        
Begin            
 /*            
 this block is for accounts master name change        
 groupids not equal to : 1,7,11,18,22,35        
 */            
 Create Table #tempgroup10(GroupID int,GroupName nvarchar(255),Status integer)            
 Insert into #tempgroup10            
 Select GroupID,GroupName,1 from AccountGroup            
 where groupid in (1,7,11,18,22,35,500)        
        --(7,11,18,22,35)            
 Declare Parent Cursor Dynamic For            
 Select GroupID,GroupName From #tempgroup10 where status=1            
Open Parent            
 Fetch From Parent Into @GroupID,@GroupName            
 While @@Fetch_Status = 0            
 Begin            
 Insert into #tempgroup10             
 Select GroupID,GroupName,1 From AccountGroup            
 Where ParentGroup = @GroupID             
 Fetch Next From Parent Into @GroupID,@GroupName          
 End            
 Close Parent            
 DeAllocate Parent            
      
 If @direction = 1      
 Begin      
  select Top 9 AM.AccountID,AM.AccountName,AG.GroupName as [Account Group],2 from AccountsMaster AM,AccountGroup AG 
  where AM.GroupID not in (Select GroupID from #tempgroup10)      
  and isnull(AM.fixed,0)=0 and isnull(AM.Active,0)=1          
  and AM.accountname like @keyfield and AM.accountname > @BookMark 
  and AM.GroupID = AG.GroupID
  order by AM.accountname      
 End      
Else      
 Begin      
  select Top 9 AM.AccountID,AM.AccountName,AG.GroupName as [Account Group],2 from AccountsMaster AM,AccountGroup AG 
  where AM.GroupID not in (Select GroupID from #tempgroup10)      
  and isnull(AM.fixed,0)=0 and isnull(AM.Active,0)=1          
  and AM.accountname like @keyfield 
  and AM.GroupID = AG.GroupID
  order by AM.accountname      
 End      
  drop table #tempgroup10        
End       
Else if @mode =10      
Begin            
 /* display de-activated account while displaying in the Asset Modify Screen*/      
 Create Table #tempgroup11(AccountID int,AccountName nvarchar(255),[Account Group] nVarchar(100),Status integer)             
            
 Insert into #tempgroup11 select GroupID,GroupName,Null,1 From AccountGroup            
 Where ParentGroup = @ParentID            
       
 Declare Parent Cursor Dynamic For            
 Select AccountID,AccountName From #tempgroup11 where status=1            
 Open Parent            
             
 Fetch From Parent Into @GroupID,@GroupName            
 While @@Fetch_Status = 0            
 Begin            
  Insert into #tempgroup11             
  Select GroupID,GroupName,Null,1 From AccountGroup            
  Where ParentGroup = @GroupID            
              
  Insert into #tempgroup11             
  Select AM.AccountID,AM.AccountName,AG.GroupName,2 From AccountsMaster AM,AccountGroup AG
  Where AM.GroupID = @GroupID and AM.GroupID = AG.GroupID
             
 Fetch Next From Parent Into @GroupID,@GroupName             
 End            
 Close Parent            
 DeAllocate Parent            
      
 Insert into #tempgroup11            
 select AM.AccountID,AM.AccountName,AG.GroupName,2 From AccountsMaster AM,AccountGroup AG
 Where AM.GroupID = @ParentID and AM.GroupID = AG.GroupID
             
 IF @Direction = 1            
 Begin            
  select Top 9 AccountID,AccountName,[Account Group] from #tempgroup11 where Status=2            
  and AccountName like @KeyField and AccountName > @BookMark            
  order by AccountName            
 End            
 Else            
 Begin            
  select Top 9 AccountID,AccountName,[Account Group] from #tempgroup11 where Status=2            
  and AccountName like @KeyField            
  order by AccountName            
 End            
 drop table #tempgroup11      
End            
Else If @Mode = 11      
 Begin /*To Display Credit Card Bank Accounts In Retail Invoice Collection Screen*/      
  CREATE Table #TempBank(BankID Int, Account_Number nVarChar(255))      
        
  Insert Into #TempBank      
  Select BankAccount_PaymentModes.BankID, 'Account_Number' = (Select BankName from BankMaster   
  Where BankMaster.BankCode = Bank.BankCode) + N' - ' + CAST(Bank.Account_Number As nVarChar(100))       
  from Bank, BankAccount_PaymentModes Where BankAccount_PaymentModes.BankID = Bank.BankID      
  And BankAccount_PaymentModes.CreditCardID = @ParentID      
        
  If @Direction = 1            
   Begin            
    Select Top 9 BankID, Account_Number from #TempBank Where Account_Number Like @KeyField      
    And Account_Number > @BookMark Order By Account_Number      
   End      
  Else      
   Begin      
    Select Top 9 BankID, Account_Number from #TempBank Where Account_Number Like @KeyField      
    Order By Account_Number      
   End      
  Drop Table #TempBank      
 End


