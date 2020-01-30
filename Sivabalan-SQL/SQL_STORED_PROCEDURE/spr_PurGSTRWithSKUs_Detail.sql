Create Procedure spr_PurGSTRWithSKUs_Detail(@BillID varchar(255),@Fromdate datetime,@Todate datetime,@UOM  nVarchar(20))
As    

Set DATEFormat DMY
Create Table #TempPurTaxItemDet(  
BillID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,   
[Item Code] nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[Item Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[MRP Per PAC]  Decimal(18,6),
Quantity Decimal(18,6),
UOM nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,   
Rate Decimal(18,6),
[Goods Value] Decimal(18,6),
[Total Discount] Decimal(18,6),
[Gross Amount] Decimal(18,6),
[Total Tax Value] Decimal(18,6),
[Total Amount] Decimal(18,6),
[HSN Code] nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[Taxable Sales Value] Decimal(18,6),
[CGST Tax Rate] Decimal(18,6),
[CGST Tax Amount] Decimal(18,6),
[SGST Tax Rate] Decimal(18,6),
[SGST Tax Amount] Decimal(18,6),
[IGST Tax Rate] Decimal(18,6),
[IGST Tax Amount] Decimal(18,6),
[UTGST Tax Rate] Decimal(18,6),
[UTGST Tax Amount] Decimal(18,6),
[Cess Rate] Decimal(18,6),
[Cess Amount] Decimal(18,6),
[AddlCess Rate] Decimal(18,6),
[AddlCess Amount] Decimal(18,6)
) 
Declare @Delimeter as Char(1)
Declare @UTGST_flag  int
Declare @TransType int
Set @Delimeter = ','


select @UTGST_flag = isnull(flag,0) from tbl_merp_configabstract(nolock) where screencode = 'UTGST' 


Create Table #tmpTaxCode(Id int identity,TaxCode int)
If @BillID <> ''
	Insert into #tmpTaxCode select * from dbo.sp_SplitIn2Rows(@BillID,@Delimeter)

Select @TransType = TaxCode from #tmpTaxCode where Id = 3

Select  BillID, Product_Code, Tax_Code ,SerialNo,  
SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End), 
SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Value Else 0 End), 
CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End), 
CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Value Else 0 End),  
IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End), 
IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Value Else 0 End), 
UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End), 
UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Value Else 0 End),
CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Value Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Value Else 0 End) Into #TempTaxDet
From GSTBillTaxComponents ITC
Join TaxComponentDetail TCD 
On TCD.TaxComponent_code = ITC.Tax_Component_Code
Group By BillID, Product_Code, Tax_Code,SerialNo

If @TransType = 1
Begin
	Insert Into #TempPurTaxItemDet
	Select Cast(BA.BillID as Nvarchar(255)) as BillID ,BD.Product_Code ,I.ProductName  ,IsNull(BD.MRPPerPack,0) ,

	"Quantity" = (Case When @UOM = 'UOM1' then (sum(BD.Quantity))/Case When IsNull(Max(I.UOM1_Conversion), 0) = 0 Then 1 Else Max(I.UOM1_Conversion) End
		When @UOM = 'UOM2' then (sum(BD.Quantity))/Case When IsNull(Max(I.UOM2_Conversion), 0) = 0 Then 1 Else Max(I.UOM2_Conversion) End
		Else (sum(BD.Quantity))
	End),
	"UOM" = Case When @UOM = 'UOM1' Then (Select Top 1 UOM.Description From UOM Where UOM.UOM = I.UOM1)
					When @UOM = 'UOM2' Then (Select Top 1 UOM.Description From UOM Where UOM.UOM = I.UOM2)
					Else (Select Top 1 UOM.Description From UOM Where UOM.UOM = I.UOM) End,

	"Rate" = ( Case When @UOM = 'UOM1' then (BD.PurchasePrice) * Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End
				When @UOM = 'UOM2' then (BD.PurchasePrice) * Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End
						Else (BD.PurchasePrice)
 				End),

	sum(BD.OrgPTS * BD.Quantity) as "Goods Value",
	sum(BD.InvDiscAmount + BD.OtherDiscAmount ) as "Total Discount" ,
	sum(BD.Amount)  as "Gross Amount",
	sum(BD.TaxAmount )  as " Total Tax Value",
	sum(BD.Amount + BD.TaxAmount )  as "Total Amount",
	IsNull(I.HSNNumber,'') ,
	sum(BD.Amount) as "Taxable Sales Value",
	"CGST Tax Rate" = max(CGSTPer),
	"CGST Tax Amount" = sum(CGSTAmt),
	"SGST Tax Rate" = Case When isnull(T.CS_TaxCode,0) = 0 Then MAX(BD.TaxSuffered) Else max(SGSTPer) End, 
	"SGST Tax Amount" = Case When isnull(T.CS_TaxCode,0) = 0 Then sum(BD.TaxAmount) Else sum(SGSTAmt) End, 
	"IGST Tax Rate" = max(IGSTPer),
	"IGST Tax Amount" = sum(IGSTAmt),
	"UTGST Tax Rate" = max(UTGSTPer),
	"UTGST Tax Amount" = sum(UTGSTAmt),
	"Cess Rate" = max(CESSPer),
	"Cess Amount" = sum(CESSAmt),
	"AddlCess Rate" = max(ADDLCESSPer),
	"AddlCess Amount" = sum(ADDLCESSAmt) 
	 from BillAbstract BA Left Join BillDetail BD On BA.BillID = BD.BillID 
	 Left Join Items I On I.Product_Code = BD.Product_Code 
	 Left Join #TempTaxDet GBT On GBT.BillID = BD.BillID and GBT.BillID = BA.BillID 
	 and GBT.Product_Code = BD.Product_Code and I.Product_Code = GBT.Product_Code 
	 and GBT.Tax_Code = BD.TaxCode and GBT.SerialNo = BD.Serial And IsNull(BA.GSTEnableFlag,0) = 1
	 Inner Join Tax T ON T.Tax_Code = BD.TaxCode 
	 Left join Vendors V On BA.VendorID = V.VendorID 
	 Where BA.BillID = (select distinct TaxCode  from  #tmpTaxCode where Id = 1) 
	 and BD.TaxCode = (select distinct TaxCode  from  #tmpTaxCode where Id = 2)
	 And (BA.Status & 192)=0    
	 Group by BA.BillID ,BD.Product_Code ,I.ProductName  ,BD.MRPPerPack ,Description ,BD.PurchasePrice ,I.HSNNumber,
	 I.UOM1_Conversion, I.UOM2_Conversion, I.UOM,I.UOM1,I.UOM2 ,isnull(T.CS_TaxCode,0)
	 
	 
End
Else
Begin
	Select  AdjustmentID , Product_Code, Tax_Code ,SerialNo,  
	SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End), 
	SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Value Else 0 End), 
	CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End), 
	CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Value Else 0 End),  
	IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End), 
	IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Value Else 0 End), 
	UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End), 
	UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Value Else 0 End),
	CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
	CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Value Else 0 End),
	ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
	ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Value Else 0 End) Into #TempPRTTaxDet
	From PRTaxComponents ITC
	Join TaxComponentDetail TCD 
	On TCD.TaxComponent_code = ITC.Tax_Component_Code
	Group By AdjustmentID, Product_Code, Tax_Code,SerialNo

 -- PurChase Return
	Insert Into #TempPurTaxItemDet
	Select Cast(AR.AdjustmentID as Nvarchar(255)) ,ARD.Product_Code ,I.ProductName  ,IsNull(ARD.MRPPerPack,0) ,
	"Quantity" = (Case When @UOM = 'UOM1' then (sum(ARD.Quantity))/Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End
		When @UOM = 'UOM2' then (sum(ARD.Quantity))/Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End
		Else (sum(ARD.Quantity))
	End),
	"UOM" = Case When @UOM = 'UOM1' Then (Select Top 1 UOM.Description From UOM Where UOM.UOM = I.UOM1)
					When @UOM = 'UOM2' Then (Select Top 1 UOM.Description From UOM Where UOM.UOM = I.UOM2)
					Else (Select Top 1 UOM.Description From UOM Where UOM.UOM = I.UOM) End,

	"Rate" = ( Case When @UOM = 'UOM1' then (ARD.Rate) * Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End
				When @UOM = 'UOM2' then (ARD.Rate) * Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End
						Else (ARD.Rate)
 				End),

	sum(ARD.Rate * ARD.Quantity)  as "Goods Value",
	0 as "Total Discount" ,
	sum(ARD.Rate * ARD.Quantity )  as "Gross Amount",
	sum(ARD.TaxAmount )  as " Total Tax Value",
	sum(ARD.Total_Value )  as "Total Amount",
	IsNull(ARD.HSNNumber,'') ,
	sum(ARD.Rate * ARD.Quantity) as "Taxable Sales Value",
	"CGST Tax Rate" = max(CGSTPer),
	"CGST Tax Amount" = sum(CGSTAmt),
	"SGST Tax Rate" = Case When isnull(T.CS_TaxCode,0) = 0 Then MAX(ARD.Tax) Else max(SGSTPer) End, 
	"SGST Tax Amount" = Case When isnull(T.CS_TaxCode,0) = 0 Then sum(ARD.TaxAmount) Else sum(SGSTAmt) End, 
	"IGST Tax Rate" = max(IGSTPer),
	"IGST Tax Amount" = sum(IGSTAmt),
	"UTGST Tax Rate" = max(UTGSTPer),
	"UTGST Tax Amount" = sum(UTGSTAmt),
	"Cess Rate" = max(CESSPer),
	"Cess Amount" = sum(CESSAmt),
	"AddlCess Rate" = max(ADDLCESSPer),
	"AddlCess Amount" = sum(ADDLCESSAmt) 
	 from AdjustmentReturnAbstract AR Left Join AdjustmentReturnDetail ARD On AR.AdjustmentID  = ARD.AdjustmentID 
	 Left Join Items I On I.Product_Code = ARD.Product_Code 
	 Left Join #TempPRTTaxDet PRT On PRT.AdjustmentID  = ARD.AdjustmentID  and PRT.Product_Code  = ARD.Product_Code 
	 and PRT.Tax_Code  = ARD.Tax_Code  and PRT.SerialNo  = ARD.SerialNo And IsNull(AR.GSTFlag,0) = 1
	 Inner Join Tax T ON T.Tax_Code = Isnull(ARD.Tax_Code,0)  
	 Left join Vendors V On AR.VendorID = V.VendorID 
	 Where AR.AdjustmentID = (select distinct TaxCode  from  #tmpTaxCode where Id = 1)  
	 and ARD.Tax_Code  = (select distinct TaxCode from  #tmpTaxCode where Id = 2)
	 And (Isnull(AR.Status,0) & 192) = 0  
	 Group by AR.AdjustmentID ,ARD.Product_Code ,I.ProductName  ,ARD.MRPPerPack , Description ,ARD.HSNNumber,
	 I.UOM1_Conversion, I.UOM2_Conversion,I.UOM,I.UOM1,I.UOM2,isnull(T.CS_TaxCode,0), ARD.Rate
	 
	 Drop table #TempPRTTaxDet
End 
	 
	 Select BillID,[Item Code] ,[Item Name] ,[MRP Per PAC],Quantity ,UOM ,Rate ,[Goods Value] ,[Total Discount],
	 [Gross Amount] ,[Total Tax Value] ,[Total Amount] ,[HSN Code],[Taxable Sales Value],
	 [CGST Tax Rate] ,[CGST Tax Amount],
	 "SGST Tax Rate" = Case When @UTGST_flag = 1 Then [UTGST Tax Rate] Else [SGST Tax Rate] End ,
	 "SGST Tax Amount" = Case When @UTGST_flag = 1 Then [UTGST Tax Amount] Else [SGST Tax Amount] End, 
	 [IGST Tax Rate] ,[IGST Tax Amount] ,[Cess Rate] ,[Cess Amount] ,
	 [AddlCess Rate],[AddlCess Amount] from #TempPurTaxItemDet Order by BillID


Drop table #TempPurTaxItemDet
Drop table #tmpTaxCode
Drop table #TempTaxDet

