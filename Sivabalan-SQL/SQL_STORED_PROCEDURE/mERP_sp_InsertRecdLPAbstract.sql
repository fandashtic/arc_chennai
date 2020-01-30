Create Procedure mERP_sp_InsertRecdLPAbstract(@DocNumber nVarchar(30), @DocDate DateTime, @CompanyFrom nVarchar(30), @DocType nVarchar(30))
As
Begin
  Insert into LP_RecdDocAbstract(CompanyID, DocumentID, DocumentDate, DocType)
  Values (@CompanyFrom, Cast(@DocNumber as int), @DocDate ,  @DocType)
  Select @@Identity
End
