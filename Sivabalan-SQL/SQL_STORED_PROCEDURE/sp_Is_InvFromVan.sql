CREATE Procedure [dbo].[sp_Is_InvFromVan] (@InvNo Int)  
As  
Select ReferenceNumber, NewReference, Isnull(InvoiceAbstract.BeatID,0), Isnull(Beat.Description   ,N'')
From InvoiceAbstract
Left Outer Join Beat   on InvoiceAbstract.BeatID = Beat.BeatID
Where InvoiceID = @InvNo And   
Status & 16 <> 0 And  
InvoiceType In (1, 3) 
--And InvoiceAbstract.BeatID *= Beat.BeatID 

