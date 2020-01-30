
Create Procedure sp_Get_Damage_Stock_DandD(@Claim_ID Int, @Cat_ID nvarchar(max))
As
Set dateformat dmy
Declare @Last_Close_Date Datetime
Declare @Delimiter Char(1)

/* For Damage Item Opening */
Declare @OpeningDate as datetime
Select Top 1 @OpeningDate=OpeningDate from Setup
Update Batch_Products Set DocDate=@OpeningDate Where Damage<>0 And isnull(DocDate,'')=''

Create Table #TmpBrand(BrandID Int)
Create Table #tmpOutput(Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS,ProductName nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
BrandID int,Quantity decimal(18,6),MultiBatch int)
--Create Table #DivItems(CategoryID int,Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS)
Create Table #DivItems(CategoryID int, Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
						Sub_Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
						Market_SKU nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
						Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS)


Set @Delimiter = ','


IF @Cat_ID = '0'	
	Insert Into #TmpBrand Select distinct CategoryID from ItemCategories where isnull(level,0)=2

Else
	Insert Into #TmpBrand Select * From dbo.sp_SplitIn2Rows(@Cat_ID, @Delimiter) 

	
Insert into #DivItems(CategoryID,Product_Code,Category,Sub_Category,Market_SKU)
select Distinct IC2.CategoryID,I.Product_code,IC2.Category_Name,IC3.Category_Name, IC4.Category_Name
from items I ,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2 where
IC4.categoryid = i.categoryid 
And IC4.Parentid = IC3.categoryid 
And IC3.Parentid = IC2.categoryid And IC2.CategoryId in (select BrandID from #TmpBrand)

IF @Claim_ID = 0
Begin
		Select @Last_Close_Date = Convert(Nvarchar(10),LastInventoryUpload,103) From Setup
		Insert into #tmpOutput(Product_Code,ProductName,BrandID,Quantity)
		Select 
			Items.Product_Code, Items.ProductName, D.CategoryID, Sum(isnull(BP.quantity,0)) As Damage_Quantity
		From 
			Batch_Products BP, Items, UOM,#DivItems D, Tax
		Where
			BP.Product_Code = Items.Product_Code
			And Items.UOM = UOM.UOM
		    And Items.Product_code=D.Product_code
			And Convert(Nvarchar(10),BP.DocDate,103) <= @Last_Close_Date
			And isnull(BP.Damage,0)<>0
			And isnull(BP.Free,0) = 0
			And Items.Sale_Tax = Tax.Tax_Code and isnull(Tax.GSTFlag,0) = 1
		Group By
		Items.Product_Code, Items.ProductName, UOM.Description, D.CategoryID,D.Category,D.Sub_Category,D.Market_SKU
		Having  Sum(isnull(BP.quantity,0))>0
		Order By D.Category,D.Sub_Category,D.Market_SKU,Items.Product_Code
		Select * from #tmpOutput
END
ELSE
BEGIN
		Select @Last_Close_Date = Convert(Nvarchar(10),DaycloseDate,103) From DandDabstract where id=@Claim_ID
		
		Insert into #tmpOutput(Product_Code,ProductName,BrandID,Quantity,multibatch)
		Select 
			Items.Product_Code, Items.ProductName, D.CategoryID, Sum(isnull(BP.quantity,0)) As Damage_Quantity,1
		From 
			batch_products BP, Items, UOM,#DivItems D, Tax
		Where
			BP.Product_Code = Items.Product_Code
			And Items.UOM = UOM.UOM
		    And Items.Product_code=D.Product_code
			And Convert(Nvarchar(10),BP.DocDate,103) <= @Last_Close_Date
			And isnull(BP.Damage,0)<>0
			And isnull(BP.Free,0) = 0
			And Items.Sale_Tax = Tax.Tax_Code and isnull(Tax.GSTFlag,0) = 1
		Group By
		Items.Product_Code, Items.ProductName, UOM.Description, D.CategoryID,D.Category,D.Sub_Category,D.Market_SKU
		Having  Sum(isnull(BP.quantity,0))>0
		Order By D.Category,D.Sub_Category,D.Market_SKU,Items.Product_Code

	/*As Per ITC, Batch popwindow should come for all items*/
--		Update T Set Multibatch=1 from #tmpOutput T ,
--		(Select Product_Code from #tmpOutput group by Product_Code having count(Product_Code)>1) T1
--		Where T.Product_code=T1.Product_code

		Select * from #tmpOutput
END
Drop Table #TmpBrand
Drop Table #DivItems
Drop Table #tmpOutput
