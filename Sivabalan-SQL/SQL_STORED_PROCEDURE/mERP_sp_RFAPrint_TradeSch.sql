Create Procedure mERP_sp_RFAPrint_TradeSch(@RFADocIDs nVarchar(4000), @Divisions nVarchar(2000))      
As      
SET NOCOUNT ON     
Begin      
  Declare @Delimeter nVarchar(1)      
  Set @Delimeter =N','       
  Create table #RFADocID(RFADocID int)      
  --Create table #CatGroup(CategoryGroup nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS)      
  Create table #tmpDivision(Division nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS)        
  /* RFA List */      
  Insert into #RFADocID      
  Select * from dbo.sp_SplitIn2Rows(@RFADocIDs,@Delimeter)      
  /*Category List*//*      
  Insert into #CatGroup      
  Select * from dbo.sp_SplitIn2Rows(@CatGroups,@Delimeter)*/      
  /*Category List*/      
  Insert into #tmpDivision      
  Select * from dbo.sp_SplitIn2Rows(@Divisions,@Delimeter)     
  
  Create Table #tmpCount (Rowno int)   
      
  /*Category wist Rebate info*/      
  select * into #tmpDiv from (  
  Select RowNum, Division , Rebt_Val From (      
  Select 1 as RowNum, RFAAbs.Division , Sum(RFAAbs.RebateValue) Rebt_Val       
  From tbl_merp_RFAAbstract RFAabs, #RFADocID tmpRFA, #tmpDivision Div      
  Where tmpRFA.RFADocID = RFAabs.RFADocID and RFAabs.Status <> 5 and Div.Division = RFAabs.Division      
  Group By RFAAbs.Division      
  Union All      
  Select 2 as RowNum, 'Total' as Division, Sum(RFAAbs.RebateValue) Rebt_Val       
  From tbl_merp_RFAAbstract RFAabs, #RFADocID tmpRFA, #tmpDivision Div      
  Where tmpRFA.RFADocID = RFAabs.RFADocID and RFAabs.Status <> 5 and Div.Division = RFAabs.Division)T      
  ) Temp      
  Order by RowNum, Division  
      
  insert into #tmpCount   
  select @@rowcount  
      
  /*Category wist Scheme info*/      
  Create Table #tmpSchInfo(RFADocID int,Division nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS,      
          ActivityCode nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS,       
          Description nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS,       
       Applicable_Period nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,       
       RFA_Period nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,      
       Submit_Date DateTime, RebateValue Decimal(18,6))      
        
  Insert into #tmpSchInfo      
  Select RFAabs.RFADocID, RFAabs.Division, ActivityCode, Description, Convert(nVarchar(10), ActiveFrom,103) + ' - ' +  Convert(nVarchar(10), ActiveTo,103) Applicable_Period,      
  Convert(nVarchar(10), PayoutFrom,103) + ' - ' +  Convert(nVarchar(10), PayoutTo,103) RFA_Period, SubmissionDate, Sum(RebateValue) RebateValue
  From tbl_merp_RFAAbstract RFAabs, #RFADocID tmpRFA, #tmpDivision Div      
  Where tmpRFA.RFADocID = RFAabs.RFADocID and RFAabs.Status <> 5 and Div.Division = RFAabs.Division      
  Group By RFAabs.RFADocID, RFAabs.Division, ActivityCode, Description, ActiveFrom, ActiveTo,PayoutFrom, PayoutTo,SubmissionDate

  insert into #tmpCount   
   select @@rowcount  
  
  /*Scheme wise Category wise Detail*/      
  Create table #tmpCatWiseRFADetail(RFADocID int,       
         Division nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS,       
         UOM nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS,       
         RFAType nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS,       
         SaleQty decimal(18,6), SaleValue decimal(18,6), PromotedQty decimal(18,6), PromotedVal decimal(18,6),       
         TaxPercent decimal(18,6), TaxAmount decimal(18,6), RebateQty decimal(18,6), RebateVal decimal(18,6), OrderBy int)        
  
  
  Insert into #tmpCatWiseRFADetail      
  Select RFAAbs.RFADocID, RFAdet.Division, RFAabs.UOM, RFAdet.LineType, Sum(RFAdet.SaleQty) SaleQty, Sum(RFAdet.SaleValue) SaleValue,       
  Sum(RFAdet.PromotedQty) PromotedQty, Sum(RFAdet.PromotedValue) PromotedVal, Tax_Percentage, Sum(Tax_Amount) TaxAmount,      
  Sum(RFAdet.RebateQty) RebateQty, Sum(RFAdet.RebateValue) RebateVal, 1 as OrderBy
  From tbl_merp_RFAAbstract RFAabs, #RFADocID tmpRFA, tbl_merp_RFADetail RFAdet, #tmpDivision Div      
  Where tmpRFA.RFADocID = RFAabs.RFADocID and RFAabs.Status <> 5 and 
  RFADet.LineType <> 'FREE' and 
  Div.Division = RFAabs.Division and       
  RFAAbs.RFAID = RFADet.RFAID      
  Group By RFAAbs.RFADocID, RFAdet.Division, RFAabs.UOM, RFAdet.LineType, Tax_Percentage
  Union 
  Select RFAAbs.RFADocID, RFAdet.Division, RFAabs.UOM, RFAdet.LineType, Sum(RFAdet.SaleQty) SaleQty, Sum(RFAdet.SaleValue) SaleValue,       
  Sum(RFAdet.PromotedQty) PromotedQty, Sum(RFAdet.PromotedValue) PromotedVal, Tax_Percentage, Sum(Tax_Amount) TaxAmount,      
  Sum(RFAdet.RebateQty) RebateQty, Sum(RFAdet.RebateValue) RebateVal, 2 as OrderBy
  From tbl_merp_RFAAbstract RFAabs, #RFADocID tmpRFA, tbl_merp_RFADetail  RFAdet
  Where tmpRFA.RFADocID = RFAabs.RFADocID and RFAabs.Status <> 5 and 
  RFADet.LineType = 'FREE' and 
  RFAAbs.RFAID = RFADet.RFAID      
  Group By RFAAbs.RFADocID, RFAdet.Division, RFAabs.UOM, RFAdet.LineType, Tax_Percentage
  
  insert into #tmpCount   
  select @@rowcount    
  
  Alter table #tmpDiv Drop column RowNum  
  Select * from #tmpCount   
  Select * from #tmpDiv      
  
  Select * from #tmpSchInfo Order by Division, RFADocID      
  
  Select * from #tmpCatWiseRFADetail Order by Division, RFADocID, OrderBy      
  
  Drop table #tmpDivision      
  Drop table #RFADocID      
  Drop table #tmpSchInfo      
  Drop table #tmpCatWiseRFADetail      
  Drop table #tmpDiv  
End 
