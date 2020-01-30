Create Procedure sp_get_CustQuotations_Item(@CustCode as nVarchar(50),@ItemCode as nVarchar(255))
As
	-- Multiple Quotation not handled
	Select Top 1 QAbs.QuotationId
	From QuotationAbstract QAbs, QuotationCustomers QCust,QuotationItems QItem
	Where QCust.CustomerID = @CustCode  
  And Active = 1 and QAbs.QuotationID = QItem.QuotationID and QItem.Product_Code=@Itemcode
  And Getdate() Between ValidFromDate and ValidToDate 
  And QAbs.QuotationId = QCust.QuotationId
