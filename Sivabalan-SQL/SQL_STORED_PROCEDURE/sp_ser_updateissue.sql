CREATE Procedure sp_ser_updateissue(@InvoiceID int )
as
declare @retval int
If exists(select * from ServiceInvoiceDetail Where ServiceInvoiceId = @InvoiceId and Isnull(SpareCode, '') <> '')
Begin 
	/* Procedur to Update Price --PTS PTR ECP-- in Issuedetail */
	Update IssDet Set 
	PTR = (case Isnull(IssDet.Batch_Code,0) 
			When 0 then Isnull(I.PTR, 0) else Isnull(b.PTR, 0) end), 
	PTS = (case Isnull(IssDet.Batch_Code,0) 
			When 0 then Isnull(I.PTS, 0) else Isnull(b.PTS, 0) end), 
	MRP = (case Isnull(IssDet.Batch_Code,0) 
			When 0 then Isnull(I.MRP, 0) else Isnull(b.ECP, 0) end)
	from IssueDetail IssDet
	Inner Join Items I On I.Product_Code = IssDet.SpareCode
	Left outer Join Batch_products b On b.Batch_Code = IssDet.Batch_Code 
	Where 
	IssDet.IssueId in (Select d.IssueID from ServiceInvoiceDetail d 
				Where d.ServiceInvoiceId = @InvoiceID) 
	and Isnull(IssDet.SpareCode, '') <> '' 
	set @retval = @@rowcount 
end
else
	set @retval = 1

Select @retval 

