CREATE procedure sp_acc_accountexists(@mode int,@masterid nvarchar(20))  
as  
Declare @CUSTOMER Int  
Declare @VENDOR Int  
Declare @BANKACCOUNT Int  
Declare @BRANCH Int  
Declare @accountid int  
DECLARE @PERSONNAL INT  
  
Set @CUSTOMER = 1  
Set @VENDOR = 2   
Set @BANKACCOUNT = 3  
Set @BRANCH = 4  
Set @PERSONNAL = 7  
  
if @mode = @CUSTOMER   
begin  
 select @accountid = isnull(AccountID,0) from Customer  
 where CustomerID = @masterid     
end  
else if @mode = @VENDOR  
begin  
 select @accountid = isnull(AccountID,0) from Vendors  
 where VendorID = @masterid     
end  
else if @mode = @BRANCH  
begin  
 select @accountid = isnull(AccountID,0) from WareHouse  
 where WareHouseID = @masterid     
end  
else if @mode = @PERSONNAL  
begin  
 select @accountid = isnull(AccountID,0) from PersonnelMaster  
 where PersonnelID = @masterid     
end  
select @accountid
