
Create procedure sp_get_SchemeInvoiceDetail
                (@SCHEMEID as INT,
                 @AMOUNT as Decimal(18,6))
As
Select * from SchemeItems where schemeID=@schemeID and @AMOUNT between startvalue and endvalue


