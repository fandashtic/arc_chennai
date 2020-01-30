CREATE Procedure sp_Get_Tax_Info (@ID Int)
As
Declare @STax Int
Declare @STDesc nvarchar(255)
Declare @PTax Int
Declare @PTDesc nvarchar(255)

Select top 1 @STax = Tax_Code, @STDesc = Tax_Description 
From Tax, ItemsReceivedDetail Where IsNull(Tax.GSTFlag,0) = 0 And Tax.Percentage = ItemsReceivedDetail.STLST  
And Tax.CST_Percentage = ItemsReceivedDetail.STCST 
And Tax.LSTApplicableOn = ItemsReceivedDetail.STLSTApplicableOn 
And Tax.LSTPartOff = ItemsReceivedDetail.STLSTPartOff 
And Tax.CSTApplicableOn = ItemsReceivedDetail.STCSTApplicableOn 
And Tax.CSTPartOff = ItemsReceivedDetail.STCSTPartOff 
And ItemsReceivedDetail.ID = @ID and tax.active = 1 order by tax.tax_code desc 

Select top 1 @PTax = Tax_Code, @PTDesc = Tax_Description 
From Tax, ItemsReceivedDetail Where IsNull(Tax.GSTFlag,0) = 0 And Tax.Percentage = ItemsReceivedDetail.PTLST  
And Tax.CST_Percentage = ItemsReceivedDetail.PTCST 
And Tax.LSTApplicableOn = ItemsReceivedDetail.PTLSTApplicableOn 
And Tax.LSTPartOff = ItemsReceivedDetail.PTLSTPartOff 
And Tax.CSTApplicableOn = ItemsReceivedDetail.PTCSTApplicableOn 
And Tax.CSTPartOff = ItemsReceivedDetail.PTCSTPartOff 
And ItemsReceivedDetail.ID = @ID and tax.active = 1 order by tax.tax_code desc

If @STax <> 0
	Update ItemsReceivedDetail Set STDesc = @STDesc Where ID = @ID
If @PTax <> 0
	Update ItemsReceivedDetail Set PTDesc = @PTDesc Where ID = @ID
Select STDesc, STLST, STCST, PTDesc, PTLST, PTCST, IsNull(@STax, 0), IsNull(@PTax, 0),
IsNull(STLSTApplicableOn,1) as STLSTApplicableOn, IsNull(STLSTPartOff,100) as STLSTPartOff, 
IsNull(STCSTApplicableOn,1) as STCSTApplicableOn, IsNull(STCSTPartOff,100) as STCSTPartOff, 
IsNull(PTLSTApplicableOn,1) as PTLSTApplicableOn, IsNull(PTLSTPartOff,100) as PTLSTPartOff, 
IsNull(PTCSTApplicableOn,1) as PTCSTApplicableOn, IsNull(PTCSTPartOff,100) as PTCSTPartOff 
From ItemsReceivedDetail Where ID = @ID

