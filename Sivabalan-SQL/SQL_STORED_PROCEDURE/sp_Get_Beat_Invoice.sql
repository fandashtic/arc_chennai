CREATE Procedure sp_Get_Beat_Invoice @InvoiceID nvarchar(30)   
as  
SELECT Beat.Description FROM InvoiceAbstract  
INNER JOIN Beat ON  
 Beat.BeatID = InvoiceAbstract.BeatID  
Where InvoiceAbstract.InvoiceID = @InvoiceID  

