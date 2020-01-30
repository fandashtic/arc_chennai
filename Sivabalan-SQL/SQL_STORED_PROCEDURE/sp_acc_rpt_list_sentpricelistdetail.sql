CREATE procedure sp_acc_rpt_list_sentpricelistdetail (@Details nvarchar(4000))
as
Declare @ProductHierarchy nVarchar(250)
Declare @Category nVarchar(250)
Declare @DocumentID Int

Create table #Info
(
	RowNum int Identity(1,1),
	Details nvarchar(4000)
)

insert into #info
exec sp_acc_sqlsplit @details,N'€'

Select @ProductHierarchy 	= Details from #info where RowNum = 1
Select @Category   			= Details from #info where RowNum = 2
Select @DocumentID 			= Details from #info where RowNum = 3


Create Table #tempCategory
(CategoryID int,Status int)
Exec dbo.GetLeafCategories @ProductHierarchy, @Category

Select 
SPLI.Product_Code as 'Item Code',
I.ProductName as 'Item Name',
SPLI.PTS as 'PTS',
SPLI.PTR as 'PTR',
SPLI.ECP as 'ECP',
SPLI.PurchasePrice as 'PP',
SPLI.SellingPrice as 'SP',
SPLI.MRP as 'MRP',
SPLI.SpecialPrice as 'SP Price',
isnull((Select Tax_Description from Tax where Tax_Code = SPLI.TaxSuffered),N'') as 'Tax_Suffered',  
isnull((Select Tax_Description from Tax where Tax_Code = SPLI.TaxApplicable),N'') as 'Tax_Applicable'  
From 
SendPriceList SPL,SendPriceListItem SPLI,Items I
Where 	
SPL.DocumentID = @DocumentID and
SPL.DocumentID = SPLI.DocumentID and
SPLI.Product_code = I.Product_code and 
SPLI.Product_Code in 
(select Product_code from items where categoryid In (Select CategoryID From #tempCategory))
Drop Table #Info




