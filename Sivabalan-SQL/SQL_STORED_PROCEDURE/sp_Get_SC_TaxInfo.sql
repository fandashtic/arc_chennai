CREATE Procedure sp_Get_SC_TaxInfo(@CustomerID nvarchar(30), @ItemCode nvarchar(30),@TaxCode as int)
As
declare @TAXTYPE INT,@CUSTSUFF INT,@VAT INT,
	   @partoff decimal(18,6),@percentage decimal(18,6),@applicableon int
begin
	SELECT @TAXTYPE = LOCALITY FROM CUSTOMER WHERE CUSTOMERID =  @CUSTOMERID 
	SELECT @PARTOFF = ISNULL(CASE @TAXTYPE 
			WHEN 1 THEN TAX.LSTPARTOFF
			ELSE TAX.CSTPARTOFF END,0) ,
	       @APPLICABLEON =ISNULL(CASE @TAXTYPE 
			WHEN 1 THEN TAX.LSTAPPLICABLEON
			ELSE TAX.CSTAPPLICABLEON END,0), 
		  @percentage = ISNULL(CASE @TAXTYPE 
			WHEN 1 THEN TAX.percentage
			ELSE TAX.CST_percentage END,0)
			from Tax where tax.tax_code = @TaxCode

			select @partoff as partoff,@percentage as percentage,@applicableon as applicableon,
			ITEMS.ECP,ITEMS.PTR,ITEMS.PTS,ITEMS.COMPANY_PRICE
			from items WHERE  ITEMS.PRODUCT_CODE =  @ITEMCODE 
end



