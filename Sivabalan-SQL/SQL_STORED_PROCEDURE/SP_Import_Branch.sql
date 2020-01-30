CREATE Procedure [dbo].[SP_Import_Branch](    
@WareHouseID nvarchar(50),    
@WareHouse_Name nvarchar(100),    
@Address nvarchar(510),    
@City  nvarchar(100),    
@State  nvarchar(100),    
@Country nvarchar(100),    
@ForumID nvarchar(40),    
@TIN_Number nvarchar(20)=Null,
@BStateID Int = 0, 
@GSTIN nVarChar(15) = N''
)    
AS
Begin   
Declare @CityID Int    
Declare @StateId Int    
Declare @CountryId Int    
Declare @CanSaveBranch nVarchar(1)        
Declare @CountBranch int        
Declare @AccountID Int    
Set @CanSaveBranch='N'    --Invalid Record    
SET NOCOUNT ON    
Begin        
Select @CountBranch=Count(*) from Warehouse Where Warehouseid = @Warehouseid And Warehouse_Name =@wareHouse_Name And Forumid =@Forumid    
        
IF (@CountBranch =1)        
 Set @CanSaveBranch='E'     -- Exsisting Record    
Else        
 begin        
  Select @CountBranch=Count(*) from WareHouse Where Warehouseid = @Warehouseid or Warehouse_Name =@wareHouse_Name or Forumid = @Forumid    
  if(@CountBranch=0)        
  Set @CanSaveBranch='Y'     -- yes U Can Save Record    
  Else        
  Set @CanSaveBranch='N'     -- No u Cant Save This .Some Invalid data is Given         
 End        
End        
    
 -- CityMaster    
Select @cityID=0    
Select @CityID=CityId From City Where CityName=@City    
If @CityID = 0 And len(@City)<>0    
 begin    
   insert into City (CityName) Values (@City)    
   set @cityid=@@identity       
 end    
    
    
 -- StateMaster    
Select @StateId = 0    
Select @StateId=Stateid From State WHere State = @State    
 If @StateID =0 and len(@State) <> 0    
 Begin    
    Insert Into State (State) Values (@State)    
    Set @Stateid=@@identity    
 end    
    
    
-- CountryMaster    
select @CountryId = 0    
Select @Countryid= Countryid From Country Where Country = @Country    
 If @CountryId=0 and len(@Country) <> 0    
 Begin    
  Insert into Country (Country) Values (@Country)    
  set @Countryid=@@identity    
 end    
    
IF(@CanSaveBranch = 'Y')  -- Yes U can Save The Record    
  Begin    
 --Getting The AccountID    
 exec sp_acc_master_addaccount 6, 35, @wareHouse_Name, 0, ''    
 set @AccountId = @@Identity     
     
 -- Insert The New Values Into WareHouse     
 Insert into WareHouse (WareHouseId,wareHouse_Name,Address,City,State,    
 Country,ForumId,Active,AccountId,Tin_Number,[BillingStateID], [GSTIN] ) Values    
 (@WarehouseId,@Warehouse_Name,@Address,@CityId,@StateId,@CountryID,@forumId,1,@AccountId,    
 @Tin_number,@BStateID ,@GSTIN )    
     
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
  Country = @CountryID ,Tin_Number = @Tin_Number ,
  [BillingStateID]=@BStateID , [GSTIN] = @GSTIN  
        where WareHouseid = @WareHouseid And WareHouse_Name = @WareHouse_Name    
     
  End    
    
If (@CanSavebranch = 'Y')    
 Select 'Y',dbo.LookUpDictionaryItem(N'New Record Inserted',default)    
Else If (@CanSavebranch = 'E')    
 Select 'E',dbo.LookUpDictionaryItem(N'Existing Record  Modified',default)    
Else If (@CanSavebranch = 'N')    
 Select 'N',dbo.LookupDictionaryItem(N'Invalid Data.Either BranchId Or BranchName or ForumID  Already Exists',default)    
End
