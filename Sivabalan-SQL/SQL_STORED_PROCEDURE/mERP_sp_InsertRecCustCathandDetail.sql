CREATE Procedure [dbo].[mERP_sp_InsertRecCustCathandDetail]    
 (@DocSerialID Int, @CustomerID [nvarchar] (50), @Categoryname nvarchar(100)= '')    
AS    
  Insert Into tbl_mERP_RecdCatHandDetail (ID, CustomerID,CategoryName,status)    
  Values (@DocSerialID, @CustomerID,@Categoryname,0)      

