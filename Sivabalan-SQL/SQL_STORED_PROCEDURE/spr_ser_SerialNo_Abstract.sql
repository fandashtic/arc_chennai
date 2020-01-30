
CREATE Procedure spr_ser_SerialNo_Abstract
		(@SerialNo nVarchar(4000),
		 @PRODUCT_HIERARCHY Varchar(4000),
	         @CATEGORY NVARCHAR(4000),  
		 @ITEMCODE NVARCHAR(4000),
		 @FROMDATE DATETIME,  
		 @TODATE DATETIME)
AS  


-- for splitting multiple Parameters...
DECLARE @Delimeter as Char(1)    
SET @Delimeter=Char(15) 

Create Table #TmpSerial(SerialSp Nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #TmpHierarchy(Hierarchy_Name NVarChar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #TmpCategory(Category_Name NVarChar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #TmpItem(Item_Code NVarChar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)

If @SerialNo = '%' 
	Insert Into #TmpSerial Select Product_Specification From ItemserialSpecifications
Else
	Insert Into #TmpSerial Select * From DBO.sp_SplitIn2Rows(@SerialNo,@Delimeter)

If @Product_Hierarchy = '%' 
	Insert Into #TmpHierarchy Select HierarchyName From ItemHierarchy
Else
	Insert Into #TmpHierarchy Select * From DBO.sp_SplitIn2Rows(@Product_Hierarchy,@Delimeter)

If @ItemCode = '%' 
	Insert Into #TmpItem Select Product_Code From Items
Else
	Insert Into #TmpItem Select * From DBO.sp_SplitIn2Rows(@ItemCode,@Delimeter)

IF @Category ='%'
	Insert into #TmpCategory Select Category_Name from ItemCategories
Else
	Insert into #TmpCategory Select * From dbo.Sp_SplitIn2Rows(@CATEGORY, @Delimeter)




Select ISS.Product_Specification,ISS.Product_Specification as 'Serial No', 
((Select Prefix from VoucherPrefix Where TranID = 'INVOICE') + cast(INA.DocumentID as Varchar)) as 'Invoice ID', 
INA.NetValue as 'Invoice Value', INA.InvoiceDate as 'Invoice Date', 
INA.CustomerID as 'Cust Code', CUS.Company_Name as 'Customer Name',
IND.Product_Code as 'Item Code', ITM.ProductName as 'Item Name', 
IsNull(IND.SalePrice, 0) as 'Sale Price', TX.Percentage 'Tax %', IsNull(IND.TaxAmount, 0) as 'Tax Value',
Isnull(IND.DiscountValue, 0) as 'Discount'

From

InvoiceAbstract INA, InvoiceDetail IND, ItemSerialSpecifications ISS,
Customer CUS, Tax TX, Items ITM, ItemCategories IC, ItemHierarchy HC

Where 

(INA.InvoiceDate Between @FROMDATE and @TODATE) And
INA.Status & 192 =  0 And 	-- to get the opened invoice...
IND.Product_Code in (Select Item_Code from #TmpItem) And
HC.HierarchyName in (Select Hierarchy_Name from #TmpHierarchy) And
IC.Category_Name in (Select Category_Name from #TmpCategory) And
ISS.Product_Specification in (Select SerialSp from #TmpSerial) And
INA.InvoiceID = IND.InvoiceID And
IND.InvoiceID = ISS.InvoiceID And
INA.CustomerID = CUS.CustomerID And
IND.TaxID = TX.Tax_Code And
IND.Product_Code = ITM.Product_Code And
HC.HierarchyID = IC.Level And
ITM.CategoryID = IC.CategoryID

