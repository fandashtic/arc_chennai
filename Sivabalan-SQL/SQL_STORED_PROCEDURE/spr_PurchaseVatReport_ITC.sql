Create Procedure spr_PurchaseVatReport_ITC(@Fromdate datetime,@Todate datetime,@Vendor nvarchar(2550),@TaxCompBreakup nvarchar(10), @TaxType nvarchar(100) = '%' )
As    
Declare @Trantype Int  
Declare @SQL varchar(8000)
Declare @TaxSuffered decimal(18,6)    
Declare @Tranid int    
Declare @ValAmount decimal(18,6)    
Declare @VatAmount Decimal(18,6)    
Declare @taxid int    
Declare @VoucherPrefix nvarchar(20)  
Declare @ARVoucherPrefix nvarchar(20)      
Declare @Delimeter nvarchar(1)    
Declare @Counter Int  

--Variables Included for TaxComp. Split-Up    
Declare @TaxCode Int    
Declare @Locality Int    
Declare @TaxDesc nvarchar(510)    
Declare @ComponentDesc nvarchar(100)    
Declare @ComponentCode Int    
Declare @CompTaxAmt Decimal(18,6)    
Declare @CompTaxPer Decimal(18,6)    

Declare @TaxHead nVarchar(1000)
Declare @TaxCompHead nVarchar(1000)

Set @Delimeter = char(15)    
declare @temp datetime 
Set DATEFormat DMY
set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)
if(@FROMDATE > @temp )
begin
select 0,'This report cannot be generated for GST period' as Reason
goto GSTOut
 end               
                 
if(@TODATE > @temp )
begin
set @TODATE  = @temp 
--goto GSTOut
end                 
  
Create table #tmpVendor(VendorName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
  
Create Table #VatTempPurchase(  
[TranID] Int, [TranType] Int, [PurchaseDate] Datetime,    
[SerialNo] Varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[DocID] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[Vendor(or)Branch] nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[Pan Number] nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[Locality] Int,  
[TotalValue] Decimal(18,6),  
[STIExemptedValue] Decimal(18,6),  
[ExemptedValue] Decimal(18,6),
[TaxType]  nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS  
)    
  
Set @vatAmount=0    
Set @ValAmount=0    
Set @SQL =N''   
  
If @TaxCompBreakup = N'%' Or Isnull(@TaxCompBreakup,'') = ''   
 Set @TaxCompBreakup = N'No'    
  
If @Vendor='%'             
  Insert into #tmpVendor select Vendor_Name from Vendors Union select Warehouse_Name from WareHouse            
Else            
  Insert into #tmpVendor select * from dbo.sp_SplitIn2Rows(@VENDOR,@Delimeter)     
  
Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid=N'BILL'      
Select @ARVoucherPrefix=Prefix From VoucherPrefix Where Tranid=N'PURCHASE RETURN'  
  
Create Table #TaxComponentDetail    
(    
[TaxCode] Int, [TaxDesc] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, [CompCode] Int,     
[CompDesc] nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, [CompPercentage] decimal(18,6),    
[LSTFlag] Int    
)      
Create Table #TaxType
(
[TaxTypeId] Int
)

If @TaxType = N'%' or @TaxType = N'ALL'
    Insert Into #TaxType select TaxId from tbl_mERP_Taxtype 
ELSE
    Insert Into #TaxType select TaxId from tbl_mERP_Taxtype Where TaxType
        In ( Select * from dbo.sp_SplitIn2Rows(@TaxType, @Delimeter))


Create Table #AdjRetTaxDetail  
([AdjustmentID] Int, [TranType] Int, AdjustmentDate datetime,
[SerialNo] Varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[DocID] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[Vendor_Name] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,       
Total_Value decimal (18, 6),
Locality Int, 
[Product_Code] nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[BatchCode] Int, [TaxCode] Int)  

--Tax component details  
Insert Into #TaxComponentDetail    
select tx.Tax_Code,Tax_Description,tc.TaxComponent_Code,    
TaxComponent_desc,SP_Percentage,tc.LST_Flag    
from Tax tx, TaxComponents tc,TaxComponentDetail tcd       
Where Tx.Tax_Code = TC.Tax_Code    
and Tc.TaxComponent_Code = Tcd.TaxComponent_Code    
order by tx.Tax_Code,tcd.TaxComponent_Code   

    
--TaxCode retrieved for PurchaseReturn from BatchProducts  
Select AdjustmentID, trantype, AdjustmentDate, serial,
Reference, Vendor_Name, sum(Total_Value) Total_Value, locality,
Product_Code, Batch_Code, taxcode Into #stk
from (
    Select ARD.AdjustmentID, 3 trantype, AdjustmentDate, @ARVoucherPrefix + Cast(ARA.DocumentId as varchar) serial,
    Reference, Vendor_Name, 0-ARD.Total_Value Total_Value, #TaxType.TaxTypeId locality,
    ARD.Product_Code, Batch_Products.Batch_Code,  
    Isnull(Batch_Products.GRNTaxID, 
        Case when IsNull(Batch_Products.Taxtype, 1) = 1  then 
            (Select max(Isnull(Tax.Tax_Code,0)) from Tax 
			Left Outer Join AdjustmentReturnDetail on ARD.Tax = Tax.Percentage) 
            when IsNull(Batch_Products.Taxtype, 1) = 2 then 
            (Select max(Isnull(Tax.Tax_Code,0)) from Tax 
			Left Outer Join AdjustmentReturnDetail on  ARD.Tax = Tax.cst_Percentage) 
        End ) taxcode  
    from Batch_Products, AdjustmentReturnDetail ARD,   
    AdjustmentReturnAbstract ARA, Vendors, #TmpVendor, #TaxType
    where (Isnull(ARA.Status,0) & 192) = 0  
    and IsNull(Batch_Products.TaxType, 1) = #TaxType.TaxTypeId
    and ARA.AdjustmentID = ARD.AdjustmentID  
    and ARD.BatchCode = Batch_Products.batch_Code   
    and ARD.Product_Code = Batch_Products.Product_Code    
    and Vendors.Vendor_Name = #TmpVendor.VendorName   
    and ARA.VendorID = Vendors.VendorID  
    and ARA.AdjustmentDate between @FromDate and @ToDate  ) tmp

group by
AdjustmentID, trantype, AdjustmentDate, serial,
Reference, Vendor_Name, locality,
Product_Code, Batch_Code, taxcode 

select ( Case when trantype = 1 or trantype = 3 then percentage Else cst_percentage end) pcnt, stk.* Into #tmpStk 
	from #Stk stk Join tax on stk.taxcode = tax.tax_code 
Delete from #tmpstk where pcnt > 0 and total_value = 0

Insert Into #AdjRetTaxDetail  
select AdjustmentID, trantype, AdjustmentDate, serial, Reference, Vendor_Name, Total_Value, 
locality, Product_Code, Batch_Code, taxcode from #tmpstk

--Tran Type 1 - STI, 2 - Purchase, 3 - Purchase Return  
  
Insert into #VatTempPurchase([TranId],[TranType],[PurchaseDate],[SerialNo],[DocID],  
            [Vendor(or)Branch],[TotalValue],[Locality],[TaxType])    
Select StkIn.DocSerial,1,StkIn.DocumentDate,StkIn.DocPrefix + Cast(StkIn.DocumentId as varchar),    
StkIn.DocPrefix + Cast(StkIn.DocumentId as varchar),WareHouse.WareHouse_Name,StkIn.NetValue, IsNull(StkIn.TaxType,1), TxType.TaxType
From StockTransferInAbstract StkIn,WareHouse, #TmpVendor, tbl_mERP_TaxType TxType, #TaxType
Where (StkIn.Status & 192)=0  
And TxType.TaxID = IsNull(StkIn.TaxType,1)
And #TaxType.[TaxTypeId] = IsNull(StkIn.TaxType, 1)
And StkIn.WareHouseID=WareHouse.WareHouseID    
And Warehouse.Warehouse_Name = #TmpVendor.VendorName  
And Stkin.Documentdate between @Fromdate And @Todate    
Union    
Select BillAb.BillID,2,BillAb.BillDate, @VoucherPrefix + Cast(BillAb.DocumentId as varchar),    
DocIDReference,Vendors.Vendor_Name,(BillAb.Value+BillAb.taxAmount),#TaxType.[TaxTypeId] as Locality, TxType.TaxType
From BillAbstract BillAb,Vendors, #TmpVendor, tbl_mERP_TaxType TxType, #TaxType
Where (BillAb.Status & 192)=0    
and TxType.TaxID = IsNull(BillAb.TaxType,1)
and #TaxType.[TaxTypeId] = IsNull(BillAb.TaxType, 1)
and BillAb.VendorId=Vendors.VendorId    
and Vendors.Vendor_Name = #TmpVendor.VendorName   
and BillAb.BillDate between @Fromdate And @Todate    
Union
Select AdjustmentID, TranType, AdjustmentDate, SerialNo,  
DocID, Vendor_Name, sum(Total_Value) Total_Value, Locality, Case when Locality = 1 then 'LST' when Locality = 2 then 'CST' when Locality = 3 then 'FLST' End 
From #AdjRetTaxDetail  
group by AdjustmentID, TranType, AdjustmentDate, SerialNo,  DocID, Vendor_Name, 
Locality, Case when Locality = 1 then 'LST' when Locality = 2 then 'CST' when Locality = 3 then 'FLST' End 

-- Column Header Creation Part  
select * Into #tmp from  
(  
Select Distinct(TaxCode), [ID]=1, locality    
From StockTransferIndetail StkIndet,Tax, #VatTempPurchase    
Where Isnull(StkInDet.TaxSuffered,0)<>0   
and StkIndet.DocSerial=#VatTempPurchase.TranID    
and StkInDet.taxCode = Tax.Tax_Code  
and #VatTempPurchase.TranType = 1  
Union   
Select Distinct bdet.TaxCode, [ID]=2, locality  
From Billdetail Bdet,Tax, #VatTempPurchase    
Where Isnull(Bdet.TaxSuffered,0)<>0     
And Bdet.TaxCode = Tax.Tax_Code    
And Bdet.BillID = #VatTempPurchase.TranID    
And #VatTempPurchase.TranType = 2  
Union   
Select Distinct #AdjRetTaxDetail.TaxCode, [ID]=2, locality
From Tax, #AdjRetTaxDetail
Where #AdjRetTaxDetail.TaxCode = Tax.Tax_Code
) As temp1  
Order by Temp1.[ID]  

Declare TaxFetch Cursor For    
select distinct taxcode, Id, Case when Locality = 2 then 0 Else 1 End from #tmp   
 Open TaxFetch    
 Fetch next from Taxfetch into @TaxCode, @TranType, @Locality
 While(@@FETCH_STATUS =0)    
 begin
  Set @TaxHead = dbo.mERP_fn_GetTaxColFormat_locality(@TaxCode, 0, 0)
  If @Trantype = 1 and @Locality = 1
  Begin                                
     Set @SQL= N'Alter Table #VatTempPurchase Add [STI(' + @TaxHead + N' Purchase Value)] decimal(18,6); '    
     Set @SQL= @SQL + N'Alter Table #VatTempPurchase Add [STI(' + @TaxHead + N' Tax Amount)] decimal(18,6) '     
  End  
  Else If @Trantype = 1 and @Locality = 0
  Begin
     Set @SQL= N'Alter Table #VatTempPurchase Add [CST_STI(' + @TaxHead + N' Purchase Value)] decimal(18,6); '
     Set @SQL= @SQL + N'Alter Table #VatTempPurchase Add [CST_STI(' + @TaxHead + N' Tax Amount)] decimal(18,6) '
  End
  Else If @Trantype = 2 and @Locality = 1
  Begin
     Set @SQL= N'Alter Table #VatTempPurchase Add [' + @TaxHead + N' Purchase Value] decimal(18,6); '
     Set @SQL= @SQL + N'Alter Table #VatTempPurchase Add [' + @TaxHead + N' Tax Amount] decimal(18,6) '
  End
  Else If @Trantype = 2 and @Locality = 0
  Begin
     Set @SQL= N'Alter Table #VatTempPurchase Add [CST_' + @TaxHead + N' Purchase Value] decimal(18,6); '
     Set @SQL= @SQL + N'Alter Table #VatTempPurchase Add [CST_' + @TaxHead + N' Tax Amount] decimal(18,6) '
  End
  Exec(@SQL)  
    --//Tax Component Split up Column addition for STI Starts //  
    If @TaxCompBreakup = N'Yes'     
      Begin     
       If exists(select CompCode from #TaxComponentDetail where TaxCode = @TaxCode)    
         Begin    
           Declare ComponentFetch Cursor For    
           select CompCode from #TaxComponentDetail
           where TaxCode = @TaxCode and LSTFlag = @Locality
           order by CompCode    
     
           Open ComponentFetch    
           Fetch next from Componentfetch into @ComponentCode
           While(@@FETCH_STATUS = 0)    
             begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat_Locality(@TaxCode, @ComponentCode, @Locality)
                If @Trantype = 1 and @Locality = 1
                 Set @SQL = N'Alter Table #VatTempPurchase Add [' +  N'STI(' + @TaxCompHead + N')] decimal(18,6) '    
                Else If @Trantype = 1 and @Locality = 0
                 Set @SQL = N'Alter Table #VatTempPurchase Add [' +  N'CST_STI(' + @TaxCompHead + N')] decimal(18,6) '    
                Else If ( @Trantype = 2 or @Trantype = 3) and @Locality = 1
				 Set @SQL = N'Alter Table #VatTempPurchase Add [' + @TaxCompHead + N'] decimal(18,6) '    
                Else If ( @Trantype = 2 or @Trantype = 3) and @Locality = 0
				 Set @SQL = N'Alter Table #VatTempPurchase Add [CST_' + @TaxCompHead + N'] decimal(18,6) '    
                Exec(@SQL)    
                Fetch next from ComponentFetch into @ComponentCode
             end    
           Close ComponentFetch    
           Deallocate ComponentFetch      
         End    
      End   
    --//Tax Component Split up Column addition for STI Ends //  
    Fetch next from Taxfetch into @TaxCode, @TranType, @Locality  
  End    
  Close TaxFetch    
  Deallocate TaxFetch    

   Select AdjDet.AdjustmentID,#VatTempPurchase.Trantype,   
    "Gross Amount" =  Case AdjDet.Tax When 0 Then (AdjDet.Total_Value * - 1)  
                      Else (AdjDet.Total_Value - AdjDet.TaxAmount) * -1  
--                       Else (AdjDet.Total_Value - (AdjDet.Total_Value - (Quantity * Rate))) * -1  
    End,  
    "TS" = AdjDet.tax,
-- 		(AdjDet.Quantity * Rate)- AdjDet.Total_Value,
	"TaxAmount" =  (AdjDet.TaxAmount) * -1 ,
		Items.TaxSuffered, 

    "TaxCode" = (Select top 1 #AdjRetTaxDetail.TaxCode from #AdjRetTaxDetail Left Outer Join Tax ON #AdjRetTaxDetail.TaxCode = Tax.Tax_Code
      where AdjDet.AdjustmentID = #AdjRetTaxDetail.AdjustmentID  
      And #AdjRetTaxDetail.BatchCode = AdjDet.BatchCode), 

    "Tax_Description" = (Select top 1 Tax.[Tax_Description] from #AdjRetTaxDetail Left Outer Join Tax ON #AdjRetTaxDetail.TaxCode = Tax.Tax_Code
      where AdjDet.AdjustmentID = #AdjRetTaxDetail.AdjustmentID  
      And #AdjRetTaxDetail.BatchCode = AdjDet.BatchCode), #VatTempPurchase.[Locality] Into #PR
   From AdjustmentReturnDetail AdjDet, Items,#VatTempPurchase, Batch_products BP, #TaxType
   Where AdjDet.Product_Code=Items.Product_Code    
   And AdjDet.Batchcode = BP.Batch_code
   And IsNull(BP.TaxType, 1) = #TaxType.TaxTypeId
   And AdjDet.AdjustmentID = #VatTempPurchase.TranID    
   And IsNull(BP.TaxType, 1) = #VatTempPurchase.Locality
   And #VatTempPurchase.Trantype = 3    


  -- Tax Computation & Split-up     
 select * Into #TaxUpdate from   
 (  
   Select StkinDet.DocSerial,#VatTempPurchase.Trantype,"Gross Amount" = (StkinDet.TotalAmount-StkinDet.TaxAmount), "TS"=StkinDet.taxSuffered,  
   StkinDet.TaxAmount,Items.TaxSuffered,Tax.Tax_Code,Tax.Tax_Description,#VatTempPurchase.[Locality]      
   From StockTransferIndetail StkinDet
   Inner Join Items ON StkinDet.Product_Code=Items.Product_Code
   Inner Join #VatTempPurchase ON StkIndet.DocSerial=#VatTempPurchase.TranID
   Left Outer Join Tax ON StkInDet.taxCode = Tax.Tax_Code   
   Where
		#VatTempPurchase.Trantype = 1    
   Union All  
   Select BDet.BillID,#VatTempPurchase.Trantype,"Gross Amount" = BDet.Amount, "TS" = Isnull(BDet.taxSuffered,0),BDet.TaxAmount,  
   Items.TaxSuffered, BDet.TaxCode,Tax.Tax_Description, #VatTempPurchase.Locality  
   From BillDetail BDet
   Inner Join Items ON BDet.Product_Code = Items.Product_Code
   Inner Join #VatTempPurchase ON BDet.BillID = #VatTempPurchase.TranID
   Left Outer Join Tax ON BDet.TaxCode = Tax.Tax_Code
   Where   
		#VatTempPurchase.Trantype = 2  
   Union All  

   Select AdjustmentID, Trantype, sum([Gross Amount]) [Gross Amount],  
    TS, sum(taxamount) taxamount,TaxSuffered, TaxCode, [Tax_Description], [Locality] 
    from #PR group by AdjustmentID, Trantype,   
    TS, TaxSuffered, TaxCode, [Tax_Description], [Locality] 

  ) As Temp2   
  Order by Temp2.[TranType]   

 Declare TaxUpdate Cursor For     
  select Docserial, trantype, [Gross amount], ts, taxamount, tax_code, Locality from #TaxUpdate
  Open TaxUpdate                  
  Fetch next from TaxUpdate into @Tranid,@TranType,@ValAmount,@taxSuffered,@VatAmount,@TaxCode,@Locality     
  While(@@FETCH_STATUS =0)    
   begin    
    If (@taxSuffered=0)    
      Begin  
        If @TranType = 1   
        Begin    
         Update #VatTempPurchase Set [STIExemptedValue]= isnull([STIExemptedValue],0) + @ValAmount   
          Where TranID=@Tranid and Trantype = @TranType           
         Update #VatTempPurchase Set [STIExemptedValue]=null where [STIExemptedValue] = 0    
        End    
       Else   
        Begin    
         Update #VatTempPurchase Set [ExemptedValue]= isnull([ExemptedValue],0) + @ValAmount   
          Where TranID=@Tranid and Trantype = @TranType           
         Update #VatTempPurchase Set [ExemptedValue]=null where [ExemptedValue] = 0    
        End    
     End   
    Else    
     begin
		Set @TaxHead = dbo.mERP_fn_GetTaxColFormat_locality(@TaxCode, 0, 0)
        If @TranType = 1 and (Case when @Locality = 2 then 0 Else 1 End ) = 1 
        Begin  
         Set @SQL=N'Update #VatTempPurchase Set [STI(' + @TaxHead + N' Purchase Value)]=isnull([STI(' + @TaxHead + ' Purchase Value)],0) + ' + Cast(@ValAmount as varchar)     
         + N', [STI(' + @TaxHead + N' Tax Amount)]=isnull([STI(' + @TaxHead + N' Tax Amount)],0) + ' + Cast(@VatAmount as Nvarchar)    
           + N' Where TranID='+ cast(@TranID as varchar)   
           + N' and TranType='+ cast(@TranType as varchar)+ N' and Locality=' + cast(@Locality as varchar)
         exec(@SQL)   
           set @SQL = N'Update #VatTempPurchase Set [STI(' + @TaxHead + N' Purchase Value)] = NULL where [STI(' + @TaxHead + N' Purchase Value)]=0' + N' and Locality=' + cast(@Locality as varchar)   
          exec(@SQL)  
          End  
        Else If @TranType = 1 and (Case when @Locality = 2 then 0 Else 1 End )  = 0 

        Begin  
         Set @SQL=N'Update #VatTempPurchase Set [CST_STI(' + @TaxHead + N' Purchase Value)]=isnull([CST_STI(' + @TaxHead + ' Purchase Value)],0) + ' + Cast(@ValAmount as varchar)     
         + N', [CST_STI(' + @TaxHead + N' Tax Amount)]=isnull([CST_STI(' + @TaxHead + N' Tax Amount)],0) + ' + Cast(@VatAmount as Nvarchar)    
           + N' Where TranID='+ cast(@TranID as varchar)   
           + N' and TranType='+ cast(@TranType as varchar)+ N' and Locality=' + cast(@Locality as varchar)
          exec(@SQL)   
           set @SQL = N'Update #VatTempPurchase Set [CST_STI(' + @TaxHead + N' Purchase Value)] = NULL where [CST_STI(' + @TaxHead + N' Purchase Value)]=0'+ N' and Locality=' + cast(@Locality as varchar)
          exec(@SQL)  
          End  
        Else If ( @TranType = 2 or @TranType = 3)  and (Case when @Locality = 2 then 0 Else 1 End )  = 1 
          Begin   
         Set @SQL=N'Update #VatTempPurchase Set [' + @TaxHead + N' Purchase Value]=isnull([' + @TaxHead + ' Purchase Value],0) + ' + Cast(@ValAmount as varchar)     
         + N', [' + @TaxHead + N' Tax Amount]=isnull([' + @TaxHead + N' Tax Amount],0) + ' + Cast(@VatAmount as Nvarchar)    
           + N' Where TranID='+ cast(@TranID as varchar)   
           + N' and TranType='+ cast(@TranType as varchar)+ N' and Locality=' + cast(@Locality as varchar)
           exec(@SQL)   
           set @SQL = N'Update #VatTempPurchase Set [' + @TaxHead + N' Purchase Value] = NULL where [' + @TaxHead + N' Purchase Value]=0'+ N' and Locality=' + cast(@Locality as varchar)
           exec(@SQL)   
          End  
        Else If ( @TranType = 2 or @TranType = 3)  and (Case when @Locality = 2 then 0 Else 1 End )  = 0
          Begin   
         Set @SQL=N'Update #VatTempPurchase Set [CST_' + @TaxHead + N' Purchase Value]=isnull([CST_' + @TaxHead + ' Purchase Value],0) + ' + Cast(@ValAmount as varchar)     
         + N', [CST_' + @TaxHead + N' Tax Amount]=isnull([CST_' + @TaxHead + N' Tax Amount],0) + ' + Cast(@VatAmount as Nvarchar)    
           + N' Where TranID='+ cast(@TranID as varchar)   
           + N' and TranType='+ cast(@TranType as varchar)+ N' and Locality=' + cast(@Locality as varchar)
           exec(@SQL)   
           set @SQL = N'Update #VatTempPurchase Set [CST_' + @TaxHead + N' Purchase Value] = NULL where [CST_' + @TaxHead + N' Purchase Value]=0'+ N' and Locality=' + cast(@Locality as varchar)
           exec(@SQL)   
          End  

      --//Tax Component Split up for Tax Amount starts //  
       If @TaxCompBreakup = N'Yes'     
        Begin     
         If exists(select CompCode from #TaxComponentDetail where TaxCode = @TaxCode)   
          Begin         
           Declare ComponentFetch Cursor For    
           select CompCode,CompPercentage    
           from #TaxComponentDetail where TaxCode = @TaxCode   
           and LSTFlag = (Case when @Locality = 2 then 0 Else 1 End)
           Order by CompCode    

           Open ComponentFetch    
           Fetch next from Componentfetch into @ComponentCode,@CompTaxPer
           While(@@FETCH_STATUS = 0)  
              begin    
               Set @CompTaxAmt = Cast((@VatAmount * ((@CompTaxPer/@TaxSuffered))) as Decimal(18,6))  
			   Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat_locality(@TaxCode, @ComponentCode, (Case when @Locality = 2 then 0 Else 1 End))	
               If @TranType = 1 and ( Case when @Locality = 2 then 0 Else 1 End) = 1 
               Begin   
              	Set @SQL=N'Update #VatTempPurchase Set [' + N'STI('+ @TaxCompHead + N')]=
				isnull([' + N'STI('+ @TaxCompHead + N')],0) + ' + Cast(Isnull(@CompTaxAmt,0) as nvarchar) 
	              + N' Where TranID='+ cast(@TranID as nvarchar)  
	                + N' and TranType='+ cast(@TranType as varchar)+ N' and Locality=' + cast(@Locality as varchar)
	                exec(@SQL)    
               End  
               Else If @TranType = 1 and ( Case when @Locality = 2 then 0 Else 1 End) = 0 
               Begin   
              	Set @SQL=N'Update #VatTempPurchase Set [CST_' + N'STI('+ @TaxCompHead + N')]=
				isnull([CST_' + N'STI('+ @TaxCompHead + N')],0) + ' + Cast(Isnull(@CompTaxAmt,0) as nvarchar) 
	              + N' Where TranID='+ cast(@TranID as nvarchar)  
	                + N' and TranType='+ cast(@TranType as varchar)+ N' and Locality=' + cast(@Locality as varchar)  
	                exec(@SQL)    
               End  

               Else If ( @TranType = 2 or @TranType = 3) and ( Case when @Locality = 2 then 0 Else 1 End ) = 1
               Begin  
	                Set @SQL=N'Update #VatTempPurchase Set [' + @TaxCompHead + N']=
					isnull([' + @TaxCompHead + N'],0) + ' + Cast(Isnull(@CompTaxAmt,0) as nvarchar)     
	              + N' Where TranID='+ cast(@TranID as nvarchar)    
	                + N' and TranType='+ cast(@TranType as varchar)+ N' and Locality=' + cast(@Locality as varchar)   
	                exec(@SQL)    
       		   End    
               Else If ( @TranType = 2 or @TranType = 3) and ( Case when @Locality = 2 then 0 Else 1 End ) = 0
               Begin  
	                Set @SQL=N'Update #VatTempPurchase Set [CST_' + @TaxCompHead + N']=
					isnull([CST_' + @TaxCompHead + N'],0) + ' + Cast(Isnull(@CompTaxAmt,0) as nvarchar)     
	              + N' Where TranID='+ cast(@TranID as nvarchar)    
	                + N' and TranType='+ cast(@TranType as varchar)+ N' and Locality=' + cast(@Locality as varchar)
	                exec(@SQL)    
       		   End    
             Fetch next from Componentfetch into @ComponentCode,@CompTaxPer
            end    
            Close ComponentFetch    
            Deallocate ComponentFetch    
          End    
        End   
      End       
    Fetch next from TaxUpdate into @Tranid,@TranType,@ValAmount,@taxSuffered,@VatAmount,@TaxCode,@Locality     
   End    
  Close TaxUpdate    
  Deallocate TaxUpdate   

   Update V set V.[Pan Number] = dbo.Fn_Get_PANNumber(V.TranId,'Bill','VENDOR') From #VatTempPurchase V,
   BillAbstract B  Where V.TranId = B.BillID
  
   Set @SQL = 'Alter table #VatTempPurchase Drop column Locality,TranType'  
   exec(@SQL)  
   Set @SQL = 'select * from #VatTempPurchase order by [PurchaseDate]'  
   exec(@SQL)  
  
Drop table #VatTempPurchase  
Drop table #TaxComponentDetail    
Drop table #tmpVendor  
Drop table #AdjRetTaxDetail  
  GSTOut:
