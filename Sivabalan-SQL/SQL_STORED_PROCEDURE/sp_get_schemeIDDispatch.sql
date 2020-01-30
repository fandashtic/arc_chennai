CREATE Procedure sp_get_schemeIDDispatch
                 (@ItemCode as nvarchar (15),
                  @Serverdate as DATETIME,
                  @QUANTItY as Decimal(18,6),
                  @SAMEITEM as INT,
                  @DIFFITEM as INT,
	  				   @CustomerId as nvarchar(30) = N''
						)
AS
IF (Select count(*) from ItemSchemes i,Schemes s where Active=1 and 
    @Serverdate between ValidFrom and ValidTo and 
   (Isnull(s.Customer,0) = 0 or @CustomerId = N'' or 
	Isnull((Select Count(*) from SchemeCustomers Where CustomerId = @CustomerID and s.schemeid = schemecustomers.schemeid) ,0) > 0) and 
    (SchemeType = @SAMEITEM or schemeType= @DIFFITEM) and 
    i.Product_Code=@ItemCode and i.SchemeID=s.SchemeID and 
    (Select count(*) from schemeItems where SchemeItems.SchemeID = i.SchemeID and
    ((@Quantity between SchemeItems.StartValue And SchemeItems.EndValue and ISNULL(s.HasSlabs, 0) = 1) or (ISNULL(s.HasSlabs, 0) = 0 and @Quantity >= SchemeItems.StartValue)) ) > 0 and
	s.SchemeType between 17 and 20) = 1
BEGIN
    SELECT 0
END
ELSE
BEGIN
    SELECT 1
END
Select i.SchemeID,s.SchemeName,s.SchemeType,s.PromptOnly,s.Message from 
ItemSchemes i,Schemes s where Active=1 and 
(Isnull(s.Customer,0) = 0 or @CustomerId = N'' or 
	Isnull((Select Count(*) from SchemeCustomers Where CustomerId = @CustomerID and s.schemeid = schemecustomers.schemeid) ,0) > 0) and 
@Serverdate between ValidFrom and ValidTo and 
(SchemeType = @SAMEITEM or schemeType= @DIFFITEM) and 
i.Product_Code=@ItemCode and i.SchemeID=s.SchemeID and 
(Select count(*) from schemeItems where SchemeItems.SchemeID = i.SchemeID and 
((@Quantity between SchemeItems.StartValue and SchemeItems.EndValue and ISNULL(s.HasSlabs, 0) = 1) or (ISNULL(s.HasSlabs, 0) = 0 and @Quantity >= SchemeItems.StartValue))) > 0
and s.SchemeType between 17 and 20


