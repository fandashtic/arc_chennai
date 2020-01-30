Create Function mERP_FN_Tally_GetTaxAccountName_Input(@Tax_Description nvarchar(255))  
Returns nvarchar(255)  
AS  
BEGIN  
 Declare @AccountName nvarchar(255)  
 if exists(Select 'x' from TallyTaxDetails where ForumDesc=@Tax_Description and isnull(TallyDesc,'') <> '')  
 Begin  
  Select @AccountName =TallyDesc from TallyTaxDetails where ForumDesc=@Tax_Description and Taxtype='Input'  
 End  
 Return @AccountName  
END  
