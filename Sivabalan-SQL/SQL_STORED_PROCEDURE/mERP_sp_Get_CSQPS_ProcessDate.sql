Create Procedure mERP_sp_Get_CSQPS_ProcessDate
As 
Begin
  Select Case IsNull(Max(InvoiceDate),'') When '' Then GETDATE() Else Max(InvoiceDate) End 
  From InvoiceAbstract where InvoiceType In (1,2,3) And (Status & 128)=0  
End
