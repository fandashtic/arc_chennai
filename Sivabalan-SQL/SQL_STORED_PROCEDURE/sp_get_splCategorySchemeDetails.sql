CREATE Procedure sp_get_splCategorySchemeDetails   
(	@SCHEMEID INT,  
 	@PRIMARYQUANTITY Decimal(18,6),
	@INVOICEAMOUNT Decimal(18,6)=0
)   
As 
BEGIN 
IF @INVOICEAMOUNT=0
	BEGIN
	Select * From SchemeItems, Schemes  
	Where   SchemeItems.SchemeID=@SchemeID and  SchemeItems.SchemeID = Schemes.SchemeID 
	  	And ((@PRIMARYQUANTITY between StartValue and EndValue And IsNull(Schemes.HasSlabs, 0) = 1) Or  
	 		(ISNULL(Schemes.HasSlabs, 0) = 0 and @PRIMARYQUANTITY >= SchemeItems.StartValue))  
	END

ELSE
	BEGIN
	Select * From SchemeItems, Schemes  
	Where   SchemeItems.SchemeID=@SchemeID and  SchemeItems.SchemeID = Schemes.SchemeID 
	  	And ((@PRIMARYQUANTITY between FromItem and ToItem And IsNull(Schemes.HasSlabs, 0) = 1) Or  
	 		(ISNULL(Schemes.HasSlabs, 0) = 0 and @PRIMARYQUANTITY >= SchemeItems.FromItem))  
		And @INVOICEAMOUNT between StartValue and EndValue
	END
END

