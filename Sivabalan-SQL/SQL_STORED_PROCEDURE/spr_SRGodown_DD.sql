Create Procedure spr_SRGodown_DD
(  
@FromDate DateTime,
@ToDate DateTime,  
@Type nvarchar(255),
@UOMDesc nVarchar(30)
)  
As  
BEGIN
	set dateformat dmy
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

Create Table #TempSalesReturnDD(  
[Invoice ID] NVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,  
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
[Customer Name]  NVarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS default ''
)  
If @Type = '%' or @Type = ''
BEGIN
	insert into #TempSalesReturnDD ([invoice ID],[WD Code],[WD Dest],[From Date],[To Date],[Doc ID],[Date],[Type], [DS ID],[DS Name],[Customer ID],[Customer Name])
	select invoiceID,@WDCode as WDCode,@WDDest as WDDest,@FromDate,@ToDate,
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
    Case IsNULL(GSTFlag ,0)
	When 0 then @INV+ cast(documentID as nvarchar(255))
	Else
		IsNULL(GSTFullDocID,'')
	End DocID,
    InvoiceDate,
	"Type" = 'Sales Return Damage',invoiceabstract.SalesmanId,salesman.Salesman_Name,invoiceabstract.CustomerId,customer.Company_Name from invoiceabstract,salesMan,Customer  
	where invoiceabstract.salesmanID = salesman.salesmanID and invoiceabstract.customerID = customer.CustomerId
	and convert(nVarchar(10),InvoiceDate,103) BETWEEN @FROMDATE AND @TODATE
	and isnull(invoicetype,0) in (4,5)
	And IsNull(invoiceabstract.Status,0) & 32 <> 0 And IsNull(invoiceabstract.Status,0) & 64 =0
	And isnull(status,0) & 192 = 0
    
END

ELSE IF @Type = 'Sales Return Saleable'
BEGIN
	insert into #TempSalesReturnDD([invoice ID],[WD Code],[WD Dest],[From Date],[To Date],[Doc ID],[Date],[Type], [DS ID],[DS Name],[Customer ID],[Customer Name])
	select invoiceID,@WDCode as WDCode,@WDDest as WDDest,@FromDate,@ToDate,
--	@INV+ cast(documentID as nvarchar(255)) DocID,
	Case IsNULL(GSTFlag ,0)
	When 0 then @INV+ cast(documentID as nvarchar(255))
	Else
		IsNULL(GSTFullDocID,'')
	End DocID,
	InvoiceDate,
	"Type" = 'Sales Return Saleable',invoiceabstract.SalesmanId,salesman.Salesman_Name,invoiceabstract.CustomerId,customer.Company_Name from invoiceabstract,salesMan,Customer  
	where invoiceabstract.salesmanID = salesman.salesmanID and invoiceabstract.customerID = customer.CustomerId
	and convert(nVarchar(10),InvoiceDate,103) BETWEEN @FROMDATE AND @TODATE	
	And IsNull(invoiceabstract.Status,0) & 32 = 0 --And IsNull(invoiceabstract.Status,0) & 64 <>0
	and isnull(invoicetype,0) in (4,5)
	And isnull(status,0) & 192 = 0
    
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


--update #TempSalesReturnDD set invoiceid=Invoiceid+ '|' + Type 
update #TempSalesReturnDD set [invoice id]=[Invoice id]+ '|' + '1' Where Type = 'Sales Return Saleable'
update #TempSalesReturnDD set [invoice id]=[Invoice id]+ '|' + '2' Where Type = 'Sales Return Damage'
update #TempSalesReturnDD set [invoice id]=[Invoice id]+ '|' + '3' Where Type = 'Damages in Godown'
update #TempSalesReturnDD set [invoice id]=[Invoice id]+ '|' + '4' Where Type = 'Damages on Arrival'

Select * from #TempSalesReturnDD order by dbo.striptimefromdate([Date]),isnull([Customer Name],''),[Type]
drop table #TempSalesReturnDD
END
