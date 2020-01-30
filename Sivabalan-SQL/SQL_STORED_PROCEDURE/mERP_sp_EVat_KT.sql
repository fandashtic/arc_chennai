create Procedure mERP_sp_EVat_KT(@FromDate datetime,@ToDate datetime,@OutputType nVarchar(50),@Format nvarchar(100),@CustType nVarchar(50))
As

Declare @WDTin nVarchar(255)
declare @Tin nVarchar(255)
Declare @InvPrfx nVarchar(10)
Declare @InvAmdPrfx nVarchar(10)
Declare @SRPrfx nVarchar(10)
Declare @BillPrfx nVarchar(10)
Declare @BillAmdPrfx nVarchar(10)
Declare @PRPrfx nVarchar(10)
select @InvPrfx=Prefix from VoucherPrefix where TranId=N'INVOICE'
select @InvAmdPrfx=Prefix from VoucherPrefix where TranId=N'INVOICE AMENDMENT'
select @SRPrfx=Prefix from VoucherPrefix where TranId=N'SALES RETURN'
select @BillPrfx=Prefix from VoucherPrefix where TranId=N'BILL'
select @BillAmdPrfx=Prefix from VoucherPrefix where TranId=N'BILL AMENDMENT'
select @PRPrfx=Prefix from VoucherPrefix where TranId=N'PURCHASE RETURN'
select @WDTin = IsNull(TIN_Number,N'') from setup
if @OutputType = N'Sales'
	Begin
	Declare @Customer table(CustomerId nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,Company_Name nVarchar(50),Tin_Number nVarchar(50))
	if @CustType=N'TIN'
		Insert into @Customer (CustomerID,Company_Name,Tin_Number ) Select CustomerID,Company_Name,Tin_Number from Customer where IsNull(Tin_Number,'') <> ''
	else	
		Insert into @Customer (CustomerID,Company_Name,Tin_Number ) Select CustomerID,Company_Name,Tin_Number from Customer where IsNull(Tin_Number,'') = ( case @CustType when N'All' then Tin_Number else '' end)
	End
else
	Begin
	Declare @Vendors table(VendorId nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,Vendor_Name nVarchar(50),Tin_Number nVarchar(50))
	if @CustType=N'TIN'
		Insert into @Vendors (VendorId ,Vendor_Name,Tin_Number ) Select VendorId ,Vendor_Name,Tin_Number from Vendors where IsNull(Tin_Number,'') <> ''
	else	
		Insert into @Vendors (VendorId ,Vendor_Name,Tin_Number ) Select VendorId ,Vendor_Name,Tin_Number  from Vendors where IsNull(Tin_Number,'') = ( case @CustType when N'All' then Tin_Number else '' end)
	End

Begin	
	If @OutputType=N'Purchase' or @OutputType=N''
	Begin
		Select TinNo,RetPerdEnd,Sno = ROW_NUMBER() Over (Order by InvDate,SelName),
		SelName,SelTin,InvNo,InvDate =CONVERT(CHAR(10),InvDate,103),NetVal,TaxCh from 
		(
		select "TinNo"=@WDTin,
		"RetPerdEnd"=Replace(left(CONVERT(CHAR(10),BA.BillDate,102) ,8),'.',''),
		"SelName" = V.Vendor_name,
		"SelTin" = isNull(V.Tin_Number,''),	
		"InvNo"=(case @Format when N'Serial No' then cast((Case IsNull(BA.BillReference,'') when '' then @BillPrfx else @BillAmdPrfx end) as nVarchar(10)) + cast(BA.DocumentId as nvarchar(10)) 
		when N'Document No' then BA.DocIDReference 
		when N'Reference No' then BA.InvoiceReference else 
		cast((Case IsNull(BA.BillReference,'') when '' then @BillPrfx else @BillAmdPrfx end) as nvarchar(10)) + cast(BA.DocumentId as nvarchar(10))+'-'+cast(BA.DocIDreference as nvarchar(255))+'-'+cast(BA.InvoiceReference as nvarchar(255)) end),
		"InvDate" = dbo.striptimefromdate(BA.BillDate),       
		"NetVal"= BA.[Value],
		"TaxCh" = BA.TaxAmount
		from BillAbstract BA,@Vendors V
		where isnull(BA.Status,0) & 192 = 0 
		and dbo.StripTimeFromDate(BA.BillDate) BETWEEN @FromDate AND @ToDate
		and V.VendorID=BA.VendorID	
		Union
		select "TinNo"=@WDTin,
		"RetPerdEnd"=Replace(left(CONVERT(CHAR(10),PR.AdjustmentDate,102) ,8),'.',''),
		"SelName" = V.Vendor_name,
		"SelTin" = isNull(V.Tin_Number,''),	
		"InvNo"=(case @Format when N'Serial No' then cast(@PRPrfx  as nVarchar(10)) + cast(PR.DocumentId as nvarchar(10)) 
		when N'Document No' then PR.Reference 
		when N'Reference No' then '' else 
		cast(@PRPrfx as nvarchar(10)) + cast(PR.DocumentId as nvarchar(10))+ (case PR.Reference when '' then '' else '-'+cast(PR.Reference as nvarchar(255)) end) end),		
		"InvDate" = dbo.striptimefromdate(PR.AdjustmentDate),       
		"NetVal"= -PR.[Value],
		"TaxCh" = -PR.VatTaxAmount
		from AdjustmentReturnAbstract PR,@Vendors V
		where isnull(PR.Status,0) & 192 = 0 
		and dbo.StripTimeFromDate(PR.AdjustmentDate) BETWEEN @FromDate AND @ToDate
		and V.VendorID=PR.VendorID	
		) P Order By Sno
	End
	Else If @OutputType=N'Sales'
	Begin

		Select "TinNo" = @WDTin,	
		"RetPerdEnd" =Replace(left(CONVERT(CHAR(10),InvoiceDate,102) ,8),'.',''),
		"Sno" = ROW_NUMBER() Over (Order by dbo.StripTimeFromDate(InvoiceDate),C.Company_Name),	
		"BuyName" = C.Company_Name,
		"BuyTin" = C.Tin_Number,
		"InvNo" = (case @Format when N'Serial No' then cast((Case InvoiceType when 1 then @InvPrfx when 3 then @InvAmdPrfx when 4 then @SRPrfx else '' end) as nvarchar(10)) + cast(DocumentId as nvarchar(10)) 
		when N'Document No' then DocReference 
		when N'Reference No' then NewReference else 
		cast((Case InvoiceType when 1 then @InvPrfx when 3 then @InvAmdPrfx when 4 then @SRPrfx else '' end) as nvarchar(10)) + cast(DocumentId as nvarchar(10))+'-'+cast(Docreference as nvarchar(255))+ (case IsNull(NewReference,'') when '' then '' else '-'+cast(Newreference as nvarchar(255)) end) end),
		"InvDate" = CONVERT(CHAR(10),InvoiceDate,103) ,
		"NetVal" = case InvoiceType when 4 then -Netvalue else NetValue end,
		"TaxCh"= case InvoiceType when 4 then -TotalTaxApplicable else TotalTaxApplicable end
		FROM InvoiceAbstract, @Customer C
		WHERE  InvoiceType in (1,3,4) AND dbo.StripTimeFromDate(InvoiceDate) BETWEEN @FROMDATE AND @TODATE 
		and InvoiceAbstract.CustomerID = C.CustomerID    
		and isnull(InvoiceAbstract.Status,0) & 192 = 0 	 
		Order by Sno 
		
	End  
End
