CREATE Procedure Sp_List_SchemeToClaimAbstract(@SchemeID int)
As

Declare @OFFTAKEINVOICEBASED As NVarchar(50)
Declare @OFFTAKEITEMBASED As NVarchar(50)
Declare @DISPLAY As NVarchar(50)
Declare @AMOUNT As NVarchar(50)
Declare @PERCENTAGE As NVarchar(50)
Declare @FREEITEMSFORVALUE As NVarchar(50)
Declare @SAMEPRODUCTFREE As NVarchar(50)
Declare @DIFFERENTPRODUCTFREE As NVarchar(50)

Set @OFFTAKEINVOICEBASED = dbo.LookupDictionaryItem(N'Off take Invoice Based', Default)
Set @OFFTAKEITEMBASED = dbo.LookupDictionaryItem(N'Off take Item Based', Default)
Set @DISPLAY = dbo.LookupDictionaryItem(N'Display', Default)
Set @AMOUNT = dbo.LookupDictionaryItem(N'Amount', Default)
Set @PERCENTAGE = dbo.LookupDictionaryItem(N'Percentage', Default)
Set @FREEITEMSFORVALUE = dbo.LookupDictionaryItem(N'Free Items For Value', Default)
Set @SAMEPRODUCTFREE = dbo.LookupDictionaryItem(N'Same Product Free', Default)
Set @DIFFERENTPRODUCTFREE = dbo.LookupDictionaryItem(N'Different Product Free', Default)

Select SchemeType,
"SchType"=Case When SchemeType/16=2 Then @OFFTAKEINVOICEBASED 
When SchemeType/16=3 Then @OFFTAKEITEMBASED
Else @DISPLAY End,
"SchemeSubtype"=
Case When (SchemeType /16 =2) Then (Case (SchemeType%16) When 1 then @AMOUNT
When 2 then @PERCENTAGE Else @FREEITEMSFORVALUE End)
When (SchemeType /16 =3) Then	(Case (SchemeType%16) When 4 then @AMOUNT
When 3 then @PERCENTAGE When 1 then @SAMEPRODUCTFREE Else @DIFFERENTPRODUCTFREE End)
Else N'' End,
ValidFrom,ValidTo,Customer
From Schemes 
Where Schemeid=@SchemeId

