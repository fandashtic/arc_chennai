Create Procedure sp_ser_updateissue_fmcg (@InvoiceID int)
as
declare @retval int
If exists(select * from ServiceInvoiceDetail Where ServiceInvoiceId = @InvoiceId and Isnull(SpareCode, '') <> '')
Begin 
	/* Procedur to Update Price  in Issuedetail */
	Update IssDet Set MRP =  Isnull(I.MRP, 0) 
	from IssueDetail IssDet
	Inner Join Items I On I.Product_Code = IssDet.SpareCode
	Where 
	IssDet.IssueId in (Select d.IssueID from ServiceInvoiceDetail d 
				Where d.ServiceInvoiceId = @InvoiceID) 
	and Isnull(SpareCode, '') <> '' 
	set @retval = @@rowcount 
end
else
	set @retval = 1

Select @retval 

