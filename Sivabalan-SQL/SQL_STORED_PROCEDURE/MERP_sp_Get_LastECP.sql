Create Procedure MERP_sp_Get_LastECP
(
@CustID nVarChar(15),
@ItemCode nVarChar(15)
)
As
	--Select Top 1 Max(InvoiceID),SalePrice From InvoiceDetail
	--Where
	--InvoiceID in (Select InvoiceID from InvoiceAbstract where CustomerID =@CustID)
	---- And 
	---- InvoiceID In (Select Distinct InvoiceID From InvoiceDetail where product_code = @ItemCode)
	--And Product_Code = @ItemCode
	--Group by SalePrice Order by 1 desc , 2 desc
	Select 0,0

