Create Procedure sp_get_CustQuotations 
	@CustCode as nVarchar(50)
As
	-- Multiple Quotation not handled
	Select QAbs.QuotationId
	From QuotationAbstract QAbs, QuotationCustomers QCust
	Where QCust.CustomerID = @CustCode
  And Active = 1 
  And Getdate() Between ValidFromDate and ValidToDate 
  And QAbs.QuotationId = QCust.QuotationId
