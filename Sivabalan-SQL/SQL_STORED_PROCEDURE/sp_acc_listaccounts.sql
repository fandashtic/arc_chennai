CREATE procedure sp_acc_listaccounts(@parentid integer)      
as      
Declare @GroupID int      
Declare @GroupName nvarchar(50)      
Declare @BANK_ACCOUNTS As Int  
Declare @BANK_OVERDRAFT_ACCOUNT As Int  
Declare @BRS_BANK_ACCOUNTS As Int  

Set @BANK_ACCOUNTS = 18  
Set @BANK_OVERDRAFT_ACCOUNT = 7  

Create Table #tempgroup(GroupID int,GroupName nvarchar(50),Status integer)      
If @parentid = @BANK_ACCOUNTS
 Begin  
  Insert into #tempgroup select GroupID,GroupName,1 From AccountGroup      
  Where ParentGroup in (@parentid,@BANK_OVERDRAFT_ACCOUNT)  
 End  
Else  
 Begin  
  Insert into #tempgroup select GroupID,GroupName,1 From AccountGroup      
  Where ParentGroup = @parentid  
 End  

Declare Parent Cursor Dynamic For      
Select GroupID,GroupName From #tempgroup where status=1      
Open Parent      
      
Fetch From Parent Into @GroupID,@GroupName      
While @@Fetch_Status = 0      
Begin      
 Insert into #tempgroup       
 Select GroupID,GroupName,1 From AccountGroup      
 Where ParentGroup = @GroupID      
       
 Insert into #tempgroup       
 Select AccountID,AccountName,2 From AccountsMaster      
 Where GroupID = @GroupID And IsNull(Active,0)=1    
      
Fetch Next From Parent Into @GroupID,@GroupName       
End      
Close Parent      
DeAllocate Parent      
  
If @parentid = @BANK_ACCOUNTS  
 Begin  
  Insert into #tempgroup      
  select AccountID,AccountName,2 From AccountsMaster       
  Where GroupID in (@parentid,@BANK_OVERDRAFT_ACCOUNT) And IsNull(Active,0)=1      
 End  
Else  
 Begin  
  Insert into #tempgroup      
  select AccountID,AccountName,2 From AccountsMaster       
  Where GroupID = @parentid And IsNull(Active,0)=1         
 End  
  
select * from #tempgroup where Status=2 Order By GroupName      
drop table #tempgroup 


