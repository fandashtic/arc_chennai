Create Procedure spr_SRGodown_DD_Upload
(  
@FromDate DateTime,
@ToDate DateTime,  
@Type nvarchar(255),
@UOMDesc nVarchar(30)
)  
As  

Set dateformat dmy

/* Report should be generated only if the last day is Closed */
Declare @DayClosed Int
Select @DayClosed = 0
If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
Begin
	If ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(@TODATE)) --dbo.StripTimeFromDate(DateAdd(d, 1, @TODATE)))
	BEGIN
		Set @DayClosed = 1
	END
End

If @DayClosed = 0
	GoTo OvernOut

Declare @WDCode nVarchar(255)  
Declare @WDDest nVarchar(255)  
Declare @CompaniesToUploadCode nVarchar(255)  
DECLARE @INV AS NVARCHAR(50)   
Declare @SA AS NVARCHAR(50)   
SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'                
SELECT @SA = Prefix FROM VoucherPrefix WHERE TranID = N'STOCK ADJUSTMENT'                

  
Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload    
Select Top 1 @WDCode = RegisteredOwner From Setup      
    
If @CompaniesToUploadCode='ITC001'    
 Set @WDDest= @WDCode    
Else    
Begin    
 Set @WDDest= @WDCode    
 Set @WDCode= @CompaniesToUploadCode    
End  

Create Table #XMLData(ID int identity(1,1),XMLStr nVarchar(max))

Create Table #TempSalesReturnDD(  
[Invoice ID] NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[WD Code] NVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[WD Dest] NVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[From Date] Datetime,  
[To Date] Datetime,  
[Doc ID] NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[Date] Datetime,  
[Type] NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[DS ID] int,
[DS Name] NVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Customer ID] NVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Customer Name]  NVarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS
) 
If @Type = '%' or @Type = 'All'
BEGIN
	insert into #TempSalesReturnDD ([invoice ID],[WD Code],[WD Dest],[From Date],[To Date],[Doc ID],[Date],[Type], [DS ID],[DS Name],[Customer ID],[Customer Name])
	select invoiceID,@WDCode as WDCode,@WDDest as WDDest,@FromDate,@ToDate,
	--@INV+ cast(documentID as nvarchar(255)) DocID,
	Case IsNULL(GSTFlag ,0)
	When 0 then @INV+ cast(documentID as nvarchar(255))
	Else
		IsNULL(GSTFullDocID,'')
	End DocID,
	InvoiceDate,
	"Type" = case When  IsNull(invoiceabstract.Status,0) & 32 <> 0 And IsNull(invoiceabstract.Status,0) & 64 =0
	Then 'Sales Return Damage'                  
	else 'Sales Return Saleable' End,invoiceabstract.SalesmanId,salesman.Salesman_Name,invoiceabstract.CustomerId,customer.Company_Name from invoiceabstract,salesMan,Customer  
	where invoiceabstract.salesmanID = salesman.salesmanID and invoiceabstract.customerID = customer.CustomerId
	
	and convert(nVarchar(10),InvoiceDate,103) BETWEEN @FROMDATE AND @TODATE
	and isnull(invoicetype,0) in (4,5)
	And isnull(status,0) & 192 = 0
    order by InvoiceDate, customer.Company_Name,Type
    

	insert into  #TempSalesReturnDD([Invoice ID],[WD Code],[WD Dest],[From Date],[To Date],[Doc ID],[Date],[Type]) 
	select SAA.AdjustmentID,@WDCode as WDCode,@WDDest as WDDest,@FromDate,@ToDate,@SA+ cast(SAA.documentID as nvarchar(255)) DocID,SAA.Adjustmentdate,"Type" = 'Damages in Godown'  from stockadjustmentabstract SAA
	where SAA.AdjustmentType = 0 and SAA.AdjustmentID in (Select SAD.SerialNo from stockadjustment SAD WHERE SAD.reasonID in (Select Reason_Type_ID from ReasonMaster where Reason_SubType=3))
	and convert(nVarchar(10),SAA.AdjustmentDate,103) BETWEEN @FROMDATE AND @TODATE

	insert into  #TempSalesReturnDD([Invoice ID],[WD Code],[WD Dest],[From Date],[To Date],[Doc ID],[Date],[Type]) 
	select SAA.AdjustmentID,@WDCode as WDCode,@WDDest as WDDest,@FromDate,@ToDate,@SA+ cast(SAA.documentID as nvarchar(255)) DocID,SAA.Adjustmentdate,"Type" = 'Damages on Arrival'  from stockadjustmentabstract SAA
	where SAA.AdjustmentType = 0 and SAA.AdjustmentID in (select SAD.SerialNo from stockadjustment SAD WHERE SAD.reasonID in (Select Reason_Type_ID from ReasonMaster where Reason_SubType=4))
	and convert(nVarchar(10),SAA.AdjustmentDate,103) BETWEEN @FROMDATE AND @TODATE     
    
END
ELSE IF @Type = 'Sales Return Damage'
BEGIN
	insert into #TempSalesReturnDD([invoice ID],[WD Code],[WD Dest],[From Date],[To Date],[Doc ID],[Date],[Type], [DS ID],[DS Name],[Customer ID],[Customer Name])
    select invoiceID,@WDCode as WDCode,@WDDest as WDDest,@FromDate,@ToDate,
    --@INV+ cast(documentID as nvarchar(255)) DocID,
    Case IsNULL(GSTFlag ,0)
	When 0 then @INV+ cast(documentID as nvarchar(255))
	Else
		IsNULL(GSTFullDocID,'')
	End DocID,
    InvoiceDate,
	"Type" = 'Sales Return Damages',invoiceabstract.SalesmanId,salesman.Salesman_Name,invoiceabstract.CustomerId,customer.Company_Name from invoiceabstract,salesMan,Customer  
	where invoiceabstract.salesmanID = salesman.salesmanID and invoiceabstract.customerID = customer.CustomerId
	and convert(nVarchar(10),InvoiceDate,103) BETWEEN @FROMDATE AND @TODATE
	and isnull(invoicetype,0) in (4,5)
	And IsNull(invoiceabstract.Status,0) & 32 <> 0 And IsNull(invoiceabstract.Status,0) & 64 =0
	And isnull(status,0) & 192 = 0
    order by InvoiceDate, customer.Company_Name,Type
END
ELSE IF @Type = 'Sales Return Saleable'
BEGIN
	insert into #TempSalesReturnDD([invoice ID],[WD Code],[WD Dest],[From Date],[To Date],[Doc ID],[Date],[Type], [DS ID],[DS Name],[Customer ID],[Customer Name])
	select invoiceID,@WDCode as WDCode,@WDDest as WDDest,@FromDate,@ToDate,
	--@INV+ cast(documentID as nvarchar(255)) DocID,
	Case IsNULL(GSTFlag ,0)
	When 0 then @INV+ cast(documentID as nvarchar(255))
	Else
		IsNULL(GSTFullDocID,'')
	End DocID,
	InvoiceDate,
	"Type" = 'Sales Return Saleable',invoiceabstract.SalesmanId,salesman.Salesman_Name,invoiceabstract.CustomerId,customer.Company_Name from invoiceabstract,salesMan,Customer  
	where invoiceabstract.salesmanID = salesman.salesmanID and invoiceabstract.customerID = customer.CustomerId
	and convert(nVarchar(10),InvoiceDate,103) BETWEEN @FROMDATE AND @TODATE
	and isnull(invoicetype,0) in (4,5)
	And IsNull(invoiceabstract.Status,0) & 32 = 0
	And isnull(status,0) & 192 = 0
    order by InvoiceDate, customer.Company_Name,Type
END
ELSE IF @Type = 'Damages in Godown'
BEGIN
	insert into  #TempSalesReturnDD([Invoice ID],[WD Code],[WD Dest],[From Date],[To Date],[Doc ID],[Date],[Type]) 
	select SAA.AdjustmentID,@WDCode as WDCode,@WDDest as WDDest,@FromDate,@ToDate,@SA+ cast(SAA.documentID as nvarchar(255)) DocID,SAA.Adjustmentdate,"Type" = 'Damages in Godown'  from stockadjustmentabstract SAA
	where SAA.AdjustmentType = 0 and SAA.AdjustmentID in (Select SAD.SerialNo from stockadjustment SAD WHERE SAD.reasonID in (Select Reason_Type_ID from ReasonMaster where Reason_SubType=3))
	and convert(nVarchar(10),SAA.AdjustmentDate,103) BETWEEN @FROMDATE AND @TODATE
    
END
ELSE IF @Type = 'Damages on Arrival'
BEGIN
	insert into  #TempSalesReturnDD([Invoice ID],[WD Code],[WD Dest],[From Date],[To Date],[Doc ID],[Date],[Type]) 
	select SAA.AdjustmentID,@WDCode as WDCode,@WDDest as WDDest,@FromDate,@ToDate,@SA+ cast(SAA.documentID as nvarchar(255)) DocID,SAA.Adjustmentdate,"Type" = 'Damages on Arrival'  from stockadjustmentabstract SAA
	where SAA.AdjustmentType = 0 and SAA.AdjustmentID in (select SAD.SerialNo from stockadjustment SAD WHERE SAD.reasonID in (Select Reason_Type_ID from ReasonMaster where Reason_SubType=4))
	and convert(nVarchar(10),SAA.AdjustmentDate,103) BETWEEN @FROMDATE AND @TODATE    
END

update #TempSalesReturnDD set [invoice id]=[Invoice id]+ '|' + '1' Where Type = 'Sales Return Saleable'
update #TempSalesReturnDD set [invoice id]=[Invoice id]+ '|' + '2' Where Type = 'Sales Return Damage'
update #TempSalesReturnDD set [invoice id]=[Invoice id]+ '|' + '3' Where Type = 'Damages in Godown'
update #TempSalesReturnDD set [invoice id]=[Invoice id]+ '|' + '4' Where Type = 'Damages on Arrival'

Create Table #Abstract(
						ID int Identity(1,1) Not Null,
						_0 nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
						_1 nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
						_2 nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
						_3 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
						_4 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
						_5 nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
						_6 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
						_7 nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
						_8 int,
						_9 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
						_10 nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
						_11 nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS
						)

Insert Into #Abstract(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11)
Select "Invoice ID" = [Invoice ID],
		"WD Code " = [WD Code],
		"WD Dest" = [WD Dest],
		"From Date" = [From Date],
		"To Date" = [To Date],
		"Doc ID" = [Doc ID],
		"Date" = [Date],
		"Type" = [Type],
		"DS ID" = [DS ID],
		"DS Name" = [DS Name],
		"Customer ID" = [Customer ID],
		"Customer Name" = [Customer Name]
From #TempSalesReturnDD


------------- Detail Procedure -----------

Declare @ID nVarchar(255)

Create Table #Detail (
				_0  nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
				_12 nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
				_13 nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
				_14 nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS,
				_15 nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,
				_16 Decimal(18, 6),
				_17 Decimal(18, 6),
				_18 nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS
				)


Create Table #TempSalesReturnDD_Detail(  
[Invoice ID] int,  
[Item Code] NVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[Item Name] NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[Batch No] NVarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[UOM] NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[Quantity] decimal(18,6),  
[Value] decimal(18,6),  
[Reason] NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	)  


Declare @PrevID nVarchar(255)
Set @PrevID = ''

Declare DetailCursor Cursor For
Select _0 From #Abstract order by ID
Open DetailCursor
Fetch Next From DetailCursor Into @ID
While @@Fetch_Status = 0
Begin

Declare @InvID int
Declare @TypeID nvarchar(50)

--Begin
If @ID <> @PrevID
Begin

Insert Into #XMLData Select 'Abstract _1="' + Cast(Isnull(_1, '') as nVarchar(20)) + '"' +
' _2="' + Cast(Isnull(_2, '') as nVarchar(20)) + '"' +
' _3="' + Cast(Isnull(_3, '') as nVarchar(50)) + '"' +
' _4="' + Cast(Isnull(_4, '') as nVarchar(50)) + '"' +
' _5="' + Cast(Isnull(_5, '') as nVarchar(255)) + '"' +
' _6="' + Cast(Isnull(_6, '') as nVarchar(50)) + '"' +
' _7="' + Cast(Isnull(_7, '') as nVarchar(255)) + '"' +
' _8="' + Cast(Isnull(_8, 0) as nVarchar) + '"' +
' _9="' + Cast(Isnull(_9, '') as nVarchar(50)) + '"' +
' _10="' + Cast(Isnull(_10, '') as nVarchar(15)) + '"' +
' _11="' + Cast(Isnull(_11, '') as nVarchar(150)) + '"'

From #Abstract
Where _0 = @ID

End

Set @InvID=Substring(@ID,1,CharIndex('|',@ID)-1)
Set @TypeID=Substring(@ID,CharIndex('|',@ID)+1,Len(@ID))

IF @TypeID = '2'
Begin
	
    insert into #TempSalesReturnDD_Detail([Invoice ID],[Item Code],[Item Name],[Batch No], [UOM],[Quantity],[Value],[Reason])
    select invoiceID,invoicedetail.Product_code,items.ProductName,Batch_Number,     
    (Select Description From UOM Where UOM = ITEMS.UOM) As UOM,
    SUM(InvoiceDetail.Quantity) As Qty,
	(sum(InvoiceDetail.Quantity) * InvoiceDetail.Saleprice) as Value,
	reasonMaster.Reason_Description 
	from invoicedetail, items, ReasonMaster 
	where invoicedetail.product_Code = items.Product_Code
	and invoicedetail.reasonId = Reasonmaster.reason_Type_ID and invoiceID = @InvID	
	group by invoiceID,invoicedetail.Product_code,items.ProductName,Batch_Number, reasonMaster.Reason_Description,InvoiceDetail.Saleprice,
    ITEMS.UOM1,items.uom2,items.uom 
    
    
End
--else if @Type = 'Sales Return Saleable'
else if @TypeID = '1'
Begin
    insert into #TempSalesReturnDD_Detail ([Invoice ID],[Item Code],[Item Name],[Batch No], [UOM],[Quantity],[Value],[Reason])
    select invoiceID,invoicedetail.Product_code,items.ProductName,Batch_Number,       
    (Select Description From UOM Where UOM = ITEMS.UOM) As UOM,    
	SUM(InvoiceDetail.Quantity) As Qty,
	(sum(InvoiceDetail.Quantity) * InvoiceDetail.Saleprice) as Value,
	reasonMaster.Reason_Description 
	from invoicedetail, items, ReasonMaster 
	where invoicedetail.product_Code = items.Product_Code
	and invoicedetail.reasonId = Reasonmaster.reason_Type_ID and invoiceID = @InvID	
	group by invoiceID,invoicedetail.Product_code,items.ProductName,Batch_Number, reasonMaster.Reason_Description,InvoiceDetail.Saleprice,
    ITEMS.UOM1,items.uom2,items.uom 
    
end
--else if @Type = 'Godown Damage'
else if @TypeID = '3'or @TypeID = '4'
Begin
	insert into #TempSalesReturnDD_Detail([Invoice ID],[Item Code],[Item Name],[Batch No], [UOM],[Quantity],[Value],[Reason])
    select @InvID as InvoiceID,sa.Product_code,items.ProductName,sa.Batch_Number,
    (Select Description From UOM Where UOM = ITEMS.UOM) As UOM,   
	SUM(sa.Quantity) As Qty,
	(sa.Rate) as Value,
	reasonMaster.Reason_Description 
	from  stockadjustmentabstract saa, stockadjustment sa, items, ReasonMaster
	where sa.serialno = saa.adjustmentid and
	sa.product_Code = items.Product_Code 
	and sa.reasonId = Reasonmaster.reason_Type_ID and saa.Adjustmentid = @InvID	
	group by sa.Product_code,items.ProductName,sa.Batch_Number,reasonMaster.Reason_Description,
	Items.UOM1_Conversion, Items.UOM2_Conversion,sa.Rate,Items.Uom1,items.uom2,items.uom   

End

Insert Into #Detail
Select @ID,
[Item Code],
[Item Name],
[Batch No],
[UOM],
[Quantity],
[Value],
[Reason]
From #TempSalesReturnDD_Detail order by [Item Code], [Reason]

Insert Into #XMLData Select  'Detail _12="' + Cast(IsNull(_12, '') as nVarchar(15)) + '"' +
' _13="' + Cast(IsNull(_13, '') as nVarchar(255)) + '"' +
' _14="' + Cast(IsNull(_14, '') as nVarchar(128)) + '"' +
' _15="' + Cast(IsNull(_15, '') as nVarchar(255)) + '"' +
' _16="' + Cast(IsNull(_16, 0) as nVarchar) + '"' +
' _17="' + Cast(IsNull(_17, 0) as nVarchar) + '"' +
' _18="' + Cast(IsNull(_18, '') as nVarchar(100)) + '"'
From #Detail
Where _0 = @ID

Set @PrevID = @ID

Truncate Table #TempSalesReturnDD_Detail

--End
Fetch Next From DetailCursor Into @ID
End
Close DetailCursor
Deallocate DetailCursor

--Select XMLStr from #XMLData as XMLData For XML Auto, Root('Root')

Select XMLStr from #XMLData as XMLData order by ID For XML Auto, Root('Root')

Drop Table #XMLData
Drop Table #Abstract
Drop Table #Detail
Drop Table #TempSalesReturnDD_Detail
Drop Table #TempSalesReturnDD


OvernOut:  
