Create Procedure mERP_sp_SaveRFAAbstract(  
 @RFADocID Int,  
 @DocID Int,  
 @SchType nVarchar(255),  
 @ActCode nVarchar(255),  
 @Desc nVarchar(255),   
 @ActiveFrom DateTime,  
 @ActiveTo DateTime,  
 @PayoutFrom DateTime,  
 @PayoutTo DateTime,  
 @DocRef Int,  
 @Division nVarchar(255),  
 @SubCategory nVarchar(255),  
 @MarketSKU nVarchar(255),  
 @SystemSKU nVarchar(255),  
 @UOM nVarchar(255),  
 @SaleQty Decimal(18,6),  
 @SaleValue Decimal(18,6),  
 @PromotedQty Decimal(18,6),  
 @PromotedValue Decimal(18,6),  
 @FreeBaseUOM nVarchar(255),  
 @RebateQty Decimal(18,6),  
 @RebateValue Decimal(18,6),  
 @BudgetedQty Decimal(18,6),  
 @BudgetedValue Decimal(18,6),   
 @SubmissionDate DateTime,  
 @AppOn nVarchar(255),   
 @SalvageQty Decimal(18, 6) = 0,   
 @SalvageValue Decimal(18, 6) = 0,  
 @DamageOption Nvarchar(100) = '',
 @UserName nvarchar(50) = '')  
As  
Begin  
 Declare @TaxConfigFlag as Int  
 Declare @SlabType as Int  
   
 Select @SlabType = SlabType From tbl_mERP_SchemeSlabDetail   
 Where SchemeID = @DocID  
  
 If @SlabType = 3  
  Select @TaxConfigFlag = IsNull(Flag, 0) From tbl_merp_ConfigAbstract   
  Where ScreenCode = 'RFA01'  
 Else  
  /* Tax Config flag for Credit Note */  
  Select @TaxConfigFlag = IsNull(Flag, 0) From tbl_merp_ConfigAbstract   
  Where ScreenCode = 'RFA02'  
  
     
  
 Insert Into tbl_mERP_RFAAbstract (RFADocID, DocumentID, SchemeType, ActivityCode, Description,  
  ActiveFrom, ActiveTo, PayoutFrom, PayoutTo, DocReference, Division, SubCategory, MarketSKU, SystemSKU,  
  UOM, SaleQty, SaleValue, PromotedQty, PromotedValue, FreeBaseUOM, RebateQty, RebateValue, BudgetedQty, BudgetedValue,  
  SubmissionDate, Appon, Status, CreationDate,ModifiedDate,TaxConfig, SalvageQty, SalvageValue, DamageOption, UserName)    
 Values(  
  @RFADocID,  
  @DocID,  
  @SchType,  
  @ActCode,  
  @Desc,  
  @ActiveFrom,  
  @ActiveTo,  
  @PayoutFrom,  
  @PayoutTo,  
  @DocRef,  
  @Division,  
  @SubCategory,  
  @MarketSKU,  
  @SystemSKU,  
  @UOM,  
  @SaleQty,  
  @SaleValue,  
  @PromotedQty,  
  @PromotedValue,  
  @FreeBaseUOM,  
  @RebateQty,  
  @RebateValue,  
  @BudgetedQty,  
  @BudgetedValue,   
  @SubmissionDate,  
  @AppOn,  
  0,  
  GetDate(),  
  Null,@TaxConfigFlag,   
  @SalvageQty,   
  @SalvageValue,  
  @DamageOption,
  @UserName)  
 Select @@Identity  
End  
