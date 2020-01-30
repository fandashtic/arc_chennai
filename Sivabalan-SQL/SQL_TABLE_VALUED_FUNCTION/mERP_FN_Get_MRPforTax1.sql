Create function [dbo].[mERP_FN_Get_MRPforTax1]()
Returns @Product Table(Product_code nvarchar(15),MRPForTax decimal(18,6))
AS
Begin
	Declare @Temp Table (Product_code nvarchar(15),Batch_code int)
	insert into @Temp(Product_code,Batch_code)
	Select Product_code,max(Batch_code) from batch_products 
	Group by Product_code
	--To insert items which don't have Batch details
	Insert Into @Temp(Product_code,Batch_code) select Product_code,0 from Items where Product_code not in (select Product_code from @Temp)

	insert into @Product(Product_code,MRPForTax)
	Select T.Product_code,isnull(B.MRPForTax,0)as MRPForTax 
	from Batch_products B right outer join @Temp T on B.Product_code=T.Product_code And B.Batch_code=T.Batch_code
	Return
END
