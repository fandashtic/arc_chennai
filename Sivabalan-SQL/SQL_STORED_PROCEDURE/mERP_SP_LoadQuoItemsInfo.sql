Create Procedure mERP_SP_LoadQuoItemsInfo(@ItemCode nvarchar(100))
as
Begin
	select ECP,(select Percentage from Tax where Tax_Code=Sale_Tax),PTS,PTR,Sale_Tax,Isnull(TOQ_Sales,0) TOQ_Sales from Items where Product_Code=@ItemCode
End
