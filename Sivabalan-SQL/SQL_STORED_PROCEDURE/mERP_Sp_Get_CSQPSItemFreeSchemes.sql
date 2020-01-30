Create Procedure mERP_Sp_Get_CSQPSItemFreeSchemes(@CustID nVarchar(50), @SchList nVarChar(100)='', @InvoiceID Int = 0)
As
Begin
If @SchList <> ''
  Begin
  Declare @tmpPayout table (SchemeID Int, PayoutID Int, IsInvoiced Int Default 1)
  If @InvoiceID <> 0
  Insert into @tmpPayout
  Select Distinct SchemeID, PayoutID,1 From SchemeCustomerItems Where InvoiceRef = Cast(@InvoiceID as nVarchar(15))
   
  Select SchCust.SchemeID, SchAbs.Description, IsNull(SchCust.PayoutID,0), IsNull(SchCust.SlabID,0), SchCust.Product_code,  SchCust.Quantity
  From SchemeCustomerItems SchCust, tbl_merp_SchemeAbstract SchAbs, Items
  Where SchCust.CustomerID = @CustID And Items.Product_Code = SchCust.Product_code And 
      SchAbs.SchemeID = SchCust.SchemeID And
--      SchCust.Claimed = 0 And
      SchAbs.SchemeID in (Select * from dbo.Sp_SplitIn2Rows(@SchList, ',')) and 
      SchAbs.SchemeID not in (Select SchemeID From @tmpPayout)
  Union 
  Select SchCust.SchemeID, SchAbs.Description, IsNull(SchCust.PayoutID,0), IsNull(SchCust.SlabID,0), SchCust.Product_code,  SchCust.Quantity
  From SchemeCustomerItems SchCust, tbl_merp_SchemeAbstract SchAbs, Items, @tmpPayout tPayout
  Where SchCust.CustomerID = @CustID And Items.Product_Code = SchCust.Product_code And 
      SchAbs.SchemeID = SchCust.SchemeID And
      SchAbs.SchemeID = tPayout.SchemeID And
      (SchCust.PayoutID = tPayout.PayoutID OR
	   SchCust.PayoutID in (Select ID From tbl_merp_schemePayoutPeriod Where SchemeID = tPayout.SchemeID and IsNull(Status,0) & 128 = 0))
  Order by SchCust.SchemeID, IsNull(SchCust.PayoutID,0), IsNull(SchCust.SlabID,0)
  End
Else
  Begin
  Select SchCust.SchemeID, SchAbs.Description, IsNull(SchCust.PayoutID,0), IsNull(SchCust.SlabID,0), SchCust.Product_code,  SchCust.Pending
  From SchemeCustomerItems SchCust, tbl_merp_SchemeAbstract SchAbs, Items
  Where SchCust.CustomerID = @CustID And Items.Product_Code = SchCust.Product_code And 
      SchAbs.SchemeID = SchCust.SchemeID And 
      IsNull(SchCust.IsInvoiced,0) = 0 
--      SchCust.Claimed = 0
  Order by SchCust.SchemeID, IsNull(SchCust.PayoutID,0), IsNull(SchCust.SlabID,0) 
  End
End
