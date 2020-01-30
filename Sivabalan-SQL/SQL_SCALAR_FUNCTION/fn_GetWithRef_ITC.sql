Create Function fn_GetWithRef_ITC(@RefNo nVarchar(256))
Returns Int 
As
Begin
Declare @Count Int 
Set @Count = 0 

Select @RefNo = Case IsNull(@RefNo, '') When '' Then ' ' Else @RefNo End 

Select @Count = Count(*) From InvoiceAbstract  
		 Where (InvoiceAbstract.Status & 128) = 0 And DocumentID = 
		Cast(IsNull(Reverse(left(reverse(@RefNo), Case When PATINDEX( N'%[^0-9]%',Reverse(@RefNo)) > 0 Then 
			 PATINDEX( N'%[^0-9]%',Reverse(@RefNo)) -1 Else Len(@RefNo) End )), 0) As Integer)
		
Return @Count

End

