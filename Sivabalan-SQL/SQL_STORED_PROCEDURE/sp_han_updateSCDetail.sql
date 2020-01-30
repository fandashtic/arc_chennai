CREATE procedure sp_han_updateSCDetail(@OrderNUmber as nvarchar(50), @Status as int = 1,@grpSalesmanID as Int)    
as    
begin
		 Declare @NoRecs as Integer   
		 Declare @GroupID as nvarchar(1000) 
	 
		 --Updating Order_details based on Grouped Salesman
		 select @GroupID=dbo.fn_han_Get_ItemGroup(@OrderNUmber,@grpSalesmanID)
		 Update OD set OD.processed=@Status from order_details OD
		 inner join (Select Product_Code from dbo.sp_Get_Items_ITC(@GroupID)) GI 
		 on isnull(@GroupID,'')<> '' and GI.Product_Code=OD.Product_Code
		 where OD.ORDERNUMBER = @OrderNUmber
		 --End Updating Order_details based on Grouped Salesman
		 
		 Set @NoRecs = @@RowCount
		 Select @NoRecs 'rowcnt' 
end
