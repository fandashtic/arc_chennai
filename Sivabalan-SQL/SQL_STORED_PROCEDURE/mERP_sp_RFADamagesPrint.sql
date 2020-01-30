
  
Create Procedure mERP_sp_RFADamagesPrint(@RFADocID Int)    
As    
Declare @RFA_Value Decimal(18,6)    
Create Table #tempDamagesRFAAbstract(RFAID Int, Activity_Code nVarchar(100), [Description] nVarchar(255), RFA_Period nVarchar(255), RFA_Value Decimal(18,6), Submission_Date nVarchar(255) )    
Create Table #tempDamagesRFADetail(Item_Code nVarchar(255), Item_Name nVarchar(255), Category nVarchar(255), UOM nVarchar(50), RFA_Qty Decimal(18, 6), Total_Amount Decimal(18,6), Salvage_Qty Decimal(18,6), Salvage_Value Decimal(18,6), Net_Qty Decimal(18,6), RFA_Value Decimal(18,6))    
    
------Display Scheme Abstract    
 Insert Into #tempDamagesRFAAbstract    
 Select   
 "RFAID" = RFAID,     
 "Activity_Code" = ActivityCode,    
 "Description" = Description,    
 "RFA_Period" = (Convert(varchar, PayoutFrom, 103) + ' - ' + Convert(varchar, PayoutTo, 103)),    
 "RFA_Value" = Sum(IsNull(RebateValue, 0)),   
 "Submission_Date" = Convert(nVarchar, dbo.stripTimeFromdate(SubmissionDate), 103)    
 From tbl_mERP_RFAAbstract     
 Where  SchemeType = 'Damages' And RFADocID = (@RFADocID)and Isnull(Status,0)<>5   
 Group By ActivityCode, Description,  PayoutFrom, PayoutTo, SubmissionDate, RFAID   
        
------Display Scheme Detail         
 Insert Into #tempDamagesRFADetail Select     
 "Item_Code" = RD.SystemSKU,   
 "Item_Name" = ISNULL((Select ProductName From Items Where Product_Code = RD.SystemSKU), '') ,   
 "Category" = RD.Division,   
 "UOM" = RD.UOM,   
 "RFA_Qty" = ISNULL(RD.SaleQty, 0),   
 "Total_Amount" = ISNULL(RD.SaleValue, 0),   
 "Salvage_Qty" = ISNULL(RD.SalvageQty, 0),   
 "Salvage_Value" = ISNULL(RD.SalvageValue, 0),   
 "Net_Qty" = ISNULL(RD.SaleQty, 0) - ISNULL(RD.SalvageQty, 0),   
 "RFA_Value" = ISNULL(RD.RebateValue, 0)  
 From tbl_mERP_RFAAbstract RD   
 Join #tempDamagesRFAAbstract TD On TD.RFAID = RD.RFAID   
Order by RD.RFAID
   
    
Select Activity_Code,[Description],RFA_Period,sum(isnull(RFA_Value,0)) as RFA_Value,Submission_Date From #tempDamagesRFAAbstract    
Group by Activity_Code,[Description],RFA_Period,Submission_Date

    
Select Item_Code , Item_Name , Category , UOM , RFA_Qty , Total_Amount , Salvage_Qty , Salvage_Value , Net_Qty , RFA_Value From #tempDamagesRFADetail    
    
Select  '', '', '', '', '', '',  '', '', '', Sum(RFA_Value) From #tempDamagesRFADetail     
    
    
Drop table #tempDamagesRFAAbstract    
Drop table #tempDamagesRFADetail    
      
