Create Procedure mERP_SP_Tally_GetTaxAccountName_Trans(@Tax_Description nvarchar(255),@type nvarchar(100))
AS
BEGIN
	Declare @AccountName nvarchar(255)
	if exists(Select 'x' from TallyTaxDetails where ForumDesc=@Tax_Description and isnull(TallyDesc,'') <> '')
	Begin
		Select @AccountName =TallyDesc from TallyTaxDetails where ForumDesc=@Tax_Description and Taxtype=@type
	End
	ELSE
	Begin
		Select Top 1 @AccountName= cast(@type as nvarchar(100))+ ' VAT @'+CAST(CAST(Percentage AS float)as VARCHAR(10))+'%' from Tax Where Tax_Description=@Tax_Description
	End
	Select @AccountName
END
