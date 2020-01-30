CREATE procedure sp_ser_updatedirinvoicejcdetail (@InvoiceID as int, 
@ProductCode as nvarchar(50), @ItemSpec1 as nvarchar(50),  @personnelID as varchar(50))
as
Update JD Set Inspectedby = @personnelID from JobcardDetail JD 
Inner Join JobcardAbstract JA on JA.JobcardID = JD.JobcardID 
Inner Join ServiceInvoiceAbstract i On i.ServiceInvoiceID = JA.ServiceInvoiceID 
and i.JobcardID = JA.JobcardID 
Where Product_Specification1 = @ItemSpec1 and Product_Code = @ProductCode and 
i.ServiceInvoiceID = @InvoiceID and JD.Type = 0

Select @@Rowcount 



