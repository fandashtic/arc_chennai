Create Procedure mERP_Sp_GetMarginDocumentNumber
As
Begin
   select isnull(Max(MarginID),0)+1 from MarginAbstract
End
