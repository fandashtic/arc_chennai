Create Procedure mERP_sp_ProcessCatgoryDefn (@ID nVarchar(255))  
As  
  
Declare @CatGrpCode nVarchar(255)  
Declare @Category nVarchar(255)  
Declare @GrpName nVarchar(255)  
Declare @Active int  
Declare @SlNo int  
  
Declare @ErrStatus int  
Declare @KeyValue nVarchar(255)  
Declare @Errmessage nVarchar(4000)  
  
Declare @mapidcnt int  
Set @ErrStatus = 0  
  
Declare CatGrpCursor Cursor for   
Select   CatGrpcode, Category, GroupName, Active, ID  
from tbl_mERP_RecdCGDefnDetail  
where RecdID = @ID and IsNull(status,0) = 0  
  
Open CatGrpCursor  
Fetch From CatGrpCursor Into @CatGrpCode, @Category, @GrpName, @Active, @SlNo  
  
While @@Fetch_Status = 0    
Begin   
  
Set @ErrStatus = 0  
select @mapidcnt =isnull(MAX(mapid),0) +1  from tblCGDivMapping     
  
If (Isnull(@Category,'') = '')   
Begin  
 Set @Errmessage = 'Category should not be Null'  
 Set @ErrStatus = 1  
 Goto last  
End  
  
If (Isnull(@GrpName,'') = '')   
Begin  
 Set @Errmessage = 'GroupName should not be Null'  
 Set @ErrStatus = 1  
 Goto last  
End  


If (IsNull(@Active, 0) > 1)
Begin
	Set @Errmessage = 'Active Column Value should be 0 or 1'
	Set @ErrStatus = 1
	Goto last
End

  
/*If (select count(*) from itemcategories where category_name = @Category and level=2) = 0  
Begin  
  -- select Message from ErrorMessages where ErrorID=149  
 Set @Errmessage = 'Division Not exists in ItemCategories table'  
 Set @ErrStatus = 1  
 Goto last  
End*/

 
--If (Select Count(*) from ProductCategoryGroupabstract where GroupName = @Grpname) = 0  
--Begin  
-- Insert Into ProductCategoryGroupabstract(GroupName, GroupCode, Active) Values(@Grpname, @CatGrpCode, @Active)  
--End  
--Else
--begin
--	Update ProductCategoryGroupabstract Set GroupCode = @CatGrpCode, Active = @Active where GroupName = @Grpname
--End

  

If ( Select Count(*) from ProductCategoryGroupabstract where GroupCode = @CatGrpCode ) = 0  
Begin  
	If (Select Count(*) from ProductCategoryGroupabstract where GroupName = @Grpname) = 0
		Insert Into ProductCategoryGroupabstract(GroupName, GroupCode, Active) Values(@Grpname, @CatGrpCode, @Active)  
--	Else
--		Begin  
--			Set @Errmessage = 'GroupName Exist in Master table'  
--			Set @ErrStatus = 1  
--			--Goto last  
--		End 
End  
Else
begin
	Update ProductCategoryGroupabstract Set GroupName = @Grpname, Active = @Active where GroupCode = @CatGrpCode
End

 
If ( Select Count(*) from tblCGDivMapping where Division = @Category) = 0  
Begin  
 Insert Into tblCGDivMapping(MapID, Division, CategoryGroup)  
 Values(@mapidcnt, @Category, @Grpname)  
End  
Else  
Begin  
 Update tblCGDivMapping Set CategoryGroup = @Grpname where division = @Category  
End  
 
 -- Status Updation  
 Update tbl_mERP_RecdCGDefnAbstract Set Status = 1 Where RecdID = @ID  
 Update tbl_mERP_RecdCGDefnDetail Set Status = 1  Where ID = @SlNo  and RecdID = @ID  
  
  
Last:  
 -- Error Log Written and Status Updation of rejected Detail   
 If (@ErrStatus = 1)  
 Begin  
  Set @KeyValue = ''  
  Set @Errmessage = 'CategoryGroupDefintion:- ' +  ' ' + Convert(nVarchar(4000), @Errmessage)
  Set @KeyValue = Convert(nVarchar, @ID) + '|' + Convert(nVarchar,@SlNo)  
  Update tbl_mERP_RecdCGDefnDetail Set Status = 2  Where ID = @SlNo  and RecdID = @ID  
  Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
  Values('MastersConfig', @Errmessage,  @KeyValue, getdate())    
 End  
  
Fetch Next From CatGrpCursor Into @CatGrpCode, @Category, @GrpName, @Active, @SlNo  
End  
  
Close CatGrpCursor  
DeAllocate CatGrpCursor  
  
