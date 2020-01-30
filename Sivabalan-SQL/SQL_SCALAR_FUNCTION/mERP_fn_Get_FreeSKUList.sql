Create Function mERP_fn_Get_FreeSKUList(@SlabID int)
Returns nVarchar(2000)
Begin
Declare @FreeSKU as nvarchar(3000)
Declare @SKUCode as nvarchar(100)

set @FreeSKU=''
Declare FreeSKU Cursor FOR
select SKUCode from tbl_mERP_SchemeFreeSKU where SlabID =@SlabID
Open FreeSKU 
FETCH From FreeSKU Into @SKUCode
While @@FETCH_STATUS = 0 
Begin
  If @FreeSKU=''
    Set @FreeSKU = @SKUCode
  Else	
    Set @FreeSKU = @FreeSKU + '|' + @SKUCode
 
  FETCH From FreeSKU Into @SKUCode
End 
close FreeSKU
Deallocate FreeSKU

Return @FreeSKU

End
