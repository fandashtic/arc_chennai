Create Function mERP_FN_Tally_GetTaxAccountName(@Tax_Description nvarchar(255))
Returns nvarchar(255)
AS
BEGIN
	Declare @AccountName nvarchar(255)
	if exists(Select 'x' from TallyTaxDetails where ForumDesc=@Tax_Description and isnull(TallyDesc,'') <> '')
	Begin
		Select @AccountName =TallyDesc from TallyTaxDetails where ForumDesc=@Tax_Description and Taxtype='output'
	End
	ELSE
	Begin
		Select Top 1 @AccountName= 'Output VAT @'+CAST(CAST(Percentage AS float)as VARCHAR(10))+'%' from Tax Where Tax_Description=@Tax_Description
	End
	Return @AccountName
END
