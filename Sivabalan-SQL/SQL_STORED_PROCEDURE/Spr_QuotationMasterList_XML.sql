CREATE PROCEDURE Spr_QuotationMasterList_XML(@CustomerID nvarchar(2550), @FromDate DateTime, @ToDate DateTime)    
AS
Begin
Declare @Delimeter as Char(1)  
Declare @YES As NVarchar(50)  
Declare @NO As NVarchar(50)  
Set @YES = dbo.LookupDictionaryitem(N'Yes', Default)  
Set @NO = dbo.LookupDictionaryitem(N'No', Default)  

Declare @ITEMWISE As NVarchar(50)  
Declare @CATEGORYWISE As NVarchar(50)  
Declare @MANUFACTURERWISE As NVarchar(50)  
Declare @UNIVERSALDISCOUNT  As NVarchar(50)    
Set @ITEMWISE = dbo.LookupDictionaryitem(N'Itemwise', Default)  
Set @CATEGORYWISE = dbo.LookupDictionaryitem(N'Categorywise', Default)  
Set @MANUFACTURERWISE = dbo.LookupDictionaryitem(N'Manufacturerwise', Default)  
Set @UNIVERSALDISCOUNT = dbo.LookupDictionaryitem(N'Universal Discount', Default)  
  
Declare @KeyAcc as nVarChar(25)
Declare @Wholesale as nVarChar(25)
Declare @Others as nVarChar(25)

Set @KeyAcc = dbo.LookupDictionaryitem(N'Key Account', Default)  
Set @Wholesale = dbo.LookupDictionaryitem(N'Wholesale', Default)  
Set @Others = dbo.LookupDictionaryitem(N'Others', Default)  

Declare @CATEGORY As NVarchar(50)
Declare @MANUFACTURER As NVarchar(50)
Declare @ECP As NVarchar(50)
Declare @PURCHASE  As NVarchar(50)
Declare @MRP As NVarchar(50)
Declare @SALEPRICE As NVarchar(50)

Set @CATEGORY = dbo.LookupDictionaryItem(N'Category', Default)
Set @MANUFACTURER = dbo.LookupDictionaryItem(N'Manufacturer', Default)
Set @ECP = dbo.LookupDictionaryItem(N'ECP', Default)
Set @PURCHASE = dbo.LookupDictionaryItem(N'Purchase', Default)
Set @MRP = dbo.LookupDictionaryItem(N'MRP', Default)
Set @SALEPRICE = dbo.LookupDictionaryItem(N'SALEPRICE', Default)

Declare @WDCode NVarchar(255)    
Declare @WDDest NVarchar(255)    
Declare @CompaniesToUploadCode NVarchar(255)    


Declare @DayClosed Int
Select @DayClosed = 0
IF (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
Begin
	IF ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(@TODATE))
		Set @DayClosed = 1
End

IF @DayClosed = 0
	GoTo OvernOut

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  
Select Top 1 @WDCode = RegisteredOwner From Setup  

If @CompaniesToUploadCode = N'ITC001'
	Set @WDDest= @WDCode  
Else  
  Begin  
	Set @WDDest= @WDCode  
	Set @WDCode= @CompaniesToUploadCode  
  End      
 
--Set @Delimeter=Char(15)      
--Declare @tmpCustomer table(Customer_ID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
--if @CustomerID='%'       
   --Insert into @tmpCustomer select CustomerID from Customer      
--Else      
--   Insert into @tmpCustomer select * from dbo.sp_SplitIn2Rows(@CustomerID,@Delimeter)      
Create Table #XMLData(XMLStr nVarchar(Max))

Declare @RepAbs_ID Int
Declare @QuotID Int
Declare @PreQuotID Int
DECLARE @QuotationType INT        

Create Table #TmpAbs(RepAbsID Int Identity(1,1), 
_1   nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,_2  nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
_3   nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,_4  nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
_5   nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,_6  nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
_7   nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,_8  nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
_9   nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,_10 nvarchar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,
_11 nvarchar(150)COLLATE SQL_Latin1_General_CP1_CI_AS,_12 nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
_13 nvarchar(10)COLLATE SQL_Latin1_General_CP1_CI_AS,_14 nvarchar(10)COLLATE SQL_Latin1_General_CP1_CI_AS,
_15 nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,QuotID Int,QuotationType Int,_17 nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #tmpQuotIDs (QuotIDs Int)

Insert into #tmpQuotIDs (QuotIDs)
Select Distinct ID.QuotationID 
From InvoiceAbstract IA 
Join InvoiceDetail ID On ID.InvoiceID = IA.InvoiceID And IsNull(ID.QuotationID,0) > 0
Where IA.InvoiceType in (1,3) And IA.Status &128 = 0 
And  IA.InvoiceDate  BETWEEN @FromDate AND @ToDate 

Insert Into #TmpAbs 
Select "WD Code"=@WDCode, "WD Dest"=@WDDest,"FromDate" = @FromDate, "ToDate"=dbo.Striptimefromdate(@ToDate),
"Quotation Name" = QA.QuotationName, 
"Quotation Date" = (Convert(varchar(10), QA.CreationDate, 103)+ ' ' + Convert(varchar(10), QA.CreationDate, 108)),  --"Quotation Date" = QA.QuotationDate,     
"Valid From Date" = QA.ValidFromDate, "Valid To Date" = dbo.Striptimefromdate(QA.ValidToDate),
"Type" = Case QA.QuotationLevel WHEN 1 THEN @ITEMWISE WHEN 2 THEN @CATEGORYWISE WHEN 3 THEN @MANUFACTURERWISE  ELSE @UNIVERSALDISCOUNT  END,     
"CustomerID" = QC.CustomerID, "Customer Name" = C.Company_Name, 
"Customer Channel Type" = OLCls.Channel_Type_Desc,     --CC.ChannelDesc ,
"Active" = Case QA.Active WHEN 1 THEN @YES ELSE @NO END,
"Special Tax" = Case When QA.SpecialTax = 1 Then @YES Else @NO End,
"Quotation Type" = Case When QA.QuotationType = 1 Then @KeyAcc When QA.QuotationType = 2 Then @Wholesale When QA.QuotationType = 3 Then @Others Else N'' End,
"Quotation ID" = QA.QuotationID,
"QuotationType" = QA.QuotationLevel
, "Last Modified Date" = (Convert(varchar(10), QA.LastModifiedDate, 103)+ ' ' + Convert(varchar(10), QA.LastModifiedDate, 108))
From QuotationAbstract QA
Join QuotationCustomers QC On QC.QuotationID = QA.QuotationID 
Join Customer C On C.CustomerID = QC.CustomerID And C.CustomerID in (select CustomerID from Customer)
--Join Customer_Channel CC On CC.ChannelType = C.ChannelType And CC.ChannelDesc Not In ('WD')
Join tbl_mERP_OLClassMapping OLClsM On OLClsM.CustomerID = C.CustomerID And OLClsM.Active = 1
Join tbl_mERP_OLClass OLCls On OLCls.ID = OLClsM.OLClassID And OLCls.Channel_Type_Desc Not In ('WD')
Where QA.QuotationType Not In  (4)  And QA.QuotationLevel in (1,2) 
And ( 
( ( ( @FromDate Between QA.ValidFromDate  And QA.ValidToDate) Or (@ToDate Between QA.ValidFromDate  And QA.ValidToDate   )) And QA.Active = 1) OR 
(Qa.QuotationID in (Select  Quotids from #tmpQuotIDs)) 
)
Order  by QA.QuotationID

Drop Table #tmpQuotIDs 

Set @PreQuotID = 0

Declare RepAbs Cursor for Select RepAbsID,QuotID,QuotationType From #TmpAbs

    Open RepAbs
    Fetch Next From RepAbs Into @RepAbs_ID,@QuotID,@QuotationType
    While @@Fetch_Status = 0
    Begin
		
		Insert Into #XMLData 			
		Select 
		'Abstract _1="' + ISNULL(_1,'') +
		+ '" _2="' + ISNULL(_2,'') +
		+ '" _3="' + ISNULL(_3,'') +
		+ '" _4="' + ISNULL(_4,'') +
		+ '" _5="' + ISNULL(_5,'') +
		+ '" _6="' + ISNULL(_6,'') +
		+ '" _7="' + ISNULL(_7,'') +
		+ '" _8="' + ISNULL(_8,'') +
		+ '" _9="' + ISNULL(_9,'') +
		+ '" _10="' + ISNULL(_10,'') +
		+ '" _11="' + ISNULL(_11,'') +
		+ '" _12="' + ISNULL(_12,'') +
		+ '" _13="' + ISNULL(_13,'') +
		+ '" _14="' + ISNULL(_14,'') +
		+ '" _15="' + ISNULL(_15,'') +
		+ '" _16="' + Cast(IsNull(QuotID,0) as nVarChar) + 
		+ '" _17="' + ISNULL(_17,'') + '"'
		From #TmpAbs
		Where  RepAbsID = @RepAbs_ID
		
		If @QuotID <> @PreQuotID
		Begin			
			IF @QuotationType = 1
				Insert Into #XMLData 
				Select  
				'Detail _18="' + IsNull(QI.Product_Code,'') + '" _19="' + IsNull(Item.ProductName,'') + '" _20="' + IsNull(U.Description,'') +
				'" _21="' + Cast(IsNull(QI.PurchasePrice,0) As nVarChar) + 
				'" _22="' + Cast(IsNull(QI.SalePrice,0) As nVarChar) +
				'" _23="' + CAST(IsNull(QI.ECP,0) As nVarChar) +
				'" _24="' + IsNull(CASE QI.MarginOn WHEN 1 THEN @ECP WHEN 2 THEN	@PURCHASE WHEN 3 THEN	@MRP When 4 Then @SALEPRICE END,'') +
				'" _25="' + Cast(IsNull(QI.MarginPercentage,0) As nVarChar)  +
				'" _26="' + Cast(IsNull(QI.RateQuoted,0) As nVarChar) +
				'" _27="' + Cast(IsNull((Select Top 1 LSTTax.Percentage From Tax LSTTax Where LSTTax.Tax_Code = QI.QuotedTax),0) As nVarChar) + 
				'" _28="' + Cast(IsNull((Select Top 1 SplTax.Percentage From Tax SplTax Where SplTax.Tax_Code = QI.Quoted_LSTTax),0) As nVarChar) +
				'" _29="' + Cast(IsNull(QI.QuotationID,0) As nVarChar) + '"'
				From QuotationItems QI
				Join Items Item On Item.Product_Code = QI.Product_Code 
				Join UOM U On U.UOM = Item.UOM 	
				Where QI.QuotationID  = @QuotID
			Else IF @QuotationType = 2
				Insert Into #XMLData 			
				Select  
				'Detail _18="' + IsNull(ItemCat.Category_Name,'') +
				'" _19="" _20="" _21="0" _22="0" _23="0"' +
				' _24="' + IsNull((CASE QC.MarginOn  WHEN 1 THEN @ECP WHEN 2 THEN	@PURCHASE WHEN 3 THEN	@MRP When 4 Then @SALEPRICE END),'') +
				'" _25="' + Cast(IsNull(QC.MarginPercentage, 0) As nVarChar) +
				'" _26="0" _27="0" _28="0"' +
				' _29="' +  Cast(IsNull(QC.QuotationID,0) As nVarChar)  + '"'
				From QuotationMfrCategory QC
				Join ItemCategories ItemCat On ItemCat.CategoryID  = QC.MfrCategoryID  
				Where QC.QuotationID = @QuotID
								
				Set @PreQuotID	= @QuotID 			
        End
        
        Fetch Next From RepAbs Into @RepAbs_ID, @QuotID, @QuotationType
    End 
    Close RepAbs
    Deallocate RepAbs    
	
	Select * from #XMLData as XMLData For XML Auto, Root('Root')

	Drop Table #TmpAbs 
	Drop Table #XMLData 

OvernOut:
End
