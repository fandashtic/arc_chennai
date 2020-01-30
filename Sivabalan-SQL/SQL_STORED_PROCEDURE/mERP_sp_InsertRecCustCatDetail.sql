  
CREATE Procedure [dbo].[mERP_sp_InsertRecCustCatDetail]    
 (@DocSerialID Int, @DivisionCode [nvarchar] (50), @Catgroup nvarchar(50)= '')    
AS    
  Insert Into tbl_mERP_RecdCatDetail(ID, Division,CategoryGroup,status)    
  Values (@DocSerialID, @DivisionCode, @Catgroup,0)    

