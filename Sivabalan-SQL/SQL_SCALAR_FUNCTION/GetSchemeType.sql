CREATE Function GetSchemeType(@SchemeType Int)
Returns nvarchar(255)
As
Begin
Declare @SchType nvarchar(255)
Select @SchType=Case @SchemeType
When  1  then 'INVOICEBASED_AMOUNT'
When  2  then 'INVOICEBASED_PERCENTAGE'
When  3  then 'INVOICEBASED_FREE_ITEMS'
When  4  then 'INVOICEBASED_ITEMWORTH_X_AMOUNT_FREE'
When  17 then 'ITEMBASED_FREE_SAME_ITEMS'
When  18 then 'ITEMBASED_FREE_DIFF_ITEMS'
When  19 then 'ITEMBASED_PERCENTAGE'
When  20 then 'ITEMBASED_AMOUNT'
When  21 then 'ITEMBASED_PERCENTAGE_CHEAPER_ITEM'
When  22 then 'ITEMBASED_PERCENTAGE_EXPENSIVE_ITEM'
When  33 then 'OFFTAKE_INVOICEBASED_AMOUNT'
When  34 then 'OFFTAKE_INVOICEBASED_PERCENTAGE'
When  35 then 'OFFTAKE_INVOICEBASED_FREE_ITEMS'
When  49 then 'OFFTAKE_ITEMBASED_FREE_SAME_ITEMS'
When  50 then 'OFFTAKE_ITEMBASED_FREE_DIFF_ITEMS'
When  51 then 'OFFTAKE_ITEMBASED_PERCENTAGE'
When  52 then 'OFFTAKE_ITEMBASED_AMOUNT'
When  65 then 'DISPLAY_SCHEME'
When  81 then 'VALUE_BASED_PERCENTAGE_DISCOUNT'
When  82 then 'VALUE_BASED_AMOUNT_DISCOUNT'
When  83 then 'VALUE_BASED_SAME_FREE_ITEMS'
When  84 then 'VALUE_BASED_DIFF_FREE_ITEMS'
When  97 then 'QTY_BASED_FREE_ITEMS'
When  98 then 'QTY_BASED_PERCENTAGE_DISCOUNT'
When  99 then 'VAL_BASED_FREE_ITEMS'
When 100 then 'VAL_BASED_PERCENTAGE_DISCOUNT' End
Return @SchType
End


