
create Procedure [dbo].[spr_SRGodown_DD_Detail]
(  
@AbstractData nvarchar(500),
@SplitType nvarchar(500),
@UOMDesc nVarchar(30)
)  
As  
begin 
	set dateformat dmy

	Declare @ID int
	Declare @Type nvarchar(255)
	Set @ID=Substring(@AbstractData,1,CharIndex('|',@AbstractData)-1)
	Set @Type=Substring(@AbstractData,CharIndex('|',@AbstractData)+1,Len(@AbstractData))
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

--IF @Type = 'Sales Return - Damages'
IF @Type = '2'
begin
	
    insert into #TempSalesReturnDD_Detail([Invoice ID],[Item Code],[Item Name],[Batch No], [UOM],[Quantity],[Value],[Reason])
    select invoiceID,invoicedetail.Product_code,items.ProductName,Batch_Number, 
    
    Case When @UOMdesc = 'UOM1' then (Select Description From UOM Where UOM = ITEMS.UOM1) 
	When @UOMdesc = 'UOM2' then (Select Description From UOM Where UOM = ITEMS.UOM2) 
    else (Select Description From UOM Where UOM = ITEMS.UOM) end,

    "Quantity" = Case When @UOMdesc = 'UOM1' then SUM(InvoiceDetail.Quantity)/Case When IsNull(Max(Items.UOM1_Conversion), 0) = 0 Then 1 Else Max(Items.UOM1_Conversion) End
	When @UOMdesc = 'UOM2' then SUM(InvoiceDetail.Quantity)/Case When IsNull(max(Items.UOM2_Conversion), 0) = 0 Then 1 Else max(Items.UOM2_Conversion) End
	Else SUM(InvoiceDetail.Quantity) end,
	(sum(InvoiceDetail.Quantity) * InvoiceDetail.Saleprice) as Value,reasonMaster.Reason_Description 
	from invoicedetail,items,ReasonMaster 
	where invoicedetail.product_Code = items.Product_Code
	and invoicedetail.reasonId = Reasonmaster.reason_Type_ID and invoiceID = @ID	
	group by invoiceID,invoicedetail.Product_code,items.ProductName,Batch_Number, reasonMaster.Reason_Description,InvoiceDetail.Saleprice,
    ITEMS.UOM1,items.uom2,items.uom 
    
    
end
--else if @Type = 'Sales Return - Saleable'
else if @Type = '1'
begin
    insert into #TempSalesReturnDD_Detail ([Invoice ID],[Item Code],[Item Name],[Batch No], [UOM],[Quantity],[Value],[Reason])
    select invoiceID,invoicedetail.Product_code,items.ProductName,Batch_Number, 
    
    Case When @UOMdesc = 'UOM1' then (Select Description From UOM Where UOM = ITEMS.UOM1) 
	When @UOMdesc = 'UOM2' then (Select Description From UOM Where UOM = ITEMS.UOM2) 
    else (Select Description From UOM Where UOM = ITEMS.UOM) end,

    "Quantity" = Case When @UOMdesc = 'UOM1' then SUM(InvoiceDetail.Quantity)/Case When IsNull(Max(Items.UOM1_Conversion), 0) = 0 Then 1 Else Max(Items.UOM1_Conversion) End
	When @UOMdesc = 'UOM2' then SUM(InvoiceDetail.Quantity)/Case When IsNull(max(Items.UOM2_Conversion), 0) = 0 Then 1 Else max(Items.UOM2_Conversion) End
	Else SUM(InvoiceDetail.Quantity) end,
	(sum(InvoiceDetail.Quantity) * InvoiceDetail.Saleprice) as Value,reasonMaster.Reason_Description 
	from invoicedetail,items,ReasonMaster 
	where invoicedetail.product_Code = items.Product_Code
	and invoicedetail.reasonId = Reasonmaster.reason_Type_ID and invoiceID = @ID	
	group by invoiceID,invoicedetail.Product_code,items.ProductName,Batch_Number, reasonMaster.Reason_Description,InvoiceDetail.Saleprice,
    ITEMS.UOM1,items.uom2,items.uom 
    
end
--else if @Type = 'Godown Damage'
else if @Type = '3' Or @Type = '4'
	insert into #TempSalesReturnDD_Detail([Invoice ID],[Item Code],[Item Name],[Batch No], [UOM],[Quantity],[Value],[Reason])
    select @ID as InvoiceID,sa.Product_code,items.ProductName,sa.Batch_Number,
    
    Case When @UOMdesc = 'UOM1' then (Select Description From UOM Where UOM = ITEMS.UOM1) 
	When @UOMdesc = 'UOM2' then (Select Description From UOM Where UOM = ITEMS.UOM2) 
    else (Select Description From UOM Where UOM = ITEMS.UOM) end,
    
	"Quantity" = Case When @UOMdesc = 'UOM1' then SUM(sa.Quantity)/Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
	When @UOMdesc = 'UOM2' then SUM(sa.Quantity)/Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End
	Else SUM(sa.Quantity) end,
	(sa.Rate) as Value,reasonMaster.Reason_Description 
	from  stockadjustmentabstract saa, stockadjustment sa,items,ReasonMaster
	where sa.serialno = saa.adjustmentid and
	sa.product_Code = items.Product_Code 
	and sa.reasonId = Reasonmaster.reason_Type_ID and saa.Adjustmentid = @ID	
	group by sa.Product_code,items.ProductName,sa.Batch_Number,reasonMaster.Reason_Description,
	Items.UOM1_Conversion, Items.UOM2_Conversion,sa.Rate,Items.Uom1,items.uom2,items.uom
    

end

select * from #TempSalesReturnDD_Detail order by [Item Code],[Reason]
drop table #TempSalesReturnDD_Detail

