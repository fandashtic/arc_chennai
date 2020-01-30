Create procedure SP_Get_DandDItems @ID int  
AS  
BEGIN  
	--Create Table #temp(Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,	Category int)
	
	Create Table #temp(Product_Code nvarchar(30) Collate SQL_Latin1_General_CP1_CI_AS, Category int, 
					CategoryName nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
					Sub_Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
					Market_SKU nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)	

	Insert Into #temp(Product_Code, Category, CategoryName, Sub_Category, Market_SKU)
	Select Distinct I.Product_Code, IC1.CategoryID, IC1.Category_Name, IC2.Category_Name, IC3.Category_Name
	From
		ItemCategories IC1, ItemCategories IC2, ItemCategories IC3, Items I
	Where
		IC1.CategoryID = IC2.ParentID
		And IC2.CategoryID = IC3.ParentID 
		And IC1.Level = 2
		And I.CategoryID = IC3.CategoryID
	Order By
		I.Product_Code, IC1.CategoryID

	--READY FOR DESTROY  
	Declare @MultiBatch  int
	If (Select claimstatus from DandDAbstract where ID =@ID) in (1)  
	BEGIN  

		Select D.Product_Code,I.ProductName,max(T.Category) as Category, Batch_Number, sum(D.TotalQuantity) as TotalQuantity,D.PTS   
		into #tmpDet	  
		from DandDDetail D,Items I,#temp T where T.Product_code=I.Product_code And ID=@ID And  
		I.Product_code=D.Product_code  
		Group by D.Product_Code,I.ProductName,I.BrandID, Batch_Number,D.PTS
		Order by I.ProductName  

		Select a.Product_Code, a.ProductName, max(a.Category), Sum(a.TotalQuantity), 1 as multibatch
		From #tmpDet a, #temp b
		Where a.Product_Code = b.Product_Code
		Group by a.Product_Code, a.ProductName, b.CategoryName, b.Sub_Category, b.Market_SKU
		--Order by ProductName
		Order By b.CategoryName, b.Sub_Category, b.Market_SKU, a.Product_Code
		Drop Table #tmpDet  
 END  
 ELSE  
 BEGIN  
		Select D.Product_Code, I.ProductName, max(T.Category) as Category, D.Batch_Number, sum(D.TotalQuantity) as TotalQuantity,1 as multibatch,
		max(D.UOM) as UOM, sum(D.RFAQuantity) as RFAQuantity, sum(TaxAmount) as TaxAmount, Sum(TotalAmount) as TotalAmount, max(SalvageQuantity) as SalvageQuantity,  
		Max(D.SalvageUOM) as SalvageUOM, max(SalvageUOMRate) as SalvageRate, max(SalvageUOMValue) as SalvageValue  
		, Sum(UOMTotalQty) as UOMTotalQty, Sum(UOMRFAQty) as UOMRFAQty, max(SalvageUOMQuantity) as SalvageUOMQuantity,isnull(D.PTS,0) as PTS,max(isnull(UOMTaxAmount,0)) as UOMTaxAmount,Max(isnull(UOMTotalAmount,0)) as UOMTotalAmount
		into #tmpDet1
		from DandDDetail D,Items I,#temp T where T.Product_code=I.Product_code And ID=@ID And  
		I.Product_code=D.Product_code  
		Group by D.Product_Code,I.ProductName, D.Batch_Number,D.PTS
		Order by I.ProductName

		Alter Table #tmpDet1 Add UOMDesc nvarchar(256) Collate SQL_Latin1_General_CP1_CI_AS
		Alter Table #tmpDet1 Add SalvageUOMDesc nvarchar(256) Collate SQL_Latin1_General_CP1_CI_AS

		Alter Table #tmpDet1 Add BaseUOM Int

		Update T set UOMDesc=UOM.Description from #tmpDet1 T,UOM where UOM.UOM=T.UOM
		Update T set SalvageUOMDesc=UOM.Description from #tmpDet1 T,UOM where UOM.UOM=T.SalvageUOM

/*As Per ITC, Batch popwindow should come for all items*/

--		Update T Set Multibatch=1 from #tmpDet1 T ,
--		(Select Product_Code from #tmpDet1 group by Product_Code having count(Product_Code)>1) T1
--		Where T.Product_code=T1.Product_code

--		Select Product_Code,PTS,TaxSuffered into #tmp  from DandDDetail where ID=@ID and isnull(batch_number,'')='' group by Product_Code,PTS,TaxSuffered
--
--		Update T Set Multibatch=1 from #tmpDet1 T ,
--		(Select product_code,count(product_code) as Prodcount from #tmp Group by product_code having count(product_code)>1) T1
--		Where T.Product_code=T1.Product_code
--		And T.Multibatch=0
--		Drop Table #tmp

		Select a.Product_Code, a.ProductName, max(a.Category), sum(TotalQuantity) As TotalQuantity, 1 as multibatch
		,max(UOM) as UOM, sum(RFAQuantity) as RFAQuantity, sum(TaxAmount) as TaxAmount, Sum(TotalAmount) as TotalAmount, max(SalvageQuantity) as SalvageQuantity,  
		Max(SalvageUOM) as SalvageUOM, Max(SalvageRate) as SalvageRate, Max(SalvageValue) as SalvageValue  
		,Sum(UOMTotalQty) as UOMTotalQty, Sum(UOMRFAQty) as UOMRFAQty, max(SalvageUOMQuantity) as SalvageUOMQuantity,UOMDesc,max(UOMTaxAmount) as UOMTaxAmount,Max(UOMTotalAmount) as UOMTotalAmount,SalvageUOMDesc
		From #tmpDet1 a, #temp b
		Where a.Product_Code = b.Product_Code
		Group by a.Product_Code, a.ProductName, UOMDesc,multibatch,SalvageUOMDesc, b.CategoryName, b.Sub_Category, b.Market_SKU
		--Order by ProductName
		Order By b.CategoryName, b.Sub_Category, b.Market_SKU, a.Product_Code
		Drop Table #tmpDet1
 END  
Drop Table #temp

END  
