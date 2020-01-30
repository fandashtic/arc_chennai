CREATE ProcEDURE [sp_put_InvoiceTaxDetails]( 
  @InvoiceID  [nvarchar](20),   
  @ForumCode [nvarchar](15),          
  @InvDetSerial  [int],    
  @TaxCode  [int],          
  @TaxComponentCode  [int],          
  @TaxAmount  Decimal(18,6)          
  )          
AS           

Declare @Status int
set @Status = 0 
            

INSERT INTO Recd_InvoiceTaxComponents           
  (     
   InvoiceNumber ,
	SystemSKUCode ,
	InvDetSerial ,
	CS_TaxCode ,
	CS_ComponentCode ,
	TaxAmount ,
	Status
	)           
           
VALUES           
 ( 
  @InvoiceID,       
  @ForumCode ,
  @InvDetSerial ,
  @TaxCode  ,          
  @TaxComponentCode  ,          
  @TaxAmount  ,          
  @Status
)          

