Create procedure sp_get_SchemeInvoiceDetail_MUOM 
                (@SCHEMEID as INT,  
                 @AMOUNT as Decimal(18,6))  
As  
Select SI.SchemeID, StartValue, EndValue, 
	(Case IsNull(FreeUOM,0) 
	When 0 then FreeValue 
	When 1 then FreeValue * IsNull((Select IsNull(Uom1_conversion,1) From Items Where Product_code = IsNull(SI.FreeItem,'')),1)
	When 2 then FreeValue * IsNull((Select IsNull(Uom2_conversion,1) From Items Where Product_code = IsNull(SI.FreeItem,'')),1) End ) FreeValue, 
	FreeItem, SI.CreationDate, SI.ModifiedDate, FromItem, ToItem
from SchemeItems SI, Schemes S
where S.SchemeID=SI.SchemeID
And SI.schemeID=@schemeID and 
((S.HasSlabs = 0 and @AMOUNT >=SI.StartValue) or (S.HasSlabs = 1 and @AMOUNT between SI.StartValue and SI.EndValue))
--@AMOUNT between startvalue and endvalue  

