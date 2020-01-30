Create Procedure mERP_SP_SaveTallyTaxDetails @Forumdescription nvarchar(255),@Taxtype nvarchar(100), 
@TallyDescription nvarchar(255)
AS
BEGIN
	If exists(Select 'x' from TallyTaxDetails where ForumDesc= @Forumdescription and @Taxtype=Taxtype)	
	Begin
		update TallyTaxDetails set TallyDesc=@TallyDescription where ForumDesc= @Forumdescription and @Taxtype=Taxtype
	End
	Else
	Begin
		insert into TallyTaxDetails(Taxtype,ForumDesc,TallyDesc)
		Select @Taxtype,@Forumdescription,@TallyDescription
	End
END 
