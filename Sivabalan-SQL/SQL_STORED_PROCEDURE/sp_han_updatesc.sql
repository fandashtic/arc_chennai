Create procedure sp_han_updatesc(@OrderNUmber as nvarchar(50), @Status as int = 1)    
as
 Declare @NoRecs as Integer 
 Update Order_Header set Processed = @Status Where ORDERNUMBER = @OrderNUmber
 Set @NoRecs = @@RowCount 

-- To Update the SchemeID_HH, GroupID, ID_split_flag Columns in Scheme_Details table
 Exec sp_han_UpdateScheme_Details @OrderNUmber,@Status
-- To Update the SchemeID_HH, GroupID, ID_split_flag Columns in Scheme_Details table

 update order_details set Processed = 2 where  ORDERNUMBER = @OrderNUmber and Processed<>1 
    
 If @NoRecs <> 0 and @Status = 1     
 Begin     
  Insert Into Order_Header_Copy    
  (OrderNumber, Order_Date, Delivery_Date    
  , Salesmanid, Outletid, Profitcenter,Processed,CreationDate)    
  Select OrderNumber, Order_Date, Delivery_Date    
   , Salesmanid, Outletid, Profitcenter,Processed,GETDATE() from Order_Header    
  where OrderNumber = @OrderNumber    
     
  Insert Into Order_Details_Copy    
  (OrderNumber, Product_Code, OrderedQty, UOMID)    
   Select OrderNumber, Product_Code, OrderedQty, UOMId     
   from Order_Details    
  where OrderNumber = @OrderNumber    
    
  Insert Into Scheme_Details_Copy    
  ( OrderNumber, OrderedProductCode, OrderedItemUOMID, OrderedQty  
  , FreeProductCode, FreeItemQty, FreeItemUOMID, SchemeID )    
  Select OrderNumber, OrderedProductCode, OrderedItemUOMID, OrderedQty  
  , FreeProductCode, FreeItemQty, FreeItemUOMID, SchemeID from Scheme_Details    
  where OrderNumber = @OrderNumber    
  --IF free item exists for a order then free item rows (even if duplicate exists) should not be deleted   
  --from scheme_details for the order  
  select distinct * into #TempSchemes from  scheme_details where ORDERNUMBER = @OrderNUmber and ISNULL(SchemeID,0) <> 0   
  delete from scheme_details  where ORDERNUMBER = @OrderNUmber and ISNULL(SchemeID,0) <> 0   
  insert into scheme_details select * from  #TempSchemes  where ORDERNUMBER = @OrderNUmber    
  Drop table #TempSchemes   
--new 26/08/09
update sa set sa.SupervisorID=TOH.supervisor_id from soabstract sa inner join 
(select distinct OD.SaleOrderid as SaleOrderid,OH.supervisor_id as supervisor_id from order_header OH inner join Order_details OD on OH.ordernumber=OD.ordernumber where OH.ORDERNUMBER = @OrderNUmber ) TOH
on sa.SONumber=TOH.SaleOrderid 
--end 26/08/09 
 End    
 Select @NoRecs 'rowcnt'       

