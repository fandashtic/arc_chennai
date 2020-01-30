CREATE Procedure sp_get_splCategorySchemeDetails_MUOM
( @SCHEMEID INT,    
  @PRIMARYQUANTITY Decimal(18,6),  
  @INVOICEAMOUNT Decimal(18,6)=0 )     
As
BEGIN   
IF @INVOICEAMOUNT=0  
 BEGIN  
 Select S.SchemeID, SI.StartValue, SI.EndValue, (Case IsNull(SI.FreeUOM,0) 
	when 0 Then IsNull(SI.FreeValue,0)
	When 1 Then IsNull(SI.FreeValue,0) * (Select UOM1_Conversion From Items Where Items.Product_Code = SI.FreeItem)
	When 2 Then IsNull(SI.FreeValue,0) * (Select UOM2_Conversion From Items Where Items.Product_Code = SI.FreeItem) end) as FreeValue,
 SI.FreeItem, SI.CreationDate, SI.modifiedDate, 
 SI.FromItem, SI.ToItem, SI.PrimaryUOM, SI.FreeUOM, S.SchemeID, S.SchemeNAme, S.SchemeType, S.ValidFrom, 
 S.ValidTo, S.PromptOnly, S.Message, S.Active, S.SchemeDescription, S.SecondaryScheme, S.HasSlabs, 
 S.CreationDate, S.ModifiedDate, S.Approved, S.BudgetedAmount, S.customer, S.HappyScheme, 
 S.FromHour, S.ToHour, S.FromWeekday, S.ToWeekDay, S.FromDayMonth, S.ToDayMonth, S.PaymentMode, S.ApplyOn
 From SchemeItems SI, Schemes S
 Where   SI.SchemeID=@SchemeID and  SI.SchemeID = S.SchemeID   
    And ((@PRIMARYQUANTITY between SI.StartValue and SI.EndValue And IsNull(S.HasSlabs, 0) = 1) Or    
    (ISNULL(S.HasSlabs, 0) = 0 and @PRIMARYQUANTITY >= SI.StartValue))    
 END  
ELSE  
 BEGIN  
 Select S.SchemeID, SI.StartValue, SI.EndValue, (Case IsNull(SI.FreeUOM,0) 
	when 0 Then IsNull(SI.FreeValue,0)
	When 1 Then IsNull(SI.FreeValue,0) * (Select UOM1_Conversion From Items Where Items.Product_Code = SI.FreeItem)
	When 2 Then IsNull(SI.FreeValue,0) * (Select UOM2_Conversion From Items Where Items.Product_Code = SI.FreeItem) end) as FreeValue,
 SI.FreeItem, SI.CreationDate, SI.modifiedDate, 
 SI.FromItem, SI.ToItem, SI.PrimaryUOM, SI.FreeUOM, S.SchemeID, S.SchemeNAme, S.SchemeType, S.ValidFrom, 
 S.ValidTo, S.PromptOnly, S.Message, S.Active, S.SchemeDescription, S.SecondaryScheme, S.HasSlabs, 
 S.CreationDate, S.ModifiedDate, S.Approved, S.BudgetedAmount, S.customer, S.HappyScheme, 
 S.FromHour, S.ToHour, S.FromWeekday, S.ToWeekDay, S.FromDayMonth, S.ToDayMonth, S.PaymentMode, S.ApplyOn
 From SchemeItems SI, Schemes S
 Where   SI.SchemeID=@SchemeID 
	and  SI.SchemeID = S.SchemeID
And 
(
(@PRIMARYQUANTITY between SI.FromItem and SI.ToItem And ( (IsNull(S.HasSlabs, 0) = 1) or (S.SchemeType In (97,99)) ) ) 
Or    
(ISNULL(S.HasSlabs, 0) = 0 and @PRIMARYQUANTITY >= SI.FromItem and S.SchemeType Not In (97,99))
) 
And
(
(@INVOICEAMOUNT between SI.StartValue and SI.EndValue And IsNull(S.HasSlabs, 0) = 1) 
Or
(ISNULL(S.HasSlabs, 0) = 0 and @INVOICEAMOUNT >= SI.StartValue)
)

 END  
END

