
CREATE procedure sp_get_DefineSchemeItems
 as
select ItemSchemes.SchemeID,Schemes.SchemeName,ItemSchemes.Product_Code,Items.ProductName from ItemSchemes,Schemes,Items where Items.Product_Code=ItemSchemes.Product_Code and Schemes.SchemeID=ItemSchemes.SchemeID order by Items.ProductName asc


