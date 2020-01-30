CREATE Procedure SP_Import_Branch_Bunge(    
  @WareHouseID nvarchar(50),    
  @WareHouse_Name nvarchar(100),    
  @Address nvarchar(510),    
  @City  nvarchar(100),    
  @State  nvarchar(100),    
  @Country nvarchar(100),    
  @ForumID nvarchar(40),    
  @TIN_Number nvarchar(20)=Null,
  @BranchState nvarchar(200))    
As    
Declare @CityID Int    
Declare @StateId Int    
Declare @CountryId Int    
Declare @CanSaveBranch nVarchar(1)        
Declare @CountBranch int        
Declare @AccountID Int    
Declare @BranchStateID Int
Set @CanSaveBranch='N'    --Invalid Record    
SET NOCOUNT ON    
Begin        
  Select @CountBranch=Count(*) from Warehouse Where Warehouseid = @Warehouseid And Warehouse_Name =@wareHouse_Name And Forumid =@Forumid    
        
  IF (@CountBranch =1)        
    Set @CanSaveBranch='E'     -- Exsisting Record    
  Else        
    Begin        
      Select @CountBranch=Count(*) from WareHouse Where Warehouseid = @Warehouseid or Warehouse_Name =@wareHouse_Name or Forumid = @Forumid    
      If(@CountBranch=0)        
        Set @CanSaveBranch='Y'     -- yes U Can Save Record    
      Else        
        Set @CanSaveBranch='N'     -- No u Cant Save This .Some Invalid data is Given         
    End        
End        

 -- BrachState  
Select @BranchStateID = 0   
Select @BranchStateID= ID From BranchState Where Name = @BranchState  
 If @BranchStateID=0   
 Begin        
   Set @CanSaveBranch='N'     -- No u Cant Save This. StateInfo Must  
 End  
  
 -- CityMaster      
Select @cityID=0      
Select @CityID=CityId From City Where CityName=@City      
If @CityID = 0 And len(@City)<>0      
 Begin      
   Insert into City (CityName) Values (@City)      
   Set @cityid=@@identity         
 End      
      
      
 -- StateMaster      
Select @StateId = 0      
Select @StateId=Stateid From State WHere State = @State      
 If @StateID =0 and len(@State) <> 0      
 Begin      
   Insert Into State (State) Values (@State)      
   Set @Stateid=@@identity      
 End      
      
      
-- CountryMaster      
select @CountryId = 0      
Select @Countryid= Countryid From Country Where Country = @Country      
 If @CountryId=0 and len(@Country) <> 0      
 Begin      
   Insert into Country (Country) Values (@Country)      
   Set @Countryid=@@identity      
 End      
      
IF(@CanSaveBranch = 'Y')  -- Yes U can Save The Record      
  Begin      
 --Getting The AccountID      
    exec sp_acc_master_addaccount 6, 35, @wareHouse_Name, 0, ''      
    Set @AccountId = @@Identity       
       
 -- Insert The New Values Into WareHouse       
    Insert into WareHouse (WareHouseId,wareHouse_Name,Address,City,State,      
    Country,ForumId,Active,AccountId,Tin_Number) Values      
    (@WarehouseId,@Warehouse_Name,@Address,@CityId,@StateId,@CountryID,@forumId,1,@AccountId,@Tin_number)      
       
 -- Update wareHouse ID In 3 Tables.They Are      
  --(1)SRAbstractReceived      
  --(2)StockTransferOutAbstractReceived      
  --(3)Schemes_Rec      
       
    exec sp_update_WareHouse_ForumCode @ForumID,@WareHouseID      
  End      
      
IF(@CanSaveBranch = 'E')  -- Modify The Exsisting Record      
  Begin      
       
 -- Update the Values Into WareHouse       
    Update WareHouse Set Address = @Address,      
    City = @CityID , State = @StateID,      
    Country = @CountryID ,Tin_Number = @Tin_Number, StateInfo = @BranchStateID
    where WareHouseid = @WareHouseid And WareHouse_Name = @WareHouse_Name      
  End      
      
If (@CanSavebranch = 'Y')      
 Select 'Y',dbo.LookUpDictionaryItem(N'New Record Inserted',default)      
Else If (@CanSavebranch = 'E')      
 Select 'E',dbo.LookUpDictionaryItem(N'Existing Record  Modified',default)      
Else If (@CanSavebranch = 'N')      
 Select 'N',dbo.LookupDictionaryItem(N'Invalid Data.Either BranchId Or BranchName Or ForumID Already Exists Or Invalid StateInfo defined',default)      
    
    
  
  


