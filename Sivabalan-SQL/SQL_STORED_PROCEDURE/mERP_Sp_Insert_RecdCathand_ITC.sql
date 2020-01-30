Create  Procedure [dbo].[mERP_Sp_Insert_RecdCathand_ITC]          
(
	@ChannelDocSerial Int,
    @CustomerID Nvarchar(50),     
    @CategoryName Nvarchar(50)	
)
AS          
  Declare @CatID int 
  Begin Tran PortCCD          
  select @CatID=CategoryID from itemcategories where category_name=@CategoryName 
--Check For Customer code exists or not  
  If UPPER(@CategoryName)<>'ALL'    
  BEGIN     
    --DELETE FROM  CustomerProductCategory WHERE CUSTOMERID=@CustomerID
    Insert into CustomerProductCategory (CustomerID,CategoryID,Active) 
    Select RR.CustomerID,@CatID,1
    From tbl_mERP_RecdCatHandDetail RR,tbl_mERP_RecdCatHandAbstract RCC      
    Where RR.ID = RCC.ID          
    AND RR.Categoryname=@CategoryName and 
    RR.ID=@ChannelDocSerial
    and RR.customerid=@CustomerID     
  END

  If UPPER(@CategoryName)='ALL'    
  BEGIN   
  --Delete from customerproductcategory where CustomerID =@CustomerID  
  Insert into CustomerProductCategory (CustomerID,CategoryID,Active)   
  select @CustomerID,categoryid,1 from itemcategories where active=1
  and  level in(2,3)
  END   
 
 If @@Error = 0           
 Begin          
  Update tbl_mERP_RecdCatHandDetail Set Status = 32 Where id=@ChannelDocSerial and customerid=@CustomerID and categoryname=@CategoryName     
  Commit Tran PortCCD          
  Goto TheEnd          
 End          
Else           
 RollBack Tran PortCCD          
TheEnd:         
