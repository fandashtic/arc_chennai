
Create Procedure mERP_SP_SaveInvoiceReportCustomer (@CustomerID nVarchar(Max), @Flag Int)
AS
BEGIN
Create Table #TempInvoiceReportCustomer_Mapping(CustomeName nVarchar(Max))

If Isnull(@Flag,0) = 1
Begin
Truncate Table InvoiceReportCustomer_Mapping
insert into InvoiceReportCustomer_Mapping(CustomerID)
Select Itemvalue from dbo.sp_SplitIn2Rows(@CustomerID, ',' )
End
Else
Begin
insert into #TempInvoiceReportCustomer_Mapping(CustomeName)
Select Itemvalue from dbo.sp_SplitIn2Rows(@CustomerID, ',' )

Truncate Table InvoiceReportCustomer_Mapping

insert into InvoiceReportCustomer_Mapping(CustomerID)
Select customerID from Customer C
Inner Join #TempInvoiceReportCustomer_Mapping M on C.Company_Name = RTrim(LTrim(M.CustomeName))

End
Drop Table #TempInvoiceReportCustomer_Mapping
END
